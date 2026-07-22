part of 'main.dart';

class AppErrorEntry {
  const AppErrorEntry({
    required this.time,
    required this.source,
    required this.message,
    required this.stack,
  });

  final DateTime time;
  final String source;
  final String message;
  final String stack;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'time': time.toIso8601String(),
        'source': source,
        'message': message,
        'stack': stack,
      };

  factory AppErrorEntry.fromJson(
    Map<String, dynamic> json,
  ) {
    return AppErrorEntry(
      time: DateTime.tryParse(
            json['time']?.toString() ?? '',
          ) ??
          DateTime.now(),
      source: json['source']?.toString() ?? 'Bilinmeyen',
      message: json['message']?.toString() ?? 'Bilinmeyen hata',
      stack: json['stack']?.toString() ?? '',
    );
  }
}

class AppErrorLogService {
  AppErrorLogService._();

  static const String _key =
      'bilgi_rotasi_error_log_v1';

  static final SharedPreferencesAsync _prefs =
      SharedPreferencesAsync();

  static final ValueNotifier<int> revision =
      ValueNotifier<int>(0);

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    FlutterError.onError = (details) {
      FlutterError.presentError(details);

      unawaited(
        record(
          source: 'Flutter',
          error: details.exception,
          stack: details.stack,
        ),
      );
    };

    ui.PlatformDispatcher.instance.onError =
        (error, stack) {
      unawaited(
        record(
          source: 'Platform',
          error: error,
          stack: stack,
        ),
      );

      return false;
    };

    ErrorWidget.builder = (details) {
      unawaited(
        record(
          source: 'Arayüz',
          error: details.exception,
          stack: details.stack,
        ),
      );

      return SystemErrorFallback(details: details);
    };
  }

  static Future<void> record({
    required String source,
    required Object error,
    StackTrace? stack,
  }) async {
    try {
      final entries = await load();

      entries.insert(
        0,
        AppErrorEntry(
          time: DateTime.now(),
          source: source,
          message: _trim(error.toString(), 1200),
          stack: _trim(stack?.toString() ?? '', 2400),
        ),
      );

      if (entries.length > 20) {
        entries.removeRange(20, entries.length);
      }

      await _prefs.setString(
        _key,
        jsonEncode(
          entries.map((entry) => entry.toJson()).toList(),
        ),
      );

      revision.value++;
    } catch (_) {
      // Hata kaydı kendi başına yeni hata oluşturmamalı.
    }
  }

  static Future<List<AppErrorEntry>> load() async {
    try {
      final raw = await _prefs.getString(_key);

      if (raw == null || raw.trim().isEmpty) {
        return <AppErrorEntry>[];
      }

      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        return <AppErrorEntry>[];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => AppErrorEntry.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (_) {
      return <AppErrorEntry>[];
    }
  }

  static Future<void> clear() async {
    try {
      await _prefs.remove(_key);
      revision.value++;
    } catch (_) {
      // Hata geçmişi temizlenemese bile ekran açık kalmalı.
    }
  }

  static String _trim(String value, int maxLength) {
    if (value.length <= maxLength) return value;
    return '${value.substring(0, maxLength)}…';
  }
}

