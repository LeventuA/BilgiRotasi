part of 'main.dart';

class RetentionState {
  RetentionState({
    required this.weekKey,
    this.lastLoginDate = '',
    this.loginStreak = 0,
    this.bestLoginStreak = 0,
    this.lastLoginReward = 0,
    this.lastLoginRewardDate = '',
    this.weeklyXp = 0,
    this.weeklyAnswered = 0,
    this.weeklyCorrect = 0,
    this.weeklyHardCorrect = 0,
    this.weeklyMarathons = 0,
    this.weeklyBestStreak = 0,
    Set<int>? weeklyCategories,
    Set<String>? rewardedTasks,
    this.dailyCategoryDate = '',
    this.dailyCategoryBonusCount = 0,
    this.eventCorrect = 0,
    this.eventRewarded = false,
  })  : weeklyCategories = weeklyCategories ?? <int>{},
        rewardedTasks = rewardedTasks ?? <String>{};

  String weekKey;
  String lastLoginDate;
  int loginStreak;
  int bestLoginStreak;
  int lastLoginReward;
  String lastLoginRewardDate;

  int weeklyXp;
  int weeklyAnswered;
  int weeklyCorrect;
  int weeklyHardCorrect;
  int weeklyMarathons;
  int weeklyBestStreak;
  Set<int> weeklyCategories;
  Set<String> rewardedTasks;

  String dailyCategoryDate;
  int dailyCategoryBonusCount;

  int eventCorrect;
  bool eventRewarded;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'weekKey': weekKey,
        'lastLoginDate': lastLoginDate,
        'loginStreak': loginStreak,
        'bestLoginStreak': bestLoginStreak,
        'lastLoginReward': lastLoginReward,
        'lastLoginRewardDate': lastLoginRewardDate,
        'weeklyXp': weeklyXp,
        'weeklyAnswered': weeklyAnswered,
        'weeklyCorrect': weeklyCorrect,
        'weeklyHardCorrect': weeklyHardCorrect,
        'weeklyMarathons': weeklyMarathons,
        'weeklyBestStreak': weeklyBestStreak,
        'weeklyCategories': weeklyCategories.toList()..sort(),
        'rewardedTasks': rewardedTasks.toList()..sort(),
        'dailyCategoryDate': dailyCategoryDate,
        'dailyCategoryBonusCount': dailyCategoryBonusCount,
        'eventCorrect': eventCorrect,
        'eventRewarded': eventRewarded,
      };

  factory RetentionState.fromJson(Map<String, dynamic> json) {
    Set<int> intSet(String key) {
      final raw = json[key];
      if (raw is! List) return <int>{};

      return raw
          .whereType<num>()
          .map((value) => value.toInt())
          .where(
            (value) =>
                value >= 0 &&
                value < GameCategory.values.length,
          )
          .toSet();
    }

    Set<String> stringSet(String key) {
      final raw = json[key];
      if (raw is! List) return <String>{};

      return raw
          .map((value) => value.toString())
          .where((value) => value.isNotEmpty)
          .toSet();
    }

    int number(String key) =>
        max(0, (json[key] as num?)?.toInt() ?? 0);

    return RetentionState(
      weekKey: json['weekKey']?.toString() ?? '',
      lastLoginDate: json['lastLoginDate']?.toString() ?? '',
      loginStreak: number('loginStreak'),
      bestLoginStreak: number('bestLoginStreak'),
      lastLoginReward: number('lastLoginReward'),
      lastLoginRewardDate:
          json['lastLoginRewardDate']?.toString() ?? '',
      weeklyXp: number('weeklyXp'),
      weeklyAnswered: number('weeklyAnswered'),
      weeklyCorrect: number('weeklyCorrect'),
      weeklyHardCorrect: number('weeklyHardCorrect'),
      weeklyMarathons: number('weeklyMarathons'),
      weeklyBestStreak: number('weeklyBestStreak'),
      weeklyCategories: intSet('weeklyCategories'),
      rewardedTasks: stringSet('rewardedTasks'),
      dailyCategoryDate:
          json['dailyCategoryDate']?.toString() ?? '',
      dailyCategoryBonusCount:
          number('dailyCategoryBonusCount'),
      eventCorrect: number('eventCorrect'),
      eventRewarded: json['eventRewarded'] == true,
    );
  }
}

