#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

PUBSPEC = Path("pubspec.yaml")
BUILD_INFO = Path("lib/app_build_info.dart")
WORKFLOW = Path(".github/workflows/android-apk.yml")
QUESTIONS = Path("assets/questions.json")
TARGETS = [PUBSPEC, BUILD_INFO, WORKFLOW]

OLD_VERSION = "1.46.0+60"
NEW_VERSION = "1.46.1+61"
OLD_ARTIFACT = "BilgiRotasi-Signed-RC1-1.46.0-60"
NEW_ARTIFACT = "BilgiRotasi-Signed-RC1-1.46.1-61"
OLD_APK = "BilgiRotasi-1.46.0-60-signed.apk"
NEW_APK = "BilgiRotasi-1.46.1-61-signed.apk"
COMMIT_MESSAGE = "Kalici imza guncelleme test surumunu hazirla"


class InstallError(RuntimeError):
    pass


def run(cmd: list[str], *, check: bool = True, clean_auth: bool = False):
    env = os.environ.copy()
    if clean_auth:
        env.pop("GH_TOKEN", None)
        env.pop("GITHUB_TOKEN", None)
        env["GIT_TERMINAL_PROMPT"] = "0"
    result = subprocess.run(
        cmd,
        text=True,
        capture_output=True,
        check=False,
        env=env,
    )
    if check and result.returncode != 0:
        detail = (result.stderr or result.stdout or "").strip()
        raise InstallError(f"Komut başarısız: {' '.join(cmd)}\n{detail}")
    return result


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise InstallError(
            f"{label} bulunamadı veya birden fazla bulundu: {count}"
        )
    return text.replace(old, new, 1)


def verify_environment() -> None:
    required = [
        Path(".git"),
        PUBSPEC,
        BUILD_INFO,
        WORKFLOW,
        QUESTIONS,
        Path("tools/rc1_quality_gate.py"),
    ]
    missing = [str(p) for p in required if not p.exists()]
    if missing:
        raise InstallError(
            "Kurulum depo kökünde çalıştırılmalı. Eksik: "
            + ", ".join(missing)
        )

    branch = run(["git", "branch", "--show-current"]).stdout.strip()
    if branch != "main":
        raise InstallError(f"Geçerli dal main değil: {branch or '?'}")

    for path in TARGETS:
        if run(
            ["git", "diff", "--quiet", "--", str(path)],
            check=False,
        ).returncode != 0:
            raise InstallError(f"Yerel değişiklik var: {path}")
        if run(
            ["git", "diff", "--cached", "--quiet", "--", str(path)],
            check=False,
        ).returncode != 0:
            raise InstallError(f"Stage edilmiş değişiklik var: {path}")

    run(["git", "fetch", "origin", "main"], clean_auth=True)
    local = run(["git", "rev-parse", "HEAD"]).stdout.strip()
    remote = run(["git", "rev-parse", "origin/main"]).stdout.strip()
    if local != remote:
        raise InstallError(
            "Codespaces güncel değil. Önce git pull --ff-only çalıştırın."
        )


def update_files() -> None:
    pubspec = PUBSPEC.read_text(encoding="utf-8")
    build = BUILD_INFO.read_text(encoding="utf-8")
    workflow = WORKFLOW.read_text(encoding="utf-8")

    pubspec = replace_once(
        pubspec,
        f"version: {OLD_VERSION}",
        f"version: {NEW_VERSION}",
        "pubspec sürümü",
    )
    build = replace_once(
        build,
        "static const String versionName = '1.46.0';",
        "static const String versionName = '1.46.1';",
        "uygulama sürüm adı",
    )
    build = replace_once(
        build,
        "static const int buildNumber = 60;",
        "static const int buildNumber = 61;",
        "uygulama build numarası",
    )

    workflow = replace_once(
        workflow,
        f'APK="dist/{OLD_APK}"',
        f'APK="dist/{NEW_APK}"',
        "APK çıktı adı",
    )
    workflow = replace_once(
        workflow,
        f'echo "- Sürüm: {OLD_VERSION}"',
        f'echo "- Sürüm: {NEW_VERSION}"',
        "rapor sürümü",
    )
    workflow = replace_once(
        workflow,
        f"name: {OLD_ARTIFACT}",
        f"name: {NEW_ARTIFACT}",
        "artifact adı",
    )
    workflow = replace_once(
        workflow,
        f"dist/{OLD_APK}",
        f"dist/{NEW_APK}",
        "artifact APK yolu",
    )

    PUBSPEC.write_text(pubspec, encoding="utf-8")
    BUILD_INFO.write_text(build, encoding="utf-8")
    WORKFLOW.write_text(workflow, encoding="utf-8")


