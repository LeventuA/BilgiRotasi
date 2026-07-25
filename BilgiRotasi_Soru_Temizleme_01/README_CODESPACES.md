# Bilgi Rotası — Ciddi Soru Elemesi

Bu paket mevcut `assets/questions.json` dosyasını temizler. Yeni soru eklemez.

## 1. ZIP'i aç

```bash
git pull
unzip -o BilgiRotasi_Soru_Temizleme_01_FINAL.zip
```

## 2. Önce yalnızca kontrol et

```bash
python3 BilgiRotasi_Soru_Temizleme_01/cleanup_questions.py \
  --repo-root . \
  --check
```

Bu komut ana soru dosyasını değiştirmez. Şunları gösterir:

- Kaç soru kalacak
- Kaç soru elenecek
- Kategori dağılımı
- Koruma ve eleme oranları

Ayrıca `question_audit_output` klasörüne şunları yazar:

- `audit_report_*.json`
- `kept_questions_*.json`
- `rejected_questions_*.json`
- `borderline_questions_*.json`

## 3. Sonucu uygula

```bash
python3 BilgiRotasi_Soru_Temizleme_01/cleanup_questions.py \
  --repo-root . \
  --apply
```

Uygulama öncesinde tam yedek otomatik oluşturulur:

```text
.question_backups/questions.json.<tarih>.before_quality_cleanup.bak
```

## 4. JSON ve değişiklik kontrolü

```bash
python3 -m json.tool assets/questions.json > /dev/null
git diff --stat
```

## 5. Yalnızca soru dosyasını gönder

```bash
git add assets/questions.json
git commit -m "Kalitesiz ve tekrarlı soruları ciddi şekilde ele"
git push
```

`git add .` kullanmayın. Yedek ve denetim raporları repoya eklenmemelidir.

## Not

ID'ler yeniden numaralandırılmaz. `q001`, `q025`, `q4100` gibi aralıklı
ID'lerin kalması uygulama açısından normaldir.
