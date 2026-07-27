part of 'main.dart';

class PlayerUsernamePolicy {
  PlayerUsernamePolicy._();

  static const int minLength = 3;
  static const int maxLength = 16;
  static const Duration changeCooldown = Duration(days: 30);

  static final RegExp _allowedPattern = RegExp(r'^[a-z0-9][a-z0-9_]{2,15}$');

  static const Set<String> _reserved = <String>{
    'admin',
    'administrator',
    'moderator',
    'mod',
    'sistem',
    'system',
    'destek',
    'support',
    'bilgirotasi',
    'bilgi_rotasi',
    'google',
    'firebase',
    'null',
    'undefined',
  };

  static String normalize(String raw) {
    return raw.trim().toLowerCase();
  }

  static String? validate(String raw) {
    final username = normalize(raw);

    if (username.length < minLength || username.length > maxLength) {
      return 'Kullanıcı adı 3–16 karakter olmalı.';
    }

    if (!_allowedPattern.hasMatch(username)) {
      return 'Yalnızca küçük harf, rakam ve alt çizgi kullanabilirsin. '
          'İlk karakter harf veya rakam olmalı.';
    }

    if (_reserved.contains(username)) {
      return 'Bu kullanıcı adı kullanılamaz.';
    }

    return null;
  }

  static Duration remainingCooldown({
    required DateTime? changedAt,
    DateTime? now,
  }) {
    if (changedAt == null) return Duration.zero;

    final current = (now ?? DateTime.now()).toUtc();
    final availableAt = changedAt.toUtc().add(changeCooldown);

    if (!availableAt.isAfter(current)) return Duration.zero;
    return availableAt.difference(current);
  }

  static String cooldownLabel(Duration remaining) {
    if (remaining <= Duration.zero) return 'Şimdi değiştirebilirsin';

    final days = (remaining.inHours / 24).ceil();
    return '$days gün sonra değiştirebilirsin';
  }
}

class PlayerUsernameProfile {
  const PlayerUsernameProfile({
    required this.uid,
    required this.username,
    this.changedAt,
  });

  final String uid;
  final String username;
  final DateTime? changedAt;

  bool get canChange =>
      PlayerUsernamePolicy.remainingCooldown(changedAt: changedAt) <=
      Duration.zero;

  String get cooldownLabel => PlayerUsernamePolicy.cooldownLabel(
    PlayerUsernamePolicy.remainingCooldown(changedAt: changedAt),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'uid': uid,
    'username': username,
    'changedAt': changedAt?.toIso8601String(),
  };

  factory PlayerUsernameProfile.fromJson(Map<String, dynamic> json) {
    return PlayerUsernameProfile(
      uid: json['uid']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      changedAt: DateTime.tryParse(json['changedAt']?.toString() ?? ''),
    );
  }
}

class PlayerUsernameException implements Exception {
  const PlayerUsernameException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PlayerUsernameService {
  PlayerUsernameService._();

  static const String _localPrefix = 'bilgi_rotasi_player_username_v1_';

  static final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  static final ValueNotifier<PlayerUsernameProfile?> state =
      ValueNotifier<PlayerUsernameProfile?>(null);

  static String? get currentUsername => state.value?.username;

  static CollectionReference<Map<String, dynamic>> get _claims =>
      FirebaseFirestore.instance.collection('usernames');

  static DocumentReference<Map<String, dynamic>> _userReference(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  static String _localKey(String uid) => '$_localPrefix$uid';

  static Future<PlayerUsernameProfile?> _readLocal(String uid) async {
    final raw = await _preferences.getString(_localKey(uid));
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      final profile = PlayerUsernameProfile.fromJson(
        Map<String, dynamic>.from(decoded),
      );

      if (profile.uid != uid ||
          PlayerUsernamePolicy.validate(profile.username) != null) {
        return null;
      }

      return profile;
    } catch (_) {
      return null;
    }
  }

  static Future<void> _writeLocal(PlayerUsernameProfile profile) async {
    await _preferences.setString(
      _localKey(profile.uid),
      jsonEncode(profile.toJson()),
    );
  }

  static Future<bool> _remoteUsernameMatches(User user, String username) async {
    final snapshot = await _userReference(user.uid)
        .get(GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 6));

    final remoteUsername = PlayerUsernamePolicy.normalize(
      snapshot.data()?['username']?.toString() ?? '',
    );

    return snapshot.exists && remoteUsername == username;
  }

