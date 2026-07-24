part of 'main.dart';

enum AccountMode {
  undecided,
  guest,
  google,
}

class AccountAccessPolicy {
  AccountAccessPolicy._();

  static bool dailyVisible(AccountMode mode) {
    return mode == AccountMode.google;
  }
}

class AccountSessionState {
  const AccountSessionState({
    required this.mode,
    required this.firebaseReady,
    this.user,
    this.busy = false,
    this.message,
    this.lastSyncedAt,
  });

  final AccountMode mode;
  final bool firebaseReady;
  final User? user;
  final bool busy;
  final String? message;
  final DateTime? lastSyncedAt;

  bool get signedIn => mode == AccountMode.google && user != null;

  String get sessionKey {
    return '${mode.name}:${user?.uid ?? 'guest'}';
  }
}

class AccountSnapshotCodec {
  AccountSnapshotCodec._();

  static String encode(Map<String, Object?> values) {
    final encoded = <String, dynamic>{};

    for (final entry in values.entries) {
      final value = entry.value;

      if (value is String) {
        encoded[entry.key] = <String, dynamic>{
          'type': 'string',
          'value': value,
        };
      } else if (value is int) {
        encoded[entry.key] = <String, dynamic>{
          'type': 'int',
          'value': value,
        };
      } else if (value is double) {
        encoded[entry.key] = <String, dynamic>{
          'type': 'double',
          'value': value,
        };
      } else if (value is bool) {
        encoded[entry.key] = <String, dynamic>{
          'type': 'bool',
          'value': value,
        };
      } else if (value is List<String>) {
        encoded[entry.key] = <String, dynamic>{
          'type': 'stringList',
          'value': value,
        };
      }
    }

    return jsonEncode(<String, dynamic>{
      'schema': 1,
      'values': encoded,
    });
  }

  static Map<String, Object?> decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Bulut kayıt biçimi geçersiz.');
    }

    final root = Map<String, dynamic>.from(decoded);
    final rawValues = root['values'];
    if (rawValues is! Map) {
      throw const FormatException('Bulut kayıt değerleri bulunamadı.');
    }

    final result = <String, Object?>{};

    for (final entry in rawValues.entries) {
      final key = entry.key.toString();
      final item = entry.value;

      if (item is! Map) continue;

      final typed = Map<String, dynamic>.from(item);
      final type = typed['type']?.toString();
      final value = typed['value'];

      switch (type) {
        case 'string':
          if (value is String) result[key] = value;
        case 'int':
          if (value is num) result[key] = value.toInt();
        case 'double':
          if (value is num) result[key] = value.toDouble();
        case 'bool':
          if (value is bool) result[key] = value;
        case 'stringList':
          if (value is List) {
            result[key] = value
                .map((item) => item.toString())
                .toList(growable: false);
          }
      }
    }

    return result;
  }
}

class AccountLocalSnapshot {
  AccountLocalSnapshot._();

  static const String controlPrefix =
      'bilgi_rotasi_account_';

  static bool shouldSyncKey(String key) {
    if (!key.startsWith('bilgi_rotasi_')) return false;
    if (key.startsWith(controlPrefix)) return false;

    final lower = key.toLowerCase();

    if (lower.contains('error_log') ||
        lower.contains('system_health') ||
        lower.contains('question_feedback')) {
      return false;
    }

    return true;
  }

  static Future<String> capture() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.reload();

    final values = <String, Object?>{};

    for (final key in preferences.getKeys()) {
      if (!shouldSyncKey(key)) continue;
      values[key] = preferences.get(key);
    }

    final encoded = AccountSnapshotCodec.encode(values);

    if (utf8.encode(encoded).length > 700000) {
      throw StateError(
        'Bulut kaydı güvenli boyut sınırını aştı.',
      );
    }

    return encoded;
  }

  static Future<void> restore(String raw) async {
    final values = AccountSnapshotCodec.decode(raw);
    final preferences = await SharedPreferences.getInstance();
    await preferences.reload();

    final currentKeys = preferences
        .getKeys()
        .where(shouldSyncKey)
        .toList(growable: false);

    for (final key in currentKeys) {
      await preferences.remove(key);
    }

    for (final entry in values.entries) {
      final value = entry.value;

      if (value is String) {
        await preferences.setString(entry.key, value);
      } else if (value is int) {
        await preferences.setInt(entry.key, value);
      } else if (value is double) {
        await preferences.setDouble(entry.key, value);
      } else if (value is bool) {
        await preferences.setBool(entry.key, value);
      } else if (value is List<String>) {
        await preferences.setStringList(entry.key, value);
      }
    }

    await preferences.reload();
  }

  static Future<void> clearGameData() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.reload();

    for (final key in preferences
        .getKeys()
        .where(shouldSyncKey)
        .toList(growable: false)) {
      await preferences.remove(key);
    }
  }
}

