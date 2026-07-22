#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess

MAIN = Path('lib/main.dart')
DAILY = Path('lib/daily_challenge.dart')
PUBSPEC = Path('pubspec.yaml')
XP_DART = "part of 'main.dart';\n\nclass XpRank {\n  const XpRank(this.level, this.title, this.emoji, this.description);\n\n  final int level;\n  final String title;\n  final String emoji;\n  final String description;\n}\n\nconst List<XpRank> xpRanks = <XpRank>[\n  XpRank(1, 'Acemi Gezgin', '🧭', 'Bilgi yolculuğuna yeni başladı.'),\n  XpRank(5, 'Meraklı', '🔎', 'Her kategoride yeni bilgiler arıyor.'),\n  XpRank(10, 'Bilgi Avcısı', '🎯', 'Doğru cevapların peşini bırakmıyor.'),\n  XpRank(20, 'Uzman', '🧠', 'Zorlu sorularda farkını gösteriyor.'),\n  XpRank(35, 'Bilge', '🦉', 'Geniş bilgi birikimiyle öne çıkıyor.'),\n  XpRank(50, 'Bilgi Efsanesi', '👑', 'Bilgi Rotası’nın zirvesine ulaştı.'),\n];\n\nclass XpSnapshot {\n  const XpSnapshot(this.level, this.currentXp, this.requiredXp);\n\n  final int level;\n  final int currentXp;\n  final int requiredXp;\n\n  double get progress => requiredXp <= 0\n      ? 1\n      : (currentXp / requiredXp).clamp(0.0, 1.0).toDouble();\n}\n\nclass XpProgress {\n  XpProgress({\n    this.totalXp = 0,\n    this.currentStreak = 0,\n    this.bestStreak = 0,\n    this.lastGain = 0,\n    this.lastReason = '',\n  });\n\n  int totalXp;\n  int currentStreak;\n  int bestStreak;\n  int lastGain;\n  String lastReason;\n\n  XpSnapshot get snapshot => XpProgressService.snapshot(totalXp);\n  int get level => snapshot.level;\n  XpRank get rank => XpProgressService.rankFor(level);\n\n  Map<String, dynamic> toJson() => <String, dynamic>{\n        'totalXp': totalXp,\n        'currentStreak': currentStreak,\n        'bestStreak': bestStreak,\n        'lastGain': lastGain,\n        'lastReason': lastReason,\n      };\n\n  factory XpProgress.fromJson(Map<String, dynamic> json) {\n    return XpProgress(\n      totalXp: max(0, (json['totalXp'] as num?)?.toInt() ?? 0),\n      currentStreak:\n          max(0, (json['currentStreak'] as num?)?.toInt() ?? 0),\n      bestStreak: max(0, (json['bestStreak'] as num?)?.toInt() ?? 0),\n      lastGain: (json['lastGain'] as num?)?.toInt() ?? 0,\n      lastReason: json['lastReason']?.toString() ?? '',\n    );\n  }\n}\n\nclass XpProgressService {\n  XpProgressService._();\n\n  static const String _key = 'bilgi_rotasi_xp_progress_v1';\n  static final SharedPreferencesAsync _prefs = SharedPreferencesAsync();\n  static final ValueNotifier<int> revision = ValueNotifier<int>(0);\n\n  static Future<void> initialize() async {\n    await load();\n  }\n\n  static int requiredForLevel(int level) =>\n      100 + ((max(1, level) - 1) * 30);\n\n  static XpSnapshot snapshot(int totalXp) {\n    var level = 1;\n    var remaining = max(0, totalXp);\n    var required = requiredForLevel(level);\n\n    while (remaining >= required && level < 999) {\n      remaining -= required;\n      level++;\n      required = requiredForLevel(level);\n    }\n\n    return XpSnapshot(level, remaining, required);\n  }\n\n  static XpRank rankFor(int level) {\n    var result = xpRanks.first;\n    for (final rank in xpRanks) {\n      if (level >= rank.level) {\n        result = rank;\n      } else {\n        break;\n      }\n    }\n    return result;\n  }\n\n  static XpRank? nextRank(int level) {\n    for (final rank in xpRanks) {\n      if (rank.level > level) return rank;\n    }\n    return null;\n  }\n\n  static Future<XpProgress> load() async {\n    try {\n      final raw = await _prefs.getString(_key);\n      if (raw != null && raw.isNotEmpty) {\n        final decoded = jsonDecode(raw);\n        if (decoded is Map) {\n          return XpProgress.fromJson(Map<String, dynamic>.from(decoded));\n        }\n      }\n    } catch (_) {\n      // Bozuk XP kaydı oyunun açılmasını engellememeli.\n    }\n\n    final stats = await CareerStatsService.load();\n    final migratedXp =\n        (stats.totalCorrect * 12) +\n        (stats.totalBadges * 40) +\n        (stats.soloWins * 120) +\n        (stats.multiplayerWins * 180) +\n        (stats.marathonRuns * 50) +\n        (stats.perfectMarathons * 100);\n\n    final progress = XpProgress(\n      totalXp: migratedXp,\n      bestStreak: stats.bestStreak,\n      lastReason:\n          migratedXp > 0 ? 'Mevcut kariyerin XP sistemine aktarıldı' : '',\n    );\n    await _save(progress);\n    return progress;\n  }\n\n  static Future<void> _save(XpProgress progress) async {\n    try {\n      await _prefs.setString(_key, jsonEncode(progress.toJson()));\n      revision.value++;\n    } catch (_) {\n      // XP kayıt hatası oyunu durdurmamalı.\n    }\n  }\n\n  static Future<void> recordAnswer({\n    required bool correct,\n    required String difficulty,\n    required bool badgeEarned,\n  }) async {\n    final progress = await load();\n    var amount = 0;\n    var reason = 'Yanlış cevap • XP kaybı yok';\n\n    if (correct) {\n      progress.currentStreak++;\n      final base = switch (difficulty.trim().toLowerCase()) {\n        'kolay' => 10,\n        'zor' => 25,\n        _ => 15,\n      };\n      final streakBonus = progress.currentStreak >= 3\n          ? min(20, (progress.currentStreak - 2) * 3)\n          : 0;\n      amount = base + streakBonus + (badgeEarned ? 40 : 0);\n      progress.bestStreak = max(progress.bestStreak, progress.currentStreak);\n      reason = badgeEarned\n          ? 'Doğru cevap + rozet bonusu'\n          : streakBonus > 0\n              ? 'Doğru cevap + seri bonusu'\n              : 'Doğru cevap';\n    } else {\n      progress.currentStreak = 0;\n    }\n\n    progress.totalXp += amount;\n    progress.lastGain = amount;\n    progress.lastReason = reason;\n    await _save(progress);\n  }\n\n  static Future<void> recordGameCompleted({required bool solo}) async {\n    await _award(\n      solo ? 120 : 180,\n      solo ? 'Serbest Rota tamamlandı' : 'Çok oyunculu oyun kazanıldı',\n    );\n  }\n\n  static Future<void> recordMarathon({\n    required int questionCount,\n    required bool perfect,\n  }) async {\n    await _award(\n      max(50, questionCount * 3) + (perfect ? 100 : 0),\n      perfect ? 'Kusursuz maraton bonusu' : 'Soru Maratonu tamamlandı',\n    );\n  }\n\n  static Future<void> recordDailyChallenge({required bool perfect}) async {\n    await _award(\n      perfect ? 150 : 75,\n      perfect ? 'Kusursuz günlük görev' : 'Günlük görev tamamlandı',\n    );\n  }\n\n  static Future<void> _award(int amount, String reason) async {\n    final progress = await load();\n    progress.totalXp += max(0, amount);\n    progress.lastGain = max(0, amount);\n    progress.lastReason = reason;\n    await _save(progress);\n  }\n\n  static Future<void> clear() async {\n    try {\n      await _prefs.remove(_key);\n      revision.value++;\n    } catch (_) {\n      // Sıfırlama sorunu ekranı kilitlememeli.\n    }\n  }\n}\n\nclass XpHomeCard extends StatelessWidget {\n  const XpHomeCard({super.key});\n\n  @override\n  Widget build(BuildContext context) {\n    return _XpFutureCard(compact: true);\n  }\n}\n\nclass XpCareerCard extends StatelessWidget {\n  const XpCareerCard({super.key});\n\n  @override\n  Widget build(BuildContext context) {\n    return _XpFutureCard(compact: false);\n  }\n}\n\nclass _XpFutureCard extends StatelessWidget {\n  const _XpFutureCard({required this.compact});\n\n  final bool compact;\n\n  @override\n  Widget build(BuildContext context) {\n    return ValueListenableBuilder<int>(\n      valueListenable: XpProgressService.revision,\n      builder: (context, _, __) {\n        return FutureBuilder<XpProgress>(\n          future: XpProgressService.load(),\n          builder: (context, snapshot) {\n            if (!snapshot.hasData) {\n              return const SizedBox(\n                height: 116,\n                child: Center(child: CircularProgressIndicator()),\n              );\n            }\n            return XpProgressCard(\n              progress: snapshot.data!,\n              compact: compact,\n              onTap: () => Navigator.of(context).push(\n                MaterialPageRoute(builder: (_) => const XpProgressScreen()),\n              ),\n            );\n          },\n        );\n      },\n    );\n  }\n}\n\nclass XpProgressCard extends StatelessWidget {\n  const XpProgressCard({\n    required this.progress,\n    required this.compact,\n    required this.onTap,\n    super.key,\n  });\n\n  final XpProgress progress;\n  final bool compact;\n  final VoidCallback onTap;\n\n  @override\n  Widget build(BuildContext context) {\n    final snapshot = progress.snapshot;\n    final rank = progress.rank;\n\n    return Material(\n      color: Colors.transparent,\n      child: InkWell(\n        onTap: onTap,\n        borderRadius: BorderRadius.circular(25),\n        child: Ink(\n          padding: EdgeInsets.all(compact ? 17 : 20),\n          decoration: BoxDecoration(\n            gradient: const LinearGradient(\n              colors: [Color(0xFF6D28D9), Color(0xFF0F766E)],\n            ),\n            borderRadius: BorderRadius.circular(25),\n            border: Border.all(color: const Color(0x99FFE082)),\n          ),\n          child: Column(\n            crossAxisAlignment: CrossAxisAlignment.stretch,\n            children: [\n              Row(\n                children: [\n                  Text(rank.emoji, style: const TextStyle(fontSize: 39)),\n                  const SizedBox(width: 12),\n                  Expanded(\n                    child: Column(\n                      crossAxisAlignment: CrossAxisAlignment.start,\n                      children: [\n                        Text(\n                          'SEVİYE ${snapshot.level}',\n                          style: const TextStyle(\n                            color: Color(0xFFFFE082),\n                            fontSize: 12,\n                            fontWeight: FontWeight.w900,\n                          ),\n                        ),\n                        Text(\n                          rank.title,\n                          style: const TextStyle(\n                            color: Colors.white,\n                            fontSize: 21,\n                            fontWeight: FontWeight.w900,\n                          ),\n                        ),\n                      ],\n                    ),\n                  ),\n                  const Icon(Icons.chevron_right_rounded, color: Colors.white),\n                ],\n              ),\n              const SizedBox(height: 12),\n              ClipRRect(\n                borderRadius: BorderRadius.circular(999),\n                child: LinearProgressIndicator(\n                  value: snapshot.progress,\n                  minHeight: 10,\n                  backgroundColor: const Color(0x33FFFFFF),\n                  color: const Color(0xFFFFE082),\n                ),\n              ),\n              const SizedBox(height: 7),\n              Row(\n                children: [\n                  Text(\n                    '${snapshot.currentXp}/${snapshot.requiredXp} XP',\n                    style: const TextStyle(\n                      color: Colors.white,\n                      fontWeight: FontWeight.w800,\n                    ),\n                  ),\n                  const Spacer(),\n                  Text(\n                    'Toplam ${progress.totalXp} XP',\n                    style: const TextStyle(\n                      color: Color(0xFFD8CCEA),\n                      fontSize: 12,\n                    ),\n                  ),\n                ],\n              ),\n              if (!compact && progress.lastReason.isNotEmpty) ...[\n                const SizedBox(height: 10),\n                Text(\n                  progress.lastGain > 0\n                      ? 'Son kazanç: +${progress.lastGain} XP • ${progress.lastReason}'\n                      : progress.lastReason,\n                  style: const TextStyle(\n                    color: Color(0xFFEDE9FE),\n                    fontSize: 12,\n                    fontWeight: FontWeight.w700,\n                  ),\n                ),\n              ],\n            ],\n          ),\n        ),\n      ),\n    );\n  }\n}\n\nclass XpProgressScreen extends StatelessWidget {\n  const XpProgressScreen({super.key});\n\n  @override\n  Widget build(BuildContext context) {\n    return Scaffold(\n      appBar: AppBar(title: const Text('XP, Seviye & Rütbeler')),\n      body: ValueListenableBuilder<int>(\n        valueListenable: XpProgressService.revision,\n        builder: (context, _, __) {\n          return FutureBuilder<XpProgress>(\n            future: XpProgressService.load(),\n            builder: (context, snapshot) {\n              if (!snapshot.hasData) {\n                return const Center(child: CircularProgressIndicator());\n              }\n              final progress = snapshot.data!;\n              final next = XpProgressService.nextRank(progress.level);\n              return ListView(\n                padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),\n                children: [\n                  XpProgressCard(\n                    progress: progress,\n                    compact: false,\n                    onTap: () {},\n                  ),\n                  const SizedBox(height: 16),\n                  _info('🔥', 'Mevcut seri', '${progress.currentStreak} doğru',\n                      'En iyi seri: ${progress.bestStreak}'),\n                  if (next != null) ...[\n                    const SizedBox(height: 10),\n                    _info('🚀', 'Sıradaki rütbe', '${next.emoji} ${next.title}',\n                        'Seviye ${next.level} olduğunda açılır.'),\n                  ],\n                  const SizedBox(height: 18),\n                  const Text('XP nasıl kazanılır?',\n                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),\n                  const SizedBox(height: 9),\n                  _line('✅', 'Doğru cevap', 'Kolay +10 • Orta +15 • Zor +25 XP'),\n                  _line('🔥', 'Seri bonusu', '3. doğrudan sonra artar, en fazla +20 XP'),\n                  _line('🏅', 'Rozet', 'Doğru cevaba ek +40 XP'),\n                  _line('🧭', 'Serbest Rota', 'Tamamlama +120 XP'),\n                  _line('👑', 'Çok oyunculu zafer', 'Kazanma +180 XP'),\n                  _line('⚡', 'Soru Maratonu', 'Tamamlama ve kusursuz tur bonusu'),\n                  _line('📅', 'Günlük görev', '+75 XP • Kusursuz görev +150 XP'),\n                  _line('❌', 'Yanlış cevap', 'XP düşürmez; doğru serisini sıfırlar'),\n                  const SizedBox(height: 18),\n                  const Text('Rütbe yolu',\n                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),\n                  const SizedBox(height: 9),\n                  for (final rank in xpRanks)\n                    _rank(rank, progress.level >= rank.level),\n                ],\n              );\n            },\n          );\n        },\n      ),\n    );\n  }\n\n  static Widget _info(String emoji, String title, String value, String detail) {\n    return _box(Row(children: [\n      Text(emoji, style: const TextStyle(fontSize: 32)),\n      const SizedBox(width: 11),\n      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [\n        Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),\n        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),\n        Text(detail, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),\n      ])),\n    ]));\n  }\n\n  static Widget _line(String emoji, String title, String detail) {\n    return Padding(\n      padding: const EdgeInsets.only(bottom: 8),\n      child: _box(Row(children: [\n        Text(emoji, style: const TextStyle(fontSize: 26)),\n        const SizedBox(width: 10),\n        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [\n          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),\n          Text(detail, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),\n        ])),\n      ])),\n    );\n  }\n\n  static Widget _rank(XpRank rank, bool unlocked) {\n    return Padding(\n      padding: const EdgeInsets.only(bottom: 8),\n      child: _box(Row(children: [\n        Text(unlocked ? rank.emoji : '🔒', style: const TextStyle(fontSize: 27)),\n        const SizedBox(width: 10),\n        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [\n          Text(rank.title, style: const TextStyle(fontWeight: FontWeight.w900)),\n          Text('Seviye ${rank.level} • ${rank.description}',\n              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),\n        ])),\n        Icon(unlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded,\n            color: unlocked ? const Color(0xFF16A34A) : const Color(0xFF94A3B8)),\n      ])),\n    );\n  }\n\n  static Widget _box(Widget child) => Container(\n        padding: const EdgeInsets.all(15),\n        decoration: BoxDecoration(\n          color: Colors.white,\n          borderRadius: BorderRadius.circular(18),\n          border: Border.all(color: const Color(0xFFE2E8F0)),\n        ),\n        child: child,\n      );\n}\n"
XP_TARGET = Path('lib/xp_progression.dart')

