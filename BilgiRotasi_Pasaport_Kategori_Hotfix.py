#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import os
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
TARGET = ROOT / "lib/career_collection_update.dart"
QUESTION_FILE = ROOT / "assets/questions.json"
COMMIT_MESSAGE = "Bilgi Pasaportu kategori basligi hotfix"

def run(cmd, *, env=None):
    print("$", " ".join(cmd))
    subprocess.run(cmd, cwd=ROOT, check=True, text=True, env=env)

def main():
    os.chdir(ROOT)

    if not TARGET.exists():
        raise RuntimeError("lib/career_collection_update.dart bulunamadı.")

    question_hash = hashlib.sha256(QUESTION_FILE.read_bytes()).hexdigest()

    run(["git", "fetch", "origin", "main"])
    run(["git", "pull", "--ff-only", "origin", "main"])

    local = subprocess.run(
        ["git", "status", "--porcelain", "--", str(TARGET.relative_to(ROOT))],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=True,
    ).stdout.strip()
    if local:
        raise RuntimeError(
            "Hotfix hedefinde yerel değişiklik var. Önce commit et veya geri al:\n"
            + local
        )

    backup = TARGET.read_bytes()

    try:
        text = TARGET.read_text(encoding="utf-8")

        anchor = """const List<PassportRequirement> passportRequirements =
    <PassportRequirement>["""
        names = """const List<String> _passportCategoryNames = <String>[
  'Tarih',
  'Coğrafya',
  'Bilim',
  'Sanat',
  'Spor',
  'Eğlence',
];

const List<PassportRequirement> passportRequirements =
    <PassportRequirement>["""

        if anchor not in text:
            raise RuntimeError("Pasaport şartları bölümü bulunamadı.")
        text = text.replace(anchor, names, 1)

        if "category.title" not in text:
            raise RuntimeError("Hatalı category.title kullanımı bulunamadı.")
        text = text.replace(
            "category.title",
            "_passportCategoryNames[categoryIndex]",
            1,
        )

        # Bu dosyada bizim eklediğimiz yeni deprecated çağrıyı da temizle.
        text = text.replace(
            "rarity.color.withOpacity(0.18)",
            "rarity.color.withValues(alpha: 0.18)",
        )

        TARGET.write_text(text, encoding="utf-8")

        if hashlib.sha256(QUESTION_FILE.read_bytes()).hexdigest() != question_hash:
            raise RuntimeError("assets/questions.json değişti; işlem durduruldu.")

        if shutil.which("dart"):
            run(["dart", "format", str(TARGET.relative_to(ROOT))])

        if shutil.which("flutter"):
            result = subprocess.run(
                ["flutter", "analyze"],
                cwd=ROOT,
                text=True,
            )
            if result.returncode != 0:
                raise RuntimeError("flutter analyze hâlâ hata veriyor.")
            run(["flutter", "test"])
        else:
            print("Flutter bulunamadı; testler GitHub Actions'a bırakıldı.")

        run(["git", "add", "--", str(TARGET.relative_to(ROOT))])
        run(["git", "commit", "-m", COMMIT_MESSAGE])

        clean_env = os.environ.copy()
        clean_env.pop("GH_TOKEN", None)
        clean_env.pop("GITHUB_TOKEN", None)
        run(["git", "push", "origin", "main"], env=clean_env)

        print("\n✅ Bilgi Pasaportu kategori başlığı hatası düzeltildi.")
        print("✅ Sürüm değişmedi: 1.48.5+69")
        print("✅ Sorular dosyası korunarak doğrulandı.")
    except Exception:
        TARGET.write_bytes(backup)
        subprocess.run(
            ["git", "reset", "--", str(TARGET.relative_to(ROOT))],
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
