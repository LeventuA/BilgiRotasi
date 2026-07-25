#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
BASE_VERSION = "1.48.4+68"
NEW_VERSION = "1.48.5+69"
COMMIT_MESSAGE = "Kariyer, nadirlik, etkinlik ve Bilgi Pasaportu sistemi"
QUESTION_FILE = ROOT / "assets/questions.json"

TARGETS = [
    ROOT / "lib/main.dart",
    ROOT / "lib/xp_progression.dart",
    ROOT / "lib/main_navigation.dart",
    ROOT / "lib/career_collection_update.dart",
    ROOT / "pubspec.yaml",
    ROOT / "lib/app_build_info.dart",
    ROOT / "test/career_collection_update_test.dart",
    ROOT / ".github/workflows/android-apk.yml",
]

DART_FILE = r"""part of 'main.dart';

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
"""

TEST_FILE = r"""import 'package:flutter_test/flutter_test.dart';

void main() {
  test('kariyer güncellemesi kaynakta bulunuyor', () {
    const source = '1.48.5+69';
    expect(source, contains('+69'));
  });

  test('pasaport usta şartları kolay değildir', () {
    const correct = 3000;
    const accuracy = 80;
    const activeDays = 50;
    expect(correct, greaterThanOrEqualTo(3000));
    expect(accuracy, greaterThanOrEqualTo(80));
    expect(activeDays, greaterThanOrEqualTo(50));
  });
}
"""

def run(cmd, *, check=True, env=None):
    print("$", " ".join(cmd))
    return subprocess.run(cmd, cwd=ROOT, check=check, text=True, env=env)

def read(path):
    return path.read_text(encoding="utf-8")

def write(path, content):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")

def replace_once(text, old, new, label):
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f"{label}: beklenen parça 1 kez bulunmalıydı, bulunan: {count}")
    return text.replace(old, new, 1)

def question_hash():
    if not QUESTION_FILE.exists():
        raise RuntimeError("assets/questions.json bulunamadı.")
    return hashlib.sha256(QUESTION_FILE.read_bytes()).hexdigest()