for path in (MAIN, DAILY, PUBSPEC):
    if not path.exists():
        raise SystemExit(
            f'Gerekli dosya bulunamadı: {path}\n'
            'Betiği BilgiRotasi deposunun ana klasöründe çalıştır.'
        )

branch = subprocess.check_output(
    ['git', 'branch', '--show-current'], text=True
).strip()
if branch != 'main':
    raise SystemExit(
        "Bu özellik soru düzeltme branch'ine kurulmayacak.\n"
        f'Şu anki dal: {branch or "(belirsiz)"}\n'
        'Önce main dalına geç: git switch main'
    )

main = MAIN.read_text(encoding='utf-8')
daily = DAILY.read_text(encoding='utf-8')
pubspec = PUBSPEC.read_text(encoding='utf-8')

if "part 'xp_progression.dart';" in main:
    raise SystemExit('XP ve seviye sistemi zaten kurulmuş.')

for marker in (
    'class CareerStatsService',
    'static Future<void> recordAnswer({',
    'static Future<void> recordGameCompleted({',
    'static Future<void> recordMarathon({',
    'class CareerStatsScreen',
    'class HomeScreen',
    '_buildHeroHeader(),',
    '_buildSummary(stats),',
    'await CareerStatsService.clear();',
):
    if marker not in main:
        raise SystemExit(f'main.dart bölümü bulunamadı: {marker}')

