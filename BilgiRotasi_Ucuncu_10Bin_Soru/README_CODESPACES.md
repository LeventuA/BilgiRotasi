# Bilgi Rotası — Üçüncü 10.000 Soru

Bu ZIP `q23121-q33120` aralığında 10 ayrı 1.000 soruluk paket içerir.

## Codespaces kurulumu

```bash
unzip -o BilgiRotasi_Ucuncu_10Bin_Soru_FINAL.zip
python3 BilgiRotasi_Ucuncu_10Bin_Soru/install_questions.py --repo-root . --check
```

Kontrol sonrası:

```bash
python3 BilgiRotasi_Ucuncu_10Bin_Soru/install_questions.py --repo-root . --apply --skip-conflicts
```

Son kontrol ve commit:

```bash
python3 -m json.tool assets/questions.json > /dev/null
git diff --stat
git add assets/questions.json
git commit -m "Üçüncü 10 bin soru: q23121-q33120"
git push
```

`git add .` kullanmayın; ZIP, kurulum klasörü ve `.question_backups` repoya eklenmemelidir.
