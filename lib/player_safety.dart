part of 'main.dart';

enum PlayerReportReason {
  inappropriateUsername('Uygunsuz kullanıcı adı'),
  impersonation('Taklit / yanıltıcı kimlik'),
  harassment('Hakaret, tehdit veya taciz'),
  cheating('Hile veya sıralama manipülasyonu'),
  other('Diğer');

  const PlayerReportReason(this.label);
  final String label;
}

class PlayerSafetyPolicy {
  PlayerSafetyPolicy._();

  static const int reportNoteMaxLength = 300;

  static String sanitizeNote(String raw) {
    final sanitized =
        raw
            .replaceAll(RegExp(r'[\u0000-\u0008\u000B\u000C\u000E-\u001F]'), '')
            .trim();
    return sanitized.substring(0, min(sanitized.length, reportNoteMaxLength));
  }

  static String reportId({
    required String reporterUid,
    required String targetUid,
    required PlayerReportReason reason,
  }) {
    return '${reporterUid}_${targetUid}_${reason.name}';
  }
}

class BlockedPlayer {
  const BlockedPlayer({
    required this.uid,
    required this.username,
    this.blockedAt,
  });

  final String uid;
  final String username;
  final DateTime? blockedAt;
}

class PlayerSafetyService {
  PlayerSafetyService._();

  static User _requireUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Bu işlem için Google hesabıyla giriş yapmalısın.');
    }
    return user;
  }

  static Future<void> report({
    required String targetUid,
    required String targetUsername,
    required PlayerReportReason reason,
    String note = '',
    String source = 'unknown',
  }) async {
    final user = _requireUser();
    if (targetUid.isEmpty || targetUid == user.uid) {
      throw StateError('Bu oyuncu bildirilemez.');
    }

    final safeNote = PlayerSafetyPolicy.sanitizeNote(note);
    final id = PlayerSafetyPolicy.reportId(
      reporterUid: user.uid,
      targetUid: targetUid,
      reason: reason,
    );

    try {
      await SecureCallableService.call('reportPlayer', <String, dynamic>{
        'reportId': id,
        'targetUid': targetUid,
        'targetUsername': PlayerUsernamePolicy.normalize(targetUsername),
        'reason': reason.name,
        'note': safeNote,
        'source': source,
        'appVersion': AppBuildInfo.version,
      });
    } on FirebaseFunctionsException catch (error) {
      if (error.code == 'permission-denied' || error.code == 'already-exists') {
        throw StateError('Bu bildirim daha önce gönderilmiş.');
      }
      rethrow;
    }
  }

  static DocumentReference<Map<String, dynamic>> _blockReference(
    String ownerUid,
    String targetUid,
  ) {
    return FirebaseFirestore.instance
        .collection('player_blocks')
        .doc(ownerUid)
        .collection('blocked')
        .doc(targetUid);
  }

  static Future<void> block({
    required String targetUid,
    required String targetUsername,
  }) async {
    final user = _requireUser();
    if (targetUid.isEmpty || targetUid == user.uid) {
      throw StateError('Bu oyuncu engellenemez.');
    }

    await SecureCallableService.call('setPlayerBlock', <String, dynamic>{
      'targetUid': targetUid,
      'targetUsername': PlayerUsernamePolicy.normalize(targetUsername),
      'blocked': true,
      'appVersion': AppBuildInfo.version,
    });
  }

  static Future<void> unblock(String targetUid) async {
    _requireUser();
    await SecureCallableService.call('setPlayerBlock', <String, dynamic>{
      'targetUid': targetUid,
      'blocked': false,
      'appVersion': AppBuildInfo.version,
    });
  }

  static Future<List<BlockedPlayer>> loadBlocked() async {
    final user = _requireUser();
    final snapshot = await FirebaseFirestore.instance
        .collection('player_blocks')
        .doc(user.uid)
        .collection('blocked')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get(const GetOptions(source: Source.server));

    return snapshot.docs
        .map((document) {
          final data = document.data();
          final rawBlockedAt = data['createdAt'];
          return BlockedPlayer(
            uid: document.id,
            username:
                data['targetUsername']?.toString().trim().isNotEmpty == true
                    ? data['targetUsername'].toString().trim()
                    : 'Bilinmeyen oyuncu',
            blockedAt: rawBlockedAt is Timestamp ? rawBlockedAt.toDate() : null,
          );
        })
        .toList(growable: false);
  }

  static Future<bool> isBlockedEitherDirection(String targetUid) async {
    final user = _requireUser();
    if (targetUid.isEmpty || targetUid == user.uid) return false;

    final documents = await Future.wait(<Future<DocumentSnapshot>>[
      _blockReference(
        user.uid,
        targetUid,
      ).get(const GetOptions(source: Source.server)),
      _blockReference(
        targetUid,
        user.uid,
      ).get(const GetOptions(source: Source.server)),
    ]);
    return documents.any((document) => document.exists);
  }
}

class PlayerSafetyDialogs {
  PlayerSafetyDialogs._();

