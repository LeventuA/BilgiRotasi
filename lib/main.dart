import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BilgiRotasiApp());
}

class BilgiRotasiApp extends StatefulWidget {
  const BilgiRotasiApp({super.key});

  @override
  State<BilgiRotasiApp> createState() => _BilgiRotasiAppState();
}

class _BilgiRotasiAppState extends State<BilgiRotasiApp> {
  late final Future<QuestionBank> _questionBankFuture;

  @override
  void initState() {
    super.initState();
    _questionBankFuture = QuestionBank.load();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bilgi Rotası',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF155E75),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
      home: FutureBuilder<QuestionBank>(
        future: _questionBankFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingScreen();
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return ErrorScreen(
              message: snapshot.error?.toString() ?? 'Sorular yüklenemedi.',
            );
          }

          return HomeScreen(questionBank: snapshot.data!);
        },
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 18),
            Text('Sorular hazırlanıyor…'),
          ],
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 72),
                const SizedBox(height: 18),
                const Text(
                  'Uygulama başlatılamadı',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                const Text(
                  'pubspec.yaml içinde assets/questions.json satırının bulunduğunu kontrol et.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.questionBank, super.key});

  final QuestionBank questionBank;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFF155E75),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: const Text('🧠', style: TextStyle(fontSize: 30)),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bilgi Rotası',
                          style: TextStyle(
                            fontSize: 30,
                            height: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text('Zarı at, bilginle yolu aç.'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF164E63), Color(0xFF0F766E)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aynı telefonda\n2–6 kişilik bilgi düellosu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${questionBank.totalCount} soru • 6 kategori • İnternetsiz',
                      style: const TextStyle(
                        color: Color(0xFFD5F5F1),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF164E63),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PlayerSetupScreen(
                              questionBank: questionBank,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text(
                        'Oyunu Başlat',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kategoriler',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(
                          GameCategory.values.length,
                          (index) => CategoryPill(category: GameCategory.values[index]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () => _showRules(context),
                icon: const Icon(Icons.menu_book_rounded),
                label: const Text('Nasıl Oynanır?'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRules(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nasıl oynanır?'),
          content: const SingleChildScrollView(
            child: Text(
              '• Bütün oyuncular oyuna ortadaki altıgenden başlar.\n\n'
              '• Zar atıldıktan sonra gidilecek yol seçilir. Kavşaklarda dış halkada sağa, sola veya merkeze doğru ilerlenebilir.\n\n• Gelinen rengin kategorisinden dört şıklı soru açılır.\n\n'
              '• Doğru cevap veren oyuncu yeniden oynar. Yanlış cevapta sıra diğer oyuncuya geçer.\n\n'
              '• Beyaz çerçeveli özel alanlarda doğru cevap veren oyuncu o kategorinin rozetini kazanır.\n\n'
              '• Altı rozeti tamamlayan oyuncu final sorusunu doğru cevaplayınca oyunu kazanır.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anladım'),
            ),
          ],
        );
      },
    );
  }
}

class CategoryPill extends StatelessWidget {
  const CategoryPill({required this.category, super.key});

  final GameCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: category.color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.emoji),
          const SizedBox(width: 7),
          Text(
            category.label,
            style: TextStyle(
              color: category.darkColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({required this.questionBank, super.key});

  final QuestionBank questionBank;

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  int _playerCount = 2;

  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(text: 'Oyuncu ${index + 1}'),
  );

  final List<int> _selectedPawnTypes = List<int>.generate(
    6,
    (index) => index,
  );

  static const List<Color> _playerColors = [
    Color(0xFFE11D48),
    Color(0xFF2563EB),
    Color(0xFF16A34A),
    Color(0xFF9333EA),
    Color(0xFFF97316),
    Color(0xFF0891B2),
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oyuncuları Hazırla')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Oyuncu sayısı: $_playerCount',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Slider(
                            min: 2,
                            max: 6,
                            divisions: 4,
                            value: _playerCount.toDouble(),
                            label: '$_playerCount',
                            onChanged: (value) {
                              setState(() => _playerCount = value.round());
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...List.generate(_playerCount, (index) {
                    final pawn = PawnCatalog.at(_selectedPawnTypes[index]);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => _showPawnPicker(index),
                              child: Container(
                                width: 84,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _playerColors[index].withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: _playerColors[index].withOpacity(0.35),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    PawnToken(
                                      type: _selectedPawnTypes[index],
                                      color: _playerColors[index],
                                      active: true,
                                      width: 42,
                                      height: 52,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      pawn.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        height: 1.05,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    const Text(
                                      'Değiştir',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _controllers[index],
                                maxLength: 16,
                                textCapitalization: TextCapitalization.words,
                                decoration: InputDecoration(
                                  counterText: '',
                                  labelText: '${index + 1}. oyuncu',
                                  helperText: 'Yanındaki piyona dokunarak seç',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: FilledButton.icon(
                onPressed: _startGame,
                icon: const Icon(Icons.casino_rounded),
                label: const Text(
                  'Tahtaya Geç',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPawnPicker(int playerIndex) async {
    final selected = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('${playerIndex + 1}. oyuncunun piyonu'),
          contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          content: SizedBox(
            width: double.maxFinite,
            height: 430,
            child: GridView.builder(
              itemCount: PawnCatalog.all.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                final pawn = PawnCatalog.all[index];
                final isSelected = _selectedPawnTypes[playerIndex] == index;

                return Material(
                  color: isSelected
                      ? _playerColors[playerIndex].withOpacity(0.14)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.pop(dialogContext, index),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? _playerColors[playerIndex]
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PawnToken(
                            type: index,
                            color: _playerColors[playerIndex],
                            active: isSelected,
                            width: 46,
                            height: 58,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            pawn.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              height: 1.05,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Vazgeç'),
            ),
          ],
        );
      },
    );

    if (selected == null || !mounted) return;

    setState(() {
      _selectedPawnTypes[playerIndex] = selected;
    });
  }

  void _startGame() {
    final players = <PlayerData>[];

    for (var index = 0; index < _playerCount; index++) {
      final name = _controllers[index].text.trim();

      players.add(
        PlayerData(
          name: name.isEmpty ? 'Oyuncu ${index + 1}' : name,
          color: _playerColors[index],
          pawnType: _selectedPawnTypes[index],
        ),
      );
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          questionBank: widget.questionBank,
          players: players,
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({
    required this.questionBank,
    required this.players,
    super.key,
  });

  final QuestionBank questionBank;
  final List<PlayerData> players;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Random _random = Random();
  int _currentPlayerIndex = 0;
  int? _lastDice;
  bool _isBusy = false;
  String _status = 'Zarı at ve rotaya çık.';
  PlayerData? _winner;

  PlayerData get _currentPlayer => widget.players[_currentPlayerIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bilgi Rotası'),
        actions: [
          IconButton(
            tooltip: 'Oyunu bitir',
            onPressed: _confirmExit,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 760;
            if (isWide) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildBoardCard()),
                    const SizedBox(width: 18),
                    SizedBox(width: 350, child: _buildControlPanel()),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
              clipBehavior: Clip.none,
              children: [
                _buildBoardCard(),
                const SizedBox(height: 14),
                _buildControlPanel(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBoardCard() {
    return Card(
      clipBehavior: Clip.none,
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final boardSize = constraints.maxWidth * 1.10;

                return SizedBox(
                  height: boardSize,
                  child: OverflowBox(
                    alignment: Alignment.topCenter,
                    minWidth: boardSize,
                    maxWidth: boardSize,
                    minHeight: boardSize,
                    maxHeight: boardSize,
                    child: GameBoard(
                      players: widget.players,
                      currentPlayerIndex: _currentPlayerIndex,
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 14),
              child: Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    PawnToken(
                      type: _currentPlayer.pawnType,
                      color: _currentPlayer.color,
                      active: true,
                      width: 44,
                      height: 54,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Sıra', style: TextStyle(fontSize: 13)),
                          Text(
                            _currentPlayer.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DiceFace(value: _lastDice),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Toplanan rozetler',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(GameCategory.values.length, (index) {
                    final category = GameCategory.values[index];
                    final earned = _currentPlayer.badges.contains(index);
                    return Tooltip(
                      message: category.label,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: earned ? category.color : const Color(0xFFE5E7EB),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: earned ? Colors.white : const Color(0xFFCBD5E1),
                            width: 2,
                          ),
                          boxShadow: earned
                              ? const [
                                  BoxShadow(
                                    blurRadius: 6,
                                    color: Color(0x33000000),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(earned ? '✓' : category.emoji),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _isBusy || _winner != null ? null : _onMainAction,
                  icon: Icon(
                    _currentPlayer.hasAllBadges
                        ? Icons.emoji_events_rounded
                        : Icons.casino_rounded,
                  ),
                  label: Text(
                    _isBusy
                        ? 'Bekle…'
                        : _currentPlayer.hasAllBadges
                            ? 'Final Sorusuna Geç'
                            : 'Zarı At',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Doğru: ${_currentPlayer.correctAnswers}   •   Yanlış: ${_currentPlayer.wrongAnswers}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Oyuncular',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                ...List.generate(widget.players.length, (index) {
                  final player = widget.players[index];
                  final active = index == _currentPlayerIndex;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: active
                          ? player.color.withOpacity(0.12)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: active
                            ? player.color.withOpacity(0.55)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        PawnToken(
                          type: player.pawnType,
                          color: player.color,
                          active: active,
                          width: 24,
                          height: 30,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            player.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                        ),
                        Text('${player.badges.length}/6'),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onMainAction() async {
    if (_currentPlayer.hasAllBadges) {
      await _askFinalQuestion();
    } else {
      await _rollDiceAndAsk();
    }
  }

  Future<void> _rollDiceAndAsk() async {
    if (_isBusy || _winner != null) return;

    setState(() {
      _isBusy = true;
      _lastDice = null;
      _status = '${_currentPlayer.name} zarı atıyor…';
    });

    HapticFeedback.mediumImpact();

    for (var i = 0; i < 12; i++) {
      await Future<void>.delayed(
        Duration(milliseconds: 65 + i * 8),
      );

      if (!mounted) return;

      setState(() {
        _lastDice = _random.nextInt(6) + 1;
      });

      if (i.isEven) {
        HapticFeedback.selectionClick();
      }
    }

    final diceResult = _random.nextInt(6) + 1;

    setState(() {
      _lastDice = diceResult;
      _status = '${_currentPlayer.name} $diceResult attı!';
    });

    HapticFeedback.heavyImpact();

    await Future<void>.delayed(
      const Duration(milliseconds: 1000),
    );

    if (!mounted) return;

    setState(() {
      _status =
          '${_currentPlayer.name} $diceResult attı. Yolunu seç.';
    });

    final options = BoardMap.options(
      _currentPlayer.position,
      diceResult,
    );

    if (!mounted) return;

    final selected = options.length == 1
        ? options.first
        : await _chooseMove(options);

    if (!mounted) return;

    if (selected == null) {
      setState(() {
        _isBusy = false;
        _status = 'Yol seçimi iptal edildi.';
      });
      return;
    }

    for (final id in selected.path.skip(1)) {
      setState(() => _currentPlayer.position = id);
      HapticFeedback.selectionClick();
      await Future<void>.delayed(const Duration(milliseconds: 220));
      if (!mounted) return;
    }

    final target = BoardMap.node(_currentPlayer.position);
    final categoryIndex = target.categoryIndex < 0
        ? _random.nextInt(GameCategory.values.length)
        : target.categoryIndex;

    setState(() {
      _status =
          '${_currentPlayer.name}, ${BoardMap.label(target.id)} alanına geldi.';
    });

    final question = widget.questionBank.randomQuestion(
      categoryIndex,
      _random,
    );

    final correct = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => QuestionScreen(
              question: question,
              isBadgeQuestion: target.isBadge,
            ),
          ),
        ) ??
        false;

    if (!mounted) return;

    _handleAnswer(
      correct: correct,
      categoryIndex: categoryIndex,
      wasBadgeCell: target.isBadge,
    );
  }

  Future<MoveOption?> _chooseMove(
    List<MoveOption> options,
  ) {
    return showDialog<MoveOption>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return SimpleDialog(
          title: Text('$_lastDice adım için yolunu seç'),
          children: options.map((option) {
            final target = BoardMap.node(option.destination);
            final category = target.categoryIndex < 0
                ? null
                : GameCategory.values[target.categoryIndex];

            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(dialogContext, option);
              },
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor:
                      category?.color ?? const Color(0xFF26364A),
                  child: Text(category?.emoji ?? '🧭'),
                ),
                title: Text(
                  BoardMap.routeTitle(option),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(
                  BoardMap.label(option.destination),
                ),
                trailing: const Icon(Icons.arrow_forward_rounded),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _askFinalQuestion() async {
    if (_isBusy || _winner != null) return;

    setState(() {
      _isBusy = true;
      _status = '${_currentPlayer.name} final sorusunda!';
    });

    final categoryIndex = _random.nextInt(GameCategory.values.length);
    final question = widget.questionBank.randomQuestion(categoryIndex, _random);

    final correct = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => QuestionScreen(
              question: question,
              isFinalQuestion: true,
            ),
          ),
        ) ??
        false;

    if (!mounted) return;

    if (correct) {
      _currentPlayer.correctAnswers++;
      setState(() {
        _winner = _currentPlayer;
        _status = '${_currentPlayer.name} Bilgi Rotası şampiyonu!';
        _isBusy = false;
      });
      HapticFeedback.heavyImpact();
      await _showWinnerDialog(_currentPlayer);
    } else {
      _currentPlayer.wrongAnswers++;
      _advanceTurn();
      setState(() {
        _status = 'Final kaçtı. Sıra ${_currentPlayer.name} oyuncusunda.';
        _isBusy = false;
      });
    }
  }

  void _handleAnswer({
    required bool correct,
    required int categoryIndex,
    required bool wasBadgeCell,
  }) {
    final answeredPlayer = _currentPlayer;

    if (correct) {
      answeredPlayer.correctAnswers++;
      var badgeMessage = '';
      if (wasBadgeCell && !answeredPlayer.badges.contains(categoryIndex)) {
        answeredPlayer.badges.add(categoryIndex);
        badgeMessage = ' ${GameCategory.values[categoryIndex].label} rozeti kazanıldı!';
      }

      setState(() {
        _status = answeredPlayer.hasAllBadges
            ? 'Altı rozet tamam! Final sorusu hazır. 🏆'
            : 'Doğru cevap!$badgeMessage Aynı oyuncu devam ediyor.';
        _isBusy = false;
      });
      HapticFeedback.selectionClick();
    } else {
      answeredPlayer.wrongAnswers++;
      _advanceTurn();
      setState(() {
        _status = 'Yanlış cevap. Sıra ${_currentPlayer.name} oyuncusunda.';
        _isBusy = false;
      });
    }
  }

  void _advanceTurn() {
    _currentPlayerIndex = (_currentPlayerIndex + 1) % widget.players.length;
    _lastDice = null;
  }

  Future<void> _showWinnerDialog(PlayerData player) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('🏆 Şampiyon belli oldu!'),
          content: Text(
            '${player.name} altı rozeti tamamladı ve final sorusunu bildi.\n\n'
            'Doğru: ${player.correctAnswers}\nYanlış: ${player.wrongAnswers}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(this.context).popUntil((route) => route.isFirst);
              },
              child: const Text('Ana Menü'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(this.context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => PlayerSetupScreen(
                      questionBank: widget.questionBank,
                    ),
                  ),
                );
              },
              child: const Text('Yeni Oyun'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmExit() async {
    final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Oyunu bitir?'),
              content: const Text('Bu oyundaki ilerleme kaybolacak.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Devam Et'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Bitir'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (shouldExit && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

}

enum BoardNodeKind { center, spoke, outer }

class BoardNode {
  const BoardNode({
    required this.id,
    required this.kind,
    required this.categoryIndex,
    this.arm,
    this.step,
    this.ring,
    this.isBadge = false,
  });

  final int id;
  final BoardNodeKind kind;
  final int categoryIndex;
  final int? arm;
  final int? step;
  final int? ring;
  final bool isBadge;
}

class MoveOption {
  const MoveOption(this.path);

  final List<int> path;
  int get destination => path.last;
}

class BoardMap {
  static const centerId = 0;
  static const outerCount = 36;
  static const spokeCount = 6;
  static const spokeLength = 5;
  static const outerStart = 1;
  static const spokeStart = 37;

  static const directions = [
    'Kuzey',
    'Kuzeydoğu',
    'Güneydoğu',
    'Güney',
    'Güneybatı',
    'Kuzeybatı',
  ];


  static const spokeMix = <List<int>>[
    [3, 1, 5, 2, 4],
    [4, 2, 0, 5, 3],
    [5, 3, 1, 0, 4],
    [0, 4, 2, 1, 5],
    [1, 5, 3, 2, 0],
    [2, 0, 4, 3, 1],
  ];

  static const outerMix = <List<int>>[
    [2, 5, 1, 4, 3],
    [3, 0, 4, 2, 5],
    [4, 1, 5, 3, 0],
    [5, 2, 0, 4, 1],
    [0, 3, 1, 5, 2],
    [1, 4, 2, 0, 3],
  ];

  static int outerId(int ring) {
    final value = (ring % outerCount + outerCount) % outerCount;
    return outerStart + value;
  }

  static int spokeId(int arm, int step) {
    return spokeStart + arm * spokeLength + step;
  }

  static BoardNode node(int id) {
    if (id == centerId) {
      return const BoardNode(
        id: centerId,
        kind: BoardNodeKind.center,
        categoryIndex: -1,
      );
    }

    if (id >= outerStart && id < outerStart + outerCount) {
      final ring = id - outerStart;
      final badge = ring % 6 == 0;

      return BoardNode(
        id: id,
        kind: BoardNodeKind.outer,
        categoryIndex: badge
            ? ring ~/ 6
            : outerMix[ring ~/ 6][(ring % 6) - 1],
        ring: ring,
        isBadge: badge,
      );
    }

    final offset = id - spokeStart;
    if (offset >= 0 && offset < spokeCount * spokeLength) {
      final arm = offset ~/ spokeLength;
      final step = offset % spokeLength;

      return BoardNode(
        id: id,
        kind: BoardNodeKind.spoke,
        categoryIndex: spokeMix[arm][step],
        arm: arm,
        step: step,
      );
    }

    throw RangeError('Geçersiz tahta alanı: $id');
  }

  static List<int> neighbors(int id) {
    final n = node(id);

    switch (n.kind) {
      case BoardNodeKind.center:
        return List.generate(
          spokeCount,
          (arm) => spokeId(arm, 0),
        );

      case BoardNodeKind.spoke:
        final result = <int>[];
        result.add(
          n.step == 0
              ? centerId
              : spokeId(n.arm!, n.step! - 1),
        );
        result.add(
          n.step == spokeLength - 1
              ? outerId(n.arm! * 6)
              : spokeId(n.arm!, n.step! + 1),
        );
        return result;

      case BoardNodeKind.outer:
        final result = <int>[
          outerId(n.ring! - 1),
          outerId(n.ring! + 1),
        ];

        if (n.ring! % 6 == 0) {
          result.add(
            spokeId(n.ring! ~/ 6, spokeLength - 1),
          );
        }

        return result;
    }
  }

  static List<MoveOption> options(int start, int steps) {
    final found = <List<int>>[];

    void walk(int current, int left, List<int> path) {
      if (left == 0) {
        found.add(path);
        return;
      }

      for (final next in neighbors(current)) {
        if (path.contains(next)) continue;
        walk(next, left - 1, [...path, next]);
      }
    }

    walk(start, steps, [start]);

    final unique = <int, MoveOption>{};
    for (final path in found) {
      unique.putIfAbsent(path.last, () => MoveOption(path));
    }

    return unique.values.toList();
  }

  static String routeTitle(MoveOption option) {
    final start = node(option.path.first);
    final first = node(option.path[1]);

    if (start.kind == BoardNodeKind.center) {
      return '${directions[first.arm!]} yolunu seç';
    }

    if (start.kind == BoardNodeKind.outer &&
        first.kind == BoardNodeKind.outer) {
      final clockwise =
          (first.ring! - start.ring! + outerCount) % outerCount == 1;
      return clockwise
          ? 'Saat yönünde ilerle'
          : 'Saat yönünün tersine ilerle';
    }

    if (first.kind == BoardNodeKind.center) {
      return 'Merkeze gir';
    }

    if (start.kind == BoardNodeKind.outer &&
        first.kind == BoardNodeKind.spoke) {
      return 'Merkeze doğru ilerle';
    }

    if (start.kind == BoardNodeKind.spoke &&
        first.kind == BoardNodeKind.spoke) {
      return first.step! < start.step!
          ? 'Merkeze doğru ilerle'
          : 'Dış halkaya doğru ilerle';
    }

    return 'Dış halkaya çık';
  }

  static String label(int id) {
    final n = node(id);

    if (n.kind == BoardNodeKind.center) {
      return 'Merkez altıgen';
    }

    final category = GameCategory.values[n.categoryIndex];

    if (n.isBadge) {
      return '${category.label} rozet alanı';
    }

    if (n.kind == BoardNodeKind.spoke) {
      return '${directions[n.arm!]} bağlantısı • ${category.label}';
    }

    return 'Dış halka • ${category.label}';
  }

  static double base(Size size) {
    return min(size.width, size.height);
  }

  static Offset center(Size size) {
    return Offset(size.width / 2, size.height / 2);
  }

  static double armAngle(int arm) {
    return -pi / 2 + arm * (2 * pi / spokeCount);
  }

  static Offset position(Size size, int id) {
    final n = node(id);
    final c = center(size);
    final b = base(size);

    if (n.kind == BoardNodeKind.center) return c;

    if (n.kind == BoardNodeKind.outer) {
      final angle = -pi / 2 + n.ring! * (2 * pi / outerCount);
      return c + Offset(cos(angle), sin(angle)) * b * 0.42;
    }

    final angle = armAngle(n.arm!);
    final radius = b * (0.155 + n.step! * 0.049);
    return c + Offset(cos(angle), sin(angle)) * radius;
  }
}

class PawnDefinition {
  const PawnDefinition({
    required this.name,
    required this.symbol,
  });

  final String name;
  final String symbol;
}

class PawnCatalog {
  static const List<PawnDefinition> all = [
    PawnDefinition(name: 'Renkli Halka', symbol: '◉'),
    PawnDefinition(name: 'Bilgi Taşı', symbol: '🧠'),
    PawnDefinition(name: 'Beyin Maskotu', symbol: '🧠'),
    PawnDefinition(name: 'Klasik Piyon', symbol: '♟'),
    PawnDefinition(name: 'Bilge At Piyonu', symbol: '♞'),
    PawnDefinition(name: 'Kristal Zar Piyonu', symbol: '🎲'),
    PawnDefinition(name: 'Pusula Yıldızı', symbol: '🧭'),
    PawnDefinition(name: 'Açık Kitap', symbol: '📖'),
    PawnDefinition(name: 'Ampul Fikri', symbol: '💡'),
    PawnDefinition(name: 'Kum Saati', symbol: '⏳'),
    PawnDefinition(name: 'Soru İşareti', symbol: '?'),
    PawnDefinition(name: 'Kupa Rozet', symbol: '🏆'),
  ];

  static PawnDefinition at(int index) {
    final normalized = (index % all.length + all.length) % all.length;
    return all[normalized];
  }
}

class PawnToken extends StatelessWidget {
  const PawnToken({
    required this.type,
    required this.color,
    required this.active,
    required this.width,
    required this.height,
    super.key,
  });

  final int type;
  final Color color;
  final bool active;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (type == 0) {
      return SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: RingPawnPainter(color: color, active: active),
        ),
      );
    }

    if (type == 3) {
      return SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: ClassicPawnPainter(color: color, active: active),
        ),
      );
    }

    final pawn = PawnCatalog.at(type);
    final isGem = type == 1 || type == 5 || type == 11;
    final isRound = type == 2 || type == 6 || type == 8 || type == 10;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          if (active)
            Positioned(
              top: height * 0.05,
              child: Container(
                width: width * 0.96,
                height: width * 0.96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.42),
                      blurRadius: width * 0.32,
                      spreadRadius: width * 0.05,
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            child: Container(
              width: width * 0.82,
              height: height * 0.16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFE79A),
                    Color(0xFFD49A22),
                    Color(0xFF8A5914),
                  ],
                ),
                boxShadow: const [
                  BoxShadow(
                    offset: Offset(0, 2),
                    blurRadius: 3,
                    color: Color(0x66000000),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: height * 0.03,
            child: Transform.rotate(
              angle: isGem ? pi / 4 : 0,
              child: Container(
                width: width * 0.82,
                height: height * 0.67,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: isRound ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius: isRound
                      ? null
                      : BorderRadius.circular(isGem ? 7 : 12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(color, Colors.white, 0.60)!,
                      color,
                      Color.lerp(color, Colors.black, 0.36)!,
                    ],
                    stops: const [0, 0.58, 1],
                  ),
                  border: Border.all(
                    color: const Color(0xFFFFE79A),
                    width: active ? 2.2 : 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(0, 3),
                      blurRadius: 4,
                      color: Color(0x66000000),
                    ),
                  ],
                ),
                child: Transform.rotate(
                  angle: isGem ? -pi / 4 : 0,
                  child: Text(
                    pawn.symbol,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: type == 10 ? width * 0.48 : width * 0.39,
                      height: 1,
                      color: type == 10 ? Colors.white : null,
                      fontWeight: FontWeight.w900,
                      shadows: const [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 2,
                          color: Color(0x77000000),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: height * 0.09,
            left: width * 0.28,
            child: Container(
              width: width * 0.10,
              height: width * 0.10,
              decoration: const BoxDecoration(
                color: Color(0xCCFFFFFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RingPawnPainter extends CustomPainter {
  const RingPawnPainter({required this.color, required this.active});

  final Color color;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.40);
    final radius = size.width * 0.34;

    if (active) {
      canvas.drawCircle(
        center,
        radius * 1.35,
        Paint()
          ..color = color.withOpacity(0.30)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.91),
        width: size.width * 0.82,
        height: size.height * 0.15,
      ),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFE79A),
            Color(0xFFD49A22),
            Color(0xFF8A5914),
          ],
        ).createShader(Offset.zero & size),
    );

    canvas.drawCircle(
      center.translate(0, size.height * 0.035),
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.23
        ..color = const Color(0xFF875817),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.21
        ..shader = SweepGradient(
          colors: [
            color,
            Color.lerp(color, Colors.white, 0.65)!,
            Color.lerp(color, Colors.black, 0.25)!,
            color,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    canvas.drawCircle(
      center,
      radius * 1.12,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0xFFFFE79A),
    );
  }

  @override
  bool shouldRepaint(covariant RingPawnPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.active != active;
  }
}

class ClassicPawnPainter extends CustomPainter {
  const ClassicPawnPainter({required this.color, required this.active});

  final Color color;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    if (active) {
      canvas.drawCircle(
        Offset(size.width / 2, size.height * 0.48),
        size.width * 0.52,
        Paint()
          ..color = color.withOpacity(0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.92),
        width: size.width * 0.84,
        height: size.height * 0.16,
      ),
      Paint()
        ..color = const Color(0x66000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    final bounds = Offset.zero & size;
    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(color, Colors.white, 0.65)!,
          color,
          Color.lerp(color, Colors.black, 0.42)!,
        ],
      ).createShader(bounds);

    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = active ? 2.1 : 1.4
      ..color = const Color(0xFFFFE79A);

    final head = Offset(size.width / 2, size.height * 0.22);
    final headRadius = size.width * 0.24;
    canvas.drawCircle(head, headRadius, fill);
    canvas.drawCircle(head, headRadius, outline);

    final body = Path()
      ..moveTo(size.width * 0.39, size.height * 0.42)
      ..quadraticBezierTo(
        size.width * 0.30,
        size.height * 0.61,
        size.width * 0.22,
        size.height * 0.79,
      )
      ..quadraticBezierTo(
        size.width * 0.16,
        size.height * 0.87,
        size.width * 0.28,
        size.height * 0.90,
      )
      ..lineTo(size.width * 0.72, size.height * 0.90)
      ..quadraticBezierTo(
        size.width * 0.84,
        size.height * 0.87,
        size.width * 0.78,
        size.height * 0.79,
      )
      ..quadraticBezierTo(
        size.width * 0.70,
        size.height * 0.61,
        size.width * 0.61,
        size.height * 0.42,
      )
      ..close();

    canvas.drawPath(body, fill);
    canvas.drawPath(body, outline);

    final baseRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.88),
      width: size.width * 0.72,
      height: size.height * 0.16,
    );
    canvas.drawOval(baseRect, fill);
    canvas.drawOval(baseRect, outline);
  }

  @override
  bool shouldRepaint(covariant ClassicPawnPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.active != active;
  }
}

class GameBoard extends StatelessWidget {
  const GameBoard({
    required this.players,
    required this.currentPlayerIndex,
    super.key,
  });

  final List<PlayerData> players;
  final int currentPlayerIndex;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(
            constraints.maxWidth,
            constraints.maxHeight,
          );
          final base = BoardMap.base(size);
          final boardCenter = BoardMap.center(size);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned.fill(
                child: CustomPaint(
                  painter: BoardPainter(),
                ),
              ),
              ...List.generate(players.length, (index) {
                final player = players[index];
                var point = BoardMap.position(size, player.position);
                final active = index == currentPlayerIndex;

                final stackedBefore = players
                    .take(index)
                    .where((other) => other.position == player.position)
                    .length;

                if (player.position == BoardMap.centerId) {
                  final divisor = players.isEmpty ? 1 : players.length;
                  final angle = -pi / 2 +
                      index * (2 * pi / divisor.toDouble());
                  point = boardCenter +
                      Offset(cos(angle), sin(angle)) * base * 0.052;
                } else if (stackedBefore > 0) {
                  final radialAngle = atan2(
                    point.dy - boardCenter.dy,
                    point.dx - boardCenter.dx,
                  );
                  final tangent = Offset(
                    -sin(radialAngle),
                    cos(radialAngle),
                  );
                  point += tangent *
                      stackedBefore.toDouble() *
                      base *
                      0.024;
                }

                final pawnWidth = active ? base * 0.046 : base * 0.040;
                final pawnHeight = active ? base * 0.060 : base * 0.053;

                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 430),
                  curve: Curves.easeOutBack,
                  left: point.dx - pawnWidth / 2,
                  top: point.dy - pawnHeight * 0.76,
                  child: PawnToken(
                    type: player.pawnType,
                    color: player.color,
                    active: active,
                    width: pawnWidth,
                    height: pawnHeight,
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class BoardPainter extends CustomPainter {
  const BoardPainter();

  static const _gold = Color(0xFFE8C76A);
  static const _darkGold = Color(0xFF7B5721);
  static const _deepPurple = Color(0xFF24122F);

  @override
  void paint(Canvas canvas, Size size) {
    final base = BoardMap.base(size);
    final center = BoardMap.center(size);

    final boardRect = Rect.fromCenter(
      center: center,
      width: base * 0.98,
      height: base * 0.98,
    );
    final boardShape = RRect.fromRectAndRadius(
      boardRect,
      Radius.circular(base * 0.042),
    );

    canvas.drawShadow(
      Path()..addRRect(boardShape),
      const Color(0xAA000000),
      15,
      true,
    );

    canvas.drawRRect(
      boardShape,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF56336B),
            Color(0xFF382047),
            Color(0xFF1D1027),
          ],
        ).createShader(boardRect),
    );

    canvas.drawRRect(
      boardShape.deflate(base * 0.012),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..color = _gold,
    );
    canvas.drawRRect(
      boardShape.deflate(base * 0.024),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = const Color(0x99FBE7A2),
    );

    _drawDecorativeWedges(canvas, center, base);
    _drawFoundations(canvas, center, base);
    _drawSpokeTiles(canvas, size, base);
    _drawOuterTiles(canvas, size, base);
    _drawCenterHex(canvas, center, base);
  }

  void _drawDecorativeWedges(Canvas canvas, Offset center, double base) {
    for (var arm = 0; arm < 6; arm++) {
      final angle = BoardMap.armAngle(arm);
      final left = angle - pi / 6;
      final right = angle + pi / 6;
      final path = Path()
        ..moveTo(
          center.dx + cos(left) * base * 0.14,
          center.dy + sin(left) * base * 0.14,
        )
        ..lineTo(
          center.dx + cos(left) * base * 0.375,
          center.dy + sin(left) * base * 0.375,
        )
        ..arcTo(
          Rect.fromCircle(center: center, radius: base * 0.375),
          left,
          pi / 3,
          false,
        )
        ..lineTo(
          center.dx + cos(right) * base * 0.14,
          center.dy + sin(right) * base * 0.14,
        )
        ..close();

      canvas.drawPath(
        path,
        Paint()
          ..color = arm.isEven
              ? const Color(0x18000000)
              : const Color(0x0EFFFFFF),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = const Color(0x33E8C76A),
      );
    }
  }

  void _drawFoundations(Canvas canvas, Offset center, double base) {
    canvas.drawCircle(
      center.translate(0, base * 0.013),
      base * 0.420,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = base * 0.086
        ..color = const Color(0x99000000),
    );
    canvas.drawCircle(
      center,
      base * 0.420,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = base * 0.084
        ..color = _darkGold,
    );
    canvas.drawCircle(
      center,
      base * 0.420,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = base * 0.071
        ..color = const Color(0xFF2B1837),
    );

    for (var arm = 0; arm < 6; arm++) {
      final direction = Offset(
        cos(BoardMap.armAngle(arm)),
        sin(BoardMap.armAngle(arm)),
      );
      final start = center + direction * base * 0.125;
      final end = center + direction * base * 0.368;

      canvas.drawLine(
        start.translate(0, base * 0.012),
        end.translate(0, base * 0.012),
        Paint()
          ..strokeWidth = base * 0.123
          ..strokeCap = StrokeCap.butt
          ..color = const Color(0x88000000),
      );
      canvas.drawLine(
        start,
        end,
        Paint()
          ..strokeWidth = base * 0.121
          ..strokeCap = StrokeCap.butt
          ..color = _darkGold,
      );
      canvas.drawLine(
        start,
        end,
        Paint()
          ..strokeWidth = base * 0.106
          ..strokeCap = StrokeCap.butt
          ..color = _deepPurple,
      );
    }
  }

  void _drawSpokeTiles(Canvas canvas, Size size, double base) {
    for (var arm = 0; arm < 6; arm++) {
      final angle = BoardMap.armAngle(arm);
      for (var step = 0; step < 5; step++) {
        final id = BoardMap.spokeId(arm, step);
        final node = BoardMap.node(id);
        _drawRaisedTile(
          canvas: canvas,
          center: BoardMap.position(size, id),
          angle: angle,
          width: base * 0.102,
          height: base * 0.045,
          category: GameCategory.values[node.categoryIndex],
          base: base,
          iconSize: base * 0.018,
        );
      }
    }
  }

  void _drawOuterTiles(Canvas canvas, Size size, double base) {
    for (var ring = 0; ring < 36; ring++) {
      final id = BoardMap.outerId(ring);
      final node = BoardMap.node(id);
      final angle = -pi / 2 + ring * (2 * pi / 36);
      final category = GameCategory.values[node.categoryIndex];

      if (node.isBadge) {
        _drawBadgeMedallion(
          canvas,
          BoardMap.position(size, id),
          category,
          base,
        );
      } else {
        _drawRaisedTile(
          canvas: canvas,
          center: BoardMap.position(size, id),
          angle: angle,
          width: base * 0.071,
          height: base * 0.052,
          category: category,
          base: base,
          iconSize: base * 0.015,
        );
      }
    }
  }

  void _drawRaisedTile({
    required Canvas canvas,
    required Offset center,
    required double angle,
    required double width,
    required double height,
    required GameCategory category,
    required double base,
    required double iconSize,
  }) {
    final depth = base * 0.010;

    void drawAt(Offset tileCenter, bool top) {
      canvas.save();
      canvas.translate(tileCenter.dx, tileCenter.dy);
      canvas.rotate(angle + pi / 2);

      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: width,
        height: height,
      );
      final shape = RRect.fromRectAndRadius(
        rect,
        Radius.circular(base * 0.006),
      );

      if (!top) {
        canvas.drawRRect(
          shape.inflate(base * 0.004),
          Paint()..color = _darkGold,
        );
        canvas.drawRRect(
          shape,
          Paint()
            ..color = Color.lerp(category.color, Colors.black, 0.52)!,
        );
      } else {
        canvas.drawRRect(
          shape.inflate(base * 0.003),
          Paint()..color = _gold,
        );
        canvas.drawRRect(
          shape,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(category.color, Colors.white, 0.48)!,
                category.color,
                Color.lerp(category.color, Colors.black, 0.25)!,
              ],
              stops: const [0, 0.58, 1],
            ).createShader(rect),
        );
        canvas.drawLine(
          Offset(rect.left + base * 0.007, rect.top + base * 0.005),
          Offset(rect.right - base * 0.007, rect.top + base * 0.005),
          Paint()
            ..strokeWidth = 1.2
            ..strokeCap = StrokeCap.round
            ..color = const Color(0xAAFFFFFF),
        );
        _drawText(
          canvas,
          category.emoji,
          Offset.zero,
          iconSize,
          Colors.white,
        );
      }

      canvas.restore();
    }

    drawAt(center.translate(0, depth), false);
    drawAt(center, true);
  }

  void _drawBadgeMedallion(
    Canvas canvas,
    Offset center,
    GameCategory category,
    double base,
  ) {
    final radius = base * 0.043;
    final depth = base * 0.012;

    canvas.drawCircle(
      center.translate(0, depth + base * 0.004),
      radius * 1.12,
      Paint()
        ..color = const Color(0x77000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(
      center.translate(0, depth),
      radius * 1.07,
      Paint()..color = _darkGold,
    );
    canvas.drawCircle(
      center,
      radius * 1.08,
      Paint()..color = _gold,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.38, -0.42),
          colors: [
            Color.lerp(category.color, Colors.white, 0.50)!,
            category.color,
            Color.lerp(category.color, Colors.black, 0.30)!,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xCCFFFFFF),
    );
    _drawText(
      canvas,
      category.emoji,
      center,
      base * 0.027,
      Colors.white,
    );
  }

  void _drawCenterHex(Canvas canvas, Offset center, double base) {
    final radius = base * 0.124;
    final depth = base * 0.015;

    Path makeHex(Offset c) {
      final path = Path();
      for (var i = 0; i < 6; i++) {
        final angle = -pi / 2 + i * (2 * pi / 6);
        final point = c + Offset(cos(angle), sin(angle)) * radius;
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      return path..close();
    }

    final lower = makeHex(center.translate(0, depth));
    final upper = makeHex(center);

    canvas.drawShadow(lower, const Color(0xAA000000), 9, true);
    canvas.drawPath(lower, Paint()..color = _darkGold);
    canvas.drawPath(
      upper,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.38),
          colors: [
            Color(0xFF2B7184),
            Color(0xFF153E50),
            Color(0xFF071E2A),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawPath(
      upper,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..color = const Color(0xFFFFD978),
    );

    _drawText(
      canvas,
      '🧭',
      center.translate(0, -base * 0.025),
      base * 0.030,
      Colors.white,
    );
    _drawText(
      canvas,
      'BİLGİ\nROTASI',
      center.translate(0, base * 0.030),
      base * 0.020,
      Colors.white,
      bold: true,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center,
    double fontSize,
    Color color, {
    bool bold = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          height: 1,
          color: color,
          fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          shadows: const [
            Shadow(
              offset: Offset(0, 1.5),
              blurRadius: 2,
              color: Color(0x88000000),
            ),
          ],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(
      canvas,
      Offset(
        center.dx - painter.width / 2,
        center.dy - painter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DiceFace extends StatelessWidget {
  const DiceFace({required this.value, super.key});

  final int? value;

  static const Map<int, String> _faces = {
    1: '⚀',
    2: '⚁',
    3: '⚂',
    4: '⚃',
    5: '⚄',
    6: '⚅',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 130),
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: Tween<double>(
              begin: 0,
              end: 0.25,
            ).animate(animation),
            child: ScaleTransition(
              scale: animation,
              child: child,
            ),
          );
        },
        child: Text(
          value == null ? '🎲' : _faces[value]!,
          key: ValueKey<int?>(value),
          style: const TextStyle(
            fontSize: 33,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({
    required this.question,
    this.isBadgeQuestion = false,
    this.isFinalQuestion = false,
    super.key,
  });

  final QuizQuestion question;
  final bool isBadgeQuestion;
  final bool isFinalQuestion;

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int? _selectedIndex;

  bool get _answered => _selectedIndex != null;
  bool get _correct => _selectedIndex == widget.question.answerIndex;

  @override
  Widget build(BuildContext context) {
    final category = GameCategory.values[widget.question.categoryIndex];

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Color.alphaBlend(
          category.color.withOpacity(0.10),
          Colors.white,
        ),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color.alphaBlend(
            category.color.withOpacity(0.10),
            Colors.white,
          ),
          foregroundColor: category.darkColor,
          surfaceTintColor: Colors.transparent,
          title: Text(
            widget.isFinalQuestion
                ? '🏆 Final Sorusu'
                : widget.isBadgeQuestion
                    ? '⭐ ${category.label} Rozet Sorusu'
                    : '${category.emoji} ${category.label}',
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: category.color.withOpacity(0.28)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: category.color.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              widget.question.difficulty,
                              style: TextStyle(
                                color: category.darkColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(category.emoji, style: const TextStyle(fontSize: 26)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        widget.question.text,
                        style: const TextStyle(
                          fontSize: 23,
                          height: 1.25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: widget.question.options.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _buildOption(index, category);
                    },
                  ),
                ),
                if (_answered) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _correct
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _correct
                          ? 'Doğru! ${widget.question.explanation}'
                          : 'Yanlış. Doğru cevap: ${widget.question.options[widget.question.answerIndex]}. ${widget.question.explanation}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, _correct),
                    child: const Text(
                      'Devam Et',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption(int index, GameCategory category) {
    final isSelected = _selectedIndex == index;
    final isCorrectOption = widget.question.answerIndex == index;

    Color background = Colors.white;
    Color border = const Color(0xFFCBD5E1);
    IconData? trailingIcon;

    if (_answered) {
      if (isCorrectOption) {
        background = const Color(0xFFDCFCE7);
        border = const Color(0xFF16A34A);
        trailingIcon = Icons.check_circle_rounded;
      } else if (isSelected) {
        background = const Color(0xFFFEE2E2);
        border = const Color(0xFFDC2626);
        trailingIcon = Icons.cancel_rounded;
      }
    }

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _answered
            ? null
            : () {
                HapticFeedback.selectionClick();
                setState(() => _selectedIndex = index);
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border, width: isSelected ? 2 : 1.2),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.13),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    color: category.darkColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.question.options[index],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailingIcon != null) Icon(trailingIcon),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayerData {
  PlayerData({
    required this.name,
    required this.color,
    required this.pawnType,
  });

  final String name;
  final Color color;
  final int pawnType;
  int position = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  final Set<int> badges = <int>{};

  bool get hasAllBadges => badges.length == GameCategory.values.length;
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.categoryIndex,
    required this.text,
    required this.options,
    required this.answerIndex,
    required this.difficulty,
    required this.explanation,
  });

  final String id;
  final int categoryIndex;
  final String text;
  final List<String> options;
  final int answerIndex;
  final String difficulty;
  final String explanation;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      categoryIndex: json['categoryIndex'] as int,
      text: json['question'] as String,
      options: List<String>.from(json['options'] as List<dynamic>),
      answerIndex: json['answerIndex'] as int,
      difficulty: (json['difficulty'] as String?) ?? 'Orta',
      explanation: (json['explanation'] as String?) ?? '',
    );
  }
}

class QuestionBank {
  QuestionBank(this.questionsByCategory);

  final Map<int, List<QuizQuestion>> questionsByCategory;

  int get totalCount => questionsByCategory.values.fold<int>(
        0,
        (sum, questions) => sum + questions.length,
      );

  static Future<QuestionBank> load() async {
    final raw = await rootBundle.loadString('assets/questions.json');
    final decoded = jsonDecode(raw) as List<dynamic>;
    final questions = decoded
        .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
        .toList();

    final grouped = <int, List<QuizQuestion>>{};
    for (final question in questions) {
      grouped.putIfAbsent(question.categoryIndex, () => []).add(question);
    }

    for (var index = 0; index < GameCategory.values.length; index++) {
      if (grouped[index] == null || grouped[index]!.isEmpty) {
        throw StateError('${GameCategory.values[index].label} kategorisinde soru yok.');
      }
    }

    return QuestionBank(grouped);
  }

  QuizQuestion randomQuestion(int categoryIndex, Random random) {
    final list = questionsByCategory[categoryIndex];
    if (list == null || list.isEmpty) {
      throw StateError('Kategori için soru bulunamadı: $categoryIndex');
    }
    return list[random.nextInt(list.length)];
  }
}

enum GameCategory {
  geography,
  entertainment,
  history,
  artLiterature,
  scienceNature,
  sports,
}

extension GameCategoryX on GameCategory {
  String get label {
    switch (this) {
      case GameCategory.geography:
        return 'Coğrafya';
      case GameCategory.entertainment:
        return 'Eğlence';
      case GameCategory.history:
        return 'Tarih';
      case GameCategory.artLiterature:
        return 'Sanat & Edebiyat';
      case GameCategory.scienceNature:
        return 'Bilim & Doğa';
      case GameCategory.sports:
        return 'Spor';
    }
  }

  String get emoji {
    switch (this) {
      case GameCategory.geography:
        return '🌍';
      case GameCategory.entertainment:
        return '🎬';
      case GameCategory.history:
        return '🏛️';
      case GameCategory.artLiterature:
        return '🎨';
      case GameCategory.scienceNature:
        return '🔬';
      case GameCategory.sports:
        return '⚽';
    }
  }

  Color get color {
    switch (this) {
      case GameCategory.geography:
        return const Color(0xFF2563EB);
      case GameCategory.entertainment:
        return const Color(0xFFDB2777);
      case GameCategory.history:
        return const Color(0xFFEAB308);
      case GameCategory.artLiterature:
        return const Color(0xFF9333EA);
      case GameCategory.scienceNature:
        return const Color(0xFF16A34A);
      case GameCategory.sports:
        return const Color(0xFFF97316);
    }
  }

  Color get darkColor {
    switch (this) {
      case GameCategory.geography:
        return const Color(0xFF1E3A8A);
      case GameCategory.entertainment:
        return const Color(0xFF831843);
      case GameCategory.history:
        return const Color(0xFF854D0E);
      case GameCategory.artLiterature:
        return const Color(0xFF581C87);
      case GameCategory.scienceNature:
        return const Color(0xFF14532D);
      case GameCategory.sports:
        return const Color(0xFF9A3412);
    }
  }
}
