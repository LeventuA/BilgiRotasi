#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

MAIN = Path("lib/main.dart")
GAME_UI = Path("lib/game_ui_polish.dart")
NAV = Path("lib/main_navigation.dart")
SOCIAL = Path("lib/social_features.dart")
PUBSPEC = Path("pubspec.yaml")
TEST = Path("test/system_smoke_test.dart")
DICE_TARGET = Path("lib/premium_dice.dart")
CHALLENGE_TARGET = Path("lib/short_challenge_mode.dart")

PREMIUM_DICE_CONTENT = "part of 'main.dart';\n\nclass PremiumDiceModel {\n  PremiumDiceModel._();\n\n  static int pipCount(int? value) {\n    if (value == null) return 0;\n    return value.clamp(1, 6).toInt();\n  }\n\n  static bool isLuckySix(int? value) => value == 6;\n}\n\nclass PremiumDiceFace extends StatefulWidget {\n  const PremiumDiceFace({\n    required this.value,\n    required this.rolling,\n    this.size = 62,\n    super.key,\n  });\n\n  final int? value;\n  final bool rolling;\n  final double size;\n\n  @override\n  State<PremiumDiceFace> createState() => _PremiumDiceFaceState();\n}\n\nclass _PremiumDiceFaceState extends State<PremiumDiceFace>\n    with SingleTickerProviderStateMixin {\n  late final AnimationController _controller;\n\n  bool get _minimal =>\n      AppPreferencesService.current.animationMode == 'minimal';\n\n  @override\n  void initState() {\n    super.initState();\n    _controller = AnimationController(\n      vsync: this,\n      duration: Duration(milliseconds: _minimal ? 230 : 620),\n      value: widget.rolling ? 0 : 1,\n    );\n    _syncAnimation();\n  }\n\n  @override\n  void didUpdateWidget(covariant PremiumDiceFace oldWidget) {\n    super.didUpdateWidget(oldWidget);\n\n    if (oldWidget.rolling != widget.rolling) {\n      _syncAnimation();\n      return;\n    }\n\n    if (oldWidget.value != widget.value) {\n      if (widget.rolling && !_minimal) {\n        if (!_controller.isAnimating) {\n          _controller.repeat();\n        }\n      } else {\n        _controller.forward(from: 0);\n      }\n    }\n  }\n\n  void _syncAnimation() {\n    if (widget.rolling) {\n      if (_minimal) {\n        _controller.forward(from: 0);\n      } else {\n        _controller.repeat();\n      }\n    } else {\n      _controller.stop();\n      _controller.forward(from: 0);\n    }\n  }\n\n  @override\n  void dispose() {\n    _controller.dispose();\n    super.dispose();\n  }\n\n  @override\n  Widget build(BuildContext context) {\n    final theme = VisualCollectionService.theme;\n\n    return AnimatedBuilder(\n      animation: _controller,\n      builder: (context, _) {\n        final t = _controller.value;\n        final rollingTurn = widget.rolling ? t * pi * 2 : 0.0;\n        final settle = widget.rolling ? 0.0 : sin(pi * t);\n        final scale = widget.rolling\n            ? 0.92 + sin(t * pi * 2).abs() * 0.10\n            : 1 + settle * 0.13;\n\n        return SizedBox.square(\n          dimension: widget.size * 1.42,\n          child: Stack(\n            alignment: Alignment.center,\n            clipBehavior: Clip.none,\n            children: [\n              if (PremiumDiceModel.isLuckySix(widget.value) &&\n                  !widget.rolling)\n                Positioned.fill(\n                  child: IgnorePointer(\n                    child: CustomPaint(\n                      painter: PremiumDiceSixBurstPainter(\n                        progress: t,\n                        color: theme.gold,\n                      ),\n                    ),\n                  ),\n                ),\n              Transform.rotate(\n                angle: rollingTurn + settle * 0.10,\n                child: Transform(\n                  alignment: Alignment.center,\n                  transform: Matrix4.identity()\n                    ..setEntry(3, 2, 0.0015)\n                    ..rotateX(\n                      widget.rolling\n                          ? sin(t * pi * 2) * 0.52\n                          : settle * 0.08,\n                    )\n                    ..rotateY(\n                      widget.rolling\n                          ? cos(t * pi * 2) * 0.52\n                          : -settle * 0.07,\n                    )\n                    ..scale(scale),\n                  child: CustomPaint(\n                    size: Size.square(widget.size),\n                    painter: PremiumDicePainter(\n                      value: widget.value,\n                      rolling: widget.rolling,\n                      primary: theme.backgroundColors.first,\n                      secondary: theme.centerColors.first,\n                      accent: theme.gold,\n                    ),\n                  ),\n                ),\n              ),\n            ],\n          ),\n        );\n      },\n    );\n  }\n}\n\nclass PremiumDicePainter extends CustomPainter {\n  const PremiumDicePainter({\n    required this.value,\n    required this.rolling,\n    required this.primary,\n    required this.secondary,\n    required this.accent,\n  });\n\n  final int? value;\n  final bool rolling;\n  final Color primary;\n  final Color secondary;\n  final Color accent;\n\n  @override\n  void paint(Canvas canvas, Size size) {\n    final rect = Offset.zero & size;\n    final radius = Radius.circular(size.width * 0.23);\n    final body = RRect.fromRectAndRadius(rect.deflate(size.width * 0.045), radius);\n\n    canvas.drawRRect(\n      body.shift(Offset(0, size.height * 0.075)),\n      Paint()\n        ..color = const Color(0x66000000)\n        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),\n    );\n\n    canvas.drawRRect(\n      body,\n      Paint()\n        ..shader = LinearGradient(\n          begin: Alignment.topLeft,\n          end: Alignment.bottomRight,\n          colors: <Color>[\n            Color.lerp(primary, Colors.white, 0.52)!,\n            Color.lerp(secondary, Colors.white, 0.18)!,\n            Color.lerp(primary, Colors.black, 0.30)!,\n          ],\n          stops: const <double>[0, 0.54, 1],\n        ).createShader(rect),\n    );\n\n    canvas.drawRRect(\n      body,\n      Paint()\n        ..style = PaintingStyle.stroke\n        ..strokeWidth = size.width * 0.055\n        ..color = accent.withOpacity(rolling ? 0.72 : 0.95),\n    );\n\n    final highlight = RRect.fromRectAndRadius(\n      Rect.fromLTWH(\n        size.width * 0.13,\n        size.height * 0.11,\n        size.width * 0.62,\n        size.height * 0.22,\n      ),\n      Radius.circular(size.width * 0.12),\n    );\n    canvas.drawRRect(\n      highlight,\n      Paint()\n        ..shader = LinearGradient(\n          colors: <Color>[\n            Colors.white.withOpacity(0.68),\n            Colors.white.withOpacity(0),\n          ],\n        ).createShader(highlight.outerRect),\n    );\n\n    final safeValue = value?.clamp(1, 6).toInt();\n    if (safeValue == null) {\n      _drawQuestionMark(canvas, size);\n      return;\n    }\n\n    final points = _pipPoints(safeValue);\n    final pipRadius = size.width * 0.078;\n    final pipColor =\n        safeValue == 6 ? const Color(0xFFFFF3B0) : Colors.white;\n\n    for (final point in points) {\n      final center = Offset(\n        size.width * point.dx,\n        size.height * point.dy,\n      );\n\n      canvas.drawCircle(\n        center.translate(0, pipRadius * 0.23),\n        pipRadius * 1.04,\n        Paint()..color = const Color(0x55000000),\n      );\n      canvas.drawCircle(\n        center,\n        pipRadius,\n        Paint()\n          ..shader = RadialGradient(\n            center: const Alignment(-0.3, -0.3),\n            colors: <Color>[\n              Colors.white,\n              pipColor,\n              Color.lerp(pipColor, Colors.black, 0.25)!,\n            ],\n          ).createShader(\n            Rect.fromCircle(center: center, radius: pipRadius),\n          ),\n      );\n    }\n  }\n\n  void _drawQuestionMark(Canvas canvas, Size size) {\n    final painter = TextPainter(\n      text: TextSpan(\n        text: '?',\n        style: TextStyle(\n          color: Colors.white.withOpacity(0.94),\n          fontSize: size.width * 0.54,\n          height: 1,\n          fontWeight: FontWeight.w900,\n          shadows: const <Shadow>[\n            Shadow(color: Color(0x88000000), blurRadius: 5, offset: Offset(0, 3)),\n          ],\n        ),\n      ),\n      textDirection: TextDirection.ltr,\n    )..layout();\n\n    painter.paint(\n      canvas,\n      Offset(\n        (size.width - painter.width) / 2,\n        (size.height - painter.height) / 2 - size.height * 0.025,\n      ),\n    );\n  }\n\n  List<Offset> _pipPoints(int number) {\n    const left = 0.28;\n    const center = 0.50;\n    const right = 0.72;\n    const top = 0.28;\n    const middle = 0.50;\n    const bottom = 0.72;\n\n    return switch (number) {\n      1 => const <Offset>[Offset(center, middle)],\n      2 => const <Offset>[Offset(left, top), Offset(right, bottom)],\n      3 => const <Offset>[\n          Offset(left, top),\n          Offset(center, middle),\n          Offset(right, bottom),\n        ],\n      4 => const <Offset>[\n          Offset(left, top),\n          Offset(right, top),\n          Offset(left, bottom),\n          Offset(right, bottom),\n        ],\n      5 => const <Offset>[\n          Offset(left, top),\n          Offset(right, top),\n          Offset(center, middle),\n          Offset(left, bottom),\n          Offset(right, bottom),\n        ],\n      _ => const <Offset>[\n          Offset(left, top),\n          Offset(right, top),\n          Offset(left, middle),\n          Offset(right, middle),\n          Offset(left, bottom),\n          Offset(right, bottom),\n        ],\n    };\n  }\n\n  @override\n  bool shouldRepaint(covariant PremiumDicePainter oldDelegate) {\n    return oldDelegate.value != value ||\n        oldDelegate.rolling != rolling ||\n        oldDelegate.primary != primary ||\n        oldDelegate.secondary != secondary ||\n        oldDelegate.accent != accent;\n  }\n}\n\nclass PremiumDiceSixBurstPainter extends CustomPainter {\n  const PremiumDiceSixBurstPainter({\n    required this.progress,\n    required this.color,\n  });\n\n  final double progress;\n  final Color color;\n\n  @override\n  void paint(Canvas canvas, Size size) {\n    final pulse = sin(pi * progress).clamp(0.0, 1.0).toDouble();\n    if (pulse <= 0.001) return;\n\n    final center = Offset(size.width / 2, size.height / 2);\n    final radius = size.width * (0.28 + pulse * 0.22);\n\n    canvas.drawCircle(\n      center,\n      radius,\n      Paint()\n        ..style = PaintingStyle.stroke\n        ..strokeWidth = max(1.0, size.width * 0.025 * pulse)\n        ..color = color.withOpacity(0.72 * pulse)\n        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),\n    );\n\n    for (var index = 0; index < 10; index++) {\n      final angle = index * (2 * pi / 10) + progress * 0.45;\n      final start = center +\n          Offset(cos(angle), sin(angle)) * size.width * 0.34;\n      final end = center +\n          Offset(cos(angle), sin(angle)) * size.width * (0.43 + pulse * 0.10);\n\n      canvas.drawLine(\n        start,\n        end,\n        Paint()\n          ..strokeCap = StrokeCap.round\n          ..strokeWidth = max(1.0, size.width * 0.022 * pulse)\n          ..color = (index.isEven ? color : Colors.white)\n              .withOpacity(0.82 * pulse),\n      );\n    }\n  }\n\n  @override\n  bool shouldRepaint(covariant PremiumDiceSixBurstPainter oldDelegate) {\n    return oldDelegate.progress != progress || oldDelegate.color != color;\n  }\n}\n"
SHORT_CHALLENGE_CONTENT = "part of 'main.dart';\n\nclass ShortChallengeCodeService {\n  ShortChallengeCodeService._();\n\n  static const int questionCount = 10;\n  static const int targetScore = 7;\n\n  static String generate([Random? random]) {\n    final source = random ?? Random.secure();\n    final number = 1000 + source.nextInt(9000);\n    return 'BR$number';\n  }\n\n  static String normalize(String raw) {\n    var cleaned = raw\n        .trim()\n        .toUpperCase()\n        .replaceAll(RegExp(r'[^A-Z0-9]'), '');\n\n    if (RegExp(r'^\\d{4}$').hasMatch(cleaned)) {\n      cleaned = 'BR$cleaned';\n    }\n\n    if (!RegExp(r'^BR\\d{4}$').hasMatch(cleaned)) {\n      throw const FormatException(\n        'Kod BR1905 gibi BR ve dört rakamdan oluşmalı.',\n      );\n    }\n\n    return cleaned;\n  }\n\n  static bool isValid(String raw) {\n    try {\n      normalize(raw);\n      return true;\n    } on FormatException {\n      return false;\n    }\n  }\n\n  static int stableHash(String value) {\n    var hash = 0x811C9DC5;\n\n    for (final byte in utf8.encode(value)) {\n      hash ^= byte;\n      hash = (hash * 0x01000193) & 0x7FFFFFFF;\n    }\n\n    return hash;\n  }\n\n  static List<QuizQuestion> selectQuestions(\n    QuestionBank questionBank,\n    String rawCode,\n  ) {\n    final code = normalize(rawCode);\n    final questions = questionBank.questionsByCategory.values\n        .expand((items) => items)\n        .toList(growable: false);\n\n    final ranked = List<QuizQuestion>.from(questions)\n      ..sort((a, b) {\n        final aHash = stableHash('$code|${a.id}');\n        final bHash = stableHash('$code|${b.id}');\n        final hashOrder = aHash.compareTo(bHash);\n\n        if (hashOrder != 0) return hashOrder;\n        return a.id.compareTo(b.id);\n      });\n\n    return ranked.take(questionCount).toList(growable: false);\n  }\n\n  static ChallengeConfig buildConfig({\n    required QuestionBank questionBank,\n    required String rawCode,\n    required String challengerName,\n  }) {\n    final code = normalize(rawCode);\n    final questions = selectQuestions(questionBank, code);\n\n    if (questions.length < questionCount) {\n      throw const FormatException(\n        'Meydan okuma için yeterli soru bulunamadı.',\n      );\n    }\n\n    final cleanName = challengerName.trim();\n\n    return ChallengeConfig(\n      challengerName: cleanName.isEmpty ? 'Bir oyuncu' : cleanName,\n      targetScore: targetScore,\n      categoryIndex: -1,\n      difficulty: 'Karışık',\n      questionIds: questions\n          .map((question) => question.id)\n          .toList(growable: false),\n      shortCode: code,\n    );\n  }\n}\n\nclass ShortChallengeModeScreen extends StatefulWidget {\n  const ShortChallengeModeScreen({\n    required this.questionBank,\n    super.key,\n  });\n\n  final QuestionBank questionBank;\n\n  @override\n  State<ShortChallengeModeScreen> createState() =>\n      _ShortChallengeModeScreenState();\n}\n\nclass _ShortChallengeModeScreenState\n    extends State<ShortChallengeModeScreen> {\n  late String _generatedCode;\n  final TextEditingController _joinController =\n      TextEditingController();\n  String? _error;\n\n  String get _playerName {\n    final name =\n        AppPreferencesService.current.defaultPlayerName.trim();\n    return name.isEmpty ? 'Bir oyuncu' : name;\n  }\n\n  @override\n  void initState() {\n    super.initState();\n    _generatedCode = ShortChallengeCodeService.generate();\n  }\n\n  @override\n  void dispose() {\n    _joinController.dispose();\n    super.dispose();\n  }\n\n  @override\n  Widget build(BuildContext context) {\n    return Scaffold(\n      appBar: AppBar(\n        title: const Text('Meydan Okuma'),\n      ),\n      body: Container(\n        decoration: const BoxDecoration(\n          gradient: LinearGradient(\n            begin: Alignment.topLeft,\n            end: Alignment.bottomRight,\n            colors: <Color>[\n              Color(0xFF24122F),\n              Color(0xFF5B2167),\n              Color(0xFF0F5661),\n            ],\n          ),\n        ),\n        child: SafeArea(\n          child: ListView(\n            padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),\n            children: [\n              _hero(),\n              const SizedBox(height: 15),\n              _createCard(),\n              const SizedBox(height: 14),\n              _joinCard(),\n              const SizedBox(height: 14),\n              const Text(\n                'Aynı kısa kod, aynı APK sürümünde iki telefonda da '\n                'aynı 10 soruyu aynı sırayla açar. Hedef skor 7 doğrudur.',\n                textAlign: TextAlign.center,\n                style: TextStyle(\n                  color: Color(0xFFD8CCEA),\n                  fontSize: 12,\n                  height: 1.4,\n                  fontWeight: FontWeight.w700,\n                ),\n              ),\n            ],\n          ),\n        ),\n      ),\n    );\n  }\n\n  Widget _hero() {\n    return Container(\n      padding: const EdgeInsets.all(22),\n      decoration: BoxDecoration(\n        gradient: const LinearGradient(\n          colors: <Color>[\n            Color(0xFF7C3AED),\n            Color(0xFFBE185D),\n          ],\n        ),\n        borderRadius: BorderRadius.circular(28),\n        border: Border.all(\n          color: const Color(0x99FFE082),\n        ),\n      ),\n      child: const Column(\n        children: [\n          Text(\n            '🎯⚔️',\n            style: TextStyle(fontSize: 54),\n          ),\n          SizedBox(height: 8),\n          Text(\n            'Kısa kodla aynı sorularda yarış',\n            textAlign: TextAlign.center,\n            style: TextStyle(\n              color: Colors.white,\n              fontSize: 23,\n              fontWeight: FontWeight.w900,\n            ),\n          ),\n          SizedBox(height: 7),\n          Text(\n            'Oyun otomatik BR1905 gibi kısa bir kod üretir. '\n            'Kodu diğer telefona gönder; ikiniz de aynı bilgi turunu oynayın.',\n            textAlign: TextAlign.center,\n            style: TextStyle(\n              color: Color(0xFFEDE9FE),\n              height: 1.35,\n            ),\n          ),\n        ],\n      ),\n    );\n  }\n\n  Widget _createCard() {\n    return Container(\n      padding: const EdgeInsets.all(18),\n      decoration: BoxDecoration(\n        color: Colors.white,\n        borderRadius: BorderRadius.circular(25),\n        border: Border.all(\n          color: const Color(0xFFC4B5FD),\n        ),\n      ),\n      child: Column(\n        crossAxisAlignment: CrossAxisAlignment.stretch,\n        children: [\n          const Text(\n            'Yeni meydan okuma',\n            style: TextStyle(\n              fontSize: 20,\n              fontWeight: FontWeight.w900,\n            ),\n          ),\n          const SizedBox(height: 5),\n          Text(\n            'Meydan okuyan: $_playerName',\n            style: const TextStyle(\n              color: Color(0xFF64748B),\n              fontWeight: FontWeight.w700,\n            ),\n          ),\n          const SizedBox(height: 15),\n          Container(\n            padding: const EdgeInsets.symmetric(\n              horizontal: 16,\n              vertical: 17,\n            ),\n            decoration: BoxDecoration(\n              gradient: const LinearGradient(\n                colors: <Color>[\n                  Color(0xFFF3E8FF),\n                  Color(0xFFE0F2FE),\n                ],\n              ),\n              borderRadius: BorderRadius.circular(21),\n              border: Border.all(\n                color: const Color(0xFF7C3AED),\n                width: 2,\n              ),\n            ),\n            child: SelectableText(\n              _generatedCode,\n              textAlign: TextAlign.center,\n              style: const TextStyle(\n                color: Color(0xFF4C1D95),\n                fontSize: 35,\n                letterSpacing: 4,\n                fontWeight: FontWeight.w900,\n              ),\n            ),\n          ),\n          const SizedBox(height: 11),\n          Row(\n            children: [\n              Expanded(\n                child: OutlinedButton.icon(\n                  onPressed: _newCode,\n                  icon: const Icon(Icons.refresh_rounded),\n                  label: const Text('Yeni Kod'),\n                ),\n              ),\n              const SizedBox(width: 8),\n              Expanded(\n                child: OutlinedButton.icon(\n                  onPressed: _copyCode,\n                  icon: const Icon(Icons.copy_rounded),\n                  label: const Text('Kopyala'),\n                ),\n              ),\n            ],\n          ),\n          const SizedBox(height: 8),\n          FilledButton.icon(\n            onPressed: _shareCode,\n            icon: const Icon(Icons.share_rounded),\n            label: const Text(\n              'Kodu Paylaş',\n              style: TextStyle(fontWeight: FontWeight.w900),\n            ),\n          ),\n          const SizedBox(height: 8),\n          FilledButton.icon(\n            onPressed: () => _start(\n              _generatedCode,\n              challengerName: _playerName,\n            ),\n            style: FilledButton.styleFrom(\n              backgroundColor: const Color(0xFF0F766E),\n            ),\n            icon: const Icon(Icons.play_arrow_rounded),\n            label: const Text(\n              'Bu Kodla Oyna',\n              style: TextStyle(fontWeight: FontWeight.w900),\n            ),\n          ),\n        ],\n      ),\n    );\n  }\n\n  Widget _joinCard() {\n    return Container(\n      padding: const EdgeInsets.all(18),\n      decoration: BoxDecoration(\n        color: const Color(0xFFF8FAFC),\n        borderRadius: BorderRadius.circular(25),\n        border: Border.all(\n          color: const Color(0xFF67E8F9),\n        ),\n      ),\n      child: Column(\n        crossAxisAlignment: CrossAxisAlignment.stretch,\n        children: [\n          const Text(\n            'Gelen kodla yarış',\n            style: TextStyle(\n              fontSize: 20,\n              fontWeight: FontWeight.w900,\n            ),\n          ),\n          const SizedBox(height: 10),\n          TextField(\n            controller: _joinController,\n            maxLength: 6,\n            autocorrect: false,\n            enableSuggestions: false,\n            textCapitalization: TextCapitalization.characters,\n            onChanged: (_) {\n              if (_error != null) {\n                setState(() => _error = null);\n              }\n            },\n            decoration: InputDecoration(\n              counterText: '',\n              labelText: 'BR1905 gibi kısa kod',\n              hintText: 'BR1905',\n              prefixIcon: const Icon(Icons.password_rounded),\n              border: const OutlineInputBorder(),\n              errorText: _error,\n            ),\n          ),\n          const SizedBox(height: 10),\n          FilledButton.icon(\n            onPressed: _openIncomingCode,\n            style: FilledButton.styleFrom(\n              backgroundColor: const Color(0xFFBE185D),\n            ),\n            icon: const Icon(Icons.sports_esports_rounded),\n            label: const Text(\n              'Kodu Aç ve Yarış',\n              style: TextStyle(fontWeight: FontWeight.w900),\n            ),\n          ),\n        ],\n      ),\n    );\n  }\n\n  void _newCode() {\n    setState(() {\n      _generatedCode = ShortChallengeCodeService.generate();\n      _error = null;\n    });\n    GameHaptics.selectionClick();\n  }\n\n  Future<void> _copyCode() async {\n    await Clipboard.setData(\n      ClipboardData(text: _generatedCode),\n    );\n\n    if (!mounted) return;\n\n    ScaffoldMessenger.of(context)\n      ..hideCurrentSnackBar()\n      ..showSnackBar(\n        const SnackBar(\n          content: Text('Kısa meydan okuma kodu kopyalandı.'),\n        ),\n      );\n  }\n\n  Future<void> _shareCode() {\n    return SocialShareService.shareText(\n      context,\n      title: 'Bilgi Rotası Meydan Okuması',\n      text: <String>[\n        '🧭 BİLGİ ROTASI MEYDAN OKUMASI',\n        '$_playerName sana meydan okuyor!',\n        '',\n        'Kod: $_generatedCode',\n        '10 karışık soru • Hedef 7 doğru',\n        '',\n        'Bilgi Rotası uygulamasında Oyna > Meydan Okuma bölümüne gir.',\n      ].join('\\n'),\n    );\n  }\n\n  void _openIncomingCode() {\n    _start(\n      _joinController.text,\n      challengerName: 'Kod sahibi',\n    );\n  }\n\n  void _start(\n    String rawCode, {\n    required String challengerName,\n  }) {\n    try {\n      final code = ShortChallengeCodeService.normalize(rawCode);\n      final questions = ShortChallengeCodeService.selectQuestions(\n        widget.questionBank,\n        code,\n      );\n\n      if (questions.length < ShortChallengeCodeService.questionCount) {\n        throw const FormatException(\n          'Bu sürümde meydan okuma için yeterli soru yok.',\n        );\n      }\n\n      final challenge = ChallengeConfig(\n        challengerName: challengerName,\n        targetScore: ShortChallengeCodeService.targetScore,\n        categoryIndex: -1,\n        difficulty: 'Karışık',\n        questionIds: questions\n            .map((question) => question.id)\n            .toList(growable: false),\n        shortCode: code,\n      );\n\n      setState(() => _error = null);\n      GameHaptics.mediumImpact();\n\n      Navigator.of(context).push(\n        MaterialPageRoute(\n          builder: (_) => ChallengeGameScreen(\n            questionBank: widget.questionBank,\n            challenge: challenge,\n            questions: questions,\n          ),\n        ),\n      );\n    } on FormatException catch (error) {\n      setState(() {\n        _error = error.message.toString();\n      });\n    } catch (_) {\n      setState(() {\n        _error = 'Kod açılamadı. BR1905 biçimini kontrol et.';\n      });\n    }\n  }\n}\n"
COMMIT_MESSAGE = "Premium zar ve kisa kodlu meydan okuma ekle"

