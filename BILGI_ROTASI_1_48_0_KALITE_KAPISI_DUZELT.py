#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import os
import shutil
import subprocess
import sys
from pathlib import Path


TARGETS = [
    Path("tools/rc1_quality_gate.py"),
    Path("test/rc1_quality_gate_test.dart"),
]

CURRENT_VERSION = "1.48.0+64"


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
        result = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            cwd=candidate,
            check=False,
            text=True,
            capture_output=True,
        )
        if result.returncode == 0:
            return Path(result.stdout.strip())

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


def target_status(repo: Path) -> str:
    return run(
        ["git", "status", "--porcelain", "--", *map(str, TARGETS)],
        cwd=repo,
    ).stdout.strip()


def verify_current_version(repo: Path) -> None:
    pubspec = (repo / "pubspec.yaml").read_text(encoding="utf-8")
    if f"version: {CURRENT_VERSION}" not in pubspec:
        raise InstallError(
            f"Mevcut sürüm {CURRENT_VERSION} değil. "
            "Bu düzeltme yalnızca 1.48.0+64 için hazırlanmıştır."
        )


def main() -> int:
    repo = locate_repo()
    question_path = repo / "assets/questions.json"
    question_hash_before = sha256(question_path)

    branch = run(
        ["git", "branch", "--show-current"],
        cwd=repo,
    ).stdout.strip()
    if branch != "main":
        raise InstallError(
            f"Kurulum main dalında çalışmalıdır. "
            f"Mevcut dal: {branch or '(yok)'}"
        )

    dirty = target_status(repo)
    if dirty:
        raise InstallError(
            "Hedef kalite dosyalarında yerel değişiklik var:\n"
            + dirty
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

    verify_current_version(repo)

    originals: dict[Path, bytes] = {}
    committed = False

    try:
        for relative in TARGETS:
            absolute = repo / relative
            if not absolute.exists():
                raise InstallError(
                    f"Gerekli dosya bulunamadı: {relative}"
                )
            originals[relative] = absolute.read_bytes()

        gate_path = repo / "tools/rc1_quality_gate.py"
        gate_text = gate_path.read_text(encoding="utf-8")
        gate_text = replace_once(
            gate_text,
            'EXPECTED_VERSION = "1.47.1+63"',
            'EXPECTED_VERSION = "1.48.0+64"',
            label="Python kalite kapısı sürümü",
        )
        gate_path.write_text(
            gate_text,
            encoding="utf-8",
            newline="\n",
        )

        test_path = repo / "test/rc1_quality_gate_test.dart"
        test_text = test_path.read_text(encoding="utf-8")
        replacements = [
            (
                "expect(AppBuildInfo.versionName, '1.47.1');",
                "expect(AppBuildInfo.versionName, '1.48.0');",
                "test sürüm adı",
            ),
            (
                "expect(AppBuildInfo.buildNumber, 63);",
                "expect(AppBuildInfo.buildNumber, 64);",
                "test yapı numarası",
            ),
            (
                "expect(AppBuildInfo.version, '1.47.1+63');",
                "expect(AppBuildInfo.version, '1.48.0+64');",
                "test tam sürümü",
            ),
            (
                "'Sürüm 1.47.1+63 • RC2',",
                "'Sürüm 1.48.0+64 • RC2',",
                "test sürüm etiketi",
            ),
        ]

        for old, new, label in replacements:
            test_text = replace_once(
                test_text,
                old,
                new,
                label=label,
            )

        test_path.write_text(
            test_text,
            encoding="utf-8",
            newline="\n",
        )

        if sha256(question_path) != question_hash_before:
            raise InstallError(
                "assets/questions.json beklenmedik biçimde değişti."
            )

        run(
            [sys.executable, "-m", "py_compile", str(gate_path)],
            cwd=repo,
        )

        run(
            [
                sys.executable,
                "tools/rc1_quality_gate.py",
                "--report",
                "reports/RC1_AUTOMATED_REPORT.md",
            ],
            cwd=repo,
            capture=False,
        )

        dart = shutil.which("dart")
        if dart:
            run(
                [dart, "format", "test/rc1_quality_gate_test.dart"],
                cwd=repo,
                capture=False,
            )
        else:
            print(
                "Bilgi: dart bulunamadı; test biçimini Actions kontrol edecek."
            )

        run(
            ["git", "diff", "--check", "--", *map(str, TARGETS)],
            cwd=repo,
        )

        run(
            ["git", "add", "--", *map(str, TARGETS)],
            cwd=repo,
        )

        staged = run(
            ["git", "diff", "--cached", "--name-only"],
            cwd=repo,
        ).stdout.splitlines()

        expected = sorted(str(path) for path in TARGETS)
        actual = sorted(
            line.strip()
            for line in staged
            if line.strip()
        )

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
                "1.48.0 kalite kapisi surumunu duzelt",
                "--",
                *map(str, TARGETS),
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
        print("DÜZELTME BAŞARILI")
        print("Kalite kapısı ve RC2 sürüm testi 1.48.0+64 olarak güncellendi.")
        print("Sürüm değiştirilmedi.")
        print("Commit GitHub'a gönderildi.")
        return 0

    except Exception:
        if committed:
            run(
                ["git", "reset", "--mixed", "HEAD~1"],
                cwd=repo,
                check=False,
            )

        for relative, content in originals.items():
            absolute = repo / relative
            absolute.parent.mkdir(parents=True, exist_ok=True)
            absolute.write_bytes(content)

        run(
            ["git", "restore", "--staged", "--", *map(str, TARGETS)],
            cwd=repo,
            check=False,
        )
        raise


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except InstallError as error:
        print()
        print("DÜZELTME DURDU")
        print(str(error))
        raise SystemExit(1)
    except Exception as error:
        print()
        print("DÜZELTME BAŞARISIZ")
        print(f"{type(error).__name__}: {error}")
        raise SystemExit(1)
