# Bilgi Rotası V4 — 2020–2026 odaklı 1.000 soru

Bu paket q56121–q57120 aralığında 1.000 aday soru içerir. Her soru 2020–2026 dönemindeki bir yapım, ödül, turnuva, bilimsel görev, olay veya konumla ilişkilidir.

## Kalite yaklaşımı

- Doğal Türkçe, dört farklı seçenek ve kısa bilgilendirici açıklama.
- Paket içinde birebir ve güçlü yakın tekrar denetimi.
- Yerelde V1–V3 paketlerindeki 3.000 aday soruyla karşılaştırma.
- Kurulum sırasında Codespaces içindeki gerçek `assets/questions.json` bankasıyla yeniden karşılaştırma.
- Otomatik tam yedek ve atomik JSON yazımı.

Sorular model tarafından yazılıp seçilmiş, otomatik kontrollerden ve birincil kaynak örneklemesinden geçirilmiştir. 1.000 maddenin tamamı bağımsız bir insan editör tarafından tek tek kaynak doğrulamasından geçirilmiş değildir.

## Kurulum

```bash
git pull
unzip -o "BilgiRotasi_V4_1000_2020_2026_Guncel_Sorular_FINAL.zip"
python3 BilgiRotasi_V4_1000/install_v4_recent_1000.py --repo-root . --check
```

Çakışma yoksa:

```bash
python3 BilgiRotasi_V4_1000/install_v4_recent_1000.py --repo-root . --apply
```

Çakışma varsa temiz soruları eklemek için:

```bash
python3 BilgiRotasi_V4_1000/install_v4_recent_1000.py --repo-root . --apply --skip-conflicts
```

Ardından yalnız soru bankasını commit edin:

```bash
python3 -m json.tool assets/questions.json > /dev/null
git diff --stat
git add assets/questions.json
git commit -m "V4: 2020-2026 odaklı güncel sorular"
git push
```

`git add .` kullanmayın.
