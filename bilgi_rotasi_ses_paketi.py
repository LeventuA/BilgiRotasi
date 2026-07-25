#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess

MAIN = Path("lib/main.dart")
PUBSPEC = Path("pubspec.yaml")
TEMPLATE = Path("ses_sistemi.txt")
SOUNDS = Path("assets/sounds")

if not MAIN.exists() or not PUBSPEC.exists() or not TEMPLATE.exists():
    raise SystemExit(
        "Dosyaları BilgiRotasi proje ana klasöründe çalıştır."
    )

required_sounds = [
    "dice_roll.wav",
    "step.wav",
    "landing.wav",
    "correct.wav",
    "wrong.wav",
    "badge.wav",
    "win.wav",
]
for name in required_sounds:
    if not (SOUNDS / name).exists():
        raise SystemExit(f"Eksik ses dosyası: assets/sounds/{name}")

source = MAIN.read_text(encoding="utf-8")
shutil.copy2(MAIN, "/tmp/bilgi_rotasi_ses_oncesi.dart")

required = [
    "class _GameScreenState extends State<GameScreen>",
    "Future<void> _rollDiceAndAsk() async",
    "Future<void> _askFinalQuestion() async",
    "void _handleAnswer({",
    "HapticFeedback.mediumImpact();",
    "_currentPlayer.movePulse++;",
]
for marker in required:
    if marker not in source:
        raise SystemExit(f"Beklenen güncel kod bulunamadı: {marker}")

if "package:audioplayers/audioplayers.dart" not in source:
    source = source.replace(
        "import 'package:flutter/material.dart';",
        "import 'package:audioplayers/audioplayers.dart';\n"
        "import 'package:flutter/material.dart';",
        1,
    )

if "class SoundFx {" not in source:
    source = source.replace(
        "void main() {",
        TEMPLATE.read_text(encoding="utf-8") + "void main() {",
        1,
    )

old_fields = """  int? _landingNodeId;
  int _landingPulse = 0;"""
new_fields = """  int? _landingNodeId;
  int _landingPulse = 0;
  bool _soundEnabled = true;"""

if old_fields not in source:
    raise SystemExit("Ses ayarı alanının ekleneceği bölüm bulunamadı.")
source = source.replace(old_fields, new_fields, 1)

old_actions = """        actions: [
          IconButton(
            tooltip: 'Oyunu bitir',"""
new_actions = """        actions: [
          IconButton(
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
          ),
          IconButton(
            tooltip: 'Oyunu bitir',"""

if old_actions not in source:
    raise SystemExit("AppBar işlem düğmeleri bulunamadı.")
source = source.replace(old_actions, new_actions, 1)

old_dice_start = """    HapticFeedback.mediumImpact();

    for (var i = 0; i < 12; i++) {"""
new_dice_start = """    unawaited(SoundFx.dice());
    HapticFeedback.mediumImpact();

    for (var i = 0; i < 12; i++) {"""

if old_dice_start not in source:
    raise SystemExit("Zar başlangıç bölümü bulunamadı.")
source = source.replace(old_dice_start, new_dice_start, 1)

old_step = """      HapticFeedback.selectionClick();
      await Future<void>.delayed(const Duration(milliseconds: 390));"""
new_step = """      unawaited(SoundFx.step());
      HapticFeedback.selectionClick();
      await Future<void>.delayed(const Duration(milliseconds: 390));"""

if old_step not in source:
    raise SystemExit("Piyon adım bölümü bulunamadı.")
source = source.replace(old_step, new_step, 1)

old_landing = """    HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 520));"""
new_landing = """    unawaited(SoundFx.landing());
    HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 520));"""

if old_landing not in source:
    raise SystemExit("Piyon iniş bölümü bulunamadı.")
source = source.replace(old_landing, new_landing, 1)

old_final_correct = """      HapticFeedback.heavyImpact();
      await _showWinnerDialog(_currentPlayer);"""
new_final_correct = """      unawaited(SoundFx.win());
      HapticFeedback.heavyImpact();
      await _showWinnerDialog(_currentPlayer);"""

if old_final_correct not in source:
    raise SystemExit("Final doğru cevap bölümü bulunamadı.")
source = source.replace(old_final_correct, new_final_correct, 1)

old_final_wrong = """      setState(() {
        _status = 'Final kaçtı. Sıra ${_currentPlayer.name} oyuncusunda.';
        _isBusy = false;
      });
    }
  }

  void _handleAnswer({"""
