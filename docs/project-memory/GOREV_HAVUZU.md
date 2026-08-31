# Bilgi Rotası - Görev Havuzu

> 29 Ağustos 2026 aktif kesimidir. Eski tam görev kayıtları Git geçmişi ve `docs/project-memory/archive/` altında korunur. Teknik gerçek her zaman canlı GitHub ve ilgili canlı servislerdir.

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

**Durum:** TEKNİK GATE + CURRENT V5 GÖRSEL KABUL TAMAMLANDI / İNSAN PLAYTESTİ + READY/MERGE BEKLENİYOR.

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
- [x] Current exact-reference gameplay görsel hedefi kullanıcı PASS aldı; güncel entegrasyon 0Y altında kayıtlıdır.
- [ ] B5/B10 gerçek insan süre dengesi playtesti.
- [ ] İnsan playtesti sonrasında ayrıca Ready kararı verilir.
- [ ] Levent ayrıca açık merge onayı verir.

İlk gate run `33250841637` formatter nedeniyle erken durmuştu; ürün failure sayılmaz. Düzeltilmiş final gate `33251736068` bunun yerini alan teknik kanıttır.

### PR #158 eski V5 gameplay tema checkpoint'i — TARİHSEL / SUPERSEDED

Önceki `67f7365...` refined-V5 görsel kabul kaydı exact-reference talebiyle supersede edilmiştir. Güncel production gameplay görsel kabul kaydı aşağıdaki **0Y** görevindedir. Eski kanıtlar Git geçmişinde korunur; current kabul olarak kullanılmaz.

---

## 0Y - V5 exact-reference production asset entegrasyonu / PR #161

**Durum:** ASSET + FLUTTER ENTEGRASYON + ANDROID INITIAL + FOUND-STATE GÖRSEL GATE PASS / HUMAN PLAYTEST + READY/MERGE BEKLENİYOR.

- Branch: `feat/kelime-avi-v5-reference-assets-integration-20260831`.
- Product HEAD: `50ab6c8da3a4d6683568c71d52f893c5dfe2e9f7`.
- Draft PR: **#161** — OPEN / DRAFT / merged=false / mergeable=true; base PR #158 branch'i `5362c094...`.
- Sürüm: `1.68.19+109`.
- Asset commit: `0d73ab3bbf5217caf203876c8c02fd5673d13d9e`.
- Production asset sayısı: 11; 11/11 exact SHA-256 PASS.
- `icon_anchor.png` / `icon_compass.png`: UNUSED / REJECTED / production overlay değil.
- Integration run `33379341765`: SUCCESS; asset SHA, deterministic presentation patch, format, analyze, 138/138 focused tests, diff/scope gate PASS.
- Android 16 initial B10: run `33384781507` SUCCESS; exact product SHA `50ab6c8...`; API36 / 1080×1920 / 420 dpi; artifact `9755405253`.
- Gerçek Android found-state artifact: run `33388386388`, artifact `9756762383` içinde `09_B10_YOL_FOUND.png`; sayaç `1/9`, Y-O-L altın found state, alt panel `YOL bulundu!`; `changed_pixels=29970` visual-change PASS.
- `33388386388` overall FAILURE, yalnız PNG/gesture kanıtlarından sonraki exact log-string grep assertion nedeniyle; ürün crash/failure olarak sınıflandırılmaz ve workflow SUCCESS diye yazılmaz.
- Levent current exact-reference görsel hedefe açık **PASS** verdi; runtime found-state görüntüsü daha sonra aynı kabul edilmiş görünümle doğrulandı.
- Canonical grid **8×8 / LOCKED / UNCHANGED**.

**Bitti ölçütü:**
- [x] Onaylı 11 raster production asset exact SHA ile branch'e alındı.
- [x] Assetler minimum presentation diff ile Flutter'a bağlandı.
- [x] Gameplay engine/swipe/timer/scoring/progression korunuyor.
- [x] 8×8 ve 64 hücre sözleşmesi korunuyor.
- [x] Format/analyze/focused test/scope gate PASS.
- [x] Gerçek Android 16 initial B10 runtime screenshot PASS.
- [x] Gerçek Android 16 found-state YOL görsel/gesture-change kanıtı PASS.
- [x] Current exact-reference görünüm kullanıcı görsel PASS aldı.
- [ ] `ERROR_STATE_VISUAL` için referans/karar doğrulaması.
- [ ] Exact `REFERENCE_FONT` kaynağı/kararı doğrulaması; mevcut kabul edilmiş görünüm tahminle değiştirilmez.
- [ ] B5 60s / B10 120s gerçek insan süre-zorluk playtesti.
- [ ] PR #161 ve zincirdeki #158 için ayrıca Ready kararı.
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
