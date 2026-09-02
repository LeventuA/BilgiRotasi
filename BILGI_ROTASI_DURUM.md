# Bilgi Rotası – Proje Durumu

**Son güncelleme:** 3 Eylül 2026 — swipe toleransı kodlandı; hedefli CI bekliyor

## Canlı Sürüm / Release Hattı

- Repo içi aktif ürün sürümü: **1.68.19+109**.
- Paket: `com.leventua.bilgirotasi`.
- Canonical release branch: `release/final-closed-test-aab-1.68.8` / `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`.
- `main` yayın kaynağı olarak varsayılmaz; canlı ürün branch/PR her görevde yeniden doğrulanır.

## Kelime Avı V6 — Güncel Ürün Hattı

Canonical gameplay sözleşmesi **8×8 / 64 hücre** olarak kilitlidir.

- Parent V5: PR #161 — **OPEN / DRAFT / merge yok**.
- V6 temel görsel: PR #162 — **OPEN / DRAFT / merge yok**.
- Güncel ürün branch: `fix/kelime-avi-v6-found-path-connector-product-20260901`.
- Güncel Draft PR: **#163 — OPEN / DRAFT / merged=false**.
- Son ürün commit: `9a6fede2c4aed4fdbaa6c9ba427fa84e0ce418da` — `fix(kelime-avi): compact completion result dialog`.
- PR #163 üzerindeki `lib/word_hunt/word_hunt_screens.dart` blob’u: **`6ce2830a7df8eb696a9df589c91c544df7712969`**.
- Bu blob, kullanıcı tarafından PASS verilen kompakt completion adayında Android’de test edilen exact blob ile birebirdir.

## Görsel / Davranış Kabul Kapıları

### Found-state edge-fuse — PASS

- Exact tested commit: `4dddf00178ef9f14b8edb3fc706114be72f477a4`.
- Android 16 run `33486609120` — **SUCCESS**.
- Raw B10 initial + `YOL / 1/9` edge-fuse kullanıcı görsel kabulü: **PASS**.
- Found hücreler ayrı formunu korur; yalnız komşu found hücrelerin görünür aralığı sıcak altın/turuncu birleşir.

### Error-state — PASS

- Clean tested commit: `0d845fc75bbe7b92c3d778ccfbcbde2761fa56de`.
- Android 16 run `33524578623` — **SUCCESS**.
- Error fill: `0xB35A1F2B`; border: `0xFFFF6B57`; 280 ms değişmedi.
- Başarı altını ile hata bordosu ayrıştırıldı; kullanıcı görsel kabulü: **PASS**.

### Completion / result popup — PASS

- Otomatik completion davranışı düzeltildi: ana hedefler tamam, bonus eksik → otomatik popup yok; tüm target+bonus tamam → otomatik popup; yeni oturum/replay → tekrar otomatik popup.
- Premium liman temalı sonuç popup’ı kabul edildi; ardından kullanıcı isteğiyle kompaktlaştırıldı.
- Exact compact tested product commit: `7fa81663cb93c3f9f43b5c1bb7cd8f4d11929fd8`.
- Exact compact tested blob: `6ce2830a7df8eb696a9df589c91c544df7712969`.
- Kompakt ölçüler: `maxWidth: 300`, padding `18/15/18/15`, sonuç butonu yüksekliği `44`.
- Static/productize run `33629855060` — **SUCCESS**; analyze + Word Hunt **139/139 PASS**.
- Final clean Android 16 run `33655562508` — **SUCCESS**.
- Android gate: B5 target-only no-dialog PASS; B5 all-words auto-dialog PASS; B5 fresh replay auto-dialog PASS; B10 target-only no-dialog PASS; B10 all-words auto-dialog PASS; crash/ANR scan PASS.
- Kompakt popup raw Android B5/B10 ekranları kullanıcıya gösterildi ve **2 Eylül 2026’da PASS** verildi.

## Gerçek İnsan Süre-Zorluk Playtesti

Levent’in gerçek cihaz/insan oynayışı:

- **B5: 115 saniye / 2 hata / 7 target + bonus ANIT.** Soft challenge hedefi 60 sn → **HEDEF KARŞILANMADI**.
- **B10: 109 saniye / 4 hata / 9 target + bonus HAZİNE.** Soft challenge hedefi 120 sn → **HEDEF KARŞILANDI**.

Bu sonuç **MIXED** kabul edilir. Otomatik QA’nın 20/23 saniyelik scripted süreleri insan playtesti değildir ve denge kararı için kullanılmaz. B5 60 sn hedefi hard-fail olmadığı için gameplay/timer kendiliğinden değiştirilmez; denge/tuning kararı ayrıca verilecektir.

### B5 60 sn denge adayı — TEKNİK + İNSAN SÜRE PASS

