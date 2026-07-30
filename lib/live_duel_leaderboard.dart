part of 'main.dart';

class LiveDuelLeaderboardEntry {
  const LiveDuelLeaderboardEntry({
    required this.uid,
    required this.displayName,
    required this.rating,
    required this.matchesPlayed,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.bestWinStreak,
    required this.highestRating,
    this.updatedAt,
  });

  final String uid;
  final String displayName;
  final int rating;
  final int matchesPlayed;
  final int wins;
  final int losses;
  final int draws;
  final int bestWinStreak;
  final int highestRating;
  final DateTime? updatedAt;

  BrLeague get league => BrLeagueResolver.fromRating(rating);

  double get winRate {
    if (matchesPlayed == 0) return 0;
    return wins / matchesPlayed;
  }

  factory LiveDuelLeaderboardEntry.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    final rawUpdatedAt = data['updatedAt'];

    return LiveDuelLeaderboardEntry(
      uid: data['uid']?.toString() ?? snapshot.id,
      displayName:
          data['displayName']?.toString().trim().isNotEmpty == true
              ? data['displayName'].toString().trim()
              : 'Bilgi Yolcusu',
      rating: max(0, (data['rating'] as num?)?.toInt() ?? 1000),
      matchesPlayed: max(0, (data['matchesPlayed'] as num?)?.toInt() ?? 0),
      wins: max(0, (data['wins'] as num?)?.toInt() ?? 0),
      losses: max(0, (data['losses'] as num?)?.toInt() ?? 0),
      draws: max(0, (data['draws'] as num?)?.toInt() ?? 0),
      bestWinStreak: max(0, (data['bestWinStreak'] as num?)?.toInt() ?? 0),
      highestRating: max(0, (data['highestRating'] as num?)?.toInt() ?? 1000),
      updatedAt: rawUpdatedAt is Timestamp ? rawUpdatedAt.toDate() : null,
    );
  }
}

class LiveDuelLeaderboardSnapshot {
  const LiveDuelLeaderboardSnapshot({
    required this.profile,
    required this.leaders,
    this.ownRank,
    this.errorMessage,
  });

  final LiveDuelProfile profile;
  final List<LiveDuelLeaderboardEntry> leaders;
  final int? ownRank;
  final String? errorMessage;
}

class LiveDuelLeaderboardPresentation {
  LiveDuelLeaderboardPresentation._();

  static double leagueProgress(int rating) {
    final league = BrLeagueResolver.fromRating(rating);
    final next = league.nextThreshold;

    if (next == null) return 1;

    final range = next - league.minimumRating;
    if (range <= 0) return 1;

    return ((rating - league.minimumRating) / range).clamp(0.0, 1.0).toDouble();
  }

  static String nextLeagueLabel(int rating) {
    final league = BrLeagueResolver.fromRating(rating);
    final next = league.nextThreshold;

    if (next == null) {
      return 'En yüksek ligdesin';
    }

    final nextLeague = BrLeague.values[league.index + 1];
    final remaining = max(0, next - rating);

    return '${nextLeague.emoji} ${nextLeague.title} ligine '
        '$remaining BR kaldı';
  }

  static int winRatePercent({required int wins, required int matchesPlayed}) {
    if (matchesPlayed <= 0) return 0;
    return ((wins / matchesPlayed) * 100).round();
  }

  static String rankLabel(int? rank) {
    if (rank == null || rank <= 0) return '—';
    return '#$rank';
  }
}

class LiveDuelLeaderboardService {
  LiveDuelLeaderboardService._();

  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _leaderboard =>
      _firestore.collection('live_duel_leaderboard');