for marker in (
    'class DailyAnswerRecord',
    'DailyChallengeService.saveOfficialResult',
    'CareerStatsService.recordAnswer(',
):
    if marker not in daily:
        raise SystemExit(f'daily_challenge.dart bölümü bulunamadı: {marker}')

shutil.copy2(MAIN, '/tmp/bilgi_rotasi_xp_oncesi_main.dart')
shutil.copy2(DAILY, '/tmp/bilgi_rotasi_xp_oncesi_daily.dart')
shutil.copy2(PUBSPEC, '/tmp/bilgi_rotasi_xp_oncesi_pubspec.yaml')
XP_TARGET.write_text(XP_DART, encoding='utf-8')

main = main.replace(
    "part 'question_feedback.dart';",
    "part 'question_feedback.dart';\npart 'xp_progression.dart';",
    1,
)

run_marker = '  runApp(const BilgiRotasiApp());'
if run_marker not in main:
    raise SystemExit('runApp satırı bulunamadı.')
main = main.replace(
    run_marker,
    "  try {\n"
    "    await XpProgressService.initialize();\n"
    "  } catch (_) {\n"
    "    // XP sistemi açılamasa bile oyun açılmaya devam eder.\n"
    "  }\n\n"
    + run_marker,
    1,
)

# CareerStatsService.recordAnswer
start = main.index('  static Future<void> recordAnswer({')
end = main.index('\n  static Future<void> recordGameCompleted({', start)
block = main[start:end]
old_sig = (
    '    required int categoryIndex,\n'
    '    required bool correct,\n'
    '    bool badgeEarned = false,\n'
)
new_sig = (
    '    required int categoryIndex,\n'
    '    required bool correct,\n'
    "    String difficulty = 'Orta',\n"
    '    bool badgeEarned = false,\n'
)
if old_sig not in block:
    raise SystemExit('recordAnswer parametreleri beklenenden farklı.')
