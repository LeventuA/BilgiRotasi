part of 'main.dart';

/// The deliberately small boundary around Firebase Analytics.
///
/// Callers can only pass non-account gameplay dimensions that are useful for
/// closed-test analysis. Firebase still creates a pseudonymous app-instance ID
/// after the user opts in. There is intentionally no generic parameter map and
/// no account-identity API in this layer.
abstract interface class AnalyticsEventSink {
  Future<void> logEvent(String name, {Map<String, Object>? parameters});

  Future<void> logScreenView(String screenName);
}

class _FirebaseAnalyticsEventSink implements AnalyticsEventSink {
  _FirebaseAnalyticsEventSink(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) {
    if (name == AnalyticsTelemetry.appOpenEvent) {
      return _analytics.logAppOpen();
    }
    return _analytics.logEvent(name: name, parameters: parameters);
  }

  @override
  Future<void> logScreenView(String screenName) {
    return _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenName,
    );
  }
}

class AnalyticsTelemetry {
  AnalyticsTelemetry._();

  static const String appOpenEvent = 'app_open';
  static const String appProcessStartedEvent = 'app_process_started';
  static const String gameModeSelectedEvent = 'game_mode_selected';
  static const String gameStartedEvent = 'game_started';
  static const String gameCompletedEvent = 'game_completed';
  static const String gameAbandonedEvent = 'game_abandoned';
  static const String jokerUsedEvent = 'joker_used';
  static const String rewardedAdCompletedEvent = 'rewarded_ad_completed';
  static const String liveDuelStartedEvent = 'live_duel_started';
  static const String liveDuelCompletedEvent = 'live_duel_completed';

  static final NavigatorObserver navigatorObserver =
      _AnalyticsNavigatorObserver();

  static AnalyticsEventSink? _testSink;
  static Future<AnalyticsEventSink?>? _firebaseSink;
  static bool _sessionLogged = false;
  static bool _consentGranted = false;

  @visibleForTesting
  static bool get consentGranted => _consentGranted;

  @visibleForTesting
  static void useTestSink(AnalyticsEventSink? sink) {
    _testSink = sink;
    _sessionLogged = false;
  }

  static Future<AnalyticsEventSink?> _resolveSink() async {
    if (_testSink != null) return _testSink;
    if (!_consentGranted) return null;
    if (!FirebaseRuntimePolicy.remoteFirebaseEnabled) return null;
    return _firebaseSink ??= _createFirebaseSink();
  }

  static Future<AnalyticsEventSink?> _createFirebaseSink() async {
    try {
      if (Firebase.apps.isEmpty) {
        try {
          await Firebase.initializeApp();
        } catch (_) {
          if (Firebase.apps.isEmpty) rethrow;
        }
      }
      final analytics = FirebaseAnalytics.instance;
      await analytics.setConsent(
        analyticsStorageConsentGranted: true,
        adStorageConsentGranted: false,
        adUserDataConsentGranted: false,
        adPersonalizationSignalsConsentGranted: false,
      );
      await analytics.setAnalyticsCollectionEnabled(true);
      return _FirebaseAnalyticsEventSink(analytics);
    } catch (_) {
      return null;
    }
  }

  static Future<void> _safe(
    Future<void> Function(AnalyticsEventSink) send,
  ) async {
    try {
      final sink = await _resolveSink();
      if (sink != null) await send(sink);
    } catch (_) {
      // Telemetri hiçbir koşulda uygulama veya oyun akışını engellemez.
    }
  }

  static Future<void> appProcessStarted() async {
    if (!_consentGranted && _testSink == null) return;
    if (_sessionLogged) return;
    _sessionLogged = true;
    await _safe((sink) async {
      await sink.logEvent(appOpenEvent);
      await sink.logEvent(
        appProcessStartedEvent,
        parameters: const <String, Object>{'app_version': AppBuildInfo.version},
      );
    });
  }

  static Future<void> applyConsent(AnalyticsConsentChoice choice) async {
    _consentGranted = choice == AnalyticsConsentChoice.granted;
    _sessionLogged = false;

    if (_consentGranted) {
      _firebaseSink = null;
      await appProcessStarted();
      return;
    }

    _firebaseSink = null;
    if (Firebase.apps.isEmpty) return;

    try {
      final analytics = FirebaseAnalytics.instance;
      await analytics.setAnalyticsCollectionEnabled(false);
      await analytics.setConsent(
        analyticsStorageConsentGranted: false,
        adStorageConsentGranted: false,
        adUserDataConsentGranted: false,
        adPersonalizationSignalsConsentGranted: false,
      );
      await analytics.resetAnalyticsData();
    } catch (_) {
      // Tercih kaydedilmiştir; SDK hatası oyunu veya ayar ekranını engellemez.
    }
  }