  static Future<void> publish(LiveDuelProfile profile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final username = await PlayerUsernameService.requireUsername();

      await _leaderboard.doc(user.uid).set(<String, dynamic>{
        'uid': user.uid,
        'displayName': username,
        'rating': profile.rating,
        'matchesPlayed': profile.matchesPlayed,
        'wins': profile.wins,
        'losses': profile.losses,
        'draws': profile.draws,
        'bestWinStreak': profile.bestWinStreak,
        'highestRating': profile.highestRating,
        'updatedAt': FieldValue.serverTimestamp(),
        'appVersion': AppBuildInfo.version,
      }, SetOptions(merge: false));
    } catch (_) {
      // Sıralama yayını kişisel BR profilini engellememeli.
    }
  }

  static Future<LiveDuelLeaderboardSnapshot> load() async {
    final profile = await LiveDuelProfileService.load();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return LiveDuelLeaderboardSnapshot(
        profile: profile,
        leaders: const <LiveDuelLeaderboardEntry>[],
        errorMessage: 'Lig sıralaması için Google hesabıyla giriş yapmalısın.',
      );
    }

    await publish(profile);

    try {
      final results = await Future.wait<Object>([
        _leaderboard.orderBy('rating', descending: true).limit(100).get(),
        _leaderboard
            .where('rating', isGreaterThan: profile.rating)
            .count()
            .get(),
      ]);

      final leadersSnapshot = results[0] as QuerySnapshot<Map<String, dynamic>>;
      final rankSnapshot = results[1] as AggregateQuerySnapshot;

      final leaders = leadersSnapshot.docs
          .map(LiveDuelLeaderboardEntry.fromSnapshot)
          .toList(growable: false);

      return LiveDuelLeaderboardSnapshot(
        profile: profile,
        leaders: leaders,
        ownRank: (rankSnapshot.count ?? 0) + 1,
      );
    } on FirebaseException catch (error) {
      return LiveDuelLeaderboardSnapshot(
        profile: profile,
        leaders: const <LiveDuelLeaderboardEntry>[],
        errorMessage:
            error.code == 'permission-denied'
                ? 'Lig tablosu güvenlik kuralları henüz '
                    'yayınlanmamış olabilir.'
                : 'Lig tablosu şu anda yüklenemedi.',
      );
    } catch (_) {
      return LiveDuelLeaderboardSnapshot(
        profile: profile,
        leaders: const <LiveDuelLeaderboardEntry>[],
        errorMessage: 'Lig tablosu şu anda yüklenemedi.',
      );
    }
  }
}

class LiveDuelLeaderboardScreen extends StatefulWidget {
  const LiveDuelLeaderboardScreen({super.key});

  @override
  State<LiveDuelLeaderboardScreen> createState() =>
      _LiveDuelLeaderboardScreenState();
}

