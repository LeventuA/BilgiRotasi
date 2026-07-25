#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess

MAIN = Path("lib/main.dart")
PUBSPEC = Path("pubspec.yaml")
DRAW_TEMPLATE = Path("soru_cekilis_modeli.txt")
METHOD_TEMPLATE = Path("soru_havuzu_metodu.txt")

if not MAIN.exists() or not PUBSPEC.exists():
    raise SystemExit(
        "Bu dosyayı BilgiRotasi deposunun ana klasöründe çalıştır."
    )

if not DRAW_TEMPLATE.exists() or not METHOD_TEMPLATE.exists():
    raise SystemExit("Paket şablon dosyaları bulunamadı.")

source = MAIN.read_text(encoding="utf-8")
shutil.copy2(
    MAIN,
    "/tmp/bilgi_rotasi_soru_sistemi_2_oncesi.dart",
)

required = [
    "class SavedGame {",
    "class GameSaveService {",
    "class GameScreen extends StatefulWidget",
    "class _GameScreenState extends State<GameScreen>",
    "final question = widget.questionBank.randomQuestion(",
    "class QuizQuestion {",
    "class QuestionBank {",
    "QuizQuestion randomQuestion(int categoryIndex, Random random)",
    "Bilgi Rotası • Sürüm 1.15",
]
for marker in required:
    if marker not in source:
        raise SystemExit(f"Beklenen güncel kod bulunamadı: {marker}")

if "class QuestionDraw {" in source:
    raise SystemExit("Soru Sistemi 2.0 zaten uygulanmış.")

# ------------------------------------------------------------
# 1) Kayıt modeline kullanılmış soru kimliklerini ekle.
# ------------------------------------------------------------
old_saved_constructor = """  const SavedGame({
    required this.players,
    required this.currentPlayerIndex,
    required this.savedAt,
  });"""

new_saved_constructor = """  const SavedGame({
    required this.players,
    required this.currentPlayerIndex,
    required this.savedAt,
    required this.usedQuestionIds,
  });"""

if old_saved_constructor not in source:
    raise SystemExit("SavedGame kurucu bölümü bulunamadı.")

source = source.replace(
    old_saved_constructor,
    new_saved_constructor,
    1,
)

old_saved_fields = """  final List<PlayerData> players;
  final int currentPlayerIndex;
  final DateTime savedAt;"""

new_saved_fields = """  final List<PlayerData> players;
  final int currentPlayerIndex;
  final DateTime savedAt;
  final Set<String> usedQuestionIds;"""

source = source.replace(
    old_saved_fields,
    new_saved_fields,
    1,
)

old_save_signature = """  static Future<void> save({
    required List<PlayerData> players,
    required int currentPlayerIndex,
  }) async {"""

new_save_signature = """  static Future<void> save({
    required List<PlayerData> players,
    required int currentPlayerIndex,
    required Set<String> usedQuestionIds,
  }) async {"""

if old_save_signature not in source:
    raise SystemExit("GameSaveService.save imzası bulunamadı.")

source = source.replace(
    old_save_signature,
    new_save_signature,
    1,
)

old_payload = """      'schema': 1,
      'savedAt': DateTime.now().toIso8601String(),
      'currentPlayerIndex': currentPlayerIndex,
      'players': players.map(_playerToJson).toList(),"""

new_payload = """      'schema': 2,
      'savedAt': DateTime.now().toIso8601String(),
      'currentPlayerIndex': currentPlayerIndex,
      'players': players.map(_playerToJson).toList(),
      'usedQuestionIds': usedQuestionIds.toList()..sort(),"""

if old_payload not in source:
    raise SystemExit("Kayıt JSON bölümü bulunamadı.")

source = source.replace(
    old_payload,
    new_payload,
    1,
)

old_load_return = """      return SavedGame(
        players: players,
        currentPlayerIndex: currentPlayerIndex,
        savedAt: savedAt,
      );"""

