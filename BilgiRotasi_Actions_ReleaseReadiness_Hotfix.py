#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import os
import shutil
import subprocess
import tempfile
from pathlib import Path


TARGET = Path("lib/system_health.dart")
QUESTIONS = Path("assets/questions.json")
QUALITY = Path("tools/rc1_quality_gate.py")
BASE_VERSION = "1.48.3+67"

BROKEN_BLOCK = """              ReleaseReadinessCard(
                questionBank: widget.questionBank,
                report: data.report,
                errorCount: data.errors.length,
              ),
              const SizedBox(height: 12),
"""


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


def main() -> int:
    repo = locate_repo()
    target = repo / TARGET
    questions = repo / QUESTIONS
    quality = repo / QUALITY
    pubspec = repo / "pubspec.yaml"

    branch = run(
        ["git", "branch", "--show-current"],
        cwd=repo,
    ).stdout.strip()
    if branch != "main":
        raise InstallError(
            f"Kurulum main dalında çalışmalıdır. "
            f"Mevcut dal: {branch or '(yok)'}"
        )

    required = [target, questions, quality, pubspec]
    missing = [str(path) for path in required if not path.is_file()]
    if missing:
        raise InstallError(
            "Gerekli dosyalar bulunamadı:\n" + "\n".join(missing)
        )

    dirty = run(
        [
            "git",
            "status",
            "--porcelain",
            "--",
            str(TARGET),
            str(QUESTIONS),
        ],
        cwd=repo,
    ).stdout.strip()
    if dirty:
        raise InstallError(
            "Hotfix dosyalarında yerel değişiklik var:\n"
            + dirty
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

    pubspec_text = pubspec.read_text(encoding="utf-8")
    if f"version: {BASE_VERSION}" not in pubspec_text:
        raise InstallError(
            f"Bu hotfix {BASE_VERSION} sürümü için hazırlandı."
        )

    original = target.read_bytes()
    text = target.read_text(encoding="utf-8")
    count = text.count(BROKEN_BLOCK)

    if count == 0 and "ReleaseReadinessCard(" not in text:
        raise InstallError(
            "ReleaseReadinessCard çağrısı zaten kaldırılmış."
        )

    if count != 1:
        raise InstallError(
            "Kaldırılacak bozuk bölüm güvenli biçimde bulunamadı. "
            f"Eşleşme sayısı: {count}"
        )

    updated = text.replace(BROKEN_BLOCK, "", 1)

    if "ReleaseReadinessCard(" in updated:
        raise InstallError(
            "Dosyada başka ReleaseReadinessCard çağrısı kaldı."
        )

    question_hash_before = sha256(questions)
    backup_dir = Path(
        tempfile.mkdtemp(prefix="bilgi_rotasi_release_hotfix_")
    )
    backup = backup_dir / TARGET
    backup.parent.mkdir(parents=True, exist_ok=True)
    backup.write_bytes(original)

    committed = False

    try:
        target.write_text(
            updated,
            encoding="utf-8",
            newline="\n",
        )

        if sha256(questions) != question_hash_before:
            raise InstallError(
                "Güvenlik kontrolü: assets/questions.json değişti."
            )

        if shutil.which("dart"):
            run(
                ["dart", "format", str(TARGET)],
                cwd=repo,
                capture=False,
            )

        run(
            ["git", "diff", "--check", "--", str(TARGET)],
            cwd=repo,
        )

        report = repo / ".git" / "RC2_RELEASE_HOTFIX_REPORT.md"
        try:
            run(
                [
                    "python3",
                    str(QUALITY),
                    "--report",
                    ".git/RC2_RELEASE_HOTFIX_REPORT.md",
                ],
                cwd=repo,
                capture=False,
            )
        finally:
            report.unlink(missing_ok=True)

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

        if sha256(questions) != question_hash_before:
            raise InstallError(
                "Testlerden sonra soru bankası değişti."
            )

        run(
            ["git", "add", "--", str(TARGET)],
            cwd=repo,
        )

        staged = [
            line.strip()
            for line in run(
                ["git", "diff", "--cached", "--name-only"],
                cwd=repo,
            ).stdout.splitlines()
            if line.strip()
        ]

        if staged != [str(TARGET)]:
            raise InstallError(
                "Commit dosyaları beklenenle eşleşmedi.\n"
                f"Beklenen: {[str(TARGET)]}\n"
                f"Bulunan: {staged}"
            )

        run(
            [
                "git",
                "commit",
                "-m",
                "Sistem sagligi eksik kart cagrisini kaldir",
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
        print("✅ ACTIONS HOTFIX TAMAMLANDI")
        print("✅ Eksik ReleaseReadinessCard çağrısı kaldırıldı.")
        print("✅ Meydan Okuma 10/20/30 sistemi korunuyor.")
        print("✅ 6710 soruluk banka korunuyor.")
        print("✅ assets/questions.json dosyasına dokunulmadı.")
        print("✅ Sürüm değişmedi: 1.48.3+67 • RC2")
        print("✅ Değişiklik GitHub main dalına gönderildi.")
        return 0

    except Exception:
        if not committed:
            target.write_bytes(backup.read_bytes())
            run(
                ["git", "restore", "--staged", "--", str(TARGET)],
                cwd=repo,
                check=False,
            )
        raise
    finally:
        shutil.rmtree(backup_dir, ignore_errors=True)


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except InstallError as error:
        print()
        print("❌ HOTFIX DURDU")
        print(str(error))
        raise SystemExit(1)
    except Exception as error:
        print()
        print("❌ HOTFIX BAŞARISIZ")
        print(f"{type(error).__name__}: {error}")
        print(
            "Commit oluştuysa yalnızca şu komutu çalıştır: "
            "env -u GH_TOKEN -u GITHUB_TOKEN git push origin main"
        )
        raise SystemExit(1)
