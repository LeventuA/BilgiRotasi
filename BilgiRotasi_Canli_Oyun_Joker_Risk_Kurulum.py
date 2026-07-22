from pathlib import Path

GAMEPLAY_DART = "part of 'main.dart';\n\nclass GameplayBoostSettings {\n  const GameplayBoostSettings({\n    this.xpAnimations = true,\n    this.levelUpCelebration = true,\n    this.streakEffects = true,\n    this.jokersEnabled = true,\n    this.riskQuestionsEnabled = true,\n  });\n\n  final bool xpAnimations;\n  final bool levelUpCelebration;\n  final bool streakEffects;\n  final bool jokersEnabled;\n  final bool riskQuestionsEnabled;\n\n  GameplayBoostSettings copyWith({\n    bool? xpAnimations,\n    bool? levelUpCelebration,\n    bool? streakEffects,\n    bool? jokersEnabled,\n    bool? riskQuestionsEnabled,\n  }) {\n    return GameplayBoostSettings(\n      xpAnimations: xpAnimations ?? this.xpAnimations,\n      levelUpCelebration:\n          levelUpCelebration ?? this.levelUpCelebration,\n      streakEffects: streakEffects ?? this.streakEffects,\n      jokersEnabled: jokersEnabled ?? this.jokersEnabled,\n      riskQuestionsEnabled:\n          riskQuestionsEnabled ?? this.riskQuestionsEnabled,\n    );\n  }\n\n  Map<String, dynamic> toJson() => <String, dynamic>{\n        'xpAnimations': xpAnimations,\n        'levelUpCelebration': levelUpCelebration,\n        'streakEffects': streakEffects,\n        'jokersEnabled': jokersEnabled,\n        'riskQuestionsEnabled': riskQuestionsEnabled,\n      };\n\n  factory GameplayBoostSettings.fromJson(\n    Map<String, dynamic> json,\n  ) {\n    return GameplayBoostSettings(\n      xpAnimations: json['xpAnimations'] != false,\n      levelUpCelebration:\n          json['levelUpCelebration'] != false,\n      streakEffects: json['streakEffects'] != false,\n      jokersEnabled: json['jokersEnabled'] != false,\n      riskQuestionsEnabled:\n          json['riskQuestionsEnabled'] != false,\n    );\n  }\n}\n\nclass GameplayBoostSettingsService {\n  GameplayBoostSettingsService._();\n\n  static const String _key =\n      'bilgi_rotasi_gameplay_boost_settings_v1';\n  static final SharedPreferencesAsync _preferences =\n      SharedPreferencesAsync();\n\n  static final ValueNotifier<int> revision =\n      ValueNotifier<int>(0);\n\n  static GameplayBoostSettings current =\n      const GameplayBoostSettings();\n\n  static Future<void> initialize() async {\n    current = await load();\n  }\n\n  static Future<GameplayBoostSettings> load() async {\n    try {\n      final raw = await _preferences.getString(_key);\n\n      if (raw == null || raw.trim().isEmpty) {\n        return const GameplayBoostSettings();\n      }\n\n      final decoded = jsonDecode(raw);\n\n      if (decoded is Map<String, dynamic>) {\n        return GameplayBoostSettings.fromJson(decoded);\n      }\n\n      if (decoded is Map) {\n        return GameplayBoostSettings.fromJson(\n          Map<String, dynamic>.from(decoded),\n        );\n      }\n    } catch (_) {\n      // Ayar kaydı bozulursa varsayılanlar kullanılır.\n    }\n\n    return const GameplayBoostSettings();\n  }\n\n  static Future<void> save(\n    GameplayBoostSettings settings,\n  ) async {\n    current = settings;\n\n    try {\n      await _preferences.setString(\n        _key,\n        jsonEncode(settings.toJson()),\n      );\n    } catch (_) {\n      // Ayar kaydı oyunun çalışmasını durdurmamalı.\n    }\n\n    revision.value++;\n  }\n}\n\nclass GameplayBoostSettingsButton extends StatelessWidget {\n  const GameplayBoostSettingsButton({super.key});\n\n  @override\n  Widget build(BuildContext context) {\n    return OutlinedButton.icon(\n      onPressed: () {\n        Navigator.of(context).push(\n          MaterialPageRoute(\n            builder: (_) =>\n                const GameplayBoostSettingsScreen(),\n          ),\n        );\n      },\n      style: OutlinedButton.styleFrom(\n        foregroundColor: Colors.white,\n        side: const BorderSide(\n          color: Color(0x99FFE082),\n        ),\n        minimumSize: const Size.fromHeight(50),\n        shape: RoundedRectangleBorder(\n          borderRadius: BorderRadius.circular(18),\n        ),\n      ),\n      icon: const Icon(Icons.auto_awesome_rounded),\n      label: const Text(\n        'Canlı Oyun, Jokerler & Risk Ayarları',\n        style: TextStyle(fontWeight: FontWeight.w900),\n      ),\n    );\n  }\n}\n\nclass GameplayBoostSettingsScreen extends StatefulWidget {\n  const GameplayBoostSettingsScreen({super.key});\n\n  @override\n  State<GameplayBoostSettingsScreen> createState() =>\n      _GameplayBoostSettingsScreenState();\n}\n\nclass _GameplayBoostSettingsScreenState\n    extends State<GameplayBoostSettingsScreen> {\n  late GameplayBoostSettings _settings;\n\n  @override\n  void initState() {\n    super.initState();\n    _settings = GameplayBoostSettingsService.current;\n  }\n\n  Future<void> _update(\n    GameplayBoostSettings settings,\n  ) async {\n    setState(() => _settings = settings);\n    await GameplayBoostSettingsService.save(settings);\n  }\n\n  @override\n  Widget build(BuildContext context) {\n    return Scaffold(\n      appBar: AppBar(\n        title: const Text(\n          'Canlı Oyun Ayarları',\n        ),\n      ),\n      body: ListView(\n        padding: const EdgeInsets.fromLTRB(\n          18,\n          16,\n          18,\n          28,\n        ),\n        children: [\n          Container(\n            padding: const EdgeInsets.all(20),\n            decoration: BoxDecoration(\n              gradient: const LinearGradient(\n                colors: [\n                  Color(0xFF6D28D9),\n                  Color(0xFF0F766E),\n                ],\n              ),\n              borderRadius: BorderRadius.circular(26),\n            ),\n            child: const Column(\n              children: [\n                Text(\n                  '🔥🎁⚡',\n                  style: TextStyle(fontSize: 43),\n                ),\n                SizedBox(height: 8),\n                Text(\n                  'Oyunun heyecanını kendine göre ayarla',\n                  textAlign: TextAlign.center,\n                  style: TextStyle(\n                    color: Colors.white,\n                    fontSize: 22,\n                    fontWeight: FontWeight.w900,\n                  ),\n                ),\n                SizedBox(height: 7),\n                Text(\n                  'Bu ayarlar soru bankasını ve kayıtlı '\n                  'istatistiklerini değiştirmez.',\n                  textAlign: TextAlign.center,\n                  style: TextStyle(\n                    color: Color(0xFFE7E1F0),\n                  ),\n                ),\n              ],\n            ),\n          ),\n          const SizedBox(height: 16),\n          _sectionTitle('Canlı oyun hissi'),\n          _switchTile(\n            emoji: '✨',\n            title: 'XP kazanma animasyonu',\n            subtitle:\n                'Sorudan sonra kazanılan XP ekranda uçar.',\n            value: _settings.xpAnimations,\n            onChanged: (value) => _update(\n              _settings.copyWith(xpAnimations: value),\n            ),\n          ),\n          _switchTile(\n            emoji: '🏆',\n            title: 'Seviye atlama gösterisi',\n            subtitle:\n                'Yeni seviye ve rütbe özel ekranla kutlanır.',\n            value: _settings.levelUpCelebration,\n            onChanged: (value) => _update(\n              _settings.copyWith(\n                levelUpCelebration: value,\n              ),\n            ),\n          ),\n          _switchTile(\n            emoji: '🔥',\n            title: 'Doğru cevap serisi efektleri',\n            subtitle:\n                '3, 5 ve 10 doğru serilerinde özel kutlama.',\n            value: _settings.streakEffects,\n            onChanged: (value) => _update(\n              _settings.copyWith(streakEffects: value),\n            ),\n          ),\n          const SizedBox(height: 14),\n          _sectionTitle('Oynanış güçlendirmeleri'),\n          _switchTile(\n            emoji: '🎁',\n            title: 'Jokerler',\n            subtitle:\n                '50:50, soru değiştir, ikinci şans, '\n                'kategori değiştir ve zar tekrar.',\n            value: _settings.jokersEnabled,\n            onChanged: (value) => _update(\n              _settings.copyWith(jokersEnabled: value),\n            ),\n          ),\n          _switchTile(\n            emoji: '⚡',\n            title: 'Riskli sorular',\n            subtitle:\n                'Daha zor soruyu seç; doğru cevapta 2 kat XP.',\n            value: _settings.riskQuestionsEnabled,\n            onChanged: (value) => _update(\n              _settings.copyWith(\n                riskQuestionsEnabled: value,\n              ),\n            ),\n          ),\n          const SizedBox(height: 16),\n          Container(\n            padding: const EdgeInsets.all(16),\n            decoration: BoxDecoration(\n              color: const Color(0xFFFFF7D6),\n              borderRadius: BorderRadius.circular(20),\n              border: Border.all(\n                color: const Color(0xFFEAB308),\n              ),\n            ),\n            child: const Text(\n              'Jokerler her yeni oyun veya maratonda '\n              'yenilenir. Her oyuncu her jokerden bir adetle '\n              'başlar. Yanlış cevap XP düşürmez; yalnızca '\n              'doğru cevap serisini sıfırlar.',\n              style: TextStyle(\n                height: 1.4,\n                fontWeight: FontWeight.w700,\n              ),\n            ),\n          ),\n        ],\n      ),\n    );\n  }\n\n  Widget _sectionTitle(String text) {\n    return Padding(\n      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),\n      child: Text(\n        text,\n        style: const TextStyle(\n          fontSize: 19,\n          fontWeight: FontWeight.w900,\n        ),\n      ),\n    );\n  }\n\n  Widget _switchTile({\n    required String emoji,\n    required String title,\n    required String subtitle,\n    required bool value,\n    required ValueChanged<bool> onChanged,\n  }) {\n    return Card(\n      margin: const EdgeInsets.only(bottom: 10),\n      child: SwitchListTile(\n        value: value,\n        onChanged: onChanged,\n        secondary: Text(\n          emoji,\n          style: const TextStyle(fontSize: 28),\n        ),\n        title: Text(\n          title,\n          style: const TextStyle(\n            fontWeight: FontWeight.w900,\n          ),\n        ),\n        subtitle: Text(subtitle),\n      ),\n    );\n  }\n}\n\nenum JokerKind {\n  fiftyFifty,\n  changeQuestion,\n  secondChance,\n  categoryChange,\n  reroll,\n}\n\nclass JokerWallet {\n  JokerWallet({\n    this.fiftyFifty = 1,\n    this.changeQuestion = 1,\n    this.secondChance = 1,\n    this.categoryChange = 1,\n    this.reroll = 1,\n  });\n\n  int fiftyFifty;\n  int changeQuestion;\n  int secondChance;\n  int categoryChange;\n  int reroll;\n\n  factory JokerWallet.starter() => JokerWallet();\n\n  int count(JokerKind kind) {\n    return switch (kind) {\n      JokerKind.fiftyFifty => fiftyFifty,\n      JokerKind.changeQuestion => changeQuestion,\n      JokerKind.secondChance => secondChance,\n      JokerKind.categoryChange => categoryChange,\n      JokerKind.reroll => reroll,\n    };\n  }\n\n  bool consume(JokerKind kind) {\n    if (count(kind) <= 0) return false;\n\n    switch (kind) {\n      case JokerKind.fiftyFifty:\n        fiftyFifty--;\n        break;\n      case JokerKind.changeQuestion:\n        changeQuestion--;\n        break;\n      case JokerKind.secondChance:\n        secondChance--;\n        break;\n      case JokerKind.categoryChange:\n        categoryChange--;\n        break;\n      case JokerKind.reroll:\n        reroll--;\n        break;\n    }\n\n    return true;\n  }\n\n  Map<String, dynamic> toJson() => <String, dynamic>{\n        'fiftyFifty': fiftyFifty,\n        'changeQuestion': changeQuestion,\n        'secondChance': secondChance,\n        'categoryChange': categoryChange,\n        'reroll': reroll,\n      };\n\n  factory JokerWallet.fromJson(dynamic raw) {\n    if (raw is! Map) return JokerWallet.starter();\n\n    final json = Map<String, dynamic>.from(raw);\n\n    int read(String key) {\n      return max(\n        0,\n        (json[key] as num?)?.toInt() ?? 1,\n      );\n    }\n\n    return JokerWallet(\n      fiftyFifty: read('fiftyFifty'),\n      changeQuestion: read('changeQuestion'),\n      secondChance: read('secondChance'),\n      categoryChange: read('categoryChange'),\n      reroll: read('reroll'),\n    );\n  }\n}\n\nclass JokerWalletMiniBar extends StatelessWidget {\n  const JokerWalletMiniBar({\n    required this.wallet,\n    super.key,\n  });\n\n  final JokerWallet wallet;\n\n  @override\n  Widget build(BuildContext context) {\n    if (!GameplayBoostSettingsService.current.jokersEnabled) {\n      return const SizedBox.shrink();\n    }\n\n    final values = <(String, int)>[\n      ('✂️', wallet.fiftyFifty),\n      ('🔄', wallet.changeQuestion),\n      ('🍀', wallet.secondChance),\n      ('🎨', wallet.categoryChange),\n      ('🎲', wallet.reroll),\n    ];\n\n    return Container(\n      padding: const EdgeInsets.symmetric(\n        horizontal: 10,\n        vertical: 8,\n      ),\n      decoration: BoxDecoration(\n        color: const Color(0xFF6D28D9).withOpacity(0.07),\n        borderRadius: BorderRadius.circular(14),\n        border: Border.all(\n          color: const Color(0xFF6D28D9).withOpacity(0.18),\n        ),\n      ),\n      child: Row(\n        mainAxisAlignment: MainAxisAlignment.spaceEvenly,\n        children: [\n          for (final value in values)\n            Text(\n              '${value.$1}${value.$2}',\n              style: const TextStyle(\n                fontSize: 12,\n                fontWeight: FontWeight.w900,\n              ),\n            ),\n        ],\n      ),\n    );\n  }\n}\n\nclass JokerActionButton extends StatelessWidget {\n  const JokerActionButton({\n    required this.emoji,\n    required this.label,\n    required this.count,\n    required this.onPressed,\n    this.active = false,\n    super.key,\n  });\n\n  final String emoji;\n  final String label;\n  final int count;\n  final VoidCallback? onPressed;\n  final bool active;\n\n  @override\n  Widget build(BuildContext context) {\n    return Expanded(\n      child: OutlinedButton(\n        onPressed: onPressed,\n        style: OutlinedButton.styleFrom(\n          padding: const EdgeInsets.symmetric(\n            horizontal: 4,\n            vertical: 9,\n          ),\n          backgroundColor: active\n              ? const Color(0xFFEDE9FE)\n              : null,\n          side: BorderSide(\n            color: active\n                ? const Color(0xFF7C3AED)\n                : const Color(0xFFCBD5E1),\n            width: active ? 2 : 1,\n          ),\n        ),\n        child: Column(\n          mainAxisSize: MainAxisSize.min,\n          children: [\n            Text(\n              emoji,\n              style: const TextStyle(fontSize: 21),\n            ),\n            const SizedBox(height: 2),\n            Text(\n              label,\n              maxLines: 1,\n              style: const TextStyle(\n                fontSize: 9,\n                fontWeight: FontWeight.w900,\n              ),\n            ),\n            Text(\n              'x$count',\n              style: const TextStyle(\n                fontSize: 9,\n                color: Color(0xFF64748B),\n                fontWeight: FontWeight.w700,\n              ),\n            ),\n          ],\n        ),\n      ),\n    );\n  }\n}\n\nclass RiskQuestionBanner extends StatelessWidget {\n  const RiskQuestionBanner({\n    required this.multiplier,\n    super.key,\n  });\n\n  final int multiplier;\n\n  @override\n  Widget build(BuildContext context) {\n    return Container(\n      padding: const EdgeInsets.symmetric(\n        horizontal: 13,\n        vertical: 10,\n      ),\n      decoration: BoxDecoration(\n        gradient: const LinearGradient(\n          colors: [\n            Color(0xFFB91C1C),\n            Color(0xFFEA580C),\n          ],\n        ),\n        borderRadius: BorderRadius.circular(16),\n        boxShadow: const [\n          BoxShadow(\n            color: Color(0x33000000),\n            blurRadius: 9,\n            offset: Offset(0, 5),\n          ),\n        ],\n      ),\n      child: Row(\n        mainAxisAlignment: MainAxisAlignment.center,\n        children: [\n          const Text(\n            '⚡',\n            style: TextStyle(fontSize: 22),\n          ),\n          const SizedBox(width: 8),\n          Text(\n            'RİSKLİ SORU • ${multiplier}x XP',\n            style: const TextStyle(\n              color: Colors.white,\n              fontWeight: FontWeight.w900,\n              letterSpacing: 0.5,\n            ),\n          ),\n        ],\n      ),\n    );\n  }\n}\n\nclass LiveStreakPill extends StatelessWidget {\n  const LiveStreakPill({super.key});\n\n  @override\n  Widget build(BuildContext context) {\n    return ValueListenableBuilder<int>(\n      valueListenable: XpProgressService.revision,\n      builder: (context, _, __) {\n        return FutureBuilder<XpProgress>(\n          future: XpProgressService.load(),\n          builder: (context, snapshot) {\n            final streak =\n                snapshot.data?.currentStreak ?? 0;\n\n            if (streak <= 0) {\n              return const SizedBox.shrink();\n            }\n\n            final multiplier = streak >= 10\n                ? 3\n                : streak >= 5\n                    ? 2\n                    : 1;\n\n            return Container(\n              padding: const EdgeInsets.symmetric(\n                horizontal: 12,\n                vertical: 8,\n              ),\n              decoration: BoxDecoration(\n                color: const Color(0xFFFFF7D6),\n                borderRadius: BorderRadius.circular(999),\n                border: Border.all(\n                  color: const Color(0xFFF59E0B),\n                ),\n              ),\n              child: Text(\n                multiplier > 1\n                    ? '🔥 $streak doğru seri • ${multiplier}x seri XP'\n                    : '🔥 $streak doğru seri',\n                textAlign: TextAlign.center,\n                style: const TextStyle(\n                  color: Color(0xFF92400E),\n                  fontSize: 12,\n                  fontWeight: FontWeight.w900,\n                ),\n              ),\n            );\n          },\n        );\n      },\n    );\n  }\n}\n\nclass QuestionRiskPlan {\n  const QuestionRiskPlan({\n    required this.categoryIndex,\n    required this.preferredDifficulty,\n    required this.xpMultiplier,\n    required this.risky,\n    required this.categoryChanged,\n  });\n\n  final int categoryIndex;\n  final String preferredDifficulty;\n  final int xpMultiplier;\n  final bool risky;\n  final bool categoryChanged;\n}\n\nclass GameplayBoostDialogs {\n  GameplayBoostDialogs._();\n\n  static String harderDifficulty(String value) {\n    return switch (value.trim().toLowerCase()) {\n      'kolay' => 'Orta',\n      'orta' => 'Zor',\n      _ => 'Zor',\n    };\n  }\n\n  static Future<QuestionRiskPlan> chooseQuestionPlan(\n    BuildContext context, {\n    required int baseCategoryIndex,\n    required String normalDifficulty,\n    JokerWallet? wallet,\n    bool allowCategoryChange = true,\n  }) async {\n    final settings = GameplayBoostSettingsService.current;\n    final canRisk = settings.riskQuestionsEnabled;\n    final canChangeCategory =\n        settings.jokersEnabled &&\n        allowCategoryChange &&\n        wallet != null &&\n        wallet.categoryChange > 0;\n\n    QuestionRiskPlan normalPlan({\n      int? categoryIndex,\n      bool categoryChanged = false,\n    }) {\n      return QuestionRiskPlan(\n        categoryIndex:\n            categoryIndex ?? baseCategoryIndex,\n        preferredDifficulty: normalDifficulty,\n        xpMultiplier: 1,\n        risky: false,\n        categoryChanged: categoryChanged,\n      );\n    }\n\n    if (!canRisk && !canChangeCategory) {\n      return normalPlan();\n    }\n\n    final selected =\n        await showModalBottomSheet<QuestionRiskPlan>(\n      context: context,\n      isScrollControlled: true,\n      showDragHandle: true,\n      builder: (sheetContext) {\n        final category =\n            GameCategory.values[baseCategoryIndex];\n        final riskyDifficulty =\n            harderDifficulty(normalDifficulty);\n\n        return SafeArea(\n          child: Padding(\n            padding: const EdgeInsets.fromLTRB(\n              18,\n              4,\n              18,\n              22,\n            ),\n            child: Column(\n              mainAxisSize: MainAxisSize.min,\n              crossAxisAlignment:\n                  CrossAxisAlignment.stretch,\n              children: [\n                const Text(\n                  'Sorunun yolunu seç',\n                  textAlign: TextAlign.center,\n                  style: TextStyle(\n                    fontSize: 21,\n                    fontWeight: FontWeight.w900,\n                  ),\n                ),\n                const SizedBox(height: 7),\n                Text(\n                  '${category.emoji} ${category.label}',\n                  textAlign: TextAlign.center,\n                  style: TextStyle(\n                    color: category.darkColor,\n                    fontWeight: FontWeight.w800,\n                  ),\n                ),\n                const SizedBox(height: 14),\n                _planTile(\n                  emoji: '🛡️',\n                  title: 'Normal Soru',\n                  subtitle:\n                      '$normalDifficulty • Standart XP',\n                  color: const Color(0xFF0F766E),\n                  onTap: () {\n                    Navigator.pop(\n                      sheetContext,\n                      normalPlan(),\n                    );\n                  },\n                ),\n                if (canRisk) ...[\n                  const SizedBox(height: 9),\n                  _planTile(\n                    emoji: '⚡',\n                    title: 'Riskli Soru',\n                    subtitle:\n                        '$riskyDifficulty • Doğruysa 2 kat XP',\n                    color: const Color(0xFFDC2626),\n                    onTap: () {\n                      Navigator.pop(\n                        sheetContext,\n                        QuestionRiskPlan(\n                          categoryIndex:\n                              baseCategoryIndex,\n                          preferredDifficulty:\n                              riskyDifficulty,\n                          xpMultiplier: 2,\n                          risky: true,\n                          categoryChanged: false,\n                        ),\n                      );\n                    },\n                  ),\n                ],\n                if (canChangeCategory) ...[\n                  const SizedBox(height: 9),\n                  _planTile(\n                    emoji: '🎨',\n                    title: 'Kategori Değiştir',\n                    subtitle:\n                        'Joker x${wallet.categoryChange}',\n                    color: const Color(0xFF7C3AED),\n                    onTap: () async {\n                      final chosen =\n                          await _chooseCategory(\n                        sheetContext,\n                        baseCategoryIndex,\n                      );\n\n                      if (chosen == null ||\n                          !sheetContext.mounted) {\n                        return;\n                      }\n\n                      wallet.consume(\n                        JokerKind.categoryChange,\n                      );\n\n                      Navigator.pop(\n                        sheetContext,\n                        normalPlan(\n                          categoryIndex: chosen,\n                          categoryChanged: true,\n                        ),\n                      );\n                    },\n                  ),\n                ],\n              ],\n            ),\n          ),\n        );\n      },\n    );\n\n    return selected ?? normalPlan();\n  }\n\n  static Widget _planTile({\n    required String emoji,\n    required String title,\n    required String subtitle,\n    required Color color,\n    required VoidCallback onTap,\n  }) {\n    return Material(\n      color: color.withOpacity(0.09),\n      borderRadius: BorderRadius.circular(18),\n      child: InkWell(\n        onTap: onTap,\n        borderRadius: BorderRadius.circular(18),\n        child: Container(\n          padding: const EdgeInsets.all(15),\n          decoration: BoxDecoration(\n            borderRadius: BorderRadius.circular(18),\n            border: Border.all(\n              color: color.withOpacity(0.45),\n            ),\n          ),\n          child: Row(\n            children: [\n              Text(\n                emoji,\n                style: const TextStyle(fontSize: 31),\n              ),\n              const SizedBox(width: 12),\n              Expanded(\n                child: Column(\n                  crossAxisAlignment:\n                      CrossAxisAlignment.start,\n                  children: [\n                    Text(\n                      title,\n                      style: const TextStyle(\n                        fontSize: 16,\n                        fontWeight: FontWeight.w900,\n                      ),\n                    ),\n                    Text(\n                      subtitle,\n                      style: const TextStyle(\n                        color: Color(0xFF64748B),\n                        fontSize: 12,\n                      ),\n                    ),\n                  ],\n                ),\n              ),\n              Icon(\n                Icons.chevron_right_rounded,\n                color: color,\n              ),\n            ],\n          ),\n        ),\n      ),\n    );\n  }\n\n  static Future<int?> _chooseCategory(\n    BuildContext context,\n    int currentCategory,\n  ) {\n    return showDialog<int>(\n      context: context,\n      builder: (dialogContext) {\n        return AlertDialog(\n          title: const Text(\n            'Yeni kategoriyi seç',\n          ),\n          contentPadding: const EdgeInsets.fromLTRB(\n            14,\n            12,\n            14,\n            8,\n          ),\n          content: SizedBox(\n            width: double.maxFinite,\n            child: Column(\n              mainAxisSize: MainAxisSize.min,\n              children: [\n                for (var index = 0;\n                    index <\n                        GameCategory.values.length;\n                    index++)\n                  if (index != currentCategory)\n                    Padding(\n                      padding:\n                          const EdgeInsets.only(\n                        bottom: 7,\n                      ),\n                      child: ListTile(\n                        leading: Text(\n                          GameCategory\n                              .values[index].emoji,\n                          style: const TextStyle(\n                            fontSize: 25,\n                          ),\n                        ),\n                        title: Text(\n                          GameCategory\n                              .values[index].label,\n                          style: const TextStyle(\n                            fontWeight:\n                                FontWeight.w800,\n                          ),\n                        ),\n                        tileColor: GameCategory\n                            .values[index].color\n                            .withOpacity(0.10),\n                        shape: RoundedRectangleBorder(\n                          borderRadius:\n                              BorderRadius.circular(\n                            15,\n                          ),\n                        ),\n                        onTap: () =>\n                            Navigator.pop(\n                          dialogContext,\n                          index,\n                        ),\n                      ),\n                    ),\n              ],\n            ),\n          ),\n        );\n      },\n    );\n  }\n\n  static Future<bool> offerReroll(\n    BuildContext context, {\n    required int currentRoll,\n    required JokerWallet wallet,\n  }) async {\n    if (!GameplayBoostSettingsService\n            .current.jokersEnabled ||\n        wallet.reroll <= 0 ||\n        currentRoll > 3) {\n      return false;\n    }\n\n    return await showDialog<bool>(\n          context: context,\n          builder: (dialogContext) {\n            return AlertDialog(\n              icon: const Text(\n                '🎲',\n                style: TextStyle(fontSize: 47),\n              ),\n              title: Text(\n                '$currentRoll attın',\n              ),\n              content: Text(\n                'Zar Tekrar jokerini kullanarak '\n                'bir kez daha atabilirsin.\\n\\n'\n                'Kalan joker: ${wallet.reroll}',\n                textAlign: TextAlign.center,\n              ),\n              actions: [\n                TextButton(\n                  onPressed: () =>\n                      Navigator.pop(\n                    dialogContext,\n                    false,\n                  ),\n                  child: const Text(\n                    'Yola Devam',\n                  ),\n                ),\n                FilledButton(\n                  onPressed: () =>\n                      Navigator.pop(\n                    dialogContext,\n                    true,\n                  ),\n                  child: const Text(\n                    'Tekrar At',\n                  ),\n                ),\n              ],\n            );\n          },\n        ) ??\n        false;\n  }\n}\n\nclass GameplayBoostQuestionPicker {\n  GameplayBoostQuestionPicker._();\n\n  static QuizQuestion? riskQuestion({\n    required QuestionBank questionBank,\n    required QuizQuestion current,\n    required String preferredDifficulty,\n    required Set<String> usedQuestionIds,\n  }) {\n    final pool = questionBank\n            .questionsByCategory[current.categoryIndex] ??\n        const <QuizQuestion>[];\n\n    final candidates = pool\n        .where(\n          (question) =>\n              question.id != current.id &&\n              question.difficulty ==\n                  preferredDifficulty &&\n              !usedQuestionIds\n                  .contains(question.id),\n        )\n        .toList();\n\n    if (candidates.isEmpty) return null;\n\n    final selected =\n        candidates[Random().nextInt(candidates.length)];\n\n    usedQuestionIds.add(selected.id);\n    return selected;\n  }\n\n  static QuizQuestion? replacement({\n    required QuestionBank questionBank,\n    required QuizQuestion current,\n    required Set<String> usedQuestionIds,\n  }) {\n    final pool = questionBank\n            .questionsByCategory[current.categoryIndex] ??\n        const <QuizQuestion>[];\n\n    var candidates = pool\n        .where(\n          (question) =>\n              question.id != current.id &&\n              question.difficulty ==\n                  current.difficulty &&\n              !usedQuestionIds\n                  .contains(question.id),\n        )\n        .toList();\n\n    if (candidates.isEmpty) return null;\n\n    final selected =\n        candidates[Random().nextInt(candidates.length)];\n\n    usedQuestionIds.add(selected.id);\n    return selected;\n  }\n}\n\nclass XpGainResult {\n  const XpGainResult({\n    required this.amount,\n    required this.oldLevel,\n    required this.newLevel,\n    required this.previousStreak,\n    required this.currentStreak,\n    required this.reason,\n    required this.xpMultiplier,\n    required this.oldRank,\n    required this.newRank,\n  });\n\n  final int amount;\n  final int oldLevel;\n  final int newLevel;\n  final int previousStreak;\n  final int currentStreak;\n  final String reason;\n  final int xpMultiplier;\n  final XpRank oldRank;\n  final XpRank newRank;\n\n  bool get leveledUp => newLevel > oldLevel;\n  bool get rankChanged =>\n      oldRank.title != newRank.title;\n\n  int get streakMilestone {\n    if (currentStreak >= 10 &&\n        previousStreak < 10) {\n      return 10;\n    }\n\n    if (currentStreak >= 5 &&\n        previousStreak < 5) {\n      return 5;\n    }\n\n    if (currentStreak >= 3 &&\n        previousStreak < 3) {\n      return 3;\n    }\n\n    return 0;\n  }\n\n  factory XpGainResult.combine(\n    List<XpGainResult> values, {\n    String reason = 'Toplam XP kazancı',\n  }) {\n    if (values.isEmpty) {\n      final rank = XpProgressService.rankFor(1);\n\n      return XpGainResult(\n        amount: 0,\n        oldLevel: 1,\n        newLevel: 1,\n        previousStreak: 0,\n        currentStreak: 0,\n        reason: reason,\n        xpMultiplier: 1,\n        oldRank: rank,\n        newRank: rank,\n      );\n    }\n\n    return XpGainResult(\n      amount: values.fold<int>(\n        0,\n        (total, value) =>\n            total + value.amount,\n      ),\n      oldLevel: values.first.oldLevel,\n      newLevel: values.last.newLevel,\n      previousStreak:\n          values.first.previousStreak,\n      currentStreak:\n          values.last.currentStreak,\n      reason: reason,\n      xpMultiplier: values\n          .map((value) => value.xpMultiplier)\n          .fold<int>(1, max),\n      oldRank: values.first.oldRank,\n      newRank: values.last.newRank,\n    );\n  }\n}\n\nclass XpCelebration {\n  XpCelebration._();\n\n  static Future<void> show(\n    BuildContext context,\n    XpGainResult gain,\n  ) async {\n    final settings =\n        GameplayBoostSettingsService.current;\n\n    if (gain.amount > 0 &&\n        settings.xpAnimations) {\n      await _showXpToast(context, gain);\n    }\n\n    if (!context.mounted) return;\n\n    if (settings.streakEffects &&\n        gain.streakMilestone > 0) {\n      await _showStreakMilestone(\n        context,\n        gain.streakMilestone,\n      );\n    }\n\n    if (!context.mounted) return;\n\n    if (settings.levelUpCelebration &&\n        gain.leveledUp) {\n      await _showLevelUp(context, gain);\n    }\n\n    if (!context.mounted) return;\n\n    if (gain.amount == 0 &&\n        gain.previousStreak >= 3 &&\n        gain.currentStreak == 0 &&\n        settings.streakEffects) {\n      ScaffoldMessenger.of(context)\n        ..hideCurrentSnackBar()\n        ..showSnackBar(\n          SnackBar(\n            content: Text(\n              '🔥 ${gain.previousStreak} doğru cevaplık '\n              'seri sona erdi.',\n            ),\n          ),\n        );\n    }\n  }\n\n  static Future<void> _showXpToast(\n    BuildContext context,\n    XpGainResult gain,\n  ) async {\n    final overlay = Overlay.maybeOf(context);\n    if (overlay == null) return;\n\n    late final OverlayEntry entry;\n\n    entry = OverlayEntry(\n      builder: (overlayContext) {\n        return Positioned(\n          top: MediaQuery.paddingOf(\n                overlayContext,\n              ).top +\n              18,\n          left: 24,\n          right: 24,\n          child: IgnorePointer(\n            child: _XpFlyingToast(gain: gain),\n          ),\n        );\n      },\n    );\n\n    overlay.insert(entry);\n    await Future<void>.delayed(\n      const Duration(milliseconds: 1050),\n    );\n\n    if (entry.mounted) entry.remove();\n  }\n\n  static Future<void> _showStreakMilestone(\n    BuildContext context,\n    int milestone,\n  ) async {\n    final data = switch (milestone) {\n      10 => (\n          '🔥👑',\n          'EFSANE SERİ!',\n          '10 doğru seri: temel soru XP’si 3 kat.',\n        ),\n      5 => (\n          '🔥🔥',\n          'SERİ ÇARPANI AÇILDI!',\n          '5 doğru seri: temel soru XP’si 2 kat.',\n        ),\n      _ => (\n          '🔥',\n          'ATEŞ SERİSİ!',\n          '3 doğru seri: ekstra seri bonusu başladı.',\n        ),\n    };\n\n    await showGeneralDialog<void>(\n      context: context,\n      barrierDismissible: true,\n      barrierLabel: 'Seri kutlaması',\n      barrierColor: Colors.black54,\n      transitionDuration:\n          const Duration(milliseconds: 300),\n      pageBuilder: (\n        dialogContext,\n        animation,\n        secondaryAnimation,\n      ) {\n        return Center(\n          child: Material(\n            color: Colors.transparent,\n            child: Container(\n              width: min(\n                330.0,\n                MediaQuery.sizeOf(\n                      dialogContext,\n                    ).width -\n                    36,\n              ),\n              padding: const EdgeInsets.all(24),\n              decoration: BoxDecoration(\n                gradient: const LinearGradient(\n                  colors: [\n                    Color(0xFF9A3412),\n                    Color(0xFF7C2D12),\n                    Color(0xFF4C1D95),\n                  ],\n                ),\n                borderRadius:\n                    BorderRadius.circular(28),\n                border: Border.all(\n                  color: const Color(0xFFFFE082),\n                  width: 2,\n                ),\n              ),\n              child: Column(\n                mainAxisSize: MainAxisSize.min,\n                children: [\n                  Text(\n                    data.$1,\n                    style:\n                        const TextStyle(fontSize: 55),\n                  ),\n                  const SizedBox(height: 8),\n                  Text(\n                    data.$2,\n                    textAlign: TextAlign.center,\n                    style: const TextStyle(\n                      color: Color(0xFFFFE082),\n                      fontSize: 22,\n                      fontWeight: FontWeight.w900,\n                    ),\n                  ),\n                  const SizedBox(height: 8),\n                  Text(\n                    data.$3,\n                    textAlign: TextAlign.center,\n                    style: const TextStyle(\n                      color: Colors.white,\n                      height: 1.35,\n                      fontWeight: FontWeight.w700,\n                    ),\n                  ),\n                  const SizedBox(height: 17),\n                  FilledButton(\n                    onPressed: () =>\n                        Navigator.pop(\n                      dialogContext,\n                    ),\n                    child: const Text('Devam Et'),\n                  ),\n                ],\n              ),\n            ),\n          ),\n        );\n      },\n      transitionBuilder: (\n        context,\n        animation,\n        secondaryAnimation,\n        child,\n      ) {\n        return FadeTransition(\n          opacity: animation,\n          child: ScaleTransition(\n            scale: Tween<double>(\n              begin: 0.72,\n              end: 1,\n            ).animate(\n              CurvedAnimation(\n                parent: animation,\n                curve: Curves.easeOutBack,\n              ),\n            ),\n            child: child,\n          ),\n        );\n      },\n    );\n  }\n\n  static Future<void> _showLevelUp(\n    BuildContext context,\n    XpGainResult gain,\n  ) async {\n    await showGeneralDialog<void>(\n      context: context,\n      barrierDismissible: false,\n      barrierLabel: 'Seviye atlama',\n      barrierColor: const Color(0xCC13091D),\n      transitionDuration:\n          const Duration(milliseconds: 420),\n      pageBuilder: (\n        dialogContext,\n        animation,\n        secondaryAnimation,\n      ) {\n        return Center(\n          child: Material(\n            color: Colors.transparent,\n            child: Container(\n              width: min(\n                350.0,\n                MediaQuery.sizeOf(\n                      dialogContext,\n                    ).width -\n                    34,\n              ),\n              padding: const EdgeInsets.all(26),\n              decoration: BoxDecoration(\n                gradient: const RadialGradient(\n                  center: Alignment(0, -0.5),\n                  radius: 1.25,\n                  colors: [\n                    Color(0xFF7C3AED),\n                    Color(0xFF4A245D),\n                    Color(0xFF0F3F4A),\n                  ],\n                ),\n                borderRadius:\n                    BorderRadius.circular(32),\n                border: Border.all(\n                  color: const Color(0xFFFFD978),\n                  width: 2.5,\n                ),\n                boxShadow: const [\n                  BoxShadow(\n                    color: Color(0x66000000),\n                    blurRadius: 24,\n                    offset: Offset(0, 12),\n                  ),\n                ],\n              ),\n              child: Column(\n                mainAxisSize: MainAxisSize.min,\n                children: [\n                  const Text(\n                    '✨🏆✨',\n                    style: TextStyle(fontSize: 50),\n                  ),\n                  const SizedBox(height: 8),\n                  const Text(\n                    'SEVİYE ATLADIN!',\n                    style: TextStyle(\n                      color: Color(0xFFFFE082),\n                      fontSize: 24,\n                      fontWeight: FontWeight.w900,\n                      letterSpacing: 0.8,\n                    ),\n                  ),\n                  const SizedBox(height: 12),\n                  Text(\n                    '${gain.oldLevel}  →  ${gain.newLevel}',\n                    style: const TextStyle(\n                      color: Colors.white,\n                      fontSize: 42,\n                      fontWeight: FontWeight.w900,\n                    ),\n                  ),\n                  const SizedBox(height: 10),\n                  Text(\n                    gain.rankChanged\n                        ? '${gain.newRank.emoji} Yeni rütbe: '\n                            '${gain.newRank.title}'\n                        : '${gain.newRank.emoji} '\n                            '${gain.newRank.title}',\n                    textAlign: TextAlign.center,\n                    style: const TextStyle(\n                      color: Color(0xFFFFE082),\n                      fontSize: 18,\n                      fontWeight: FontWeight.w900,\n                    ),\n                  ),\n                  const SizedBox(height: 8),\n                  Text(\n                    gain.newRank.description,\n                    textAlign: TextAlign.center,\n                    style: const TextStyle(\n                      color: Color(0xFFE7E1F0),\n                      height: 1.35,\n                    ),\n                  ),\n                  const SizedBox(height: 20),\n                  FilledButton.icon(\n                    onPressed: () =>\n                        Navigator.pop(\n                      dialogContext,\n                    ),\n                    icon: const Icon(\n                      Icons.explore_rounded,\n                    ),\n                    label: const Text(\n                      'Rotaya Devam',\n                      style: TextStyle(\n                        fontWeight: FontWeight.w900,\n                      ),\n                    ),\n                  ),\n                ],\n              ),\n            ),\n          ),\n        );\n      },\n      transitionBuilder: (\n        context,\n        animation,\n        secondaryAnimation,\n        child,\n      ) {\n        return FadeTransition(\n          opacity: animation,\n          child: ScaleTransition(\n            scale: Tween<double>(\n              begin: 0.45,\n              end: 1,\n            ).animate(\n              CurvedAnimation(\n                parent: animation,\n                curve: Curves.elasticOut,\n              ),\n            ),\n            child: child,\n          ),\n        );\n      },\n    );\n  }\n}\n\nclass _XpFlyingToast extends StatelessWidget {\n  const _XpFlyingToast({\n    required this.gain,\n  });\n\n  final XpGainResult gain;\n\n  @override\n  Widget build(BuildContext context) {\n    return TweenAnimationBuilder<double>(\n      tween: Tween<double>(begin: 0, end: 1),\n      duration: const Duration(milliseconds: 750),\n      curve: Curves.easeOutBack,\n      builder: (context, value, child) {\n        return Opacity(\n          opacity: value.clamp(0.0, 1.0),\n          child: Transform.translate(\n            offset: Offset(\n              0,\n              24 * (1 - value),\n            ),\n            child: Transform.scale(\n              scale: 0.75 + value * 0.25,\n              child: child,\n            ),\n          ),\n        );\n      },\n      child: Material(\n        color: Colors.transparent,\n        child: Container(\n          padding: const EdgeInsets.symmetric(\n            horizontal: 18,\n            vertical: 13,\n          ),\n          decoration: BoxDecoration(\n            gradient: const LinearGradient(\n              colors: [\n                Color(0xFF6D28D9),\n                Color(0xFF0F766E),\n              ],\n            ),\n            borderRadius: BorderRadius.circular(22),\n            border: Border.all(\n              color: const Color(0xFFFFE082),\n              width: 2,\n            ),\n            boxShadow: const [\n              BoxShadow(\n                color: Color(0x66000000),\n                blurRadius: 16,\n                offset: Offset(0, 8),\n              ),\n            ],\n          ),\n          child: Row(\n            mainAxisAlignment:\n                MainAxisAlignment.center,\n            children: [\n              const Text(\n                '✨',\n                style: TextStyle(fontSize: 24),\n              ),\n              const SizedBox(width: 8),\n              Text(\n                '+${gain.amount} XP',\n                style: const TextStyle(\n                  color: Color(0xFFFFE082),\n                  fontSize: 24,\n                  fontWeight: FontWeight.w900,\n                ),\n              ),\n              if (gain.xpMultiplier > 1) ...[\n                const SizedBox(width: 8),\n                Text(\n                  '${gain.xpMultiplier}x',\n                  style: const TextStyle(\n                    color: Colors.white,\n                    fontWeight: FontWeight.w900,\n                  ),\n                ),\n              ],\n            ],\n          ),\n        ),\n      ),\n    );\n  }\n}\n"

