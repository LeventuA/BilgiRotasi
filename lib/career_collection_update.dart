part of 'main.dart';

enum PawnRarity {
  common('Sıradan', '⚪', Color(0xFF94A3B8)),
  rare('Nadir', '🟢', Color(0xFF22C55E)),
  epic('Destansı', '🔵', Color(0xFF3B82F6)),
  legendary('Efsanevi', '🟣', Color(0xFFA855F7)),
  mythic('Mitik', '🟠', Color(0xFFF59E0B));

  const PawnRarity(this.title, this.emoji, this.color);
  final String title;
  final String emoji;
  final Color color;
}

class PawnRarityCatalog {
  PawnRarityCatalog._();

  static const List<String> pawnNames = <String>[
    'Enerji Yolcusu',
    'Kristal Taş',
    'Merak Maskotu',
    'Klasik Piyon',
    'Bilge Yolcu',
    'Şans Küpü',
    'Kâşif Pusulası',
    'Bilgi Kitabı',
    'Fikir Ampulü',
    'Zaman Ustası',
    'Meraklı Yolcu',
    'Şampiyon Kupası',
    'Minik Galaksi Bilgesi',
    'Fidan Muhafızı',
    'Özgür Ev Cini',
    'Mağara Sinsiği',
    'Kara Kedi',
  ];

  static PawnRarity rarityFor(int index) {
    if (index >= 16) return PawnRarity.mythic;
    if (index >= 14) return PawnRarity.legendary;
    if (index >= 12) return PawnRarity.epic;
    if (index >= 7) return PawnRarity.rare;
    return PawnRarity.common;
  }
}

class PassportDayProgress {
  PassportDayProgress({
    List<Set<String>>? activeDays,
  }) : activeDays = activeDays ??
            List<Set<String>>.generate(
              GameCategory.values.length,
              (_) => <String>{},
            );

  final List<Set<String>> activeDays;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'activeDays': activeDays
            .map((days) => days.toList()..sort())
            .toList(),
      };

  factory PassportDayProgress.fromJson(Map<String, dynamic> json) {
    final raw = json['activeDays'];
    final values = List<Set<String>>.generate(
      GameCategory.values.length,
      (_) => <String>{},
    );
    if (raw is List) {
      for (var i = 0; i < raw.length && i < values.length; i++) {
        final item = raw[i];
        if (item is List) {
          values[i].addAll(item.map((value) => value.toString()));
        }
      }
    }
    return PassportDayProgress(activeDays: values);
  }
}

class PassportProgressService {
  PassportProgressService._();

  static const String _key = 'bilgi_rotasi_passport_days_v1';
  static final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static String _dayKey(DateTime now) =>
      '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';

  static Future<PassportDayProgress> load() async {
    try {
      final raw = await _prefs.getString(_key);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          return PassportDayProgress.fromJson(
            Map<String, dynamic>.from(decoded),
          );
        }
      }
    } catch (_) {}
    return PassportDayProgress();
  }

  static Future<void> recordAnswer({
    required int categoryIndex,
  }) async {
    if (categoryIndex < 0 ||
        categoryIndex >= GameCategory.values.length) {
      return;
    }
    final progress = await load();
    progress.activeDays[categoryIndex].add(_dayKey(DateTime.now()));
    await _prefs.setString(_key, jsonEncode(progress.toJson()));
    revision.value++;
  }

  static Future<void> clear() async {
    await _prefs.remove(_key);
    revision.value++;
  }
}

class PassportRequirement {
  const PassportRequirement(
    this.name,
    this.correct,
    this.accuracy,
    this.activeDays,
  );

  final String name;
  final int correct;
  final int accuracy;
  final int activeDays;
}

const List<PassportRequirement> passportRequirements =
    <PassportRequirement>[
  PassportRequirement('Bronz', 100, 65, 5),
  PassportRequirement('Gümüş', 300, 70, 12),
  PassportRequirement('Altın', 700, 75, 25),
  PassportRequirement('Elmas', 1500, 78, 40),
  PassportRequirement('Usta Mührü', 3000, 80, 50),
];

class PassportRules {
  PassportRules._();

  static int tierFor({
    required int correct,
    required int accuracy,
    required int activeDays,
  }) {
    var tier = 0;
    for (var i = 0; i < passportRequirements.length; i++) {
      final requirement = passportRequirements[i];
      if (correct >= requirement.correct &&
          accuracy >= requirement.accuracy &&
          activeDays >= requirement.activeDays) {
        tier = i + 1;
      }
    }
    return tier;
  }

  static bool grandPassportUnlocked(
    CareerStats stats,
    PassportDayProgress days,
  ) {
    for (var i = 0; i < GameCategory.values.length; i++) {
      if (tierFor(
            correct: stats.categoryCorrect[i],
            accuracy: stats.categoryAccuracy(i),
            activeDays: days.activeDays[i].length,
          ) <
          passportRequirements.length) {
        return false;
      }
    }
    return true;
  }
}

