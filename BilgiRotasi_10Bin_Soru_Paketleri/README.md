# Bilgi Rotası — 10.000 Yeni Soru Paketi

Durum: **10 / 10 paket tamamlandı.**

Bu ZIP, `q3121-q13120` arasında toplam 10.000 yeni soru içerir. Repodaki
mevcut `assets/questions.json` dosyasının tam kopyasını taşımaz ve `q001-q3120`
kayıtlarını değiştirmez.

## Codespaces kurulumu

ZIP dosyasını repo köküne yükleyin ve terminalde çalıştırın:

```bash
unzip -o BilgiRotasi_10Bin_Soru_Paketleri_FINAL.zip
python3 BilgiRotasi_10Bin_Soru_Paketleri/install_questions.py --repo-root . --check
```

Kontrol raporunu gördükten sonra:

```bash
python3 BilgiRotasi_10Bin_Soru_Paketleri/install_questions.py --repo-root . --apply --skip-conflicts
```

Sonucu kontrol edip yalnızca soru dosyasını commit edin:

```bash
python3 -m json.tool assets/questions.json > /dev/null
git diff --stat
git add assets/questions.json
git commit -m "10 bin yeni soru: q3121-q13120"
git push
```

## Güvenlik

- Her paket tam 1.000 sorudur.
- Kurulumdan önce `.question_backups/` altında yedek alınır.
- ID çakışması ve birebir soru tekrarı kontrol edilir.
- Çakışan kayıtlar `--skip-conflicts` ile atlanabilir; mevcut sorular silinmez.
- Dört seçenek, `answerIndex`, kategori, zorluk ve açıklama alanları doğrulanır.
- Her paket için kaynak kaydı ve QA raporu ZIP içinde bulunur.
- On paketin tamamı tek işlemde sahte repo üzerinde başarıyla kurulmuştur.

## Doğrulama kapsamı

Sorular kaynaklanmış yapılandırılmış bilgi kayıtlarından türetilmiş ve otomatik
kalite kontrollerinden geçirilmiştir. Bu, 10.000 sorunun her birinin bağımsız
bir insan editör tarafından satır satır doğrulandığı anlamına gelmez; kaynak ve
kontrol dosyaları daha sonra yapılacak editoryal incelemeyi izlenebilir kılar.
