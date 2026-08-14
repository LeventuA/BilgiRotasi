part of 'main.dart';

enum PushEnvironment { test, development, closedTest, production }

class PushRuntimePolicy {
  PushRuntimePolicy._();

  static const String explicitEnvironment = String.fromEnvironment(
    'PUSH_ENVIRONMENT',
    defaultValue: '',
  );

  static PushEnvironment resolveEnvironment({
    required String explicit,
    required String adMob,
    required String firebase,
  }) {
    final selected = explicit.trim().toLowerCase();
    if (selected.isNotEmpty) {
      return switch (selected) {
        'production' => PushEnvironment.production,
        'closed_test' => PushEnvironment.closedTest,
        'development' => PushEnvironment.development,
        _ => PushEnvironment.test,
      };
    }

    return switch (adMob.trim().toLowerCase()) {
      'production' => PushEnvironment.production,
      'closed_test' => PushEnvironment.closedTest,
      _ when firebase.trim().toLowerCase() == 'development' =>
        PushEnvironment.development,
      _ => PushEnvironment.test,
    };
  }

  static PushEnvironment get environment => resolveEnvironment(
    explicit: explicitEnvironment,
    adMob: AdMobConfig.environment,
    firebase: FirebaseRuntimePolicy.rawEnvironment,
  );

  static bool get remoteMessagingEnabled =>
      FirebaseRuntimePolicy.remoteFirebaseEnabled &&
      environment != PushEnvironment.test;

  static String? topicFor(PushEnvironment value) {
    return switch (value) {
      PushEnvironment.test => null,
      PushEnvironment.development => 'bilgi_rotasi_announcements_dev',
      PushEnvironment.closedTest => 'bilgi_rotasi_announcements_closed_test',
      PushEnvironment.production => 'bilgi_rotasi_announcements_production',
    };
  }

  static String? get topic => topicFor(environment);
}

enum PushPermissionState { granted, denied, notDetermined }

enum PushEnableResult { enabled, disabled, denied, unavailable, failed }

abstract interface class PushMessagingGateway {
  Future<PushPermissionState> currentPermission();

  Future<PushPermissionState> requestPermission();

  Future<void> setAutoInitEnabled(bool enabled);

  Future<void> subscribeToTopic(String topic);

  Future<void> unsubscribeFromTopic(String topic);

  Future<void> deleteToken();
}

abstract interface class PushPreferenceStore {
  Future<bool> readEnabled();

  Future<void> writeEnabled(bool enabled);
}

class PushSubscriptionCoordinator {
  PushSubscriptionCoordinator({
    required this.gateway,
    required this.store,
    required this.topic,
  });

  final PushMessagingGateway gateway;
  final PushPreferenceStore store;
  final String? topic;

  Future<PushEnableResult> restore() async {
    if (topic == null) return PushEnableResult.unavailable;
    if (!await store.readEnabled()) {
      await gateway.setAutoInitEnabled(false);
      return PushEnableResult.disabled;
    }

    try {
      await gateway.setAutoInitEnabled(true);
      if (await gateway.currentPermission() != PushPermissionState.granted) {
        await _clearLocalChoice();
        return PushEnableResult.denied;
      }
      await gateway.subscribeToTopic(topic!);
      return PushEnableResult.enabled;
    } catch (_) {
      return PushEnableResult.failed;
    }
  }

  Future<PushEnableResult> setEnabled(bool enabled) async {
    if (topic == null) return PushEnableResult.unavailable;
    if (!enabled) {
      await _clearLocalChoice();
      return PushEnableResult.disabled;
    }

    try {
      await gateway.setAutoInitEnabled(true);
      final permission = await gateway.requestPermission();
      if (permission != PushPermissionState.granted) {
        await _clearLocalChoice();
        return PushEnableResult.denied;
      }
      await gateway.subscribeToTopic(topic!);
      await store.writeEnabled(true);
      return PushEnableResult.enabled;
    } catch (_) {
      await _clearLocalChoice();
      return PushEnableResult.failed;
    }
  }

