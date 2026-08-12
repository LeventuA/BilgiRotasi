part of 'main.dart';

enum AdPlacement {
  homeMenu,
  settings,
  socialRecords,
  familyRecords,
  career,
  play,
  otherModes,
  boardResult,
  marathonResult,
  challengeResult,
  dailyResult,
  survival,
  speed,
  otherModeResult,
  auth,
  boardGame,
  question,
  liveDuelEntry,
  liveDuelMatchmaking,
  liveDuelMatch,
}

class AdVisibilityPolicy {
  const AdVisibilityPolicy._();

  static bool showsBanner(AdPlacement placement) {
    return switch (placement) {
      AdPlacement.homeMenu ||
      AdPlacement.settings ||
      AdPlacement.socialRecords ||
      AdPlacement.familyRecords ||
      AdPlacement.career ||
      AdPlacement.play ||
      AdPlacement.otherModes ||
      AdPlacement.boardResult ||
      AdPlacement.marathonResult ||
      AdPlacement.challengeResult ||
      AdPlacement.dailyResult ||
      AdPlacement.survival ||
      AdPlacement.speed ||
      AdPlacement.otherModeResult => true,
      AdPlacement.auth ||
      AdPlacement.boardGame ||
      AdPlacement.question ||
      AdPlacement.liveDuelEntry ||
      AdPlacement.liveDuelMatchmaking ||
      AdPlacement.liveDuelMatch => false,
    };
  }
}

class AdMobConfig {
  const AdMobConfig._();

  static const String environment = String.fromEnvironment(
    'ADMOB_ENVIRONMENT',
    defaultValue: 'test',
  );
  static const bool isProduction = environment == 'production';
  static const bool isClosedTest = environment == 'closed_test';
  static const bool usesGoogleTestAds = !isProduction;

  static const String testAndroidAppId =
      'ca-app-pub-3940256099942544~3347511713';
  static const String testAndroidBannerUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String testAndroidRewardedUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  static const String productionAndroidAppId =
      'ca-app-pub-7452194004008791~7046504043';
  static const String productionAndroidBannerUnitId =
      'ca-app-pub-7452194004008791/4228769011';
  static const String productionAndroidRewardedUnitId =
      'ca-app-pub-7452194004008791/4974874471';

  static const String androidAppId =
      isProduction ? productionAndroidAppId : testAndroidAppId;
  static const String androidBannerUnitId =
      isProduction ? productionAndroidBannerUnitId : testAndroidBannerUnitId;
  static const String androidRewardedUnitId =
      isProduction
          ? productionAndroidRewardedUnitId
          : testAndroidRewardedUnitId;
}

abstract interface class AdConsentGateway {
  Future<void> requestConsentInfoUpdate();
  Future<void> loadAndShowConsentFormIfRequired();
  Future<bool> canRequestAds();
  Future<bool> isPrivacyOptionsRequired();
  Future<void> showPrivacyOptionsForm();
}

class AndroidEmulatorGateway {
  const AndroidEmulatorGateway();

  static const MethodChannel _channel = MethodChannel(
    'com.leventua.bilgirotasi/runtime_environment',
  );

  Future<bool> isEmulator() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('isEmulator') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}

class GoogleUmpConsentGateway implements AdConsentGateway {
  const GoogleUmpConsentGateway();

  @override
  Future<void> requestConsentInfoUpdate() async {
    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () => completer.complete(),
      (error) => completer.completeError(error),
    );
    await completer.future;
  }

  @override
  Future<void> loadAndShowConsentFormIfRequired() {
    final completer = Completer<void>();
    ConsentForm.loadAndShowConsentFormIfRequired((error) {
      if (error == null) {
        completer.complete();
      } else {
        completer.completeError(error);
      }
    });
    return completer.future;
  }

  @override
  Future<bool> canRequestAds() {
    return ConsentInformation.instance.canRequestAds();
  }

  @override
  Future<bool> isPrivacyOptionsRequired() async {
    return await ConsentInformation.instance
            .getPrivacyOptionsRequirementStatus() ==
        PrivacyOptionsRequirementStatus.required;
  }

  @override
  Future<void> showPrivacyOptionsForm() {
    final completer = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((error) {
      if (error == null) {
        completer.complete();
      } else {
        completer.completeError(error);
      }
    });
    return completer.future;
  }
}

abstract interface class MobileAdsGateway {
  Future<void> configureForTeenAudience();
  Future<void> initialize();
}

class GoogleMobileAdsGateway implements MobileAdsGateway {
  const GoogleMobileAdsGateway();

  @override
  Future<void> configureForTeenAudience() {
    return MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        maxAdContentRating: MaxAdContentRating.t,
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
      ),
    );
  }

  @override
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }
}

