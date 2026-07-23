#!/usr/bin/env python3
from pathlib import Path
import re, shutil, subprocess, tempfile

MAIN = Path("lib/main.dart")
PUBSPEC = Path("pubspec.yaml")
TEST = Path("test/system_smoke_test.dart")
TARGET = Path("lib/pawn_step_sounds.dart")
PART_CONTENT = "part of 'main.dart';\n\nclass PawnStepSoundFactory {\n  PawnStepSoundFactory._();\n\n  static const int sampleRate = 22050;\n  static const int profileCount = 16;\n\n  static const List<String> profileNames = <String>[\n    'Renkli Halka Cam Tınısı',\n    'Bilgi Taşı Kristal Vuruşu',\n    'Beyin Maskotu Yumuşak Dokunuşu',\n    'Klasik Piyon Ahşap Tıkırtısı',\n    'Bilge At Toynak Sesi',\n    'Kristal Zar Küp Tıkırtısı',\n    'Pusula Yıldızı Metal Kliği',\n    'Açık Kitap Sayfa Dokunuşu',\n    'Ampul Fikri Elektrik Parıltısı',\n    'Kum Saati Kum Tıkırtısı',\n    'Soru İşareti Merak Bipi',\n    'Kupa Rozet Zafer Çanı',\n    'Minik Galaksi Bilgesi Kozmik Çanı',\n    'Fidan Muhafızı Dal ve Yaprak Sesi',\n    'Özgür Ev Cini Kumaş ve Sihir Sesi',\n    'Mağara Sinsiği Taş ve Yüzük Sesi',\n  ];\n\n  static const List<double> _volume = <double>[\n    .74, .72, .78, .82, .80, .78, .68, .72,\n    .66, .70, .72, .68, .66, .78, .70, .74,\n  ];\n\n  static const List<List<num>> _profile = <List<num>>[\n    [118, 860, 1290, .02, -.08, 1, 0],\n    [132, 1040, 1660, .015, -.14, 1, 0],\n    [112, 238, 356, .05, -.30, 1, 2],\n    [94, 182, 420, .26, -.20, 1, 1],\n    [126, 164, 292, .18, -.12, 2, 1],\n    [88, 286, 742, .34, -.16, 2, 3],\n    [106, 1180, 1840, .04, -.18, 1, 3],\n    [116, 430, 910, .52, .18, 1, 4],\n    [128, 1420, 2260, .08, .24, 3, 5],\n    [122, 680, 1080, .64, -.12, 3, 4],\n    [124, 490, 760, .03, .44, 2, 2],\n    [148, 654, 988, .02, -.10, 1, 0],\n    [158, 734, 1468, .025, .22, 3, 5],\n    [124, 206, 478, .30, -.18, 2, 1],\n    [136, 520, 1250, .13, .20, 2, 5],\n    [132, 148, 842, .32, -.24, 2, 3],\n  ];\n\n  static int normalize(int pawnType) =>\n      (pawnType % profileCount + profileCount) % profileCount;\n\n  static String fileNameForPawn(int pawnType) {\n    final no = normalize(pawnType) + 1;\n    return 'pawn_step_${no.toString().padLeft(2, '0')}.wav';\n  }\n\n  static String profileNameForPawn(int pawnType) =>\n      profileNames[normalize(pawnType)];\n\n  static double volumeForPawn(int pawnType) =>\n      _volume[normalize(pawnType)];\n\n  static double rateForStep(int pawnType, int stepIndex) {\n    final values = normalize(pawnType).isEven\n        ? const <double>[.97, 1, 1.035]\n        : const <double>[1.025, .985, 1];\n    return values[stepIndex.abs() % values.length];\n  }\n\n  static Map<String, Uint8List> buildAll() => <String, Uint8List>{\n        for (var index = 0; index < profileCount; index++)\n          fileNameForPawn(index): _build(index),\n      };\n\n  static Uint8List _build(int index) {\n    final p = _profile[index];\n    final durationMs = p[0].toInt();\n    final base = p[1].toDouble();\n    final second = p[2].toDouble();\n    final noiseMix = p[3].toDouble();\n    final glide = p[4].toDouble();\n    final pulses = p[5].toInt();\n    final character = p[6].toInt();\n    final count = (sampleRate * durationMs / 1000).round();\n    final samples = Int16List(count);\n    var state = 0x51F15EED ^ (index * 0x45D9F3B);\n\n    double noise() {\n      state = (1664525 * state + 1013904223) & 0x7FFFFFFF;\n      return state / 0x7FFFFFFF * 2 - 1;\n    }\n\n    for (var i = 0; i < count; i++) {\n      final t = i / sampleRate;\n      final x = i / max(1, count - 1);\n      final attack = min(1.0, t / .006);\n      final release = pow(1 - x, 2.25).toDouble();\n      final pulseX = (x * pulses) % 1.0;\n      final gate = pulses == 1\n          ? 1.0\n          : pow(max(0.0, 1 - pulseX), .42).toDouble();\n      final f1 = base * (1 + glide * x);\n      final f2 = second * (1 - glide * x * .35);\n      final a = 2 * pi * f1 * t;\n      final b = 2 * pi * f2 * t;\n      var tone = sin(a) * .72 + sin(b) * .28;\n\n      if (character == 1) {\n        tone = 2 / pi * asin(sin(a)) * .72 + sin(b) * .28;\n      } else if (character == 2) {\n        tone = sin(a) * .76 + sin(a * .5) * .24;\n      } else if (character == 3) {\n        tone = sin(a) * .55 + sin(b) * .30 + sin(b * 1.51) * .15;\n      } else if (character == 4) {\n        tone = sin(a) * .44 + sin(b) * .20;\n      } else if (character == 5) {\n        final sparkle =\n            pow(max(0.0, sin(pi * pulseX)), 8).toDouble();\n        tone = sin(a) * .50 +\n            sin(b) * .28 +\n            sin(b * 1.73) * sparkle * .22;\n      }\n\n      final transient = exp(-t * (42 + index % 4 * 6)) *\n          sin(2 * pi * (1700 + index * 73) * t);\n      var value = (tone * (1 - noiseMix) +\n              noise() * noiseMix +\n              transient * (.15 + noiseMix * .20)) *\n          attack *\n          release *\n          gate;\n      value = value.clamp(-1.0, 1.0).toDouble();\n      samples[i] = (value * 23500).round();\n    }\n\n    return _wav(samples);\n  }\n\n  static Uint8List _wav(Int16List samples) {\n    final dataLength = samples.length * 2;\n    final data = ByteData(44 + dataLength);\n\n    void text(int offset, String value) {\n      for (var i = 0; i < value.length; i++) {\n        data.setUint8(offset + i, value.codeUnitAt(i));\n      }\n    }\n\n    text(0, 'RIFF');\n    data.setUint32(4, 36 + dataLength, Endian.little);\n    text(8, 'WAVE');\n    text(12, 'fmt ');\n    data.setUint32(16, 16, Endian.little);\n    data.setUint16(20, 1, Endian.little);\n    data.setUint16(22, 1, Endian.little);\n    data.setUint32(24, sampleRate, Endian.little);\n    data.setUint32(28, sampleRate * 2, Endian.little);\n    data.setUint16(32, 2, Endian.little);\n    data.setUint16(34, 16, Endian.little);\n    text(36, 'data');\n    data.setUint32(40, dataLength, Endian.little);\n\n    for (var i = 0; i < samples.length; i++) {\n      data.setInt16(44 + i * 2, samples[i], Endian.little);\n    }\n    return data.buffer.asUint8List();\n  }\n}\n"
COMMIT_MESSAGE = "Her piyona ozgun hareket sesi ekle"

