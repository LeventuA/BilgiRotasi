part of 'main.dart';

class AppPreferences {
  const AppPreferences({
    this.defaultPlayerName = 'Oyuncu',
    this.defaultColorIndex = 1,
    this.textScale = 1.0,
    this.childMode = false,
    this.categoryAssist = false,
    this.soundEnabled = true,
    this.masterVolume = 1.0,
    this.animationMode = 'full',
    this.hapticsEnabled = true,
    this.tutorialSeen = false,
  });

  final String defaultPlayerName;
  final int defaultColorIndex;
  final double textScale;
  final bool childMode;
  final bool categoryAssist;
  final bool soundEnabled;
  final double masterVolume;
  final String animationMode;
  final bool hapticsEnabled;
  final bool tutorialSeen;

  double get effectiveTextScale =>
      childMode ? max(1.15, textScale) : textScale;

  AppPreferences copyWith({
    String? defaultPlayerName,
    int? defaultColorIndex,
    double? textScale,
    bool? childMode,
    bool? categoryAssist,
    bool? soundEnabled,
    double? masterVolume,
    String? animationMode,
    bool? hapticsEnabled,
    bool? tutorialSeen,
  }) {
    return AppPreferences(
      defaultPlayerName:
          defaultPlayerName ?? this.defaultPlayerName,
      defaultColorIndex:
          defaultColorIndex ?? this.defaultColorIndex,
      textScale: textScale ?? this.textScale,
      childMode: childMode ?? this.childMode,
      categoryAssist:
          categoryAssist ?? this.categoryAssist,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      masterVolume: masterVolume ?? this.masterVolume,
      animationMode: animationMode ?? this.animationMode,
      hapticsEnabled:
          hapticsEnabled ?? this.hapticsEnabled,
      tutorialSeen: tutorialSeen ?? this.tutorialSeen,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'defaultPlayerName': defaultPlayerName,
        'defaultColorIndex': defaultColorIndex,
        'textScale': textScale,
        'childMode': childMode,
        'categoryAssist': categoryAssist,
        'soundEnabled': soundEnabled,
        'masterVolume': masterVolume,
        'animationMode': animationMode,
        'hapticsEnabled': hapticsEnabled,
        'tutorialSeen': tutorialSeen,
      };

  factory AppPreferences.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawName =
        json['defaultPlayerName']?.toString().trim() ?? '';
    final rawAnimation =
        json['animationMode']?.toString() ?? 'full';

    return AppPreferences(
      defaultPlayerName:
          rawName.isEmpty ? 'Oyuncu' : rawName,
      defaultColorIndex: ((json['defaultColorIndex']
                  as num?)
              ?.toInt() ??
          1)
          .clamp(0, 5)
          .toInt(),
      textScale: ((json['textScale'] as num?)
                  ?.toDouble() ??
              1.0)
          .clamp(1.0, 1.30)
          .toDouble(),
      childMode: json['childMode'] == true,
      categoryAssist: json['categoryAssist'] == true,
      soundEnabled: json['soundEnabled'] != false,
      masterVolume: ((json['masterVolume'] as num?)
                  ?.toDouble() ??
              1.0)
          .clamp(0.0, 1.0)
          .toDouble(),
      animationMode: <String>{
        'full',
        'reduced',
        'minimal',
      }.contains(rawAnimation)
          ? rawAnimation
          : 'full',
      hapticsEnabled: json['hapticsEnabled'] != false,
      tutorialSeen: json['tutorialSeen'] == true,
    );
  }
}

class AppPreferencesService {
  AppPreferencesService._();

  static const String _key =
      'bilgi_rotasi_app_preferences_v1';

  static const List<Color> playerColors = <Color>[
    Color(0xFFE11D48),
    Color(0xFF2563EB),
    Color(0xFF16A34A),
    Color(0xFFF97316),
    Color(0xFF9333EA),
    Color(0xFF0891B2),
  ];

  static final SharedPreferencesAsync _prefs =
      SharedPreferencesAsync();

  static final ValueNotifier<int> revision =
      ValueNotifier<int>(0);

  static AppPreferences current =
      const AppPreferences();

  static Future<void> initialize() async {
    try {
      final raw = await _prefs.getString(_key);

      if (raw != null && raw.trim().isNotEmpty) {
        final decoded = jsonDecode(raw);

        if (decoded is Map) {
          current = AppPreferences.fromJson(
            Map<String, dynamic>.from(decoded),
          );
        }
      }
    } catch (_) {
      current = const AppPreferences();
    }

    SoundFx.setEnabled(current.soundEnabled);
  }