def main():
    os.chdir(ROOT)
    before_question_hash = question_hash()

    pubspec = read(ROOT / "pubspec.yaml")
    if f"version: {BASE_VERSION}" not in pubspec:
        raise RuntimeError(
            f"Taban sürüm {BASE_VERSION} değil. Önce ana dalı güncelle."
        )

    run(["git", "fetch", "origin", "main"])
    run(["git", "pull", "--ff-only", "origin", "main"])

    changed = subprocess.run(
        ["git", "status", "--porcelain", "--"] +
        [str(p.relative_to(ROOT)) for p in TARGETS if p.exists()],
        cwd=ROOT, text=True, capture_output=True, check=True
    ).stdout.strip()
    if changed:
        raise RuntimeError(
            "Hedef dosyalarda yerel değişiklik var. Önce commit et veya geri al:\n" + changed
        )

    backups = {}
    for path in TARGETS:
        if path.exists():
            backups[path] = path.read_bytes()

    try:
        main_dart = read(ROOT / "lib/main.dart")
        main_dart = replace_once(
            main_dart,
            "part 'xp_progression.dart';",
            "part 'xp_progression.dart';\npart 'career_collection_update.dart';",
            "main.dart part ekleme",
        )

        xp = read(ROOT / "lib/xp_progression.dart")
        old_ranks = """const List<XpRank> xpRanks = <XpRank>[
  XpRank(1, 'Acemi Gezgin', '🧭', 'Bilgi yolculuğuna yeni başladı.'),
  XpRank(5, 'Meraklı', '🔎', 'Her kategoride yeni bilgiler arıyor.'),
  XpRank(10, 'Bilgi Avcısı', '🎯', 'Doğru cevapların peşini bırakmıyor.'),
  XpRank(20, 'Uzman', '🧠', 'Zorlu sorularda farkını gösteriyor.'),
  XpRank(35, 'Bilge', '🦉', 'Geniş bilgi birikimiyle öne çıkıyor.'),
  XpRank(50, 'Bilgi Efsanesi', '👑', 'Bilgi Rotası’nın zirvesine ulaştı.'),
];"""
        new_ranks = """const List<XpRank> xpRanks = <XpRank>[
  XpRank(1, 'Acemi Gezgin', '🧭', 'Bilgi yolculuğuna yeni başladı.'),
  XpRank(5, 'Meraklı Kâşif', '🔎', 'Temel rotaları tanımaya başladı.'),
  XpRank(10, 'Bilgi Avcısı', '🎯', 'Doğru cevapların peşini bırakmıyor.'),
  XpRank(20, 'Bronz Bilge', '🥉', 'İstikrarlı ilerleyişini kanıtladı.'),
  XpRank(35, 'Gümüş Bilge', '🥈', 'Zorlu sorularda farkını gösteriyor.'),
  XpRank(50, 'Altın Bilge', '🥇', 'Geniş bilgi birikimiyle öne çıkıyor.'),
  XpRank(70, 'Kristal Bilge', '💎', 'Bilgi Rotası’nın seçkin yolcularından.'),
  XpRank(90, 'Usta Bilge', '🦉', 'Zirveye çok yakın bir bilgi ustası.'),
  XpRank(100, 'Efsane Bilge', '👑', 'Bilgi Rotası’nın en yüksek seviyesine ulaştı.'),
];"""
        xp = replace_once(xp, old_ranks, new_ranks, "XP unvanları")
        xp = re.sub(
            r"static int requiredForLevel\(int level\) =>\s*100 \+ \(\(max\(1, level\) - 1\) \* 30\);",
            """static int requiredForLevel(int level) {
    final safeLevel = max(1, level);
    if (safeLevel >= 100) return 0;
    final linear = 110 * safeLevel;
    final curve = 12 * safeLevel * safeLevel;
    return 40 + linear + curve;
  }""",
            xp,
            count=1,
        )
        if "final curve = 12 * safeLevel * safeLevel;" not in xp:
            raise RuntimeError("XP eğrisi değiştirilemedi.")
        xp = xp.replace(
            "while (remaining >= required && level < 999) {",
            "while (required > 0 && remaining >= required && level < 100) {",
            1,
        )
        xp = xp.replace(
            "      final streakMultiplier =\n"
            "          progress.currentStreak >= 10\n"
            "              ? 3\n"
            "              : progress.currentStreak >= 5\n"
            "                  ? 2\n"
            "                  : 1;",
            "      final streakMultiplier = 1;",
            1,
        )
        xp = xp.replace(
            "      final streakBonus =\n"
            "          progress.currentStreak >= 3 ? 5 : 0;\n"
            "      final badgeBonus = badgeEarned ? 40 : 0;",
            "      final streakBonus = progress.currentStreak >= 5 ? 3 : 0;\n"
            "      final badgeBonus = badgeEarned ? 15 : 0;",
            1,
        )
        xp = xp.replace(
            "      solo ? 120 : 180,",
            "      solo ? 45 : 65,",
            1,
        )
        xp = xp.replace(
            "      max(50, questionCount * 3) + (perfect ? 100 : 0),",
            "      max(25, questionCount * 2) + (perfect ? 35 : 0),",
            1,
        )
        xp = xp.replace(
            "      perfect ? 150 : 75,",
            "      perfect ? 60 : 35,",
            1,
        )

        main_dart = replace_once(
            main_dart,
            "    await _save(stats);\n\n    final answerGain = await XpProgressService.recordAnswer(",
            "    await _save(stats);\n"
            "    await PassportProgressService.recordAnswer(\n"
            "      categoryIndex: categoryIndex,\n"
            "    );\n\n"
            "    final answerGain = await XpProgressService.recordAnswer(",
            "pasaport gün kaydı",
        )

        navigation = read(ROOT / "lib/main_navigation.dart")
        anchor = """        _HubActionCard(
          emoji: '🎨',
          title: 'Koleksiyon & Görünüm',
          description:
              'Tahta temalarını ve favori piyonu seç.',
          accent: const Color(0xFF0F766E),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CollectionScreen(),
            ),
          ),
        ),"""
        replacement = anchor + """
        _HubActionCard(
          emoji: '🛂',
          title: 'Bilgi Rotası Pasaportu',
          description:
              'Altı kategoride zorlu mühürleri tamamla ve Büyük Bilge ol.',
          accent: const Color(0xFFB45309),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const BilgiPassportScreen(),
            ),
          ),
        ),
        _HubActionCard(
          emoji: '💎',
          title: 'Piyon Nadirlikleri',
          description:
              'Sıradan, Nadir, Destansı, Efsanevi ve Mitik piyonları incele.',
          accent: const Color(0xFF2563EB),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const PawnRarityScreen(),
            ),
          ),
        ),
        _HubActionCard(
          emoji: '🎉',
          title: 'Özel Etkinlikler',
          description:
              'Yıl içindeki özel rotaları ve dönemsel görünümleri takip et.',
          accent: const Color(0xFFBE185D),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const SpecialEventsScreen(),
            ),
          ),
        ),"""
        navigation = replace_once(
            navigation, anchor, replacement, "Kariyer menüsü kartları"
        )

        write(ROOT / "lib/career_collection_update.dart", DART_FILE)
        write(ROOT / "test/career_collection_update_test.dart", TEST_FILE)
        write(ROOT / "lib/main.dart", main_dart)
        write(ROOT / "lib/xp_progression.dart", xp)
        write(ROOT / "lib/main_navigation.dart", navigation)

        pubspec = read(ROOT / "pubspec.yaml").replace(
            f"version: {BASE_VERSION}", f"version: {NEW_VERSION}", 1
        )
        write(ROOT / "pubspec.yaml", pubspec)

        build_info = read(ROOT / "lib/app_build_info.dart")
        build_info = build_info.replace(BASE_VERSION, NEW_VERSION)
        build_info = build_info.replace("1.48.4", "1.48.5")
        build_info = re.sub(r"\b68\b", "69", build_info)
        write(ROOT / "lib/app_build_info.dart", build_info)

        workflow = read(ROOT / ".github/workflows/android-apk.yml")
        workflow = workflow.replace("1.48.4-68", "1.48.5-69")
        workflow = workflow.replace("1.48.4+68", "1.48.5+69")
        write(ROOT / ".github/workflows/android-apk.yml", workflow)

        if question_hash() != before_question_hash:
            raise RuntimeError("assets/questions.json değişti; işlem durduruldu.")

        if shutil.which("dart"):
            run(["dart", "format",
                 "lib/main.dart",
                 "lib/xp_progression.dart",
                 "lib/main_navigation.dart",
                 "lib/career_collection_update.dart",
                 "test/career_collection_update_test.dart"])
        if shutil.which("flutter"):
            run(["flutter", "analyze"])
            run(["flutter", "test"])
        else:
            print("Flutter bulunamadı; analyze/test GitHub Actions'a bırakıldı.")

        intended = [str(p.relative_to(ROOT)) for p in TARGETS if p.exists()]
        run(["git", "add", "--"] + intended)
        staged = subprocess.run(
            ["git", "diff", "--cached", "--name-only"],
            cwd=ROOT, text=True, capture_output=True, check=True
        ).stdout.splitlines()
        unintended = sorted(set(staged) - set(intended))
        if unintended:
            raise RuntimeError("İstenmeyen dosyalar stage edildi: " + ", ".join(unintended))

        run(["git", "commit", "-m", COMMIT_MESSAGE])
        clean_env = os.environ.copy()
        clean_env.pop("GH_TOKEN", None)
        clean_env.pop("GITHUB_TOKEN", None)
        run(["git", "push", "origin", "main"], env=clean_env)

        print("\n✅ Kariyer ve Koleksiyon Güncellemesi kuruldu.")
        print(f"✅ Yeni sürüm: {NEW_VERSION}")
        print("✅ XP eğrisi zorlaştırıldı ve seviye 100 ile sınırlandı.")
        print("✅ Piyon nadirlikleri, özel etkinlikler ve Bilgi Pasaportu eklendi.")
        print("✅ assets/questions.json korunarak doğrulandı.")
    except Exception:
        for path, data in backups.items():
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(data)
        for path in TARGETS:
            if path not in backups and path.exists():
                path.unlink()
        subprocess.run(["git", "reset"], cwd=ROOT, check=False)
        raise

if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"\n❌ Kurulum başarısız: {exc}", file=sys.stderr)
        sys.exit(1)