class WeeklyTask {
  const WeeklyTask({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.progress,
    required this.target,
    required this.reward,
    required this.rewarded,
  });

  final String id;
  final String emoji;
  final String title;
  final String description;
  final int progress;
  final int target;
  final int reward;
  final bool rewarded;

  bool get completed => progress >= target;

  double get ratio =>
      (progress / max(1, target)).clamp(0.0, 1.0).toDouble();
}

class WeeklyLeague {
  const WeeklyLeague(
    this.minimumXp,
    this.title,
    this.emoji,
  );

  final int minimumXp;
  final String title;
  final String emoji;
}

const List<WeeklyLeague> weeklyLeagues = <WeeklyLeague>[
  WeeklyLeague(0, 'Bronz Lig', '🥉'),
  WeeklyLeague(500, 'Gümüş Lig', '🥈'),
  WeeklyLeague(1200, 'Altın Lig', '🥇'),
  WeeklyLeague(2500, 'Elmas Lig', '💎'),
  WeeklyLeague(5000, 'Efsane Lig', '👑'),
];

class RetentionProgressService {
  RetentionProgressService._();

  static const String _key =
      'bilgi_rotasi_retention_progress_v1';

  static final SharedPreferencesAsync _prefs =
      SharedPreferencesAsync();

  static final ValueNotifier<int> revision =
      ValueNotifier<int>(0);

  static DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static String _two(int value) =>
      value.toString().padLeft(2, '0');

  static String dateKey(DateTime value) =>
      '${value.year}-${_two(value.month)}-${_two(value.day)}';

  static DateTime weekStart([DateTime? value]) {
    final source = value ?? today;
    final normalized =
        DateTime(source.year, source.month, source.day);

    return normalized.subtract(
      Duration(days: normalized.weekday - 1),
    );
  }

  static String currentWeekKey() =>
      dateKey(weekStart());

  static int todayCategoryIndex() {
    final day = today.millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;

    return day % GameCategory.values.length;
  }

  static int eventCategoryIndex() {
    final week = weekStart().millisecondsSinceEpoch ~/
        (Duration.millisecondsPerDay * 7);

    return week % GameCategory.values.length;
  }

  static String eventTitle(int categoryIndex) {
    return switch (categoryIndex) {
      0 => 'Bilim Haftası',
      1 => 'Coğrafya Keşfi',
      2 => 'Tarih Yolculuğu',
      3 => 'Sanat Gecesi',
      4 => 'Eğlence Maratonu',
      _ => 'Spor Festivali',
    };
  }

  static WeeklyLeague leagueFor(int xp) {
    var result = weeklyLeagues.first;

    for (final league in weeklyLeagues) {
      if (xp >= league.minimumXp) {
        result = league;
      } else {
        break;
      }
    }

    return result;
  }

  static WeeklyLeague? nextLeagueFor(int xp) {
    for (final league in weeklyLeagues) {
      if (xp < league.minimumXp) return league;
    }
    return null;
  }

  static Future<void> initialize() async {
    final state = await load();
    final key = dateKey(today);

    if (state.lastLoginDate == key) return;

    final last = DateTime.tryParse(state.lastLoginDate);
    final consecutive = last != null &&
        today
                .difference(
                  DateTime(last.year, last.month, last.day),
                )
                .inDays ==
            1;

    state.loginStreak =
        consecutive ? state.loginStreak + 1 : 1;
    state.bestLoginStreak = max(
      state.bestLoginStreak,
      state.loginStreak,
    );

    const rewards = <int>[20, 30, 40, 50, 60, 80, 120];
    final reward =
        rewards[(state.loginStreak - 1) % rewards.length];

    state.lastLoginDate = key;
    state.lastLoginRewardDate = key;
    state.lastLoginReward = reward;

    await _save(state);

    await XpProgressService._award(
      reward,
      'Günlük giriş serisi • ${state.loginStreak}. gün',
    );
  }

