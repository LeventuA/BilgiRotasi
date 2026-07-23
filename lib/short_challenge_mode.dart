part of 'main.dart';

class ShortChallengeCodeService {
  ShortChallengeCodeService._();

  static const int questionCount = 10;
  static const int targetScore = 7;

  static String generate([Random? random]) {
    final source = random ?? Random.secure();
    final number = 1000 + source.nextInt(9000);
    return 'BR$number';
  }

  static String normalize(String raw) {
    var cleaned = raw
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]'), '');

    if (RegExp(r'^\d{4}$').hasMatch(cleaned)) {
      cleaned = 'BR$cleaned';
    }

    if (!RegExp(r'^BR\d{4}$').hasMatch(cleaned)) {
      throw const FormatException(
        'Kod BR1905 gibi BR ve dört rakamdan oluşmalı.',
      );
    }

    return cleaned;
  }

  static bool isValid(String raw) {
    try {
      normalize(raw);
      return true;
    } on FormatException {
      return false;
    }
  }

  static int stableHash(String value) {
    var hash = 0x811C9DC5;

    for (final byte in utf8.encode(value)) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }

    return hash;
  }

  static List<QuizQuestion> selectQuestions(
    QuestionBank questionBank,
    String rawCode,
  ) {
    final code = normalize(rawCode);
    final questions = questionBank.questionsByCategory.values
        .expand((items) => items)
        .toList(growable: false);

    final ranked = List<QuizQuestion>.from(questions)
      ..sort((a, b) {
        final aHash = stableHash('$code|${a.id}');
        final bHash = stableHash('$code|${b.id}');
        final hashOrder = aHash.compareTo(bHash);

        if (hashOrder != 0) return hashOrder;
        return a.id.compareTo(b.id);
      });

    return ranked.take(questionCount).toList(growable: false);
  }

  static ChallengeConfig buildConfig({
    required QuestionBank questionBank,
    required String rawCode,
    required String challengerName,
  }) {
    final code = normalize(rawCode);
    final questions = selectQuestions(questionBank, code);

    if (questions.length < questionCount) {
      throw const FormatException(
        'Meydan okuma için yeterli soru bulunamadı.',
      );
    }

    final cleanName = challengerName.trim();

    return ChallengeConfig(
      challengerName: cleanName.isEmpty ? 'Bir oyuncu' : cleanName,
      targetScore: targetScore,
      categoryIndex: -1,
      difficulty: 'Karışık',
      questionIds: questions
          .map((question) => question.id)
          .toList(growable: false),
      shortCode: code,
    );
  }
}

class ShortChallengeModeScreen extends StatefulWidget {
  const ShortChallengeModeScreen({
    required this.questionBank,
    super.key,
  });

  final QuestionBank questionBank;

  @override
  State<ShortChallengeModeScreen> createState() =>
      _ShortChallengeModeScreenState();
}

