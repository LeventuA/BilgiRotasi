# Bilgi Rotası V5 — 1.000 Soru

Bu paket, **q57121–q58120** aralığında 1.000 soru içerir.

- 2020–2026 odaklı soru: **700**
- Zamansız soru: **300**
- Canlı `assets/questions.json` ile ID, birebir metin ve güçlü yakın tekrar kontrolü kurulum sırasında yeniden yapılır.
- Çakışma varsa kurucu varsayılan olarak ana dosyayı değiştirmez.
- Sorular model tarafından yazılmış/seçilmiş ve otomatik denetimlerden geçirilmiştir; 1.000 maddenin tamamı bağımsız bir insan editör tarafından kaynak kaynak doğrulanmış değildir.

## Kurulum

```bash
unzip -o BilgiRotasi_V5_1000_Guncel_ve_Zamansiz_Sorular_FINAL.zip
python3 BilgiRotasi_V5_1000/install_v5_1000.py --repo-root . --check
python3 BilgiRotasi_V5_1000/install_v5_1000.py --repo-root . --apply
```

Çakışma çıkarsa temiz soruları eklemek için:

```bash
python3 BilgiRotasi_V5_1000/install_v5_1000.py --repo-root . --apply --skip-conflicts
```

Ardından yalnızca soru dosyasını commit edin:

```bash
python3 -m json.tool assets/questions.json > /dev/null
git diff --stat
git add assets/questions.json
git commit -m "V5: güncel ve zamansız kaliteli sorular"
git push
```

`git add .` kullanmayın.
