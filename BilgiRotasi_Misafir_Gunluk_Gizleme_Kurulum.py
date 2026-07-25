#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import os
import re
import shutil
import subprocess
import tempfile
from pathlib import Path


BASE_VERSION = "1.48.3+67"

MAIN_NAV = Path("lib/main_navigation.dart")
BUILD_INFO = Path("lib/app_build_info.dart")
PUBSPEC = Path("pubspec.yaml")
SYSTEM_TEST = Path("test/system_smoke_test.dart")
RC_TEST = Path("test/rc1_quality_gate_test.dart")
QUALITY = Path("tools/rc1_quality_gate.py")
WORKFLOW = Path(".github/workflows/android-apk.yml")
CHECKLIST = Path("reports/RC1_MANUAL_TEST_CHECKLIST.md")
AUTOMATED_REPORT = Path("reports/RC1_AUTOMATED_REPORT.md")
QUESTIONS = Path("assets/questions.json")

TEXT_TARGETS = [
    MAIN_NAV,
    BUILD_INFO,
    PUBSPEC,
    SYSTEM_TEST,
    RC_TEST,
    QUALITY,
    WORKFLOW,
    CHECKLIST,
]
INTENDED_TARGETS = [*TEXT_TARGETS, AUTOMATED_REPORT]


class InstallError(RuntimeError):
    pass


def run(
    args: list[str],
    *,
    cwd: Path,
    check: bool = True,
    capture: bool = True,
    env: dict[str, str] | None = None,
) -> subprocess.CompletedProcess[str]:
    print("$ " + " ".join(args))
    completed = subprocess.run(
        args,
        cwd=cwd,
        check=False,
        text=True,
        capture_output=capture,
        env=env,
    )
    if check and completed.returncode != 0:
        detail = (completed.stderr or completed.stdout or "").strip()
        raise InstallError(
            f"Komut başarısız: {' '.join(args)}\n{detail}"
        )
    return completed


def locate_repo() -> Path:
    for candidate in [Path.cwd(), Path("/workspaces/BilgiRotasi")]:
        if not candidate.exists():
            continue
        completed = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            cwd=candidate,
            check=False,
            text=True,
            capture_output=True,
        )
        if completed.returncode == 0:
            return Path(completed.stdout.strip())

    raise InstallError(
        "BilgiRotasi Git deposu bulunamadı. "
        "Dosyayı /workspaces/BilgiRotasi içinde çalıştır."
    )


def sha256(path: Path) -> str | None:
    if not path.exists():
        return None
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def replace_once(
    text: str,
    old: str,
    new: str,
    *,
    label: str,
) -> str:
    count = text.count(old)
    if count != 1:
        raise InstallError(
            f"{label} için beklenen bölüm bulunamadı. "
            f"Eşleşme sayısı: {count}"
        )
    return text.replace(old, new, 1)


def backup_targets(
    repo: Path,
    backup: Path,
) -> dict[Path, bool]:
    existed: dict[Path, bool] = {}
    for relative in INTENDED_TARGETS:
        source = repo / relative
        existed[relative] = source.exists()
        if source.exists():
            destination = backup / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, destination)
    return existed


def restore_targets(
    repo: Path,
    backup: Path,
    existed: dict[Path, bool],
) -> None:
    for relative in INTENDED_TARGETS:
        destination = repo / relative
        if existed.get(relative, False):
            source = backup / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, destination)
        elif destination.exists():
            destination.unlink()