  Future<void> _clearLocalChoice() async {
    try {
      if (topic != null) await gateway.unsubscribeFromTopic(topic!);
    } catch (_) {
      // Yerel kapatma kararı uzak abonelik hatasından bağımsız saklanır.
    }
    try {
      await gateway.deleteToken();
    } catch (_) {
      // Token silme hatası uygulamayı veya ayar değişikliğini engellemez.
    }
    try {
      await gateway.setAutoInitEnabled(false);
    } catch (_) {
      // SDK hatası kullanıcı tercihinin kaydedilmesini engellemez.
    }
    try {
      await store.writeEnabled(false);
    } catch (_) {
      // Yerel depolama hatası oyun akışına veya ayar ekranına taşınmaz.
    }
  }
}

class _FirebasePushMessagingGateway implements PushMessagingGateway {
  _FirebasePushMessagingGateway(this.messaging);

  final FirebaseMessaging messaging;

  @override
  Future<PushPermissionState> currentPermission() async {
    return _mapPermission(
      (await messaging.getNotificationSettings()).authorizationStatus,
    );
  }

  @override
  Future<PushPermissionState> requestPermission() async {
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    return _mapPermission(settings.authorizationStatus);
  }

  PushPermissionState _mapPermission(AuthorizationStatus status) {
    return switch (status) {
      AuthorizationStatus.authorized ||
      AuthorizationStatus.provisional => PushPermissionState.granted,
      AuthorizationStatus.denied => PushPermissionState.denied,
      AuthorizationStatus.notDetermined => PushPermissionState.notDetermined,
    };
  }

  @override
  Future<void> deleteToken() => messaging.deleteToken();

  @override
  Future<void> setAutoInitEnabled(bool enabled) =>
      messaging.setAutoInitEnabled(enabled);

  @override
  Future<void> subscribeToTopic(String topic) =>
      messaging.subscribeToTopic(topic);

  @override
  Future<void> unsubscribeFromTopic(String topic) =>
      messaging.unsubscribeFromTopic(topic);
}

class _SharedPreferencesPushStore implements PushPreferenceStore {
  static const String preferenceKey = 'push_notifications_enabled_v1';

  @override
  Future<bool> readEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(preferenceKey) == true;
  }

  @override
  Future<void> writeEnabled(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(preferenceKey, enabled);
  }
}

enum PushNotificationState { unavailable, disabled, enabled, denied, error }

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!PushRuntimePolicy.remoteMessagingEnabled) return;
  try {
    if (Firebase.apps.isEmpty) await Firebase.initializeApp();
  } catch (_) {
    // Background notification payload is still handled by Android/FCM.
  }
}

class PushNotificationService {
  PushNotificationService._();

  static final ValueNotifier<PushNotificationState> state =
      ValueNotifier<PushNotificationState>(PushNotificationState.unavailable);
  static PushSubscriptionCoordinator? _coordinator;
  static StreamSubscription<RemoteMessage>? _foregroundSubscription;
  static StreamSubscription<RemoteMessage>? _openedSubscription;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    if (!Platform.isAndroid || !PushRuntimePolicy.remoteMessagingEnabled) {
      state.value = PushNotificationState.unavailable;
      return;
    }

    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
      final messaging = FirebaseMessaging.instance;
      _coordinator = PushSubscriptionCoordinator(
        gateway: _FirebasePushMessagingGateway(messaging),
        store: _SharedPreferencesPushStore(),
        topic: PushRuntimePolicy.topic,
      );
      state.value = _stateFor(await _coordinator!.restore());