block = block.replace(old_sig, new_sig, 1)
if '    await _save(stats);\n' not in block:
    raise SystemExit('recordAnswer kayıt satırı bulunamadı.')
block = block.replace(
    '    await _save(stats);\n',
    '    await _save(stats);\n'
    '    await XpProgressService.recordAnswer(\n'
    '      correct: correct,\n'
    '      difficulty: difficulty,\n'
    '      badgeEarned: badgeEarned,\n'
    '    );\n',
    1,
)
main = main[:start] + block + main[end:]

# Oyun bitirme bonusu
start = main.index('  static Future<void> recordGameCompleted({')
end = main.index('\n  static Future<void> recordMarathon({', start)
block = main[start:end]
if '    await _save(stats);\n' not in block:
    raise SystemExit('recordGameCompleted kayıt satırı bulunamadı.')
block = block.replace(
    '    await _save(stats);\n',
    '    await _save(stats);\n'
    '    await XpProgressService.recordGameCompleted(solo: solo);\n',
    1,
)
main = main[:start] + block + main[end:]

# Maraton bonusu
start = main.index('  static Future<void> recordMarathon({')
end = main.index('\n  static Future<void> clear()', start)
block = main[start:end]
if '    await _save(stats);\n' not in block:
    raise SystemExit('recordMarathon kayıt satırı bulunamadı.')
