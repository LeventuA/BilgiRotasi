part of 'main.dart';

class SocialShareService {
  SocialShareService._();

  static Future<void> shareText(
    BuildContext context, {
    required String title,
    required String text,
  }) async {
    try {
      await Share.share(
        text,
        subject: title,
      );
    } catch (_) {
      await Clipboard.setData(
        ClipboardData(text: text),
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Paylaşım açılamadı; metin panoya kopyalandı.',
            ),
          ),
        );
    }
  }

  static int firstNumber(String value) {
    final match = RegExp(r'\d+').firstMatch(value);
    return int.tryParse(match?.group(0) ?? '') ?? 0;
  }

  static String resultText({
    required String title,
    required String score,
    required String detail,
    int? bonusXp,
  }) {
    return <String>[
      '🧭 BİLGİ ROTASI',
      title,
      '',
      '🏆 $score',
      detail,
      if (bonusXp != null) '+$bonusXp XP tamamlama bonusu',
      '',
      'Benim skorumu geçebilir misin? 🎯',
    ].join('\n');
  }

  static String standingsText({
    required String title,
    required String headline,
    required List<AdvancedStanding> standings,
  }) {
    final ordered = List<AdvancedStanding>.from(standings)
      ..sort((a, b) => b.score.compareTo(a.score));

    return <String>[
      '🧭 BİLGİ ROTASI',
      title,
      headline,
      '',
      for (var index = 0;
          index < ordered.length;
          index++)
        '${index + 1}. ${ordered[index].name} — '
            '${ordered[index].score}',
      '',
      'Aynı telefonda bilgi düellosu! 🎮',
    ].join('\n');
  }

  static String careerText(
    CareerStats stats,
    XpProgress xp,
  ) {
    return <String>[
      '🧭 BİLGİ ROTASI KARİYERİM',
      '${xp.rank.emoji} Seviye ${xp.level} • ${xp.rank.title}',
      '⭐ ${xp.totalXp} toplam XP',
      '✅ ${stats.totalCorrect} doğru cevap',
      '🎯 %${stats.accuracy} genel başarı',
      '🔥 ${max(stats.bestStreak, xp.bestStreak)} en iyi seri',
      '🏆 ${stats.completedGames} tamamlanan tur',
      '🏅 ${stats.totalBadges} kazanılan rozet',
      '',
      'Bilgi rotama yetişebilir misin?',
    ].join('\n');
  }

  static String challengeText(
    ChallengeConfig challenge,
  ) {
    return <String>[
      '🧭 BİLGİ ROTASI MEYDAN OKUMASI',
      '${challenge.challengerName} sana meydan okuyor!',
      '🎯 Hedef: ${challenge.targetScore}/'
          '${challenge.questionIds.length}',
      '${challenge.categoryLabel} • '
          '${challenge.difficulty}',
      '',
      'Kod:',
      challenge.code,
      '',
      'Bilgi Rotası uygulamasında '
          'Sosyal & Meydan Okuma bölümüne gir.',
    ].join('\n');
  }
}

class FamilyRecord {
  FamilyRecord({
    required this.name,
    this.games = 0,
    this.wins = 0,
    this.totalScore = 0,
    this.bestScore = 0,
    this.totalCorrect = 0,
    this.totalQuestions = 0,
    this.lastMode = '',
    this.lastPlayed = '',
  });

  final String name;
  int games;
  int wins;
  int totalScore;
  int bestScore;
  int totalCorrect;
  int totalQuestions;
  String lastMode;
  String lastPlayed;

  int get accuracy {
    if (totalQuestions <= 0) return 0;
    return (totalCorrect / totalQuestions * 100).round();
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'games': games,
        'wins': wins,
        'totalScore': totalScore,
        'bestScore': bestScore,
        'totalCorrect': totalCorrect,
        'totalQuestions': totalQuestions,
        'lastMode': lastMode,
        'lastPlayed': lastPlayed,
      };

  factory FamilyRecord.fromJson(
    Map<String, dynamic> json,
  ) {
    int number(String key) =>
        max(0, (json[key] as num?)?.toInt() ?? 0);

    final name = json['name']?.toString().trim() ?? '';

    return FamilyRecord(
      name: name.isEmpty ? 'Oyuncu' : name,
      games: number('games'),
      wins: number('wins'),
      totalScore: number('totalScore'),
      bestScore: number('bestScore'),
      totalCorrect: number('totalCorrect'),
      totalQuestions: number('totalQuestions'),
      lastMode: json['lastMode']?.toString() ?? '',
      lastPlayed: json['lastPlayed']?.toString() ?? '',
    );
  }
}

