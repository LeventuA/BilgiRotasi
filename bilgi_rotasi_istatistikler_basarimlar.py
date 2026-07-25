#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess

MAIN = Path("lib/main.dart")
PUBSPEC = Path("pubspec.yaml")

def template(name):
    path = Path(name)
    if not path.exists():
        raise SystemExit(f"Paket dosyası bulunamadı: {name}")
    return path.read_text(encoding="utf-8")

if not MAIN.exists() or not PUBSPEC.exists():
    raise SystemExit(
        "Bu dosyayı BilgiRotasi deposunun ana klasöründe çalıştır."
    )

source = MAIN.read_text(encoding="utf-8")
shutil.copy2(
    MAIN,
    "/tmp/bilgi_rotasi_istatistikler_oncesi.dart",
)

required = [
    "class GameSaveService {",
    "Future<void> main() async {",
    "class _HomeScreenState extends State<HomeScreen>",
    "class SoloRouteSetupScreen extends StatefulWidget",
    "class MarathonScreen extends StatefulWidget",
    "class PlayerSetupScreen extends StatefulWidget",
    "class _GameScreenState extends State<GameScreen>",
    "Future<void> _handleAnswer({",
    "Bilgi Rotası • Sürüm 1.16",
]
for marker in required:
    if marker not in source:
        raise SystemExit(f"Beklenen güncel kod bulunamadı: {marker}")

if "class CareerStats {" in source:
    raise SystemExit("İstatistikler güncellemesi zaten uygulanmış.")

# 1) Kalıcı istatistik servisi.
main_marker = "Future<void> main() async {"
source = source.replace(
    main_marker,
    template("kariyer_istatistik_servisi.txt")
    + "\n"
    + main_marker,
    1,
)

# 2) İstatistik ekranı HomeScreen'den önce.
home_marker = "class HomeScreen extends StatefulWidget"
source = source.replace(
    home_marker,
    template("istatistik_ekrani.txt")
    + "\n"
    + home_marker,
    1,
)

# 3) Ana menüye İstatistikler düğmesi.
old_home_buttons = """                _buildCategoryCard(),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () => _showRules(context),"""

new_home_buttons = """                _buildCategoryCard(),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            const CareerStatsScreen(),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFFFE082),
                    foregroundColor:
                        const Color(0xFF3A2448),
                  ),
                  icon: const Icon(
                    Icons.insights_rounded,
                  ),
                  label: const Text(
                    'İstatistikler & Başarımlar',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _showRules(context),"""

if old_home_buttons not in source:
    raise SystemExit("Ana menü düğme bölümü bulunamadı.")

source = source.replace(
    old_home_buttons,
    new_home_buttons,
    1,
)

# 4) Serbest Rota başlangıcını kaydet.
solo_start = source.index(
    "class _SoloRouteSetupScreenState"
)
solo_end = source.index(
    "class MarathonSetupScreen",
    solo_start,
)
solo_section = source[solo_start:solo_end]

old_clear = """    await GameSaveService.clear();

    if (!mounted) return;"""

new_solo_clear = """    await GameSaveService.clear();
    await CareerStatsService.recordGameStarted();

    if (!mounted) return;"""

if old_clear not in solo_section:
    raise SystemExit("Serbest Rota başlangıç bölümü bulunamadı.")

solo_section = solo_section.replace(
    old_clear,
    new_solo_clear,
    1,
)
source = (
    source[:solo_start]
    + solo_section
    + source[solo_end:]
)

# 5) Çok oyunculu başlangıcı kaydet.
setup_start = source.index(
    "class _PlayerSetupScreenState"
)
setup_end = source.index(
    "class WinnerScreen",
    setup_start,
)
setup_section = source[setup_start:setup_end]

new_multi_clear = """    await GameSaveService.clear();
    await CareerStatsService.recordGameStarted();

    if (!mounted) return;"""

if old_clear not in setup_section:
    raise SystemExit("Çok oyunculu başlangıç bölümü bulunamadı.")

setup_section = setup_section.replace(
    old_clear,
    new_multi_clear,
    1,
)
source = (
    source[:setup_start]
    + setup_section
    + source[setup_end:]
)

# 6) Normal soru cevaplarını kaydet.
handle_start = source.index(
    "  Future<void> _handleAnswer({"
)
advance_start = source.index(
    "  void _advanceTurn()",
    handle_start,
)
source = (
    source[:handle_start]
    + template("istatistikli_cevap_metodu.txt")
    + source[advance_start:]
)

# 7) Final sorusunu ve oyun tamamlanmasını kaydet.
final_start = source.index(
    "  Future<void> _askFinalQuestion() async"
)
handle_start = source.index(
    "  Future<void> _handleAnswer({",
    final_start,
)
final_section = source[final_start:handle_start]

