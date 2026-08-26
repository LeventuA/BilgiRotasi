# Bilgi Rotası - Açık Sorular ve Canlı Doğrulamalar

> 26 Ağustos 2026 aktif kesimidir. Bu tarihten önceki dosyanın tam ve değişmemiş kopyası `docs/project-memory/archive/ACIK_SORULAR_VE_DOGRULAMALAR_PRE_20260825.md` altında korunur.

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

## PR #132 Başlangıç Limanı production pilot — AÇIK

- PR #132: `OPEN / DRAFT / MERGED=false`.
- Base: `fix/kelime-avi-approved-reference-pixel-match-20260823` / `bc8a03bfefd401570e0c51cc4aab4206ea45d363`.
- Head branch: `feat/kelime-avi-baslangic-limani-asset-first-20260824`.
- Sürüm: `1.68.19+109`.
- PR #147, #150 ve #149 bu branch'e merge edildi.
- PR body güncel mimari ve final kapılarla hizalandı.

**DOĞRULANACAK — KALANLAR:**
1. Bütün merge/docs commit'lerini içeren yeni exact HEAD nedir?
2. Bu exact HEAD üzerinde focused test + analyze + `git diff --check` PASS mi?
3. Android 16 production proof yeni exact HEAD üzerinde SUCCESS mi?
4. Crash/ANR/FATAL/process-death taraması temiz mi?
5. Final production screenshot/artifact görünümü kabul edilebilir mi?
6. Levent PR #132 için ayrıca açık merge onayı verecek mi?

---

## Kelime Avı production ana navigasyon entegrasyonu — AÇIK / AYRI KAPSAM

- Production `lib/main.dart` bu pilot merge zincirinde değiştirilmedi.
- Başlangıç Limanı production route ekranının gerçek uygulama girişine bağlanması ayrı kapsamdır.

**DOĞRULANACAK:** Levent bu entegrasyon için ayrı açık kapsam/onay verecek mi?

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