class FamilyRecordEntry {
  const FamilyRecordEntry({
    required this.name,
    required this.mode,
    required this.score,
    required this.total,
    required this.won,
  });

  final String name;
  final String mode;
  final int score;
  final int total;
  final bool won;
}

class FamilyRecordService {
  FamilyRecordService._();

  static const String _key =
      'bilgi_rotasi_family_records_v1';

  static final SharedPreferencesAsync _prefs =
      SharedPreferencesAsync();

  static final ValueNotifier<int> revision =
      ValueNotifier<int>(0);

  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static Future<List<FamilyRecord>> load() async {
    try {
      final raw = await _prefs.getString(_key);

      if (raw == null || raw.trim().isEmpty) {
        return <FamilyRecord>[];
      }

      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        return <FamilyRecord>[];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => FamilyRecord.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (_) {
      return <FamilyRecord>[];
    }
  }

  static Future<void> recordEntries(
    List<FamilyRecordEntry> entries,
  ) async {
    if (entries.isEmpty) return;

    final records = await load();
    final byName = <String, FamilyRecord>{
      for (final record in records)
        _normalize(record.name): record,
    };

    for (final entry in entries) {
      final cleanName = entry.name.trim().isEmpty
          ? 'Oyuncu'
          : entry.name.trim();
      final key = _normalize(cleanName);
      final record = byName.putIfAbsent(
        key,
        () => FamilyRecord(name: cleanName),
      );

      record.games++;
      if (entry.won) record.wins++;
      record.totalScore += max(0, entry.score);
      record.bestScore = max(
        record.bestScore,
        entry.score,
      );
      record.totalCorrect += max(0, entry.score);
      record.totalQuestions += max(
        entry.score,
        entry.total,
      );
      record.lastMode = entry.mode;
      record.lastPlayed =
          DateTime.now().toIso8601String();
    }

    final updated = byName.values.toList()
      ..sort((a, b) {
        final wins = b.wins.compareTo(a.wins);
        if (wins != 0) return wins;

        final score =
            b.totalScore.compareTo(a.totalScore);
        if (score != 0) return score;

        return a.name.compareTo(b.name);
      });

    try {
      await _prefs.setString(
        _key,
        jsonEncode(
          updated.map((record) => record.toJson()).toList(),
        ),
      );
      revision.value++;
    } catch (_) {
      // Aile rekoru oyunu durdurmamalı.
    }
  }

  static Future<void> clear() async {
    try {
      await _prefs.remove(_key);
      revision.value++;
    } catch (_) {
      // Rekor sıfırlama ekranı kilitlememeli.
    }
  }
}

class FamilyRecordCapture extends StatefulWidget {
  const FamilyRecordCapture({
    required this.entries,
    super.key,
  });

  final List<FamilyRecordEntry> entries;

  factory FamilyRecordCapture.single({
    required String name,
    required String mode,
    required int score,
    required int total,
    required bool won,
  }) {
    return FamilyRecordCapture(
      entries: <FamilyRecordEntry>[
        FamilyRecordEntry(
          name: name,
          mode: mode,
          score: score,
          total: total,
          won: won,
        ),
      ],
    );
  }

  factory FamilyRecordCapture.standings({
    required String mode,
    required List<AdvancedStanding> standings,
  }) {
    final best = standings.isEmpty
        ? 0
        : standings
            .map((item) => item.score)
            .reduce(max);

    return FamilyRecordCapture(
      entries: <FamilyRecordEntry>[
        for (final standing in standings)
          FamilyRecordEntry(
            name: standing.name,
            mode: mode,
            score: standing.score,
            total: max(standing.score, 1),
            won: standing.score == best,
          ),
      ],
    );
  }

  factory FamilyRecordCapture.board({
    required List<PlayerData> players,
    required PlayerData winner,
  }) {
    return FamilyRecordCapture(
      entries: <FamilyRecordEntry>[
        for (final player in players)
          FamilyRecordEntry(
            name: player.name,
            mode: players.length == 1
                ? 'Serbest Rota'
                : 'Tahta Oyunu',
            score: player.correctAnswers,
            total:
                player.correctAnswers + player.wrongAnswers,
            won: identical(player, winner),
          ),
      ],
    );
  }

