# Bilgi Rotası — Beşinci 10.000 Kolay Soru

Bu ZIP `q43121-q53120` aralığında, tamamı kolay seviyede 10 ayrı 1.000 soruluk paket içerir.

## Codespaces kurulumu

```bash
git pull
unzip -o BilgiRotasi_Besinci_10Bin_Soru_FINAL.zip
python3 BilgiRotasi_Besinci_10Bin_Soru/install_questions.py --repo-root . --check
```

Kontrol sonrası:

```bash
python3 BilgiRotasi_Besinci_10Bin_Soru/install_questions.py --repo-root . --apply --skip-conflicts
```

Son kontrol ve commit:

```bash
python3 -m json.tool assets/questions.json > /dev/null
git diff --stat
git add assets/questions.json
git commit -m "Beşinci 10 bin kolay soru: q43121-q53120"
git push
```

`git add .` kullanmayın; ZIP, kurulum klasörü ve `.question_backups` repoya eklenmemelidir.