block = block.replace(
    '    await _save(stats);\n',
    '    await _save(stats);\n'
    '    await XpProgressService.recordMarathon(\n'
    '      questionCount: questionCount,\n'
    '      perfect: correct == questionCount && questionCount > 0,\n'
    '    );\n',
    1,
)
main = main[:start] + block + main[end:]

# recordAnswer çağrılarına gerçek soru zorluğunu ekle.
def matching_paren(source: str, open_index: int) -> int:
    depth = 0
    quote = None
    escaped = False
    for index in range(open_index, len(source)):
        char = source[index]
        if quote is not None:
            if escaped:
                escaped = False
            elif char == '\\':
                escaped = True
            elif char == quote:
                quote = None
            continue
        if char in ("'", '"'):
            quote = char
        elif char == '(':
            depth += 1
        elif char == ')':
            depth -= 1
            if depth == 0:
                return index
    return -1

cursor = 0
patched_calls = 0
token = 'CareerStatsService.recordAnswer('
while True:
    call_start = main.find(token, cursor)
    if call_start < 0:
        break
    open_index = call_start + len(token) - 1
    close_index = matching_paren(main, open_index)
    if close_index < 0:
        raise SystemExit('recordAnswer çağrısının kapanışı bulunamadı.')
    call = main[call_start:close_index + 1]
    if 'difficulty:' not in call:
        match = re.search(
            r'(?m)^(\s*)categoryIndex:\s*'
            r'([A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)*)'
            r'\.categoryIndex,\s*$',
            call,
        )
        if match:
            line = match.group(0)
            replacement = (
                line + '\n' + match.group(1)
                + f'difficulty: {match.group(2)}.difficulty,'
            )
            updated = call.replace(line, replacement, 1)
            main = main[:call_start] + updated + main[close_index + 1:]
            close_index += len(updated) - len(call)
            patched_calls += 1
    cursor = close_index + 1

