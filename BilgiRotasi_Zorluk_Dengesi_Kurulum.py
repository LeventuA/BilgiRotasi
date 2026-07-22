#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess

MAIN = Path("lib/main.dart")
PART = Path("lib/difficulty_balance.dart")
PUBSPEC = Path("pubspec.yaml")

def fail(message: str) -> None:
    raise SystemExit(f"\n❌ {message}\n")

def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        fail(
            f"{label} bölümü güvenli biçimde bulunamadı "
            f"(eşleşme sayısı: {count}).\n"
            "Repo başka bir güncelleme aldıysa bu çıktıyı ChatGPT'ye gönder."
        )
    return text.replace(old, new, 1)

for path in (MAIN, PUBSPEC):
    if not path.exists():
        fail(
            f"Gerekli dosya bulunamadı: {path}\n"
            "Kurulum dosyasını BilgiRotasi deposunun ana klasöründe çalıştır."
        )

branch = subprocess.run(
    ["git", "branch", "--show-current"],
    check=True,
    capture_output=True,
    text=True,
).stdout.strip()

if branch != "main":
    fail(f"Bu paket main dalında çalıştırılmalı. Mevcut dal: {branch or 'bilinmiyor'}")

main = MAIN.read_text(encoding="utf-8")
pubspec = PUBSPEC.read_text(encoding="utf-8")

marker = "enum DifficultyMode {"
already_installed = marker in main or (
    PART.exists() and marker in PART.read_text(encoding="utf-8")
)
if already_installed:
    fail("Zorluk Dengesi sistemi bu repoda zaten kurulu görünüyor.")