  static Future<void> screenViewed(String screenName) {
    final safeName = _safeDimension(screenName, fallback: 'unknown_screen');
    return _safe((sink) => sink.logScreenView(safeName));
  }

  static Future<void> gameModeSelected({required String gameMode}) {
    return _gameEvent(gameModeSelectedEvent, gameMode: gameMode);
  }

  static Future<void> gameStarted({
    required String gameMode,
    String? category,
    String? difficultyGroup,
  }) {
    return _gameEvent(
      gameStartedEvent,
      gameMode: gameMode,
      category: category,
      difficultyGroup: difficultyGroup,
    );
  }

  static Future<void> gameCompleted({
    required String gameMode,
    String? category,
    String? difficultyGroup,
    required Duration duration,
    required String result,
  }) {
    return _gameEvent(
      gameCompletedEvent,
      gameMode: gameMode,
      category: category,
      difficultyGroup: difficultyGroup,
      duration: duration,
      result: result,
    );
  }

  static Future<void> gameAbandoned({
    required String gameMode,
    String? category,
    String? difficultyGroup,
    required Duration duration,
  }) {
    return _gameEvent(
      gameAbandonedEvent,
      gameMode: gameMode,
      category: category,
      difficultyGroup: difficultyGroup,
      duration: duration,
      result: 'abandoned',
    );
  }

  static Future<void> jokerUsed({required String gameMode, String? category}) {
    return _gameEvent(jokerUsedEvent, gameMode: gameMode, category: category);
  }

  static Future<void> rewardedAdCompleted({required String gameMode}) {
    return _gameEvent(rewardedAdCompletedEvent, gameMode: gameMode);
  }

  static Future<void> liveDuelStarted() {
    return _gameEvent(liveDuelStartedEvent, gameMode: 'live_duel');
  }

  static Future<void> liveDuelCompleted({
    required Duration duration,
    required String result,
  }) {
    return _gameEvent(
      liveDuelCompletedEvent,
      gameMode: 'live_duel',
      duration: duration,
      result: result,
    );
  }

  static Future<void> _gameEvent(
    String name, {
    required String gameMode,
    String? category,
    String? difficultyGroup,
    Duration? duration,
    String? result,
  }) {
    final parameters = <String, Object>{
      'game_mode': _safeDimension(gameMode, fallback: 'unknown'),
      'app_version': AppBuildInfo.version,
      if (category != null)
        'category': _safeDimension(category, fallback: 'unknown'),
      if (difficultyGroup != null)
        'difficulty_group': _safeDimension(
          difficultyGroup,
          fallback: 'unknown',
        ),
      if (duration != null) 'duration_seconds': max(0, duration.inSeconds),
      if (result != null) 'result': _safeDimension(result, fallback: 'unknown'),
    };
    return _safe((sink) => sink.logEvent(name, parameters: parameters));
  }

  static String _safeDimension(String value, {required String fallback}) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    if (normalized.isEmpty) return fallback;
    return normalized.substring(0, min(40, normalized.length));
  }
}

enum AnalyticsConsentChoice { unknown, granted, denied }

class FirstRunNotificationOptInPolicy {
  FirstRunNotificationOptInPolicy._();

  static bool shouldOffer({
    required AccountMode accountMode,
    required bool remoteMessagingEnabled,
    required bool alreadyShown,
    required bool pushAlreadyEnabled,
  }) {
    return Platform.isAndroid &&
        remoteMessagingEnabled &&
        accountMode != AccountMode.undecided &&
        !alreadyShown &&
        !pushAlreadyEnabled;
  }
}

class FirstRunNotificationOptInService {
  FirstRunNotificationOptInService._();

  static const String preferenceKey = 'push_first_run_prompt_shown_v1';
  static bool _scheduled = false;
  static bool _showing = false;
  static VoidCallback? _accountListener;

