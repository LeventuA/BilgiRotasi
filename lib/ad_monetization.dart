part of 'main.dart';

class AdMonetizationService {
  AdMonetizationService._();

  static const String androidBannerTestUnitId =
      'ca-app-pub-3940256099942544/9214589741';
  static const String androidRewardedTestUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  static bool _initialized = false;
  static RewardedAd? _rewardedAd;
  static Future<bool>? _rewardedLoadFuture;

  static Future<void> initialize() async {
    if (_initialized || !Platform.isAndroid) return;

    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      unawaited(_loadRewarded());
    } catch (_) {
      _initialized = false;
    }
  }

  static Future<bool> _loadRewarded() {
    if (!Platform.isAndroid) return Future<bool>.value(false);
    if (_rewardedAd != null) return Future<bool>.value(true);

    final current = _rewardedLoadFuture;
    if (current != null) return current;

    final completer = Completer<bool>();
    _rewardedLoadFuture = completer.future;

    RewardedAd.load(
      adUnitId: androidRewardedTestUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedLoadFuture = null;
          if (!completer.isCompleted) completer.complete(true);
        },
        onAdFailedToLoad: (_) {
          _rewardedAd = null;
          _rewardedLoadFuture = null;
          if (!completer.isCompleted) completer.complete(false);
        },
      ),
    );

    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        _rewardedLoadFuture = null;
        return false;
      },
    );
  }

  static Future<bool> showRewarded() async {
    if (!Platform.isAndroid) return false;
    if (!_initialized) await initialize();

    final ready = await _loadRewarded();
    final ad = _rewardedAd;
    if (!ready || ad == null) {
      unawaited(_loadRewarded());
      return false;
    }

    _rewardedAd = null;
    final completer = Completer<bool>();
    var earned = false;

    ad.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
      onAdDismissedFullScreenContent: (shownAd) {
        shownAd.dispose();
        if (!completer.isCompleted) completer.complete(earned);
        unawaited(_loadRewarded());
      },
      onAdFailedToShowFullScreenContent: (shownAd, _) {
        shownAd.dispose();
        if (!completer.isCompleted) completer.complete(false);
        unawaited(_loadRewarded());
      },
    );

    ad.show(
      onUserEarnedReward: (_, __) {
        earned = true;
      },
    );

    return completer.future.timeout(
      const Duration(minutes: 3),
      onTimeout: () {
        ad.dispose();
        return earned;
      },
    );
  }
}

class SupportRewardClaimService {
  SupportRewardClaimService._();

  static final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  static String get _scope {
    try {
      return GameSaveService.storageScopeForUid(
        FirebaseAuth.instance.currentUser?.uid,
      );
    } catch (_) {
      return 'guest';
    }
  }

  static String get _key =>
      'bilgi_rotasi_account_support_reward_claims_$_scope';

  static Future<bool> isClaimed(String resultId) async {
    try {
      final values = await _preferences.getStringList(_key) ?? const <String>[];
      return values.contains(resultId);
    } catch (_) {
      return false;
    }
  }

  static Future<XpGainResult?> awardOnce(String resultId) async {
    final values = await _preferences.getStringList(_key) ?? <String>[];

    if (values.contains(resultId)) return null;

    final gain = await XpProgressService.awardSupportAd();
    final updated = <String>[...values, resultId];

    if (updated.length > 500) {
      updated.removeRange(0, updated.length - 500);
    }

    await _preferences.setStringList(_key, updated);
    return gain;
  }
}

class AdMonetizationDialogs {
  AdMonetizationDialogs._();

