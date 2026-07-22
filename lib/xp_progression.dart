part of 'main.dart';

class XpRank {
  const XpRank(this.level, this.title, this.emoji, this.description);

  final int level;
  final String title;
  final String emoji;
  final String description;
}

const List<XpRank> xpRanks = <XpRank>[
  XpRank(1, 'Acemi Gezgin', '🧭', 'Bilgi yolculuğuna yeni başladı.'),
  XpRank(5, 'Meraklı', '🔎', 'Her kategoride yeni bilgiler arıyor.'),
  XpRank(10, 'Bilgi Avcısı', '🎯', 'Doğru cevapların peşini bırakmıyor.'),
  XpRank(20, 'Uzman', '🧠', 'Zorlu sorularda farkını gösteriyor.'),
  XpRank(35, 'Bilge', '🦉', 'Geniş bilgi birikimiyle öne çıkıyor.'),
  XpRank(50, 'Bilgi Efsanesi', '👑', 'Bilgi Rotası’nın zirvesine ulaştı.'),
];

class XpSnapshot {
  const XpSnapshot(this.level, this.currentXp, this.requiredXp);

  final int level;
  final int currentXp;
  final int requiredXp;

  double get progress => requiredXp <= 0
      ? 1
      : (currentXp / requiredXp).clamp(0.0, 1.0).toDouble();
}

class XpProgress {
  XpProgress({
    this.totalXp = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastGain = 0,
    this.lastReason = '',
  });

  int totalXp;
  int currentStreak;
  int bestStreak;
  int lastGain;
  String lastReason;

  XpSnapshot get snapshot => XpProgressService.snapshot(totalXp);
  int get level => snapshot.level;
  XpRank get rank => XpProgressService.rankFor(level);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'totalXp': totalXp,
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
        'lastGain': lastGain,
        'lastReason': lastReason,
      };

  factory XpProgress.fromJson(Map<String, dynamic> json) {
    return XpProgress(
      totalXp: max(0, (json['totalXp'] as num?)?.toInt() ?? 0),
      currentStreak:
          max(0, (json['currentStreak'] as num?)?.toInt() ?? 0),
      bestStreak: max(0, (json['bestStreak'] as num?)?.toInt() ?? 0),
      lastGain: (json['lastGain'] as num?)?.toInt() ?? 0,
      lastReason: json['lastReason']?.toString() ?? '',
    );
  }
}

class XpProgressService {
  XpProgressService._();

  static const String _key = 'bilgi_rotasi_xp_progress_v1';
  static final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static Future<void> initialize() async {
    await load();
  }

  static int requiredForLevel(int level) =>
      100 + ((max(1, level) - 1) * 30);

  static XpSnapshot snapshot(int totalXp) {
    var level = 1;
    var remaining = max(0, totalXp);
    var required = requiredForLevel(level);

    while (remaining >= required && level < 999) {
      remaining -= required;
      level++;
      required = requiredForLevel(level);
    }

    return XpSnapshot(level, remaining, required);
  }

  static XpRank rankFor(int level) {
    var result = xpRanks.first;
    for (final rank in xpRanks) {
      if (level >= rank.level) {
        result = rank;
      } else {
        break;
      }
    }
    return result;
  }

  static XpRank? nextRank(int level) {
    for (final rank in xpRanks) {
      if (rank.level > level) return rank;
    }
    return null;
  }

  static Future<XpProgress> load() async {
    try {
      final raw = await _prefs.getString(_key);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          return XpProgress.fromJson(Map<String, dynamic>.from(decoded));
        }
      }
    } catch (_) {
      // Bozuk XP kaydı oyunun açılmasını engellememeli.
    }

    final stats = await CareerStatsService.load();
    final migratedXp =
        (stats.totalCorrect * 12) +
        (stats.totalBadges * 40) +
        (stats.soloWins * 120) +
        (stats.multiplayerWins * 180) +
        (stats.marathonRuns * 50) +
        (stats.perfectMarathons * 100);

    final progress = XpProgress(
      totalXp: migratedXp,
      bestStreak: stats.bestStreak,
      lastReason:
          migratedXp > 0 ? 'Mevcut kariyerin XP sistemine aktarıldı' : '',
    );
    await _save(progress);
    return progress;
  }

  static Future<void> _save(XpProgress progress) async {
    try {
      await _prefs.setString(_key, jsonEncode(progress.toJson()));
      revision.value++;
    } catch (_) {
      // XP kayıt hatası oyunu durdurmamalı.
    }
  }

  static Future<XpGainResult> recordAnswer({
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

  static Future<XpGainResult> recordGameCompleted({required bool solo}) async {
    return _award(
      solo ? 120 : 180,
      solo ? 'Serbest Rota tamamlandı' : 'Çok oyunculu oyun kazanıldı',
    );
  }

  static Future<XpGainResult> recordMarathon({
    required int questionCount,
    required bool perfect,
  }) async {
    return _award(
      max(50, questionCount * 3) + (perfect ? 100 : 0),
      perfect ? 'Kusursuz maraton bonusu' : 'Soru Maratonu tamamlandı',
    );
  }

  static Future<XpGainResult> recordDailyChallenge({required bool perfect}) async {
    return _award(
      perfect ? 150 : 75,
      perfect ? 'Kusursuz günlük görev' : 'Günlük görev tamamlandı',
    );
  }

  static Future<XpGainResult> _award(
    int amount,
    String reason,
  ) async {
    final progress = await load();
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

  static Future<void> clear() async {
    try {
      await _prefs.remove(_key);
      revision.value++;
    } catch (_) {
      // Sıfırlama sorunu ekranı kilitlememeli.
    }
  }
}

class XpHomeCard extends StatelessWidget {
  const XpHomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _XpFutureCard(compact: true);
  }
}

class XpCareerCard extends StatelessWidget {
  const XpCareerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _XpFutureCard(compact: false);
  }
}