#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess
import sys

MAIN = Path("lib/main.dart")
XP = Path("lib/xp_progression.dart")
DAILY = Path("lib/daily_challenge.dart")
FEEDBACK = Path("lib/question_feedback.dart")
PUBSPEC = Path("pubspec.yaml")
BOOST_TARGET = Path("lib/gameplay_boost.dart")

REQUIRED = [
    MAIN,
    XP,
    DAILY,
    FEEDBACK,
    PUBSPEC,
]

for path in REQUIRED:
    if not path.exists():
        raise SystemExit(
            f"Gerekli dosya bulunamadı: {path}\n"
            "Kurulum dosyasını BilgiRotasi deposunun "
            "ana klasöründe çalıştır."
        )

branch = subprocess.check_output(
    ["git", "branch", "--show-current"],
    text=True,
).strip()

if branch != "main":
    raise SystemExit(
        "Bu paket yalnızca main dalına kurulur.\n"
        f"Şu anki dal: {branch or '(belirsiz)'}\n"
        "Önce: git switch main"
    )

main = MAIN.read_text(encoding="utf-8")
xp = XP.read_text(encoding="utf-8")
daily = DAILY.read_text(encoding="utf-8")
feedback = FEEDBACK.read_text(encoding="utf-8")
pubspec = PUBSPEC.read_text(encoding="utf-8")

