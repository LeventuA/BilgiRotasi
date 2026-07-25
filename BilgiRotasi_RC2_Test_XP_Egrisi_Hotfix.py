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
    ROOT / "lib/xp_progression.dart",
    ROOT / "test/rc1_quality_gate_test.dart",
]
COMMIT_MESSAGE = "RC2 test ve XP egri hotfix"

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
        [str(p.relative_to(ROOT)) for p in TARGETS],
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

    backups = {p: p.read_bytes() for p in TARGETS}

    try:
        xp_path, test_path = TARGETS
        xp = xp_path.read_text(encoding="utf-8")
        old = """  static int requiredForLevel(int level) {
    final safeLevel = max(1, level);
    if (safeLevel >= 100) return 0;
    final linear = 110 * safeLevel;
    final curve = 12 * safeLevel * safeLevel;
    return 40 + linear + curve;
  }"""
        new = """  static int requiredForLevel(int level) {
    final safeLevel = max(1, level);
    final linear = 110 * safeLevel;
    final curve = 12 * safeLevel * safeLevel;
    return 40 + linear + curve;
  }"""
        if old not in xp:
            raise RuntimeError("XP eğrisi bölümü beklenen biçimde bulunamadı.")
        xp_path.write_text(xp.replace(old, new, 1), encoding="utf-8")

        test = test_path.read_text(encoding="utf-8")
        replacements = {
            "expect(AppBuildInfo.versionName, '1.48.4');":
                "expect(AppBuildInfo.versionName, '1.48.5');",
            "expect(AppBuildInfo.buildNumber, 68);":
                "expect(AppBuildInfo.buildNumber, 69);",
            "expect(AppBuildInfo.version, '1.48.4+68');":
                "expect(AppBuildInfo.version, '1.48.5+69');",
            "'Sürüm 1.48.4+68 • RC2',":
                "'Sürüm 1.48.5+69 • RC2',",
        }
        for old_text, new_text in replacements.items():
            if old_text not in test:
                raise RuntimeError(f"Test sürüm satırı bulunamadı: {old_text}")
            test = test.replace(old_text, new_text, 1)
        test_path.write_text(test, encoding="utf-8")

        if hashlib.sha256(QUESTION_FILE.read_bytes()).hexdigest() != before_hash:
            raise RuntimeError("assets/questions.json değişti; işlem durduruldu.")

        if shutil.which("dart"):
            run(["dart", "format"] + [str(p.relative_to(ROOT)) for p in TARGETS])

        if shutil.which("flutter"):
            run(["flutter", "analyze"])
            run(["flutter", "test"])
        else:
            print("Flutter bulunamadı; analyze/test GitHub Actions'a bırakıldı.")

        intended = [str(p.relative_to(ROOT)) for p in TARGETS]
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

        print("\n✅ RC2 test sürüm beklentileri 1.48.5+69 yapıldı.")
        print("✅ XP gereksinimi 100. seviyeye kadar sürekli artacak şekilde düzeltildi.")
        print("✅ Sorular dosyası korunarak doğrulandı.")
    except Exception:
        for path, data in backups.items():
            path.write_bytes(data)
        subprocess.run(
            ["git", "reset", "--"] +
            [str(p.relative_to(ROOT)) for p in TARGETS],
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