home_marker = (
    '                _buildHeroHeader(),\n'
    '                const SizedBox(height: 18),'
)
if home_marker not in main:
    raise SystemExit('Ana ekran XP ekleme noktası bulunamadı.')
main = main.replace(
    home_marker,
    '                _buildHeroHeader(),\n'
    '                const SizedBox(height: 16),\n'
    '                const XpHomeCard(),\n'
    '                const SizedBox(height: 18),',
    1,
)

stats_marker = (
    '                  _buildHero(stats),\n'
    '                  const SizedBox(height: 16),\n'
    '                  _buildSummary(stats),'
)
if stats_marker not in main:
    raise SystemExit('İstatistik ekranı XP ekleme noktası bulunamadı.')
main = main.replace(
    stats_marker,
    '                  _buildHero(stats),\n'
    '                  const SizedBox(height: 16),\n'
    '                  const XpCareerCard(),\n'
    '                  const SizedBox(height: 16),\n'
    '                  _buildSummary(stats),',
    1,
)

reset_marker = (
    '    await CareerStatsService.clear();\n'
    '    await DailyChallengeService.clear();'
)
if reset_marker not in main:
    raise SystemExit('İstatistik sıfırlama bölümü bulunamadı.')
main = main.replace(
    reset_marker,
    reset_marker + '\n    await XpProgressService.clear();',
    1,
)
main = main.replace(
    "'Bütün toplamlar, kategori başarıları ve '\n"
    "                'açılan başarımlar silinecek. '",
    "'XP, seviye, bütün toplamlar, kategori '\n"
    "                'başarıları ve açılan başarımlar silinecek. '",
    1,
)

