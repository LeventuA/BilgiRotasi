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

**Durum:** TEKNİK GATE TAMAMLANDI / KULLANICI KABULÜ BEKLENİYOR.

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
- [ ] B5/B10 gerçek insan süre dengesi playtesti.
- [ ] Levent 8×8 gerçek görünüm/oynanış kabulü verir.
- [ ] Kullanıcı kabulünden sonra ayrıca Ready kararı verilir.
- [ ] Levent ayrıca açık merge onayı verir.

İlk gate run `33250841637` formatter nedeniyle erken durmuştu; ürün failure sayılmaz. Düzeltilmiş final gate `33251736068` bunun yerini alan teknik kanıttır.

---

## 0Y - Başlangıç Limanı gece-limanı / deniz-feneri tema uygulaması

**Durum:** KOD + PRODUCTION FLOW BAĞLANTISI HAZIR / RUNTIME DOĞRULAMA BEKLİYOR.

- Kullanıcı tema seçimi: beş aday içinden **1. görsel**.
- Ana görsel yön: derin lacivert gece limanı + sıcak altın/amber deniz feneri ışığı.
- Clean branch: `feat/kelime-avi-baslangic-limani-theme-clean-v1-20260829`.
- Taban: doğrulanmış 8×8 docs HEAD `69efcd17606d339233e1d9ca6183d9ac37ed5b5c`.
- Tema wrapper: `lib/word_hunt/baslangic_limani_theme_screen.dart`.
- Production flow varsayılan level açılışı `BaslangicLimaniThemedLevelScreen` üzerinden mevcut `WordHuntLevelProductionScreen`'e bağlandı.
- `lib/main.dart`, doğrulanmış production screen, 8×8 content, path/scoring, MASTER ART ve reklam/Firebase/release yapılandırması değişmedi.
- Tema branch'inde Actions run sayısı 0.

**Bitti ölçütü:**
- [x] Seçilen tema kod katmanı ayrı ve geri alınabilir dosyada oluşturuldu.
- [x] Overlay pointer eventlerini `IgnorePointer` ile engellemiyor.
- [x] Production gameplay flow varsayılan açılışı tema wrapper'a bağlandı.
- [x] Tema widget sözleşme testi yazıldı.
- [x] Rota → Bölüm 1 → tema → production ekran entegrasyon testi yazıldı.
- [x] Diff temiz: production base'e göre yalnız tema dosyaları/testleri + gameplay flow'da 2 ekleme/1 değişiklik.
- [ ] Gerçek Dart formatter/analyze PASS.
- [ ] Tema testleri gerçek Flutter runner'da PASS.
- [ ] Android 16 gerçek tema ekran görüntüsü alınır.
- [ ] Kullanıcı seçilen görsel dile yakınlığı ve okunabilirliği onaylar.
- [ ] Gerekirse tema renk/ışık yoğunluğu gerçek screenshot üzerinden ayarlanır.
- [ ] Draft PR ancak runtime görsel gate sonrası açılır.
- [ ] Ready/merge yalnız ayrı kullanıcı onayıyla yapılır.

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