class AccountCloudService with WidgetsBindingObserver {
  AccountCloudService._();

  static final AccountCloudService _instance =
      AccountCloudService._();

  static const String _webClientId =
      '184174765052-cq19m113aum2jofrfj3np8adbulgmeon'
      '.apps.googleusercontent.com';

  static const String _guestSelectedKey =
      'bilgi_rotasi_account_guest_selected_v1';
  static const String _guestSnapshotKey =
      'bilgi_rotasi_account_guest_snapshot_v1';

  static final ValueNotifier<AccountSessionState> state =
      ValueNotifier<AccountSessionState>(
    const AccountSessionState(
      mode: AccountMode.undecided,
      firebaseReady: false,
    ),
  );

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  GoogleSignIn? _googleSignIn;
  Timer? _syncTimer;
  bool _initialized = false;
  bool _syncing = false;

  static bool get dailyVisible {
    return AccountAccessPolicy.dailyVisible(state.value.mode);
  }

  static Future<void> initialize() {
    return _instance._initialize();
  }

  static Future<void> continueAsGuest() {
    return _instance._continueAsGuest();
  }

  static Future<void> signInWithGoogle() {
    return _instance._signInWithGoogle();
  }

  static Future<void> signOut() {
    return _instance._signOut();
  }

  static Future<void> syncNow() {
    return _instance._syncNow(manual: true);
  }

  Future<void> _initialize() async {
    if (_initialized) return;
    _initialized = true;

    final preferences = await SharedPreferences.getInstance();
    final guestSelected =
        preferences.getBool(_guestSelectedKey) == true;

    try {
      await Firebase.initializeApp();

      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _googleSignIn = GoogleSignIn.instance;

      await _googleSignIn!.initialize(
        serverClientId: _webClientId,
      );

      WidgetsBinding.instance.addObserver(this);

      final currentUser = _auth!.currentUser;

      if (currentUser == null) {
        state.value = AccountSessionState(
          mode: guestSelected
              ? AccountMode.guest
              : AccountMode.undecided,
          firebaseReady: true,
        );
      } else {
        state.value = AccountSessionState(
          mode: AccountMode.google,
          firebaseReady: true,
          user: currentUser,
          busy: true,
        );

        await _activateExistingUser(currentUser);
      }

      _syncTimer = Timer.periodic(
        const Duration(seconds: 45),
        (_) {
          if (state.value.signedIn) {
            unawaited(_syncNow(manual: false));
          }
        },
      );
    } catch (error) {
      state.value = AccountSessionState(
        mode: guestSelected
            ? AccountMode.guest
            : AccountMode.undecided,
        firebaseReady: false,
        message:
            'Google girişi şu an hazırlanamadı. '
            'Misafir olarak çevrimdışı oynayabilirsin.',
      );
    }
  }

