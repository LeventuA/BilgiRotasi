# Soru Düzeltme — Ayrı Sohbet Devir Komutu

**Tarih:** 18 Ağustos 2026
**Kaynak:** canlı release `9e51728889e67efd60dc96c4ea9a2f8cd627c289`, `assets/questions.json` blob `915164406004eaa44b818953beb0c667880f5223`.

Aşağıdaki metin ayrı Bilgi Rotası sohbetine tek parça gönderilmek üzere hazırlanmıştır.

---

## KOPYALA / YAPIŞTIR KOMUTU

Bilgi Rotası projesinde yalnız **3 soru için kontrollü kalite düzeltmesi** yap. Eski sohbet kodunu güncel kabul etme; teknik kaynak canlı `ZMilaStudio/BilgiRotasi` GitHub deposudur.

İşe başlamadan önce sırasıyla canlı:
1. `docs/project-memory/BILGI_ROTASI_DURUM.md`
2. `docs/project-memory/KARARLAR.md`
3. `docs/project-memory/GOREV_HAVUZU.md`
4. `docs/project-memory/ACIK_SORULAR_VE_DOGRULAMALAR.md`
5. kanonik release branch/SHA
6. `pubspec.yaml`
7. açık PR/CI durumunu doğrula.

`main` güncel varsayılmayacak. `assets/questions.json` toplu veya kontrolsüz değiştirilMEYECEK. Yalnız aşağıdaki exact ID’leri hedefle:

### 1) q56250
- mevcut `categoryIndex`: 3
- mevcut soru: `“Prophet Song” için doğru konu veya çeviri bilgisi hangisidir?`
- mevcut seçenekler:
  1. `Kannadacadan Deepa Bhasthi tarafından çevrildi`
  2. `otoriterleşen bir İrlanda’yı anlatan distopya`
  3. `Fransızcadan Anna Moschovakis tarafından çevrildi`
  4. `Almancadan Michael Hofmann tarafından çevrildi`
- mevcut `answerIndex`: 1
- mevcut zorluk: `Orta`
- mevcut açıklama: `Kitabın ayırt edici ayrıntısı şudur: otoriterleşen bir İrlanda’yı anlatan distopya. Bu bilgi 2023 yılındaki gelişmeyle ilişkilidir.`

### 2) q56526
- mevcut `categoryIndex`: 3
- mevcut soru: `“Trust” için doğru konu veya çeviri bilgisi hangisidir?`
- mevcut seçenekler:
  1. `otoriterleşen bir İrlanda’yı anlatan distopya`
  2. `servet, finans ve anlatının güvenilirliği üzerine kurulu roman`
  3. `1980’ler Glasgow’unda geçen bir aile hikâyesi`
  4. `Bulgarcadan Angela Rodel tarafından çevrildi`
- mevcut `answerIndex`: 1
- mevcut zorluk: `Zor`
- mevcut açıklama: `Kitabın ayırt edici ayrıntısı şudur: servet, finans ve anlatının güvenilirliği üzerine kurulu roman. Bu bilgi 2023 yılındaki gelişmeyle ilişkilidir.`

### 3) q55862
- mevcut `categoryIndex`: 0
- mevcut soru: `Felemenkçe hangi ülkenin resmî dilidir?`
- mevcut seçenekler: `Macaristan`, `Hollanda`, `Danimarka`, `Finlandiya`
- mevcut `answerIndex`: 1
- mevcut zorluk: `Kolay`
- mevcut açıklama: `Felemenkçe, Hollanda’nın ve Belçika’nın resmî dillerinden biridir.`

Amaç:
- q56250 ve q56526’daki yapay `doğru konu veya çeviri bilgisi` şablonunu kaldır.
- Tek bir bilgi türünü ölçen, doğal ve tek doğru cevabı olan soru üret.
- Dört seçenek aynı semantik türde ve makul çeldiriciler olsun; konu bilgisi ile çevirmen/dil bilgisini aynı seçenek kümesinde karıştırma.
- Açıklama kısa, öğretici ve soru ile doğrudan ilgili olsun; `Bu bilgi 2023 yılındaki gelişmeyle ilişkilidir` gibi yapay dolgu kullanma.
- q55862’de mevcut açıklama zaten Felemenkçenin hem Hollanda hem Belçika’da resmî olduğunu söylüyor; buna rağmen soru tek ülke istiyor. Soruyu tek doğru cevap verecek biçimde kesinleştir. `Hollanda`yı tek resmî-dil ülkesi gibi genelleme.
- Her üç kayıt için soru metni, dört seçenek, doğru indeks, açıklama, kategori/categoryIndex ve zorluğu **birlikte** doğrula. Kategori indeksinin anlamını canlı koddan doğrula; tahmin etme.
- Gerekiyorsa güncel/otoritatif dış kaynakla olgusal doğrulama yap; kaynakları kaydet. Edebiyat eserleri için güvenilir yayıncı/ödül kurumu/kitap kaynağı tercih et.

Çalışma yöntemi:
1. Güncel release’ten ayrı branch aç.
2. Yalnız bu üç ID’nin kayıtlarına minimal patch uygula; başka soruyu değiştirme.
3. JSON yapısının geçerli olduğunu doğrula.
4. Her ID’nin tek kez bulunduğunu, dört seçenek taşıdığını, `answerIndex`in aralıkta ve doğru cevapla uyumlu olduğunu test et.
5. `QuestionQualityGuard` / `QuestionBank.load()` üzerinden bu üç sorunun playable kaldığını doğrula.
6. Soru bankası toplam sayısının beklenmedik biçimde değişmediğini doğrula.
7. İlgili focused testleri, soru kalite kapılarını ve gereken tam regresyonu çalıştır.
8. `git diff --check` ve exact diff incelemesi yap; diff yalnız hedef üç kayıt + gerekirse odaklı regresyon testi/proje hafızası olmalı.
9. Commit → push → Draft PR aç. Commit adını açıkça yaz.
10. Tam CI logu, artifact/gate varsa, final diff ve Git geçmişini birlikte incele.
11. Levent açıkça onaylamadan merge etme.
12. Sheet/geri bildirim satırlarını gerçek soru düzeltmesi release’e merge edilip doğrulanmadan kapatma.
13. İş sonunda `BILGI_ROTASI_DURUM.md`, `GOREV_HAVUZU.md`; gerekiyorsa `ACIK_SORULAR_VE_DOGRULAMALAR.md` güncelle. Yeni ürün kararı yoksa `KARARLAR.md` değiştirme.

Önemli: Bu görevde `git reset --hard`, toplu soru yeniden üretimi, başka soru temizliği veya `assets/questions.json` üzerinde geniş formatlama/reorder yapılmayacak.

---