part_content = "part of 'main.dart';\n\nenum DifficultyMode {\n  relaxed,\n  balanced,\n  expert,\n}\n\nDifficultyMode difficultyModeFromName(Object? value) {\n  final name = value?.toString();\n\n  for (final mode in DifficultyMode.values) {\n    if (mode.name == name) return mode;\n  }\n\n  return DifficultyMode.relaxed;\n}\n\nextension DifficultyModeX on DifficultyMode {\n  String get label {\n    switch (this) {\n      case DifficultyMode.relaxed:\n        return 'Rahat';\n      case DifficultyMode.balanced:\n        return 'Dengeli';\n      case DifficultyMode.expert:\n        return 'Uzman';\n    }\n  }\n\n  String get emoji {\n    switch (this) {\n      case DifficultyMode.relaxed:\n        return '🌿';\n      case DifficultyMode.balanced:\n        return '⚖️';\n      case DifficultyMode.expert:\n        return '🔥';\n    }\n  }\n\n  String get description {\n    switch (this) {\n      case DifficultyMode.relaxed:\n        return '%80 kolay • %18 orta • %2 zor';\n      case DifficultyMode.balanced:\n        return '%60 kolay • %30 orta • %10 zor';\n      case DifficultyMode.expert:\n        return '%30 kolay • %45 orta • %25 zor';\n    }\n  }\n\n  Map<String, int> get weights {\n    switch (this) {\n      case DifficultyMode.relaxed:\n        return <String, int>{\n          'Kolay': 80,\n          'Orta': 18,\n          'Zor': 2,\n        };\n      case DifficultyMode.balanced:\n        return <String, int>{\n          'Kolay': 60,\n          'Orta': 30,\n          'Zor': 10,\n        };\n      case DifficultyMode.expert:\n        return <String, int>{\n          'Kolay': 30,\n          'Orta': 45,\n          'Zor': 25,\n        };\n    }\n  }\n\n  DifficultyMode get oneStepHarder {\n    switch (this) {\n      case DifficultyMode.relaxed:\n        return DifficultyMode.balanced;\n      case DifficultyMode.balanced:\n      case DifficultyMode.expert:\n        return DifficultyMode.expert;\n    }\n  }\n\n  String chooseDifficulty(\n    Random random, {\n    int correctStreak = 0,\n    int wrongStreak = 0,\n    bool finalQuestion = false,\n    bool forceRelaxed = false,\n  }) {\n    var effectiveMode =\n        forceRelaxed ? DifficultyMode.relaxed : this;\n\n    if (finalQuestion) {\n      effectiveMode = effectiveMode.oneStepHarder;\n    }\n\n    final values = Map<String, int>.from(effectiveMode.weights);\n\n    if (wrongStreak >= 2) {\n      final hardShift = min(12, values['Zor'] ?? 0);\n      final mediumShift = min(13, values['Orta'] ?? 0);\n\n      values['Zor'] = (values['Zor'] ?? 0) - hardShift;\n      values['Orta'] = (values['Orta'] ?? 0) - mediumShift;\n      values['Kolay'] =\n          (values['Kolay'] ?? 0) + hardShift + mediumShift;\n    } else if (correctStreak >= 3) {\n      final easyShift = min(15, values['Kolay'] ?? 0);\n      final mediumShift = min(5, values['Orta'] ?? 0);\n\n      values['Kolay'] = (values['Kolay'] ?? 0) - easyShift;\n      values['Orta'] =\n          (values['Orta'] ?? 0) + easyShift - mediumShift;\n      values['Zor'] = (values['Zor'] ?? 0) + mediumShift;\n    }\n\n    final total = values.values.fold<int>(\n      0,\n      (sum, value) => sum + value,\n    );\n    var roll = random.nextInt(max(1, total));\n\n    for (final difficulty in const ['Kolay', 'Orta', 'Zor']) {\n      roll -= values[difficulty] ?? 0;\n      if (roll < 0) return difficulty;\n    }\n\n    return 'Kolay';\n  }\n}\n\nextension PlayerDifficultyBalanceX on PlayerData {\n  void registerAdaptiveAnswer(bool correct) {\n    if (correct) {\n      correctStreak++;\n      wrongStreak = 0;\n    } else {\n      wrongStreak++;\n      correctStreak = 0;\n    }\n  }\n\n  String get adaptiveDifficultyLabel {\n    if (wrongStreak >= 2) {\n      return 'Destek aktif';\n    }\n\n    if (correctStreak >= 3) {\n      return 'Meydan okuma aktif';\n    }\n\n    return 'Dengeleniyor';\n  }\n}\n\nclass DifficultyModeDropdown extends StatelessWidget {\n  const DifficultyModeDropdown({\n    required this.value,\n    required this.onChanged,\n    this.label = 'Soru seviyesi',\n    super.key,\n  });\n\n  final DifficultyMode value;\n  final ValueChanged<DifficultyMode> onChanged;\n  final String label;\n\n  @override\n  Widget build(BuildContext context) {\n    return DropdownButtonFormField<DifficultyMode>(\n      value: value,\n      isExpanded: true,\n      decoration: InputDecoration(\n        labelText: label,\n        prefixIcon: Text(\n          value.emoji,\n          textAlign: TextAlign.center,\n          style: const TextStyle(fontSize: 20),\n        ),\n        prefixIconConstraints: const BoxConstraints(\n          minWidth: 42,\n        ),\n        filled: true,\n        fillColor: Colors.white,\n        isDense: true,\n        border: OutlineInputBorder(\n          borderRadius: BorderRadius.circular(16),\n          borderSide: BorderSide.none,\n        ),\n      ),\n      items: DifficultyMode.values\n          .map(\n            (mode) => DropdownMenuItem<DifficultyMode>(\n              value: mode,\n              child: Text(\n                '${mode.label} — ${mode.description}',\n                overflow: TextOverflow.ellipsis,\n                style: const TextStyle(\n                  fontSize: 12,\n                  fontWeight: FontWeight.w800,\n                ),\n              ),\n            ),\n          )\n          .toList(growable: false),\n      onChanged: (mode) {\n        if (mode != null) onChanged(mode);\n      },\n    );\n  }\n}\n\nclass DifficultyModeCard extends StatelessWidget {\n  const DifficultyModeCard({\n    required this.value,\n    required this.onChanged,\n    super.key,\n  });\n\n  final DifficultyMode value;\n  final ValueChanged<DifficultyMode> onChanged;\n\n  @override\n  Widget build(BuildContext context) {\n    return Card(\n      child: Padding(\n        padding: const EdgeInsets.all(16),\n        child: Column(\n          crossAxisAlignment: CrossAxisAlignment.start,\n          children: [\n            const Text(\n              'Soru seviyesi',\n              style: TextStyle(\n                fontSize: 18,\n                fontWeight: FontWeight.w900,\n              ),\n            ),\n            const SizedBox(height: 5),\n            Text(\n              'Başlangıç seviyesi oyun sırasında verdiğin '\n              'cevaplara göre yumuşak biçimde dengelenir.',\n              style: TextStyle(\n                color: Colors.blueGrey.shade700,\n                fontSize: 12,\n              ),\n            ),\n            const SizedBox(height: 12),\n            DifficultyModeDropdown(\n              value: value,\n              onChanged: onChanged,\n            ),\n          ],\n        ),\n      ),\n    );\n  }\n}\n\nclass DifficultyBalance {\n  DifficultyBalance._();\n\n  static List<QuizQuestion> pickMarathonQuestions({\n    required QuestionBank questionBank,\n    required List<QuizQuestion> pool,\n    required int count,\n    required Random random,\n    required DifficultyMode mode,\n  }) {\n    if (pool.isEmpty || count <= 0) {\n      return const <QuizQuestion>[];\n    }\n\n    final available = List<QuizQuestion>.from(pool);\n    final selected = <QuizQuestion>[];\n    final usedFamilies = <String>{};\n\n    while (available.isNotEmpty && selected.length < count) {\n      final targetDifficulty = mode.chooseDifficulty(random);\n\n      var candidates = available\n          .where(\n            (question) =>\n                question.difficulty == targetDifficulty &&\n                !usedFamilies.contains(\n                  QuestionBank.questionFamilyKey(question.text),\n                ),\n          )\n          .toList();\n\n      if (candidates.isEmpty) {\n        candidates = available\n            .where(\n              (question) => !usedFamilies.contains(\n                QuestionBank.questionFamilyKey(question.text),\n              ),\n            )\n            .toList();\n      }\n\n      if (candidates.isEmpty) {\n        candidates = List<QuizQuestion>.from(available);\n      }\n\n      final chosen =\n          candidates[random.nextInt(candidates.length)];\n      selected.add(chosen);\n      available.removeWhere((question) => question.id == chosen.id);\n      usedFamilies.add(\n        QuestionBank.questionFamilyKey(chosen.text),\n      );\n    }\n\n    return selected;\n  }\n}\n"
PART.parent.mkdir(parents=True, exist_ok=True)
PART.write_text(part_content, encoding="utf-8")

