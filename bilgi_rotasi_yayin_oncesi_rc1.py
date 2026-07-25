#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess
import sys

MAIN = Path("lib/main.dart")
SYSTEM_HEALTH = Path("lib/system_health.dart")
NAVIGATION = Path("lib/main_navigation.dart")
PUBSPEC = Path("pubspec.yaml")
WORKFLOW = Path(".github/workflows/android-apk.yml")

TEMPLATES = {
    "release_candidate": Path("release_candidate.dart"),
    "validator": Path("validate_questions.py"),
    "smoke_test": Path("release_smoke_test.dart"),
    "workflow": Path("android-apk-rc.yml"),
}

for path in [
    MAIN,
    SYSTEM_HEALTH,
    NAVIGATION,
    PUBSPEC,
    WORKFLOW,
    *TEMPLATES.values(),
]:
    if not path.exists():
        raise SystemExit(
            f"Gerekli dosya bulunamadı: {path}\n"
            "Bu betiği BilgiRotasi deposunun ana klasöründe çalıştır."
        )

main_source = MAIN.read_text(encoding="utf-8")
health_source = SYSTEM_HEALTH.read_text(encoding="utf-8")
navigation_source = NAVIGATION.read_text(encoding="utf-8")

for marker in [
    "part 'pawn_visual_effects.dart';",
    "Bilgi Rotası • Sürüm 1.41.0",
]:
    if marker not in main_source:
        raise SystemExit(f"Beklenen güncel ana kod bulunamadı: {marker}")

for marker in [
    "class SystemHealthScreen extends StatefulWidget",
    "_performanceCard(),",
    "Sürüm 1.29.0+38",
]:
    if marker not in health_source:
        raise SystemExit(f"Sistem Sağlığı işareti bulunamadı: {marker}")

for marker in [
    "class SettingsCenterScreen extends StatelessWidget",
    "title: 'Eğitimi Yeniden Göster'",
]:
    if marker not in navigation_source:
        raise SystemExit(f"Ayarlar işareti bulunamadı: {marker}")

if "part 'release_candidate.dart';" in main_source:
    raise SystemExit("Yayın Öncesi RC1 paketi zaten uygulanmış.")

# Güvenli yedekler.
shutil.copy2(MAIN, "/tmp/bilgi_rotasi_rc1_main_before.dart")
shutil.copy2(
    SYSTEM_HEALTH,
    "/tmp/bilgi_rotasi_rc1_health_before.dart",
)
shutil.copy2(
    NAVIGATION,
    "/tmp/bilgi_rotasi_rc1_navigation_before.dart",
)
shutil.copy2(
    WORKFLOW,
    "/tmp/bilgi_rotasi_rc1_workflow_before.yml",
)

# 1) Release Candidate ekranları ve merkezi sürüm bilgisi.
release_target = Path("lib/release_candidate.dart")
shutil.copy2(TEMPLATES["release_candidate"], release_target)

main_source = main_source.replace(
    "part 'pawn_visual_effects.dart';",
    "part 'pawn_visual_effects.dart';\n"
    "part 'release_candidate.dart';",
    1,
)

old_version = """                const Text(
                  'Bilgi Rotası • Sürüm 1.41.0',
                  textAlign: TextAlign.center,"""

new_version = """                const Text(
                  'Bilgi Rotası • ${AppBuildInfo.shortLabel}',
                  textAlign: TextAlign.center,"""

if old_version not in main_source:
    raise SystemExit("Ana menü sürüm metni bulunamadı.")

main_source = main_source.replace(old_version, new_version, 1)
MAIN.write_text(main_source, encoding="utf-8")

# 2) Sistem Sağlığına yayın hazırlık kartı.
health_source = health_source.replace(
    "'Sürüm 1.29.0+38',",
    "AppBuildInfo.fullLabel,",
    1,
)
health_source = health_source.replace(
    "'Sürüm 1.29.0+38 • '",
    "'${AppBuildInfo.fullLabel} • '",
    1,
)

health_marker = """              _performanceCard(),
              const SizedBox(height: 12),
              _errorCard(data.errors),"""

health_replacement = """              _performanceCard(),
              const SizedBox(height: 12),
              ReleaseReadinessCard(
                questionBank: widget.questionBank,
                report: data.report,
                errorCount: data.errors.length,
              ),
              const SizedBox(height: 12),
              _errorCard(data.errors),"""

if health_marker not in health_source:
    raise SystemExit("RC kontrol kartı yerleştirme noktası bulunamadı.")

health_source = health_source.replace(
    health_marker,
    health_replacement,
    1,
)
SYSTEM_HEALTH.write_text(health_source, encoding="utf-8")