  static Future<void> save(
    AppPreferences settings,
  ) async {
    current = settings;

    try {
      await _prefs.setString(
        _key,
        jsonEncode(settings.toJson()),
      );
    } catch (_) {
      // Ayar kaydı oyunun açılmasını engellememeli.
    }

    SoundFx.setEnabled(settings.soundEnabled);
    revision.value++;
  }

  static Future<void> setSoundEnabled(
    bool enabled,
  ) {
    return save(
      current.copyWith(soundEnabled: enabled),
    );
  }

  static Future<void> setChildMode(
    bool enabled,
  ) async {
    final next = current.copyWith(
      childMode: enabled,
      categoryAssist:
          enabled ? true : current.categoryAssist,
      textScale:
          enabled ? max(1.15, current.textScale) : null,
    );

    await save(next);

    if (enabled) {
      final boost =
          GameplayBoostSettingsService.current;

      await GameplayBoostSettingsService.save(
        boost.copyWith(
          riskQuestionsEnabled: false,
          jokersEnabled: true,
        ),
      );
    }
  }

  static Future<void> setAnimationMode(
    String mode,
  ) async {
    final safeMode = <String>{
      'full',
      'reduced',
      'minimal',
    }.contains(mode)
        ? mode
        : 'full';

    await save(
      current.copyWith(animationMode: safeMode),
    );

    final boost =
        GameplayBoostSettingsService.current;

    switch (safeMode) {
      case 'minimal':
        await GameplayBoostSettingsService.save(
          boost.copyWith(
            xpAnimations: false,
            levelUpCelebration: false,
            streakEffects: false,
          ),
        );
        await VisualCollectionService.setLiveBoard(false);
        break;

      case 'reduced':
        await GameplayBoostSettingsService.save(
          boost.copyWith(
            xpAnimations: false,
            levelUpCelebration: true,
            streakEffects: false,
          ),
        );
        await VisualCollectionService.setLiveBoard(false);
        break;

      default:
        await GameplayBoostSettingsService.save(
          boost.copyWith(
            xpAnimations: true,
            levelUpCelebration: true,
            streakEffects: true,
          ),
        );
        await VisualCollectionService.setLiveBoard(true);
    }
  }

  static Future<void> markTutorialSeen(
    bool value,
  ) {
    return save(
      current.copyWith(tutorialSeen: value),
    );
  }

  static double get soundMultiplier =>
      current.masterVolume.clamp(0.0, 1.0);

  static Future<void> clear() async {
    try {
      await _prefs.remove(_key);
    } catch (_) {
      // Sıfırlama sorunu oyunu kilitlememeli.
    }

    current = const AppPreferences();
    SoundFx.setEnabled(true);
    revision.value++;
  }
}

class AccessibilityAppFrame extends StatelessWidget {
  const AccessibilityAppFrame({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppPreferencesService.revision,
      builder: (context, _, __) {
        final settings = AppPreferencesService.current;
        final media = MediaQuery.of(context);

        Widget result = MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(
              settings.effectiveTextScale,
            ),
          ),
          child: child,
        );

        if (settings.categoryAssist) {
          final theme = Theme.of(context);

          result = Theme(
            data: theme.copyWith(
              colorScheme: theme.colorScheme.copyWith(
                outline: const Color(0xFF0F172A),
                outlineVariant:
                    const Color(0xFF475569),
                onSurface: const Color(0xFF0F172A),
              ),
              dividerColor: const Color(0xFF475569),
            ),
            child: result,
          );
        }

        return result;
      },
    );
  }
}

class GameHaptics {
  GameHaptics._();

  static Future<void> selectionClick() async {
    if (!AppPreferencesService
        .current.hapticsEnabled) {
      return;
    }
    await HapticFeedback.selectionClick();
  }

  static Future<void> lightImpact() async {
    if (!AppPreferencesService
        .current.hapticsEnabled) {
      return;
    }
    await HapticFeedback.lightImpact();
  }

  static Future<void> mediumImpact() async {
    if (!AppPreferencesService
        .current.hapticsEnabled) {
      return;
    }
    await HapticFeedback.mediumImpact();
  }

  static Future<void> heavyImpact() async {
    if (!AppPreferencesService
        .current.hapticsEnabled) {
      return;
    }
    await HapticFeedback.heavyImpact();
  }

