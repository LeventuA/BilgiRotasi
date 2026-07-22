part of 'main.dart';

class BoardThemeDefinition {
  const BoardThemeDefinition({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.unlockLevel,
    required this.backgroundColors,
    required this.gold,
    required this.darkGold,
    required this.foundation,
    required this.centerColors,
  });

  final String id;
  final String title;
  final String emoji;
  final String description;
  final int unlockLevel;
  final List<Color> backgroundColors;
  final Color gold;
  final Color darkGold;
  final Color foundation;
  final List<Color> centerColors;
}

const List<BoardThemeDefinition> boardThemes =
    <BoardThemeDefinition>[
  BoardThemeDefinition(
    id: 'classic',
    title: 'Klasik Bilgi Rotası',
    emoji: '🧭',
    description: 'Mor, turkuaz ve altın klasik görünüm.',
    unlockLevel: 1,
    backgroundColors: <Color>[
      Color(0xFF56336B),
      Color(0xFF382047),
      Color(0xFF1D1027),
    ],
    gold: Color(0xFFE8C76A),
    darkGold: Color(0xFF7B5721),
    foundation: Color(0xFF2B1837),
    centerColors: <Color>[
      Color(0xFF2B7184),
      Color(0xFF153E50),
      Color(0xFF071E2A),
    ],
  ),
  BoardThemeDefinition(
    id: 'egypt',
    title: 'Antik Mısır',
    emoji: '🏺',
    description: 'Kum taşı, lapis ve firavun altını.',
    unlockLevel: 5,
    backgroundColors: <Color>[
      Color(0xFF9A6A2F),
      Color(0xFF5F3A18),
      Color(0xFF24160B),
    ],
    gold: Color(0xFFFFD166),
    darkGold: Color(0xFF8A5415),
    foundation: Color(0xFF3A2410),
    centerColors: <Color>[
      Color(0xFF176B87),
      Color(0xFF0E4154),
      Color(0xFF071F2A),
    ],
  ),
  BoardThemeDefinition(
    id: 'space',
    title: 'Uzay İstasyonu',
    emoji: '🚀',
    description: 'Gece mavisi, neon mor ve yıldız ışığı.',
    unlockLevel: 10,
    backgroundColors: <Color>[
      Color(0xFF182A63),
      Color(0xFF17103D),
      Color(0xFF050716),
    ],
    gold: Color(0xFF9FE7FF),
    darkGold: Color(0xFF315A75),
    foundation: Color(0xFF101733),
    centerColors: <Color>[
      Color(0xFF6D28D9),
      Color(0xFF312E81),
      Color(0xFF0B1029),
    ],
  ),
  BoardThemeDefinition(
    id: 'forest',
    title: 'Bilgelik Ormanı',
    emoji: '🌲',
    description: 'Zümrüt yeşili ve sıcak ahşap tonları.',
    unlockLevel: 15,
    backgroundColors: <Color>[
      Color(0xFF28644A),
      Color(0xFF183E2E),
      Color(0xFF0A2017),
    ],
    gold: Color(0xFFD9B66F),
    darkGold: Color(0xFF6B4D23),
    foundation: Color(0xFF163426),
    centerColors: <Color>[
      Color(0xFF3F7D58),
      Color(0xFF24513B),
      Color(0xFF0D281C),
    ],
  ),
  BoardThemeDefinition(
    id: 'ocean',
    title: 'Derin Okyanus',
    emoji: '🌊',
    description: 'Mercan parıltılı derin deniz tahtası.',
    unlockLevel: 25,
    backgroundColors: <Color>[
      Color(0xFF087E8B),
      Color(0xFF07536A),
      Color(0xFF032A3A),
    ],
    gold: Color(0xFFFFC857),
    darkGold: Color(0xFF80601B),
    foundation: Color(0xFF073D4D),
    centerColors: <Color>[
      Color(0xFF00A6A6),
      Color(0xFF006D77),
      Color(0xFF023047),
    ],
  ),
  BoardThemeDefinition(
    id: 'future',
    title: 'Gelecek Şehri',
    emoji: '🌆',
    description: 'Neon pembe, elektrik mavisi ve krom.',
    unlockLevel: 35,
    backgroundColors: <Color>[
      Color(0xFF8B1E8F),
      Color(0xFF3B1B6E),
      Color(0xFF10142E),
    ],
    gold: Color(0xFF6FFFE9),
    darkGold: Color(0xFF285A66),
    foundation: Color(0xFF211B4A),
    centerColors: <Color>[
      Color(0xFFFF2E88),
      Color(0xFF7B2CBF),
      Color(0xFF240046),
    ],
  ),
];

