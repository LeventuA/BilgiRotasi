part of 'main.dart';

enum PushEnvironment { test, development, closedTest, production }

class PushRuntimePolicy {
  PushRuntimePolicy._();

  static const String explicitEnvironment = String.fromEnvironment(
    'PUSH_ENVIRONMENT',
    defaultValue: '',
  );

  static const List<String> knownTopics = <String>[
    'bilgi_rotasi_announcements_dev',
    'bilgi_rotasi_announcements_closed_test',
    'bilgi_rotasi_announcements_production',
  ];

  static PushEnvironment resolveEnvironment({
    required String explicit,
    required String adMob,
    required String firebase,
  }) {
    final adMobProfile = adMob.trim().toLowerCase();
    final firebaseProfile = firebase.trim().toLowerCase();
    final inferred = switch (adMobProfile) {
      'production' when firebaseProfile == 'production' =>
        PushEnvironment.production,
      'closed_test' when firebaseProfile == 'production' =>
        PushEnvironment.closedTest,
      _ when adMobProfile == 'test' && firebaseProfile == 'development' =>
        PushEnvironment.development,
      _ => PushEnvironment.test,
    };

    final selected = explicit.trim().toLowerCase();
    if (selected.isEmpty) return inferred;
    final requested = switch (selected) {
      'production' => PushEnvironment.production,
      'closed_test' => PushEnvironment.closedTest,
      'development' => PushEnvironment.development,
      _ => PushEnvironment.test,
    };

    // PUSH_ENVIRONMENT yalnız daha geniş build profilini doğrulayabilir; tek
    // başına closed-test veya production erişimi açamaz. Yanlış/eski define
    // kombinasyonu güvenli biçimde uzak FCM'i kapatan test profiline düşer.
    return requested == inferred ? requested : PushEnvironment.test;
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

  Future<bool> readCleanupPending();

  Future<void> writeCleanupPending(bool pending);
}

class PushSubscriptionCoordinator {
  PushSubscriptionCoordinator({
    required this.gateway,
    required this.store,
    required this.topic,
    this.knownTopics = PushRuntimePolicy.knownTopics,
  });

  final PushMessagingGateway gateway;
  final PushPreferenceStore store;
  final String? topic;
  final List<String> knownTopics;

  Future<PushEnableResult> restore() async {
    if (topic == null) return PushEnableResult.unavailable;

    final enabled = await store.readEnabled();
    if (!enabled) {
      var autoInitDisabled = true;
      try {
        await gateway.setAutoInitEnabled(false);
      } catch (_) {
        autoInitDisabled = false;
      }

      var cleanupPending = false;
      try {
        cleanupPending = await store.readCleanupPending();
      } catch (_) {
        cleanupPending = true;
      }
      if (cleanupPending || !autoInitDisabled) {
        await _cleanupAllRemoteState();
      }
      return PushEnableResult.disabled;
    }

    try {
      await gateway.setAutoInitEnabled(true);
      if (await gateway.currentPermission() != PushPermissionState.granted) {
        await _clearLocalChoice();
        return PushEnableResult.denied;
      }
      if (!await _isolateCurrentTopic()) return PushEnableResult.failed;
      await gateway.subscribeToTopic(topic!);
      await _safeWriteCleanupPending(false);
      return PushEnableResult.enabled;
    } catch (_) {
      await _clearLocalChoice();
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
      if (!await _isolateCurrentTopic()) return PushEnableResult.failed;
      await gateway.subscribeToTopic(topic!);
      await store.writeEnabled(true);
      await _safeWriteCleanupPending(false);
      return PushEnableResult.enabled;
    } catch (_) {
      await _clearLocalChoice();
      return PushEnableResult.failed;
    }
  }

  Future<bool> _isolateCurrentTopic() async {
    var otherTopicsRemoved = true;
    for (final candidate in knownTopics) {
      if (candidate == topic) continue;
      try {
        await gateway.unsubscribeFromTopic(candidate);
      } catch (_) {
        otherTopicsRemoved = false;
      }
    }
    if (otherTopicsRemoved) {
      await _safeWriteCleanupPending(false);
      return true;
    }

    // Ortam topic'i temizlenemediyse eski tokenı sıfırlamak, aynı kurulumun
    // closed-test ve production topic'lerinde birlikte kalmasını engeller.
    try {
      await gateway.deleteToken();
      await _safeWriteCleanupPending(false);
      return true;
    } catch (_) {
      await _safeWriteCleanupPending(true);
      try {
        await gateway.setAutoInitEnabled(false);
      } catch (_) {
        // Başarısız uzak temizleme bir sonraki açılışta tekrar denenecek.
      }
      return false;
    }
  }

  Future<void> _clearLocalChoice() async {
    try {
      await store.writeEnabled(false);
    } catch (_) {
      // Yerel depolama hatası oyun akışına veya ayar ekranına taşınmaz.
    }
    await _cleanupAllRemoteState();
  }

  Future<bool> _cleanupAllRemoteState() async {
    var clean = true;
    try {
      await gateway.setAutoInitEnabled(false);
    } catch (_) {
      clean = false;
    }
    for (final candidate in knownTopics) {
      try {
        await gateway.unsubscribeFromTopic(candidate);
      } catch (_) {
        clean = false;
      }
    }
    try {
      await gateway.deleteToken();
    } catch (_) {
      clean = false;
    }
    await _safeWriteCleanupPending(!clean);
    return clean;
  }

  Future<void> _safeWriteCleanupPending(bool pending) async {
    try {
      await store.writeCleanupPending(pending);
    } catch (_) {
      // Cleanup durumu yazılamasa bile oyun ve ayar akışı etkilenmez.
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
  static const String cleanupPendingKey = 'push_notifications_cleanup_pending_v1';

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

  @override
  Future<bool> readCleanupPending() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(cleanupPendingKey) == true;
  }

  @override
  Future<void> writeCleanupPending(bool pending) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(cleanupPendingKey, pending);
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