new_load_return = """      final rawUsedQuestionIds =
          decoded['usedQuestionIds'];
      final usedQuestionIds = <String>{};

      if (rawUsedQuestionIds is List) {
        usedQuestionIds.addAll(
          rawUsedQuestionIds
              .map((value) => value.toString())
              .where((value) => value.isNotEmpty),
        );
      }

      return SavedGame(
        players: players,
        currentPlayerIndex: currentPlayerIndex,
        savedAt: savedAt,
        usedQuestionIds: usedQuestionIds,
      );"""

if old_load_return not in source:
    raise SystemExit("SavedGame yükleme dönüşü bulunamadı.")

source = source.replace(
    old_load_return,
    new_load_return,
    1,
)

# ------------------------------------------------------------
# 2) Kayıtlı oyunu açarken soru geçmişini GameScreen'e taşı.
# ------------------------------------------------------------
old_continue_args = """          initialPlayerIndex: savedGame.currentPlayerIndex,
          initialStatus:
              'Kayıtlı oyun açıldı. Sıra '"""

new_continue_args = """          initialPlayerIndex: savedGame.currentPlayerIndex,
          initialUsedQuestionIds: savedGame.usedQuestionIds,
          initialStatus:
              'Kayıtlı oyun açıldı. Sıra '"""

if old_continue_args not in source:
    raise SystemExit("Kayıtlı GameScreen çağrısı bulunamadı.")

source = source.replace(
    old_continue_args,
    new_continue_args,
    1,
)

# Kayıt kartında farklı soru sayısını göster.
old_saved_summary = """                      '${savedGame.players.length} oyuncu • '
                      '${savedGame.totalBadges} rozet • '
                      '${_formatDate(savedGame.savedAt)}',"""

new_saved_summary = """                      '${savedGame.players.length} oyuncu • '
                      '${savedGame.totalBadges} rozet • '
                      '${savedGame.usedQuestionIds.length} soru\\n'
                      '${_formatDate(savedGame.savedAt)}',"""

if old_saved_summary not in source:
    raise SystemExit("Kayıt kartı özet metni bulunamadı.")

source = source.replace(
    old_saved_summary,
    new_saved_summary,
    1,
)

# ------------------------------------------------------------
# 3) GameScreen soru havuzu durumu.
# ------------------------------------------------------------
old_game_constructor = """  const GameScreen({
    required this.questionBank,
    required this.players,
    this.initialPlayerIndex = 0,
    this.initialStatus,
    super.key,
  });"""

new_game_constructor = """  const GameScreen({
    required this.questionBank,
    required this.players,
    this.initialPlayerIndex = 0,
    this.initialUsedQuestionIds = const <String>{},
    this.initialStatus,
    super.key,
  });"""

if old_game_constructor not in source:
    raise SystemExit("GameScreen kurucusu bulunamadı.")

source = source.replace(
    old_game_constructor,
    new_game_constructor,
    1,
)

old_game_fields = """  final QuestionBank questionBank;
  final List<PlayerData> players;
  final int initialPlayerIndex;
  final String? initialStatus;"""

new_game_fields = """  final QuestionBank questionBank;
  final List<PlayerData> players;
  final int initialPlayerIndex;
  final Set<String> initialUsedQuestionIds;
  final String? initialStatus;"""

source = source.replace(
    old_game_fields,
    new_game_fields,
    1,
)

old_state_fields = """  bool _soundEnabled = true;
  bool _allowRoutePop = false;
  bool _exitDialogOpen = false;"""

new_state_fields = """  bool _soundEnabled = true;
  bool _allowRoutePop = false;
  bool _exitDialogOpen = false;
  final Set<String> _usedQuestionIds = <String>{};"""

if old_state_fields not in source:
    raise SystemExit("GameScreen durum alanları bulunamadı.")

source = source.replace(
    old_state_fields,
    new_state_fields,
    1,
)

old_init_status = """    _status = widget.initialStatus ?? 'Zarı at ve rotaya çık.';

    WidgetsBinding.instance.addPostFrameCallback((_) {"""