  static Future<void> vibrate() async {
    if (!AppPreferencesService
        .current.hapticsEnabled) {
      return;
    }
    await HapticFeedback.vibrate();
  }
}

class AccessibilitySettingsButton
    extends StatelessWidget {
  const AccessibilitySettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                const AccessibilitySettingsScreen(),
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(
          color: Color(0x99FFE082),
        ),
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      icon: const Icon(
        Icons.accessibility_new_rounded,
      ),
      label: const Text(
        'Ayarlar & Erişilebilirlik',
        style: TextStyle(
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class AccessibilitySettingsScreen
    extends StatefulWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  State<AccessibilitySettingsScreen> createState() =>
      _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState
    extends State<AccessibilitySettingsScreen> {
  late AppPreferences _settings;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _settings = AppPreferencesService.current;
    _nameController = TextEditingController(
      text: _settings.defaultPlayerName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save(
    AppPreferences settings,
  ) async {
    setState(() => _settings = settings);
    await AppPreferencesService.save(settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ayarlar & Erişilebilirlik',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          14,
          10,
          14,
          22,
        ),
        children: [
          _hero(),
          const SizedBox(height: 12),
          _title('Kişiselleştirme'),
          _nameCard(),
          const SizedBox(height: 9),
          _colorCard(),
          const SizedBox(height: 12),
          _title('Okuma ve erişilebilirlik'),
          _textScaleCard(),
          _switchCard(
            emoji: '🧒',
            title: 'Çocuk modu',
            subtitle:
                'Tahta oyununda Kolay sorular, daha büyük '
                'yazılar, kategori açıklamaları ve kapalı risk.',
            value: _settings.childMode,
            onChanged: (value) async {
              await AppPreferencesService.setChildMode(
                value,
              );
              if (!mounted) return;
              setState(() {
                _settings =
                    AppPreferencesService.current;
              });
            },
          ),
          _switchCard(
            emoji: '👁️',
            title: 'Kategori destek modu',
            subtitle:
                'Tahtada renklerin yanında kategori '
                'emoji ve adlarını gösterir; kontrastı artırır.',
            value: _settings.categoryAssist,
            onChanged: (value) => _save(
              _settings.copyWith(
                categoryAssist: value,
              ),
            ),
          ),
          _switchCard(
            emoji: '📳',
            title: 'Titreşim geri bildirimi',
            subtitle:
                'Zar, seçim ve hareketlerdeki titreşimleri açar.',
            value: _settings.hapticsEnabled,
            onChanged: (value) => _save(
              _settings.copyWith(
                hapticsEnabled: value,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _title('Ses'),
          _switchCard(
            emoji: '🔊',
            title: 'Oyun sesleri',
            subtitle:
                'Zar, doğru, yanlış ve kutlama sesleri.',
            value: _settings.soundEnabled,
            onChanged: (value) async {
              await AppPreferencesService
                  .setSoundEnabled(value);
              if (!mounted) return;
              setState(() {
                _settings =
                    AppPreferencesService.current;
              });

              if (value) {
                unawaited(SoundFx.test());
              }
            },
          ),
          _volumeCard(),
          const SizedBox(height: 12),
          _title('Animasyon yoğunluğu'),
          _animationCard(),
          const SizedBox(height: 12),
          _title('Oynanış ve yardım'),
          Card(
            child: ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const GameplayBoostSettingsScreen(),
                  ),
                );
              },
              leading: const Text(
                '🎁',
                style: TextStyle(fontSize: 30),
              ),
              title: const Text(
                'Joker, risk ve XP ayarları',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: const Text(
                'Jokerleri, riskli soruları ve '
                'kutlama efektlerini ayrı ayrı yönet.',
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
              ),
            ),
          ),
          const SizedBox(height: 9),
          Card(
            child: ListTile(
              onTap: () {
                FirstRunTutorial.show(
                  context,
                  force: true,
                );
              },
              leading: const Text(
                '📘',
                style: TextStyle(fontSize: 30),
              ),
              title: const Text(
                'Oyunun eğitimini tekrar göster',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: const Text(
                'Zar, rota, rozet ve özel alanları '
                'dört kısa ekranda anlatır.',
              ),
              trailing: const Icon(
                Icons.play_circle_outline_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF155E75),
            Color(0xFF6D28D9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Text(
            '⚙️👁️🔊',
            style: TextStyle(fontSize: 32),
          ),
          SizedBox(height: 8),
          Text(
            'Bilgi Rotası sana uysun',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Yazı, ses, titreşim, animasyon ve '
            'oyuncu varsayılanlarını tek ekrandan yönet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFE7E1F0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _nameCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              maxLength: 18,
              textCapitalization:
                  TextCapitalization.words,
              decoration: const InputDecoration(
                counterText: '',
                labelText: 'Varsayılan oyuncu adı',
                prefixIcon: Icon(
                  Icons.person_rounded,
                ),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 9),
            FilledButton.icon(
              onPressed: () {
                final value =
                    _nameController.text.trim();

                _save(
                  _settings.copyWith(
                    defaultPlayerName: value.isEmpty
                        ? 'Oyuncu'
                        : value,
                  ),
                );
              },
              icon: const Icon(Icons.save_rounded),
              label: const Text(
                'Oyuncu Adını Kaydet',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Serbest Rota varsayılan rengi',
              style: TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 11,
              runSpacing: 11,
              children: [
                for (var index = 0;
                    index <
                        AppPreferencesService
                            .playerColors.length;
                    index++)
                  InkWell(
                    onTap: () => _save(
                      _settings.copyWith(
                        defaultColorIndex: index,
                      ),
                    ),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppPreferencesService
                            .playerColors[index],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              _settings.defaultColorIndex ==
                                      index
                                  ? Colors.black
                                  : Colors.white,
                          width:
                              _settings.defaultColorIndex ==
                                      index
                                  ? 3.5
                                  : 2,
                        ),
                      ),
                      child:
                          _settings.defaultColorIndex ==
                                  index
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                )
                              : null,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _textScaleCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 7),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Yazı boyutu',
              style: TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 11),
            SegmentedButton<double>(
              segments: const [
                ButtonSegment<double>(
                  value: 1.0,
                  label: Text('Normal'),
                ),
                ButtonSegment<double>(
                  value: 1.15,
                  label: Text('Büyük'),
                ),
                ButtonSegment<double>(
                  value: 1.30,
                  label: Text('Çok büyük'),
                ),
              ],
              selected: <double>{
                _settings.textScale,
              },
              onSelectionChanged: (selection) {
                _save(
                  _settings.copyWith(
                    textScale: selection.first,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _volumeCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 7),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  '🎚️',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 11),
                const Expanded(
                  child: Text(
                    'Ana ses seviyesi',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '%${(_settings.masterVolume * 100).round()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            Slider(
              value: _settings.masterVolume,
              min: 0,
              max: 1,
              divisions: 10,
              onChanged: _settings.soundEnabled
                  ? (value) {
                      _save(
                        _settings.copyWith(
                          masterVolume: value,
                        ),
                      );
                    }
                  : null,
              onChangeEnd: (_) {
                if (_settings.soundEnabled) {
                  unawaited(SoundFx.test());
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _animationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment<String>(
                  value: 'full',
                  label: Text('Tam'),
                  icon: Icon(
                    Icons.auto_awesome_rounded,
                  ),
                ),
                ButtonSegment<String>(
                  value: 'reduced',
                  label: Text('Azaltılmış'),
                  icon: Icon(
                    Icons.motion_photos_paused_rounded,
                  ),
                ),
                ButtonSegment<String>(
                  value: 'minimal',
                  label: Text('Minimum'),
                  icon: Icon(
                    Icons.block_rounded,
                  ),
                ),
              ],
              selected: <String>{
                _settings.animationMode,
              },
              onSelectionChanged: (selection) async {
                await AppPreferencesService
                    .setAnimationMode(
                  selection.first,
                );

                if (!mounted) return;
                setState(() {
                  _settings =
                      AppPreferencesService.current;
                });
              },
            ),
            const SizedBox(height: 10),
            Text(
              switch (_settings.animationMode) {
                'minimal' =>
                  'XP uçuşları, seri efektleri, seviye '
                      'kutlamaları ve canlı tahta kapalı.',
                'reduced' =>
                  'XP uçuşları, seri efektleri ve canlı '
                      'tahta kapalı; seviye ekranı açık.',
                _ =>
                  'Bütün kutlamalar ve canlı tahta açık.',
              },
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchCard({
    required String emoji,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 7),
      child: SwitchListTile(
        value: value,
        dense: true,
        visualDensity: VisualDensity.compact,
        onChanged: onChanged,
        secondary: Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class AccessibilityCategoryLegend
    extends StatelessWidget {
  const AccessibilityCategoryLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppPreferencesService.revision,
      builder: (context, _, __) {
        if (!AppPreferencesService
            .current.categoryAssist) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(
            12,
            2,
            12,
            8,
          ),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFF334155),
              width: 1.5,
            ),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 9,
            runSpacing: 7,
            children: [
              for (final category
                  in GameCategory.values)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(category.emoji),
                    const SizedBox(width: 3),
                    Text(
                      category.label,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class FirstRunTutorial {
  FirstRunTutorial._();

  static const List<_TutorialPage> _pages =
      <_TutorialPage>[
    _TutorialPage(
      emoji: '🎲',
      title: 'Zarı at',
      text:
          'Tahta oyununda zar sonucu kadar ilerlersin. '
          'Kavşaklarda gideceğin yolu sen seçersin.',
    ),
    _TutorialPage(
      emoji: '🧭',
      title: 'Rotanı seç',
      text:
          'Dış halkada sağa veya sola; bağlantılarda '
          'merkeze ya da dış halkaya ilerleyebilirsin.',
    ),
    _TutorialPage(
      emoji: '🏅',
      title: 'Altı rozeti topla',
      text:
          'Beyaz çerçeveli rozet alanlarında soruyu '
          'doğru bilerek kategori rozetini kazan.',
    ),
    _TutorialPage(
      emoji: '✨',
      title: 'Özel alanları kullan',
      text:
          'İleri 2, Geri 2, Kategori Seç ve Çifte Şans '
          'alanları oyunun yönünü değiştirebilir.',
    ),
  ];

  static Future<void> showIfNeeded(
    BuildContext context,
  ) async {
    if (AppPreferencesService.current.tutorialSeen) {
      return;
    }

    await show(context);
  }

  static Future<void> show(
    BuildContext context, {
    bool force = false,
  }) async {
    if (!force &&
        AppPreferencesService.current.tutorialSeen) {
      return;
    }

    final controller = PageController();
    var page = 0;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final item = _pages[page];

            return SafeArea(
              child: Container(
                margin: const EdgeInsets.all(14),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  21,
                  20,
                  18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFFFFD978),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 280,
                      child: PageView.builder(
                        controller: controller,
                        itemCount: _pages.length,
                        onPageChanged: (index) {
                          setSheetState(() => page = index);
                        },
                        itemBuilder: (context, index) {
                          final current = _pages[index];

                          return Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Text(
                                current.emoji,
                                style: const TextStyle(
                                  fontSize: 76,
                                ),
                              ),
                              const SizedBox(height: 13),
                              Text(
                                current.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 27,
                                  fontWeight:
                                      FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 9),
                              Text(
                                current.text,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color:
                                      Color(0xFF475569),
                                  height: 1.4,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        for (var index = 0;
                            index < _pages.length;
                            index++)
                          AnimatedContainer(
                            duration: const Duration(
                              milliseconds: 180,
                            ),
                            width: index == page ? 24 : 8,
                            height: 8,
                            margin:
                                const EdgeInsets.symmetric(
                              horizontal: 3,
                            ),
                            decoration: BoxDecoration(
                              color: index == page
                                  ? const Color(0xFF7C3AED)
                                  : const Color(0xFFCBD5E1),
                              borderRadius:
                                  BorderRadius.circular(99),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 17),
                    Row(
                      children: [
                        if (page == 0)
                          TextButton(
                            onPressed: () async {
                              await AppPreferencesService
                                  .markTutorialSeen(true);
                              if (sheetContext.mounted) {
                                Navigator.pop(sheetContext);
                              }
                            },
                            child: const Text('Atla'),
                          )
                        else
                          TextButton(
                            onPressed: () {
                              controller.previousPage(
                                duration: const Duration(
                                  milliseconds: 260,
                                ),
                                curve: Curves.easeOut,
                              );
                            },
                            child: const Text('Geri'),
                          ),
                        const Spacer(),
                        FilledButton(
                          onPressed: () async {
                            if (page <
                                _pages.length - 1) {
                              await controller.nextPage(
                                duration: const Duration(
                                  milliseconds: 260,
                                ),
                                curve: Curves.easeOut,
                              );
                              return;
                            }

                            await AppPreferencesService
                                .markTutorialSeen(true);

                            if (sheetContext.mounted) {
                              Navigator.pop(sheetContext);
                            }
                          },
                          child: Text(
                            page == _pages.length - 1
                                ? 'Oyuna Başla'
                                : 'Devam',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    controller.dispose();
  }
}

class _TutorialPage {
  const _TutorialPage({
    required this.emoji,
    required this.title,
    required this.text,
  });

  final String emoji;
  final String title;
  final String text;
}