# 3) Ayarlara Hakkında & Gizlilik.
tutorial_marker = """        _HubActionCard(
          emoji: '📘',
          title: 'Eğitimi Yeniden Göster',"""

about_card = """        _HubActionCard(
          emoji: 'ℹ️',
          title: 'Hakkında & Gizlilik',
          description:
              'Sürüm bilgisi, çevrimdışı kullanım, '
              'yerel kayıtlar ve gizlilik açıklaması.',
          accent: const Color(0xFF475569),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AboutPrivacyScreen(
                questionBank: questionBank,
              ),
            ),
          ),
        ),
        _HubActionCard(
          emoji: '📘',
          title: 'Eğitimi Yeniden Göster',"""

if tutorial_marker not in navigation_source:
    raise SystemExit("Ayarlar kartı yerleştirme noktası bulunamadı.")

navigation_source = navigation_source.replace(
    tutorial_marker,
    about_card,
    1,
)
NAVIGATION.write_text(navigation_source, encoding="utf-8")

# 4) Doğrulayıcı, test ve CI iş akışı.
scripts_dir = Path("scripts")
tests_dir = Path("test")
release_dir = Path("release")

scripts_dir.mkdir(parents=True, exist_ok=True)
tests_dir.mkdir(parents=True, exist_ok=True)
release_dir.mkdir(parents=True, exist_ok=True)

shutil.copy2(
    TEMPLATES["validator"],
    scripts_dir / "validate_questions.py",
)
shutil.copy2(
    TEMPLATES["smoke_test"],
    tests_dir / "release_smoke_test.dart",
)
shutil.copy2(TEMPLATES["workflow"], WORKFLOW)

# 5) Yayın belgeleri.
for name in [
    "PRIVACY_POLICY_TR.md",
    "PLAY_STORE_LISTING_TR.md",
    "BETA_TEST_CHECKLIST.md",
    "RELEASE_CANDIDATE_1.md",
]:
    source = Path(name)
    if not source.exists():
        raise SystemExit(f"Yayın belgesi bulunamadı: {source}")
    shutil.copy2(source, release_dir / name)

# 6) Sürüm numarası.
pub = PUBSPEC.read_text(encoding="utf-8")
pub = re.sub(
    r"^version:\s*.*$",
    "version: 1.42.0+52",
    pub,
    flags=re.MULTILINE,
)
PUBSPEC.write_text(pub, encoding="utf-8")

# 7) Soru bankası kontrolü.
subprocess.run(
    [
        sys.executable,
        "scripts/validate_questions.py",
        "assets/questions.json",
    ],
    check=True,
)

# 8) Biçim, analiz ve duman testi.
if shutil.which("dart"):
    subprocess.run(
        [
            "dart",
            "format",
            "lib/main.dart",
            "lib/system_health.dart",
            "lib/main_navigation.dart",
            "lib/release_candidate.dart",
            "test/release_smoke_test.dart",
        ],
        check=True,
    )

subprocess.run(["git", "diff", "--check"], check=True)

if shutil.which("flutter"):
    subprocess.run(
        ["flutter", "analyze", "--no-fatal-infos"],
        check=True,
    )
    subprocess.run(
        [
            "flutter",
            "test",
            "test/release_smoke_test.dart",
            "--reporter",
            "expanded",
        ],
        check=True,
    )

# 9) Commit ve push.
subprocess.run(
    [
        "git",
        "add",
        "lib/main.dart",
        "lib/system_health.dart",
        "lib/main_navigation.dart",
        "lib/release_candidate.dart",
        "test/release_smoke_test.dart",
        "scripts/validate_questions.py",
        ".github/workflows/android-apk.yml",
        "release",
        "pubspec.yaml",
    ],
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
            "Yayin oncesi Release Candidate 1",
        ],
        check=True,
    )

subprocess.run(["git", "push", "origin", "main"], check=True)

print("")
print("✅ Bilgi Rotası 1.42.0+52 RC1 hazırlandı.")
print("✅ GitHub Actions kalite kapısı eklendi.")
print("✅ Soru bankası otomatik doğrulaması eklendi.")
print("✅ Flutter analiz ve duman testleri zorunlu yapıldı.")
print("✅ Release APK ve AAB üretimi eklendi.")
print("✅ Sistem Sağlığına RC hazırlık kartı eklendi.")
print("✅ Ayarlara Hakkında & Gizlilik ekranı eklendi.")
print("✅ Yayın belgeleri projeye eklendi.")
print("✅ Değişiklikler GitHub'a gönderildi.")