  static Future<PlayerUsernameProfile?> load() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      state.value = null;
      return null;
    }

    final local = await _readLocal(user.uid);

    if (local != null) {
      state.value = local;
      unawaited(_refreshRemote(user, local));
      return local;
    }

    return _refreshRemote(user, null);
  }

  static Future<PlayerUsernameProfile?> _refreshRemote(
    User user,
    PlayerUsernameProfile? fallback,
  ) async {
    try {
      final snapshot = await _userReference(user.uid)
          .get(GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 6));

      final data = snapshot.data();
      final username = PlayerUsernamePolicy.normalize(
        data?['username']?.toString() ?? '',
      );
      final changedAt = data?['usernameChangedAt'];

      if (PlayerUsernamePolicy.validate(username) != null) {
        return fallback;
      }

      final profile = PlayerUsernameProfile(
        uid: user.uid,
        username: username,
        changedAt:
            changedAt is Timestamp ? changedAt.toDate() : fallback?.changedAt,
      );

      await _writeLocal(profile);
      state.value = profile;
      return profile;
    } catch (_) {
      return fallback;
    }
  }

  static Future<String> requireUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw const PlayerUsernameException(
        'Kullanıcı adı için Google hesabıyla giriş yapmalısın.',
      );
    }

    final current = state.value;
    if (current != null &&
        current.uid == user.uid &&
        PlayerUsernamePolicy.validate(current.username) == null) {
      try {
        if (await _remoteUsernameMatches(user, current.username)) {
          return current.username;
        }

        final repaired = await claim(current.username);
        return repaired.username;
      } on PlayerUsernameException {
        rethrow;
      } catch (_) {
        throw const PlayerUsernameException(
          'Kullanıcı adı sunucuda doğrulanamadı. '
          'İnternet bağlantını kontrol edip tekrar dene.',
        );
      }
    }

    final loaded = await load();
    if (loaded == null) {
      throw const PlayerUsernameException(
        'Önce kullanıcı adını belirlemelisin.',
      );
    }

    return loaded.username;
  }

  static Future<PlayerUsernameProfile> claim(String raw) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw const PlayerUsernameException(
        'Kullanıcı adı için Google hesabıyla giriş yapmalısın.',
      );
    }

    final username = PlayerUsernamePolicy.normalize(raw);
    final validationError = PlayerUsernamePolicy.validate(username);

    if (validationError != null) {
      throw PlayerUsernameException(validationError);
    }

    final current = await load();

    if (current?.username == username) {
      try {
        if (await _remoteUsernameMatches(user, username)) {
          return current!;
        }
      } catch (_) {
        // Aynı adın sunucu kaydı eksikse işlem aşağıdaki
        // transaction ile yeniden kurulacaktır.
      }
    }

    if (current != null && current.username != username && !current.canChange) {
      throw PlayerUsernameException(
        'Kullanıcı adını ${current.cooldownLabel.toLowerCase()}.',
      );
    }

    final userReference = _userReference(user.uid);
    final targetReference = _claims.doc(username);
    final now = DateTime.now().toUtc();

    await FirebaseFirestore.instance.runTransaction<void>((transaction) async {
      final userSnapshot = await transaction.get(userReference);
      final targetSnapshot = await transaction.get(targetReference);
      final userData = userSnapshot.data() ?? <String, dynamic>{};

      final oldUsername = PlayerUsernamePolicy.normalize(
        userData['username']?.toString() ?? '',
      );
      final rawChangedAt = userData['usernameChangedAt'];
      final remoteChangedAt =
          rawChangedAt is Timestamp ? rawChangedAt.toDate() : null;

      DocumentSnapshot<Map<String, dynamic>>? oldClaimSnapshot;
      DocumentReference<Map<String, dynamic>>? oldClaimReference;

      if (oldUsername.isNotEmpty && oldUsername != username) {
        oldClaimReference = _claims.doc(oldUsername);
        oldClaimSnapshot = await transaction.get(oldClaimReference);
      }

      final ownerUid = targetSnapshot.data()?['uid']?.toString();

      if (targetSnapshot.exists && ownerUid != user.uid) {
        throw const PlayerUsernameException(
          'Bu kullanıcı adı başkası tarafından alınmış.',
        );
      }

      final remaining = PlayerUsernamePolicy.remainingCooldown(
        changedAt: remoteChangedAt,
        now: now,
      );

      if (oldUsername.isNotEmpty &&
          oldUsername != username &&
          remaining > Duration.zero) {
        throw PlayerUsernameException(
          'Kullanıcı adını '
          '${PlayerUsernamePolicy.cooldownLabel(remaining).toLowerCase()}.',
        );
      }

      if (!targetSnapshot.exists) {
        transaction.set(targetReference, <String, dynamic>{
          'uid': user.uid,
          'username': username,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      transaction.set(userReference, <String, dynamic>{
        'username': username,
        'usernameChangedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (oldClaimReference != null &&
          oldClaimSnapshot?.data()?['uid']?.toString() == user.uid) {
        transaction.delete(oldClaimReference);
      }
    });

    final profile = PlayerUsernameProfile(
      uid: user.uid,
      username: username,
      changedAt: now,
    );

    await _writeLocal(profile);
    state.value = profile;
    AccountCloudService.refreshPresentation();

    try {
      final duelProfile = await LiveDuelProfileService.load();
      await LiveDuelLeaderboardService.publish(duelProfile);
    } catch (_) {
      // Kullanıcı adı kaydı sıralama yayını yüzünden geri alınmamalı.
    }

    return profile;
  }

  static Future<void> deleteAccountIdentity(String uid) async {
    final userReference = _userReference(uid);
    final local = await _readLocal(uid);

    await FirebaseFirestore.instance.runTransaction<void>((transaction) async {
      final userSnapshot = await transaction.get(userReference);
      final username = PlayerUsernamePolicy.normalize(
        userSnapshot.data()?['username']?.toString() ?? local?.username ?? '',
      );

      DocumentReference<Map<String, dynamic>>? claimReference;
      DocumentSnapshot<Map<String, dynamic>>? claimSnapshot;

      if (username.isNotEmpty) {
        claimReference = _claims.doc(username);
        claimSnapshot = await transaction.get(claimReference);
      }

      if (claimReference != null &&
          claimSnapshot?.data()?['uid']?.toString() == uid) {
        transaction.delete(claimReference);
      }

      if (userSnapshot.exists) {
        transaction.delete(userReference);
      }
    });

    await _preferences.remove(_localKey(uid));

    if (state.value?.uid == uid) {
      state.value = null;
    }
  }

  static void resetSession() {
    state.value = null;
  }
}

class PlayerUsernameGate extends StatefulWidget {
  const PlayerUsernameGate({required this.questionBank, super.key});

  final QuestionBank questionBank;

  @override
  State<PlayerUsernameGate> createState() => _PlayerUsernameGateState();
}

class _PlayerUsernameGateState extends State<PlayerUsernameGate> {
  late Future<PlayerUsernameProfile?> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = PlayerUsernameService.load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PlayerUsernameProfile?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data != null) {
          return HomeScreen(questionBank: widget.questionBank);
        }

        return PlayerUsernameSetupScreen(
          onSaved: (_) {
            if (!mounted) return;
            setState(_reload);
          },
        );
      },
    );
  }
}