class _LiveDuelLeaderboardScreenState extends State<LiveDuelLeaderboardScreen> {
  late Future<LiveDuelLeaderboardSnapshot> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = LiveDuelLeaderboardService.load();
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lig ve Sıralama')),
      body: FutureBuilder<LiveDuelLeaderboardSnapshot>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;
          if (data == null) {
            return _errorBody('Lig bilgileri yüklenemedi.');
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: <Widget>[
                _profileCard(data),
                const SizedBox(height: 14),
                _statisticsCard(data.profile),
                const SizedBox(height: 20),
                _sectionTitle(
                  emoji: '🏆',
                  title: 'İlk 100 Oyuncu',
                  subtitle: 'BR puanına göre genel sıralama',
                ),
                const SizedBox(height: 10),
                if (data.errorMessage != null)
                  _messageCard(data.errorMessage!)
                else if (data.leaders.isEmpty)
                  _messageCard('Henüz sıralamaya giren oyuncu yok.')
                else
                  _leaderboardCard(data.leaders),
                const SizedBox(height: 20),
                _sectionTitle(
                  emoji: '🕘',
                  title: 'Son Maçların',
                  subtitle: 'En son 10 dereceli düello',
                ),
                const SizedBox(height: 10),
                _recentMatchesCard(data.profile),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _errorBody(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }

  Widget _profileCard(LiveDuelLeaderboardSnapshot data) {
    final profile = data.profile;
    final league = profile.league;
    final progress = LiveDuelLeaderboardPresentation.leagueProgress(
      profile.rating,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF0F766E), Color(0xFF4338CA)],
        ),
        border: Border.all(color: const Color(0x99FFE082)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 18,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0x22FFFFFF),
                  border: Border.all(color: const Color(0xAAFFE082), width: 2),
                ),
                child: Text(league.emoji, style: const TextStyle(fontSize: 32)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'REKABET PROFİLİN',
                      style: TextStyle(
                        color: Color(0xFFFFE082),
                        fontSize: 11,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${league.title} Ligi',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${profile.rating} BR',
                      style: const TextStyle(
                        color: Color(0xFFD8F7F1),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  const Text(
                    'SIRAN',
                    style: TextStyle(
                      color: Color(0xFFD8CCEA),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    LiveDuelLeaderboardPresentation.rankLabel(data.ownRank),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 11,
              backgroundColor: const Color(0x33FFFFFF),
              color: const Color(0xFFFFE082),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            LiveDuelLeaderboardPresentation.nextLeagueLabel(profile.rating),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (!profile.placementsComplete) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0x20FFFFFF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Yerleştirme maçları: '
                '${profile.placementMatchesRemaining} kaldı. '
                'İlk 5 maçta BR değişimi daha hızlıdır.',
                style: const TextStyle(
                  color: Color(0xFFEDE7F6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statisticsCard(LiveDuelProfile profile) {
    final winRate = LiveDuelLeaderboardPresentation.winRatePercent(
      wins: profile.wins,
      matchesPlayed: profile.matchesPlayed,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: _stat('Maç', profile.matchesPlayed.toString())),
                Expanded(child: _stat('Galibiyet', profile.wins.toString())),
                Expanded(child: _stat('Mağlubiyet', profile.losses.toString())),
                Expanded(child: _stat('Kazanma', '%$winRate')),
              ],
            ),
            const Divider(height: 28),
            Row(
              children: <Widget>[
                Expanded(child: _stat('Beraberlik', profile.draws.toString())),
                Expanded(
                  child: _stat('En iyi seri', profile.bestWinStreak.toString()),
                ),
                Expanded(
                  child: _stat(
                    'En yüksek BR',
                    profile.highestRating.toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _sectionTitle({
    required String emoji,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: <Widget>[
        Text(emoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(subtitle, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _messageCard(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }

  Widget _leaderboardCard(List<LiveDuelLeaderboardEntry> leaders) {
    final ownUid = FirebaseAuth.instance.currentUser?.uid;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          for (var index = 0; index < leaders.length; index++)
            _leaderRow(
              rank: index + 1,
              entry: leaders[index],
              isOwn: leaders[index].uid == ownUid,
              showDivider: index < leaders.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _leaderRow({
    required int rank,
    required LiveDuelLeaderboardEntry entry,
    required bool isOwn,
    required bool showDivider,
  }) {
    final rankText = switch (rank) {
      1 => '🥇',
      2 => '🥈',
      3 => '🥉',
      _ => '#$rank',
    };

    return Container(
      decoration: BoxDecoration(
        color: isOwn ? const Color(0x2232B8A6) : Colors.transparent,
        border:
            showDivider
                ? const Border(bottom: BorderSide(color: Color(0x16000000)))
                : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 40,
            child: Text(
              rankText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: rank <= 3 ? 23 : 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Text(entry.league.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  isOwn ? '${entry.displayName} • Sen' : entry.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  '${entry.matchesPlayed} maç • '
                  '${entry.wins}G ${entry.losses}M',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '${entry.rating} BR',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              Text(entry.league.title, style: const TextStyle(fontSize: 10)),
            ],
          ),
          if (!isOwn)
            IconButton(
              tooltip: 'Oyuncu işlemleri',
              onPressed:
                  () => PlayerSafetyDialogs.showActions(
                    context,
                    targetUid: entry.uid,
                    targetUsername: entry.displayName,
                    source: 'leaderboard',
                  ),
              icon: const Icon(Icons.more_vert_rounded),
            ),
        ],
      ),
    );
  }

  Widget _recentMatchesCard(LiveDuelProfile profile) {
    if (profile.recentMatches.isEmpty) {
      return _messageCard('Henüz tamamlanmış bir düello yok.');
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          for (var index = 0; index < profile.recentMatches.length; index++)
            _recentMatchRow(
              profile.recentMatches[index],
              showDivider: index < profile.recentMatches.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _recentMatchRow(
    LiveDuelRecentMatch match, {
    required bool showDivider,
  }) {
    final resultText = switch (match.result) {
      LiveDuelResult.win => 'Galibiyet',
      LiveDuelResult.loss => 'Mağlubiyet',
      LiveDuelResult.draw => 'Beraberlik',
    };
    final resultEmoji = switch (match.result) {
      LiveDuelResult.win => '✅',
      LiveDuelResult.loss => '❌',
      LiveDuelResult.draw => '🤝',
    };
    final deltaPrefix = match.ratingDelta > 0 ? '+' : '';
    final date = match.playedAt.toLocal();

    return Container(
      decoration: BoxDecoration(
        border:
            showDivider
                ? const Border(bottom: BorderSide(color: Color(0x16000000)))
                : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Row(
        children: <Widget>[
          Text(resultEmoji, style: const TextStyle(fontSize: 23)),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$resultText • ${match.opponentName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  '${date.day.toString().padLeft(2, '0')}.'
                  '${date.month.toString().padLeft(2, '0')}.'
                  '${date.year}',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            '$deltaPrefix${match.ratingDelta} BR',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color:
                  match.ratingDelta >= 0
                      ? const Color(0xFF0F766E)
                      : const Color(0xFFB91C1C),
            ),
          ),
          if (match.opponentUid.isNotEmpty)
            IconButton(
              tooltip: 'Rakibi bildir veya engelle',
              onPressed:
                  () => PlayerSafetyDialogs.showActions(
                    context,
                    targetUid: match.opponentUid,
                    targetUsername: match.opponentName,
                    source: 'live_duel_result',
                  ),
              icon: const Icon(Icons.more_vert_rounded),
            ),
        ],
      ),
    );
  }
}