def run(command):
    print("$ " + " ".join(command))
    return subprocess.run(command, check=True)

for path in (MAIN, PUBSPEC, TEST):
    if not path.exists():
        raise SystemExit(f"Gerekli dosya bulunamadı: {path}")

branch = subprocess.check_output(
    ["git", "branch", "--show-current"], text=True
).strip()
if branch != "main":
    raise SystemExit(
        f"Bu paket main dalında çalışır. Şu anki dal: {branch or '(belirsiz)'}"
    )

question_status = subprocess.run(
    ["git", "status", "--porcelain", "--", "assets/questions.json"],
    text=True, capture_output=True, check=True,
).stdout.strip()
if question_status:
    raise SystemExit(
        "assets/questions.json dosyasında yerel değişiklik var. "
        "Önce soru çalışmasını tamamla."
    )

main = MAIN.read_text(encoding="utf-8")
pubspec = PUBSPEC.read_text(encoding="utf-8")
test = TEST.read_text(encoding="utf-8")

match = re.search(
    r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$",
    pubspec, flags=re.MULTILINE,
)
if not match:
    raise SystemExit("Sürüm satırı okunamadı.")
version = tuple(map(int, match.groups()))
if version != (1, 38, 0, 48):
    raise SystemExit(
        "Bu paket 1.38.0+48 sürümü için hazırlandı.\n"
        f"Depodaki sürüm: {version[0]}.{version[1]}.{version[2]}+{version[3]}"
    )

if TARGET.exists() or "SoundFx.pawnStep" in main:
    raise SystemExit("Piyona özel hareket sesleri zaten kurulmuş görünüyor.")

backup = Path(tempfile.mkdtemp(prefix="bilgi_rotasi_pawn_sound_"))
committed = False