class PlayerUsernameSetupScreen extends StatefulWidget {
  const PlayerUsernameSetupScreen({
    this.onSaved,
    this.allowBack = false,
    super.key,
  });

  final ValueChanged<PlayerUsernameProfile>? onSaved;
  final bool allowBack;

  @override
  State<PlayerUsernameSetupScreen> createState() =>
      _PlayerUsernameSetupScreenState();
}

class _PlayerUsernameSetupScreenState extends State<PlayerUsernameSetupScreen> {
  late final TextEditingController _controller;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    final current = PlayerUsernameService.currentUsername;
    final googleName = FirebaseAuth.instance.currentUser?.displayName ?? '';
    final parts = googleName
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList(growable: false);
    final first = parts.isEmpty ? '' : parts.first;
    final suggestion = first.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9_]'),
      '',
    );

    _controller = TextEditingController(
      text:
          current ??
          (suggestion.length >= 3
              ? suggestion.substring(0, min(suggestion.length, 16))
              : ''),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;

    final validationError = PlayerUsernamePolicy.validate(_controller.text);

    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final profile = await PlayerUsernameService.claim(_controller.text);

      if (!mounted) return;

      widget.onSaved?.call(profile);

      if (widget.allowBack && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(profile);
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _busy = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = PlayerUsernameService.state.value;
    final changing = current != null;
    final remaining = PlayerUsernamePolicy.remainingCooldown(
      changedAt: current?.changedAt,
    );
    final blocked = changing && remaining > Duration.zero;

    return Scaffold(
      appBar:
          widget.allowBack ? AppBar(title: const Text('Kullanıcı Adı')) : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF170C21),
              Color(0xFF352044),
              Color(0xFF0D5260),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const Text(
                          '🪪',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 52),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          changing
                              ? 'Kullanıcı adını değiştir'
                              : 'Oyuncu adını belirle',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Bu ad Canlı Düello, lig sıralaması ve '
                          'maç geçmişinde görünecek. Google adın ve '
                          'e-postan diğer oyunculara gösterilmeyecek.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _controller,
                          enabled: !_busy && !blocked,
                          maxLength: 16,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9_]'),
                            ),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Kullanıcı adı',
                            prefixText: '@',
                            hintText: 'leventua',
                            errorText: _error,
                            helperText:
                                blocked
                                    ? PlayerUsernamePolicy.cooldownLabel(
                                      remaining,
                                    )
                                    : '3–16 karakter • küçük harf, '
                                        'rakam ve _',
                          ),
                          onSubmitted: (_) => _save(),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _busy || blocked ? null : _save,
                          icon:
                              _busy
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                  : const Icon(Icons.check_rounded),
                          label: Text(
                            changing
                                ? 'Kullanıcı Adını Değiştir'
                                : 'Kullanıcı Adını Kaydet',
                          ),
                        ),
                        if (!widget.allowBack) ...<Widget>[
                          const SizedBox(height: 12),
                          const Text(
                            'Kullanıcı adını daha sonra 30 günde bir '
                            'değiştirebilirsin.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
