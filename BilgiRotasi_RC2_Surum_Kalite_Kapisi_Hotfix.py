#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import os
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
VERSION = "1.48.5+69"
QUESTION_FILE = ROOT / "assets/questions.json"
TARGETS = [
    ROOT / "tools/rc1_quality_gate.py",
    ROOT / "reports/RC1_AUTOMATED_REPORT.md",
]
COMMIT_MESSAGE = "RC2 kalite kapisi surum hotfix"

def run(cmd, *, env=None):
    print("$", " ".join(cmd))
    subprocess.run(cmd, cwd=ROOT, check=True, text=True, env=env)

def main():
    os.chdir(ROOT)

    before_hash = hashlib.sha256(QUESTION_FILE.read_bytes()).hexdigest()

    run(["git", "fetch", "origin", "main"])
    run(["git", "pull", "--ff-only", "origin", "main"])

    local = subprocess.run(
        ["git", "status", "--porcelain", "--"] +
        [str(p.relative_to(ROOT)) for p in TARGETS if p.exists()],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=True,
    ).stdout.strip()

    if local:
        raise RuntimeError(
            "Hedef dosyalarda yerel değişiklik var. Önce commit et veya geri al:\n"
            + local
        )

    backups = {p: p.read_bytes() for p in TARGETS if p.exists()}

    try:
        gate = TARGETS[0].read_text(encoding="utf-8")
        old = 'EXPECTED_VERSION = "1.48.4+68"'
        new = f'EXPECTED_VERSION = "{VERSION}"'

        if old not in gate:
            if new in gate:
                print("Kalite kapısı sürümü zaten güncel.")
            else:
                raise RuntimeError("Kalite kapısındaki beklenen sürüm satırı bulunamadı.")
        else:
            gate = gate.replace(old, new, 1)
            TARGETS[0].write_text(gate, encoding="utf-8")

        if shutil.which("python3"):
            run([
                "python3",
                "tools/rc1_quality_gate.py",
                "--report",
                "reports/RC1_AUTOMATED_REPORT.md",
            ])

        if hashlib.sha256(QUESTION_FILE.read_bytes()).hexdigest() != before_hash:
            raise RuntimeError("assets/questions.json değişti; işlem durduruldu.")

        if shutil.which("flutter"):
            run(["flutter", "analyze"])
            run(["flutter", "test"])
        else:
            print("Flutter bulunamadı; analyze/test GitHub Actions'a bırakıldı.")

        intended = [str(p.relative_to(ROOT)) for p in TARGETS if p.exists()]
        run(["git", "add", "--"] + intended)

        staged = subprocess.run(
            ["git", "diff", "--cached", "--name-only"],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=True,
        ).stdout.splitlines()

        unintended = sorted(set(staged) - set(intended))
        if unintended:
            raise RuntimeError(
                "İstenmeyen dosyalar stage edildi: " + ", ".join(unintended)
            )

        run(["git", "commit", "-m", COMMIT_MESSAGE])

        clean_env = os.environ.copy()
        clean_env.pop("GH_TOKEN", None)
        clean_env.pop("GITHUB_TOKEN", None)
        run(["git", "push", "origin", "main"], env=clean_env)

        print("\n✅ RC2 kalite kapısı 1.48.5+69 sürümüne güncellendi.")
        print("✅ Otomatik kalite raporu yeniden üretildi.")
        print("✅ Sorular dosyası korunarak doğrulandı.")
    except Exception:
        for path, data in backups.items():
            path.write_bytes(data)
        subprocess.run(
            ["git", "reset", "--"] +
            [str(p.relative_to(ROOT)) for p in TARGETS if p.exists()],
            cwd=ROOT,
            check=False,
        )
        raise

if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"\n❌ Hotfix başarısız: {exc}", file=sys.stderr)
        sys.exit(1)
