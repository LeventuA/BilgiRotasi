# Bilgi Rotası — İkinci 10.000 Soru

Bu ZIP, `q13121-q23120` aralığında 10 ayrı 1.000 soruluk paket içerir.
Tam `questions.json` dosyası içermez. Codespaces içindeki güncel
`assets/questions.json` dosyasına yalnızca yeni soruları ekler.

## Kurulum

```bash
unzip -o BilgiRotasi_Ikinci_10Bin_Soru_FINAL.zip
python3 BilgiRotasi_Ikinci_10Bin_Soru/install_questions.py --repo-root . --check
```

Kontrol sonrası:

```bash
python3 BilgiRotasi_Ikinci_10Bin_Soru/install_questions.py \
  --repo-root . \
  --apply \
  --skip-conflicts
```

Son kontrol ve commit:

```bash
python3 -m json.tool assets/questions.json > /dev/null
git diff --stat
git add assets/questions.json
git commit -m "İkinci 10 bin soru: q13121-q23120"
git push
```

`git add .` kullanmayın. ZIP klasörü ile `.question_backups` repoya
eklenmemelidir.