class AdPrivacyService {
  AdPrivacyService({
    required this.consentGateway,
    required this.mobileAdsGateway,
    this.emulatorGateway = const AndroidEmulatorGateway(),
  });

  static final AdPrivacyService instance = AdPrivacyService(
    consentGateway: const GoogleUmpConsentGateway(),
    mobileAdsGateway: const GoogleMobileAdsGateway(),
  );

  final AdConsentGateway consentGateway;
  final MobileAdsGateway mobileAdsGateway;
  final AndroidEmulatorGateway emulatorGateway;
  final ValueNotifier<bool> privacyOptionsRequired = ValueNotifier<bool>(false);

  Future<bool>? _initializing;
  bool _adsReady = false;

  Future<bool> initialize() {
    if (_adsReady) return Future<bool>.value(true);
    final active = _initializing;
    if (active != null) return active;

    final future = _initialize();
    _initializing = future;
    return future;
  }

  Future<bool> _initialize() async {
    try {
      // Android x86_64 API 36 system images can crash inside their bundled
      // WebView while UMP or Mobile Ads is starting. CI/emulator validation
      // therefore stays ad-free; physical closed-test builds still use the
      // normal UMP flow and Google's official demo ad units.
      if (await emulatorGateway.isEmulator()) return false;

      await consentGateway.requestConsentInfoUpdate();
      await consentGateway.loadAndShowConsentFormIfRequired();
      privacyOptionsRequired.value =
          await consentGateway.isPrivacyOptionsRequired();

      if (!await consentGateway.canRequestAds()) return false;

      await mobileAdsGateway.configureForTeenAudience();
      await mobileAdsGateway.initialize();
      _adsReady = true;
      return true;
    } catch (_) {
      _adsReady = false;
      return false;
    } finally {
      _initializing = null;
    }
  }

  Future<bool> showPrivacyOptions() async {
    if (!privacyOptionsRequired.value) return false;
    try {
      await consentGateway.showPrivacyOptionsForm();
      privacyOptionsRequired.value =
          await consentGateway.isPrivacyOptionsRequired();
      return true;
    } catch (_) {
      return false;
    }
  }
}

class AdMonetizationService {
  AdMonetizationService._();

  static final AdMonetizationService instance = AdMonetizationService._();

  bool _initialized = false;
  Future<bool>? _initializing;
  RewardedAd? _rewardedAd;
  Future<bool>? _rewardedLoading;
  bool _disposed = false;

  Future<bool> _ensureInitialized() {
    if (_disposed || !Platform.isAndroid) return Future<bool>.value(false);
    if (_initialized) return Future<bool>.value(true);
    final active = _initializing;
    if (active != null) return active;

    final future = () async {
      try {
        _initialized = await AdPrivacyService.instance.initialize();
        return _initialized;
      } catch (_) {
        _initialized = false;
        return false;
      } finally {
        _initializing = null;
      }
    }();
    _initializing = future;
    return future;
  }

  Future<bool> _loadRewarded() async {
    if (_disposed || !await _ensureInitialized()) return false;
    if (_rewardedAd != null) return true;
    final active = _rewardedLoading;
    if (active != null) return active;

    final completer = Completer<bool>();
    _rewardedLoading = completer.future;
    try {
      RewardedAd.load(
        adUnitId: AdMobConfig.androidRewardedUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            if (_disposed) {
              ad.dispose();
              if (!completer.isCompleted) completer.complete(false);
              return;
            }
            _rewardedAd = ad;
            if (!completer.isCompleted) completer.complete(true);
          },
          onAdFailedToLoad: (_) {
            _rewardedAd = null;
            if (!completer.isCompleted) completer.complete(false);
          },
        ),
      );
      return await completer.future.timeout(
        const Duration(seconds: 12),
        onTimeout: () => false,
      );
    } catch (_) {
      return false;
    } finally {
      _rewardedLoading = null;
    }
  }

  Future<bool> showRewarded() async {
    if (!await _loadRewarded()) return false;
    final ad = _rewardedAd;
    if (ad == null) return false;
    _rewardedAd = null;

    final completer = Completer<bool>();
    var rewardCallbackReceived = false;
    ad.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
      onAdDismissedFullScreenContent: (shownAd) {
        shownAd.dispose();
        if (!completer.isCompleted) {
          completer.complete(rewardCallbackReceived);
        }
        unawaited(_loadRewarded());
      },
      onAdFailedToShowFullScreenContent: (shownAd, _) {
        shownAd.dispose();
        if (!completer.isCompleted) completer.complete(false);
        unawaited(_loadRewarded());
      },
    );

    try {
      ad.show(
        onUserEarnedReward: (_, __) {
          rewardCallbackReceived = true;
        },
      );
      return await completer.future.timeout(
        const Duration(minutes: 3),
        onTimeout: () {
          ad.dispose();
          return false;
        },
      );
    } catch (_) {
      ad.dispose();
      unawaited(_loadRewarded());
      return false;
    }
  }

  Future<BannerAd?> loadBanner() async {
    if (_disposed || !await _ensureInitialized()) return null;
    final completer = Completer<BannerAd?>();
    late final BannerAd ad;
    ad = BannerAd(
      adUnitId: AdMobConfig.androidBannerUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (!completer.isCompleted) completer.complete(ad);
        },
        onAdFailedToLoad: (failedAd, _) {
          failedAd.dispose();
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );
    try {
      await ad.load();
      return await completer.future.timeout(
        const Duration(seconds: 12),
        onTimeout: () {
          ad.dispose();
          return null;
        },
      );
    } catch (_) {
      ad.dispose();
      return null;
    }
  }

  void dispose() {
    _disposed = true;
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}

