#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess

MAIN = Path("lib/main.dart")
PUBSPEC = Path("pubspec.yaml")

if not MAIN.exists() or not PUBSPEC.exists():
    raise SystemExit(
        "Bu dosyayı BilgiRotasi deposunun ana klasöründe çalıştır."
    )

source = MAIN.read_text(encoding="utf-8")
shutil.copy2(
    MAIN,
    "/tmp/bilgi_rotasi_android_geri_oncesi.dart",
)

required = [
    "class _GameScreenState extends State<GameScreen>",
    "Future<void> _confirmExit() async",
    "bool _soundEnabled = true;",
    "Navigator.of(context).popUntil((route) => route.isFirst);",
]
for marker in required:
    if marker not in source:
        raise SystemExit(f"Beklenen güncel kod bulunamadı: {marker}")

if "canPop: _allowRoutePop" in source:
    raise SystemExit("Android geri tuşu düzeltmesi zaten uygulanmış.")

old_fields = """  bool _soundEnabled = true;

  PlayerData get _currentPlayer =>"""

new_fields = """  bool _soundEnabled = true;
  bool _allowRoutePop = false;
  bool _exitDialogOpen = false;

  PlayerData get _currentPlayer =>"""

if old_fields not in source:
    raise SystemExit("GameScreen durum alanları bulunamadı.")
source = source.replace(old_fields, new_fields, 1)

game_start = source.index(
    "class _GameScreenState extends State<GameScreen>"
)
board_card_start = source.index(
    "  Widget _buildBoardCard() {",
    game_start,
)
build_section = source[game_start:board_card_start]

old_build_start = """  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar("""

new_build_start = """  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: _allowRoutePop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          unawaited(_handleSystemBack());
        }
      },
      child: Scaffold(
        appBar: AppBar("""

if old_build_start not in build_section:
    raise SystemExit("GameScreen build başlangıcı bulunamadı.")

build_section = build_section.replace(
    old_build_start,
    new_build_start,
    1,
)

old_build_end = """      ),
    );
  }

"""

new_build_end = """      ),
      ),
    );
  }

"""

last_end_index = build_section.rfind(old_build_end)
if last_end_index == -1:
    raise SystemExit("GameScreen build kapanışı bulunamadı.")

build_section = (
    build_section[:last_end_index]
    + new_build_end
    + build_section[last_end_index + len(old_build_end):]
)

source = (
    source[:game_start]
    + build_section
    + source[board_card_start:]
)

confirm_marker = "  Future<void> _confirmExit() async {"
confirm_index = source.index(confirm_marker, game_start)

system_back_method = """  Future<void> _handleSystemBack() async {
    if (_allowRoutePop || _exitDialogOpen || !mounted) return;
    await _confirmExit();
  }

"""

source = (
    source[:confirm_index]
    + system_back_method
    + source[confirm_index:]
)

old_confirm_start = """  Future<void> _confirmExit() async {
    final action = await showDialog<String>("""

new_confirm_start = """  Future<void> _confirmExit() async {
    if (_exitDialogOpen || !mounted) return;

    _exitDialogOpen = true;
    String? action;

    try {
      action = await showDialog<String>("""

if old_confirm_start not in source:
    raise SystemExit("Çıkış yönteminin başlangıcı bulunamadı.")

source = source.replace(
    old_confirm_start,
    new_confirm_start,
    1,
)

confirm_index = source.index(
    "  Future<void> _confirmExit() async {",
    game_start,
)
after_confirm = source[confirm_index:]

old_dialog_end = """      },
    );

    if (!mounted || action == null || action == 'cancel') {
      return;
    }"""

new_dialog_end = """      },
    );
    } finally {
      _exitDialogOpen = false;
    }

    if (!mounted || action == null || action == 'cancel') {
      return;
    }"""

if old_dialog_end not in after_confirm:
    raise SystemExit("Çıkış penceresinin kapanış bölümü bulunamadı.")

after_confirm = after_confirm.replace(
    old_dialog_end,
    new_dialog_end,
    1,
)
source = source[:confirm_index] + after_confirm

confirm_index = source.index(
    "  Future<void> _confirmExit() async {",
    game_start,
)
after_confirm = source[confirm_index:]

old_exit_end = """    if (!mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);
  }"""

new_exit_end = """    if (!mounted) return;

    setState(() {
      _allowRoutePop = true;
    });

    Navigator.of(context).popUntil((route) => route.isFirst);
  }"""

if old_exit_end not in after_confirm:
    raise SystemExit("Çıkış yönlendirme bölümü bulunamadı.")

after_confirm = after_confirm.replace(
    old_exit_end,
    new_exit_end,
    1,
)
source = source[:confirm_index] + after_confirm

for marker in [
    "return PopScope<Object?>(",
    "canPop: _allowRoutePop",
    "onPopInvokedWithResult:",
    "Future<void> _handleSystemBack() async",
    "_exitDialogOpen = true;",
    "_allowRoutePop = true;",
]:
    if marker not in source:
        raise SystemExit(f"Geri tuşu doğrulaması başarısız: {marker}")

MAIN.write_text(source, encoding="utf-8")

pub = PUBSPEC.read_text(encoding="utf-8")
pub = re.sub(
    r"^version:\s*.*$",
    "version: 1.12.1+16",
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
            "Android geri tusunda kaydetme penceresi",
        ],
        check=True,
    )

subprocess.run(
    ["git", "push", "origin", "main"],
    check=True,
)

print("✅ Android geri tuşu oyun ekranında yakalanacak.")
print("✅ Sağ üst çıkış düğmesiyle aynı kayıt penceresi açılacak.")
print("✅ Kaydet ve Çık / Oyunu Sil / Devam Et seçenekleri korunacak.")
print("✅ Çıkış penceresinin iki kez açılması engellendi.")
print("✅ Onaydan sonra ana menüye güvenli şekilde dönülecek.")
print("✅ Kod GitHub'a gönderildi; Actions derlemesi başlayacak.")