- Aday branch: `tune/kelime-avi-v6-b5-60s-layout-20260902`.
- Aday ürün commit: `44ebec6b830a288df66f4fa16e2611dfa2165bae` — `tune(kelime-avi): simplify B5 word layout for 60s challenge`.
- Güncel tuning branch HEAD: `b0a0fa5a4935b3595c48ad95d8d4089e9dd4ebec`.
- Yedi target (`ANKARA`, `ŞEHİR`, `TÜRKİYE`, `BAŞKENT`, `MECLİS`, `KULE`, `KALE`) ve bonus `ANIT` değişmedi.
- 8×8 / 64 hücre, 60 sn soft challenge, yıldız/eşik kuralları ve yatay+dikey+çapraz yön aileleri korundu.
- Android 16 run `33670657723` — **SUCCESS**.
- `dart analyze`: PASS; aday sözleşme testleri **3/3 PASS**; dar viewport 64 hücre render smoke PASS.
- QA APK: `com.leventua.bilgirotasi.wordhuntb5qa`, SHA-256 `9a83695e1c62323a2ce61697bdb59aab16d91c8393be74c2725e40c0cea5a1c2`.
- Raw Android: `B5_64_CELL_RENDER=PASS`, `B5_FULL_RASTER_SCREENSHOT=PASS`, `PROCESS_FAILURE_SCAN=PASS`.
- Artifact `9862719927`, digest `sha256:bccdf3f22b9a42a56624138ea57378ff8302caa147c3f9c7a8049b1f0385590c`.
- Levent gerçek cihaz sonucu: **32 saniye / UI'da 2 hata / 7 target + bonus ANIT**.
- Levent iki kaydın bilinçli yanlış seçim olmadığını; kaydırma sırasında fazla temas/taşma nedeniyle oluştuğunu bildirdi. İnsan niyeti açısından sonuç **0 gerçek hata**dır.
- 60 sn soft challenge süresi karşılandı; B5 tuning amacı **PASS**. Ancak 1 yıldız sonucu mevcut sayacın mekanik çıktısıdır ve iki false-positive hata nedeniyle kullanıcı performansını doğru temsil etmez.

### Swipe false-positive hata sayımı — KODLANDI / CI BEKLİYOR

- Mevcut runtime tek hücrelik tap/release seçimini `notAWord` olarak sayabilir.
- Doğru kelime yolunun sonundan bir hücre taşan sürükleme bütün yolu `notAWord` yapabilir.
- Listener aktif pointer kimliğini kilitlemediği için aynı gesture sırasında istenmeyen ek temas seçime karışabilir.
- Branch `fix/kelime-avi-swipe-tolerance-20260903` üzerinde input-normalization katmanı eklendi: kelime olamayacak kadar kısa gesture cezasız iptal; yalnız bir trailing hücre çıkarıldığında exact target/bonus/already-found oluşuyorsa kırpıp kabul; gesture boyunca tek aktif pointer; diğer anlamlı yanlış düz seçimler hata kalır.
- Geniş “en yakın kelimeyi kabul et” veya otomatik kelime bulma uygulanmayacak.
- Path engine, scoring, timer, içerik ve yıldız eşikleri değiştirilmedi. Dört resolver testi ile kısa temas + taşma + çoklu pointer widget regresyonları eklendi.
- Çalışma ortamında Flutter/Dart SDK bulunmadığı için `git diff --check` PASS olsa da executable focused test/analyze sonucu uzaktaki CI’dan alınmadan kapı kapanmış sayılmaz; Android/APK üretilmedi.

## Ölçeklenebilir üretim/test akışı

- Her bölüm için ayrı branch/Action/APK/insan testi yapılmayacak.
- Üretim birimi 10 bölümlük rota/pakettir; 10 bölüm tek içerik branch’inde geliştirilir.
- Her bölüm otomatik grid/kelime/yol/timer/render sözleşme testinden geçer.
- Varsayılan insan örneklemesi: B1 + B5 + B10; yalnız otomatik outlier bulunan bölüm ayrıca oynanır.
- Tek Android 16 paket kapısı 10 bölüm tamamlanınca çalışır. Engine/ortak UI değişikliği ve final release ayrıca tam Android kapısı gerektirir.
- Paket QA APK’sı B1–B10 bölüm seçici taşır; bölüm başına ayrı APK üretilmez.

## Reference font

- Runtime `fontFamily: 'serif'` kullanır.
- `pubspec.yaml` custom font tanımı yok; repoda `.ttf/.otf/.woff/.woff2` kaynak yok.
- Exact reference font ailesi mevcut kaynaklardan kanıtlanamadı.
- `REFERENCE_FONT = DOĞRULANACAK / KAYNAK SINIRI`; spekülatif font değişikliği yapılmadı.

## Korunan Alanlar

Bu ürünizasyon sırasında değiştirilmedi:
- canonical 8×8 / 64 hücre içerik geometrisi
- `assets/questions.json`
- `lib/main.dart`
- `assets/word_hunt/v5_reference_assets/**`
- locked V5 reference asset SHA sözleşmesi
- BoardMap / 67 node
- Firebase / AdMob / release signing
- package name / version

QA workflow/script dosyaları PR #163 ürün branch’ine taşınmadı; ürün değişikliği exact tested `word_hunt_screens.dart` blob’u ile sınırlıdır, proje hafıza dosyaları ayrıca güncellenir.

## Kalan Gerçek Kapılar

1. Swipe false-positive hedefli test/analyze kapısını çalıştırmak — **KODLANDI / CI BEKLİYOR**; B5 ekranda 2, gerçekte 0 bilinçli hata.
2. B5 tuning adayını PR #163 ürün hattına temiz biçimde taşımak — **AÇIK**; 32 sn süre PASS.
3. `REFERENCE_FONT` exact kaynak bulunmadığı sürece DOĞRULANACAK/deferred.
4. PR #161 / #162 / #163 Ready kararları ayrıca verilecek.
5. Production `lib/main.dart` navigasyon entegrasyonu ayrı scope/onaydır.
6. Merge yalnız Levent’in ayrı ve açık merge onayıyla yapılır.

**Durum:** V6 FOUND + ERROR + COMPACT COMPLETION PASS / B5 SÜRE PASS / SWIPE TOLERANSI KODLANDI-CI BEKLİYOR / PAKET BAZLI TEST AKIŞI KABUL / READY YOK / MERGE YOK.