def run(command):
    print("$ " + " ".join(command))
    return subprocess.run(command, check=True)

def require_replace(content, old, new, label):
    if old not in content:
        raise RuntimeError(f"{label} bulunamadı.")
    return content.replace(old, new, 1)

required_files = [MAIN, GAME_UI, NAV, SOCIAL, PUBSPEC, TEST]
for path in required_files:
    if not path.exists():
        raise SystemExit(
            f"Gerekli dosya bulunamadı: {path}\n"
            "Kurulumu BilgiRotasi deposunun ana klasöründe çalıştır."
        )

branch = subprocess.check_output(
    ["git", "branch", "--show-current"],
    text=True,
).strip()

if branch != "main":
    raise SystemExit(
        "Bu özellik yalnızca main dalına kurulabilir.\n"
        f"Şu anki dal: {branch or '(belirsiz)'}\n"
        "Önce: git switch main"
    )

question_status = subprocess.run(
    ["git", "status", "--porcelain", "--", "assets/questions.json"],
    text=True,
    capture_output=True,
    check=True,
).stdout.strip()

if question_status:
    raise SystemExit(
        "assets/questions.json dosyasında yerel değişiklik var.\n"
        "Soru çalışmasını tamamlayıp main dalını güncelledikten sonra "
        "bu özellik paketini çalıştır."
    )

