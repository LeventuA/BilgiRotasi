# Bilgi Rotası – Proje Durumu

**Son güncelleme:** 3 Eylül 2026 — PR #163 Levent’in “Devam et” onayıyla Ready for Review yapıldı; merge ayrı açık onay bekliyor

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
- Güncel PR: **#163 — OPEN / READY / merged=false**.
- PR #163 Ready öncesi doğrulanan HEAD: `4f3c0eaf231f23c70dd3bb35be6cfff2fe7f8d0c`; Ready sonrası yalnız proje checkpoint belgeleri güncellenmiştir.
- PR #167 merge commit’i: `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.
- B5 + swipe ürün commit’i: `749c678b885d6cefec428c603c55a83a4190152c`.
- Compact completion ürün commit’i: `9a6fede2c4aed4fdbaa6c9ba427fa84e0ce418da`.
- Compact completion için exact tested `lib/word_hunt/word_hunt_screens.dart` blob’u: **`6ce2830a7df8eb696a9df589c91c544df7712969`**.

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

- **B5 ilk ölçüm: 115 saniye / 2 hata / 7 target + bonus ANIT.** Soft challenge hedefi 60 sn → **HEDEF KARŞILANMADI**.
- **B10: 109 saniye / 4 hata / 9 target + bonus HAZİNE.** Soft challenge hedefi 120 sn → **HEDEF KARŞILANDI**.
- B5 tuning sonrası gerçek cihaz sonucu: **32 saniye / UI'da 2 false-positive kayıt / 7 target + bonus ANIT**.
- Levent iki kaydın bilinçli yanlış seçim olmadığını; kaydırma sırasında fazla temas/taşma kaynaklı olduğunu bildirdi. İnsan niyeti açısından sonuç **0 gerçek hata**dır.
- B5 60 sn soft challenge tuning amacı **PASS**.

### B5 60 sn denge adayı — TEKNİK + İNSAN SÜRE PASS

- Aday branch: `tune/kelime-avi-v6-b5-60s-layout-20260902`.
- Aday ürün commit: `44ebec6b830a288df66f4fa16e2611dfa2165bae` — `tune(kelime-avi): simplify B5 word layout for 60s challenge`.
- Yedi target (`ANKARA`, `ŞEHİR`, `TÜRKİYE`, `BAŞKENT`, `MECLİS`, `KULE`, `KALE`) ve bonus `ANIT` değişmedi.
- 8×8 / 64 hücre, 60 sn soft challenge, yıldız/eşik kuralları ve yatay+dikey+çapraz yön aileleri korundu.
- Android 16 run `33670657723` — **SUCCESS**.
- `dart analyze`: PASS; aday sözleşme testleri **3/3 PASS**; dar viewport 64 hücre render smoke PASS.
- QA APK SHA-256: `9a83695e1c62323a2ce61697bdb59aab16d91c8393be74c2725e40c0cea5a1c2`.
- Raw Android: `B5_64_CELL_RENDER=PASS`, `B5_FULL_RASTER_SCREENSHOT=PASS`, `PROCESS_FAILURE_SCAN=PASS`.
- Artifact `9862719927`.

### Swipe false-positive hata sayımı — PASS

- Geliştirme uygulama commit’i: `8610b01e7ac534def33c0125bc2b9185d2774f5d`; tarihsel Draft PR **#166 — OPEN / merge yok**.
- Input-normalization katmanı: kelime olamayacak kadar kısa gesture cezasız iptal; yalnız bir trailing hücre çıkarıldığında exact target/bonus/already-found oluşuyorsa kırpıp kabul; gesture boyunca tek aktif pointer; diğer anlamlı yanlış düz seçimler hata kalır.
- Geniş “en yakın kelimeyi kabul et” veya otomatik kelime bulma uygulanmadı.
- Path engine, scoring, timer, içerik ve yıldız eşikleri değiştirilmedi.
- Otomatik `Kelime Avi Fast Checks` run `33688788065`: **SUCCESS**.

### Temiz ürün entegrasyonu — PASS / MERGED PR #167

- Entegrasyon branch’i: `integrate/kelime-avi-v6-b5-swipe-20260903`.
- Ürün commit’i: `749c678b885d6cefec428c603c55a83a4190152c`.
- Fast checks run `33724552713`: **SUCCESS**.
- Android 16 run `33724549202`: **SUCCESS**. Gerçek fiziksel hareket ANKARA yolundan bir hücre taşırıldı; ANKARA bulundu (`0/7 → 1/7`) ve hata `0` kaldı.
- Android özet kapıları: `B5_64_CELL_RENDER`, `REAL_GESTURE_ANKARA_PLUS_ONE_CELL`, `TARGET_PROGRESS_0_TO_1_OF_7`, `MISTAKES_REMAINED_ZERO`, `PROCESS_FAILURE_SCAN` — tamamı PASS.
- Job `100550528945`; artifact `9881526593`; APK SHA-256 `73618f5af356374104475d457fe15f263cdd370b009f81f7691c5f7d333dbd58`.
- Kanıt için eklenen geçici QA/workflow dosyaları final ürün diff’inden temizlendi.
- **3 Eylül 2026:** Levent Ready onayı verdi; ardından “Devam et” ile açık merge kapısını onayladı.
- PR #167: **CLOSED / MERGED**. Merge commit: `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.
- Merge hedefi release/main değil, PR #163’ün V6 ürün branch’idir.

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

## Kalan Gerçek Kapılar

1. PR #167 B5 tuning + swipe entegrasyonu — **PASS / MERGED**; merge commit `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.
2. PR #163 güncel V6 ürün hattı — **READY / OPEN**; Levent 3 Eylül 2026’da “Devam et” ile Ready kapısını onayladı.
3. PR #163 merge — **AÇIK / ayrıca Levent’in açık onayı gerekli**.
4. `REFERENCE_FONT` exact kaynak bulunmadığı sürece **DOĞRULANACAK / deferred**.
5. PR #161 / #162 zincir kararları ayrıca ele alınacak.
6. Production `lib/main.dart` navigasyon entegrasyonu ayrı scope/onaydır.

**Durum:** V6 FOUND + ERROR + COMPACT COMPLETION PASS / B5 SÜRE PASS / SWIPE TOLERANSI ANDROID 16 PASS / PR #167 MERGED / PR #163 READY-OPEN / MERGE YOK.