  static Future<RetentionState> load() async {
    RetentionState state;

    try {
      final raw = await _prefs.getString(_key);

      if (raw != null && raw.trim().isNotEmpty) {
        final decoded = jsonDecode(raw);

        state = decoded is Map
            ? RetentionState.fromJson(
                Map<String, dynamic>.from(decoded),
              )
            : RetentionState(
                weekKey: currentWeekKey(),
              );
      } else {
        state = RetentionState(
          weekKey: currentWeekKey(),
        );
      }
    } catch (_) {
      state = RetentionState(
        weekKey: currentWeekKey(),
      );
    }

    if (state.weekKey != currentWeekKey()) {
      state.weekKey = currentWeekKey();
      state.weeklyXp = 0;
      state.weeklyAnswered = 0;
      state.weeklyCorrect = 0;
      state.weeklyHardCorrect = 0;
      state.weeklyMarathons = 0;
      state.weeklyBestStreak = 0;
      state.weeklyCategories.clear();
      state.rewardedTasks.clear();
      state.eventCorrect = 0;
      state.eventRewarded = false;
      await _save(state);
    }

    return state;
  }

  static Future<void> _save(
    RetentionState state,
  ) async {
    try {
      await _prefs.setString(
        _key,
        jsonEncode(state.toJson()),
      );
      revision.value++;
    } catch (_) {
      // Görev kaydı oyunun açılmasını engellememeli.
    }
  }

  static List<WeeklyTask> tasks(
    RetentionState state,
  ) {
    WeeklyTask task({
      required String id,
      required String emoji,
      required String title,
      required String description,
      required int progress,
      required int target,
      required int reward,
    }) {
      return WeeklyTask(
        id: id,
        emoji: emoji,
        title: title,
        description: description,
        progress: progress,
        target: target,
        reward: reward,
        rewarded: state.rewardedTasks.contains(id),
      );
    }

    return <WeeklyTask>[
      task(
        id: 'answer_50',
        emoji: '📝',
        title: 'Haftalık Isınma',
        description: '50 soru cevapla.',
        progress: state.weeklyAnswered,
        target: 50,
        reward: 120,
      ),
      task(
        id: 'correct_25',
        emoji: '✅',
        title: 'Doğru Rotası',
        description: '25 doğru cevap ver.',
        progress: state.weeklyCorrect,
        target: 25,
        reward: 150,
      ),
      task(
        id: 'hard_5',
        emoji: '🧠',
        title: 'Zorların Ustası',
        description: '5 Zor soruyu doğru cevapla.',
        progress: state.weeklyHardCorrect,
        target: 5,
        reward: 120,
      ),
      task(
        id: 'categories_4',
        emoji: '🌈',
        title: 'Çok Yönlü Bilgin',
        description: '4 farklı kategoride doğru cevap ver.',
        progress: state.weeklyCategories.length,
        target: 4,
        reward: 100,
      ),
      task(
        id: 'streak_7',
        emoji: '🔥',
        title: 'Ateş Serisi',
        description: '7 doğru cevaplık seri yap.',
        progress: state.weeklyBestStreak,
        target: 7,
        reward: 150,
      ),
      task(
        id: 'marathon_1',
        emoji: '⚡',
        title: 'Maraton Haftası',
        description: 'Bir Soru Maratonu tamamla.',
        progress: state.weeklyMarathons,
        target: 1,
        reward: 150,
      ),
    ];
  }

  static Future<void> recordXp(int amount) async {
    if (amount <= 0) return;

    final state = await load();
    state.weeklyXp += amount;
    await _save(state);
  }

  static Future<XpGainResult?> recordAnswer({
    required int categoryIndex,
    required bool correct,
    required String difficulty,
    required int currentStreak,
  }) async {
    final state = await load();
    final currentDateKey = dateKey(today);

    if (state.dailyCategoryDate != currentDateKey) {
      state.dailyCategoryDate = currentDateKey;
      state.dailyCategoryBonusCount = 0;
    }

    state.weeklyAnswered++;

    if (correct) {
      state.weeklyCorrect++;
      state.weeklyBestStreak = max(
        state.weeklyBestStreak,
        currentStreak,
      );

      if (difficulty.trim().toLowerCase() == 'zor') {
        state.weeklyHardCorrect++;
      }

      if (categoryIndex >= 0 &&
          categoryIndex < GameCategory.values.length) {
        state.weeklyCategories.add(categoryIndex);
      }
    }

    var bonus = 0;
    final reasons = <String>[];

    if (correct &&
        categoryIndex == todayCategoryIndex() &&
        state.dailyCategoryBonusCount < 10) {
      state.dailyCategoryBonusCount++;
      bonus += 5;
      reasons.add('Günün kategorisi');
    }

    if (correct &&
        categoryIndex == eventCategoryIndex()) {
      state.eventCorrect++;

      if (state.eventCorrect >= 10 &&
          !state.eventRewarded) {
        state.eventRewarded = true;
        bonus += 200;
        reasons.add(eventTitle(categoryIndex));
      }
    }

    for (final task in tasks(state)) {
      if (task.completed && !task.rewarded) {
        state.rewardedTasks.add(task.id);
        bonus += task.reward;
        reasons.add(task.title);
      }
    }

    await _save(state);

    if (bonus <= 0) return null;

    return XpProgressService._award(
      bonus,
      reasons.join(' + '),
    );
  }

