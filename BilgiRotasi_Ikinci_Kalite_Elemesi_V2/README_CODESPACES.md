# Bilgi Rotası — İkinci Kalite Elemesi V2

Bu sürümde **sabit kategori kotaları kaldırılmıştır**.

Önceki kontrolde Coğrafya, Eğlence, Tarih ve Sporun tam 90; Sanat ve
Edebiyatın tam 110 çıkması, iyi soruların yalnızca kota dolduğu için
elenebildiğini gösterdi. V2 yalnızca:

- soru kalitesi,
- aynı bilginin tekrarı,
- aynı konuya yığılma,
- seri üretim soru aileleri,
- seçenek ve açıklama kalitesi

üzerinden karar verir.

## Kurulum

```bash
git pull
unzip -o BilgiRotasi_Ikinci_Kalite_Elemesi_V2_FINAL.zip
```

## Önce yalnızca kontrol

```bash
python3 BilgiRotasi_Ikinci_Kalite_Elemesi_V2/second_quality_review_v2.py \
  --repo-root . \
  --check
```

Bu komut `assets/questions.json` dosyasını değiştirmez.

## Sonuç onaylandıktan sonra uygulama

```bash
python3 BilgiRotasi_Ikinci_Kalite_Elemesi_V2/second_quality_review_v2.py \
  --repo-root . \
  --apply
```

Sonrasında:

```bash
python3 -m json.tool assets/questions.json > /dev/null
git diff --stat
git add assets/questions.json
git commit -m "Kalan soruları kota kullanmadan ikinci kalite elemesinden geçir"
git push
```

`git add .` kullanmayın.
