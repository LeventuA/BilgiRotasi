# Bilgi Rotası - Açık Sorular ve Canlı Doğrulamalar

> 29 Ağustos 2026 aktif kesimidir. Bu tarihten önceki dosyanın tam kayıtları Git geçmişi ve `docs/project-memory/archive/` altında korunur.

## Kelime Avı Başlangıç Limanı 8×8 — AÇIK / ANA AKTİF DOĞRULAMA

29 Ağustos 2026 kullanıcı kararıyla starter-content grid standardı 8×8'e geçti; eski 6×10 ürün geometrisi yeni çalışma için superseded edildi.

Canlı çalışma:
- Branch: `feat/kelime-avi-8x8-content-v1-20260829`
- Base/product source SHA: `0e9408ddda511259f588a338b3fcd8192bf92431`
- Geçici final-gate head: `7cff26f4a75e1c58beaea2c163f2e89e2c2af154`
- PR #156 eski 6×10 branch'inde **OPEN / DRAFT / merged=false**; 8×8 kabul/merge kaynağı değildir.
- Sürüm: `1.68.19+109`.

Statik olarak doğrulandı:
- 10 adet 8×8 grid.
- 80 toplam target+bonus.
- Her kelime exactly-one physical straight-line occurrence.
- Intended/opposite canonical yol eşleşmeleri.
- B5/B10 yatay+dikey+çapraz yön aileleri.
- B8 `HIZ`+`SKOR`, B9 `ROKET` ve `AY` yok, B10 `YOL`+`HAZİNE` ve `ROTA` yok.
- B5/B10 süre eşikleri korunuyor.
- Hard-coded widget yolları yeni canonical koordinatlarla statik uyumlu.

Tek yetkili Actions run:
- Run `33250841637`, job `99096135627`: **FAILURE**.
- Payload decode/apply + Java + Flutter kurulumu PASS.
- `dart format --output=none --set-exit-if-changed` üç Dart dosyasında format değişikliği istedi; step burada durdu.
- Analyze, Flutter testleri, APK build ve Android16 hiç çalışmadı.
- Bu nedenle ürün/runtime failure değil; teknik kabul de değildir.

Ek scope açığı:
- Payload içindeki QA-only `lib/word_hunt/word_hunt_8x8_qa_main.dart`, eski final stage mantığına ulaşılsaydı ürün commitine yanlışlıkla eklenebilirdi.
- Run o adıma ulaşmadığı için kirli QA dosyası ürün commitine girmedi.

**DOĞRULANACAK — KALANLAR:**
1. Gerçek Dart formatter PASS mi?
2. `dart analyze lib/word_hunt` PASS mi?
3. Focused Word Hunt + full Flutter suite PASS mi?
4. Korunan alan diff/scope temiz mi ve QA-only dosyalar ürün commitinden kesin çıkarıldı mı?
5. Android 16 B1/B5/B8/B10 ilk viewportta 64/64 hücreyi okunabilir gösteriyor mu?
6. B5 >60s soft-time hard fail olmadan çalışıyor mu?
7. B5 gerçek ANKARA ve ters BAŞKENT fiziksel swipe seçimleri PASS mi?
8. Crash/ANR/FATAL/am_crash taraması temiz mi?
9. Kullanıcı 8×8 gerçek Android görünümünü ve oynanışı kabul ediyor mu?
10. Yeni Actions koşusu için Levent açık izin verecek mi? İzin yokken yeniden çalıştırılmaz.
11. Teknik + kullanıcı kabulünden sonra yeni 8×8 PR stratejisi nedir? Ready/merge ayrıca açık onay gerektirir.

---

## Issue #109 / PR #147 MASTER ART production — KAPANDI

- Issue #109 `Photo 1.jpg` Başlangıç Limanı için tek bağlayıcı MASTER ART'tır.
- Levent gerçek production Android 16 MASTER ART görünümünü **GÖRSEL PASS** olarak kabul etti.
- Levent `MASTER ART raster + şeffaf hitbox` production mimarisini **MİMARİ PASS** olarak kabul etti.
- PR #147 expected-head ile PR #132 feature branch'ine squash merge edildi.
- Merge SHA `d118aa98c5551cb3b4418f61047f6a730406d963`.