class _XpFutureCard extends StatelessWidget {
  const _XpFutureCard({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: XpProgressService.revision,
      builder: (context, _, __) {
        return FutureBuilder<XpProgress>(
          future: XpProgressService.load(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 116,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return XpProgressCard(
              progress: snapshot.data!,
              compact: compact,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const XpProgressScreen()),
              ),
            );
          },
        );
      },
    );
  }
}

class XpProgressCard extends StatelessWidget {
  const XpProgressCard({
    required this.progress,
    required this.compact,
    required this.onTap,
    super.key,
  });

  final XpProgress progress;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final snapshot = progress.snapshot;
    final rank = progress.rank;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Ink(
          padding: EdgeInsets.all(compact ? 17 : 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6D28D9), Color(0xFF0F766E)],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0x99FFE082)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(rank.emoji, style: const TextStyle(fontSize: 39)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SEVİYE ${snapshot.level}',
                          style: const TextStyle(
                            color: Color(0xFFFFE082),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          rank.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: snapshot.progress,
                  minHeight: 10,
                  backgroundColor: const Color(0x33FFFFFF),
                  color: const Color(0xFFFFE082),
                ),
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  Text(
                    '${snapshot.currentXp}/${snapshot.requiredXp} XP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Toplam ${progress.totalXp} XP',
                    style: const TextStyle(
                      color: Color(0xFFD8CCEA),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (!compact && progress.lastReason.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  progress.lastGain > 0
                      ? 'Son kazanç: +${progress.lastGain} XP • ${progress.lastReason}'
                      : progress.lastReason,
                  style: const TextStyle(
                    color: Color(0xFFEDE9FE),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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

class XpProgressScreen extends StatelessWidget {
  const XpProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('XP, Seviye & Rütbeler')),
      body: ValueListenableBuilder<int>(
        valueListenable: XpProgressService.revision,
        builder: (context, _, __) {
          return FutureBuilder<XpProgress>(
            future: XpProgressService.load(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final progress = snapshot.data!;
              final next = XpProgressService.nextRank(progress.level);
              return ListView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
                children: [
                  XpProgressCard(
                    progress: progress,
                    compact: false,
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  _info('🔥', 'Mevcut seri', '${progress.currentStreak} doğru',
                      'En iyi seri: ${progress.bestStreak}'),
                  if (next != null) ...[
                    const SizedBox(height: 10),
                    _info('🚀', 'Sıradaki rütbe', '${next.emoji} ${next.title}',
                        'Seviye ${next.level} olduğunda açılır.'),
                  ],
                  const SizedBox(height: 18),
                  const Text('XP nasıl kazanılır?',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 9),
                  _line('✅', 'Doğru cevap', 'Kolay +10 • Orta +15 • Zor +25 XP'),
                  _line('🔥', 'Seri bonusu', '3. doğrudan sonra artar, en fazla +20 XP'),
                  _line('🏅', 'Rozet', 'Doğru cevaba ek +40 XP'),
                  _line('🧭', 'Serbest Rota', 'Tamamlama +120 XP'),
                  _line('👑', 'Çok oyunculu zafer', 'Kazanma +180 XP'),
                  _line('⚡', 'Soru Maratonu', 'Tamamlama ve kusursuz tur bonusu'),
                  _line('📅', 'Günlük görev', '+75 XP • Kusursuz görev +150 XP'),
                  _line('❌', 'Yanlış cevap', 'XP düşürmez; doğru serisini sıfırlar'),
                  const SizedBox(height: 18),
                  const Text('Rütbe yolu',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 9),
                  for (final rank in xpRanks)
                    _rank(rank, progress.level >= rank.level),
                ],
              );
            },
          );
        },
      ),
    );
  }

  static Widget _info(String emoji, String title, String value, String detail) {
    return _box(Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 32)),
      const SizedBox(width: 11),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        Text(detail, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
      ])),
    ]));
  }

  static Widget _line(String emoji, String title, String detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _box(Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          Text(detail, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
        ])),
      ])),
    );
  }

  static Widget _rank(XpRank rank, bool unlocked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _box(Row(children: [
        Text(unlocked ? rank.emoji : '🔒', style: const TextStyle(fontSize: 27)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(rank.title, style: const TextStyle(fontWeight: FontWeight.w900)),
          Text('Seviye ${rank.level} • ${rank.description}',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
        ])),
        Icon(unlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
            color: unlocked ? const Color(0xFF16A34A) : const Color(0xFF94A3B8)),
      ])),
    );
  }

  static Widget _box(Widget child) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: child,
      );
}