# Günlük görev zorluk ve tamamlama bonusu.
old_record = (
    'class DailyAnswerRecord {\n'
    '  const DailyAnswerRecord({\n'
    '    required this.categoryIndex,\n'
    '    required this.correct,\n'
    '  });\n\n'
    '  final int categoryIndex;\n'
    '  final bool correct;\n'
    '}'
)
new_record = (
    'class DailyAnswerRecord {\n'
    '  const DailyAnswerRecord({\n'
    '    required this.categoryIndex,\n'
    '    required this.difficulty,\n'
    '    required this.correct,\n'
    '  });\n\n'
    '  final int categoryIndex;\n'
    '  final String difficulty;\n'
    '  final bool correct;\n'
    '}'
)
if old_record not in daily:
    raise SystemExit('DailyAnswerRecord yapısı beklenenden farklı.')
daily = daily.replace(old_record, new_record, 1)

daily = daily.replace(
    '        categoryIndex: _question.categoryIndex,\n'
    '        correct: correct,',
    '        categoryIndex: _question.categoryIndex,\n'
    '        difficulty: _question.difficulty,\n'
    '        correct: correct,',
    1,
)
daily = daily.replace(
    '          categoryIndex: answer.categoryIndex,\n'
    '          correct: answer.correct,',
    '          categoryIndex: answer.categoryIndex,\n'
    '          difficulty: answer.difficulty,\n'
    '          correct: answer.correct,',
    1,
)
loop_marker = (
    '      for (final answer in _answers) {\n'
    '        await CareerStatsService.recordAnswer(\n'
    '          categoryIndex: answer.categoryIndex,\n'
    '          difficulty: answer.difficulty,\n'
    '          correct: answer.correct,\n'
    '        );\n'
    '      }\n'
)
if loop_marker not in daily:
    raise SystemExit('Günlük görev XP bonus noktası bulunamadı.')
