# Bilgi Rotası - Görev Havuzu

> 1 Eylül 2026 aktif kesimidir. Eski tam görev kayıtları Git geçmişi ve `docs/project-memory/archive/` altında korunur. Teknik gerçek her zaman canlı GitHub ve ilgili canlı servislerdir.

## 0R - Başlangıç Limanı production MASTER ART mimari kabulü

**Durum:** TAMAMLANDI.

- [x] Issue #109 `Photo 1.jpg` tek bağlayıcı MASTER ART.
- [x] Production MASTER ART raster + şeffaf hitbox mimarisi kabul edildi.
- [x] Dynamic progression state görünür ve callback sözleşmesi doğrulandı.

---

## 0S - PR #147 production merge kapısı

**Durum:** TAMAMLANDI / MERGED.

- [x] Android 16 production/pixel-proof PASS.
- [x] Levent açık merge onayı verdi.
- [x] Merge SHA `d118aa98c5551cb3b4418f61047f6a730406d963`.

---

## 0T - Dynamic progression görünür state / PR #150

**Durum:** TAMAMLANDI / MERGED.

- [x] Gerçek `X / 30`, yıldız ve locked/open state override edildi.
- [x] Android 16 run `32969604847` SUCCESS.
- [x] Merge SHA `d64fcd4ea63f173c6653ff33926b12a6c99ef37d`.

---

## 0U - Proje hafızası checkpoint / PR #149

**Durum:** TAMAMLANDI / MERGED.

- [x] Merge SHA `adb4557a9a95dd624166b6b08a9e0ab27b1e4f80`.

---

## 0V - PR #132 final entegrasyon zinciri

**Durum:** TARİHSEL / TAMAMLANDI.

26 Ağustos production MASTER ART zincirinin tarihsel checkpoint'idir.

---

## 0W - Kelime Avı production ana navigasyon entegrasyonu

**Durum:** AÇIK / AYRI KAPSAM + AYRI ONAY GEREKİYOR.

`lib/main.dart` 8×8 starter-content dönüşümünün kapsamı değildir.

**Bitti ölçütü:**
- [ ] Levent açık kapsam/onay verir.
- [ ] Canlı hedef branch/release yeniden kilitlenir.
- [ ] Minimum navigation diff ayrı branch/PR üzerinde yapılır.
- [ ] Mevcut giriş, reklam, Firebase, BoardMap/67 node ve diğer oyun modları bozulmaz.
- [ ] Analyze/test/Android gerçek cihaz veya Android 16 kabulü PASS.
- [ ] Ayrı açık merge onayı olmadan merge yapılmaz.

---

## 0X - Başlangıç Limanı 8×8 starter-content dönüşümü

**Durum:** TEKNİK GATE TAMAMLANDI / V6 RAW ANDROID GÖRSEL PASS / READY-MERGE YOK.

- Branch: `feat/kelime-avi-8x8-content-v1-20260829`
- Temiz ürün commit: `052ea7da775db0b58a5ce0c6731a04f251879008`
- Draft PR: **#158** — OPEN / DRAFT / merged=false / mergeable=true.
- Final gate run: `33251736068` — **SUCCESS**.
- Artifact: `9714700778` / `sha256:dfbca264c2f67bb3549a0e336b075c9238f1a0638962dc69392ea8715b9a2092`.

**Bitti ölçütü:**
- [x] 10 bölümün tüm gridleri 8×8 üretildi.
- [x] 80 toplam target+bonus kelime eğrisi korundu.
- [x] Her target/bonus exactly-one physical straight-line occurrence statik denetimden geçti.
- [x] Intended/reverse canonical yol eşleşmeleri doğrulandı.
- [x] B5/B10 yatay+dikey+çapraz yön aileleri korunuyor.
- [x] B8/B9/B10 özel kelime sözleşmeleri ve B5/B10 süre eşikleri korunuyor.
- [x] Hard-coded widget gesture yolları canonical 8×8 koordinatlarla eşleşiyor.
- [x] Gerçek Dart formatter PASS.
- [x] `dart analyze lib/word_hunt` PASS / No issues.
- [x] Focused Word Hunt testleri **37/37 PASS**.
- [x] Full Flutter suite **442/442 PASS**.
- [x] `git diff --check` ve korunan alan scope gate PASS.
- [x] Android 16 B1/B5/B8/B10 ilk viewportta **64/64** hücre görünürlüğü PASS.
- [x] B5 >60 saniye soft-time PASS.
- [x] Android 16 gerçek `ANKARA` ve ters `BAŞKENT` swipe PASS.
- [x] Crash/ANR/FATAL/am_crash taraması temiz.
- [x] QA-only entrypoint/helper dosyaları ürün commitinde yok.
- [x] Temiz ürün commit SHA'sı yazıldı.
- [x] 8×8 Draft PR #158 açıldı.
- [x] Current V6 raw Android initial + edge-fuse found-state kullanıcı görsel PASS aldı.
- [ ] B5/B10 gerçek insan süre dengesi playtesti.
- [ ] İnsan playtesti sonrasında ayrıca Ready kararı verilir.
- [ ] Levent ayrıca açık merge onayı verir.

