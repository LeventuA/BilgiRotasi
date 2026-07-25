# Bilgi Rotası — Türkiye Özel 1.000 Soru

Bu paket yalnızca Türkiye bağlantılı sorulardan oluşur.

## İçerik

- Coğrafya: 170
- Eğlence: 200
  - Türk dizileri
  - Türk filmleri
  - Türk müziği
- Tarih: 150
- Sanat & Edebiyat: 160
- Bilim & Doğa: 140
- Spor: 180

Ana paket: `q58121–q59120`

Ayrıca canlı soru bankasında çıkabilecek çakışmaları otomatik telafi etmek için,
her kategoriden 20 olmak üzere toplam 120 yedek soru bulunur. Kurucu, çakışan bir
sorunun yerine önce aynı kategoriden temiz bir yedek yerleştirmeyi dener ve
orijinal ID'yi korur.

## Kalite yaklaşımı

- Cevabı soru metninde açıkça bulunan maddeler elendi.
- Takım adıyla şehir buldurma gibi aşırı kolay kalıplar elendi.
- Aynı kalıbın isim değiştirilmiş seri kopyaları elendi.
- Her soruda dört farklı seçenek ve kısa açıklama bulunur.
- Ana 1.000 soruda paket içi birebir tekrar yoktur.
- Ana 1.000 soru, önceki V1–V5 paketlerindeki 5.000 aday soruyla birebir ve
  güçlü yakın tekrar kontrolünden geçirilmiştir.
- Kurulum sırasında gerçek `assets/questions.json` yeniden taranır.

Sorular model tarafından yazılıp otomatik ve editoryal kontrollerden geçirildi.
1.000 sorunun tamamı bağımsız bir insan editör tarafından kaynak kaynak
doğrulanmış değildir. Seçilmiş güncel ve önemli maddeler için
`sources/FACT_CHECK_NOTES.json` dosyasında örnek kaynak notları bulunur.

## Codespaces kurulumu

Önce yalnızca kontrol:

```bash
python3 BilgiRotasi_Turkiye_1000/install_turkiye_1000.py \
  --repo-root . \
  --check
```

Kontrol temizse kurulum:

```bash
python3 BilgiRotasi_Turkiye_1000/install_turkiye_1000.py \
  --repo-root . \
  --apply
```

Yedek havuzun da çözemediği çakışmalar kalırsa temiz soruları eklemek için:

```bash
python3 BilgiRotasi_Turkiye_1000/install_turkiye_1000.py \
  --repo-root . \
  --apply \
  --skip-conflicts
```

Kurucu şunları yapar:

1. JSON şemasını ve ID aralığını doğrular.
2. Canlı bankayla birebir ve güçlü yakın tekrar kontrolü yapar.
3. Çakışan sorular için 120 soruluk yedek havuzu dener.
4. Ana dosyanın tam yedeğini `.question_backups` içine alır.
5. Sonucu atomik biçimde yazar ve yeniden okur.
6. Ayrıntılı raporu `quality_turkiye_1000_install_output` içine kaydeder.

## Git işlemleri

```bash
python3 -m json.tool assets/questions.json > /dev/null
git diff --stat
git add assets/questions.json
git commit -m "Türkiye özel: 1000 kaliteli soru"
git push
```

`git add .` kullanmayın; paket ve rapor dosyaları commite eklenmesin.