try:
    shutil.copy2(MAIN, backup / "main.dart")
    shutil.copy2(PUBSPEC, backup / "pubspec.yaml")
    shutil.copy2(TEST, backup / "system_smoke_test.dart")
    TARGET.write_text(PART_CONTENT, encoding="utf-8")

    main = main.replace(
        "import 'dart:math';",
        "import 'dart:math';\nimport 'dart:typed_data';",
        1,
    )
    main = main.replace(
        "part 'game_ui_polish.dart';",
        "part 'game_ui_polish.dart';\npart 'pawn_step_sounds.dart';",
        1,
    )

    marker = """      for (final entry in embeddedSoundBase64.entries) {
        final bytes = base64Decode(entry.value);
        final file = File('${directory.path}/${entry.key}');

        final needsWrite =
            !await file.exists() || await file.length() != bytes.length;

        if (needsWrite) {
          await file.writeAsBytes(
            bytes,
            flush: true,
          );
        }

        _soundPaths[entry.key] = file.path;
      }
"""
    if marker not in main:
        raise RuntimeError("Ses hazırlama bloğu bulunamadı.")
    main = main.replace(
        marker,
        marker + """
      for (final entry in PawnStepSoundFactory.buildAll().entries) {
        final file = File('${directory.path}/${entry.key}');
        final bytes = entry.value;
        final needsWrite =
            !await file.exists() || await file.length() != bytes.length;

        if (needsWrite) {
          await file.writeAsBytes(bytes, flush: true);
        }
        _soundPaths[entry.key] = file.path;
      }
""",
        1,
    )

    old = """  static Future<bool> _play(
    AudioPlayer player,
    String fileName, {
    double volume = 1,
  }) async {
"""
    new = """  static Future<bool> _play(
    AudioPlayer player,
    String fileName, {
    double volume = 1,
    double playbackRateMultiplier = 1,
  }) async {
"""
    if old not in main:
        raise RuntimeError("SoundFx._play bloğu bulunamadı.")
    main = main.replace(old, new, 1)

    old = """      await player.setPlaybackRate(
        atmosphere.playbackRate,
      );
"""
    new = """      await player.setPlaybackRate(
        (
          atmosphere.playbackRate *
              playbackRateMultiplier
        ).clamp(0.5, 2.0).toDouble(),
      );
"""
    if old not in main:
        raise RuntimeError("Ses hızı bloğu bulunamadı.")
    main = main.replace(old, new, 1)

    old = """  static Future<bool> step() {
    return _play(
      _stepPlayer,
      'step.mp3',
      volume: 0.88,
    );
  }
"""
    new = """  static Future<bool> step() {
    return pawnStep(0);
  }

  static Future<bool> pawnStep(
    int pawnType, {
    int stepIndex = 0,
  }) {
    return _play(
      _stepPlayer,
      PawnStepSoundFactory.fileNameForPawn(pawnType),
      volume: PawnStepSoundFactory.volumeForPawn(pawnType),
      playbackRateMultiplier:
          PawnStepSoundFactory.rateForStep(pawnType, stepIndex),
    );
  }
"""
    if old not in main:
        raise RuntimeError("Mevcut adım sesi metodu bulunamadı.")
    main = main.replace(old, new, 1)

    old = """  Future<void> _animatePawnPath(List<int> path) async {
    for (final id in path.skip(1)) {
      setState(() {
        _currentPlayer.position = id;
        _currentPlayer.movePulse++;
      });

      unawaited(SoundFx.step());
      GameHaptics.selectionClick();

      await Future<void>.delayed(
        const Duration(milliseconds: 390),
      );

      if (!mounted) return;
    }
  }
"""
    new = """  Future<void> _animatePawnPath(List<int> path) async {
    final pawnType = _currentPlayer.pawnType;
    var stepIndex = 0;

    for (final id in path.skip(1)) {
      setState(() {
        _currentPlayer.position = id;
        _currentPlayer.movePulse++;
      });

      unawaited(
        SoundFx.pawnStep(
          pawnType,
          stepIndex: stepIndex,
        ),
      );
      stepIndex++;
      GameHaptics.selectionClick();

      await Future<void>.delayed(
        const Duration(milliseconds: 390),
      );

      if (!mounted) return;
    }
  }
"""
    if old not in main:
        raise RuntimeError("Piyon hareket bloğu bulunamadı.")
    main = main.replace(old, new, 1)

    main, count = re.subn(
        r"Bilgi Rotası • Sürüm 1\.38\.0",
        "Bilgi Rotası • Sürüm 1.39.0",
        main, count=1,
    )
    if count != 1:
        raise RuntimeError("Ana menü sürümü güncellenemedi.")
    pubspec = re.sub(
        r"^version:\s*.*$", "version: 1.39.0+49",
        pubspec, count=1, flags=re.MULTILINE,
    )

    test_insert = """
    test('On altı piyonun hareket sesi birbirinden ayrıdır', () {
      expect(PawnStepSoundFactory.profileCount, 16);
      expect(
        PawnStepSoundFactory.profileNames.length,
        PawnCatalog.all.length,
      );

      final sounds = PawnStepSoundFactory.buildAll();
      expect(sounds.length, 16);
      final signatures = <int>{};

      for (var index = 0; index < 16; index++) {
        final bytes = sounds[
          PawnStepSoundFactory.fileNameForPawn(index)
        ];
        expect(bytes, isNotNull);
        expect(bytes!.length, greaterThan(1500));
        expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF');
        expect(String.fromCharCodes(bytes.sublist(8, 12)), 'WAVE');

        var signature = 17;
        for (final byte in bytes) {
          signature = (signature * 31 + byte) & 0x7FFFFFFF;
        }
        signatures.add(signature);
      }

      expect(signatures.length, 16);
    });
"""
    end = test.rfind("  });\n}")
    if end < 0:
        raise RuntimeError("Test ekleme noktası bulunamadı.")
    test = test[:end] + test_insert + test[end:]

    MAIN.write_text(main, encoding="utf-8")
    PUBSPEC.write_text(pubspec, encoding="utf-8")
    TEST.write_text(test, encoding="utf-8")

    required = {
        MAIN: [
            "import 'dart:typed_data';",
            "part 'pawn_step_sounds.dart';",
            "SoundFx.pawnStep(",
            "Bilgi Rotası • Sürüm 1.39.0",
        ],
        TARGET: [
            "class PawnStepSoundFactory",
            "profileCount = 16",
            "Minik Galaksi Bilgesi Kozmik Çanı",
            "Mağara Sinsiği Taş ve Yüzük Sesi",
        ],
        PUBSPEC: ["version: 1.39.0+49"],
        TEST: ["On altı piyonun hareket sesi birbirinden ayrıdır"],
    }
    for path, markers in required.items():
        content = path.read_text(encoding="utf-8")
        for item in markers:
            if item not in content:
                raise RuntimeError(f"Doğrulama başarısız: {path} / {item}")

    if shutil.which("dart"):
        run([
            "dart", "format",
            "lib/main.dart",
            "lib/pawn_step_sounds.dart",
            "test/system_smoke_test.dart",
        ])
    run(["git", "diff", "--check"])

    if "assets/questions.json" in subprocess.check_output(
        ["git", "diff", "--name-only"], text=True
    ).splitlines():
        raise RuntimeError("questions.json değişmiş görünüyor.")

    if shutil.which("flutter"):
        run(["flutter", "pub", "get"])
        run([
            "flutter", "analyze",
            "--no-fatal-warnings", "--no-fatal-infos",
        ])
        run(["flutter", "test"])
    else:
        print("ℹ️ Flutter yok; testler GitHub Actions'ta çalışacak.")

    files = [
        "lib/main.dart",
        "lib/pawn_step_sounds.dart",
        "test/system_smoke_test.dart",
        "pubspec.yaml",
    ]
    if Path("pubspec.lock").exists():
        files.append("pubspec.lock")
    run(["git", "add", *files])

    if subprocess.run(
        ["git", "diff", "--cached", "--quiet"], check=False
    ).returncode == 0:
        raise RuntimeError("Commit edilecek değişiklik bulunamadı.")

    run(["git", "commit", "-m", COMMIT_MESSAGE])
    committed = True
    run(["git", "push", "origin", "main"])