class AdRewardController {
  const AdRewardController({
    required this.showRewarded,
    required this.grantReward,
  });

  final Future<bool> Function() showRewarded;
  final Future<void> Function() grantReward;

  Future<bool> run() async {
    final earned = await showRewarded();
    if (!earned) return false;
    await grantReward();
    return true;
  }
}

abstract interface class AdLimitStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class SharedPreferencesAdLimitStore implements AdLimitStore {
  SharedPreferencesAdLimitStore([SharedPreferencesAsync? preferences])
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> read(String key) => _preferences.getString(key);

  @override
  Future<void> write(String key, String value) {
    return _preferences.setString(key, value);
  }
}

class SupportRewardLimiter {
  SupportRewardLimiter({required this.store});

  final AdLimitStore store;

  static const String _gamesKey = 'admob_support_games_v1';
  static Future<void> _claimQueue = Future<void>.value();

  Future<bool> wasClaimedForGame(String gameId) async {
    final normalizedGameId = gameId.trim();
    if (normalizedGameId.isEmpty) return false;
    final values = (await store.read(_gamesKey) ?? '')
        .split('\n')
        .where((value) => value.isNotEmpty);
    return values.contains(normalizedGameId);
  }

  Future<bool> canClaim(String gameId) async {
    final normalizedGameId = gameId.trim();
    if (normalizedGameId.isEmpty) return false;
    return !await wasClaimedForGame(normalizedGameId);
  }

  Future<bool> claim(String gameId) {
    final normalizedGameId = gameId.trim();
    if (normalizedGameId.isEmpty) return Future<bool>.value(false);

    final completer = Completer<bool>();
    _claimQueue = _claimQueue.then((_) async {
      try {
        final existing =
            (await store.read(_gamesKey) ?? '')
                .split('\n')
                .where((value) => value.isNotEmpty)
                .toList();
        if (existing.contains(normalizedGameId)) {
          completer.complete(false);
          return;
        }
        existing.add(normalizedGameId);
        await store.write(_gamesKey, existing.join('\n'));
        completer.complete(true);
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }
}

bool supportRewardAvailabilityAfterAttempt({
  required bool rewardGranted,
  required bool canClaimAgain,
}) {
  return !rewardGranted && canClaimAgain;
}

bool supportRewardEnabledForProfile({
  required bool firebaseProductionEnabled,
  required bool isClosedTest,
  required bool isProductionAds,
}) {
  if (isProductionAds) return false;
  return !firebaseProductionEnabled || isClosedTest;
}

class AdMonetizationDialogs {
  const AdMonetizationDialogs._();

  static Future<bool> askForJokerReward(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (dialogContext) => AlertDialog(
                icon: const Text('🎁📺', style: TextStyle(fontSize: 46)),
                title: const Text('Joker ödülü'),
                content: const Text(
                  'İstersen kısa bir reklamı tamamlayarak rastgele bir joker +1 '
                  'kazanabilirsin. Reklamı reddedersen oyun normal devam eder.',
                  textAlign: TextAlign.center,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Hayır, devam et'),
                  ),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    icon: const Icon(Icons.play_circle_fill_rounded),
                    label: const Text('Reklamı izle'),
                  ),
                ],
              ),
        ) ??
        false;
  }
}

class AdBannerScaffold extends StatelessWidget {
  const AdBannerScaffold({
    this.placement,
    this.appBar,
    this.body,
    this.backgroundColor,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.bannerLoader,
    super.key,
  });

  final AdPlacement? placement;
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final Widget? endDrawer;
  final Future<BannerAd?> Function()? bannerLoader;

  @override
  Widget build(BuildContext context) {
    final adPlacement = placement;
    return Scaffold(
      appBar: appBar,
      body: body,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      bottomNavigationBar:
          adPlacement != null && AdVisibilityPolicy.showsBanner(adPlacement)
              ? AdBannerSlot(
                key: ValueKey<String>('ad-banner-${adPlacement.name}'),
                placement: adPlacement,
                loadBanner: bannerLoader,
              )
              : null,
    );
  }
}

