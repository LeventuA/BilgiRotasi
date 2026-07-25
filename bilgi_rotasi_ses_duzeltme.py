#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess

MAIN = Path("lib/main.dart")
PUBSPEC = Path("pubspec.yaml")
TEMPLATE = Path("duzeltilmis_ses_sistemi.txt")
SOUNDS = Path("assets/sounds")

if not MAIN.exists() or not PUBSPEC.exists() or not TEMPLATE.exists():
    raise SystemExit(
        "Dosyaları BilgiRotasi proje ana klasöründe çalıştır."
    )

required_mp3 = [
    "dice_roll.mp3",
    "step.mp3",
    "landing.mp3",
    "correct.mp3",
    "wrong.mp3",
    "badge.mp3",
    "win.mp3",
]
for name in required_mp3:
    if not (SOUNDS / name).exists():
        raise SystemExit(f"Eksik ses dosyası: assets/sounds/{name}")

source = MAIN.read_text(encoding="utf-8")
shutil.copy2(
    MAIN,
    "/tmp/bilgi_rotasi_ses_duzeltme_oncesi.dart",
)

if "class SoundFx {" not in source or "void main()" not in source:
    raise SystemExit("Mevcut ses sistemi bulunamadı.")

sound_start = source.index("class SoundFx {")
main_start = source.index("void main()", sound_start)

source = (
    source[:sound_start]
    + TEMPLATE.read_text(encoding="utf-8")
    + source[main_start:]
)

old_main = """void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BilgiRotasiApp());
}"""

new_main = """Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SoundFx.initialize();
  } catch (_) {
    // Ses başlatılamasa bile oyun açılmaya devam eder.
  }

  runApp(const BilgiRotasiApp());
}"""

if old_main not in source:
    raise SystemExit("main() başlangıcı bulunamadı.")
source = source.replace(old_main, new_main, 1)

old_sound_button = """          IconButton(
            tooltip: _soundEnabled ? 'Sesleri kapat' : 'Sesleri aç',
            onPressed: () {
              setState(() {
                _soundEnabled = !_soundEnabled;
                SoundFx.setEnabled(_soundEnabled);
              });
            },
            icon: Icon(
              _soundEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
            ),
          ),"""

new_sound_button = """          IconButton(
            tooltip: _soundEnabled ? 'Sesleri kapat' : 'Sesleri aç',
            onPressed: () async {
              final willEnable = !_soundEnabled;

              setState(() {
                _soundEnabled = willEnable;
                SoundFx.setEnabled(willEnable);
              });

              if (willEnable) {
                await SoundFx.test();
              }
            },
            icon: Icon(
              _soundEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
            ),
          ),
          IconButton(
            tooltip: 'Sesi test et',
            onPressed: () async {
              if (!_soundEnabled) {
                setState(() {
                  _soundEnabled = true;
                  SoundFx.setEnabled(true);
                });
              }

              final played = await SoundFx.test();

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    played
                        ? 'Ses testi oynatıldı. Telefonun medya sesini kontrol et.'
                        : 'Ses oynatılamadı: ${SoundFx.lastError ?? 'bilinmeyen hata'}',
                  ),
                  duration: const Duration(seconds: 4),
                ),
              );
            },
            icon: const Icon(Icons.graphic_eq_rounded),
          ),"""

if old_sound_button not in source:
    raise SystemExit("Mevcut ses düğmesi bulunamadı.")
source = source.replace(old_sound_button, new_sound_button, 1)

for old_name, new_name in [
    ("dice_roll.wav", "dice_roll.mp3"),
    ("step.wav", "step.mp3"),
    ("landing.wav", "landing.mp3"),
    ("correct.wav", "correct.mp3"),
    ("wrong.wav", "wrong.mp3"),
    ("badge.wav", "badge.mp3"),
    ("win.wav", "win.mp3"),
]:
    source = source.replace(old_name, new_name)

for marker in [
    "AudioPlayer.global.ensureInitialized()",
    "AudioContextConfigFocus.mixWithOthers",
    "mimeType: 'audio/mpeg'",
    "Sesi test et",
    "SoundFx.lastError",
    "dice_roll.mp3",
]:
    if marker not in source:
        raise SystemExit(f"Ses düzeltme doğrulaması başarısız: {marker}")

if "await player.stop();" in source[source.index("class SoundFx {"):source.index("Future<void> main()")]:
    raise SystemExit("Sorunlu stop-before-play kodu kaldırılamadı.")

MAIN.write_text(source, encoding="utf-8")

pub = PUBSPEC.read_text(encoding="utf-8")

if "    - assets/sounds/" not in pub:
    raise SystemExit("pubspec.yaml içinde assets/sounds/ kaydı bulunamadı.")

pub = re.sub(
    r"^version:\s*.*$",
    "version: 1.11.1+13",
    pub,
    flags=re.MULTILINE,
)
PUBSPEC.write_text(pub, encoding="utf-8")

if shutil.which("flutter"):
    subprocess.run(["flutter", "pub", "get"], check=True)

if shutil.which("dart"):
    subprocess.run(["dart", "format", "lib/main.dart"], check=True)

subprocess.run(["git", "diff", "--check"], check=True)

files_to_add = [
    "lib/main.dart",
    "pubspec.yaml",
    "assets/sounds",
]
if Path("pubspec.lock").exists():
    files_to_add.append("pubspec.lock")

subprocess.run(["git", "add", *files_to_add], check=True)

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
            "Android ses oynatma sorununu duzelt",
        ],
        check=True,
    )

subprocess.run(["git", "push", "origin", "main"], check=True)

print("✅ WAV yerine Android uyumlu MP3 sesler bağlandı.")
print("✅ Ses sistemi uygulama açılırken başlatılacak.")
print("✅ Ses oynatmadan önceki sorunlu stop çağrısı kaldırıldı.")
print("✅ Android medya ses yönlendirmesi ayarlandı.")
print("✅ Üst menüye ayrı Ses Testi düğmesi eklendi.")
print("✅ Ses hatası olursa artık ekranda gerçek hata gösterilecek.")
print("✅ Kod GitHub'a gönderildi; Actions derlemesi başlayacak.")
