# Bilgi Rotası V2 — 1.000 Özgün Kaliteli Soru

V1'in eğlenceli kısa-trivia çizgisini koruyan ikinci 1.000 soruluk pakettir.

## İçerik

- 1.000 soru
- ID: q54121-q55120
- 10 × 100 ayrı JSON
- Coğrafya: 170
- Eğlence: 170
- Tarih: 170
- Sanat & Edebiyat: 170
- Bilim & Doğa: 160
- Spor: 160
- Kolay: 552
- Orta: 416
- Zor: 32
- V2 içinde birebir tekrar: 0
- V2 içinde güçlü yakın tekrar: 0
- V1 ile birebir veya güçlü yakın tekrar: 0
- 1.000 kaynak-grubu doğrulama kaydı

## Tek seferde kurulum

ZIP'i repo ana klasörüne yükleyin ve açın:

```bash
unzip -o BilgiRotasi_V2_1000_Ozgun_Kaliteli_Soru_FINAL.zip
```

Önce yalnız kontrol:

```bash
python3 BilgiRotasi_V2_1000/install_v2_quality_1000.py \
  --repo-root . \
  --check
```

Kontrol temizse tek seferde ekleyin:

```bash
python3 BilgiRotasi_V2_1000/install_v2_quality_1000.py \
  --repo-root . \
  --apply
```

Çakışma bulunan birkaç soruyu atlayıp kalanları eklemek için:

```bash
python3 BilgiRotasi_V2_1000/install_v2_quality_1000.py \
  --repo-root . \
  --apply \
  --skip-conflicts
```

## Commit

```bash
python3 -m json.tool assets/questions.json > /dev/null
git diff --stat
git add assets/questions.json
git commit -m "V2: 1000 özgün kaliteli soru q54121-q55120"
git push
```

`git add .` kullanmayın. Yedekler ve kurulum raporları repoya gitmemelidir.

## Doğrulama sınırı

Sorular editoryal olarak hazırlanmış; JSON, şema, seçenek, kimlik ve tekrar kontrollerinden geçirilmiştir. `VERIFICATION_INDEX.csv` her soruyu tercih edilen kaynak grubuna bağlar. Bu kayıt, 1.000 sorunun bağımsız bir akademik hakem tarafından tek tek onaylandığı anlamına gelmez. Kurucu gerçek güncel soru bankasına karşı son tekrar kontrolünü Codespaces içinde yapar.