  static Future<void> scheduleIfNeeded() async {
    if (_scheduled) return;
    _scheduled = true;

    if (!Platform.isAndroid || !PushRuntimePolicy.remoteMessagingEnabled) {
      return;
    }

    void listener() {
      if (AccountCloudService.state.value.mode == AccountMode.undecided) return;
      AccountCloudService.state.removeListener(listener);
      _accountListener = null;
      _queueShow();
    }

    _accountListener = listener;
    AccountCloudService.state.addListener(listener);
    listener();
  }

  static void _queueShow([int retriesRemaining = 4]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_attemptShow(retriesRemaining));
    });
  }

  static Future<void> _attemptShow(int retriesRemaining) async {
    if (_showing) return;

    final preferences = await SharedPreferences.getInstance();
    final alreadyShown = preferences.getBool(preferenceKey) == true;
    final pushAlreadyEnabled =
        preferences.getBool(_SharedPreferencesPushStore.preferenceKey) == true ||
        PushNotificationService.state.value == PushNotificationState.enabled;
    final mode = AccountCloudService.state.value.mode;

    if (!FirstRunNotificationOptInPolicy.shouldOffer(
      accountMode: mode,
      remoteMessagingEnabled: PushRuntimePolicy.remoteMessagingEnabled,
      alreadyShown: alreadyShown,
      pushAlreadyEnabled: pushAlreadyEnabled,
    )) {
      return;
    }

    final context = AnalyticsConsentService.navigatorKey.currentContext;
    final messenger =
        context == null ? null : ScaffoldMessenger.maybeOf(context);
    if (context == null || !context.mounted || messenger == null) {
      if (retriesRemaining > 0) {
        Future<void>.delayed(const Duration(milliseconds: 250), () {
          _queueShow(retriesRemaining - 1);
        });
      }
      return;
    }

    await preferences.setBool(preferenceKey, true);
    _showing = true;
    messenger
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(
        MaterialBanner(
          leading: const Icon(Icons.notifications_active_outlined),
          content: const Text(
            'Yeni özellikler, özel gün duyuruları ve önemli Bilgi Rotası '
            'haberlerinden haberdar ol.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                messenger.hideCurrentMaterialBanner();
                _showing = false;
              },
              child: const Text('Şimdi Değil'),
            ),
            FilledButton(
              onPressed: () {
                messenger.hideCurrentMaterialBanner();
                _showing = false;
                unawaited(_enableNotifications(context));
              },
              child: const Text('Bildirimleri Aç'),
            ),
          ],
        ),
      );
  }

  static Future<void> _enableNotifications(BuildContext context) async {
    final result = await PushNotificationService.setEnabled(true);
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    final message = switch (result) {
      PushEnableResult.enabled => 'Genel duyuru bildirimleri açıldı.',
      PushEnableResult.denied =>
        'Bildirim izni verilmedi. Oyun normal çalışmaya devam eder.',
      PushEnableResult.unavailable =>
        'Bu derlemede uzak bildirim bağlantısı kapalı.',
      PushEnableResult.failed =>
        'Bildirim ayarı şu anda güncellenemedi. Oyun etkilenmedi.',
      PushEnableResult.disabled => 'Genel duyuru bildirimleri kapalı kaldı.',
    };
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @visibleForTesting
  static void resetForTesting() {
    final listener = _accountListener;
    if (listener != null) AccountCloudService.state.removeListener(listener);
    _accountListener = null;
    _scheduled = false;
    _showing = false;
  }
}

class AnalyticsConsentService {
  AnalyticsConsentService._();

  static const String preferenceKey = 'analytics_consent_granted_v1';
  // Tarihsel anahtar korunur; yeni sürümlerde ilk açılış Analytics popup'ı yoktur.
  static const String promptVersionKey = 'analytics_consent_prompt_version_v1';
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final ValueNotifier<AnalyticsConsentChoice> choice =
      ValueNotifier<AnalyticsConsentChoice>(AnalyticsConsentChoice.unknown);
  static SharedPreferences? _preferences;