class _ShortChallengeModeScreenState
    extends State<ShortChallengeModeScreen> {
  late String _generatedCode;
  final TextEditingController _joinController =
      TextEditingController();
  String? _error;

  String get _playerName {
    final name =
        AppPreferencesService.current.defaultPlayerName.trim();
    return name.isEmpty ? 'Bir oyuncu' : name;
  }

  @override
  void initState() {
    super.initState();
    _generatedCode = ShortChallengeCodeService.generate();
  }

  @override
  void dispose() {
    _joinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Color(0xFF5B2167),
              Color(0xFF0F5661),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
            children: [
              _hero(),
              const SizedBox(height: 15),
              _createCard(),
              const SizedBox(height: 14),
              _joinCard(),
              const SizedBox(height: 14),
              const Text(
                'Aynı kısa kod, aynı APK sürümünde iki telefonda da '
                'aynı 10 soruyu aynı sırayla açar. Hedef skor 7 doğrudur.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFD8CCEA),
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF7C3AED),
            Color(0xFFBE185D),
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
            '🎯⚔️',
            style: TextStyle(fontSize: 54),
          ),
          SizedBox(height: 8),
          Text(
            'Kısa kodla aynı sorularda yarış',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Oyun otomatik BR1905 gibi kısa bir kod üretir. '
            'Kodu diğer telefona gönder; ikiniz de aynı bilgi turunu oynayın.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFEDE9FE),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _createCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFFC4B5FD),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Yeni meydan okuma',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Meydan okuyan: $_playerName',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[
                  Color(0xFFF3E8FF),
                  Color(0xFFE0F2FE),
                ],
              ),
              borderRadius: BorderRadius.circular(21),
              border: Border.all(
                color: const Color(0xFF7C3AED),
                width: 2,
              ),
            ),
            child: SelectableText(
              _generatedCode,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF4C1D95),
                fontSize: 35,
                letterSpacing: 4,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _newCode,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Yeni Kod'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyCode,
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Kopyala'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _shareCode,
            icon: const Icon(Icons.share_rounded),
            label: const Text(
              'Kodu Paylaş',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => _start(
              _generatedCode,
              challengerName: _playerName,
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0F766E),
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text(
              'Bu Kodla Oyna',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _joinCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFF67E8F9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Gelen kodla yarış',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _joinController,
            maxLength: 6,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) {
              if (_error != null) {
                setState(() => _error = null);
              }
            },
            decoration: InputDecoration(
              counterText: '',
              labelText: 'BR1905 gibi kısa kod',
              hintText: 'BR1905',
              prefixIcon: const Icon(Icons.password_rounded),
              border: const OutlineInputBorder(),
              errorText: _error,
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _openIncomingCode,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFBE185D),
            ),
            icon: const Icon(Icons.sports_esports_rounded),
            label: const Text(
              'Kodu Aç ve Yarış',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  void _newCode() {
    setState(() {
      _generatedCode = ShortChallengeCodeService.generate();
      _error = null;
    });
    GameHaptics.selectionClick();
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(
      ClipboardData(text: _generatedCode),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Kısa meydan okuma kodu kopyalandı.'),
        ),
      );
  }

  Future<void> _shareCode() {
    return SocialShareService.shareText(
      context,
      title: 'Bilgi Rotası Meydan Okuması',
      text: <String>[
        '🧭 BİLGİ ROTASI MEYDAN OKUMASI',
        '$_playerName sana meydan okuyor!',
        '',
        'Kod: $_generatedCode',
        '10 karışık soru • Hedef 7 doğru',
        '',
        'Bilgi Rotası uygulamasında Oyna > Meydan Okuma bölümüne gir.',
      ].join('\n'),
    );
  }

  void _openIncomingCode() {
    _start(
      _joinController.text,
      challengerName: 'Kod sahibi',
    );
  }

  void _start(
    String rawCode, {
    required String challengerName,
  }) {
    try {
      final code = ShortChallengeCodeService.normalize(rawCode);
      final questions = ShortChallengeCodeService.selectQuestions(
        widget.questionBank,
        code,
      );

      if (questions.length < ShortChallengeCodeService.questionCount) {
        throw const FormatException(
          'Bu sürümde meydan okuma için yeterli soru yok.',
        );
      }

      final challenge = ChallengeConfig(
        challengerName: challengerName,
        targetScore: ShortChallengeCodeService.targetScore,
        categoryIndex: -1,
        difficulty: 'Karışık',
        questionIds: questions
            .map((question) => question.id)
            .toList(growable: false),
        shortCode: code,
      );

      setState(() => _error = null);
      GameHaptics.mediumImpact();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChallengeGameScreen(
            questionBank: widget.questionBank,
            challenge: challenge,
            questions: questions,
          ),
        ),
      );
    } on FormatException catch (error) {
      setState(() {
        _error = error.message.toString();
      });
    } catch (_) {
      setState(() {
        _error = 'Kod açılamadı. BR1905 biçimini kontrol et.';
      });
    }
  }
}
