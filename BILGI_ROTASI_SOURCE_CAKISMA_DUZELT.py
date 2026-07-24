#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import annotations

import os
import subprocess
from pathlib import Path

MAIN = Path("lib/main.dart")
ACCOUNT = Path("lib/account_cloud.dart")

OLD_IMPORT = "import 'package:audioplayers/audioplayers.dart';"
NEW_IMPORT = "import 'package:audioplayers/audioplayers.dart' hide Source;"
OLD_OPTIONS = "const GetOptions(source: Source.server)"
NEW_OPTIONS = "GetOptions(source: Source.server)"


def run(
    args: list[str],
    *,
    check: bool = True,
    timeout: int | None = None,
    env: dict[str, str] | None = None,
) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(
        args,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        timeout=timeout,
        env=env,
    )
    if result.stdout:
        print(result.stdout, end="")
    if check and result.returncode != 0:
        raise RuntimeError(
            f"Komut başarısız: {' '.join(args)}"
        )
    return result


def main() -> int:
    print(
        "Bilgi Rotası — Firestore Source çakışması düzeltmesi"
    )

    if (
        not Path(".git").exists()
        or not MAIN.exists()
        or not ACCOUNT.exists()
    ):
        print(
            "HATA: Dosya depo kökünde çalıştırılmalı."
        )
        return 1

    branch = run(
        ["git", "branch", "--show-current"]
    ).stdout.strip()
    if branch != "main":
        print(
            f"HATA: Beklenen dal main, mevcut dal: {branch}"
        )
        return 1

    changed = run(
        [
            "git",
            "status",
            "--porcelain",
            "--",
            str(MAIN),
            str(ACCOUNT),
        ]
    ).stdout.strip()

    if changed:
        print(
            "HATA: Hedef dosyalarda yerel değişiklik var:"
        )
        print(changed)
        return 1

    main_text = MAIN.read_text(encoding="utf-8")
    account_text = ACCOUNT.read_text(encoding="utf-8")

    import_count = main_text.count(OLD_IMPORT)
    options_count = account_text.count(OLD_OPTIONS)

    if import_count != 1:
        print(
            "HATA: Ses import eşleşmesi "
            f"{import_count}, beklenen 1."
        )
        return 1

    if options_count != 2:
        print(
            "HATA: GetOptions eşleşmesi "
            f"{options_count}, beklenen 2."
        )
        return 1

    main_text = main_text.replace(
        OLD_IMPORT,
        NEW_IMPORT,
        1,
    )
    account_text = account_text.replace(
        OLD_OPTIONS,
        NEW_OPTIONS,
    )

    if main_text.count(NEW_IMPORT) != 1:
        print(
            "HATA: Source gizleme doğrulanamadı."
        )
        return 1

    if (
        account_text.count(OLD_OPTIONS) != 0
        or account_text.count(NEW_OPTIONS) != 2
    ):
        print(
            "HATA: GetOptions düzeltmesi doğrulanamadı."
        )
        return 1

    MAIN.write_text(main_text, encoding="utf-8")
    ACCOUNT.write_text(
        account_text,
        encoding="utf-8",
    )

    run(
        [
            "git",
            "add",
            "--",
            str(MAIN),
            str(ACCOUNT),
        ]
    )

    staged = run(
        [
            "git",
            "diff",
            "--cached",
            "--name-only",
        ]
    ).stdout.splitlines()

    expected = {str(MAIN), str(ACCOUNT)}
    if set(staged) != expected:
        run(
            [
                "git",
                "restore",
                "--staged",
                "--",
                str(MAIN),
                str(ACCOUNT),
            ],
            check=False,
        )
        print(
            "HATA: Stage edilen dosyalar beklenmiyor:"
        )
        print("\n".join(staged))
        return 1

    run(
        [
            "git",
            "commit",
            "-m",
            "Firestore Source ad cakismasini duzelt",
        ]
    )

    env = os.environ.copy()
    env.pop("GH_TOKEN", None)
    env.pop("GITHUB_TOKEN", None)
    env["GIT_TERMINAL_PROMPT"] = "0"

    try:
        push = run(
            ["git", "push", "origin", "main"],
            check=False,
            timeout=120,
            env=env,
        )
    except subprocess.TimeoutExpired:
        print(
            "Düzeltme commit'i hazır; "
            "push zaman aşımına uğradı."
        )
        print(
            "Yeni terminalde çalıştır:"
        )
        print(
            "env -u GH_TOKEN -u GITHUB_TOKEN "
            "GIT_TERMINAL_PROMPT=0 "
            "git push origin main"
        )
        return 0

    if push.returncode != 0:
        print(
            "Düzeltme commit'i hazır; "
            "push tamamlanmadı."
        )
        print(
            "Yeni terminalde çalıştır:"
        )
        print(
            "env -u GH_TOKEN -u GITHUB_TOKEN "
            "GIT_TERMINAL_PROMPT=0 "
            "git push origin main"
        )
        return 0

    print("DÜZELTME BAŞARILI")
    print(
        "Source çakışması kaldırıldı "
        "ve GitHub'a gönderildi."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