  static Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    _preferences = preferences;
    final stored = preferences.getBool(preferenceKey);
    final restored = switch (stored) {
      true => AnalyticsConsentChoice.granted,
      false => AnalyticsConsentChoice.denied,
      null => AnalyticsConsentChoice.unknown,
    };
    choice.value = restored;
    await AnalyticsTelemetry.applyConsent(restored);
  }

  static Future<void> setGranted(bool granted) async {
    final preferences = _preferences ??= await SharedPreferences.getInstance();
    await preferences.setBool(preferenceKey, granted);
    final updated =
        granted
            ? AnalyticsConsentChoice.granted
            : AnalyticsConsentChoice.denied;
    choice.value = updated;
    await AnalyticsTelemetry.applyConsent(updated);
  }

  static Future<void> showInitialPromptIfNeeded() async {
    // İlk açılışta Analytics popup'ı gösterilmez. Analytics varsayılan kapalı
    // kalır ve yalnız Ayarlar'daki açık opt-in akışıyla etkinleştirilebilir.
    // Mevcut app-root çağrısını güvenli biçimde ilk kullanım bildirim çağrısına
    // yönlendiriyoruz; Android sistem izni yalnız kullanıcı butona basarsa açılır.
    await FirstRunNotificationOptInService.scheduleIfNeeded();
  }

  static Future<bool> showOptInDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Kullanım Analizine izin verilsin mi?'),
              content: const Text(
                'İzin verirsen Firebase SDK bu uygulama kurulumu için '
                'pseudonymous bir app-instance ID üretir. Oyun modu, kategori, '
                'süre ve sonuç gibi kullanım olayları ölçülür; adın, e-posta '
                'adresin, Google/Firebase hesap kimliğin ve kullanıcı adın '
                'gönderilmez. İzni daha sonra Ayarlar ekranından kapatabilirsin.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Şimdi Değil'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('İzin Ver'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}

class AnalyticsConsentSettingsCard extends StatelessWidget {
  const AnalyticsConsentSettingsCard({super.key});

  Future<void> _update(BuildContext context, bool enabled) async {
    if (enabled) {
      final accepted = await AnalyticsConsentService.showOptInDialog(context);
      if (!accepted) return;
    }

    await AnalyticsConsentService.setGranted(enabled);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? 'Kişisel hesap kimliği göndermeyen kullanım analizi açıldı.'
                : 'Kullanım analizi kapatıldı.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AnalyticsConsentChoice>(
      valueListenable: AnalyticsConsentService.choice,
      builder: (context, choice, _) {
        final enabled = choice == AnalyticsConsentChoice.granted;
        return Card(
          child: SwitchListTile(
            value: enabled,
            onChanged: (value) => unawaited(_update(context, value)),
            secondary: const Icon(Icons.analytics_outlined),
            title: const Text(
              'Kullanım Analizi',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text(
              enabled
                  ? 'Açık • Pseudonymous app-instance ID kullanılır; hesap kimliği gönderilmez.'
                  : 'Kapalı • Analytics identifier depolanmaz ve olay gönderilmez.',
            ),
          ),
        );
      },
    );
  }
}

class _AnalyticsNavigatorObserver extends NavigatorObserver {
  void _record(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == null || name.isEmpty || name == '/') return;
    unawaited(AnalyticsTelemetry.screenViewed(name));
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _record(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _record(newRoute);
  }
}

class TelemetryPageRoute<T> extends MaterialPageRoute<T> {
  TelemetryPageRoute({
    required String screenName,
    required super.builder,
    super.fullscreenDialog,
  }) : super(settings: RouteSettings(name: screenName));
}

class GameTelemetrySession {
  GameTelemetrySession._({
    required this.gameMode,
    this.category,
    this.difficultyGroup,
  }) : _startedAt = DateTime.now();

  final String gameMode;
  final String? category;
  final String? difficultyGroup;
  final DateTime _startedAt;
  bool _ended = false;

  static GameTelemetrySession start({
    required String gameMode,
    String? category,
    String? difficultyGroup,
  }) {
    final session = GameTelemetrySession._(
      gameMode: gameMode,
      category: category,
      difficultyGroup: difficultyGroup,
    );
    unawaited(
      AnalyticsTelemetry.gameStarted(
        gameMode: gameMode,
        category: category,
        difficultyGroup: difficultyGroup,
      ),
    );
    return session;
  }

  void complete(String result) {
    if (_ended) return;
    _ended = true;
    unawaited(
      AnalyticsTelemetry.gameCompleted(
        gameMode: gameMode,
        category: category,
        difficultyGroup: difficultyGroup,
        duration: DateTime.now().difference(_startedAt),
        result: result,
      ),
    );
  }

  void abandon() {
    if (_ended) return;
    _ended = true;
    unawaited(
      AnalyticsTelemetry.gameAbandoned(
        gameMode: gameMode,
        category: category,
        difficultyGroup: difficultyGroup,
        duration: DateTime.now().difference(_startedAt),
      ),
    );
  }
}