  static Future<void> showActions(
    BuildContext context, {
    required String targetUid,
    required String targetUsername,
    required String source,
  }) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder:
          (sheetContext) => SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: const Text('Oyuncuyu bildir'),
                  onTap: () => Navigator.pop(sheetContext, 'report'),
                ),
                ListTile(
                  leading: const Icon(Icons.block_rounded),
                  title: const Text('Oyuncuyu engelle'),
                  subtitle: const Text(
                    'Bu oyuncuyla yeniden eşleştirilmezsin.',
                  ),
                  onTap: () => Navigator.pop(sheetContext, 'block'),
                ),
              ],
            ),
          ),
    );
    if (!context.mounted || action == null) return;

    if (action == 'block') {
      try {
        await PlayerSafetyService.block(
          targetUid: targetUid,
          targetUsername: targetUsername,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Oyuncu engellendi.')));
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        }
      }
      return;
    }

    final noteController = TextEditingController();
    var reason = PlayerReportReason.inappropriateUsername;
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder:
              (dialogContext) => StatefulBuilder(
                builder:
                    (context, setState) => AlertDialog(
                      title: const Text('Oyuncuyu bildir'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            DropdownButtonFormField<PlayerReportReason>(
                              initialValue: reason,
                              decoration: const InputDecoration(
                                labelText: 'Bildirim nedeni',
                              ),
                              items: PlayerReportReason.values
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(item.label),
                                    ),
                                  )
                                  .toList(growable: false),
                              onChanged:
                                  (value) => setState(
                                    () =>
                                        reason =
                                            value ?? PlayerReportReason.other,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: noteController,
                              maxLength: PlayerSafetyPolicy.reportNoteMaxLength,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Kısa not (isteğe bağlı)',
                                helperText:
                                    'Telefon, e-posta veya başka kişisel bilgi yazma.',
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text('Vazgeç'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text('Bildir'),
                        ),
                      ],
                    ),
              ),
        ) ??
        false;
    if (!confirmed || !context.mounted) {
      noteController.dispose();
      return;
    }

    try {
      await PlayerSafetyService.report(
        targetUid: targetUid,
        targetUsername: targetUsername,
        reason: reason,
        note: noteController.text,
        source: source,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bildirim güvenle alındı.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      noteController.dispose();
    }
  }
}

class BlockedPlayersScreen extends StatefulWidget {
  const BlockedPlayersScreen({super.key});

  @override
  State<BlockedPlayersScreen> createState() => _BlockedPlayersScreenState();
}

class _BlockedPlayersScreenState extends State<BlockedPlayersScreen> {
  late Future<List<BlockedPlayer>> _future = PlayerSafetyService.loadBlocked();

  void _reload() {
    setState(() => _future = PlayerSafetyService.loadBlocked());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Engellenen oyuncular')),
      body: FutureBuilder<List<BlockedPlayer>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Engellenen oyuncular yüklenemedi.'),
            );
          }
          final players = snapshot.data ?? const <BlockedPlayer>[];
          if (players.isEmpty) {
            return const Center(child: Text('Engellenen oyuncu yok.'));
          }
          return ListView.separated(
            itemCount: players.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final player = players[index];
              return ListTile(
                leading: const Icon(Icons.person_off_outlined),
                title: Text('@${player.username}'),
                trailing: TextButton(
                  onPressed: () async {
                    await PlayerSafetyService.unblock(player.uid);
                    if (mounted) _reload();
                  },
                  child: const Text('Engeli kaldır'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AccountDataViewScreen extends StatelessWidget {
  const AccountDataViewScreen({super.key});

  Future<Map<String, dynamic>> _loadOwnData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Google hesabı gerekli.');

    final values = await Future.wait<Object>(<Future<Object>>[
      XpProgressService.load(),
      CareerStatsService.load(),
      LiveDuelProfileService.load(),
    ]);
    final xp = values[0] as XpProgress;
    final career = values[1] as CareerStats;
    final duel = values[2] as LiveDuelProfile;
    final unlocked =
        careerAchievements.where((item) => item.isUnlocked(career)).length;

    return <String, dynamic>{
      'account': <String, dynamic>{
        'firebaseUid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'username': PlayerUsernameService.currentUsername,
        'lastSyncedAt':
            AccountCloudService.state.value.lastSyncedAt?.toIso8601String(),
      },
      'progress': <String, dynamic>{
        'totalXp': xp.totalXp,
        'level': xp.level,
        'rank': xp.rank.title,
        'achievementsUnlocked': unlocked,
        'achievementsTotal': careerAchievements.length,
      },
      'career': career.toJson(),
      'liveDuel': duel.toJson(),
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'appVersion': AppBuildInfo.version,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verilerimi görüntüle')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadOwnData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Hesap verileri yüklenemedi.'));
          }
          final data = snapshot.data!;
          final account = data['account'] as Map<String, dynamic>;
          final progress = data['progress'] as Map<String, dynamic>;
          final duel = data['liveDuel'] as Map<String, dynamic>;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              ListTile(
                title: const Text('Kullanıcı adı'),
                subtitle: Text('@${account['username'] ?? 'belirlenmedi'}'),
              ),
              ListTile(
                title: const Text('Hesap ve son eşitleme'),
                subtitle: Text(
                  '${account['email'] ?? 'E-posta yok'}\n'
                  '${account['lastSyncedAt'] ?? 'Henüz eşitlenmedi'}',
                ),
              ),
              ListTile(
                title: const Text('XP ve seviye'),
                subtitle: Text(
                  '${progress['totalXp']} XP • Seviye ${progress['level']}',
                ),
              ),
              ListTile(
                title: const Text('Başarımlar'),
                subtitle: Text(
                  '${progress['achievementsUnlocked']}/'
                  '${progress['achievementsTotal']} açıldı',
                ),
              ),
              ListTile(
                title: const Text('Canlı Düello'),
                subtitle: Text(
                  '${duel['rating']} BR • ${duel['matchesPlayed']} maç • '
                  '${duel['wins']} galibiyet',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed:
                    () => Share.share(
                      const JsonEncoder.withIndent('  ').convert(data),
                      subject: 'Bilgi Rotası hesap verilerim',
                    ),
                icon: const Icon(Icons.ios_share_rounded),
                label: const Text('JSON olarak dışa aktar'),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'Dışa aktarılan dosya yalnızca oturum açmış hesabın '
                  'uygulama verilerini içerir. Paylaşmadan önce alıcıyı kontrol et.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