      _foregroundSubscription = FirebaseMessaging.onMessage.listen(
        _showForegroundMessage,
      );
      _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
        _handleOpenedMessage,
      );
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) _handleOpenedMessage(initialMessage);
    } catch (_) {
      state.value = PushNotificationState.error;
    }
  }

  static Future<PushEnableResult> setEnabled(bool enabled) async {
    if (!_initialized) await initialize();
    final coordinator = _coordinator;
    if (coordinator == null) return PushEnableResult.unavailable;
    final result = await coordinator.setEnabled(enabled);
    state.value = _stateFor(result);
    return result;
  }

  static PushNotificationState _stateFor(PushEnableResult result) {
    return switch (result) {
      PushEnableResult.enabled => PushNotificationState.enabled,
      PushEnableResult.disabled => PushNotificationState.disabled,
      PushEnableResult.denied => PushNotificationState.denied,
      PushEnableResult.unavailable => PushNotificationState.unavailable,
      PushEnableResult.failed => PushNotificationState.error,
    };
  }

  static void _showForegroundMessage(RemoteMessage message) {
    if (state.value != PushNotificationState.enabled) return;
    final notification = message.notification;
    if (notification == null) return;
    final title = PushMessageText.normalize(notification.title, limit: 80);
    final body = PushMessageText.normalize(notification.body, limit: 240);
    if (title.isEmpty && body.isEmpty) return;

    final context = AnalyticsConsentService.navigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 8),
          content: Text(
            title.isEmpty ? body : (body.isEmpty ? title : '$title\n$body'),
          ),
        ),
      );
  }

  static void _handleOpenedMessage(RemoteMessage message) {
    // İlk sürümde bildirim yalnız uygulamayı güvenle açar. Dış veriden route
    // üretilmez; böylece geçersiz veya beklenmeyen payload crash oluşturamaz.
  }

  @visibleForTesting
  static Future<void> resetForTesting() async {
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
    _foregroundSubscription = null;
    _openedSubscription = null;
    _coordinator = null;
    _initialized = false;
    state.value = PushNotificationState.unavailable;
  }
}

class PushMessageText {
  PushMessageText._();

  static String normalize(String? value, {required int limit}) {
    final normalized = (value ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= limit) return normalized;
    return normalized.substring(0, limit).trimRight();
  }
}

class PushNotificationSettingsCard extends StatelessWidget {
  const PushNotificationSettingsCard({super.key});

  Future<void> _update(BuildContext context, bool enabled) async {
    final result = await PushNotificationService.setEnabled(enabled);
    if (!context.mounted) return;
    final message = switch (result) {
      PushEnableResult.enabled => 'Genel duyuru bildirimleri açıldı.',
      PushEnableResult.disabled => 'Genel duyuru bildirimleri kapatıldı.',
      PushEnableResult.denied =>
        'Bildirim izni verilmedi. Oyun normal çalışmaya devam eder.',
      PushEnableResult.unavailable =>
        'Bu derlemede uzak bildirim bağlantısı kapalı.',
      PushEnableResult.failed =>
        'Bildirim ayarı şu anda güncellenemedi. Oyun etkilenmedi.',
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PushNotificationState>(
      valueListenable: PushNotificationService.state,
      builder: (context, current, _) {
        final enabled = current == PushNotificationState.enabled;
        final unavailable = current == PushNotificationState.unavailable;
        final subtitle = switch (current) {
          PushNotificationState.enabled =>
            'Açık • Genel duyurular bu cihaza gönderilebilir.',
          PushNotificationState.denied =>
            'Kapalı • Sistem izni verilmedi; oyun etkilenmez.',
          PushNotificationState.error =>
            'Kapalı • Bildirim hizmetine şu anda ulaşılamıyor.',
          PushNotificationState.unavailable =>
            'Bu test/debug derlemesinde uzak bildirim kapalı.',
          PushNotificationState.disabled =>
            'Kapalı • İzin yalnız bu anahtarı açtığında istenir.',
        };
        return Card(
          margin: const EdgeInsets.only(bottom: 7),
          child: SwitchListTile(
            value: enabled,
            onChanged:
                unavailable
                    ? null
                    : (value) => unawaited(_update(context, value)),
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Genel duyuru bildirimleri'),
            subtitle: Text(subtitle),
          ),
        );
      },
    );
  }
}