  Future<void> _continueAsGuest() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_guestSelectedKey, true);

    final snapshot = await AccountLocalSnapshot.capture();
    await preferences.setString(
      _guestSnapshotKey,
      snapshot,
    );

    state.value = AccountSessionState(
      mode: AccountMode.guest,
      firebaseReady: state.value.firebaseReady,
    );
  }

  Future<void> _signInWithGoogle() async {
    if (_auth == null ||
        _firestore == null ||
        _googleSignIn == null) {
      state.value = AccountSessionState(
        mode: state.value.mode,
        firebaseReady: false,
        message:
            'Google girişi hazır değil. '
            'İnternet bağlantını kontrol et.',
      );
      return;
    }

    final previousMode = state.value.mode;
    final preferences = await SharedPreferences.getInstance();
    final guestSnapshot = await AccountLocalSnapshot.capture();

    await preferences.setString(
      _guestSnapshotKey,
      guestSnapshot,
    );
    await preferences.setBool(_guestSelectedKey, true);

    state.value = AccountSessionState(
      mode: previousMode,
      firebaseReady: true,
      busy: true,
    );

    try {
      final GoogleSignInAccount? googleUser =
          await _googleSignIn!.authenticate();

      if (googleUser == null) {
        state.value = AccountSessionState(
          mode: previousMode,
          firebaseReady: true,
          message: 'Google girişi iptal edildi.',
        );
        return;
      }

      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw StateError(
          'Google kimlik doğrulama anahtarı alınamadı.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final result = await _auth!.signInWithCredential(
        credential,
      );
      final user = result.user;

      if (user == null) {
        throw StateError('Google hesabı açılamadı.');
      }

      final remote = await _loadRemoteSnapshot(user.uid);

      if (remote == null) {
        await _writeRemoteSnapshot(
          user,
          guestSnapshot,
        );
      } else {
        await AccountLocalSnapshot.restore(remote);
        await _saveUserLocalSnapshot(
          user.uid,
          remote,
          dirty: false,
        );
      }

      await _refreshGameServices();

      state.value = AccountSessionState(
        mode: AccountMode.google,
        firebaseReady: true,
        user: user,
        lastSyncedAt: DateTime.now(),
      );
    } catch (error) {
      state.value = AccountSessionState(
        mode: previousMode,
        firebaseReady: true,
        message: _friendlyError(error),
      );
    }
  }

  Future<void> _activateExistingUser(User user) async {
    final preferences = await SharedPreferences.getInstance();
    final localSnapshot = preferences.getString(
      _userSnapshotKey(user.uid),
    );
    final dirty =
        preferences.getBool(_userDirtyKey(user.uid)) == true;

    try {
      if (dirty &&
          localSnapshot != null &&
          localSnapshot.isNotEmpty) {
        await AccountLocalSnapshot.restore(localSnapshot);
        await _writeRemoteSnapshot(user, localSnapshot);
      } else {
        final remote = await _loadRemoteSnapshot(user.uid);

        if (remote != null) {
          await AccountLocalSnapshot.restore(remote);
          await _saveUserLocalSnapshot(
            user.uid,
            remote,
            dirty: false,
          );
        } else {
          final snapshot = localSnapshot != null &&
                  localSnapshot.isNotEmpty
              ? localSnapshot
              : await AccountLocalSnapshot.capture();

          await AccountLocalSnapshot.restore(snapshot);
          await _writeRemoteSnapshot(user, snapshot);
        }
      }

      await _refreshGameServices();

      state.value = AccountSessionState(
        mode: AccountMode.google,
        firebaseReady: true,
        user: user,
        lastSyncedAt: DateTime.now(),
      );
    } catch (_) {
      await _refreshGameServices();

      state.value = AccountSessionState(
        mode: AccountMode.google,
        firebaseReady: true,
        user: user,
        message:
            'Bulut kaydı şu an alınamadı. '
            'Telefondaki kayıtla devam ediliyor.',
      );
    }
  }

  Future<String?> _loadRemoteSnapshot(String uid) async {
    final document = await _firestore!
        .collection('users')
        .doc(uid)
        .get();

    if (!document.exists) return null;

    final data = document.data();
    final raw = data?['snapshotJson'];

    if (raw is! String || raw.isEmpty) return null;

    AccountSnapshotCodec.decode(raw);
    return raw;
  }

  Future<void> _writeRemoteSnapshot(
    User user,
    String snapshot,
  ) async {
    if (utf8.encode(snapshot).length > 700000) {
      throw StateError(
        'Bulut kaydı güvenli boyut sınırını aştı.',
      );
    }

    await _firestore!
        .collection('users')
        .doc(user.uid)
        .set(
      <String, dynamic>{
        'schema': 1,
        'snapshotJson': snapshot,
        'displayName': user.displayName ?? '',
        'email': user.email ?? '',
        'appVersion': AppBuildInfo.version,
        'clientUpdatedAt':
            DateTime.now().toUtc().toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await _saveUserLocalSnapshot(
      user.uid,
      snapshot,
      dirty: false,
    );
  }

  Future<void> _saveUserLocalSnapshot(
    String uid,
    String snapshot, {
    required bool dirty,
  }) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      _userSnapshotKey(uid),
      snapshot,
    );
    await preferences.setBool(
      _userDirtyKey(uid),
      dirty,
    );
  }

  Future<void> _syncNow({
    required bool manual,
  }) async {
    final user = _auth?.currentUser;

    if (user == null ||
        _firestore == null ||
        _syncing) {
      return;
    }

    _syncing = true;

    if (manual) {
      state.value = AccountSessionState(
        mode: AccountMode.google,
        firebaseReady: true,
        user: user,
        busy: true,
        lastSyncedAt: state.value.lastSyncedAt,
      );
    }

    try {
      final snapshot = await AccountLocalSnapshot.capture();

      await _saveUserLocalSnapshot(
        user.uid,
        snapshot,
        dirty: true,
      );

      await _writeRemoteSnapshot(user, snapshot);

      state.value = AccountSessionState(
        mode: AccountMode.google,
        firebaseReady: true,
        user: user,
        lastSyncedAt: DateTime.now(),
      );
    } catch (_) {
      state.value = AccountSessionState(
        mode: AccountMode.google,
        firebaseReady: true,
        user: user,
        message:
            'Bulut eşitlemesi bekliyor. '
            'Bağlantı gelince yeniden denenecek.',
        lastSyncedAt: state.value.lastSyncedAt,
      );
    } finally {
      _syncing = false;
    }
  }

  Future<void> _signOut() async {
    final user = _auth?.currentUser;

    if (user == null) {
      await _continueAsGuest();
      return;
    }

    state.value = AccountSessionState(
      mode: AccountMode.google,
      firebaseReady: true,
      user: user,
      busy: true,
      lastSyncedAt: state.value.lastSyncedAt,
    );

    try {
      await _syncNow(manual: false);
    } catch (_) {
      // Çıkış, eşitleme hatası yüzünden kilitlenmemeli.
    }

    final accountSnapshot =
        await AccountLocalSnapshot.capture();

    await _saveUserLocalSnapshot(
      user.uid,
      accountSnapshot,
      dirty: false,
    );

    await _auth?.signOut();
    await _googleSignIn?.signOut();

    final preferences = await SharedPreferences.getInstance();
    final guestSnapshot =
        preferences.getString(_guestSnapshotKey);

    if (guestSnapshot != null &&
        guestSnapshot.isNotEmpty) {
      await AccountLocalSnapshot.restore(
        guestSnapshot,
      );
    } else {
      await AccountLocalSnapshot.clearGameData();
    }

    await preferences.setBool(_guestSelectedKey, true);
    await _refreshGameServices();

    state.value = const AccountSessionState(
      mode: AccountMode.guest,
      firebaseReady: true,
    );
  }

  Future<void> _refreshGameServices() async {
    try {
      await XpProgressService.initialize();
    } catch (_) {}

    try {
      await GameplayBoostSettingsService.initialize();
    } catch (_) {}

    try {
      await RetentionProgressService.initialize();
    } catch (_) {}

    try {
      await VisualCollectionService.initialize();
    } catch (_) {}

    try {
      await AppPreferencesService.initialize();
    } catch (_) {}
  }

  String _friendlyError(Object error) {
    final text = error.toString().toLowerCase();

    if (text.contains('canceled') ||
        text.contains('cancelled') ||
        text.contains('iptal')) {
      return 'Google girişi iptal edildi.';
    }

    if (text.contains('network') ||
        text.contains('socket') ||
        text.contains('timeout')) {
      return 'İnternet bağlantısı kurulamadı.';
    }

    return 'Google hesabı bağlanamadı. '
        'Biraz sonra yeniden deneyebilirsin.';
  }

  String _userSnapshotKey(String uid) {
    return 'bilgi_rotasi_account_user_snapshot_$uid';
  }

  String _userDirtyKey(String uid) {
    return 'bilgi_rotasi_account_user_dirty_$uid';
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState lifecycleState,
  ) {
    if (lifecycleState == AppLifecycleState.inactive ||
        lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.detached) {
      unawaited(_syncNow(manual: false));
    }
  }
}