def patch_main_navigation(text: str) -> str:
    text = replace_once(
        text,
        "class MainNavigationGrid extends StatelessWidget {\n",
        """class MainNavigationPolicy {
  MainNavigationPolicy._();

  static List<MainNavigationSection> visibleSections(
    AccountMode mode,
  ) {
    return <MainNavigationSection>[
      MainNavigationSection.play,
      if (AccountAccessPolicy.dailyVisible(mode))
        MainNavigationSection.daily,
      MainNavigationSection.career,
      MainNavigationSection.social,
      MainNavigationSection.settings,
    ];
  }

  static bool dailyVisible(AccountMode mode) {
    return visibleSections(mode).contains(
      MainNavigationSection.daily,
    );
  }
}

class MainNavigationGrid extends StatelessWidget {
""",
        label="ana navigasyon görünürlük politikası",
    )

    text = replace_once(
        text,
        """  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _pair(
          context,
          MainNavigationSection.play,
          MainNavigationSection.daily,
        ),
        const SizedBox(height: 10),
        _pair(
          context,
          MainNavigationSection.career,
          MainNavigationSection.social,
        ),
        const SizedBox(height: 10),
        _MainNavigationCard(
          section: MainNavigationSection.settings,
          horizontal: true,
          onTap: () => _open(
            context,
            SettingsCenterScreen(
              questionBank: questionBank,
            ),
          ),
        ),
      ],
    );
  }
""",
        """  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AccountSessionState>(
      valueListenable: AccountCloudService.state,
      builder: (context, session, _) {
        final showDaily = MainNavigationPolicy.dailyVisible(
          session.mode,
        );

        return Column(
          children: [
            if (showDaily)
              _pair(
                context,
                MainNavigationSection.play,
                MainNavigationSection.daily,
              )
            else
              _MainNavigationCard(
                section: MainNavigationSection.play,
                horizontal: true,
                onTap: () => _openSection(
                  context,
                  MainNavigationSection.play,
                ),
              ),
            const SizedBox(height: 10),
            _pair(
              context,
              MainNavigationSection.career,
              MainNavigationSection.social,
            ),
            const SizedBox(height: 10),
            _MainNavigationCard(
              section: MainNavigationSection.settings,
              horizontal: true,
              onTap: () => _open(
                context,
                SettingsCenterScreen(
                  questionBank: questionBank,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
""",
        label="hesaba duyarlı ana navigasyon",
    )

    text = replace_once(
        text,
        """  void _openSection(
    BuildContext context,
    MainNavigationSection section,
  ) {
    final screen = switch (section) {
""",
        """  void _openSection(
    BuildContext context,
    MainNavigationSection section,
  ) {
    if (section == MainNavigationSection.daily &&
        !AccountCloudService.dailyVisible) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Günlük görevler Google hesabıyla giriş '
            'yapıldığında açılır.',
          ),
        ),
      );
      return;
    }

    final screen = switch (section) {
""",
        label="Günlük bölümü erişim koruması",
    )

    return text


def patch_system_test(text: str) -> str:
    return replace_once(
        text,
        """    test('Oyun arayüzü telefon ve geniş ekranı ayırır', () {
""",
        """    test('Misafir navigasyonunda Günlük bölümü gizlidir', () {
      final guestSections =
          MainNavigationPolicy.visibleSections(
        AccountMode.guest,
      );
      final undecidedSections =
          MainNavigationPolicy.visibleSections(
        AccountMode.undecided,
      );
      final googleSections =
          MainNavigationPolicy.visibleSections(
        AccountMode.google,
      );

      expect(guestSections.length, 4);
      expect(
        guestSections,
        isNot(contains(MainNavigationSection.daily)),
      );
      expect(
        undecidedSections,
        isNot(contains(MainNavigationSection.daily)),
      );
      expect(googleSections.length, 5);
      expect(
        googleSections,
        contains(MainNavigationSection.daily),
      );
    });

    test('Oyun arayüzü telefon ve geniş ekranı ayırır', () {
""",
        label="misafir Günlük görünürlük testi",
    )