class SoundAtmosphere {
  const SoundAtmosphere({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.unlockLevel,
    required this.volumeMultiplier,
    required this.playbackRate,
  });

  final String id;
  final String title;
  final String emoji;
  final String description;
  final int unlockLevel;
  final double volumeMultiplier;
  final double playbackRate;
}

const List<SoundAtmosphere> soundAtmospheres =
    <SoundAtmosphere>[
  SoundAtmosphere(
    id: 'classic',
    title: 'Klasik',
    emoji: '🎲',
    description: 'Oyunun standart ses dengesi.',
    unlockLevel: 1,
    volumeMultiplier: 1,
    playbackRate: 1,
  ),
  SoundAtmosphere(
    id: 'calm',
    title: 'Sakin',
    emoji: '🌙',
    description: 'Daha yumuşak ve düşük yoğunluklu sesler.',
    unlockLevel: 10,
    volumeMultiplier: 0.68,
    playbackRate: 0.93,
  ),
  SoundAtmosphere(
    id: 'energetic',
    title: 'Enerjik',
    emoji: '⚡',
    description: 'Daha canlı ve hızlı oyun hissi.',
    unlockLevel: 20,
    volumeMultiplier: 1,
    playbackRate: 1.08,
  ),
];

class VisualCollectionSettings {
  const VisualCollectionSettings({
    this.themeId = 'classic',
    this.favoritePawn = 0,
    this.soundId = 'classic',
    this.liveBoard = true,
  });

  final String themeId;
  final int favoritePawn;
  final String soundId;
  final bool liveBoard;

  VisualCollectionSettings copyWith({
    String? themeId,
    int? favoritePawn,
    String? soundId,
    bool? liveBoard,
  }) {
    return VisualCollectionSettings(
      themeId: themeId ?? this.themeId,
      favoritePawn: favoritePawn ?? this.favoritePawn,
      soundId: soundId ?? this.soundId,
      liveBoard: liveBoard ?? this.liveBoard,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'themeId': themeId,
        'favoritePawn': favoritePawn,
        'soundId': soundId,
        'liveBoard': liveBoard,
      };

  factory VisualCollectionSettings.fromJson(
    Map<String, dynamic> json,
  ) {
    return VisualCollectionSettings(
      themeId: json['themeId']?.toString() ?? 'classic',
      favoritePawn:
          (json['favoritePawn'] as num?)?.toInt() ?? 0,
      soundId: json['soundId']?.toString() ?? 'classic',
      liveBoard: json['liveBoard'] != false,
    );
  }
}

class VisualCollectionService {
  VisualCollectionService._();

  static const String _key =
      'bilgi_rotasi_visual_collection_v1';

  static final SharedPreferencesAsync _prefs =
      SharedPreferencesAsync();

  static final ValueNotifier<int> revision =
      ValueNotifier<int>(0);

  static VisualCollectionSettings current =
      const VisualCollectionSettings();

  static int currentLevel = 1;

  static Future<void> initialize() async {
    try {
      final raw = await _prefs.getString(_key);

      if (raw != null && raw.trim().isNotEmpty) {
        final decoded = jsonDecode(raw);

        if (decoded is Map) {
          current = VisualCollectionSettings.fromJson(
            Map<String, dynamic>.from(decoded),
          );
        }
      }
    } catch (_) {
      current = const VisualCollectionSettings();
    }

    await refreshLevel();

    if (!isThemeUnlocked(current.themeId)) {
      current = current.copyWith(themeId: 'classic');
    }

    if (!isSoundUnlocked(current.soundId)) {
      current = current.copyWith(soundId: 'classic');
    }

    final safePawn = current.favoritePawn
        .clamp(0, PawnCatalog.all.length - 1)
        .toInt();

    current = current.copyWith(favoritePawn: safePawn);
    await _save();
  }