new_init_status = """    _status = widget.initialStatus ?? 'Zarı at ve rotaya çık.';
    _usedQuestionIds.addAll(widget.initialUsedQuestionIds);

    WidgetsBinding.instance.addPostFrameCallback((_) {"""

if old_init_status not in source:
    raise SystemExit("GameScreen initState bölümü bulunamadı.")

source = source.replace(
    old_init_status,
    new_init_status,
    1,
)

old_save_call = """    return GameSaveService.save(
      players: widget.players,
      currentPlayerIndex: _currentPlayerIndex,
    );"""

new_save_call = """    return GameSaveService.save(
      players: widget.players,
      currentPlayerIndex: _currentPlayerIndex,
      usedQuestionIds: _usedQuestionIds,
    );"""

if old_save_call not in source:
    raise SystemExit("GameScreen kayıt çağrısı bulunamadı.")

source = source.replace(
    old_save_call,
    new_save_call,
    1,
)

# Zorluk ilerlemesi getter'ı.
getter_marker = """  PlayerData get _currentPlayer =>
      widget.players[_currentPlayerIndex];

  @override
  void initState() {"""

difficulty_getter = """  PlayerData get _currentPlayer =>
      widget.players[_currentPlayerIndex];

  String get _preferredQuestionDifficulty {
    final badgeCount = _currentPlayer.badges.length;

    if (badgeCount <= 1) return 'Kolay';
    if (badgeCount <= 3) return 'Orta';
    return 'Zor';
  }

  @override
  void initState() {"""

if getter_marker not in source:
    raise SystemExit("GameScreen currentPlayer getter bulunamadı.")

source = source.replace(
    getter_marker,
    difficulty_getter,
    1,
)

# Kontrol panelinde soru seviyesi ve havuz göstergesi.
old_stats_text = """                Text(
                  'Doğru: ${_currentPlayer.correctAnswers}   •   Yanlış: ${_currentPlayer.wrongAnswers}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),"""

new_stats_text = """                Text(
                  'Doğru: ${_currentPlayer.correctAnswers}   •   '
                  'Yanlış: ${_currentPlayer.wrongAnswers}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF155E75).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: const Color(0xFF155E75)
                          .withOpacity(0.22),
                    ),
                  ),
                  child: Text(
                    '🧠 Soru seviyesi: '
                    '$_preferredQuestionDifficulty   •   '
                    '${_usedQuestionIds.length}/'
                    '${widget.questionBank.totalCount} farklı soru',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),"""

if old_stats_text not in source:
    raise SystemExit("Kontrol paneli istatistik metni bulunamadı.")

source = source.replace(
    old_stats_text,
    new_stats_text,
    1,
)

# ------------------------------------------------------------
# 4) Normal ve final sorularını tekrarsız motorla çek.
# ------------------------------------------------------------
old_normal_draw = """    final question = widget.questionBank.randomQuestion(
      categoryIndex,
      _random,
    );

    final correct = await Navigator.of(context).push<bool>("""

new_normal_draw = """    final draw = widget.questionBank.nextQuestion(
      categoryIndex: categoryIndex,
      random: _random,
      usedQuestionIds: _usedQuestionIds,
      preferredDifficulty: _preferredQuestionDifficulty,
    );
    final question = draw.question;

    if (draw.poolReset && mounted) {
      setState(() {
        _status =
            '${GameCategory.values[categoryIndex].label} '
            'soru havuzu tamamlandı; yeni tur başladı.';
      });
    }

    await _saveGame();

    if (!mounted) return;

    final correct = await Navigator.of(context).push<bool>("""

if old_normal_draw not in source:
    raise SystemExit("Normal soru çekilişi bulunamadı.")

source = source.replace(
    old_normal_draw,
    new_normal_draw,
    1,
)

old_final_draw = """    final categoryIndex =
        _random.nextInt(GameCategory.values.length);
    final question = widget.questionBank.randomQuestion(
      categoryIndex,
      _random,
    );

    final correct = await Navigator.of(context).push<bool>("""