main = MAIN.read_text(encoding="utf-8")
game_ui = GAME_UI.read_text(encoding="utf-8")
nav = NAV.read_text(encoding="utf-8")
social = SOCIAL.read_text(encoding="utf-8")
pubspec = PUBSPEC.read_text(encoding="utf-8")
test = TEST.read_text(encoding="utf-8")

version_match = re.search(
    r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$",
    pubspec,
    flags=re.MULTILINE,
)
if version_match is None:
    raise SystemExit("pubspec.yaml sürüm satırı okunamadı.")

version = tuple(map(int, version_match.groups()))
if version != (1, 41, 0, 51):
    raise SystemExit(
        "Bu paket 1.41.0+51 sürümü için hazırlandı.\n"
        f"Depodaki sürüm: {version[0]}.{version[1]}.{version[2]}+{version[3]}\n"
        "Önce git pull çalıştır. Sürüm yine farklıysa güncel kurulum "
        "paketi hazırlanması gerekir."
    )

if (
    DICE_TARGET.exists()
    or CHALLENGE_TARGET.exists()
    or "part 'premium_dice.dart';" in main
    or "part 'short_challenge_mode.dart';" in main
):
    raise SystemExit(
        "Premium zar veya kısa kodlu meydan okuma zaten kurulmuş görünüyor."
    )

