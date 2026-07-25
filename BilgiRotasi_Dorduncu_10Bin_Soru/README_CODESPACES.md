# Bilgi Rotası — Dördüncü 10.000 Soru

Bu ZIP `q33121-q43120` aralığında 10 ayrı 1.000 soruluk paket içerir. Tam `questions.json` dosyası içermez.

## Codespaces kurulumu

```bash
unzip -o BilgiRotasi_Dorduncu_10Bin_Soru_FINAL.zip
python3 BilgiRotasi_Dorduncu_10Bin_Soru/install_questions.py --repo-root . --check
```

Kontrol sonrası:

```bash
python3 BilgiRotasi_Dorduncu_10Bin_Soru/install_questions.py --repo-root . --apply --skip-conflicts
```

Commit:

```bash
python3 -m json.tool assets/questions.json > /dev/null
git diff --stat
git add assets/questions.json
git commit -m "Dördüncü 10 bin soru: q33121-q43120"
git push
```

`git add .` kullanmayın.