---

## 0Y - V5 exact-reference production asset entegrasyonu / PR #161

**Durum:** ASSET + FLUTTER ENTEGRASYON TEKNİK PASS / V6 CHILD RAW ANDROID GÖRSEL PASS / READY-MERGE YOK.

- Branch: `feat/kelime-avi-v5-reference-assets-integration-20260831`.
- Product integration commit: `50ab6c8da3a4d6683568c71d52f893c5dfe2e9f7`.
- Draft PR: **#161** — OPEN / DRAFT / merged=false.
- Sürüm: `1.68.19+109`.
- Asset commit: `0d73ab3bbf5217caf203876c8c02fd5673d13d9e`.
- Production asset sayısı: 11; 11/11 exact SHA-256 PASS.
- `icon_anchor.png` / `icon_compass.png`: UNUSED / REJECTED / production overlay değil.
- Integration run `33379341765`: SUCCESS; asset SHA, deterministic presentation patch, format, analyze, 138/138 focused tests, diff/scope gate PASS.

**V6 accepted child chain:**
- PR #162: temel V6 spacing/scale/found-state sunumu.
- PR #163: accepted edge-fuse found path.
- Exact Android-tested edge-fuse commit: `4dddf00178ef9f14b8edb3fc706114be72f477a4`.
- Exact tested blob: `f43deaad5328f6263f9479de1738cc1f4ac465e0`.
- Android 16 run `33486609120`: SUCCESS; analyze PASS; focused 138/138 PASS; B10 `0/9 → 1/9`; semantic + edge-fuse pixel gates PASS.
- Artifact `9792346079`, digest `sha256:f5a1592ce074a6e0a8f3bc1f7c88baf5bd9ec9b6bf5337327d7368aea83046d8`.
- Raw B10 initial ve raw `YOL / 1/9` edge-fuse found-state Levent tarafından **PASS** edildi.
- Clean product commit: `217beb83c31976436a6f26ec43ae4e35a0c7f05c` exact aynı blob’u taşır.

**Bitti ölçütü:**
- [x] Onaylı 11 raster production asset exact SHA ile branch'e alındı.
- [x] Assetler minimum presentation diff ile Flutter'a bağlandı.
- [x] Gameplay engine/swipe/timer/scoring/progression korunuyor.
- [x] 8×8 ve 64 hücre sözleşmesi korunuyor.
- [x] Format/analyze/focused test/scope gate PASS.
- [x] Gerçek Android 16 initial B10 screenshot üretildi.
- [x] Gerçek Android 16 YOL swipe/found-state teknik kanıtı üretildi.
- [x] V6 raw Android initial görünüm kullanıcı görsel PASS aldı.
- [x] V6 edge-fuse raw Android found-state kullanıcı görsel PASS aldı.
- [ ] `ERROR_STATE_VISUAL` için referans/karar doğrulaması.
- [ ] Exact `REFERENCE_FONT` kaynağı/kararı doğrulaması.
- [ ] B5 60s / B10 120s gerçek insan süre-zorluk playtesti.
- [ ] PR #161 / #162 / #163 için ayrıca Ready kararı.
- [ ] Levent'in ayrıca açık merge onayı.
- [ ] Production `lib/main.dart` navigasyon entegrasyonu ayrı 0W görevi.

---

## Korunan açık işler

- Soru geri bildirimleri: soru metni + 4 seçenek + doğru indeks + açıklama + kategori + zorluk birlikte doğrulanacak; gerçek düzeltme merge edilmeden Sheet satırı kapatılmayacak.
- Rewarded/SSV fiziksel no-double, başarısız reklamda hak/retry ve farklı oyunlarda toplam kota olmaması canlı kabul maddeleri.
- Play/Firebase signing SHA rol eşlemesi ve canlı production/Play kabul maddeleri.
- İki cihaz Canlı Düello uçtan uca fiziksel kabulü.
- 3B tahta: BoardMap/67 node korunur; 8 konsept rozet / 6 fiziksel rozet eşlemesi çözülmeden ilerlenmez.
- Mağaza/tanıtım varlıklarının canlı Play Console durumu.

## Kaynak koruması

- `assets/questions.json` kontrolsüz değiştirilmez.
- `main` güncel yayın kaynağı varsayılmaz.
- Release/main'e doğrudan yazılmaz.
- Kritik merge için Levent'in açık onayı gerekir.
- Build PASS tek başına çalışma kanıtı değildir.