main = replace_once(
    main,
    "part 'system_health.dart';",
    "part 'system_health.dart';\npart 'difficulty_balance.dart';",
    "part bağlantısı",
)

main = replace_once(
    main,
    """      'correctAnswers': player.correctAnswers,
      'wrongAnswers': player.wrongAnswers,
      'doubleChance': player.doubleChance,""",
    """      'correctAnswers': player.correctAnswers,
      'wrongAnswers': player.wrongAnswers,
      'correctStreak': player.correctStreak,
      'wrongStreak': player.wrongStreak,
      'difficultyMode': player.difficultyMode.name,
      'doubleChance': player.doubleChance,""",
    "oyuncu kayıt alanları",
)

main = replace_once(
    main,
    """      pawnType: (json['pawnType'] as num?)?.toInt() ?? 0,
      jokers: JokerWallet.fromJson(json['jokers']),""",
    """      pawnType: (json['pawnType'] as num?)?.toInt() ?? 0,
      difficultyMode:
          difficultyModeFromName(json['difficultyMode']),
      jokers: JokerWallet.fromJson(json['jokers']),""",
    "oyuncu kayıt yükleme yapıcısı",
)

main = replace_once(
    main,
    """    player.wrongAnswers =
        (json['wrongAnswers'] as num?)?.toInt() ?? 0;
    player.doubleChance = json['doubleChance'] == true;""",
    """    player.wrongAnswers =
        (json['wrongAnswers'] as num?)?.toInt() ?? 0;
    player.correctStreak =
        (json['correctStreak'] as num?)?.toInt() ?? 0;
    player.wrongStreak =
        (json['wrongStreak'] as num?)?.toInt() ?? 0;
    player.doubleChance = json['doubleChance'] == true;""",
    "oyuncu seri kayıtları",
)