new_final_wrong = """      setState(() {
        _status = 'Final kaçtı. Sıra ${_currentPlayer.name} oyuncusunda.';
        _isBusy = false;
      });
      unawaited(SoundFx.wrong());
    }
  }

  void _handleAnswer({"""

if old_final_wrong not in source:
    raise SystemExit("Final yanlış cevap bölümü bulunamadı.")
source = source.replace(old_final_wrong, new_final_wrong, 1)

old_badge_logic = """      answeredPlayer.correctAnswers++;
      var badgeMessage = '';
      if (wasBadgeCell && !answeredPlayer.badges.contains(categoryIndex)) {
        answeredPlayer.badges.add(categoryIndex);
        badgeMessage = ' ${GameCategory.values[categoryIndex].label} rozeti kazanıldı!';
      }"""
new_badge_logic = """      answeredPlayer.correctAnswers++;
      var badgeMessage = '';
      var badgeEarned = false;
      if (wasBadgeCell && !answeredPlayer.badges.contains(categoryIndex)) {
        answeredPlayer.badges.add(categoryIndex);
        badgeEarned = true;
        badgeMessage = ' ${GameCategory.values[categoryIndex].label} rozeti kazanıldı!';
      }"""

if old_badge_logic not in source:
    raise SystemExit("Rozet kazanma bölümü bulunamadı.")
source = source.replace(old_badge_logic, new_badge_logic, 1)

old_correct_end = """      });
      HapticFeedback.selectionClick();
    } else {
      answeredPlayer.wrongAnswers++;"""
new_correct_end = """      });
      unawaited(
        badgeEarned
            ? SoundFx.badge()
            : SoundFx.correct(),
      );
      HapticFeedback.selectionClick();
    } else {
      answeredPlayer.wrongAnswers++;"""

if old_correct_end not in source:
    raise SystemExit("Doğru cevap sesinin ekleneceği bölüm bulunamadı.")
source = source.replace(old_correct_end, new_correct_end, 1)

old_wrong_end = """      setState(() {
        _status = 'Yanlış cevap. Sıra ${_currentPlayer.name} oyuncusunda.';
        _isBusy = false;
      });
    }
  }"""
new_wrong_end = """      setState(() {
        _status = 'Yanlış cevap. Sıra ${_currentPlayer.name} oyuncusunda.';
        _isBusy = false;
      });
      unawaited(SoundFx.wrong());
    }
  }"""

if old_wrong_end not in source:
    raise SystemExit("Yanlış cevap sesinin ekleneceği bölüm bulunamadı.")
source = source.replace(old_wrong_end, new_wrong_end, 1)

for marker in [
    "class SoundFx {",
    "unawaited(SoundFx.dice());",
    "unawaited(SoundFx.step());",
    "unawaited(SoundFx.landing());",
    "badgeEarned",
    "unawaited(SoundFx.win());",
    "Icons.volume_up_rounded",
]:
    if marker not in source:
        raise SystemExit(f"Ses sistemi doğrulaması başarısız: {marker}")

MAIN.write_text(source, encoding="utf-8")

pub = PUBSPEC.read_text(encoding="utf-8")

if "  audioplayers:" not in pub:
    pub = pub.replace(
        "dependencies:\n",
        "dependencies:\n  audioplayers: ^6.8.1\n",
        1,
    )

if "    - assets/sounds/" not in pub:
    pub = pub.replace(
        "  assets:\n",
        "  assets:\n    - assets/sounds/\n",
        1,
    )

pub = re.sub(
    r"^version:\s*.*$",
    "version: 1.11.0+12",
    pub,
    flags=re.MULTILINE,
)
PUBSPEC.write_text(pub, encoding="utf-8")

if shutil.which("flutter"):
    subprocess.run(["flutter", "pub", "get"], check=True)
elif shutil.which("dart"):
    subprocess.run(["dart", "pub", "get"], check=True)

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
        ["git", "commit", "-m", "Oyun ses efektleri ve ses dugmesi"],
        check=True,
    )

subprocess.run(["git", "push", "origin", "main"], check=True)

print("✅ Zar yuvarlanma sesi eklendi.")
print("✅ Piyon adım ve iniş sesleri eklendi.")
print("✅ Doğru, yanlış ve rozet sesleri eklendi.")
print("✅ Şampiyonluk müziği eklendi.")
print("✅ Üst menüye ses aç/kapat düğmesi eklendi.")
print("✅ Ses hataları oyunu durdurmayacak şekilde güvenli hale getirildi.")
print("✅ Kod ve ses dosyaları GitHub'a gönderildi; Actions başlayacak.")