def patch_versions(contents: dict[Path, str]) -> dict[Path, str]:
    contents[PUBSPEC] = replace_once(
        contents[PUBSPEC],
        "version: 1.48.3+67",
        "version: 1.48.4+68",
        label="pubspec sürümü",
    )

    build = contents[BUILD_INFO]
    build = replace_once(
        build,
        "  static const String versionName = '1.48.3';",
        "  static const String versionName = '1.48.4';",
        label="uygulama sürüm adı",
    )
    build = replace_once(
        build,
        "  static const int buildNumber = 67;",
        "  static const int buildNumber = 68;",
        label="uygulama yapı numarası",
    )
    contents[BUILD_INFO] = build

    rc = contents[RC_TEST]
    rc = replace_once(
        rc,
        "expect(AppBuildInfo.versionName, '1.48.3');",
        "expect(AppBuildInfo.versionName, '1.48.4');",
        label="RC2 sürüm adı testi",
    )
    rc = replace_once(
        rc,
        "expect(AppBuildInfo.buildNumber, 67);",
        "expect(AppBuildInfo.buildNumber, 68);",
        label="RC2 yapı numarası testi",
    )
    rc = replace_once(
        rc,
        "expect(AppBuildInfo.version, '1.48.3+67');",
        "expect(AppBuildInfo.version, '1.48.4+68');",
        label="RC2 tam sürüm testi",
    )
    rc = replace_once(
        rc,
        "'Sürüm 1.48.3+67 • RC2'",
        "'Sürüm 1.48.4+68 • RC2'",
        label="RC2 sürüm etiketi testi",
    )
    contents[RC_TEST] = rc

    contents[QUALITY] = replace_once(
        contents[QUALITY],
        'EXPECTED_VERSION = "1.48.3+67"',
        'EXPECTED_VERSION = "1.48.4+68"',
        label="kalite kapısı sürümü",
    )

    workflow = contents[WORKFLOW]
    if "1.48.3+67" not in workflow or "1.48.3-67" not in workflow:
        raise InstallError("Workflow sürüm işaretleri bulunamadı.")
    workflow = workflow.replace("1.48.3+67", "1.48.4+68")
    workflow = workflow.replace("1.48.3-67", "1.48.4-68")
    contents[WORKFLOW] = workflow

    checklist = contents[CHECKLIST].replace(
        "1.48.3+67",
        "1.48.4+68",
    )
    if "## 9. Misafir Günlük görünürlüğü testi" in checklist:
        raise InstallError(
            "Misafir Günlük test bölümü zaten mevcut."
        )
    checklist = checklist.rstrip() + """

## 9. Misafir Günlük görünürlüğü testi

- [ ] Misafir modunda ana sayfadaki Günlük Görev kartı görünmedi.
- [ ] Misafir modunda Bölümler alanındaki Günlük kartı görünmedi.
- [ ] Misafir modunda Oyna kartı tam genişlikte göründü.
- [ ] Google hesabıyla giriş yapılınca Günlük kartı otomatik geri geldi.
- [ ] Google hesabından çıkınca Günlük kartı tekrar gizlendi.
- [ ] Misafir kullanıcı diğer oyun modlarına erişebildi.
"""
    contents[CHECKLIST] = checklist

    return contents


def validate_patched(contents: dict[Path, str]) -> None:
    expected: dict[Path, list[str]] = {
        MAIN_NAV: [
            "class MainNavigationPolicy",
            "ValueListenableBuilder<AccountSessionState>",
            "if (showDaily)",
            "Günlük görevler Google hesabıyla giriş",
        ],
        BUILD_INFO: [
            "versionName = '1.48.4'",
            "buildNumber = 68",
        ],
        PUBSPEC: ["version: 1.48.4+68"],
        SYSTEM_TEST: [
            "Misafir navigasyonunda Günlük bölümü gizlidir",
            "AccountMode.guest",
            "AccountMode.google",
        ],
        RC_TEST: [
            "AppBuildInfo.versionName, '1.48.4'",
            "AppBuildInfo.buildNumber, 68",
            "AppBuildInfo.version, '1.48.4+68'",
        ],
        QUALITY: ['EXPECTED_VERSION = "1.48.4+68"'],
        WORKFLOW: [
            "BilgiRotasi-1.48.4-68-signed.apk",
            "BilgiRotasi-1.48.4-68-signed.aab",
            "BilgiRotasi-Signed-RC2-1.48.4-68",
            "Sürüm: 1.48.4+68",
        ],
        CHECKLIST: [
            "Sürüm: **1.48.4+68 • RC2**",
            "Misafir Günlük görünürlüğü testi",
        ],
    }

    for relative, markers in expected.items():
        for marker in markers:
            if marker not in contents[relative]:
                raise InstallError(
                    f"Kurulum doğrulaması başarısız: "
                    f"{relative} / {marker}"
                )