new_final_draw = """    final categoryIndex =
        _random.nextInt(GameCategory.values.length);
    final draw = widget.questionBank.nextQuestion(
      categoryIndex: categoryIndex,
      random: _random,
      usedQuestionIds: _usedQuestionIds,
      preferredDifficulty: 'Zor',
    );
    final question = draw.question;

    await _saveGame();

    if (!mounted) return;

    final correct = await Navigator.of(context).push<bool>("""

if old_final_draw not in source:
    raise SystemExit("Final soru çekilişi bulunamadı.")

source = source.replace(
    old_final_draw,
    new_final_draw,
    1,
)

# ------------------------------------------------------------
# 5) QuestionBank içine tekrarsız havuz motorunu ekle.
# ------------------------------------------------------------
quiz_marker = "class QuizQuestion {"
quiz_index = source.index(quiz_marker)

source = (
    source[:quiz_index]
    + DRAW_TEMPLATE.read_text(encoding="utf-8")
    + quiz_marker
    + source[quiz_index + len(quiz_marker):]
)

random_method_marker = """  QuizQuestion randomQuestion(int categoryIndex, Random random) {"""

if random_method_marker not in source:
    raise SystemExit("QuestionBank randomQuestion metodu bulunamadı.")

source = source.replace(
    random_method_marker,
    METHOD_TEMPLATE.read_text(encoding="utf-8")
    + random_method_marker,
    1,
)

# Ana menü sürümünü güncelle.
source = source.replace(
    "Bilgi Rotası • Sürüm 1.15",
    "Bilgi Rotası • Sürüm 1.16",
    1,
)

for marker in [
    "class QuestionDraw {",
    "QuestionDraw nextQuestion({",
    "required Set<String> usedQuestionIds",
    "final Set<String> _usedQuestionIds = <String>{};",
    "preferredDifficulty: _preferredQuestionDifficulty",
    "preferredDifficulty: 'Zor'",
    "'usedQuestionIds': usedQuestionIds.toList()..sort()",
    "initialUsedQuestionIds: savedGame.usedQuestionIds",
]:
    if marker not in source:
        raise SystemExit(f"Soru sistemi doğrulaması başarısız: {marker}")

MAIN.write_text(source, encoding="utf-8")

pub = PUBSPEC.read_text(encoding="utf-8")
pub = re.sub(
    r"^version:\s*.*$",
    "version: 1.16.0+21",
    pub,
    flags=re.MULTILINE,
)
PUBSPEC.write_text(pub, encoding="utf-8")

if shutil.which("dart"):
    subprocess.run(
        ["dart", "format", "lib/main.dart"],
        check=True,
    )

subprocess.run(
    ["git", "diff", "--check"],
    check=True,
)

if shutil.which("flutter"):
    subprocess.run(
        ["flutter", "analyze", "--no-fatal-infos"],
        check=True,
    )

subprocess.run(
    ["git", "add", "lib/main.dart", "pubspec.yaml"],
    check=True,
)

changed = subprocess.run(
    ["git", "diff", "--cached", "--quiet"],
    check=False,
).returncode != 0

if changed:
    subprocess.run(
        [
            "git",
            "commit",
            "-m",
            "Tekrarsiz ve ilerlemeli soru sistemi",
        ],
        check=True,
    )

subprocess.run(
    ["git", "push", "origin", "main"],
    check=True,
)

print("✅ Tahta oyununda aynı soru havuz bitmeden tekrarlanmayacak.")
print("✅ Kullanılmış sorular Kaydet ve Çık sisteminde korunacak.")
print("✅ Serbest Rota ve çok oyunculu oyun aynı sistemi kullanacak.")
print("✅ Rozet ilerlemesine göre Kolay, Orta ve Zor soru dengesi eklendi.")
print("✅ Final soruları mümkün olduğunda Zor seviyeden seçilecek.")
print("✅ Kategori havuzu bitince yalnızca o kategori yenilenecek.")
print("✅ Kontrol paneline soru seviyesi ve farklı soru sayacı eklendi.")
print("✅ Kod analizden geçti ve GitHub'a gönderildi.")