main = replace_once(
    main,
    """  final List<int> _selectedPawnTypes =
      List<int>.generate(
    6,
    (index) => index == 0
        ? VisualCollectionService
            .current.favoritePawn
        : index,
  );""",
    """  final List<int> _selectedPawnTypes =
      List<int>.generate(
    6,
    (index) => index == 0
        ? VisualCollectionService
            .current.favoritePawn
        : index,
  );

  final List<DifficultyMode> _selectedDifficultyModes =
      List<DifficultyMode>.filled(
    6,
    DifficultyMode.relaxed,
  );""",
    "oyuncu zorluk durumları",
)

main = replace_once(
    main,
    """                            Expanded(
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
                            ),""",
    """                            Expanded(
                              child: Column(
                                children: [
                                  TextField(
                                    controller: _controllers[index],
                                    maxLength: 16,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: InputDecoration(
                                      counterText: '',
                                      labelText: '${index + 1}. oyuncu',
                                      helperText:
                                          'Yanındaki piyona dokunarak seç',
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(18),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DifficultyModeDropdown(
                                    value:
                                        _selectedDifficultyModes[index],
                                    label: 'Oyuncunun soru seviyesi',
                                    onChanged: (mode) {
                                      setState(() {
                                        _selectedDifficultyModes[index] =
                                            mode;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),""",
    "oyuncu kartı zorluk seçimi",
)

main = replace_once(
    main,
    """          color: _playerColors[index],
          pawnType: _selectedPawnTypes[index],
        ),""",
    """          color: _playerColors[index],
          pawnType: _selectedPawnTypes[index],
          difficultyMode: _selectedDifficultyModes[index],
        ),""",
    "çok oyunculu zorluk ataması",
)

main = replace_once(
    main,
    """  bool _starting = false;

  @override""",
    """  bool _starting = false;
  DifficultyMode _difficultyMode = DifficultyMode.relaxed;

  @override""",
    "serbest rota zorluk durumu",
)

main = replace_once(
    main,
    """              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _starting ? null : _startSoloRoute,""",
    """              const SizedBox(height: 18),
              DifficultyModeCard(
                value: _difficultyMode,
                onChanged: (mode) {
                  setState(() => _difficultyMode = mode);
                },
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _starting ? null : _startSoloRoute,""",
    "serbest rota zorluk seçimi",
)

main = replace_once(
    main,
    """      color: _colors[_colorIndex],
      pawnType: _pawnType,
    );""",
    """      color: _colors[_colorIndex],
      pawnType: _pawnType,
      difficultyMode: _difficultyMode,
    );""",
    "serbest rota zorluk ataması",
)

main = replace_once(
    main,
    """  int? _categoryIndex;
  int _questionCount = 10;

  int get _poolSize""",
    """  int? _categoryIndex;
  int _questionCount = 10;
  DifficultyMode _difficultyMode = DifficultyMode.relaxed;

  int get _poolSize""",
    "maraton zorluk durumu",
)

main = replace_once(
    main,
    """            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed:
                  availableCounts.isEmpty ? null : _startMarathon,""",
    """            const SizedBox(height: 18),
            DifficultyModeCard(
              value: _difficultyMode,
              onChanged: (mode) {
                setState(() => _difficultyMode = mode);
              },
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed:
                  availableCounts.isEmpty ? null : _startMarathon,""",
    "maraton zorluk seçimi",
)