daily = daily.replace(
    loop_marker,
    loop_marker
    + '      await XpProgressService.recordDailyChallenge(\n'
      '        perfect: result.isPerfect,\n'
      '      );\n',
    1,
)

# Sürüm 1.21.0
match = re.search(
    r'^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$',
    pubspec,
    flags=re.MULTILINE,
)
if not match:
    raise SystemExit('pubspec.yaml sürüm satırı okunamadı.')
major, minor, patch, build = map(int, match.groups())
if (major, minor) >= (1, 21):
    raise SystemExit('Sürüm zaten 1.21 veya üzerinde.')
new_version = f'1.21.0+{build + 1}'
pubspec = re.sub(
    r'^version:\s*.*$',
    f'version: {new_version}',
    pubspec,
    count=1,
    flags=re.MULTILINE,
)
main, count = re.subn(
    r'Bilgi Rotası • Sürüm \d+\.\d+(?:\.\d+)?',
    'Bilgi Rotası • Sürüm 1.21',
    main,
    count=1,
)
if count != 1:
    raise SystemExit('Ana menü sürüm metni güncellenemedi.')

MAIN.write_text(main, encoding='utf-8')
DAILY.write_text(daily, encoding='utf-8')
PUBSPEC.write_text(pubspec, encoding='utf-8')

for path, markers in {
    MAIN: (
        "part 'xp_progression.dart';",
        'XpProgressService.initialize',
        'XpProgressService.recordAnswer',
        'XpProgressService.recordGameCompleted',
        'XpProgressService.recordMarathon',
        'const XpHomeCard()',
        'const XpCareerCard()',
        'await XpProgressService.clear();',
        'Bilgi Rotası • Sürüm 1.21',
    ),
    DAILY: (
        'required this.difficulty',
        'difficulty: _question.difficulty',
        'difficulty: answer.difficulty',
        'XpProgressService.recordDailyChallenge',
    ),
    XP_TARGET: (
        'class XpProgressService',
        'class XpHomeCard',
        'class XpProgressScreen',
        'Bilgi Efsanesi',
    ),
}.items():
    text = path.read_text(encoding='utf-8')
    for marker in markers:
        if marker not in text:
            raise SystemExit(f'Doğrulama başarısız: {path} / {marker}')

if shutil.which('dart'):
    subprocess.run(
        ['dart', 'format', str(MAIN), str(DAILY), str(XP_TARGET)],
        check=True,
    )

subprocess.run(['git', 'diff', '--check'], check=True)

if shutil.which('flutter'):
    subprocess.run(['flutter', 'analyze', '--no-fatal-infos'], check=True)

subprocess.run(
    ['git', 'add', str(MAIN), str(DAILY), str(XP_TARGET), str(PUBSPEC)],
    check=True,
)
changed = subprocess.run(
    ['git', 'diff', '--cached', '--quiet'], check=False
).returncode != 0
if changed:
    subprocess.run(
        ['git', 'commit', '-m', 'XP seviye ve rutbe sistemi'],
        check=True,
    )
subprocess.run(['git', 'push', 'origin', 'main'], check=True)

print('')
print('✅ XP, seviye ve rütbe sistemi kuruldu.')
print("✅ Mevcut istatistikler başlangıç XP'sine çevrilecek.")
print('✅ Soru zorluğu, seri, rozet ve mod bonusları eklendi.')
print('✅ Ana ekran ve istatistiklere canlı XP kartı eklendi.')
print('✅ Yanlış cevap XP düşürmeyecek.')
print('✅ questions.json dosyasına dokunulmadı.')
print(f'✅ Zorluk bilgisi eklenen ana oyun çağrıları: {patched_calls}')
print(f'✅ Yeni sürüm: {new_version}')
print("✅ Değişiklikler GitHub'a gönderildi.")