  @override
  State<FamilyRecordCapture> createState() =>
      _FamilyRecordCaptureState();
}

class _FamilyRecordCaptureState
    extends State<FamilyRecordCapture> {
  @override
  void initState() {
    super.initState();

    unawaited(
      FamilyRecordService.recordEntries(
        widget.entries,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class SocialShareButton extends StatelessWidget {
  const SocialShareButton({
    required this.title,
    required this.text,
    this.dark = false,
    super.key,
  });

  final String title;
  final String text;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        SocialShareService.shareText(
          context,
          title: title,
          text: text,
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor:
            dark ? Colors.white : const Color(0xFF4338CA),
        side: BorderSide(
          color: dark
              ? const Color(0x99FFE082)
              : const Color(0xFF7C3AED),
        ),
        minimumSize: const Size.fromHeight(52),
      ),
      icon: const Icon(Icons.share_rounded),
      label: const Text(
        'Sonucu Paylaş',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}

class SocialHomeButton extends StatelessWidget {
  const SocialHomeButton({
    required this.questionBank,
    super.key,
  });

  final QuestionBank questionBank;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SocialHubScreen(
              questionBank: questionBank,
            ),
          ),
        );
      },
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFBE185D),
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      icon: const Icon(Icons.people_alt_rounded),
      label: const Text(
        'Sosyal • Rekorlar, Paylaşım & Meydan Okuma',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}

class SocialHubScreen extends StatelessWidget {
  const SocialHubScreen({
    required this.questionBank,
    super.key,
  });

  final QuestionBank questionBank;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sosyal & Meydan Okuma'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF3B0A2A),
              Color(0xFF5B2167),
              Color(0xFF0F5661),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              18,
              16,
              18,
              28,
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[
                      Color(0xFFBE185D),
                      Color(0xFF7C3AED),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0x99FFE082),
                  ),
                ),
                child: const Column(
                  children: [
                    Text(
                      '🏆👨‍👩‍👧‍👦📨',
                      style: TextStyle(fontSize: 52),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Bilgini paylaş, ailene meydan oku',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'Sonuçlarını paylaş, aynı telefondaki '
                      'aile rekorlarını gör ve başka telefona '
                      'aynı soru setini kodla gönder.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFE7E1F0),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _socialCard(
                context,
                emoji: '🎯',
                title: 'Meydan Okuma Kodu',
                text:
                    'Aynı soru listesini kodla başka telefona '
                    'gönder; hedef skor belirle.',
                colors: const <Color>[
                  Color(0xFF7C3AED),
                  Color(0xFF4338CA),
                ],
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChallengeLobbyScreen(
                        questionBank: questionBank,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _socialCard(
                context,
                emoji: '👨‍👩‍👧‍👦',
                title: 'Aile Rekorları',
                text:
                    'Aynı telefonda oynayan isimlerin maç, '
                    'galibiyet ve skor geçmişini karşılaştır.',
                colors: const <Color>[
                  Color(0xFF0F766E),
                  Color(0xFF155E75),
                ],
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const FamilyRecordsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _socialCard(
                context,
                emoji: '📊',
                title: 'Kariyerimi Paylaş',
                text:
                    'Seviye, rütbe, doğruluk, seri ve '
                    'toplam XP bilgilerini paylaş.',
                colors: const <Color>[
                  Color(0xFFB45309),
                  Color(0xFF7C2D12),
                ],
                onTap: () async {
                  final stats =
                      await CareerStatsService.load();
                  final xp =
                      await XpProgressService.load();

                  if (!context.mounted) return;

                  await SocialShareService.shareText(
                    context,
                    title: 'Bilgi Rotası Kariyerim',
                    text: SocialShareService.careerText(
                      stats,
                      xp,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0x16FFFFFF),
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(
                    color: const Color(0x33FFFFFF),
                  ),
                ),
                child: const Text(
                  'Meydan okuma kodu çevrim dışı çalışır. '
                  'Kod, soru kimliklerini taşıdığı için iki '
                  'telefonda da aynı sorular açılır.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFD8CCEA),
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialCard(
    BuildContext context, {
    required String emoji,
    required String title,
    required String text,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0x55FFFFFF),
            ),
          ),
          child: Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 44),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      text,
                      style: const TextStyle(
                        color: Color(0xFFEDE9FE),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FamilyRecordsScreen extends StatefulWidget {
  const FamilyRecordsScreen({super.key});

  @override
  State<FamilyRecordsScreen> createState() =>
      _FamilyRecordsScreenState();
}

class _FamilyRecordsScreenState
    extends State<FamilyRecordsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aile Rekorları'),
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: FamilyRecordService.revision,
        builder: (context, _, __) {
          return FutureBuilder<List<FamilyRecord>>(
            future: FamilyRecordService.load(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final records = snapshot.data!;

              if (records.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '👨‍👩‍👧‍👦',
                          style: TextStyle(fontSize: 66),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Henüz aile rekoru yok',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'Sonuç ekranına ulaştıkça oyuncu '
                          'isimleri burada otomatik birikir.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final ordered =
                  List<FamilyRecord>.from(records)
                    ..sort((a, b) {
                      final wins =
                          b.wins.compareTo(a.wins);
                      if (wins != 0) return wins;
                      return b.totalScore
                          .compareTo(a.totalScore);
                    });

              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  16,
                  18,
                  28,
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(21),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: <Color>[
                          Color(0xFF0F766E),
                          Color(0xFF6D28D9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(27),
                    ),
                    child: Text(
                      '🏆 ${ordered.first.name} önde\n'
                      '${ordered.first.wins} galibiyet • '
                      '${ordered.first.totalScore} toplam skor',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        height: 1.35,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  for (var index = 0;
                      index < ordered.length;
                      index++)
                    _recordCard(
                      ordered[index],
                      index,
                    ),
                  const SizedBox(height: 10),
                  SocialShareButton(
                    title: 'Bilgi Rotası Aile Rekorları',
                    text: <String>[
                      '🧭 BİLGİ ROTASI AİLE REKORLARI',
                      '',
                      for (var index = 0;
                          index < ordered.length;
                          index++)
                        '${index + 1}. '
                            '${ordered[index].name} — '
                            '${ordered[index].wins} galibiyet, '
                            '${ordered[index].totalScore} skor',
                    ].join('\n'),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _clear,
                    style: TextButton.styleFrom(
                      foregroundColor:
                          const Color(0xFFB91C1C),
                    ),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                    ),
                    label: const Text(
                      'Yalnızca Aile Rekorlarını Sıfırla',
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _recordCard(
    FamilyRecord record,
    int index,
  ) {
    final medal = switch (index) {
      0 => '🥇',
      1 => '🥈',
      2 => '🥉',
      _ => '${index + 1}.',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: index == 0
            ? const Color(0xFFFFF7D6)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: index == 0
              ? const Color(0xFFEAB308)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 39,
            child: Text(
              medal,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  record.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${record.games} oyun • '
                  '${record.wins} galibiyet • '
                  '%${record.accuracy} başarı',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
                if (record.lastMode.isNotEmpty)
                  Text(
                    'Son mod: ${record.lastMode}',
                    style: const TextStyle(
                      color: Color(0xFF7C3AED),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${record.totalScore}',
                style: const TextStyle(
                  color: Color(0xFF7C3AED),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                'toplam',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _clear() async {
    final accepted = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text(
                'Aile rekorları sıfırlansın mı?',
              ),
              content: const Text(
                'XP, kariyer istatistikleri ve kayıtlı '
                'oyun etkilenmeyecek.',
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext, false),
                  child: const Text('Vazgeç'),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext, true),
                  child: const Text('Sıfırla'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!accepted) return;

    await FamilyRecordService.clear();

    if (mounted) setState(() {});
  }
}

class ChallengeConfig {
  ChallengeConfig({
    required this.challengerName,
    required this.targetScore,
    required this.categoryIndex,
    required this.difficulty,
    required this.questionIds,
  });

  final String challengerName;
  final int targetScore;
  final int categoryIndex;
  final String difficulty;
  final List<String> questionIds;

  String get categoryLabel => categoryIndex < 0
      ? 'Karışık'
      : GameCategory.values[categoryIndex].label;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'v': 1,
        'n': challengerName,
        't': targetScore,
        'c': categoryIndex,
        'd': difficulty,
        'q': questionIds,
      };

  String get code {
    final bytes = utf8.encode(jsonEncode(toJson()));
    final encoded = base64UrlEncode(bytes)
        .replaceAll('=', '');

    return 'BR1-$encoded';
  }

  static ChallengeConfig decode(String raw) {
    final cleaned = raw
        .trim()
        .replaceAll(RegExp(r'\s+'), '');

    if (!cleaned.startsWith('BR1-')) {
      throw const FormatException(
        'Kod BR1- ile başlamalı.',
      );
    }

    var payload = cleaned.substring(4);

    while (payload.length % 4 != 0) {
      payload += '=';
    }

    final decoded = jsonDecode(
      utf8.decode(base64Url.decode(payload)),
    );

    if (decoded is! Map) {
      throw const FormatException('Kod okunamadı.');
    }

    final map = Map<String, dynamic>.from(decoded);
    final ids = map['q'];

    if (map['v'] != 1 ||
        ids is! List ||
        ids.isEmpty) {
      throw const FormatException(
        'Kod sürümü veya soru listesi geçersiz.',
      );
    }

    final category =
        (map['c'] as num?)?.toInt() ?? -1;

    if (category < -1 ||
        category >= GameCategory.values.length) {
      throw const FormatException(
        'Kodun kategori bilgisi geçersiz.',
      );
    }

    final questionIds = ids
        .map((value) => value.toString())
        .where((value) => value.isNotEmpty)
        .toList();

    if (questionIds.isEmpty ||
        questionIds.length > 30) {
      throw const FormatException(
        'Kodun soru sayısı geçersiz.',
      );
    }

    final difficulty =
        map['d']?.toString() ?? 'Karışık';

    return ChallengeConfig(
      challengerName:
          map['n']?.toString().trim().isNotEmpty == true
              ? map['n'].toString()
              : 'Bir oyuncu',
      targetScore: ((map['t'] as num?)
                  ?.toInt() ??
              0)
          .clamp(0, questionIds.length)
          .toInt(),
      categoryIndex: category,
      difficulty: <String>{
        'Karışık',
        'Kolay',
        'Orta',
        'Zor',
      }.contains(difficulty)
          ? difficulty
          : 'Karışık',
      questionIds: questionIds,
    );
  }
}

class ChallengeLobbyScreen extends StatefulWidget {
  const ChallengeLobbyScreen({
    required this.questionBank,
    super.key,
  });

  final QuestionBank questionBank;

  @override
  State<ChallengeLobbyScreen> createState() =>
      _ChallengeLobbyScreenState();
}

class _ChallengeLobbyScreenState
    extends State<ChallengeLobbyScreen> {
  final TextEditingController _nameController =
      TextEditingController(
    text: AppPreferencesService
        .current.defaultPlayerName,
  );

  final TextEditingController _codeController =
      TextEditingController();

  int _categoryIndex = -1;
  String _difficulty = 'Karışık';
  int _questionCount = 10;
  int _targetScore = 7;
  ChallengeConfig? _generated;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  List<QuizQuestion> get _allQuestions {
    return widget.questionBank.questionsByCategory.values
        .expand((items) => items)
        .toList(growable: false);
  }

  List<QuizQuestion> _pool() {
    Iterable<QuizQuestion> result =
        _categoryIndex < 0
            ? _allQuestions
            : widget.questionBank
                    .questionsByCategory[_categoryIndex] ??
                const <QuizQuestion>[];

    if (_difficulty != 'Karışık') {
      result = result.where(
        (question) =>
            question.difficulty
                .trim()
                .toLowerCase() ==
            _difficulty.trim().toLowerCase(),
      );
    }

    return result.toList();
  }

  @override
  Widget build(BuildContext context) {
    final poolCount = _pool().length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meydan Okuma Kodu'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            18,
            14,
            18,
            28,
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(21),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[
                    Color(0xFF7C3AED),
                    Color(0xFFBE185D),
                  ],
                ),
                borderRadius: BorderRadius.circular(27),
              ),
              child: const Column(
                children: [
                  Text(
                    '🎯📨',
                    style: TextStyle(fontSize: 54),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Aynı sorular, iki farklı telefon',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Bir soru seti oluştur ve kodu paylaş. '
                    'Kodu giren kişi tam olarak aynı soruları çözer.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFE7E1F0),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _sectionTitle('Yeni kod oluştur'),
            TextField(
              controller: _nameController,
              maxLength: 18,
              textCapitalization:
                  TextCapitalization.words,
              decoration: const InputDecoration(
                counterText: '',
                labelText: 'Meydan okuyan oyuncu',
                prefixIcon: Icon(Icons.person_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              initialValue: _categoryIndex,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: <DropdownMenuItem<int>>[
                const DropdownMenuItem<int>(
                  value: -1,
                  child: Text('🌈 Karışık'),
                ),
                for (var index = 0;
                    index < GameCategory.values.length;
                    index++)
                  DropdownMenuItem<int>(
                    value: index,
                    child: Text(
                      '${GameCategory.values[index].emoji} '
                      '${GameCategory.values[index].label}',
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _categoryIndex = value;
                  _generated = null;
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _difficulty,
              decoration: const InputDecoration(
                labelText: 'Zorluk',
                border: OutlineInputBorder(),
              ),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(
                  value: 'Karışık',
                  child: Text('Karışık zorluk'),
                ),
                DropdownMenuItem<String>(
                  value: 'Kolay',
                  child: Text('Kolay'),
                ),
                DropdownMenuItem<String>(
                  value: 'Orta',
                  child: Text('Orta'),
                ),
                DropdownMenuItem<String>(
                  value: 'Zor',
                  child: Text('Zor'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _difficulty = value;
                  _generated = null;
                });
              },
            ),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: const <ButtonSegment<int>>[
                ButtonSegment<int>(
                  value: 10,
                  label: Text('10 soru'),
                ),
                ButtonSegment<int>(
                  value: 15,
                  label: Text('15 soru'),
                ),
                ButtonSegment<int>(
                  value: 20,
                  label: Text('20 soru'),
                ),
              ],
              selected: <int>{_questionCount},
              onSelectionChanged: (selection) {
                setState(() {
                  _questionCount = selection.first;
                  _targetScore = min(
                    _targetScore,
                    _questionCount,
                  );
                  _generated = null;
                });
              },
            ),
            const SizedBox(height: 13),
            Text(
              'Hedef skor: $_targetScore / $_questionCount',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
            Slider(
              value: _targetScore.toDouble(),
              min: 1,
              max: _questionCount.toDouble(),
              divisions: _questionCount - 1,
              label: '$_targetScore',
              onChanged: (value) {
                setState(() {
                  _targetScore = value.round();
                  _generated = null;
                });
              },
            ),
            Text(
              'Bu ayarda $poolCount soru kullanılabilir.',
              style: TextStyle(
                color: poolCount >= _questionCount
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFB91C1C),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 13),
            FilledButton.icon(
              onPressed: poolCount >= _questionCount
                  ? _generate
                  : null,
              icon: const Icon(Icons.qr_code_2_rounded),
              label: const Text(
                'Meydan Okuma Kodu Oluştur',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (_generated != null) ...[
              const SizedBox(height: 14),
              _generatedCard(_generated!),
            ],
            const SizedBox(height: 24),
            _sectionTitle('Gelen kodu aç'),
            TextField(
              controller: _codeController,
              minLines: 2,
              maxLines: 5,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization:
                  TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'BR1- ile başlayan kod',
                hintText: 'Kodu buraya yapıştır',
                border: const OutlineInputBorder(),
                errorText: _error,
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _openCode,
              style: FilledButton.styleFrom(
                backgroundColor:
                    const Color(0xFFBE185D),
              ),
              icon: const Icon(
                Icons.play_arrow_rounded,
              ),
              label: const Text(
                'Kodu Aç ve Yarış',
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

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        4,
        0,
        4,
        9,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _generatedCard(
    ChallengeConfig challenge,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF7C3AED),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          Text(
            '${challenge.categoryLabel} • '
            '${challenge.difficulty} • '
            '${challenge.questionIds.length} soru',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF5B21B6),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          SelectableText(
            challenge.code,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(
                        text: challenge.code,
                      ),
                    );

                    if (!mounted) return;

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Kod kopyalandı.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.copy_rounded,
                  ),
                  label: const Text('Kopyala'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    SocialShareService.shareText(
                      context,
                      title:
                          'Bilgi Rotası Meydan Okuması',
                      text: SocialShareService
                          .challengeText(challenge),
                    );
                  },
                  icon: const Icon(
                    Icons.share_rounded,
                  ),
                  label: const Text('Paylaş'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              final questions =
                  _resolveQuestions(challenge);

              if (questions != null) {
                _startChallenge(
                  challenge,
                  questions,
                );
              }
            },
            icon: const Icon(
              Icons.play_arrow_rounded,
            ),
            label: const Text(
              'Bu Kodu Kendim Test Et',
            ),
          ),
        ],
      ),
    );
  }

  void _generate() {
    final pool = _pool()
      ..sort((a, b) => a.id.compareTo(b.id));

    final seed =
        DateTime.now().microsecondsSinceEpoch &
            0x7fffffff;

    pool.shuffle(Random(seed));

    final selected = pool
        .take(_questionCount)
        .map((question) => question.id)
        .toList(growable: false);

    final name = _nameController.text.trim();

    setState(() {
      _error = null;
      _generated = ChallengeConfig(
        challengerName:
            name.isEmpty ? 'Bir oyuncu' : name,
        targetScore: _targetScore,
        categoryIndex: _categoryIndex,
        difficulty: _difficulty,
        questionIds: selected,
      );
    });

    GameHaptics.mediumImpact();
  }

  void _openCode() {
    try {
      final challenge = ChallengeConfig.decode(
        _codeController.text,
      );
      final questions = _resolveQuestions(challenge);

      if (questions == null) return;

      setState(() => _error = null);
      _startChallenge(challenge, questions);
    } on FormatException catch (error) {
      setState(() {
        _error = error.message.toString();
      });
    } catch (_) {
      setState(() {
        _error =
            'Kod okunamadı veya eksik kopyalandı.';
      });
    }
  }

  List<QuizQuestion>? _resolveQuestions(
    ChallengeConfig challenge,
  ) {
    final byId = <String, QuizQuestion>{
      for (final question in _allQuestions)
        question.id: question,
    };

    final missing = challenge.questionIds
        .where((id) => !byId.containsKey(id))
        .toList();

    if (missing.isNotEmpty) {
      setState(() {
        _error =
            '${missing.length} soru bu sürümde bulunamadı. '
            'İki telefonda da güncel APK olmalı.';
      });
      return null;
    }

    return challenge.questionIds
        .map((id) => byId[id]!)
        .toList(growable: false);
  }

  void _startChallenge(
    ChallengeConfig challenge,
    List<QuizQuestion> questions,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChallengeGameScreen(
          questionBank: widget.questionBank,
          challenge: challenge,
          questions: questions,
        ),
      ),
    );
  }
}

class ChallengeGameScreen extends StatefulWidget {
  const ChallengeGameScreen({
    required this.questionBank,
    required this.challenge,
    required this.questions,
    super.key,
  });

  final QuestionBank questionBank;
  final ChallengeConfig challenge;
  final List<QuizQuestion> questions;

  @override
  State<ChallengeGameScreen> createState() =>
      _ChallengeGameScreenState();
}

class _ChallengeGameScreenState
    extends State<ChallengeGameScreen> {
  final JokerWallet _jokers = JokerWallet.starter();
  final Set<String> _used = <String>{};

  int _index = 0;
  int _correct = 0;
  int _wrong = 0;
  int _streak = 0;
  int _bestStreak = 0;
  bool _busy = false;
  bool _finished = false;

  QuizQuestion get _question =>
      widget.questions[_index];

  @override
  Widget build(BuildContext context) {
    final progress =
        _index / max(1, widget.questions.length);

    return PopScope<Object?>(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meydan Okuma'),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color(0xFF24122F),
                Color(0xFF6D28D9),
                Color(0xFF0F5661),
              ],
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                18,
                16,
                18,
                28,
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _scoreBox(
                        '✅',
                        '$_correct',
                        'Doğru',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _scoreBox(
                        '🎯',
                        '${widget.challenge.targetScore}',
                        'Hedef',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _scoreBox(
                        '🔥',
                        '$_streak',
                        'Seri',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor:
                      const Color(0x33FFFFFF),
                  color: const Color(0xFFFFE082),
                ),
                const SizedBox(height: 8),
                Text(
                  'Soru ${_index + 1} / '
                  '${widget.questions.length}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFD8CCEA),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(23),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '🎯',
                        style: TextStyle(fontSize: 58),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.challenge.challengerName} '
                        'hedefi: '
                        '${widget.challenge.targetScore}/'
                        '${widget.questions.length}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${widget.challenge.categoryLabel} • '
                        '${widget.challenge.difficulty}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      JokerWalletMiniBar(
                        wallet: _jokers,
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed:
                            _busy ? null : _openQuestion,
                        icon: const Icon(
                          Icons.quiz_rounded,
                        ),
                        label: Text(
                          _busy
                              ? 'Bekle…'
                              : 'Soruyu Aç',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const LiveStreakPill(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _scoreBox(
    String emoji,
    String value,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: const Color(0x16FFFFFF),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0x33FFFFFF),
        ),
      ),
      child: Column(
        children: [
          Text(emoji),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFCBC1D6),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openQuestion() async {
    if (_busy || _finished) return;

    setState(() => _busy = true);

    final question = _question;
    _used.add(question.id);

    final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => QuestionScreen(
              question: question,
              jokers: _jokers,
              onChangeQuestion: (_) async => null,
            ),
          ),
        ) ??
        false;

    if (!mounted) return;

    if (result) {
      _correct++;
      _streak++;
      _bestStreak = max(_bestStreak, _streak);
      unawaited(SoundFx.correct());
    } else {
      _wrong++;
      _streak = 0;
      unawaited(SoundFx.wrong());
    }

    final gain = await CareerStatsService.recordAnswer(
      categoryIndex: question.categoryIndex,
      difficulty: question.difficulty,
      correct: result,
    );

    if (mounted) {
      await XpCelebration.show(context, gain);
    }

    if (!mounted) return;

    if (_index + 1 >= widget.questions.length) {
      await _finish();
      return;
    }

    setState(() {
      _index++;
      _busy = false;
    });
  }

  Future<void> _finish() async {
    if (_finished) return;
    _finished = true;

    final won =
        _correct >= widget.challenge.targetScore;
    final bonusXp = won ? 150 : 70;

    final bonus = await XpProgressService._award(
      bonusXp,
      won
          ? 'Meydan okuma hedefi geçildi'
          : 'Meydan okuma tamamlandı',
    );

    await FamilyRecordService.recordEntries(
      <FamilyRecordEntry>[
        FamilyRecordEntry(
          name: AppPreferencesService
              .current.defaultPlayerName,
          mode: 'Meydan Okuma',
          score: _correct,
          total: widget.questions.length,
          won: won,
        ),
      ],
    );

    if (!mounted) return;

    await XpCelebration.show(context, bonus);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ChallengeResultScreen(
          questionBank: widget.questionBank,
          challenge: widget.challenge,
          correct: _correct,
          wrong: _wrong,
          bestStreak: _bestStreak,
          bonusXp: bonusXp,
        ),
      ),
    );
  }
}

class ChallengeResultScreen extends StatelessWidget {
  const ChallengeResultScreen({
    required this.questionBank,
    required this.challenge,
    required this.correct,
    required this.wrong,
    required this.bestStreak,
    required this.bonusXp,
    super.key,
  });

  final QuestionBank questionBank;
  final ChallengeConfig challenge;
  final int correct;
  final int wrong;
  final int bestStreak;
  final int bonusXp;

  @override
  Widget build(BuildContext context) {
    final won = correct >= challenge.targetScore;

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context)
              .popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.45),
              radius: 1.25,
              colors: <Color>[
                Color(0xFF5B2C70),
                Color(0xFF21132D),
                Color(0xFF0B3440),
              ],
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                20,
                26,
                20,
                28,
              ),
              children: [
                Text(
                  won
                      ? '🏆 HEDEF GEÇİLDİ!'
                      : '🎯 MEYDAN OKUMA BİTTİ',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFE082),
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xE61D1027),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFFFFD978),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        won ? '👑' : '🎯',
                        style: const TextStyle(
                          fontSize: 66,
                        ),
                      ),
                      Text(
                        '$correct / '
                        '${challenge.questionIds.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 43,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '${challenge.challengerName} hedefi: '
                        '${challenge.targetScore}',
                        style: const TextStyle(
                          color: Color(0xFFD8CCEA),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        '$wrong yanlış • En iyi seri '
                        '$bestStreak • +$bonusXp XP',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFFFE082),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                SocialShareButton(
                  dark: true,
                  title: 'Bilgi Rotası Meydan Okuma Sonucu',
                  text: <String>[
                    SocialShareService.resultText(
                      title: '🎯 Meydan Okuma',
                      score:
                          '$correct/${challenge.questionIds.length}',
                      detail: won
                          ? '${challenge.challengerName} '
                              'hedefini geçtim!'
                          : '${challenge.challengerName} '
                              'hedefine karşı yarıştım.',
                      bonusXp: bonusXp,
                    ),
                    '',
                    'Aynı soruları çözmek için kod:',
                    challenge.code,
                  ].join('\n'),
                ),
                const SizedBox(height: 9),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) =>
                            ChallengeLobbyScreen(
                          questionBank: questionBank,
                        ),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFFFE082),
                    foregroundColor:
                        const Color(0xFF3A2448),
                  ),
                  icon: const Icon(
                    Icons.qr_code_2_rounded,
                  ),
                  label: const Text(
                    'Yeni Kod Aç',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context)
                        .popUntil((route) => route.isFirst);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(
                      color: Color(0x99FFE082),
                    ),
                    minimumSize: const Size.fromHeight(54),
                  ),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text(
                    'Ana Menü',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