class BilgiPassportScreen extends StatelessWidget {
  const BilgiPassportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bilgi Rotası Pasaportu')),
      body: ValueListenableBuilder<int>(
        valueListenable: PassportProgressService.revision,
        builder: (context, _, __) {
          return FutureBuilder<List<Object>>(
            future: Future.wait<Object>([
              CareerStatsService.load(),
              PassportProgressService.load(),
            ]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final stats = snapshot.data![0] as CareerStats;
              final days = snapshot.data![1] as PassportDayProgress;
              final grand = PassportRules.grandPassportUnlocked(stats, days);

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF312E81), Color(0xFF7C3AED)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Text(grand ? '👑' : '🛂',
                            style: const TextStyle(fontSize: 52)),
                        const SizedBox(height: 8),
                        Text(
                          grand
                              ? 'Büyük Bilgelik Pasaportu Açıldı!'
                              : 'Altı kategoride Usta Mührü kazan',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          grand
                              ? 'Bilgelik Tacı, Büyük Bilge unvanı ve ömür boyu özel rozet senin.'
                              : 'Her kategoride 3.000 doğru, en az %80 doğruluk ve 50 farklı aktif gün gerekir.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFFE9D5FF)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  for (var i = 0; i < GameCategory.values.length; i++)
                    _PassportCategoryCard(
                      categoryIndex: i,
                      stats: stats,
                      days: days,
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _PassportCategoryCard extends StatelessWidget {
  const _PassportCategoryCard({
    required this.categoryIndex,
    required this.stats,
    required this.days,
  });

  final int categoryIndex;
  final CareerStats stats;
  final PassportDayProgress days;

  @override
  Widget build(BuildContext context) {
    final category = GameCategory.values[categoryIndex];
    final correct = stats.categoryCorrect[categoryIndex];
    final accuracy = stats.categoryAccuracy(categoryIndex);
    final activeDays = days.activeDays[categoryIndex].length;
    final tier = PassportRules.tierFor(
      correct: correct,
      accuracy: accuracy,
      activeDays: activeDays,
    );
    final next = tier < passportRequirements.length
        ? passportRequirements[tier]
        : passportRequirements.last;
    final progress = tier >= passportRequirements.length
        ? 1.0
        : [
            correct / next.correct,
            accuracy / next.accuracy,
            activeDays / next.activeDays,
          ].reduce(min).clamp(0.0, 1.0).toDouble();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(category.emoji, style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    category.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  tier == 0
                      ? 'Mühür yok'
                      : passportRequirements[tier - 1].name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 9),
            Text(
              '$correct doğru • %$accuracy doğruluk • $activeDays aktif gün',
            ),
            const SizedBox(height: 4),
            Text(
              tier >= passportRequirements.length
                  ? 'Usta Mührü tamamlandı.'
                  : 'Sıradaki: ${next.name} — ${next.correct} doğru, '
                      '%${next.accuracy} doğruluk, ${next.activeDays} aktif gün',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class PawnRarityScreen extends StatelessWidget {
  const PawnRarityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Piyon Nadirlikleri')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: PawnRarityCatalog.pawnNames.length,
        itemBuilder: (context, index) {
          final rarity = PawnRarityCatalog.rarityFor(index);
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: rarity.color.withOpacity(0.18),
                child: Text(rarity.emoji),
              ),
              title: Text(
                PawnRarityCatalog.pawnNames[index],
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(rarity.title),
              trailing: Icon(Icons.auto_awesome, color: rarity.color),
            ),
          );
        },
      ),
    );
  }
}

class SpecialEventDefinition {
  const SpecialEventDefinition({
    required this.name,
    required this.emoji,
    required this.month,
    required this.day,
    required this.durationDays,
    required this.description,
  });

  final String name;
  final String emoji;
  final int month;
  final int day;
  final int durationDays;
  final String description;

  bool isActive(DateTime now) {
    final start = DateTime(now.year, month, day);
    final end = start.add(Duration(days: durationDays));
    return !now.isBefore(start) && now.isBefore(end);
  }
}

const List<SpecialEventDefinition> specialEvents =
    <SpecialEventDefinition>[
  SpecialEventDefinition(
    name: '23 Nisan Çocuk Şenliği',
    emoji: '🎈',
    month: 4,
    day: 20,
    durationDays: 7,
    description: 'Çocuklara özel neşeli görünüm ve hatıra rozeti.',
  ),
  SpecialEventDefinition(
    name: '19 Mayıs Gençlik Rotası',
    emoji: '🇹🇷',
    month: 5,
    day: 16,
    durationDays: 7,
    description: 'Gençlik ve spor temalı özel rota.',
  ),
  SpecialEventDefinition(
    name: '30 Ağustos Zafer Rotası',
    emoji: '🏅',
    month: 8,
    day: 27,
    durationDays: 7,
    description: 'Zafer teması ve özel profil rozeti.',
  ),
  SpecialEventDefinition(
    name: '29 Ekim Cumhuriyet Rotası',
    emoji: '🇹🇷',
    month: 10,
    day: 26,
    durationDays: 8,
    description: 'Cumhuriyet teması ve kalıcı hatıra rozeti.',
  ),
  SpecialEventDefinition(
    name: 'Cadılar Bayramı',
    emoji: '🎃',
    month: 10,
    day: 30,
    durationDays: 4,
    description: 'Karanlık tahta görünümü ve gizemli piyon vitrini.',
  ),
  SpecialEventDefinition(
    name: 'Yılbaşı Bilgi Şenliği',
    emoji: '🎄',
    month: 12,
    day: 24,
    durationDays: 14,
    description: 'Kış görünümü ve yıl sonu başarı özeti.',
  ),
];

class SpecialEventsScreen extends StatelessWidget {
  const SpecialEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: const Text('Özel Etkinlikler')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final event in specialEvents)
            Card(
              child: ListTile(
                leading: Text(event.emoji,
                    style: const TextStyle(fontSize: 32)),
                title: Text(
                  event.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(event.description),
                trailing: event.isActive(now)
                    ? const Chip(label: Text('AKTİF'))
                    : const Icon(Icons.lock_clock_rounded),
              ),
            ),
        ],
      ),
    );
  }
}