class AccountGate extends StatelessWidget {
  const AccountGate({
    required this.questionBank,
    super.key,
  });

  final QuestionBank questionBank;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AccountSessionState>(
      valueListenable: AccountCloudService.state,
      builder: (context, session, _) {
        if (session.mode == AccountMode.undecided) {
          return const AccountWelcomeScreen();
        }

        return HomeScreen(
          key: ValueKey<String>(session.sessionKey),
          questionBank: questionBank,
        );
      },
    );
  }
}

class AccountWelcomeScreen extends StatelessWidget {
  const AccountWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AccountSessionState>(
      valueListenable: AccountCloudService.state,
      builder: (context, session, _) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
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
                    constraints:
                        const BoxConstraints(maxWidth: 520),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/branding/splash_logo.png',
                          width: 116,
                          height: 116,
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'BİLGİ ROTASI',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'İlerlemeni bu telefonda tutabilir '
                          'veya Google hesabınla buluta '
                          'yedekleyebilirsin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFD7F6F2),
                            height: 1.45,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 26),
                        FilledButton.icon(
                          onPressed:
                              session.busy ||
                                      !session.firebaseReady
                                  ? null
                                  : AccountCloudService
                                      .signInWithGoogle,
                          icon: session.busy
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                  ),
                                )
                              : const Icon(
                                  Icons.account_circle_rounded,
                                ),
                          label: const Text(
                            'Google ile giriş yap',
                          ),
                        ),
                        const SizedBox(height: 11),
                        OutlinedButton.icon(
                          onPressed: session.busy
                              ? null
                              : AccountCloudService
                                  .continueAsGuest,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: Color(0x88FFFFFF),
                            ),
                            minimumSize:
                                const Size.fromHeight(54),
                          ),
                          icon: const Icon(
                            Icons.person_outline_rounded,
                          ),
                          label: const Text(
                            'Misafir olarak devam et',
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Misafir kullanımında Günlük Görev '
                          'gösterilmez ve ilerleme yalnızca '
                          'bu telefonda saklanır.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFB9AEC2),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        if (session.message != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            session.message!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFFFD27A),
                              fontWeight: FontWeight.w700,
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
        );
      },
    );
  }
}

