part of 'main.dart';

class GameplayBoostSettings {
  const GameplayBoostSettings({
    this.xpAnimations = true,
    this.levelUpCelebration = true,
    this.streakEffects = true,
    this.jokersEnabled = true,
    this.riskQuestionsEnabled = true,
  });

  final bool xpAnimations;
  final bool levelUpCelebration;
  final bool streakEffects;
  final bool jokersEnabled;
  final bool riskQuestionsEnabled;

  GameplayBoostSettings copyWith({
    bool? xpAnimations,
    bool? levelUpCelebration,
    bool? streakEffects,
    bool? jokersEnabled,
    bool? riskQuestionsEnabled,
  }) {
    return GameplayBoostSettings(
      xpAnimations: xpAnimations ?? this.xpAnimations,
      levelUpCelebration:
          levelUpCelebration ?? this.levelUpCelebration,
      streakEffects: streakEffects ?? this.streakEffects,
      jokersEnabled: jokersEnabled ?? this.jokersEnabled,
      riskQuestionsEnabled:
          riskQuestionsEnabled ?? this.riskQuestionsEnabled,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'xpAnimations': xpAnimations,
        'levelUpCelebration': levelUpCelebration,
        'streakEffects': streakEffects,
        'jokersEnabled': jokersEnabled,
        'riskQuestionsEnabled': riskQuestionsEnabled,
      };

  factory GameplayBoostSettings.fromJson(
    Map<String, dynamic> json,
  ) {
    return GameplayBoostSettings(
      xpAnimations: json['xpAnimations'] != false,
      levelUpCelebration:
          json['levelUpCelebration'] != false,
      streakEffects: json['streakEffects'] != false,
      jokersEnabled: json['jokersEnabled'] != false,
      riskQuestionsEnabled:
          json['riskQuestionsEnabled'] != false,
    );
  }
}

class GameplayBoostSettingsService {
  GameplayBoostSettingsService._();

  static const String _key =
      'bilgi_rotasi_gameplay_boost_settings_v1';
  static final SharedPreferencesAsync _preferences =
      SharedPreferencesAsync();

  static final ValueNotifier<int> revision =
      ValueNotifier<int>(0);

  static GameplayBoostSettings current =
      const GameplayBoostSettings();

  static Future<void> initialize() async {
    current = await load();
  }

  static Future<GameplayBoostSettings> load() async {
    try {
      final raw = await _preferences.getString(_key);

      if (raw == null || raw.trim().isEmpty) {
        return const GameplayBoostSettings();
      }

      final decoded = jsonDecode(raw);

      if (decoded is Map<String, dynamic>) {
        return GameplayBoostSettings.fromJson(decoded);
      }

      if (decoded is Map) {
        return GameplayBoostSettings.fromJson(
          Map<String, dynamic>.from(decoded),
        );
      }
    } catch (_) {
      // Ayar kaydı bozulursa varsayılanlar kullanılır.
    }

    return const GameplayBoostSettings();
  }

  static Future<void> save(
    GameplayBoostSettings settings,
  ) async {
    current = settings;

    try {
      await _preferences.setString(
        _key,
        jsonEncode(settings.toJson()),
      );
    } catch (_) {
      // Ayar kaydı oyunun çalışmasını durdurmamalı.
    }

    revision.value++;
  }
}

class GameplayBoostSettingsButton extends StatelessWidget {
  const GameplayBoostSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                const GameplayBoostSettingsScreen(),
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
      icon: const Icon(Icons.auto_awesome_rounded),
      label: const Text(
        'Canlı Oyun, Jokerler & Risk Ayarları',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}

class GameplayBoostSettingsScreen extends StatefulWidget {
  const GameplayBoostSettingsScreen({super.key});

  @override
  State<GameplayBoostSettingsScreen> createState() =>
      _GameplayBoostSettingsScreenState();
}

class _GameplayBoostSettingsScreenState
    extends State<GameplayBoostSettingsScreen> {
  late GameplayBoostSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = GameplayBoostSettingsService.current;
  }

