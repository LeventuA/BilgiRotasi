#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import os
import subprocess
from pathlib import Path


TARGET = Path(".github/workflows/android-apk.yml")
BASE_VERSION = "1.48.1+65"
AAB_NAME = "BilgiRotasi-1.48.1-65-signed.aab"
APK_NAME = "BilgiRotasi-1.48.1-65-signed.apk"


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
    candidates = [Path.cwd(), Path("/workspaces/BilgiRotasi")]
    for candidate in candidates:
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
            f"Bulunan eşleşme: {count}"
        )
    return text.replace(old, new, 1)


def main() -> int:
    repo = locate_repo()
    workflow = repo / TARGET
    questions = repo / "assets/questions.json"
    question_hash_before = sha256(questions)

    branch = run(
        ["git", "branch", "--show-current"],
        cwd=repo,
    ).stdout.strip()
    if branch != "main":
        raise InstallError(
            f"Kurulum main dalında çalışmalıdır. "
            f"Mevcut dal: {branch or '(yok)'}"
        )

    dirty = run(
        ["git", "status", "--porcelain", "--", str(TARGET)],
        cwd=repo,
    ).stdout.strip()
    if dirty:
        raise InstallError(
            "Workflow dosyasında yerel değişiklik var:\n" + dirty
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

    if len(divergence) == 2:
        ahead, behind = map(int, divergence)
        if behind > 0:
            raise InstallError(
                "Yerel dal GitHub'ın gerisinde. "
                "Önce git pull --ff-only çalıştır."
            )
        if ahead > 0:
            raise InstallError(
                "GitHub'a gönderilmemiş yerel commit var."
            )

    pubspec = (repo / "pubspec.yaml").read_text(encoding="utf-8")
    if f"version: {BASE_VERSION}" not in pubspec:
        raise InstallError(
            f"Beklenen uygulama sürümü bulunamadı: {BASE_VERSION}"
        )

    if not workflow.exists():
        raise InstallError(f"Workflow bulunamadı: {TARGET}")

    original = workflow.read_bytes()
    committed = False

    try:
        text = workflow.read_text(encoding="utf-8")

        text = replace_once(
            text,
            "name: RC2 kalite kapısı ve APK",
            "name: RC2 kalite kapısı, APK ve AAB",
            label="workflow başlığı",
        )
        text = replace_once(
            text,
            "    name: Kalite + APK",
            "    name: Kalite + APK + AAB",
            label="job başlığı",
        )

        apk_build = """      - name: Release APK oluştur
        working-directory: .flutter_build
        run: flutter build apk --release
"""
        apk_and_aab_build = """      - name: Release APK oluştur
        working-directory: .flutter_build
        run: flutter build apk --release

      - name: Google Play AAB oluştur
        working-directory: .flutter_build
        run: flutter build appbundle --release
"""
        text = replace_once(
            text,
            apk_build,
            apk_and_aab_build,
            label="AAB derleme adımı",
        )

        source_block = """          SOURCE_APK=".flutter_build/build/app/outputs/flutter-apk/app-release.apk"
          APK="dist/BilgiRotasi-1.48.1-65-signed.apk"
          test -f "$SOURCE_APK"
          cp "$SOURCE_APK" "$APK"

          sha256sum "$APK" | tee reports/RC1_APK_SHA256.txt
"""
        source_with_aab = """          SOURCE_APK=".flutter_build/build/app/outputs/flutter-apk/app-release.apk"
          SOURCE_AAB=".flutter_build/build/app/outputs/bundle/release/app-release.aab"
          APK="dist/BilgiRotasi-1.48.1-65-signed.apk"
          AAB="dist/BilgiRotasi-1.48.1-65-signed.aab"

          test -f "$SOURCE_APK"
          test -f "$SOURCE_AAB"

          cp "$SOURCE_APK" "$APK"
          cp "$SOURCE_AAB" "$AAB"

          sha256sum "$APK" | tee reports/RC1_APK_SHA256.txt
          sha256sum "$AAB" | tee reports/RC1_AAB_SHA256.txt
"""
        text = replace_once(
            text,
            source_block,
            source_with_aab,
            label="APK ve AAB dosya hazırlığı",
        )

        apk_verify_end = """          if [ "$ACTUAL_SHA1" != "$EXPECTED_SHA1" ]; then
            echo "İmza SHA-1 uyuşmuyor."
            echo "Beklenen: $EXPECTED_SHA1"
            echo "Bulunan : $ACTUAL_SHA1"
            exit 1
          fi

          grep -Fq"""
        apk_and_aab_verify = """          if [ "$ACTUAL_SHA1" != "$EXPECTED_SHA1" ]; then
            echo "APK imza SHA-1 uyuşmuyor."
            echo "Beklenen: $EXPECTED_SHA1"
            echo "Bulunan : $ACTUAL_SHA1"
            exit 1
          fi

          jarsigner -verify "$AAB"

          AAB_CERT_OUTPUT="$(keytool -printcert -jarfile "$AAB")"
          printf '%s\\n' "$AAB_CERT_OUTPUT"

          ACTUAL_AAB_SHA1="$(
            printf '%s\\n' "$AAB_CERT_OUTPUT" \\
              | awk -F': ' '/SHA1:/ {print $2; exit}' \\
              | tr '[:lower:]' '[:upper:]' \\
              | tr -d '[:space:]:'
          )"

          if [ "$ACTUAL_AAB_SHA1" != "$EXPECTED_SHA1" ]; then
            echo "AAB imza SHA-1 uyuşmuyor."
            echo "Beklenen: $EXPECTED_SHA1"
            echo "Bulunan : $ACTUAL_AAB_SHA1"
            exit 1
          fi

          grep -Fq"""
        text = replace_once(
            text,
            apk_verify_end,
            apk_and_aab_verify,
            label="AAB imza doğrulaması",
        )

        build_info_anchor = """            echo "- İmza: Kalıcı upload anahtarı"
            echo "- Workflow: ${GITHUB_RUN_ID}"
"""
        build_info_new = """            echo "- İmza: Kalıcı upload anahtarı"
            echo "- APK: dist/BilgiRotasi-1.48.1-65-signed.apk"
            echo "- AAB: dist/BilgiRotasi-1.48.1-65-signed.aab"
            echo "- Workflow: ${GITHUB_RUN_ID}"
"""
        text = replace_once(
            text,
            build_info_anchor,
            build_info_new,
            label="yapı raporu AAB kaydı",
        )

        text = replace_once(
            text,
            "      - name: RC2 APK ve raporları yükle",
            "      - name: RC2 APK, AAB ve raporları yükle",
            label="artifact adımı başlığı",
        )

        upload_anchor = """          path: |
            dist/BilgiRotasi-1.48.1-65-signed.apk
            reports/RC1_AUTOMATED_REPORT.md
            reports/RC1_APK_SHA256.txt
"""
        upload_new = """          path: |
            dist/BilgiRotasi-1.48.1-65-signed.apk
            dist/BilgiRotasi-1.48.1-65-signed.aab
            reports/RC1_AUTOMATED_REPORT.md
            reports/RC1_APK_SHA256.txt
            reports/RC1_AAB_SHA256.txt
"""
        text = replace_once(
            text,
            upload_anchor,
            upload_new,
            label="artifact AAB yolları",
        )

        workflow.write_text(text, encoding="utf-8", newline="\n")

        if sha256(questions) != question_hash_before:
            raise InstallError(
                "assets/questions.json beklenmedik biçimde değişti."
            )

        run(
            ["git", "diff", "--check", "--", str(TARGET)],
            cwd=repo,
        )
        run(["git", "add", "--", str(TARGET)], cwd=repo)

        staged = run(
            ["git", "diff", "--cached", "--name-only"],
            cwd=repo,
        ).stdout.splitlines()
        actual = sorted(
            line.strip() for line in staged if line.strip()
        )
        expected = [str(TARGET)]
        if actual != expected:
            raise InstallError(
                "Commit dosyaları beklenenle eşleşmedi.\n"
                f"Beklenen: {expected}\nBulunan: {actual}"
            )

        run(
            [
                "git",
                "commit",
                "--only",
                "-m",
                "Imzali Google Play AAB ciktisini ekle",
                "--",
                str(TARGET),
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
        print("AAB KURULUMU BAŞARILI")
        print("Sürüm değiştirilmedi: 1.48.1+65 • RC2")
        print("Actions artık imzalı APK ve Google Play AAB üretecek.")
        print("Commit GitHub'a gönderildi.")
        return 0

    except Exception:
        if committed:
            run(
                ["git", "reset", "--mixed", "HEAD~1"],
                cwd=repo,
                check=False,
            )

        workflow.parent.mkdir(parents=True, exist_ok=True)
        workflow.write_bytes(original)

        run(
            ["git", "restore", "--staged", "--", str(TARGET)],
            cwd=repo,
            check=False,
        )
        raise


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except InstallError as error:
        print()
        print("AAB KURULUMU DURDU")
        print(str(error))
        raise SystemExit(1)
    except Exception as error:
        print()
        print("AAB KURULUMU BAŞARISIZ")
        print(f"{type(error).__name__}: {error}")
        raise SystemExit(1)