class AdBannerSlot extends StatefulWidget {
  const AdBannerSlot({required this.placement, this.loadBanner, super.key});

  final AdPlacement placement;
  final Future<BannerAd?> Function()? loadBanner;

  @override
  State<AdBannerSlot> createState() => _AdBannerSlotState();
}

class _AdBannerSlotState extends State<AdBannerSlot> {
  BannerAd? _ad;

  @override
  void initState() {
    super.initState();
    if (AdVisibilityPolicy.showsBanner(widget.placement)) {
      unawaited(_load());
    }
  }

  Future<void> _load() async {
    final ad =
        await (widget.loadBanner ??
            AdMonetizationService.instance.loadBanner)();
    if (!mounted) {
      ad?.dispose();
      return;
    }
    setState(() => _ad = ad);
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null || !AdVisibilityPolicy.showsBanner(widget.placement)) {
      return const SizedBox.shrink();
    }
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: ad.size.height.toDouble(),
          child: Center(
            child: SizedBox(
              width: ad.size.width.toDouble(),
              height: ad.size.height.toDouble(),
              child: AdWidget(ad: ad),
            ),
          ),
        ),
      ),
    );
  }
}

class SupportRewardCard extends StatefulWidget {
  const SupportRewardCard({required this.gameId, this.dark = false, super.key});

  final String gameId;
  final bool dark;

  @override
  State<SupportRewardCard> createState() => _SupportRewardCardState();
}

class _SupportRewardCardState extends State<SupportRewardCard> {
  late final SupportRewardLimiter _limiter;
  bool _loading = true;
  bool _available = false;
  bool _busy = false;

  bool get _rewardProfileEnabled => supportRewardEnabledForProfile(
    firebaseProductionEnabled: FirebaseRuntimePolicy.productionEnabled,
    isClosedTest: AdMobConfig.isClosedTest,
    isProductionAds: AdMobConfig.isProduction,
  );

  @override
  void initState() {
    super.initState();
    _limiter = SupportRewardLimiter(store: SharedPreferencesAdLimitStore());
    unawaited(_refresh());
  }

  Future<void> _refresh() async {
    final available =
        _rewardProfileEnabled && await _limiter.canClaim(widget.gameId);
    if (!mounted) return;
    setState(() {
      _available = available;
      _loading = false;
    });
  }

  Future<void> _watch() async {
    if (_busy || !_available || !_rewardProfileEnabled) {
      return;
    }
    setState(() => _busy = true);

    XpGainResult? gain;
    final controller = AdRewardController(
      showRewarded: AdMonetizationService.instance.showRewarded,
      grantReward: () async {
        if (await _limiter.claim(widget.gameId)) {
          gain = await XpProgressService.awardSupportAd();
        }
      },
    );
    final rewarded = await controller.run();
    if (!mounted) return;

    final rewardGranted = rewarded && gain != null;
    final canClaimAgain =
        !rewardGranted && await _limiter.canClaim(widget.gameId);
    if (!mounted) return;

    setState(() {
      _busy = false;
      _available = supportRewardAvailabilityAfterAttempt(
        rewardGranted: rewardGranted,
        canClaimAgain: canClaimAgain,
      );
    });
    if (rewardGranted) {
      unawaited(
        AnalyticsTelemetry.rewardedAdCompleted(gameMode: widget.gameId),
      );
      await XpCelebration.show(context, gain!);
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Reklam tamamlanmadı veya bu oyun için ödül zaten alındı; '
            'XP verilmedi.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final foreground = widget.dark ? Colors.white : const Color(0xFF281538);
    final secondary =
        widget.dark ? const Color(0xFFD8CCEA) : const Color(0xFF64748B);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.dark ? const Color(0x22FFFFFF) : const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC4B5FD)),
      ),
      child: Column(
        children: [
          Text(
            'Bize destek olmak ister misiniz?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: foreground,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _available
                ? 'İsteğe bağlı reklamı tamamlayarak +10 XP kazan.'
                : !_rewardProfileEnabled
                ? 'Sunucu doğrulaması tamamlanana kadar +10 XP ödülü kapalı.'
                : 'Bu oyun için +10 XP ödülü zaten alındı.',
            textAlign: TextAlign.center,
            style: TextStyle(color: secondary),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loading || _busy || !_available ? null : _watch,
            icon: const Icon(Icons.play_circle_fill_rounded),
            label: Text(
              _loading
                  ? 'Kontrol ediliyor…'
                  : _busy
                  ? 'Reklam hazırlanıyor…'
                  : _available
                  ? 'Reklamı İzle · +10 XP'
                  : 'Bu oyun için ödül alındı',
            ),
          ),
        ],
      ),
    );
  }
}