  static Future<bool> askForJokerReward(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return AlertDialog(
              icon: const Text('🎁📺', style: TextStyle(fontSize: 46)),
              title: const Text('Rastgele Joker Kazan'),
              content: const Text(
                'Kısa reklamı tamamla ve dört jokerden '
                'rastgele birine +1 kazan.\n\n'
                'Reklam izlemek istemezsen oyun normal devam eder.',
                textAlign: TextAlign.center,
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Jokersiz Devam Et'),
                ),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  icon: const Icon(Icons.play_circle_fill_rounded),
                  label: const Text('Reklamı İzle ve Joker Kazan'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}

class AdBannerSlot extends StatefulWidget {
  const AdBannerSlot({super.key});

  @override
  State<AdBannerSlot> createState() => _AdBannerSlotState();
}

class _AdBannerSlotState extends State<AdBannerSlot> {
  BannerAd? _bannerAd;
  bool _loadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_loadStarted) {
      _loadStarted = true;
      unawaited(_loadBanner());
    }
  }

  Future<void> _loadBanner() async {
    if (!Platform.isAndroid) return;

    await AdMonetizationService.initialize();
    if (!mounted) return;

    final ad = BannerAd(
      adUnitId: AdMonetizationService.androidBannerTestUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (loadedAd) {
          if (!mounted) {
            loadedAd.dispose();
            return;
          }

          setState(() {
            _bannerAd = loadedAd as BannerAd;
          });
        },
        onAdFailedToLoad: (failedAd, _) {
          failedAd.dispose();
        },
      ),
    );

    await ad.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _bannerAd;
    if (ad == null) return const SizedBox.shrink();

    return Material(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: SizedBox(
            width: ad.size.width.toDouble(),
            height: ad.size.height.toDouble(),
            child: AdWidget(ad: ad),
          ),
        ),
      ),
    );
  }
}

class SupportRewardCard extends StatefulWidget {
  const SupportRewardCard({
    required this.resultId,
    this.dark = false,
    super.key,
  });

  final String resultId;
  final bool dark;

  @override
  State<SupportRewardCard> createState() => _SupportRewardCardState();
}

class _SupportRewardCardState extends State<SupportRewardCard> {
  bool _loading = true;
  bool _busy = false;
  bool _claimed = false;

  @override
  void initState() {
    super.initState();
    _loadClaim();
  }

  Future<void> _loadClaim() async {
    final claimed = await SupportRewardClaimService.isClaimed(widget.resultId);

    if (!mounted) return;
    setState(() {
      _claimed = claimed;
      _loading = false;
    });
  }

  Future<void> _watch() async {
    if (_busy || _claimed) return;

    setState(() {
      _busy = true;
    });

    final earned = await AdMonetizationService.showRewarded();

    if (!mounted) return;

    if (!earned) {
      setState(() {
        _busy = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Reklam hazır değildi veya tamamlanmadı. '
              'XP ödülü verilmedi.',
            ),
          ),
        );
      return;
    }

    final gain = await SupportRewardClaimService.awardOnce(widget.resultId);

    if (!mounted) return;

    setState(() {
      _busy = false;
      _claimed = true;
    });

    if (gain != null) {
      await XpCelebration.show(context, gain);
    }
  }

  @override
  Widget build(BuildContext context) {
    final foreground = widget.dark ? Colors.white : const Color(0xFF281538);
    final secondary =
        widget.dark ? const Color(0xFFD8CCEA) : const Color(0xFF64748B);
    final background =
        widget.dark ? const Color(0x22FFFFFF) : const Color(0xFFF5F3FF);
    final border =
        widget.dark ? const Color(0x66FFE082) : const Color(0xFFC4B5FD);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          const Text('💜📺', style: TextStyle(fontSize: 34)),
          const SizedBox(height: 7),
          Text(
            'Bilgi Rotası’nı desteklemek ister misin?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: foreground,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _claimed
                ? 'Bu oyun için +10 XP desteğini aldın. Teşekkürler!'
                : 'Kısa reklamı tamamla, bize destek ol ve +10 XP kazan.',
            textAlign: TextAlign.center,
            style: TextStyle(color: secondary, height: 1.35),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loading || _busy || _claimed ? null : _watch,
            icon: Icon(
              _claimed
                  ? Icons.check_circle_rounded
                  : Icons.play_circle_fill_rounded,
            ),
            label: Text(
              _loading
                  ? 'Kontrol ediliyor…'
                  : _busy
                  ? 'Reklam hazırlanıyor…'
                  : _claimed
                  ? 'Destek Alındı · +10 XP'
                  : 'Reklamı İzle · +10 XP',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