main = replace_once(
    main,
    """    final questions = widget.questionBank.diverseQuestions(
      pool: pool,
      count: min(_questionCount, pool.length),
      random: Random(),
    );""",
    """    final questions =
        DifficultyBalance.pickMarathonQuestions(
      questionBank: widget.questionBank,
      pool: pool,
      count: min(_questionCount, pool.length),
      random: Random(),
      mode: _difficultyMode,
    );""",
    "maraton dengeli soru seçimi",
)

main = replace_once(
    main,
    """class PlayerData {
  PlayerData({
    required this.name,
    required this.color,
    required this.pawnType,
    JokerWallet? jokers,
  }) : jokers = jokers ?? JokerWallet.starter();

  final String name;
  final Color color;
  final int pawnType;
  final JokerWallet jokers;
  int position = 0;
  int movePulse = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  bool doubleChance = false;
  final Set<int> badges = <int>{};

  bool get hasAllBadges => badges.length == GameCategory.values.length;
}""",
    """class PlayerData {
  PlayerData({
    required this.name,
    required this.color,
    required this.pawnType,
    DifficultyMode? difficultyMode,
    JokerWallet? jokers,
  })  : difficultyMode =
            difficultyMode ?? DifficultyMode.relaxed,
        jokers = jokers ?? JokerWallet.starter();

  final String name;
  final Color color;
  final int pawnType;
  final DifficultyMode difficultyMode;
  final JokerWallet jokers;
  int position = 0;
  int movePulse = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  int correctStreak = 0;
  int wrongStreak = 0;
  bool doubleChance = false;
  final Set<int> badges = <int>{};

  bool get hasAllBadges =>
      badges.length == GameCategory.values.length;
}""",
    "PlayerData zorluk alanları",
)

main = replace_once(
    main,
    """  String get _preferredQuestionDifficulty {
    if (AppPreferencesService.current.childMode) {
      return 'Kolay';
    }

    final badgeCount = _currentPlayer.badges.length;

    if (badgeCount <= 1) return 'Kolay';
    if (badgeCount <= 3) return 'Orta';
    return 'Zor';
  }""",
    """  String _chooseQuestionDifficulty({
    bool finalQuestion = false,
  }) {
    return _currentPlayer.difficultyMode.chooseDifficulty(
      _random,
      correctStreak: _currentPlayer.correctStreak,
      wrongStreak: _currentPlayer.wrongStreak,
      finalQuestion: finalQuestion,
      forceRelaxed:
          AppPreferencesService.current.childMode,
    );
  }

  String get _difficultyStatusText {
    final mode = AppPreferencesService.current.childMode
        ? DifficultyMode.relaxed
        : _currentPlayer.difficultyMode;

    return '${mode.emoji} ${mode.label} • '
        '${_currentPlayer.adaptiveDifficultyLabel}';
  }""",
    "oyuncuya göre zorluk seçici",
)

main = replace_once(
    main,
    """                    '🧠 Soru seviyesi: '
                    '$_preferredQuestionDifficulty   •   '
                    '${_usedQuestionIds.length}/'""",
    """                    '🧠 Soru seviyesi: '
                    '$_difficultyStatusText   •   '
                    '${_usedQuestionIds.length}/'""",
    "oyun içi zorluk etiketi",
)

main = replace_once(
    main,
    """      normalDifficulty: _preferredQuestionDifficulty,
      wallet: _currentPlayer.jokers,""",
    """      normalDifficulty: _chooseQuestionDifficulty(),
      wallet: _currentPlayer.jokers,""",
    "normal soru zorluk seçimi",
)

main = replace_once(
    main,
    """      usedQuestionIds: _usedQuestionIds,
      preferredDifficulty: 'Zor',
    );""",
    """      usedQuestionIds: _usedQuestionIds,
      preferredDifficulty: _chooseQuestionDifficulty(
        finalQuestion: true,
      ),
    );""",
    "final sorusu zorluk seçimi",
)