**KAPANDI:** MASTER ART kaynağı, mimari kabul, node 9 progression, PR #147 merge kararı.

---

## PR #150 dynamic progression state — KAPANDI

PR #132 final incelemesinde MASTER ART içindeki demo state ile runtime progression state'in çelişebildiği tespit edildi.

Düzeltildi:
- gerçek `X / 30`,
- level 1–10 gerçek `0–3` yıldız state'i,
- gerçek locked/open state,
- node 9 open state'i.

İlk ikinci-yıldız-satırı denemesi FAIL kabul edildi ve kullanılmadı. MASTER ART'ın ölçülmüş star-slot pikselleri kullanılarak eski demo yıldız kalıntıları temizlendi.

Son doğrulanmış kod HEAD: `aebb384912d379fc87908e4e79b31aecdaba427b`.
- Android 16 production run `32969604847`: SUCCESS.
- Artifact `9607328059`.
- Digest `sha256:a1c01a5acb1c515b584e6cf1d24dea63ece57eaa9417f279f4b52f17e41ef776`.
- Node 9 callback PASS.
- Node 10 locked/no callback PASS.
- App process failure scan PASS.
- Screenshot visual QA PASS.

PR #150 PR #132 feature branch'ine merge edildi; merge SHA `d64fcd4ea63f173c6653ff33926b12a6c99ef37d`.

**KAPANDI:** raster demo progression state'in kullanıcıya yanlış görünmesi açığı.

---

## PR #149 proje hafızası checkpoint — KAPANDI

- PR #149 PR #132 feature branch'ine merge edildi.
- Merge SHA `adb4557a9a95dd624166b6b08a9e0ab27b1e4f80`.

---

## Kelime Avı production ana navigasyon entegrasyonu — AÇIK / AYRI KAPSAM

- Production `lib/main.dart` 8×8 starter-content dönüşümünde değiştirilmez.
- Başlangıç Limanı production route ekranının gerçek uygulama girişine bağlanması ayrı kapsamdır.

**DOĞRULANACAK:** Levent bu entegrasyon için ayrıca açık kapsam/onay verecek mi?

---

## 1.68.19+109 release / Play / rewarded canlı kabul — AÇIK

- Aynı `gameId` ikinci +10 XP vermez — fiziksel canlı kabul.
- Yarım/başarısız rewarded reklamda XP yok; hak korunur ve yeniden denenebilir — fiziksel canlı kabul.
- Farklı tamamlanan oyunlarda günlük/oturumluk toplam kota yok — fiziksel canlı kabul.
- Production +109 AAB package/version/signing/AdMob/Firebase profil doğrulaması.
- Play Console +109 upload/install/rollout/public listing doğrulaması.
- Play App Signing / Upload sertifika SHA rollerinin canlı Console + Firebase fingerprint eşlemesi.

---

## Canlı Düello fiziksel kabulü — AÇIK

İki güncel Play cihazı ve iki ayrı hesapla otomatik eşleştirme, 10/20/30 soru, aynı soru/sıra, skor/ilerleme, maç sonucu, BR/lig tek sefer işleme, leaderboard ve kopma/ayrılma davranışı uçtan uca doğrulanacak.

---

## Soru geri bildirimleri — AÇIK

- Sheet'teki bekleyen olaylar canlı kaynaktan yeniden okunacak.
- Her soru için metin, dört seçenek, doğru indeks, açıklama, kategori ve zorluk birlikte kontrol edilecek.
- `assets/questions.json` kontrolsüz değiştirilmeyecek.
- Sheet satırı gerçek soru düzeltmesi merge edilmeden kapatılmayacak.

---

## 3B tahta — DURDURULDU / KARAR BEKLİYOR

- Oynanış, BoardMap ve 67 node düzenine dokunulmayacak.
- Önce numaralı deterministik geometri.
- 8 konsept rozet / 6 fiziksel rozet eşlemesi çözülmeden ilerlenmeyecek.
- Kullanıcı görsel onayı olmadan stil/Flutter/APK aşamasına geçilmeyecek.

---

## Mağaza ve tanıtım — AÇIK

Telefon, tablet, Chromebook, PC ve XR varlıklarının Play Console durumu canlı ekrandan `hazır / yüklendi / reddedildi / yeniden yapılacak` biçiminde doğrulanacak.