if "part 'gameplay_boost.dart';" in main:
    raise SystemExit(
        "Canlı Oyun + Joker + Risk sistemi "
        "zaten kurulmuş görünüyor."
    )

for marker in [
    "part 'xp_progression.dart';",
    "class CareerStatsService",
    "class QuestionScreen",
    "class PlayerData",
    "class GameScreen",
    "class MarathonScreen",
    "const XpHomeCard(),",
    "Bilgi Rotası • Sürüm 1.21",
]:
    if marker not in main:
        raise SystemExit(
            f"main.dart beklenen sürümde değil: {marker}"
        )

for marker in [
    "class XpProgressService",
    "static Future<void> recordAnswer({",
    "static Future<void> recordGameCompleted",
    "static Future<void> recordMarathon",
    "static Future<void> recordDailyChallenge",
]:
    if marker not in xp:
        raise SystemExit(
            f"xp_progression.dart beklenen sürümde değil: {marker}"
        )

for marker in [
    "class DailyAnswerRecord",
    "class DailyChallengeScreen",
    "Future<void> _openQuestion()",
    "XpProgressService.recordDailyChallenge",
]:
    if marker not in daily:
        raise SystemExit(
            f"daily_challenge.dart beklenen sürümde değil: {marker}"
        )

backups = {
    MAIN: main,
    XP: xp,
    DAILY: daily,
    FEEDBACK: feedback,
    PUBSPEC: pubspec,
}