  static Future<void> refreshLevel() async {
    final progress = await XpProgressService.load();
    currentLevel = progress.level;
  }

  static BoardThemeDefinition get theme {
    return boardThemes.firstWhere(
      (item) => item.id == current.themeId,
      orElse: () => boardThemes.first,
    );
  }

  static SoundAtmosphere get sound {
    return soundAtmospheres.firstWhere(
      (item) => item.id == current.soundId,
      orElse: () => soundAtmospheres.first,
    );
  }

  static bool isThemeUnlocked(String id) {
    final item = boardThemes.firstWhere(
      (theme) => theme.id == id,
      orElse: () => boardThemes.first,
    );

    return currentLevel >= item.unlockLevel;
  }

  static bool isSoundUnlocked(String id) {
    final item = soundAtmospheres.firstWhere(
      (sound) => sound.id == id,
      orElse: () => soundAtmospheres.first,
    );

    return currentLevel >= item.unlockLevel;
  }

  static Future<void> selectTheme(String id) async {
    await refreshLevel();
    if (!isThemeUnlocked(id)) return;

    current = current.copyWith(themeId: id);
    await _save();
  }

  static Future<void> selectSound(String id) async {
    await refreshLevel();
    if (!isSoundUnlocked(id)) return;

    current = current.copyWith(soundId: id);
    await _save();
  }

  static Future<void> selectFavoritePawn(int index) async {
    final safe = index.clamp(
      0,
      PawnCatalog.all.length - 1,
    ).toInt();

    current = current.copyWith(favoritePawn: safe);
    await _save();
  }

  static Future<void> setLiveBoard(bool value) async {
    current = current.copyWith(liveBoard: value);
    await _save();
  }

