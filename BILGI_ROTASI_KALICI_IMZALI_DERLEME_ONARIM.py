#!/usr/bin/env python3
from __future__ import annotations

import subprocess
import sys
import tempfile
from pathlib import Path


SOURCE = Path("BILGI_ROTASI_KALICI_IMZALI_DERLEME_KURULUM.py")


def fail(message: str) -> None:
    print()
    print("ONARIM DURDURULDU")
    print("=" * 60)
    print(message)
    raise SystemExit(1)


def main() -> int:
    print("Bilgi Rotası — İmzalı Derleme Kurulum Onarımı")
    print("=" * 60)

    if not SOURCE.exists():
        fail(
            f"{SOURCE} bulunamadı. "
            "Dosyayı depo köküne yükleyip git pull çalıştırın."
        )

    text = SOURCE.read_text(encoding="utf-8")

    start_old = (
        '    signing_step = r' + '"' * 3
        + '      - name: Kalıcı Android imzasını hazırla\n'
    )
    start_new = (
        "    signing_step = r" + "'" * 3
        + "      - name: Kalıcı Android imzasını hazırla\n"
    )

    end_old = (
        '          PY\n\n' + '"' * 3 + '\n'
        '    if updated.count(release_anchor) != 1:'
    )
    end_new = (
        "          PY\n\n" + "'" * 3 + "\n"
        "    if updated.count(release_anchor) != 1:"
    )

    if text.count(start_old) != 1:
        fail(
            "Bozuk başlangıç bölümü beklenen biçimde bulunamadı. "
            "Yanlış veya farklı bir dosya kullanılıyor olabilir."
        )

    if text.count(end_old) != 1:
        fail(
            "Bozuk kapanış bölümü beklenen biçimde bulunamadı. "
            "Yanlış veya farklı bir dosya kullanılıyor olabilir."
        )

    fixed = text.replace(start_old, start_new, 1)
    fixed = fixed.replace(end_old, end_new, 1)

    with tempfile.TemporaryDirectory(
        prefix="bilgi_rotasi_installer_fix_"
    ) as temp_dir:
        fixed_path = Path(temp_dir) / SOURCE.name
        fixed_path.write_text(fixed, encoding="utf-8")

        try:
            compile(
                fixed,
                str(fixed_path),
                "exec",
            )
        except Exception as error:
            fail(f"Düzeltilmiş dosya doğrulanamadı: {error}")

        print("✓ Girinti ve metin sınırları düzeltildi.")
        print("✓ Python sözdizimi kontrolü geçti.")
        print("✓ Asıl kurulum başlatılıyor...")
        print()

        result = subprocess.run(
            [sys.executable, str(fixed_path)],
            cwd=Path.cwd(),
            check=False,
        )

        if result.returncode != 0:
            fail(
                "Asıl kurulum hata ile durdu. "
                f"Çıkış kodu: {result.returncode}"
            )

    print()
    print("ONARIM VE KURULUM BAŞARILI")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