main = replace_once(
    main,
    """    if (!mounted) return;

    if (correct) {
      _currentPlayer.correctAnswers++;""",
    """    if (!mounted) return;

    _currentPlayer.registerAdaptiveAnswer(correct);

    if (correct) {
      _currentPlayer.correctAnswers++;""",
    "final cevabı uyarlaması",
)

main = replace_once(
    main,
    """  }) async {
    final answeredPlayer = _currentPlayer;

    if (correct) {""",
    """  }) async {
    final answeredPlayer = _currentPlayer;
    answeredPlayer.registerAdaptiveAnswer(correct);

    if (correct) {""",
    "normal cevabı uyarlaması",
)

if "'schema': 2," in main:
    main = main.replace("'schema': 2,", "'schema': 3,", 1)

version_match = re.search(
    r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$",
    pubspec,
    flags=re.MULTILINE,
)
if not version_match:
    fail("pubspec.yaml sürüm satırı okunamadı.")

major, minor, patch, build = map(int, version_match.groups())
new_version = f"{major}.{minor + 1}.0+{build + 1}"
display_version = f"{major}.{minor + 1}.0"

pubspec = re.sub(
    r"^version:\s*.*$",
    f"version: {new_version}",
    pubspec,
    count=1,
    flags=re.MULTILINE,
)

main, display_count = re.subn(
    r"Bilgi Rotası • Sürüm \d+\.\d+(?:\.\d+)?",
    f"Bilgi Rotası • Sürüm {display_version}",
    main,
    count=1,
)
if display_count != 1:
    fail("Ana menü sürüm yazısı güncellenemedi.")

backup_dir = Path("/tmp/bilgi_rotasi_zorluk_dengesi_yedek")
backup_dir.mkdir(parents=True, exist_ok=True)
shutil.copy2(MAIN, backup_dir / "main.dart")
shutil.copy2(PUBSPEC, backup_dir / "pubspec.yaml")

MAIN.write_text(main, encoding="utf-8")
PUBSPEC.write_text(pubspec, encoding="utf-8")

if shutil.which("dart"):
    subprocess.run(
        ["dart", "format", "lib/main.dart", "lib/difficulty_balance.dart"],
        check=True,
    )

subprocess.run(["git", "diff", "--check"], check=True)

if shutil.which("flutter"):
    subprocess.run(
        ["flutter", "analyze", "--no-fatal-infos"],
        check=True,
    )
    if Path("test").exists():
        subprocess.run(["flutter", "test"], check=True)

subprocess.run(
    [
        "git",
        "add",
        "lib/main.dart",
        "lib/difficulty_balance.dart",
        "pubspec.yaml",
    ],
    check=True,
)

has_changes = subprocess.run(
    ["git", "diff", "--cached", "--quiet"],
    check=False,
).returncode != 0

if not has_changes:
    fail("Kurulum sonunda commit edilecek değişiklik bulunamadı.")

subprocess.run(
    [
        "git",
        "commit",
        "-m",
        "Oyuncuya gore zorluk dengesini ekle",
    ],
    check=True,
)
subprocess.run(["git", "push", "origin", "main"], check=True)

print("")
print("✅ Zorluk Dengesi ve Oyuncuya Göre Uyarlama kuruldu.")
print("✅ Varsayılan seviye: Rahat")
print("✅ Her oyuncu kendi seviyesini seçebilir.")
print("✅ Rahat: %80 Kolay • %18 Orta • %2 Zor")
print("✅ Dengeli: %60 Kolay • %30 Orta • %10 Zor")
print("✅ Uzman: %30 Kolay • %45 Orta • %25 Zor")
print("✅ İki yanlışta destek, üç doğruda meydan okuma devreye girer.")
print("✅ Final sorusu seçilen seviyeden bir kademe yukarıdan seçilir.")
print("✅ Serbest Rota ve Soru Maratonu seviye seçimi aldı.")
print(f"✅ Yeni sürüm: {new_version}")
print("✅ Değişiklikler GitHub'a gönderildi.")
print(f"ℹ️ Geçici yedek: {backup_dir}")