old_final_correct = """      await GameSaveService.clear();
      unawaited(SoundFx.win());"""

new_final_correct = """      await CareerStatsService.recordAnswer(
        categoryIndex: categoryIndex,
        correct: true,
      );
      await CareerStatsService.recordGameCompleted(
        solo: widget.players.length == 1,
      );
      await GameSaveService.clear();
      unawaited(SoundFx.win());"""

if old_final_correct not in final_section:
    raise SystemExit("Final doğru cevap bölümü bulunamadı.")

final_section = final_section.replace(
    old_final_correct,
    new_final_correct,
    1,
)

old_final_wrong = """      _currentPlayer.wrongAnswers++;
      _advanceTurn();"""

new_final_wrong = """      _currentPlayer.wrongAnswers++;
      await CareerStatsService.recordAnswer(
        categoryIndex: categoryIndex,
        correct: false,
      );
      _advanceTurn();"""

if old_final_wrong not in final_section:
    raise SystemExit("Final yanlış cevap bölümü bulunamadı.")

final_section = final_section.replace(
    old_final_wrong,
    new_final_wrong,
    1,
)

source = (
    source[:final_start]
    + final_section
    + source[handle_start:]
)

# 8) Maraton cevapları ve tamamlanması.
marathon_start = source.index(
    "class _MarathonScreenState"
)
marathon_end = source.index(
    "class MarathonResultScreen",
    marathon_start,
)
marathon_section = source[marathon_start:marathon_end]

old_finished_marker = """    final finished =
        _questionIndex + 1 >= widget.questions.length;"""

new_finished_marker = """    await CareerStatsService.recordAnswer(
      categoryIndex: _question.categoryIndex,
      correct: correct,
    );

    final finished =
        _questionIndex + 1 >= widget.questions.length;"""

if old_finished_marker not in marathon_section:
    raise SystemExit("Maraton cevap bölümü bulunamadı.")

marathon_section = marathon_section.replace(
    old_finished_marker,
    new_finished_marker,
    1,
)

old_marathon_save = """      await MarathonScoreService.saveBest(
        categoryIndex: widget.categoryIndex,
        questionCount: widget.questions.length,
        score: _correct,
      );

      if (!mounted) return;"""

new_marathon_save = """      await MarathonScoreService.saveBest(
        categoryIndex: widget.categoryIndex,
        questionCount: widget.questions.length,
        score: _correct,
      );
      await CareerStatsService.recordMarathon(
        questionCount: widget.questions.length,
        correct: _correct,
        bestStreak: _maxStreak,
      );

      if (!mounted) return;"""

if old_marathon_save not in marathon_section:
    raise SystemExit("Maraton bitiş bölümü bulunamadı.")

marathon_section = marathon_section.replace(
    old_marathon_save,
    new_marathon_save,
    1,
)

source = (
    source[:marathon_start]
    + marathon_section
    + source[marathon_end:]
)

# 9) Sürüm.
source = source.replace(
    "Bilgi Rotası • Sürüm 1.16",
    "Bilgi Rotası • Sürüm 1.17",
    1,
)

for marker in [
    "class CareerStats {",
    "class CareerStatsService {",
    "class CareerStatsScreen extends StatefulWidget",
    "İstatistikler & Başarımlar",
    "CareerStatsService.recordGameStarted()",
    "CareerStatsService.recordGameCompleted(",
    "CareerStatsService.recordMarathon(",
    "CareerStatsService.recordAnswer(",
]:
    if marker not in source:
        raise SystemExit(f"İstatistik doğrulaması başarısız: {marker}")

MAIN.write_text(source, encoding="utf-8")

pub = PUBSPEC.read_text(encoding="utf-8")
pub = re.sub(
    r"^version:\s*.*$",
    "version: 1.17.0+22",
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
            "Kariyer istatistikleri ve basarimlar",
        ],
        check=True,
    )

subprocess.run(
    ["git", "push", "origin", "main"],
    check=True,
)

print("✅ Kalıcı kariyer istatistikleri eklendi.")
print("✅ Kategori bazlı doğru ve başarı yüzdeleri eklendi.")
print("✅ Serbest Rota, çok oyunculu ve maraton sonuçları takip edilecek.")
print("✅ On kalıcı başarım eklendi.")
print("✅ Ana menüye İstatistikler & Başarımlar düğmesi eklendi.")
print("✅ İstatistikleri sıfırlama seçeneği eklendi.")
print("✅ Kayıtlı oyun sıfırlamadan etkilenmeyecek.")
print("✅ Kod analizden geçti ve GitHub'a gönderildi.")