def restore():
    for path, content in backups.items():
        path.write_text(content, encoding="utf-8")

    if BOOST_TARGET.exists():
        BOOST_TARGET.unlink()

def replace_once(text, old, new, label):
    count = text.count(old)

    if count != 1:
        raise RuntimeError(
            f"{label}: beklenen parça {count} kez bulundu."
        )

    return text.replace(old, new, 1)

try:
    BOOST_TARGET.write_text(
        GAMEPLAY_DART,
        encoding="utf-8",
    )

    # ---------------------------------------------------------
    # main.dart: part ve başlangıç ayarları
    # ---------------------------------------------------------
    main = replace_once(
        main,
        "part 'xp_progression.dart';",
        "part 'xp_progression.dart';\n"
        "part 'gameplay_boost.dart';",
        "gameplay_boost part satırı",
    )

    init_marker = (
        "  try {\n"
        "    await XpProgressService.initialize();\n"
        "  } catch (_) {\n"
        "    // XP sistemi açılamasa bile oyun açılmaya devam eder.\n"
        "  }\n\n"
        "  runApp(const BilgiRotasiApp());"
    )

    init_new = (
        "  try {\n"
        "    await XpProgressService.initialize();\n"
        "  } catch (_) {\n"
        "    // XP sistemi açılamasa bile oyun açılmaya devam eder.\n"
        "  }\n\n"
        "  try {\n"
        "    await GameplayBoostSettingsService.initialize();\n"
        "  } catch (_) {\n"
        "    // Oynanış ayarları açılamasa bile oyun devam eder.\n"
        "  }\n\n"
        "  runApp(const BilgiRotasiApp());"
    )

    main = replace_once(
        main,
        init_marker,
        init_new,
        "oynanış ayarları başlangıcı",
    )

    home_marker = (
        "                const XpHomeCard(),\n"
        "                const SizedBox(height: 18),"
    )

    home_new = (
        "                const XpHomeCard(),\n"
        "                const SizedBox(height: 10),\n"
        "                const GameplayBoostSettingsButton(),\n"
        "                const SizedBox(height: 18),"
    )

    main = replace_once(
        main,
        home_marker,
        home_new,
        "ana ekran ayar düğmesi",
    )

    # ---------------------------------------------------------
    # CareerStatsService sonuç döndürsün
    # ---------------------------------------------------------
    service_start = main.index(
        "class CareerStatsService"
    )
    service_end = main.index(
        "\nclass CareerAchievement",
        service_start,
    )
    service = main[service_start:service_end]

    answer_start = service.index(
        "  static Future<void> recordAnswer({"
    )
    answer_end = service.index(
        "\n  static Future<void> recordGameCompleted",
        answer_start,
    )

    answer_new = '''  static Future<XpGainResult> recordAnswer({
    required int categoryIndex,
    required bool correct,
    String difficulty = 'Orta',
    bool badgeEarned = false,
    int xpMultiplier = 1,
  }) async {
    final stats = await load();

    stats.totalQuestions++;

    if (correct) {
      stats.totalCorrect++;
    } else {
      stats.totalWrong++;
    }

    if (categoryIndex >= 0 &&
        categoryIndex < GameCategory.values.length) {
      stats.categoryAnswered[categoryIndex]++;

      if (correct) {
        stats.categoryCorrect[categoryIndex]++;
      }
    }

    if (badgeEarned) {
      stats.totalBadges++;
    }

    await _save(stats);

    return XpProgressService.recordAnswer(
      correct: correct,
      difficulty: difficulty,
      badgeEarned: badgeEarned,
      xpMultiplier: xpMultiplier,
    );
  }
'''

    service = (
        service[:answer_start]
        + answer_new
        + service[answer_end:]
    )

    game_start = service.index(
        "  static Future<void> recordGameCompleted"
    )
    game_end = service.index(
        "\n  static Future<void> recordMarathon",
        game_start,
    )

    game_block = service[game_start:game_end]
    game_block = game_block.replace(
        "static Future<void>",
        "static Future<XpGainResult>",
        1,
    )
    game_block = replace_once(
        game_block,
        "    await _save(stats);\n"
        "    await XpProgressService.recordGameCompleted(solo: solo);",
        "    await _save(stats);\n"
        "    return XpProgressService.recordGameCompleted(\n"
        "      solo: solo,\n"
        "    );",
        "oyun tamamlama XP sonucu",
    )

    service = (
        service[:game_start]
        + game_block
        + service[game_end:]
    )

    marathon_start = service.index(
        "  static Future<void> recordMarathon"
    )
    marathon_end = service.index(
        "\n  static Future<void> clear()",
        marathon_start,
    )

    marathon_block = service[
        marathon_start:marathon_end
    ]
    marathon_block = marathon_block.replace(
        "static Future<void>",
        "static Future<XpGainResult>",
        1,
    )
    marathon_block = replace_once(
        marathon_block,
        "    await _save(stats);\n"
        "    await XpProgressService.recordMarathon(\n",
        "    await _save(stats);\n"
        "    return XpProgressService.recordMarathon(\n",
        "maraton XP sonucu",
    )

    service = (
        service[:marathon_start]
        + marathon_block
        + service[marathon_end:]
    )

    main = (
        main[:service_start]
        + service
        + main[service_end:]
    )

    # ---------------------------------------------------------
    # GameSaveService ve PlayerData joker kaydı
    # ---------------------------------------------------------
    main = replace_once(
        main,
        "      'doubleChance': player.doubleChance,\n"
        "      'badges': player.badges.toList()..sort(),",
        "      'doubleChance': player.doubleChance,\n"
        "      'jokers': player.jokers.toJson(),\n"
        "      'badges': player.badges.toList()..sort(),",
        "jokerlerin kayıt dosyasına eklenmesi",
    )

    player_from_marker = (
        "      pawnType: "
        "(json['pawnType'] as num?)?.toInt() ?? 0,\n"
        "    );"
    )

    main = replace_once(
        main,
        player_from_marker,
        "      pawnType: "
        "(json['pawnType'] as num?)?.toInt() ?? 0,\n"
        "      jokers: JokerWallet.fromJson(json['jokers']),\n"
        "    );",
        "jokerlerin kayıttan okunması",
    )

    player_class_old = '''class PlayerData {
  PlayerData({
    required this.name,
    required this.color,
    required this.pawnType,
  });

  final String name;
  final Color color;
  final int pawnType;
'''

    player_class_new = '''class PlayerData {
  PlayerData({
    required this.name,
    required this.color,
    required this.pawnType,
    JokerWallet? jokers,
  }) : jokers = jokers ?? JokerWallet.starter();

  final String name;
  final Color color;
  final int pawnType;
  final JokerWallet jokers;
'''

    main = replace_once(
        main,
        player_class_old,
        player_class_new,
        "PlayerData joker cüzdanı",
    )

    # ---------------------------------------------------------
    # QuestionScreen: risk göstergesi ve soru içi jokerler
    # ---------------------------------------------------------
    question_start = main.index(
        "class QuestionScreen"
    )
    player_data_start = main.index(
        "class PlayerData",
        question_start,
    )
    question = main[
        question_start:player_data_start
    ]

    constructor_old = '''class QuestionScreen extends StatefulWidget {
  const QuestionScreen({
    required this.question,
    this.isBadgeQuestion = false,
    this.isFinalQuestion = false,
    super.key,
  });

  final QuizQuestion question;
  final bool isBadgeQuestion;
  final bool isFinalQuestion;
'''

    constructor_new = '''class QuestionScreen extends StatefulWidget {
  const QuestionScreen({
    required this.question,
    this.isBadgeQuestion = false,
    this.isFinalQuestion = false,
    this.jokers,
    this.onChangeQuestion,
    this.riskMode = false,
    this.xpMultiplier = 1,
    super.key,
  });

  final QuizQuestion question;
  final bool isBadgeQuestion;
  final bool isFinalQuestion;
  final JokerWallet? jokers;
  final Future<QuizQuestion?> Function(
    QuizQuestion current,
  )? onChangeQuestion;
  final bool riskMode;
  final int xpMultiplier;
'''

    question = replace_once(
        question,
        constructor_old,
        constructor_new,
        "QuestionScreen parametreleri",
    )

    state_marker = (
        "  bool _feedbackLoading = false;\n"
    )

    state_new = (
        "  bool _feedbackLoading = false;\n"
        "  late QuizQuestion _question;\n"
        "  final Set<int> _hiddenOptions = <int>{};\n"
        "  final Set<int> _disabledOptions = <int>{};\n"
        "  bool _secondChanceArmed = false;\n"
        "  bool _secondChanceUsed = false;\n"
        "  bool _jokerBusy = false;\n"
    )

    question = replace_once(
        question,
        state_marker,
        state_new,
        "QuestionScreen joker durumu",
    )

    # Artık ekranda değişebilen soru kullanılır.
    question = question.replace(
        "widget.question",
        "_question",
    )

    init_marker = (
        "  void initState() {\n"
        "    super.initState();\n"
    )

    init_new = (
        "  void initState() {\n"
        "    super.initState();\n"
        "    _question = widget.question;\n"
    )

    question = replace_once(
        question,
        init_marker,
        init_new,
        "QuestionScreen başlangıç sorusu",
    )

    mode_marker = (
        "  String get _gameMode {\n"
        "    if (widget.isFinalQuestion) return 'Final sorusu';"
    )

    mode_new = (
        "  String get _gameMode {\n"
        "    if (widget.riskMode) return 'Riskli soru';\n"
        "    if (widget.isFinalQuestion) return 'Final sorusu';"
    )

    question = replace_once(
        question,
        mode_marker,
        mode_new,
        "riskli soru geri bildirim modu",
    )

    ui_marker = (
        "                const SizedBox(height: 16),\n"
        "                Expanded(\n"
    )

    ui_new = (
        "                const LiveStreakPill(),\n"
        "                if (widget.riskMode) ...[\n"
        "                  const SizedBox(height: 10),\n"
        "                  RiskQuestionBanner(\n"
        "                    multiplier: widget.xpMultiplier,\n"
        "                  ),\n"
        "                ],\n"
        "                if (!_answered &&\n"
        "                    !widget.isFinalQuestion &&\n"
        "                    GameplayBoostSettingsService\n"
        "                        .current.jokersEnabled &&\n"
        "                    widget.jokers != null) ...[\n"
        "                  const SizedBox(height: 10),\n"
        "                  _buildJokerPanel(category),\n"
        "                ],\n"
        "                const SizedBox(height: 16),\n"
        "                Expanded(\n"
    )

    question = replace_once(
        question,
        ui_marker,
        ui_new,
        "QuestionScreen joker paneli",
    )

    feedback_method_marker = (
        "  Widget _buildFeedbackPanel("
    )

    joker_methods = r'''  Widget _buildJokerPanel(
    GameCategory category,
  ) {
    final wallet = widget.jokers!;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: category.color.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Jokerler • Her biri oyun başına 1 adet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              JokerActionButton(
                emoji: '✂️',
                label: '50:50',
                count: wallet.fiftyFifty,
                onPressed: _jokerBusy ||
                        wallet.fiftyFifty <= 0
                    ? null
                    : _useFiftyFifty,
              ),
              const SizedBox(width: 6),
              JokerActionButton(
                emoji: '🔄',
                label: 'Değiştir',
                count: wallet.changeQuestion,
                onPressed: _jokerBusy ||
                        wallet.changeQuestion <= 0 ||
                        widget.onChangeQuestion == null
                    ? null
                    : _changeQuestion,
              ),
              const SizedBox(width: 6),
              JokerActionButton(
                emoji: '🍀',
                label: '2. Şans',
                count: wallet.secondChance,
                active: _secondChanceArmed,
                onPressed: _jokerBusy ||
                        wallet.secondChance <= 0 ||
                        _secondChanceArmed ||
                        _secondChanceUsed
                    ? null
                    : _armSecondChance,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _useFiftyFifty() {
    final wallet = widget.jokers;
    if (wallet == null ||
        !wallet.consume(JokerKind.fiftyFifty)) {
      return;
    }

    final wrongOptions = <int>[
      for (var index = 0;
          index < _question.options.length;
          index++)
        if (index != _question.answerIndex)
          index,
    ]..shuffle(Random());

    setState(() {
      _hiddenOptions.addAll(
        wrongOptions.take(2),
      );
    });

    HapticFeedback.mediumImpact();
    _showMessage('✂️ İki yanlış seçenek elendi.');
  }

  void _armSecondChance() {
    final wallet = widget.jokers;
    if (wallet == null ||
        !wallet.consume(JokerKind.secondChance)) {
      return;
    }

    setState(() {
      _secondChanceArmed = true;
    });

    HapticFeedback.mediumImpact();
    _showMessage(
      '🍀 İlk cevabın yanlış olursa bir kez daha deneyebilirsin.',
    );
  }

  Future<void> _changeQuestion() async {
    final wallet = widget.jokers;
    final callback = widget.onChangeQuestion;

    if (wallet == null ||
        callback == null ||
        wallet.changeQuestion <= 0 ||
        _jokerBusy) {
      return;
    }

    setState(() => _jokerBusy = true);

    final replacement = await callback(_question);

    if (!mounted) return;

    if (replacement == null) {
      setState(() => _jokerBusy = false);
      _showMessage(
        'Bu kategoride kullanılabilir başka soru kalmadı.',
      );
      return;
    }

    wallet.consume(JokerKind.changeQuestion);

    setState(() {
      _question = replacement;
      _selectedIndex = null;
      _difficultyVote = null;
      _errorReported = false;
      _hiddenOptions.clear();
      _disabledOptions.clear();
      _secondChanceArmed = false;
      _secondChanceUsed = false;
      _jokerBusy = false;
    });

    await _loadFeedbackState();

    if (!mounted) return;

    HapticFeedback.mediumImpact();
    _showMessage('🔄 Soru değiştirildi.');
  }

  void _selectOption(int index) {
    if (_answered ||
        _hiddenOptions.contains(index) ||
        _disabledOptions.contains(index)) {
      return;
    }

    HapticFeedback.selectionClick();

    if (_secondChanceArmed &&
        !_secondChanceUsed &&
        index != _question.answerIndex) {
      setState(() {
        _secondChanceArmed = false;
        _secondChanceUsed = true;
        _disabledOptions.add(index);
      });

      HapticFeedback.heavyImpact();
      _showMessage(
        '🍀 İlk cevap yanlış. İkinci şansını kullan!',
      );
      return;
    }

    setState(() => _selectedIndex = index);
  }

'''

    question = question.replace(
        feedback_method_marker,
        joker_methods + feedback_method_marker,
        1,
    )

    option_start_marker = (
        "  Widget _buildOption(\n"
        "    int index,\n"
        "    GameCategory category,\n"
        "  ) {\n"
    )

    option_start_new = (
        "  Widget _buildOption(\n"
        "    int index,\n"
        "    GameCategory category,\n"
        "  ) {\n"
        "    if (_hiddenOptions.contains(index)) {\n"
        "      return const SizedBox.shrink();\n"
        "    }\n\n"
        "    final isDisabled =\n"
        "        _disabledOptions.contains(index);\n"
    )

    question = replace_once(
        question,
        option_start_marker,
        option_start_new,
        "gizlenen joker seçenekleri",
    )

    tap_old = '''        onTap: _answered
            ? null
            : () {
                HapticFeedback.selectionClick();
                setState(() => _selectedIndex = index);
              },
'''

    tap_new = '''        onTap: _answered || isDisabled
            ? null
            : () => _selectOption(index),
'''

    question = replace_once(
        question,
        tap_old,
        tap_new,
        "ikinci şans seçenek seçimi",
    )

    option_text_old = (
        "                    fontWeight: FontWeight.w700,\n"
        "                  ),"
    )

    # Engellenen ilk yanlış seçeneği görsel olarak soluklaştır.
    # İlk eşleşme soru metninde olabileceği için doğrudan
    # AnimatedContainer rengiyle güvenli bir işaret ekliyoruz.
    border_old = (
        "              color: border,\n"
        "              width: isSelected ? 2 : 1.2,"
    )
    border_new = (
        "              color: isDisabled\n"
        "                  ? const Color(0xFFE2E8F0)\n"
        "                  : border,\n"
        "              width: isSelected ? 2 : 1.2,"
    )

    question = replace_once(
        question,
        border_old,
        border_new,
        "ikinci şans devre dışı seçenek görünümü",
    )

    main = (
        main[:question_start]
        + question
        + main[player_data_start:]
    )

    # ---------------------------------------------------------
    # GameScreen: risk, kategori jokeri, zar tekrar, XP kutlama
    # ---------------------------------------------------------
    game_screen_start = main.index(
        "class GameScreen"
    )
    game_screen = main[game_screen_start:]

    game_screen = replace_once(
        game_screen,
        "    final diceResult = _random.nextInt(6) + 1;\n",
        "    var diceResult = _random.nextInt(6) + 1;\n\n"
        "    final useReroll =\n"
        "        await GameplayBoostDialogs.offerReroll(\n"
        "      context,\n"
        "      currentRoll: diceResult,\n"
        "      wallet: _currentPlayer.jokers,\n"
        "    );\n\n"
        "    if (!mounted) return;\n\n"
        "    if (useReroll &&\n"
        "        _currentPlayer.jokers.consume(\n"
        "          JokerKind.reroll,\n"
        "        )) {\n"
        "      unawaited(SoundFx.dice());\n"
        "      HapticFeedback.mediumImpact();\n"
        "      await Future<void>.delayed(\n"
        "        const Duration(milliseconds: 450),\n"
        "      );\n"
        "      diceResult = _random.nextInt(6) + 1;\n"
        "    }\n",
        "zar tekrar jokeri",
    )

    category_old = '''    final categoryIndex = selectedCategory ??
        (target.categoryIndex < 0
            ? _random.nextInt(GameCategory.values.length)
            : target.categoryIndex);

    final draw = widget.questionBank.nextQuestion(
      categoryIndex: categoryIndex,
      random: _random,
      usedQuestionIds: _usedQuestionIds,
      preferredDifficulty: _preferredQuestionDifficulty,
    );
    final question = draw.question;
'''

    category_new = '''    final baseCategoryIndex = selectedCategory ??
        (target.categoryIndex < 0
            ? _random.nextInt(GameCategory.values.length)
            : target.categoryIndex);

    final plan =
        await GameplayBoostDialogs.chooseQuestionPlan(
      context,
      baseCategoryIndex: baseCategoryIndex,
      normalDifficulty: _preferredQuestionDifficulty,
      wallet: _currentPlayer.jokers,
    );

    if (!mounted) return;

    final categoryIndex = plan.categoryIndex;

    final draw = widget.questionBank.nextQuestion(
      categoryIndex: categoryIndex,
      random: _random,
      usedQuestionIds: _usedQuestionIds,
      preferredDifficulty: plan.preferredDifficulty,
    );
    final question = draw.question;
'''

    game_screen = replace_once(
        game_screen,
        category_old,
        category_new,
        "tahta risk ve kategori seçimi",
    )

    board_question_old = '''            builder: (_) => QuestionScreen(
              question: question,
              isBadgeQuestion: target.isBadge,
            ),
'''

    board_question_new = '''            builder: (_) => QuestionScreen(
              question: question,
              isBadgeQuestion: target.isBadge,
              jokers: _currentPlayer.jokers,
              riskMode: plan.risky,
              xpMultiplier: plan.xpMultiplier,
              onChangeQuestion: (current) async {
                final replacement =
                    GameplayBoostQuestionPicker.replacement(
                  questionBank: widget.questionBank,
                  current: current,
                  usedQuestionIds: _usedQuestionIds,
                );

                if (replacement != null) {
                  await _saveGame();
                }

                return replacement;
              },
            ),
'''

    game_screen = replace_once(
        game_screen,
        board_question_old,
        board_question_new,
        "tahta soru jokerleri",
    )

    handle_call_old = '''    await _handleAnswer(
      correct: correct,
      categoryIndex: categoryIndex,
      wasBadgeCell: target.isBadge,
    );
'''

    handle_call_new = '''    await _handleAnswer(
      correct: correct,
      categoryIndex: categoryIndex,
      difficulty: question.difficulty,
      xpMultiplier: plan.xpMultiplier,
      wasBadgeCell: target.isBadge,
    );
'''

    game_screen = replace_once(
        game_screen,
        handle_call_old,
        handle_call_new,
        "tahta XP çarpanı aktarımı",
    )

    handle_signature_old = '''  Future<void> _handleAnswer({
    required bool correct,
    required int categoryIndex,
    required bool wasBadgeCell,
  }) async {
'''

    handle_signature_new = '''  Future<void> _handleAnswer({
    required bool correct,
    required int categoryIndex,
    required String difficulty,
    required int xpMultiplier,
    required bool wasBadgeCell,
  }) async {
'''

    game_screen = replace_once(
        game_screen,
        handle_signature_old,
        handle_signature_new,
        "cevap işleme XP parametreleri",
    )

    correct_record_old = '''      await CareerStatsService.recordAnswer(
        categoryIndex: categoryIndex,
        correct: true,
        badgeEarned: badgeEarned,
      );
'''

    correct_record_new = '''      final xpGain =
          await CareerStatsService.recordAnswer(
        categoryIndex: categoryIndex,
        difficulty: difficulty,
        correct: true,
        badgeEarned: badgeEarned,
        xpMultiplier: xpMultiplier,
      );

      if (mounted) {
        await XpCelebration.show(context, xpGain);
      }
'''

    game_screen = replace_once(
        game_screen,
        correct_record_old,
        correct_record_new,
        "doğru cevap XP animasyonu",
    )

    wrong_record_old = '''      await CareerStatsService.recordAnswer(
        categoryIndex: categoryIndex,
        correct: false,
      );
    }

    await _saveGame();
'''

    wrong_record_new = '''      final xpGain =
          await CareerStatsService.recordAnswer(
        categoryIndex: categoryIndex,
        difficulty: difficulty,
        correct: false,
        xpMultiplier: xpMultiplier,
      );

      if (mounted) {
        await XpCelebration.show(context, xpGain);
      }
    }

    await _saveGame();
'''

    # GameScreen içinde önce normal yanlış blok değiştirilir.
    game_screen = replace_once(
        game_screen,
        wrong_record_old,
        wrong_record_new,
        "yanlış cevap seri bildirimi",
    )

    final_correct_old = '''      await CareerStatsService.recordAnswer(
        categoryIndex: categoryIndex,
        correct: true,
      );
      await CareerStatsService.recordGameCompleted(
        solo: widget.players.length == 1,
      );
'''

    final_correct_new = '''      final answerGain =
          await CareerStatsService.recordAnswer(
        categoryIndex: categoryIndex,
        difficulty: question.difficulty,
        correct: true,
      );

      if (mounted) {
        await XpCelebration.show(
          context,
          answerGain,
        );
      }

      final completionGain =
          await CareerStatsService.recordGameCompleted(
        solo: widget.players.length == 1,
      );

      if (mounted) {
        await XpCelebration.show(
          context,
          completionGain,
        );
      }
'''

    game_screen = replace_once(
        game_screen,
        final_correct_old,
        final_correct_new,
        "final doğru XP ve seviye kutlaması",
    )

    final_wrong_old = '''      await CareerStatsService.recordAnswer(
        categoryIndex: categoryIndex,
        correct: false,
      );
      _advanceTurn();
'''

    final_wrong_new = '''      final answerGain =
          await CareerStatsService.recordAnswer(
        categoryIndex: categoryIndex,
        difficulty: question.difficulty,
        correct: false,
      );

      if (mounted) {
        await XpCelebration.show(
          context,
          answerGain,
        );
      }

      _advanceTurn();
'''

    game_screen = replace_once(
        game_screen,
        final_wrong_old,
        final_wrong_new,
        "final yanlış seri bildirimi",
    )

    mini_bar_marker = '''                Text(
                  'Doğru: ${_currentPlayer.correctAnswers}   •   '
'''

    mini_bar_new = '''                JokerWalletMiniBar(
                  wallet: _currentPlayer.jokers,
                ),
                const SizedBox(height: 9),
                Text(
                  'Doğru: ${_currentPlayer.correctAnswers}   •   '
'''

    game_screen = replace_once(
        game_screen,
        mini_bar_marker,
        mini_bar_new,
        "tahta joker sayacı",
    )

    main = (
        main[:game_screen_start]
        + game_screen
    )

    # ---------------------------------------------------------
    # MarathonScreen: risk, jokerler ve canlı XP
    # ---------------------------------------------------------
    marathon_start = main.index(
        "class _MarathonScreenState"
    )
    marathon_end = main.index(
        "\nclass MarathonResultScreen",
        marathon_start,
    )
    marathon = main[marathon_start:marathon_end]

    marathon = replace_once(
        marathon,
        "  final Stopwatch _stopwatch = Stopwatch();\n",
        "  final Stopwatch _stopwatch = Stopwatch();\n"
        "  final JokerWallet _jokers = JokerWallet.starter();\n"
        "  final Set<String> _usedQuestionIds = <String>{};\n",
        "maraton joker cüzdanı",
    )

    marathon_open_old = '''    setState(() => _busy = true);

    final correct = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => QuestionScreen(
              question: _question,
            ),
          ),
        ) ??
        false;
'''

    marathon_open_new = '''    setState(() => _busy = true);

    final plan =
        await GameplayBoostDialogs.chooseQuestionPlan(
      context,
      baseCategoryIndex: _question.categoryIndex,
      normalDifficulty: _question.difficulty,
      wallet: null,
      allowCategoryChange: false,
    );

    if (!mounted) return;

    var questionForPlay = _question;

    if (plan.risky) {
      questionForPlay =
          GameplayBoostQuestionPicker.riskQuestion(
            questionBank: widget.questionBank,
            current: _question,
            preferredDifficulty:
                plan.preferredDifficulty,
            usedQuestionIds: _usedQuestionIds,
          ) ??
          _question;
    }

    _usedQuestionIds.add(questionForPlay.id);

    final correct = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => QuestionScreen(
              question: questionForPlay,
              jokers: _jokers,
              riskMode: plan.risky,
              xpMultiplier: plan.xpMultiplier,
              onChangeQuestion: (current) async {
                return GameplayBoostQuestionPicker.replacement(
                  questionBank: widget.questionBank,
                  current: current,
                  usedQuestionIds: _usedQuestionIds,
                );
              },
            ),
          ),
        ) ??
        false;
'''

    marathon = replace_once(
        marathon,
        marathon_open_old,
        marathon_open_new,
        "maraton risk ve jokerler",
    )

    marathon_record_old = '''    await CareerStatsService.recordAnswer(
      categoryIndex: _question.categoryIndex,
      difficulty: _question.difficulty,
      correct: correct,
    );
'''

    marathon_record_new = '''    final answerGain =
        await CareerStatsService.recordAnswer(
      categoryIndex: questionForPlay.categoryIndex,
      difficulty: questionForPlay.difficulty,
      correct: correct,
      xpMultiplier: plan.xpMultiplier,
    );

    if (mounted) {
      await XpCelebration.show(
        context,
        answerGain,
      );
    }
'''

    marathon = replace_once(
        marathon,
        marathon_record_old,
        marathon_record_new,
        "maraton XP animasyonu",
    )

    marathon_finish_old = '''      await CareerStatsService.recordMarathon(
        questionCount: widget.questions.length,
        correct: _correct,
        bestStreak: _maxStreak,
      );

      if (!mounted) return;
'''

    marathon_finish_new = '''      final marathonGain =
          await CareerStatsService.recordMarathon(
        questionCount: widget.questions.length,
        correct: _correct,
        bestStreak: _maxStreak,
      );

      if (!mounted) return;

      await XpCelebration.show(
        context,
        marathonGain,
      );

      if (!mounted) return;
'''

    marathon = replace_once(
        marathon,
        marathon_finish_old,
        marathon_finish_new,
        "maraton bitirme XP kutlaması",
    )

    main = (
        main[:marathon_start]
        + marathon
        + main[marathon_end:]
    )

    # ---------------------------------------------------------
    # xp_progression.dart: sonuç, seri çarpanı, risk çarpanı
    # ---------------------------------------------------------
    xp_answer_start = xp.index(
        "  static Future<void> recordAnswer({"
    )
    xp_game_start = xp.index(
        "  static Future<void> recordGameCompleted",
        xp_answer_start,
    )

    xp_answer_new = '''  static Future<XpGainResult> recordAnswer({
    required bool correct,
    required String difficulty,
    required bool badgeEarned,
    int xpMultiplier = 1,
  }) async {
    final progress = await load();
    final oldLevel = progress.level;
    final oldRank = progress.rank;
    final previousStreak = progress.currentStreak;
    final safeRiskMultiplier =
        xpMultiplier.clamp(1, 3).toInt();

    var amount = 0;
    var reason = 'Yanlış cevap • XP kaybı yok';

    if (correct) {
      progress.currentStreak++;

      final base = switch (
        difficulty.trim().toLowerCase()
      ) {
        'kolay' => 10,
        'zor' => 25,
        _ => 15,
      };

      final streakMultiplier =
          progress.currentStreak >= 10
              ? 3
              : progress.currentStreak >= 5
                  ? 2
                  : 1;

      final streakBonus =
          progress.currentStreak >= 3 ? 5 : 0;
      final badgeBonus = badgeEarned ? 40 : 0;

      amount = (
        base * streakMultiplier +
        streakBonus +
        badgeBonus
      ) * safeRiskMultiplier;

      progress.bestStreak = max(
        progress.bestStreak,
        progress.currentStreak,
      );

      final parts = <String>[
        'Doğru cevap',
        if (streakMultiplier > 1)
          '${streakMultiplier}x seri',
        if (streakBonus > 0)
          'seri bonusu',
        if (badgeEarned)
          'rozet bonusu',
        if (safeRiskMultiplier > 1)
          '${safeRiskMultiplier}x risk',
      ];

      reason = parts.join(' + ');
    } else {
      progress.currentStreak = 0;
    }

    progress.totalXp += amount;
    progress.lastGain = amount;
    progress.lastReason = reason;

    await _save(progress);

    return XpGainResult(
      amount: amount,
      oldLevel: oldLevel,
      newLevel: progress.level,
      previousStreak: previousStreak,
      currentStreak: progress.currentStreak,
      reason: reason,
      xpMultiplier: safeRiskMultiplier,
      oldRank: oldRank,
      newRank: progress.rank,
    );
  }

'''

    xp = (
        xp[:xp_answer_start]
        + xp_answer_new
        + xp[xp_game_start:]
    )

    xp = xp.replace(
        "  static Future<void> recordGameCompleted",
        "  static Future<XpGainResult> recordGameCompleted",
        1,
    )
    xp = xp.replace(
        "  static Future<void> recordMarathon",
        "  static Future<XpGainResult> recordMarathon",
        1,
    )
    xp = xp.replace(
        "  static Future<void> recordDailyChallenge",
        "  static Future<XpGainResult> recordDailyChallenge",
        1,
    )
    xp = xp.replace(
        "  static Future<void> _award(int amount, String reason) async {",
        "  static Future<XpGainResult> _award(\n"
        "    int amount,\n"
        "    String reason,\n"
        "  ) async {",
        1,
    )

    award_old = '''    final progress = await load();
    progress.totalXp += max(0, amount);
    progress.lastGain = max(0, amount);
    progress.lastReason = reason;
    await _save(progress);
  }
'''

    award_new = '''    final progress = await load();
    final oldLevel = progress.level;
    final oldRank = progress.rank;
    final safeAmount = max(0, amount);

    progress.totalXp += safeAmount;
    progress.lastGain = safeAmount;
    progress.lastReason = reason;

    await _save(progress);

    return XpGainResult(
      amount: safeAmount,
      oldLevel: oldLevel,
      newLevel: progress.level,
      previousStreak: progress.currentStreak,
      currentStreak: progress.currentStreak,
      reason: reason,
      xpMultiplier: 1,
      oldRank: oldRank,
      newRank: progress.rank,
    );
  }
'''

    xp = replace_once(
        xp,
        award_old,
        award_new,
        "tamamlama XP sonucu",
    )

    # return eklenmesi: dört metot _award sonucunu döndürür.
    xp = xp.replace(
        "    await _award(\n",
        "    return _award(\n",
        3,
    )

    # ---------------------------------------------------------
    # daily_challenge.dart: risk, joker, toplu XP kutlaması
    # ---------------------------------------------------------
    daily_record_old = '''class DailyAnswerRecord {
  const DailyAnswerRecord({
    required this.categoryIndex,
    required this.difficulty,
    required this.correct,
  });

  final int categoryIndex;
  final String difficulty;
  final bool correct;
}
'''

    daily_record_new = '''class DailyAnswerRecord {
  const DailyAnswerRecord({
    required this.categoryIndex,
    required this.difficulty,
    required this.correct,
    required this.xpMultiplier,
  });

  final int categoryIndex;
  final String difficulty;
  final bool correct;
  final int xpMultiplier;
}
'''

    daily = replace_once(
        daily,
        daily_record_old,
        daily_record_new,
        "günlük görev XP çarpanı kaydı",
    )

    daily_state_marker = (
        "  final Stopwatch _stopwatch = Stopwatch();\n"
        "  final List<DailyAnswerRecord> _answers =\n"
        "      <DailyAnswerRecord>[];\n"
    )

    daily_state_new = (
        "  final Stopwatch _stopwatch = Stopwatch();\n"
        "  final List<DailyAnswerRecord> _answers =\n"
        "      <DailyAnswerRecord>[];\n"
        "  final JokerWallet _jokers = JokerWallet.starter();\n"
        "  final Set<String> _usedQuestionIds = <String>{};\n"
    )

    daily = replace_once(
        daily,
        daily_state_marker,
        daily_state_new,
        "günlük görev joker cüzdanı",
    )

    daily_open_old = '''    setState(() => _busy = true);

    final correct = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => QuestionScreen(
              question: _question,
            ),
          ),
        ) ??
        false;
'''

    daily_open_new = '''    setState(() => _busy = true);

    final plan =
        await GameplayBoostDialogs.chooseQuestionPlan(
      context,
      baseCategoryIndex: _question.categoryIndex,
      normalDifficulty: _question.difficulty,
      wallet: null,
      allowCategoryChange: false,
    );

    if (!mounted) return;

    var questionForPlay = _question;

    if (plan.risky) {
      questionForPlay =
          GameplayBoostQuestionPicker.riskQuestion(
            questionBank: widget.questionBank,
            current: _question,
            preferredDifficulty:
                plan.preferredDifficulty,
            usedQuestionIds: _usedQuestionIds,
          ) ??
          _question;
    }

    _usedQuestionIds.add(questionForPlay.id);

    final correct = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => QuestionScreen(
              question: questionForPlay,
              jokers: _jokers,
              riskMode: plan.risky,
              xpMultiplier: plan.xpMultiplier,
              onChangeQuestion: (current) async {
                return GameplayBoostQuestionPicker.replacement(
                  questionBank: widget.questionBank,
                  current: current,
                  usedQuestionIds: _usedQuestionIds,
                );
              },
            ),
          ),
        ) ??
        false;
'''

    daily = replace_once(
        daily,
        daily_open_old,
        daily_open_new,
        "günlük görev risk ve jokerler",
    )

    daily = replace_once(
        daily,
        "        categoryIndex: _question.categoryIndex,\n"
        "        difficulty: _question.difficulty,\n"
        "        correct: correct,",
        "        categoryIndex: questionForPlay.categoryIndex,\n"
        "        difficulty: questionForPlay.difficulty,\n"
        "        correct: correct,\n"
        "        xpMultiplier: plan.xpMultiplier,",
        "günlük görev risk çarpanı",
    )

    daily_finish_old = '''    if (officialSaved) {
      for (final answer in _answers) {
        await CareerStatsService.recordAnswer(
          categoryIndex: answer.categoryIndex,
          difficulty: answer.difficulty,
          correct: answer.correct,
        );
      }
      await XpProgressService.recordDailyChallenge(
        perfect: result.isPerfect,
      );
    }

    if (!mounted) return;
'''

    daily_finish_new = '''    if (officialSaved) {
      final gains = <XpGainResult>[];

      for (final answer in _answers) {
        gains.add(
          await CareerStatsService.recordAnswer(
            categoryIndex: answer.categoryIndex,
            difficulty: answer.difficulty,
            correct: answer.correct,
            xpMultiplier: answer.xpMultiplier,
          ),
        );
      }

      gains.add(
        await XpProgressService.recordDailyChallenge(
          perfect: result.isPerfect,
        ),
      );

      if (mounted) {
        await XpCelebration.show(
          context,
          XpGainResult.combine(
            gains,
            reason: 'Günlük görev toplamı',
          ),
        );
      }
    }

    if (!mounted) return;
'''

    daily = replace_once(
        daily,
        daily_finish_old,
        daily_finish_new,
        "günlük görev toplu XP kutlaması",
    )

    # ---------------------------------------------------------
    # Sürüm ve geri bildirim sürümü
    # ---------------------------------------------------------
    version_match = re.search(
        r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$",
        pubspec,
        flags=re.MULTILINE,
    )

    if version_match is None:
        raise RuntimeError(
            "pubspec.yaml sürümü okunamadı."
        )

    major, minor, patch, build = map(
        int,
        version_match.groups(),
    )

    if (major, minor) != (1, 21):
        raise RuntimeError(
            f"Beklenen sürüm 1.21.x, bulunan: "
            f"{major}.{minor}.{patch}+{build}"
        )

    new_version = f"1.22.0+{build + 1}"

    pubspec = re.sub(
        r"^version:\s*.*$",
        f"version: {new_version}",
        pubspec,
        count=1,
        flags=re.MULTILINE,
    )

    main = replace_once(
        main,
        "Bilgi Rotası • Sürüm 1.21",
        "Bilgi Rotası • Sürüm 1.22",
        "ana ekran sürüm metni",
    )

    feedback = feedback.replace(
        "appVersion: '1.20',",
        "appVersion: '1.22',",
        1,
    )

    # ---------------------------------------------------------
    # Yaz ve doğrula
    # ---------------------------------------------------------
    MAIN.write_text(main, encoding="utf-8")
    XP.write_text(xp, encoding="utf-8")
    DAILY.write_text(daily, encoding="utf-8")
    FEEDBACK.write_text(feedback, encoding="utf-8")
    PUBSPEC.write_text(pubspec, encoding="utf-8")

    checks = {
        MAIN: [
            "part 'gameplay_boost.dart';",
            "GameplayBoostSettingsService.initialize",
            "const GameplayBoostSettingsButton()",
            "JokerWallet.fromJson",
            "final JokerWallet jokers;",
            "RiskQuestionBanner",
            "GameplayBoostDialogs.chooseQuestionPlan",
            "GameplayBoostDialogs.offerReroll",
            "XpCelebration.show",
            "Bilgi Rotası • Sürüm 1.22",
        ],
        XP: [
            "Future<XpGainResult> recordAnswer",
            "xpMultiplier = 1",
            "streakMultiplier",
            "Future<XpGainResult> recordGameCompleted",
            "Future<XpGainResult> recordDailyChallenge",
        ],
        DAILY: [
            "required this.xpMultiplier",
            "final JokerWallet _jokers",
            "riskMode: plan.risky",
            "XpGainResult.combine",
        ],
        BOOST_TARGET: [
            "class GameplayBoostSettingsService",
            "class JokerWallet",
            "class XpGainResult",
            "class XpCelebration",
            "class GameplayBoostDialogs",
        ],
        PUBSPEC: [
            f"version: {new_version}",
        ],
    }

    for path, markers in checks.items():
        content = path.read_text(encoding="utf-8")

        for marker in markers:
            if marker not in content:
                raise RuntimeError(
                    f"Kurulum doğrulaması başarısız: "
                    f"{path} / {marker}"
                )

    if "assets/questions.json" in subprocess.check_output(
        ["git", "diff", "--name-only"],
        text=True,
    ).splitlines():
        raise RuntimeError(
            "Güvenlik kontrolü: questions.json "
            "değişmiş görünüyor."
        )

    if shutil.which("dart"):
        subprocess.run(
            [
                "dart",
                "format",
                "lib/main.dart",
                "lib/xp_progression.dart",
                "lib/daily_challenge.dart",
                "lib/gameplay_boost.dart",
                "lib/question_feedback.dart",
            ],
            check=True,
        )

    subprocess.run(
        ["git", "diff", "--check"],
        check=True,
    )

    if shutil.which("flutter"):
        subprocess.run(
            [
                "flutter",
                "analyze",
                "--no-fatal-infos",
            ],
            check=True,
        )