  static Future<void> _save() async {
    try {
      await _prefs.setString(
        _key,
        jsonEncode(current.toJson()),
      );
      revision.value++;
    } catch (_) {
      // Görsel ayar hatası oyunun açılmasını engellememeli.
    }
  }
}

class CollectionHomeButton extends StatelessWidget {
  const CollectionHomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: VisualCollectionService.revision,
      builder: (context, _, __) {
        final theme = VisualCollectionService.theme;
        final pawn = PawnCatalog.at(
          VisualCollectionService.current.favoritePawn,
        );

        return FilledButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CollectionScreen(),
              ),
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: theme.backgroundColors.first,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          icon: Text(
            theme.emoji,
            style: const TextStyle(fontSize: 22),
          ),
          label: Text(
            'Koleksiyon • ${theme.title} • ${pawn.name}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
        );
      },
    );
  }
}

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() =>
      _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_refresh());
  }

  Future<void> _refresh() async {
    await VisualCollectionService.refreshLevel();

    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Koleksiyon & Görünüm'),
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: VisualCollectionService.revision,
        builder: (context, _, __) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              18,
              16,
              18,
              28,
            ),
            children: [
              _hero(),
              const SizedBox(height: 18),
              const Text(
                'Tahta temaları',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 9),
              for (final theme in boardThemes)
                _themeCard(theme),
              const SizedBox(height: 18),
              const Text(
                'Piyon koleksiyonu',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Favori piyonun Serbest Rota ekranında '
                'varsayılan olarak seçilir.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              _pawnGrid(),
              const SizedBox(height: 18),
              const Text(
                'Ses atmosferi',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 9),
              for (final sound in soundAtmospheres)
                _soundCard(sound),
              const SizedBox(height: 14),
              SwitchListTile(
                value:
                    VisualCollectionService.current.liveBoard,
                onChanged:
                    VisualCollectionService.setLiveBoard,
                secondary: const Text(
                  '✨',
                  style: TextStyle(fontSize: 30),
                ),
                title: const Text(
                  'Canlı tahta parıltısı',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                subtitle: const Text(
                  'Tahtanın çevresinde yavaş ve hafif '
                  'bir ışık animasyonu oluşturur.',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _hero() {
    final theme = VisualCollectionService.theme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.backgroundColors,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.gold,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            theme.emoji,
            style: const TextStyle(fontSize: 58),
          ),
          const SizedBox(height: 7),
          Text(
            'Seviye ${VisualCollectionService.currentLevel} Koleksiyonu',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Yeni seviyelerde tema ve ses atmosferleri açılır.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _themeCard(BoardThemeDefinition theme) {
    final unlocked =
        VisualCollectionService.isThemeUnlocked(theme.id);
    final selected =
        VisualCollectionService.current.themeId == theme.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? theme.gold
              : const Color(0xFFE2E8F0),
          width: selected ? 2.2 : 1,
        ),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: unlocked
              ? () => VisualCollectionService.selectTheme(
                    theme.id,
                  )
              : () => _lockedMessage(
                    'Bu tema Seviye ${theme.unlockLevel} '
                    'olduğunda açılır.',
                  ),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 57,
                  height: 57,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: theme.backgroundColors,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    unlocked ? theme.emoji : '🔒',
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        theme.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        theme.description,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        unlocked
                            ? selected
                                ? 'Seçili tema'
                                : 'Kullanılabilir'
                            : 'Seviye ${theme.unlockLevel}',
                        style: TextStyle(
                          color: unlocked
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFB45309),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : unlocked
                          ? Icons.radio_button_unchecked_rounded
                          : Icons.lock_outline_rounded,
                  color: selected
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pawnGrid() {
    final selected =
        VisualCollectionService.current.favoritePawn;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: PawnCatalog.all.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 9,
        mainAxisSpacing: 9,
        childAspectRatio: 0.76,
      ),
      itemBuilder: (context, index) {
        final pawn = PawnCatalog.all[index];
        final active = index == selected;

        return InkWell(
          onTap: () =>
              VisualCollectionService.selectFavoritePawn(
            index,
          ),
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFFF3E8FF)
                  : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: active
                    ? const Color(0xFF7C3AED)
                    : const Color(0xFFD7DEE8),
                width: active ? 2.4 : 1.1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PawnToken(
                  type: index,
                  color: const Color(0xFF7C3AED),
                  active: active,
                  width: 58,
                  height: 72,
                ),
                const SizedBox(height: 5),
                Text(
                  pawn.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _soundCard(SoundAtmosphere sound) {
    final unlocked =
        VisualCollectionService.isSoundUnlocked(sound.id);
    final selected =
        VisualCollectionService.current.soundId == sound.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        onTap: unlocked
            ? () async {
                await VisualCollectionService.selectSound(
                  sound.id,
                );
                unawaited(SoundFx.test());
              }
            : () => _lockedMessage(
                  'Bu ses atmosferi Seviye '
                  '${sound.unlockLevel} olduğunda açılır.',
                ),
        tileColor: selected
            ? const Color(0xFFF0FDF4)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: selected
                ? const Color(0xFF86EFAC)
                : const Color(0xFFE2E8F0),
          ),
        ),
        leading: Text(
          unlocked ? sound.emoji : '🔒',
          style: const TextStyle(fontSize: 29),
        ),
        title: Text(
          sound.title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          unlocked
              ? sound.description
              : 'Seviye ${sound.unlockLevel}',
        ),
        trailing: Icon(
          selected
              ? Icons.check_circle_rounded
              : Icons.volume_up_rounded,
          color: selected
              ? const Color(0xFF16A34A)
              : const Color(0xFF64748B),
        ),
      ),
    );
  }

  void _lockedMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class LiveBoardLayer extends StatefulWidget {
  const LiveBoardLayer({super.key});

  @override
  State<LiveBoardLayer> createState() =>
      _LiveBoardLayerState();
}

class _LiveBoardLayerState extends State<LiveBoardLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: VisualCollectionService.revision,
      builder: (context, _, __) {
        final live =
            VisualCollectionService.current.liveBoard;

        if (!live) {
          return const CustomPaint(
            painter: BoardPainter(),
          );
        }

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: BoardPainter(
                pulse: _controller.value,
              ),
            );
          },
        );
      },
    );
  }
}
