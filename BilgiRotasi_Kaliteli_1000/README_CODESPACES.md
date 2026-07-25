# Bilgi Rotası — 1.000 Özgün Kaliteli Soru

Bu paket, önceki yapay ve seri üretim soru formatlarından uzak durularak
hazırlanan 1.000 trivia sorusunu içerir.

## İçerik

- Toplam: **1.000 soru**
- ID: **q53121-q54120**
- 10 ayrı paket × 100 soru
- Tek birleşik JSON
- Her soruda dört benzersiz seçenek
- Her soruda kısa bilgi açıklaması
- Global birebir tekrar: 0
- Global soru-cevap tekrarı: 0
- Güçlü yakın tekrar: 0

### Kategori dağılımı

- Coğrafya: 170
- Eğlence: 170
- Tarih: 170
- Sanat & Edebiyat: 170
- Bilim & Doğa: 160
- Spor: 160

### Zorluk dağılımı

- Kolay: 678
- Orta: 301
- Zor: 21

## Tek seferde kurulum

ZIP'i repo ana klasörüne yükleyin:

```bash
unzip -o BilgiRotasi_1000_Ozgun_Kaliteli_Soru_FINAL.zip
```

Mevcut soru bankasına karşı tekrar denetimi yapıp temizse doğrudan eklemek için:

```bash
python3 BilgiRotasi_Kaliteli_1000/install_quality_1000.py \
  --repo-root . \
  --apply
```

Kurucu çakışma bulursa ana dosyayı değiştirmez ve ayrıntılı rapor üretir.

Çakışanları otomatik atlayarak kalan temiz soruları aynı işlemde eklemek için:

```bash
python3 BilgiRotasi_Kaliteli_1000/install_quality_1000.py \
  --repo-root . \
  --apply \
  --skip-conflicts
```

## GitHub'a gönderme

```bash
python3 -m json.tool assets/questions.json > /dev/null
git diff --stat
git add assets/questions.json
git commit -m "1000 özgün kaliteli soru: q53121-q54120"
git push
```

`git add .` kullanmayın. Denetim raporları ve yedekler repoya eklenmemelidir.

## Denetim notu

Sorular otomatik JSON/şema/tekrar kurallarıyla kontrol edilmiş ve hazırlanırken
editoryal olarak gözden geçirilmiştir. Bu ifade, 1.000 bilginin bağımsız bir
insan araştırmacı tarafından kaynak kaynak elle doğrulandığı anlamına gelmez.
Güncel veya değişebilir bilgi yerine ağırlıklı olarak zamanla değişmeyen genel
kültür bilgileri kullanılmıştır.
