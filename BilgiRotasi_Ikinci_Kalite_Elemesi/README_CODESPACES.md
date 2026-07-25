# Bilgi Rotası — İkinci Kalite Elemesi

Bu paket yeni soru üretmez. İlk elemeden kalan bankayı yeniden inceler.

## ZIP'i aç

```bash
git pull
unzip -o BilgiRotasi_Ikinci_Kalite_Elemesi_FINAL.zip
```

## Önce yalnızca kontrol et

```bash
python3 BilgiRotasi_Ikinci_Kalite_Elemesi/second_quality_review.py \
  --repo-root . \
  --check
```

Bu komut `assets/questions.json` dosyasını değiştirmez. Terminalde şu sayıları
gösterir:

- Kesin kalacak
- Yeniden yazılacak
- Doğrudan elenecek
- Kalanların kategori dağılımı

Ayrıntılı kayıtlar `question_second_review_output` klasörüne yazılır.

## Sonuç onaylandıktan sonra uygulama

```bash
python3 BilgiRotasi_Ikinci_Kalite_Elemesi/second_quality_review.py \
  --repo-root . \
  --apply
```

Uygulamadan önce tam yedek alınır.

```bash
python3 -m json.tool assets/questions.json > /dev/null
git diff --stat
git add assets/questions.json
git commit -m "Kalan soruları ikinci kalite elemesinden geçir"
git push
```

`git add .` kullanmayın. Rapor ve yedek klasörleri repoya eklenmemelidir.

ID'lerin aralıklı kalması normaldir.