except Exception as error:
    if not committed:
        shutil.copy2(backup / "main.dart", MAIN)
        shutil.copy2(backup / "pubspec.yaml", PUBSPEC)
        shutil.copy2(backup / "system_smoke_test.dart", TEST)
        if TARGET.exists():
            TARGET.unlink()
        subprocess.run([
            "git", "reset", "--",
            "lib/main.dart",
            "lib/pawn_step_sounds.dart",
            "test/system_smoke_test.dart",
            "pubspec.yaml",
        ], check=False)
        if shutil.which("flutter"):
            subprocess.run(["flutter", "pub", "get"], check=False)

    print("\n❌ Kurulum tamamlanamadı.")
    print(error)
    if committed:
        print("Commit oluştu, push başarısız. Çalıştır: git push origin main")
    else:
        print("Dosyalar önceki hâline döndürüldü.")
    raise SystemExit(1)

finally:
    shutil.rmtree(backup, ignore_errors=True)

print("""
✅ 16 piyonun her birine özgün hareket sesi eklendi.
✅ Her adımda küçük ton değişimi uygulanıyor.
✅ Ses ayarları ve sessize alma korunuyor.
✅ Haricî/telifli ses kullanılmadı.
✅ questions.json dosyasına dokunulmadı.
✅ Yeni sürüm: 1.39.0+49
✅ Değişiklikler main dalına gönderildi.
""")