backup_dir = Path(tempfile.mkdtemp(prefix="bilgi_rotasi_dice_challenge_"))
committed = False

try:
    for path in required_files:
        shutil.copy2(path, backup_dir / path.name)

    DICE_TARGET.write_text(PREMIUM_DICE_CONTENT, encoding="utf-8")
    CHALLENGE_TARGET.write_text(SHORT_CHALLENGE_CONTENT, encoding="utf-8")

    main = require_replace(
        main,
        "part 'pawn_visual_effects.dart';",
        "part 'pawn_visual_effects.dart';\n"
        "part 'premium_dice.dart';\n"
        "part 'short_challenge_mode.dart';",
        "Yeni part dosyaları için ekleme noktası",
    )

    main = require_replace(
        main,
        "  int? _lastDice;\n  bool _isBusy = false;",
        "  int? _lastDice;\n"
        "  bool _diceRolling = false;\n"
        "  bool _isBusy = false;",
        "Zar animasyonu durum alanı",
    )

    main = require_replace(
        main,
        "                GameTurnHeader(\n"
        "                  player: _currentPlayer,\n"
        "                  lastDice: _lastDice,\n"
        "                ),",
        "                GameTurnHeader(\n"
        "                  player: _currentPlayer,\n"
        "                  lastDice: _lastDice,\n"
        "                  diceRolling: _diceRolling,\n"
        "                ),",
        "GameTurnHeader çağrısı",
    )

    main = require_replace(
        main,
        "    setState(() {\n"
        "      _isBusy = true;\n"
        "      _lastDice = null;\n"
        "      _status = '${_currentPlayer.name} zarı atıyor…';\n"
        "    });",
        "    setState(() {\n"
        "      _isBusy = true;\n"
        "      _lastDice = null;\n"
        "      _diceRolling = true;\n"
        "      _status = '${_currentPlayer.name} zarı atıyor…';\n"
        "    });",
        "Zar atış başlangıcı",
    )

    main = require_replace(
        main,
        "    var diceResult = _random.nextInt(6) + 1;\n\n"
        "    final useReroll =",
        "    var diceResult = _random.nextInt(6) + 1;\n\n"
        "    setState(() {\n"
        "      _lastDice = diceResult;\n"
        "      _diceRolling = false;\n"
        "    });\n\n"
        "    final useReroll =",
        "İlk zar sonucunun yerleşmesi",
    )

    main = require_replace(
        main,
        "    if (useReroll &&\n"
        "        _currentPlayer.jokers.consume(\n"
        "          JokerKind.reroll,\n"
        "        )) {\n"
        "      unawaited(SoundFx.dice());",
        "    if (useReroll &&\n"
        "        _currentPlayer.jokers.consume(\n"
        "          JokerKind.reroll,\n"
        "        )) {\n"
        "      setState(() {\n"
        "        _lastDice = null;\n"
        "        _diceRolling = true;\n"
        "      });\n"
        "      unawaited(SoundFx.dice());",
        "Tekrar zar animasyonu",
    )

    main = require_replace(
        main,
        "    setState(() {\n"
        "      _lastDice = diceResult;\n"
        "      _status = '${_currentPlayer.name} $diceResult attı!';\n"
        "    });",
        "    setState(() {\n"
        "      _lastDice = diceResult;\n"
        "      _diceRolling = false;\n"
        "      _status = '${_currentPlayer.name} $diceResult attı!';\n"
        "    });",
        "Zar sonucu yerleşme durumu",
    )

    main, version_text_count = re.subn(
        r"Bilgi Rotası • Sürüm 1\.41\.0",
        "Bilgi Rotası • Sürüm 1.42.0",
        main,
        count=1,
    )
    if version_text_count != 1:
        raise RuntimeError("Ana menü sürüm yazısı güncellenemedi.")

    game_ui = require_replace(
        game_ui,
        "    required this.lastDice,\n"
        "    super.key,",
        "    required this.lastDice,\n"
        "    this.diceRolling = false,\n"
        "    super.key,",
        "GameTurnHeader yapıcısı",
    )

    game_ui = require_replace(
        game_ui,
        "  final PlayerData player;\n"
        "  final int? lastDice;",
        "  final PlayerData player;\n"
        "  final int? lastDice;\n"
        "  final bool diceRolling;",
        "GameTurnHeader zar alanı",
    )

    game_ui = require_replace(
        game_ui,
        "          DiceFace(value: lastDice),",
        "          PremiumDiceFace(\n"
        "            value: lastDice,\n"
        "            rolling: diceRolling,\n"
        "          ),",
        "Eski zar görünümü",
    )

    nav = nav.replace(
        "Tahta, Serbest Rota, Maraton ve diğer modlar",
        "Tahta, maraton, meydan okuma ve diğer modlar",
        1,
    )
    nav = nav.replace(
        "Paylaşım, aile rekorları ve meydan okuma",
        "Paylaşım, aile rekorları ve kariyer özeti",
        1,
    )

    challenge_card = """        _HubActionCard(
          emoji: '⚡',
          title: 'Diğer Oyun Modları',
"""
    if challenge_card not in nav:
        raise RuntimeError("Oyna bölümündeki oyun modu ekleme noktası bulunamadı.")

    nav = nav.replace(
        challenge_card,
        """        _HubActionCard(
          emoji: '🎯',
          title: 'Meydan Okuma',
          description:
              'BR1905 gibi otomatik kısa kod üret; başka telefonda '
              'aynı 10 soruda 7 doğru hedefiyle yarış.',
          accent: const Color(0xFFBE185D),
          onTap: () => _open(
            context,
            ShortChallengeModeScreen(questionBank: questionBank),
          ),
        ),
        _HubActionCard(
          emoji: '⚡',
          title: 'Diğer Oyun Modları',
""",
        1,
    )

    social = social.replace(
        "Bilgi Rotası uygulamasında '\n"
        "          'Sosyal & Meydan Okuma bölümüne gir.",
        "Bilgi Rotası uygulamasında '\n"
        "          'Oyna > Meydan Okuma bölümüne gir.",
        1,
    )

    social = social.replace(
        "    required this.questionIds,\n"
        "  });",
        "    required this.questionIds,\n"
        "    this.shortCode,\n"
        "  });",
        1,
    )

    social = social.replace(
        "  final List<String> questionIds;\n\n"
        "  String get categoryLabel",
        "  final List<String> questionIds;\n"
        "  final String? shortCode;\n\n"
        "  String get categoryLabel",
        1,
    )

    social = social.replace(
        "  String get code {\n"
        "    final bytes = utf8.encode(jsonEncode(toJson()));",
        "  String get code {\n"
        "    final compactCode = shortCode?.trim().toUpperCase();\n"
        "    if (compactCode != null && compactCode.isNotEmpty) {\n"
        "      return compactCode;\n"
        "    }\n\n"
        "    final bytes = utf8.encode(jsonEncode(toJson()));",
        1,
    )

    social = social.replace(
        "'Sosyal • Rekorlar, Paylaşım & Meydan Okuma'",
        "'Sosyal • Rekorlar ve Paylaşım'",
        1,
    )
    social = social.replace(
        "title: const Text('Sosyal & Meydan Okuma')",
        "title: const Text('Sosyal & Rekorlar')",
        1,
    )
    social = social.replace(
        "'Bilgini paylaş, ailene meydan oku'",
        "'Bilgini paylaş, aile rekorlarını gör'",
        1,
    )
    social = social.replace(
        "'Sonuçlarını paylaş, aynı telefondaki '\n"
        "                      'aile rekorlarını gör ve başka telefona '\n"
        "                      'aynı soru setini kodla gönder.'",
        "'Sonuçlarını paylaş, aynı telefondaki '\n"
        "                      'aile rekorlarını gör ve kariyerindeki '\n"
        "                      'ilerlemeyi çevrenle paylaş.'",
        1,
    )

    challenge_block_pattern = re.compile(
        r"""\n\s+_socialCard\(
\s+context,
\s+emoji: '🎯',
\s+title: 'Meydan Okuma Kodu',
.*?
\s+const SizedBox\(height: 12\),
(?=\s+_socialCard\(
\s+context,
\s+emoji: '👨‍👩‍👧‍👦')""",
        flags=re.DOTALL,
    )
    social, removed_count = challenge_block_pattern.subn("\n", social, count=1)
    if removed_count != 1:
        raise RuntimeError("Sosyal bölümündeki eski meydan okuma kartı kaldırılamadı.")

    social = social.replace(
        "'Meydan okuma kodu çevrim dışı çalışır. '\n"
        "                  'Kod, soru kimliklerini taşıdığı için iki '\n"
        "                  'telefonda da aynı sorular açılır.'",
        "'Meydan Okuma artık Oyna bölümünde. Sosyal bölümünde '\n"
        "                  'aile rekorları ve paylaşım araçları bulunur.'",
        1,
    )

    pubspec = re.sub(
        r"^version:\s*.*$",
        "version: 1.42.0+52",
        pubspec,
        count=1,
        flags=re.MULTILINE,
    )

    test_insert = """
    test('Premium zar modeli altı yüzü doğru tanır', () {
      expect(PremiumDiceModel.pipCount(null), 0);
      expect(PremiumDiceModel.pipCount(1), 1);
      expect(PremiumDiceModel.pipCount(6), 6);
      expect(PremiumDiceModel.isLuckySix(6), isTrue);
      expect(PremiumDiceModel.isLuckySix(5), isFalse);
    });

    test('Kısa meydan okuma kodu kararlı ve okunabilirdir', () {
      expect(
        ShortChallengeCodeService.normalize('br-1905'),
        'BR1905',
      );
      expect(
        ShortChallengeCodeService.normalize('1905'),
        'BR1905',
      );
      expect(
        ShortChallengeCodeService.isValid('BR1905'),
        isTrue,
      );
      expect(
        ShortChallengeCodeService.isValid('BR19'),
        isFalse,
      );
      expect(
        ShortChallengeCodeService.stableHash('BR1905'),
        ShortChallengeCodeService.stableHash('BR1905'),
      );
      expect(ShortChallengeCodeService.questionCount, 10);
      expect(ShortChallengeCodeService.targetScore, 7);
    });

    test('ChallengeConfig kısa kodu doğrudan paylaşır', () {
      final challenge = ChallengeConfig(
        challengerName: 'Test',
        targetScore: 7,
        categoryIndex: -1,
        difficulty: 'Karışık',
        questionIds: const <String>['q001'],
        shortCode: 'BR1905',
      );

      expect(challenge.code, 'BR1905');
    });
"""
    group_end = test.rfind("  });\n}")
    if group_end < 0:
        raise RuntimeError("Test dosyası ekleme noktası bulunamadı.")
    test = test[:group_end] + test_insert + test[group_end:]

    MAIN.write_text(main, encoding="utf-8")
    GAME_UI.write_text(game_ui, encoding="utf-8")
    NAV.write_text(nav, encoding="utf-8")
    SOCIAL.write_text(social, encoding="utf-8")
    PUBSPEC.write_text(pubspec, encoding="utf-8")
    TEST.write_text(test, encoding="utf-8")

    checks = {
        MAIN: [
            "part 'premium_dice.dart';",
            "part 'short_challenge_mode.dart';",
            "bool _diceRolling = false;",
            "diceRolling: _diceRolling",
            "Bilgi Rotası • Sürüm 1.42.0",
        ],
        GAME_UI: [
            "final bool diceRolling;",
            "PremiumDiceFace(",
        ],
        NAV: [
            "title: 'Meydan Okuma'",
            "ShortChallengeModeScreen(questionBank: questionBank)",
        ],
        SOCIAL: [
            "final String? shortCode;",
            "return compactCode;",
            "Sosyal • Rekorlar ve Paylaşım",
            "Oyna > Meydan Okuma bölümüne gir",
        ],
        DICE_TARGET: [
            "class PremiumDiceFace",
            "class PremiumDicePainter",
            "class PremiumDiceSixBurstPainter",
        ],
        CHALLENGE_TARGET: [
            "class ShortChallengeCodeService",
            "class ShortChallengeModeScreen",
            "BR1905",
            "targetScore = 7",
        ],
        PUBSPEC: ["version: 1.42.0+52"],
        TEST: [
            "Premium zar modeli altı yüzü doğru tanır",
            "Kısa meydan okuma kodu kararlı ve okunabilirdir",
        ],
    }

    for path, markers in checks.items():
        content = path.read_text(encoding="utf-8")
        for marker in markers:
            if marker not in content:
                raise RuntimeError(
                    f"Kurulum doğrulaması başarısız: {path} / {marker}"
                )

    if "title: 'Meydan Okuma Kodu'" in social:
        raise RuntimeError(
            "Eski meydan okuma kartı Sosyal bölümünde kalmış görünüyor."
        )

    if shutil.which("dart"):
        run([
            "dart",
            "format",
            "lib/main.dart",
            "lib/game_ui_polish.dart",
            "lib/main_navigation.dart",
            "lib/social_features.dart",
            "lib/premium_dice.dart",
            "lib/short_challenge_mode.dart",
            "test/system_smoke_test.dart",
        ])

    run(["git", "diff", "--check"])

    changed_paths = subprocess.check_output(
        ["git", "diff", "--name-only"],
        text=True,
    ).splitlines()

    if "assets/questions.json" in changed_paths:
        raise RuntimeError(
            "Güvenlik kontrolü: questions.json değişmiş görünüyor."
        )

    if shutil.which("flutter"):
        run(["flutter", "pub", "get"])
        run([
            "flutter",
            "analyze",
            "--no-fatal-warnings",
            "--no-fatal-infos",
        ])
        run(["flutter", "test"])
    else:
        print(
            "ℹ️ Flutter bu ortamda bulunamadı; analiz ve test "
            "GitHub Actions'ta çalışacak."
        )

    files_to_stage = [
        "lib/main.dart",
        "lib/game_ui_polish.dart",
        "lib/main_navigation.dart",
        "lib/social_features.dart",
        "lib/premium_dice.dart",
        "lib/short_challenge_mode.dart",
        "test/system_smoke_test.dart",
        "pubspec.yaml",
    ]
    if Path("pubspec.lock").exists():
        files_to_stage.append("pubspec.lock")

    run(["git", "add", *files_to_stage])

    changed = subprocess.run(
        ["git", "diff", "--cached", "--quiet"],
        check=False,
    ).returncode != 0
    if not changed:
        raise RuntimeError("Commit edilecek değişiklik bulunamadı.")

    run(["git", "commit", "-m", COMMIT_MESSAGE])
    committed = True
    run(["git", "push", "origin", "main"])