  Future<void> _update(
    GameplayBoostSettings settings,
  ) async {
    setState(() => _settings = settings);
    await GameplayBoostSettingsService.save(settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Canlı Oyun Ayarları',
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
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6D28D9),
                  Color(0xFF0F766E),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              children: [
                Text(
                  '🔥🎁⚡',
                  style: TextStyle(fontSize: 32),
                ),
                SizedBox(height: 8),
                Text(
                  'Oyunun heyecanını kendine göre ayarla',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Bu ayarlar soru bankasını ve kayıtlı '
                  'istatistiklerini değiştirmez.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFE7E1F0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          _sectionTitle('Canlı oyun hissi'),
          _switchTile(
            emoji: '✨',
            title: 'XP kazanma animasyonu',
            subtitle:
                'Sorudan sonra kazanılan XP ekranda uçar.',
            value: _settings.xpAnimations,
            onChanged: (value) => _update(
              _settings.copyWith(xpAnimations: value),
            ),
          ),
          _switchTile(
            emoji: '🏆',
            title: 'Seviye atlama gösterisi',
            subtitle:
                'Yeni seviye ve rütbe özel ekranla kutlanır.',
            value: _settings.levelUpCelebration,
            onChanged: (value) => _update(
              _settings.copyWith(
                levelUpCelebration: value,
              ),
            ),
          ),
          _switchTile(
            emoji: '🔥',
            title: 'Doğru cevap serisi efektleri',
            subtitle:
                '3, 5 ve 10 doğru serilerinde özel kutlama.',
            value: _settings.streakEffects,
            onChanged: (value) => _update(
              _settings.copyWith(streakEffects: value),
            ),
          ),
          const SizedBox(height: 14),
          _sectionTitle('Oynanış güçlendirmeleri'),
          _switchTile(
            emoji: '🎁',
            title: 'Jokerler',
            subtitle:
                '50:50, soru değiştir, ikinci şans ve '
                'kategori değiştir.',
            value: _settings.jokersEnabled,
            onChanged: (value) => _update(
              _settings.copyWith(jokersEnabled: value),
            ),
          ),
          _switchTile(
            emoji: '⚡',
            title: 'Riskli sorular',
            subtitle:
                'Daha zor soruyu seç; doğru cevapta 2 kat XP.',
            value: _settings.riskQuestionsEnabled,
            onChanged: (value) => _update(
              _settings.copyWith(
                riskQuestionsEnabled: value,
              ),
            ),
          ),
          const SizedBox(height: 11),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7D6),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: const Color(0xFFEAB308),
              ),
            ),
            child: const Text(
              'Jokerler her yeni oyun veya maratonda '
              'yenilenir. Her oyuncu dört jokerin her birinden '
              'bir adetle başlar. Tahtadaki hediye kutusu '
              'rastgele bir jokere +1 ekler. Yanlış cevap '
              'XP düşürmez; yalnızca doğru cevap serisini '
              'sıfırlar.',
              style: TextStyle(
                height: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _switchTile({
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

enum JokerKind {
  fiftyFifty,
  changeQuestion,
  secondChance,
  categoryChange,
}

extension JokerKindX on JokerKind {
  String get title => switch (this) {
        JokerKind.fiftyFifty => '50:50',
        JokerKind.changeQuestion => 'Soru Değiştir',
        JokerKind.secondChance => 'İkinci Şans',
        JokerKind.categoryChange => 'Kategori Değiştir',
      };

  String get emoji => switch (this) {
        JokerKind.fiftyFifty => '✂️',
        JokerKind.changeQuestion => '🔄',
        JokerKind.secondChance => '🍀',
        JokerKind.categoryChange => '🎨',
      };
}

class JokerWallet {
  JokerWallet({
    this.fiftyFifty = 1,
    this.changeQuestion = 1,
    this.secondChance = 1,
    this.categoryChange = 1,
  });

  int fiftyFifty;
  int changeQuestion;
  int secondChance;
  int categoryChange;

  factory JokerWallet.starter() => JokerWallet();

  int count(JokerKind kind) {
    return switch (kind) {
      JokerKind.fiftyFifty => fiftyFifty,
      JokerKind.changeQuestion => changeQuestion,
      JokerKind.secondChance => secondChance,
      JokerKind.categoryChange => categoryChange,
    };
  }

  bool consume(JokerKind kind) {
    if (count(kind) <= 0) return false;

    switch (kind) {
      case JokerKind.fiftyFifty:
        fiftyFifty--;
        break;
      case JokerKind.changeQuestion:
        changeQuestion--;
        break;
      case JokerKind.secondChance:
        secondChance--;
        break;
      case JokerKind.categoryChange:
        categoryChange--;
        break;
    }

    return true;
  }

  void grant(JokerKind kind, {int amount = 1}) {
    final safeAmount = max(0, amount);
    if (safeAmount == 0) return;

    switch (kind) {
      case JokerKind.fiftyFifty:
        fiftyFifty += safeAmount;
        break;
      case JokerKind.changeQuestion:
        changeQuestion += safeAmount;
        break;
      case JokerKind.secondChance:
        secondChance += safeAmount;
        break;
      case JokerKind.categoryChange:
        categoryChange += safeAmount;
        break;
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'fiftyFifty': fiftyFifty,
        'changeQuestion': changeQuestion,
        'secondChance': secondChance,
        'categoryChange': categoryChange,
      };

  factory JokerWallet.fromJson(dynamic raw) {
    if (raw is! Map) return JokerWallet.starter();

    final json = Map<String, dynamic>.from(raw);

    int read(String key) {
      return max(
        0,
        (json[key] as num?)?.toInt() ?? 1,
      );
    }

    return JokerWallet(
      fiftyFifty: read('fiftyFifty'),
      changeQuestion: read('changeQuestion'),
      secondChance: read('secondChance'),
      categoryChange: read('categoryChange'),
    );
  }
}

class JokerWalletMiniBar extends StatelessWidget {
  const JokerWalletMiniBar({
    required this.wallet,
    super.key,
  });

  final JokerWallet wallet;

  @override
  Widget build(BuildContext context) {
    if (!GameplayBoostSettingsService.current.jokersEnabled) {
      return const SizedBox.shrink();
    }

    final values = <(String, int)>[
      ('✂️', wallet.fiftyFifty),
      ('🔄', wallet.changeQuestion),
      ('🍀', wallet.secondChance),
      ('🎨', wallet.categoryChange),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF6D28D9).withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF6D28D9).withOpacity(0.18),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final value in values)
            Text(
              '${value.$1}${value.$2}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
        ],
      ),
    );
  }
}

class JokerActionButton extends StatelessWidget {
  const JokerActionButton({
    required this.emoji,
    required this.label,
    required this.count,
    required this.onPressed,
    this.active = false,
    super.key,
  });

  final String emoji;
  final String label;
  final int count;
  final VoidCallback? onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 9,
          ),
          backgroundColor: active
              ? const Color(0xFFEDE9FE)
              : null,
          side: BorderSide(
            color: active
                ? const Color(0xFF7C3AED)
                : const Color(0xFFCBD5E1),
            width: active ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 21),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'x$count',
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RiskQuestionBanner extends StatelessWidget {
  const RiskQuestionBanner({
    required this.multiplier,
    super.key,
  });

  final int multiplier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFB91C1C),
            Color(0xFFEA580C),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 9,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '⚡',
            style: TextStyle(fontSize: 22),
          ),
          const SizedBox(width: 8),
          Text(
            'RİSKLİ SORU • ${multiplier}x XP',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class LiveStreakPill extends StatelessWidget {
  const LiveStreakPill({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: XpProgressService.revision,
      builder: (context, _, __) {
        return FutureBuilder<XpProgress>(
          future: XpProgressService.load(),
          builder: (context, snapshot) {
            final streak =
                snapshot.data?.currentStreak ?? 0;

            if (streak <= 0) {
              return const SizedBox.shrink();
            }

            final multiplier = streak >= 10
                ? 3
                : streak >= 5
                    ? 2
                    : 1;

            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7D6),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: const Color(0xFFF59E0B),
                ),
              ),
              child: Text(
                multiplier > 1
                    ? '🔥 $streak doğru seri • ${multiplier}x seri XP'
                    : '🔥 $streak doğru seri',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF92400E),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class QuestionRiskPlan {
  const QuestionRiskPlan({
    required this.categoryIndex,
    required this.preferredDifficulty,
    required this.xpMultiplier,
    required this.risky,
    required this.categoryChanged,
  });

  final int categoryIndex;
  final String preferredDifficulty;
  final int xpMultiplier;
  final bool risky;
  final bool categoryChanged;
}

class GameplayBoostDialogs {
  GameplayBoostDialogs._();

  static String harderDifficulty(String value) {
    return switch (value.trim().toLowerCase()) {
      'kolay' => 'Orta',
      'orta' => 'Zor',
      _ => 'Zor',
    };
  }

  static Future<QuestionRiskPlan> chooseQuestionPlan(
    BuildContext context, {
    required int baseCategoryIndex,
    required String normalDifficulty,
    JokerWallet? wallet,
    bool allowCategoryChange = true,
  }) async {
    final settings = GameplayBoostSettingsService.current;
    final canRisk = settings.riskQuestionsEnabled;
    final canChangeCategory =
        settings.jokersEnabled &&
        allowCategoryChange &&
        wallet != null &&
        wallet.categoryChange > 0;

    QuestionRiskPlan normalPlan({
      int? categoryIndex,
      bool categoryChanged = false,
    }) {
      return QuestionRiskPlan(
        categoryIndex:
            categoryIndex ?? baseCategoryIndex,
        preferredDifficulty: normalDifficulty,
        xpMultiplier: 1,
        risky: false,
        categoryChanged: categoryChanged,
      );
    }

    if (!canRisk && !canChangeCategory) {
      return normalPlan();
    }

    final selected =
        await showModalBottomSheet<QuestionRiskPlan>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final category =
            GameCategory.values[baseCategoryIndex];
        final riskyDifficulty =
            harderDifficulty(normalDifficulty);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              4,
              18,
              22,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Sorunun yolunu seç',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '${category.emoji} ${category.label}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: category.darkColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                _planTile(
                  emoji: '🛡️',
                  title: 'Normal Soru',
                  subtitle:
                      '$normalDifficulty • Standart XP',
                  color: const Color(0xFF0F766E),
                  onTap: () {
                    Navigator.pop(
                      sheetContext,
                      normalPlan(),
                    );
                  },
                ),
                if (canRisk) ...[
                  const SizedBox(height: 9),
                  _planTile(
                    emoji: '⚡',
                    title: 'Riskli Soru',
                    subtitle:
                        '$riskyDifficulty • Doğruysa 2 kat XP',
                    color: const Color(0xFFDC2626),
                    onTap: () {
                      Navigator.pop(
                        sheetContext,
                        QuestionRiskPlan(
                          categoryIndex:
                              baseCategoryIndex,
                          preferredDifficulty:
                              riskyDifficulty,
                          xpMultiplier: 2,
                          risky: true,
                          categoryChanged: false,
                        ),
                      );
                    },
                  ),
                ],
                if (canChangeCategory) ...[
                  const SizedBox(height: 9),
                  _planTile(
                    emoji: '🎨',
                    title: 'Kategori Değiştir',
                    subtitle:
                        'Joker x${wallet.categoryChange}',
                    color: const Color(0xFF7C3AED),
                    onTap: () async {
                      final chosen =
                          await _chooseCategory(
                        sheetContext,
                        baseCategoryIndex,
                      );

                      if (chosen == null ||
                          !sheetContext.mounted) {
                        return;
                      }

                      wallet.consume(
                        JokerKind.categoryChange,
                      );

                      Navigator.pop(
                        sheetContext,
                        normalPlan(
                          categoryIndex: chosen,
                          categoryChanged: true,
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );

    return selected ?? normalPlan();
  }

  static Widget _planTile({
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.09),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: color.withOpacity(0.45),
            ),
          ),
          child: Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 31),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<int?> _chooseCategory(
    BuildContext context,
    int currentCategory,
  ) {
    return showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Yeni kategoriyi seç',
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            14,
            12,
            14,
            8,
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var index = 0;
                    index <
                        GameCategory.values.length;
                    index++)
                  if (index != currentCategory)
                    Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 7,
                      ),
                      child: ListTile(
                        leading: Text(
                          GameCategory
                              .values[index].emoji,
                          style: const TextStyle(
                            fontSize: 25,
                          ),
                        ),
                        title: Text(
                          GameCategory
                              .values[index].label,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                        tileColor: GameCategory
                            .values[index].color
                            .withOpacity(0.10),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            15,
                          ),
                        ),
                        onTap: () =>
                            Navigator.pop(
                          dialogContext,
                          index,
                        ),
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

}

class GameplayBoostQuestionPicker {
  GameplayBoostQuestionPicker._();

  static QuizQuestion? riskQuestion({
    required QuestionBank questionBank,
    required QuizQuestion current,
    required String preferredDifficulty,
    required Set<String> usedQuestionIds,
  }) {
    final pool = questionBank
            .questionsByCategory[current.categoryIndex] ??
        const <QuizQuestion>[];

    final candidates = pool
        .where(
          (question) =>
              question.id != current.id &&
              question.difficulty ==
                  preferredDifficulty &&
              !usedQuestionIds
                  .contains(question.id),
        )
        .toList();

    if (candidates.isEmpty) return null;

    final selected =
        candidates[Random().nextInt(candidates.length)];

    usedQuestionIds.add(selected.id);
    return selected;
  }

  static QuizQuestion? replacement({
    required QuestionBank questionBank,
    required QuizQuestion current,
    required Set<String> usedQuestionIds,
  }) {
    final pool = questionBank
            .questionsByCategory[current.categoryIndex] ??
        const <QuizQuestion>[];

    var candidates = pool
        .where(
          (question) =>
              question.id != current.id &&
              question.difficulty ==
                  current.difficulty &&
              !usedQuestionIds
                  .contains(question.id),
        )
        .toList();

    if (candidates.isEmpty) return null;

    final selected =
        candidates[Random().nextInt(candidates.length)];

    usedQuestionIds.add(selected.id);
    return selected;
  }
}

class XpGainResult {
  const XpGainResult({
    required this.amount,
    required this.oldLevel,
    required this.newLevel,
    required this.previousStreak,
    required this.currentStreak,
    required this.reason,
    required this.xpMultiplier,
    required this.oldRank,
    required this.newRank,
  });

  final int amount;
  final int oldLevel;
  final int newLevel;
  final int previousStreak;
  final int currentStreak;
  final String reason;
  final int xpMultiplier;
  final XpRank oldRank;
  final XpRank newRank;

  bool get leveledUp => newLevel > oldLevel;
  bool get rankChanged =>
      oldRank.title != newRank.title;

  int get streakMilestone {
    if (currentStreak >= 10 &&
        previousStreak < 10) {
      return 10;
    }

    if (currentStreak >= 5 &&
        previousStreak < 5) {
      return 5;
    }

    if (currentStreak >= 3 &&
        previousStreak < 3) {
      return 3;
    }

    return 0;
  }

  factory XpGainResult.combine(
    List<XpGainResult> values, {
    String reason = 'Toplam XP kazancı',
  }) {
    if (values.isEmpty) {
      final rank = XpProgressService.rankFor(1);

      return XpGainResult(
        amount: 0,
        oldLevel: 1,
        newLevel: 1,
        previousStreak: 0,
        currentStreak: 0,
        reason: reason,
        xpMultiplier: 1,
        oldRank: rank,
        newRank: rank,
      );
    }

    return XpGainResult(
      amount: values.fold<int>(
        0,
        (total, value) =>
            total + value.amount,
      ),
      oldLevel: values.first.oldLevel,
      newLevel: values.last.newLevel,
      previousStreak:
          values.first.previousStreak,
      currentStreak:
          values.last.currentStreak,
      reason: reason,
      xpMultiplier: values
          .map((value) => value.xpMultiplier)
          .fold<int>(1, max),
      oldRank: values.first.oldRank,
      newRank: values.last.newRank,
    );
  }
}

class XpCelebration {
  XpCelebration._();

  static Future<void> show(
    BuildContext context,
    XpGainResult gain,
  ) async {
    final settings =
        GameplayBoostSettingsService.current;

    if (gain.amount > 0 &&
        settings.xpAnimations) {
      await _showXpToast(context, gain);
    }

    if (!context.mounted) return;

    if (settings.streakEffects &&
        gain.streakMilestone > 0) {
      await _showStreakMilestone(
        context,
        gain.streakMilestone,
      );
    }

    if (!context.mounted) return;

    if (settings.levelUpCelebration &&
        gain.leveledUp) {
      await _showLevelUp(context, gain);
    }

    if (!context.mounted) return;

    if (gain.amount == 0 &&
        gain.previousStreak >= 3 &&
        gain.currentStreak == 0 &&
        settings.streakEffects) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '🔥 ${gain.previousStreak} doğru cevaplık '
              'seri sona erdi.',
            ),
          ),
        );
    }
  }

  static Future<void> _showXpToast(
    BuildContext context,
    XpGainResult gain,
  ) async {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (overlayContext) {
        return Positioned(
          top: MediaQuery.paddingOf(
                overlayContext,
              ).top +
              18,
          left: 24,
          right: 24,
          child: IgnorePointer(
            child: _XpFlyingToast(gain: gain),
          ),
        );
      },
    );

    overlay.insert(entry);
    await Future<void>.delayed(
      const Duration(milliseconds: 1050),
    );

    if (entry.mounted) entry.remove();
  }

  static Future<void> _showStreakMilestone(
    BuildContext context,
    int milestone,
  ) async {
    final data = switch (milestone) {
      10 => (
          '🔥👑',
          'EFSANE SERİ!',
          '10 doğru seri: temel soru XP’si 3 kat.',
        ),
      5 => (
          '🔥🔥',
          'SERİ ÇARPANI AÇILDI!',
          '5 doğru seri: temel soru XP’si 2 kat.',
        ),
      _ => (
          '🔥',
          'ATEŞ SERİSİ!',
          '3 doğru seri: ekstra seri bonusu başladı.',
        ),
    };

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Seri kutlaması',
      barrierColor: Colors.black54,
      transitionDuration:
          const Duration(milliseconds: 300),
      pageBuilder: (
        dialogContext,
        animation,
        secondaryAnimation,
      ) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: min(
                330.0,
                MediaQuery.sizeOf(
                      dialogContext,
                    ).width -
                    36,
              ),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF9A3412),
                    Color(0xFF7C2D12),
                    Color(0xFF4C1D95),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFFFFE082),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.$1,
                    style:
                        const TextStyle(fontSize: 55),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.$2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFFFE082),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.$3,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 17),
                  FilledButton(
                    onPressed: () =>
                        Navigator.pop(
                      dialogContext,
                    ),
                    child: const Text('Devam Et'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.72,
              end: 1,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }

  static Future<void> _showLevelUp(
    BuildContext context,
    XpGainResult gain,
  ) async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Seviye atlama',
      barrierColor: const Color(0xCC13091D),
      transitionDuration:
          const Duration(milliseconds: 420),
      pageBuilder: (
        dialogContext,
        animation,
        secondaryAnimation,
      ) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: min(
                350.0,
                MediaQuery.sizeOf(
                      dialogContext,
                    ).width -
                    34,
              ),
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  center: Alignment(0, -0.5),
                  radius: 1.25,
                  colors: [
                    Color(0xFF7C3AED),
                    Color(0xFF4A245D),
                    Color(0xFF0F3F4A),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(32),
                border: Border.all(
                  color: const Color(0xFFFFD978),
                  width: 2.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '✨🏆✨',
                    style: TextStyle(fontSize: 50),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'SEVİYE ATLADIN!',
                    style: TextStyle(
                      color: Color(0xFFFFE082),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${gain.oldLevel}  →  ${gain.newLevel}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    gain.rankChanged
                        ? '${gain.newRank.emoji} Yeni rütbe: '
                            '${gain.newRank.title}'
                        : '${gain.newRank.emoji} '
                            '${gain.newRank.title}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFFFE082),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    gain.newRank.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFE7E1F0),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () =>
                        Navigator.pop(
                      dialogContext,
                    ),
                    icon: const Icon(
                      Icons.explore_rounded,
                    ),
                    label: const Text(
                      'Rotaya Devam',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.45,
              end: 1,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.elasticOut,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

class _XpFlyingToast extends StatelessWidget {
  const _XpFlyingToast({
    required this.gain,
  });

  final XpGainResult gain;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 750),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(
              0,
              24 * (1 - value),
            ),
            child: Transform.scale(
              scale: 0.75 + value * 0.25,
              child: child,
            ),
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF6D28D9),
                Color(0xFF0F766E),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFFFE082),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Text(
                '✨',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Text(
                '+${gain.amount} XP',
                style: const TextStyle(
                  color: Color(0xFFFFE082),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (gain.xpMultiplier > 1) ...[
                const SizedBox(width: 8),
                Text(
                  '${gain.xpMultiplier}x',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