def main() -> int:
    repo = locate_repo()

    branch = run(
        ["git", "branch", "--show-current"],
        cwd=repo,
    ).stdout.strip()
    if branch != "main":
        raise InstallError(
            f"Kurulum main dalında çalışmalıdır. "
            f"Mevcut dal: {branch or '(yok)'}"
        )

    required = [*TEXT_TARGETS, AUTOMATED_REPORT, QUESTIONS]
    missing = [
        str(relative)
        for relative in required
        if not (repo / relative).is_file()
    ]
    if missing:
        raise InstallError(
            "Gerekli proje dosyaları bulunamadı:\n"
            + "\n".join(missing)
        )

    protected_status = run(
        [
            "git",
            "status",
            "--porcelain",
            "--",
            *[str(path) for path in [*INTENDED_TARGETS, QUESTIONS]],
        ],
        cwd=repo,
    ).stdout.strip()
    if protected_status:
        raise InstallError(
            "Kurulumun değiştireceği dosyalarda yerel değişiklik var:\n"
            + protected_status
            + "\nÖnce bu değişiklikleri commit et."
        )

    run(["git", "fetch", "origin", "main"], cwd=repo)
    divergence = run(
        [
            "git",
            "rev-list",
            "--left-right",
            "--count",
            "HEAD...origin/main",
        ],
        cwd=repo,
    ).stdout.strip().split()

    if len(divergence) != 2:
        raise InstallError("Git dal durumu okunamadı.")

    ahead, behind = map(int, divergence)
    if ahead > 0:
        raise InstallError(
            "GitHub'a gönderilmemiş yerel commit var."
        )
    if behind > 0:
        run(
            ["git", "pull", "--ff-only", "origin", "main"],
            cwd=repo,
            capture=False,
        )

    question_hash_before = sha256(repo / QUESTIONS)
    contents = {
        relative: (repo / relative).read_text(encoding="utf-8")
        for relative in TEXT_TARGETS
    }

    version_match = re.search(
        r"(?m)^version:\s*([^\s]+)\s*$",
        contents[PUBSPEC],
    )
    current_version = version_match.group(1) if version_match else "?"
    if current_version != BASE_VERSION:
        raise InstallError(
            f"Bu paket {BASE_VERSION} sürümü için hazırlandı. "
            f"Depodaki sürüm: {current_version}"
        )

    if "class MainNavigationPolicy" in contents[MAIN_NAV]:
        raise InstallError(
            "Misafir Günlük görünürlük düzeltmesi zaten kurulu."
        )

    contents[MAIN_NAV] = patch_main_navigation(
        contents[MAIN_NAV],
    )
    contents[SYSTEM_TEST] = patch_system_test(
        contents[SYSTEM_TEST],
    )
    contents = patch_versions(contents)
    validate_patched(contents)

    backup = Path(
        tempfile.mkdtemp(
            prefix="bilgi_rotasi_misafir_gunluk_"
        )
    )
    existed = backup_targets(repo, backup)
    committed = False

    try:
        for relative, text in contents.items():
            destination = repo / relative
            destination.parent.mkdir(
                parents=True,
                exist_ok=True,
            )
            destination.write_text(
                text,
                encoding="utf-8",
                newline="\n",
            )

        if sha256(repo / QUESTIONS) != question_hash_before:
            raise InstallError(
                "Güvenlik kontrolü: assets/questions.json değişti."
            )

        if shutil.which("dart"):
            run(
                [
                    "dart",
                    "format",
                    str(MAIN_NAV),
                    str(BUILD_INFO),
                    str(SYSTEM_TEST),
                    str(RC_TEST),
                ],
                cwd=repo,
                capture=False,
            )

        run(
            [
                "git",
                "diff",
                "--check",
                "--",
                *[str(path) for path in INTENDED_TARGETS],
            ],
            cwd=repo,
        )

        run(
            [
                "python3",
                str(QUALITY),
                "--report",
                str(AUTOMATED_REPORT),
            ],
            cwd=repo,
            capture=False,
        )

        report_text = (
            repo / AUTOMATED_REPORT
        ).read_text(encoding="utf-8")

        for marker in [
            "- Durum: **BAŞARILI**",
            "- Sürüm: `1.48.4+68`",
            "- Toplam soru: **6710**",
            "- Kritik hata yok.",
        ]:
            if marker not in report_text:
                raise InstallError(
                    "Yenilenen kalite raporu doğrulanamadı: "
                    + marker
                )

        if shutil.which("flutter"):
            run(
                [
                    "flutter",
                    "analyze",
                    "--no-fatal-warnings",
                    "--no-fatal-infos",
                ],
                cwd=repo,
                capture=False,
            )
            run(
                ["flutter", "test"],
                cwd=repo,
                capture=False,
            )
        else:
            print(
                "ℹ️ Flutter bu ortamda bulunamadı; "
                "analiz ve test GitHub Actions'ta çalışacak."
            )

        if sha256(repo / QUESTIONS) != question_hash_before:
            raise InstallError(
                "Testlerden sonra soru dosyası değişmiş görünüyor."
            )

        run(
            [
                "git",
                "add",
                "--",
                *[str(path) for path in INTENDED_TARGETS],
            ],
            cwd=repo,
        )

        staged = sorted(
            line.strip()
            for line in run(
                ["git", "diff", "--cached", "--name-only"],
                cwd=repo,
            ).stdout.splitlines()
            if line.strip()
        )
        expected = sorted(
            str(path) for path in INTENDED_TARGETS
        )

        if staged != expected:
            raise InstallError(
                "Commit dosyaları beklenenle eşleşmedi.\n"
                f"Beklenen: {expected}\n"
                f"Bulunan: {staged}"
            )

        run(
            [
                "git",
                "commit",
                "-m",
                "Misafir modunda Gunluk bolumunu gizle",
            ],
            cwd=repo,
            capture=False,
        )
        committed = True

        push_env = os.environ.copy()
        push_env.pop("GH_TOKEN", None)
        push_env.pop("GITHUB_TOKEN", None)

        run(
            ["git", "push", "origin", "main"],
            cwd=repo,
            capture=False,
            env=push_env,
        )

        print()
        print("✅ MİSAFİR GÜNLÜK DÜZELTMESİ TAMAMLANDI")
        print("✅ Misafir modunda Günlük kartı gizlendi.")
        print("✅ Misafirde Oyna kartı tam genişlikte gösteriliyor.")
        print("✅ Google girişinde Günlük kartı otomatik geri geliyor.")
        print("✅ Çıkış yapıldığında Günlük kartı tekrar gizleniyor.")
        print("✅ Eski kalite raporu 6710 soruyla yenilendi.")
        print("✅ assets/questions.json dosyasına dokunulmadı.")
        print("✅ Yeni sürüm: 1.48.4+68 • RC2")
        print("✅ Değişiklikler GitHub main dalına gönderildi.")
        return 0

    except Exception:
        if not committed:
            restore_targets(repo, backup, existed)
            run(
                [
                    "git",
                    "restore",
                    "--staged",
                    "--",
                    *[str(path) for path in INTENDED_TARGETS],
                ],
                cwd=repo,
                check=False,
            )
        raise
    finally:
        shutil.rmtree(backup, ignore_errors=True)


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except InstallError as error:
        print()
        print("❌ KURULUM DURDU")
        print(str(error))
        raise SystemExit(1)
    except Exception as error:
        print()
        print("❌ KURULUM BAŞARISIZ")
        print(f"{type(error).__name__}: {error}")
        print(
            "Commit oluştuysa yalnızca şu komutu çalıştır: "
            "env -u GH_TOKEN -u GITHUB_TOKEN "
            "git push origin main"
        )
        raise SystemExit(1)