def run_checks(question_hash: str) -> None:
    run(["git", "diff", "--check"])

    report = Path("reports/RC1_UPDATE_TEST_TEMP.md")
    try:
        run(
            [
                "python3",
                "tools/rc1_quality_gate.py",
                "--report",
                str(report),
            ]
        )
    finally:
        report.unlink(missing_ok=True)

    if shutil.which("dart"):
        run(["dart", "format", str(BUILD_INFO)])

    if shutil.which("flutter"):
        run(["flutter", "pub", "get"])
        run(
            [
                "flutter",
                "analyze",
                "--no-fatal-warnings",
                "--no-fatal-infos",
            ]
        )
        run(["flutter", "test"])
    else:
        print(
            "ℹ Flutter Codespaces içinde yok; analiz ve test "
            "GitHub Actions'ta çalışacak."
        )

    if sha256(QUESTIONS) != question_hash:
        raise InstallError("assets/questions.json değişti.")


def commit_and_push() -> None:
    allowed = {str(p) for p in TARGETS}
    run(["git", "add", "--", *sorted(allowed)])

    staged = set(
        run(["git", "diff", "--cached", "--name-only"]).stdout.splitlines()
    )
    if staged != allowed:
        run(["git", "reset"], check=False)
        raise InstallError(
            "Commit dosyaları doğrulanamadı. Stage: "
            + ", ".join(sorted(staged))
        )

    run(
        [
            "git",
            "-c",
            "commit.gpgsign=false",
            "commit",
            "-m",
            COMMIT_MESSAGE,
        ]
    )
    run(["git", "push", "origin", "main"], clean_auth=True)


def main() -> int:
    print("Bilgi Rotası — Kalıcı İmza Güncelleme Testi")
    print("=" * 60)
    print(f"{OLD_VERSION} → {NEW_VERSION}")
    print()

    verify_environment()
    question_hash = sha256(QUESTIONS)

    with tempfile.TemporaryDirectory(
        prefix="bilgi_rotasi_update_test_"
    ) as tmp:
        backup_dir = Path(tmp)
        backups = {}
        for target in TARGETS:
            backup = backup_dir / target.name
            shutil.copy2(target, backup)
            backups[target] = backup

        try:
            update_files()
            print("✓ Sürüm 1.46.1+61 yapıldı.")
            print("✓ Paket adı ve kalıcı imza korunuyor.")
            print("✓ Soru dosyasına dokunulmadı.")
            run_checks(question_hash)
            print("✓ Kalite kontrolleri geçti.")
            commit_and_push()
            print("✓ Commit ve push tamamlandı.")
        except Exception:
            run(
                ["git", "reset", "--", *[str(p) for p in TARGETS]],
                check=False,
            )
            for target, backup in backups.items():
                shutil.copy2(backup, target)
            raise

    print()
    print("KURULUM BAŞARILI")
    print("=" * 60)
    print(f"Artifact: {NEW_ARTIFACT}")
    print(f"APK: {NEW_APK}")
    print(
        "Actions yeşil olunca APK'yı mevcut uygulamayı "
        "kaldırmadan kurun."
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except InstallError as error:
        print()
        print("KURULUM DURDURULDU")
        print("=" * 60)
        print(error)
        raise SystemExit(1)