except Exception as error:
    if not committed:
        restore_map = {
            MAIN: backup_dir / MAIN.name,
            GAME_UI: backup_dir / GAME_UI.name,
            NAV: backup_dir / NAV.name,
            SOCIAL: backup_dir / SOCIAL.name,
            PUBSPEC: backup_dir / PUBSPEC.name,
            TEST: backup_dir / TEST.name,
        }
        for destination, source in restore_map.items():
            shutil.copy2(source, destination)

        for target in [DICE_TARGET, CHALLENGE_TARGET]:
            if target.exists():
                target.unlink()

        reset_paths = [
            "lib/main.dart",
            "lib/game_ui_polish.dart",
            "lib/main_navigation.dart",
            "lib/social_features.dart",
            "lib/premium_dice.dart",
            "lib/short_challenge_mode.dart",
            "test/system_smoke_test.dart",
            "pubspec.yaml",
        ]
        if Path("pubspec.lock").exists():
            reset_paths.append("pubspec.lock")

        subprocess.run(
            ["git", "reset", "--", *reset_paths],
            check=False,
        )

        if shutil.which("flutter"):
            subprocess.run(["flutter", "pub", "get"], check=False)

    print("")
    print("❌ Kurulum tamamlanamadı.")
    print(str(error))

    if committed:
        print(
            "Commit oluşturuldu fakat push başarısız oldu. "
            "Tekrar dene: git push origin main"
        )
    else:
        print("Dosyalar önceki hâline otomatik döndürüldü.")

    raise SystemExit(1)

finally:
    shutil.rmtree(backup_dir, ignore_errors=True)

print("")
print("✅ Premium zar atışı ve 6 için altın parıltı eklendi.")
print("✅ Zar animasyonu tahta temasına ve düşük animasyon ayarına uyuyor.")
print("✅ Meydan Okuma, Sosyal bölümünden Oyna bölümüne taşındı.")
print("✅ BR1905 biçiminde otomatik kısa kod sistemi eklendi.")
print("✅ Aynı kısa kod iki güncel telefonda aynı 10 soruyu açıyor.")
print("✅ Hedef skor 7 doğru olarak ayarlandı.")
print("✅ questions.json dosyasına dokunulmadı.")
print("✅ Yeni sürüm: 1.42.0+52")
print("✅ Değişiklikler GitHub main dalına gönderildi.")