class SystemErrorFallback extends StatelessWidget {
  const SystemErrorFallback({
    required this.details,
    super.key,
  });

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 430,
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFFCA5A5),
              ),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🛠️',
                  style: TextStyle(fontSize: 54),
                ),
                SizedBox(height: 10),
                Text(
                  'Bu bölüm görüntülenemedi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Hata teknik günlüğe kaydedildi. '
                  'Geri dönüp oyuna devam edebilirsin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    height: 1.4,
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

class GameRecoveryService {
  GameRecoveryService._();

  static const String backupKey =
      'bilgi_rotasi_saved_game_backup_v1';

  static Future<void> saveWithBackup(
    String encoded,
  ) async {
    final previous =
        await GameSaveService._preferences.getString(
      GameSaveService._saveKey,
    );

    if (previous != null && previous.trim().isNotEmpty) {
      await GameSaveService._preferences.setString(
        backupKey,
        previous,
      );
    }

    await GameSaveService._preferences.setString(
      GameSaveService._saveKey,
      encoded,
    );

    if (previous == null || previous.trim().isEmpty) {
      await GameSaveService._preferences.setString(
        backupKey,
        encoded,
      );
    }
  }

  static Future<bool> hasBackup() async {
    try {
      final raw =
          await GameSaveService._preferences.getString(
        backupKey,
      );

      return raw != null && raw.trim().isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<SavedGame?> recover() async {
    try {
      final raw =
          await GameSaveService._preferences.getString(
        backupKey,
      );

      if (raw == null || raw.trim().isEmpty) {
        return null;
      }

      final recovered = _decode(raw);

      if (recovered == null) {
        return null;
      }

      await GameSaveService._preferences.setString(
        GameSaveService._saveKey,
        raw,
      );

      return recovered;
    } catch (error, stack) {
      await AppErrorLogService.record(
        source: 'Kayıt kurtarma',
        error: error,
        stack: stack,
      );

      return null;
    }
  }

  static Future<bool> restoreBackup() async {
    return await recover() != null;
  }

  static Future<void> clearBackup() async {
    try {
      await GameSaveService._preferences.remove(
        backupKey,
      );
    } catch (_) {
      // Yedek temizleme sorunu oyunu kilitlememeli.
    }
  }

  static SavedGame? _decode(String raw) {
    final decoded = jsonDecode(raw);

    if (decoded is! Map) {
      return null;
    }

    final map = Map<String, dynamic>.from(decoded);
    final rawPlayers = map['players'];

    if (rawPlayers is! List || rawPlayers.isEmpty) {
      return null;
    }

    final players = <PlayerData>[];

    for (final item in rawPlayers) {
      if (item is Map) {
        players.add(
          GameSaveService._playerFromJson(
            Map<String, dynamic>.from(item),
          ),
        );
      }
    }

    if (players.isEmpty) return null;

    final rawIndex =
        (map['currentPlayerIndex'] as num?)?.toInt() ?? 0;

    final currentPlayerIndex = rawIndex
        .clamp(0, players.length - 1)
        .toInt();

    final savedAt = DateTime.tryParse(
          map['savedAt']?.toString() ?? '',
        ) ??
        DateTime.now();

    final usedQuestionIds = <String>{};
    final rawUsed = map['usedQuestionIds'];

    if (rawUsed is List) {
      usedQuestionIds.addAll(
        rawUsed
            .map((value) => value.toString())
            .where((value) => value.isNotEmpty),
      );
    }

    return SavedGame(
      players: players,
      currentPlayerIndex: currentPlayerIndex,
      savedAt: savedAt,
      usedQuestionIds: usedQuestionIds,
    );
  }
}

class QuestionHealthReport {
  const QuestionHealthReport({
    required this.total,
    required this.categoryCounts,
    required this.difficultyCounts,
    required this.duplicateIds,
    required this.duplicateTexts,
    required this.invalidItems,
    required this.emptyExplanations,
    required this.fingerprint,
  });

  final int total;
  final List<int> categoryCounts;
  final Map<String, int> difficultyCounts;
  final int duplicateIds;
  final int duplicateTexts;
  final int invalidItems;
  final int emptyExplanations;
  final String fingerprint;

  bool get healthy =>
      total > 0 && duplicateIds == 0 && invalidItems == 0;

  int get warningCount =>
      duplicateTexts + emptyExplanations;

  factory QuestionHealthReport.fromBank(
    QuestionBank bank,
  ) {
    final questions = bank.questionsByCategory.values
        .expand((items) => items)
        .toList(growable: false);

    final categoryCounts = List<int>.filled(
      GameCategory.values.length,
      0,
    );

    final difficulties = <String, int>{
      'Kolay': 0,
      'Orta': 0,
      'Zor': 0,
      'Diğer': 0,
    };

    final ids = <String>{};
    final texts = <String>{};

    var duplicateIds = 0;
    var duplicateTexts = 0;
    var invalidItems = 0;
    var emptyExplanations = 0;
    var hash = 0x811C9DC5;

    for (final question in questions) {
      final id = question.id.trim();
      final text = question.text.trim();
      final normalizedText = text
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), ' ');

      if (id.isEmpty || !ids.add(id)) {
        duplicateIds++;
      }

      if (normalizedText.isNotEmpty &&
          !texts.add(normalizedText)) {
        duplicateTexts++;
      }

      final categoryValid =
          question.categoryIndex >= 0 &&
              question.categoryIndex <
                  GameCategory.values.length;

      if (categoryValid) {
        categoryCounts[question.categoryIndex]++;
      }

      final optionsValid =
          question.options.length == 4 &&
              question.options.every(
                (option) => option.trim().isNotEmpty,
              );

      final answerValid =
          question.answerIndex >= 0 &&
              question.answerIndex <
                  question.options.length;

      final difficulty =
          question.difficulty.trim();

      if (difficulties.containsKey(difficulty)) {
        difficulties[difficulty] =
            difficulties[difficulty]! + 1;
      } else {
        difficulties['Diğer'] =
            difficulties['Diğer']! + 1;
      }

      if (question.explanation.trim().isEmpty) {
        emptyExplanations++;
      }

      if (id.isEmpty ||
          text.isEmpty ||
          !categoryValid ||
          !optionsValid ||
          !answerValid ||
          !<String>{
            'Kolay',
            'Orta',
            'Zor',
          }.contains(difficulty)) {
        invalidItems++;
      }

      for (final unit in id.codeUnits) {
        hash ^= unit;
        hash = (hash * 0x01000193) & 0xFFFFFFFF;
      }
    }

    return QuestionHealthReport(
      total: questions.length,
      categoryCounts: categoryCounts,
      difficultyCounts: difficulties,
      duplicateIds: duplicateIds,
      duplicateTexts: duplicateTexts,
      invalidItems: invalidItems,
      emptyExplanations: emptyExplanations,
      fingerprint:
          hash.toRadixString(16).padLeft(8, '0').toUpperCase(),
    );
  }

  String shareText({
    required bool hasSave,
    required bool hasBackup,
    required int errorCount,
  }) {
    return <String>[
      '🛠️ BİLGİ ROTASI TEKNİK RAPORU',
      'Sürüm 1.29.0+38',
      '',
      healthy
          ? '✅ Soru bankası yapısal olarak sağlıklı'
          : '❌ Soru bankasında kritik sorun var',
      '📝 $total soru',
      '🔐 Banka kimliği: BRQ-$fingerprint',
      '🚫 Geçersiz kayıt: $invalidItems',
      '🆔 Yinelenen kimlik: $duplicateIds',
      '⚠️ Uyarı: $warningCount',
      '💾 Aktif kayıt: ${hasSave ? 'Var' : 'Yok'}',
      '🛟 Kurtarma yedeği: ${hasBackup ? 'Var' : 'Yok'}',
      '🐞 Teknik hata günlüğü: $errorCount kayıt',
    ].join('\n');
  }
}

class SystemHealthSnapshot {
  const SystemHealthSnapshot({
    required this.report,
    required this.hasSave,
    required this.hasBackup,
    required this.errors,
  });

  final QuestionHealthReport report;
  final bool hasSave;
  final bool hasBackup;
  final List<AppErrorEntry> errors;
}

class SystemHealthHomeButton extends StatelessWidget {
  const SystemHealthHomeButton({
    required this.questionBank,
    super.key,
  });

  final QuestionBank questionBank;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SystemHealthScreen(
              questionBank: questionBank,
            ),
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(
          color: Color(0x997DE3FC),
        ),
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      icon: const Icon(
        Icons.health_and_safety_rounded,
      ),
      label: const Text(
        'Sistem Sağlığı & Teknik Kontrol',
        style: TextStyle(
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class SystemHealthScreen extends StatefulWidget {
  const SystemHealthScreen({
    required this.questionBank,
    super.key,
  });

  final QuestionBank questionBank;

  @override
  State<SystemHealthScreen> createState() =>
      _SystemHealthScreenState();
}

class _SystemHealthScreenState
    extends State<SystemHealthScreen> {
  late Future<SystemHealthSnapshot> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = _load();
  }

  Future<SystemHealthSnapshot> _load() async {
    final report = QuestionHealthReport.fromBank(
      widget.questionBank,
    );

    final savedGame = await GameSaveService.load();
    final hasBackup =
        await GameRecoveryService.hasBackup();
    final errors = await AppErrorLogService.load();

    return SystemHealthSnapshot(
      report: report,
      hasSave: savedGame != null,
      hasBackup: hasBackup,
      errors: errors,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sistem Sağlığı',
        ),
      ),
      body: FutureBuilder<SystemHealthSnapshot>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              18,
              16,
              18,
              28,
            ),
            children: [
              _hero(data.report),
              const SizedBox(height: 15),
              _questionCard(data.report),
              const SizedBox(height: 12),
              _saveCard(data),
              const SizedBox(height: 12),
              _performanceCard(),
              const SizedBox(height: 12),
              _errorCard(data.errors),
              const SizedBox(height: 14),
              SocialShareButton(
                title: 'Bilgi Rotası Teknik Raporu',
                text: data.report.shareText(
                  hasSave: data.hasSave,
                  hasBackup: data.hasBackup,
                  errorCount: data.errors.length,
                ),
              ),
              const SizedBox(height: 9),
              OutlinedButton.icon(
                onPressed: () {
                  setState(_reload);
                },
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: const Text(
                  'Kontrolleri Yenile',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _hero(QuestionHealthReport report) {
    final healthy = report.healthy;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: healthy
              ? const <Color>[
                  Color(0xFF047857),
                  Color(0xFF155E75),
                ]
              : const <Color>[
                  Color(0xFFB91C1C),
                  Color(0xFF7C2D12),
                ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Text(
            healthy ? '✅🛡️' : '⚠️🛠️',
            style: const TextStyle(fontSize: 54),
          ),
          const SizedBox(height: 8),
          Text(
            healthy
                ? 'Sistem sağlıklı görünüyor'
                : 'Teknik kontrol gerekli',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sürüm 1.29.0+38 • '
            'Banka BRQ-${report.fingerprint}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFD8F4EE),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _questionCard(
    QuestionHealthReport report,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            const Text(
              '📝 Soru bankası doğrulaması',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            _statusRow(
              'Toplam soru',
              '${report.total}',
              report.total > 0,
            ),
            _statusRow(
              'Geçersiz kayıt',
              '${report.invalidItems}',
              report.invalidItems == 0,
            ),
            _statusRow(
              'Yinelenen soru kimliği',
              '${report.duplicateIds}',
              report.duplicateIds == 0,
            ),
            _statusRow(
              'Benzer soru metni uyarısı',
              '${report.duplicateTexts}',
              true,
              warning:
                  report.duplicateTexts > 0,
            ),
            _statusRow(
              'Boş açıklama uyarısı',
              '${report.emptyExplanations}',
              true,
              warning:
                  report.emptyExplanations > 0,
            ),
            const Divider(height: 24),
            for (var index = 0;
                index < GameCategory.values.length;
                index++)
              Padding(
                padding:
                    const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Text(
                      GameCategory.values[index].emoji,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        GameCategory
                            .values[index].label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${report.categoryCounts[index]}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _saveCard(SystemHealthSnapshot data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            const Text(
              '💾 Kayıt ve kurtarma',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 11),
            _statusRow(
              'Aktif kayıtlı oyun',
              data.hasSave ? 'Var' : 'Yok',
              true,
            ),
            _statusRow(
              'Otomatik kurtarma yedeği',
              data.hasBackup ? 'Hazır' : 'Henüz yok',
              true,
              warning: !data.hasBackup,
            ),
            if (data.hasBackup) ...[
              const SizedBox(height: 11),
              FilledButton.icon(
                onPressed: _restoreBackup,
                icon: const Icon(
                  Icons.restore_rounded,
                ),
                label: const Text(
                  'Kurtarma Yedeğini Geri Yükle',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _performanceCard() {
    final minimal =
        AppPreferencesService.current.animationMode ==
            'minimal';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            const Text(
              '⚡ Performans araçları',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              minimal
                  ? 'Performans modu açık: ağır '
                      'animasyonlar ve canlı tahta kapalı.'
                  : 'Normal görünüm açık. Takılma yaşanırsa '
                      'performans modunu etkinleştir.',
              style: const TextStyle(
                color: Color(0xFF64748B),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 11),
            FilledButton.icon(
              onPressed: () => _setPerformance(
                minimal ? 'full' : 'minimal',
              ),
              icon: Icon(
                minimal
                    ? Icons.auto_awesome_rounded
                    : Icons.bolt_rounded,
              ),
              label: Text(
                minimal
                    ? 'Normal Görünüme Dön'
                    : 'Performans Modunu Aç',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _clearImageCache,
              icon: const Icon(
                Icons.cleaning_services_rounded,
              ),
              label: const Text(
                'Görüntü Önbelleğini Temizle',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorCard(
    List<AppErrorEntry> errors,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '🐞 Teknik hata günlüğü',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '${errors.length}/20',
                  style: const TextStyle(
                    color: Color(0xFF7C3AED),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            if (errors.isEmpty)
              const Text(
                'Kayıtlı teknik hata yok. ✅',
                style: TextStyle(
                  color: Color(0xFF15803D),
                  fontWeight: FontWeight.w800,
                ),
              )
            else
              for (final error in errors.take(5))
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding:
                      const EdgeInsets.fromLTRB(
                    8,
                    0,
                    8,
                    12,
                  ),
                  leading: const Text('⚠️'),
                  title: Text(
                    error.source,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle: Text(
                    _dateLabel(error.time),
                    style: const TextStyle(
                      fontSize: 11,
                    ),
                  ),
                  children: [
                    SelectableText(
                      error.message,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                    if (error.stack.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SelectableText(
                        error.stack,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
            if (errors.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _clearErrors,
                style: TextButton.styleFrom(
                  foregroundColor:
                      const Color(0xFFB91C1C),
                ),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                ),
                label: const Text(
                  'Hata Günlüğünü Temizle',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusRow(
    String label,
    String value,
    bool okay, {
    bool warning = false,
  }) {
    final icon = warning
        ? '⚠️'
        : okay
            ? '✅'
            : '❌';

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Text(icon),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label),
          ),
          Text(
            value,
            style: TextStyle(
              color: warning
                  ? const Color(0xFFB45309)
                  : okay
                      ? const Color(0xFF15803D)
                      : const Color(0xFFB91C1C),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreBackup() async {
    final restored =
        await GameRecoveryService.restoreBackup();

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            restored
                ? 'Kurtarma yedeği aktif kayıt olarak geri yüklendi.'
                : 'Kurtarma yedeği okunamadı.',
          ),
        ),
      );

    setState(_reload);
  }

  Future<void> _setPerformance(
    String mode,
  ) async {
    await AppPreferencesService.setAnimationMode(mode);

    if (!mounted) return;

    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mode == 'minimal'
              ? 'Performans modu etkinleştirildi.'
              : 'Normal görünüm yeniden etkinleştirildi.',
        ),
      ),
    );
  }

  void _clearImageCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Görüntü önbelleği temizlendi.',
        ),
      ),
    );
  }

  Future<void> _clearErrors() async {
    await AppErrorLogService.clear();

    if (mounted) {
      setState(_reload);
    }
  }

  String _dateLabel(DateTime value) {
    String two(int number) =>
        number.toString().padLeft(2, '0');

    return '${two(value.day)}.${two(value.month)}.'
        '${value.year} ${two(value.hour)}:${two(value.minute)}';
  }
}