  static Future<XpGainResult?> recordMarathon() async {
    final state = await load();
    state.weeklyMarathons++;

    var bonus = 0;
    final reasons = <String>[];

    for (final task in tasks(state)) {
      if (task.completed && !task.rewarded) {
        state.rewardedTasks.add(task.id);
        bonus += task.reward;
        reasons.add(task.title);
      }
    }

    await _save(state);

    if (bonus <= 0) return null;

    return XpProgressService._award(
      bonus,
      reasons.join(' + '),
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

class RetentionHomeCard extends StatelessWidget {
  const RetentionHomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: RetentionProgressService.revision,
      builder: (context, _, __) {
        return FutureBuilder<RetentionState>(
          future: RetentionProgressService.load(),
          builder: (context, snapshot) {
            final state = snapshot.data;

            if (state == null) {
              return const SizedBox(
                height: 120,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFFE082),
                  ),
                ),
              );
            }

            final category = GameCategory.values[
                RetentionProgressService.todayCategoryIndex()];
            final league =
                RetentionProgressService.leagueFor(
              state.weeklyXp,
            );
            final completed =
                RetentionProgressService.tasks(state)
                    .where((task) => task.completed)
                    .length;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const RetentionHubScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(25),
                child: Ink(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF92400E),
                        Color(0xFF6D28D9),
                        Color(0xFF0F766E),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color(0x99FFE082),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      const Row(
                        children: [
                          Text(
                            '📅',
                            style: TextStyle(fontSize: 38),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'GÜNLÜK & HAFTALIK ROTA',
                                  style: TextStyle(
                                    color:
                                        Color(0xFFFFE082),
                                    fontSize: 11,
                                    fontWeight:
                                        FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  'Görevler, lig ve etkinlik',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight:
                                        FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _RetentionMini(
                            '🔥',
                            '${state.loginStreak} gün',
                            'Giriş serisi',
                          ),
                          const SizedBox(width: 7),
                          _RetentionMini(
                            category.emoji,
                            category.label,
                            'Günün kategorisi',
                          ),
                          const SizedBox(width: 7),
                          _RetentionMini(
                            league.emoji,
                            league.title
                                .replaceAll(' Lig', ''),
                            '$completed/6 görev',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _RetentionMini extends StatelessWidget {
  const _RetentionMini(
    this.emoji,
    this.value,
    this.label,
  );

  final String emoji;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: const Color(0x16FFFFFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0x33FFFFFF),
          ),
        ),
        child: Column(
          children: [
            Text(emoji),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFD8CCEA),
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RetentionHubScreen extends StatelessWidget {
  const RetentionHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Günlük & Haftalık Rota'),
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: RetentionProgressService.revision,
        builder: (context, _, __) {
          return FutureBuilder<RetentionState>(
            future: RetentionProgressService.load(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final state = snapshot.data!;
              final tasks =
                  RetentionProgressService.tasks(state);
              final category = GameCategory.values[
                  RetentionProgressService.todayCategoryIndex()];
              final eventCategory = GameCategory.values[
                  RetentionProgressService.eventCategoryIndex()];
              final league =
                  RetentionProgressService.leagueFor(
                state.weeklyXp,
              );
              final next =
                  RetentionProgressService.nextLeagueFor(
                state.weeklyXp,
              );

              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  16,
                  18,
                  28,
                ),
                children: [
                  _loginCard(state),
                  const SizedBox(height: 14),
                  _categoryCard(state, category),
                  const SizedBox(height: 18),
                  const Text(
                    'Haftalık görevler',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 9),
                  for (final task in tasks)
                    _taskCard(task),
                  const SizedBox(height: 18),
                  _leagueCard(state, league, next),
                  const SizedBox(height: 18),
                  _eventCard(state, eventCategory),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _loginCard(RetentionState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF9A3412),
            Color(0xFF7C2D12),
            Color(0xFF4C1D95),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0x99FFE082),
        ),
      ),
      child: Column(
        children: [
          const Text(
            '🔥',
            style: TextStyle(fontSize: 49),
          ),
          Text(
            '${state.loginStreak} günlük giriş serisi',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            'En iyi seri: ${state.bestLoginStreak} gün',
            style: const TextStyle(
              color: Color(0xFFD8CCEA),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            'Bugünün ödülü: +${state.lastLoginReward} XP ✅',
            style: const TextStyle(
              color: Color(0xFFFFE082),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            '7. gün ödülü 120 XP • Seri devam ettikçe döngü yenilenir.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFE7E1F0),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryCard(
    RetentionState state,
    GameCategory category,
  ) {
    final currentKey = RetentionProgressService.dateKey(
      RetentionProgressService.today,
    );
    final used = state.dailyCategoryDate == currentKey
        ? state.dailyCategoryBonusCount
        : 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          category.color.withOpacity(0.13),
          Colors.white,
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: category.color.withOpacity(0.45),
        ),
      ),
      child: Row(
        children: [
          Text(
            category.emoji,
            style: const TextStyle(fontSize: 47),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'GÜNÜN KATEGORİSİ',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  category.label,
                  style: TextStyle(
                    color: category.darkColor,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'İlk 10 doğru cevapta +5 XP • $used/10',
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskCard(WeeklyTask task) {
    final color = task.completed
        ? const Color(0xFF16A34A)
        : const Color(0xFF7C3AED);

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: task.completed
            ? const Color(0xFFECFDF5)
            : Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: task.completed
              ? const Color(0xFF86EFAC)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Text(
            task.completed ? '✅' : task.emoji,
            style: const TextStyle(fontSize: 29),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      '+${task.reward} XP',
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Text(
                  task.description,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 7),
                LinearProgressIndicator(
                  value: task.ratio,
                  minHeight: 8,
                  backgroundColor:
                      const Color(0xFFE2E8F0),
                  color: color,
                ),
                const SizedBox(height: 4),
                Text(
                  '${min(task.progress, task.target)} / '
                  '${task.target}'
                  '${task.rewarded ? ' • Ödül alındı' : ''}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _leagueCard(
    RetentionState state,
    WeeklyLeague league,
    WeeklyLeague? next,
  ) {
    final nextTarget = next?.minimumXp;
    final progress = nextTarget == null
        ? 1.0
        : ((state.weeklyXp - league.minimumXp) /
                max(1, nextTarget - league.minimumXp))
            .clamp(0.0, 1.0)
            .toDouble();

    final start = RetentionProgressService.weekStart();
    final end = start.add(const Duration(days: 6));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF312E81),
            Color(0xFF6D28D9),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0x99FFE082),
        ),
      ),
      child: Column(
        children: [
          Text(
            league.emoji,
            style: const TextStyle(fontSize: 52),
          ),
          Text(
            league.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            '${start.day}.${start.month} – '
            '${end.day}.${end.month} • '
            '${state.weeklyXp} XP',
            style: const TextStyle(
              color: Color(0xFFD8CCEA),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 11,
            backgroundColor:
                const Color(0x33FFFFFF),
            color: const Color(0xFFFFE082),
          ),
          const SizedBox(height: 7),
          Text(
            next == null
                ? 'Efsane Lig açıldı! 👑'
                : '${next.title} için '
                    '${max(0, next.minimumXp - state.weeklyXp)} XP kaldı.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFFE082),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _eventCard(
    RetentionState state,
    GameCategory category,
  ) {
    const target = 10;
    final progress =
        (state.eventCorrect / target).clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          category.color.withOpacity(0.14),
          Colors.white,
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: category.color.withOpacity(0.48),
        ),
      ),
      child: Column(
        children: [
          Text(
            category.emoji,
            style: const TextStyle(fontSize: 48),
          ),
          Text(
            RetentionProgressService.eventTitle(
              category.index,
            ),
            style: TextStyle(
              color: category.darkColor,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            '${category.label} kategorisinde '
            '10 doğru cevap • +200 XP',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 11),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor:
                category.color.withOpacity(0.12),
            color: category.color,
          ),
          const SizedBox(height: 6),
          Text(
            '${min(state.eventCorrect, target)} / $target'
            '${state.eventRewarded ? ' • Ödül alındı ✅' : ''}',
            style: TextStyle(
              color: category.darkColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