except Exception as error:
    restore()
    print("")
    print("❌ Kurulum tamamlanamadı.")
    print(f"Sebep: {error}")
    print("✅ Değiştirilen proje dosyaları eski hâline getirildi.")
    raise SystemExit(1)

subprocess.run(
    [
        "git",
        "add",
        "lib/main.dart",
        "lib/xp_progression.dart",
        "lib/daily_challenge.dart",
        "lib/gameplay_boost.dart",
        "lib/question_feedback.dart",
        "pubspec.yaml",
    ],
    check=True,
)

if subprocess.run(
    ["git", "diff", "--cached", "--quiet"],
    check=False,
).returncode != 0:
    subprocess.run(
        [
            "git",
            "commit",
            "-m",
            "Canli oyun jokerler ve risk sistemi",
        ],
        check=True,
    )

push = subprocess.run(
    ["git", "push", "origin", "main"],
    check=False,
)

print("")
print("✅ Canlı Oyun Hissi + Jokerler + Risk sistemi kuruldu.")
print("✅ XP uçuş animasyonu eklendi.")
print("✅ 3, 5 ve 10 doğru seri kutlamaları eklendi.")
print("✅ 5 doğru seride 2x, 10 doğru seride 3x temel XP eklendi.")
print("✅ Seviye ve yeni rütbe kutlama ekranı eklendi.")
print("✅ 50:50, Soru Değiştir ve İkinci Şans jokerleri eklendi.")
print("✅ Kategori Değiştir ve Zar Tekrar jokerleri eklendi.")
print("✅ Riskli soru seçimi ve doğru cevapta 2x XP eklendi.")
print("✅ Jokerler kayıtlı oyunla birlikte kaydediliyor.")
print("✅ Ana menüye aç/kapat ayarları eklendi.")
print("✅ questions.json dosyasına dokunulmadı.")
print(f"✅ Yeni sürüm: {new_version}")

if push.returncode == 0:
    print("✅ Değişiklikler GitHub main dalına gönderildi.")
else:
    print("⚠️ Kod doğrulandı ve commit oluşturuldu; push tamamlanamadı.")
    print("Terminalde yalnızca şu komutu çalıştır: git push origin main")