class AccountSummaryCard extends StatelessWidget {
  const AccountSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AccountSessionState>(
      valueListenable: AccountCloudService.state,
      builder: (context, session, _) {
        final signedIn = session.signedIn;
        final user = session.user;
        final title = signedIn
            ? (user?.displayName?.trim().isNotEmpty == true
                ? user!.displayName!
                : 'Google hesabı')
            : 'Misafir';
        final subtitle = signedIn
            ? (user?.email ?? 'Bulut kaydı etkin')
            : 'İlerleme yalnızca bu telefonda';

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: const Color(0x16FFFFFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: signedIn
                  ? const Color(0x665EEAD4)
                  : const Color(0x44FFFFFF),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: signedIn
                      ? const Color(0x2232D5C5)
                      : const Color(0x22FFFFFF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  signedIn
                      ? Icons.cloud_done_rounded
                      : Icons.person_outline_rounded,
                  color: signedIn
                      ? const Color(0xFF67E8D8)
                      : Colors.white,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFCFC6D6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (session.busy)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.3,
                    color: Color(0xFFFFE082),
                  ),
                )
              else
                TextButton(
                  onPressed: signedIn
                      ? AccountCloudService.syncNow
                      : session.firebaseReady
                          ? AccountCloudService
                              .signInWithGoogle
                          : null,
                  child: Text(
                    signedIn ? 'Eşitle' : 'Giriş yap',
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AccountSessionState>(
      valueListenable: AccountCloudService.state,
      builder: (context, session, _) {
        final signedIn = session.signedIn;
        final user = session.user;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Hesap & Bulut Kaydı'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              14,
              16,
              28,
            ),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Icon(
                        signedIn
                            ? Icons.cloud_done_rounded
                            : Icons.person_outline_rounded,
                        size: 54,
                        color: const Color(0xFF155E75),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        signedIn
                            ? (user?.displayName ??
                                'Google hesabı')
                            : 'Misafir kullanıcı',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (signedIn && user?.email != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          user!.email!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Text(
                        signedIn
                            ? 'XP, başarımlar, kayıtlı oyun, '
                                'temalar ve tercihler buluta '
                                'yedeklenir.'
                            : 'İlerleme yalnızca bu telefonda '
                                'saklanır. Günlük Görev '
                                'gösterilmez.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      if (signedIn) ...[
                        FilledButton.icon(
                          onPressed: session.busy
                              ? null
                              : AccountCloudService.syncNow,
                          icon: const Icon(
                            Icons.sync_rounded,
                          ),
                          label: const Text(
                            'Şimdi eşitle',
                          ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: session.busy
                              ? null
                              : AccountCloudService.signOut,
                          icon: const Icon(
                            Icons.logout_rounded,
                          ),
                          label: const Text(
                            'Hesaptan çık',
                          ),
                        ),
                      ] else
                        FilledButton.icon(
                          onPressed: session.busy ||
                                  !session.firebaseReady
                              ? null
                              : AccountCloudService
                                  .signInWithGoogle,
                          icon: const Icon(
                            Icons.account_circle_rounded,
                          ),
                          label: const Text(
                            'Google ile giriş yap',
                          ),
                        ),
                      if (session.message != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          session.message!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFB45309),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Hesaptan çıkıldığında Google hesabına '
                    'ait kayıt bulutta kalır ve telefondaki '
                    'misafir kaydı geri yüklenir. Böylece '
                    'hesapların ilerlemeleri birbirine '
                    'karışmaz.',
                    style: TextStyle(height: 1.45),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GuestDailyLockedScreen extends StatelessWidget {
  const GuestDailyLockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Günlük Görev')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🔐',
                  style: TextStyle(fontSize: 64),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Günlük Görev için hesap gerekli',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Google hesabınla giriş yaptığında '
                  'Günlük Görev ve bulut kaydı açılır.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed:
                      AccountCloudService.signInWithGoogle,
                  icon: const Icon(
                    Icons.account_circle_rounded,
                  ),
                  label: const Text(
                    'Google ile giriş yap',
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
