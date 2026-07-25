# Bilgi Rotası V3 — 1.000 Özgün Kaliteli Soru

Dört kişilik test sürecini beslemek için hazırlanmış üçüncü kaliteli pakettir.

## İçerik

- 1.000 soru, ID: q55121-q56120
- 10 × 100 ayrı JSON
- Coğrafya 170, Eğlence 170, Tarih 170, Sanat & Edebiyat 170, Bilim & Doğa 160, Spor 160
- Kolay 525, Orta 441, Zor 34
- Cevap konumları: her indeks tam 250
- Paket içi birebir ve güçlü yakın tekrar: 0
- V1 ve V2 aday havuzundaki 2.000 soruyla birebir/güçlü tekrar: 0
- Semantik denetim sonrası 92 soru yeniden yazıldı veya değiştirildi

## Tek seferde kurulum

```bash
unzip -o BilgiRotasi_V3_1000_Ozgun_Kaliteli_Soru_FINAL.zip
python3 BilgiRotasi_V3_1000/install_v3_quality_1000.py --repo-root . --check
python3 BilgiRotasi_V3_1000/install_v3_quality_1000.py --repo-root . --apply
```

Canlı bankada çakışma bulunursa:

```bash
python3 BilgiRotasi_V3_1000/install_v3_quality_1000.py --repo-root . --apply --skip-conflicts
```

## Commit

```bash
python3 -m json.tool assets/questions.json > /dev/null
git diff --stat
git add assets/questions.json
git commit -m "V3: kaliteli sorular q55121-q56120"
git push
```

`git add .` kullanmayın.

Sorular editoryal olarak hazırlanıp otomatik şema ve tekrar denetiminden geçirilmiştir. Referans eşlemesi başvurulabilecek kaynak gruplarını gösterir; 1.000 sorunun bağımsız bir insan hakem tarafından kaynak kaynak onaylandığı anlamına gelmez. Kurucu, gerçek güncel soru bankasına karşı son tekrar kontrolünü Codespaces içinde yapar.
