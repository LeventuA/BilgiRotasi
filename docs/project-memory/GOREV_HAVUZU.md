# Bilgi Rotası - Görev Havuzu

> 29 Ağustos 2026 aktif kesimidir. 26 Ağustos öncesindeki görev havuzunun tam ve değişmemiş kopyası `docs/project-memory/archive/GOREV_HAVUZU_PRE_20260825.md` altında korunur. Teknik gerçek her zaman canlı GitHub ve ilgili canlı servislerdir.

## 0R - Başlangıç Limanı production MASTER ART mimari kabulü

**Durum:** TAMAMLANDI.

- [x] Issue #109 `Photo 1.jpg` tek bağlayıcı MASTER ART.
- [x] Production `WordHuntReferenceRouteScreen` MASTER ART raster görünür taban kullanıyor.
- [x] Level 1–10, geri, bilgi, pusula ve kitap şeffaf hitbox ile gerçek callback/progression sistemine bağlı.
- [x] Görünür MASTER ART sanatı ikinci kez komple Flutter katmanı olarak çizilmiyor.
- [x] Node 9 normal/open; 7 sonrası 8 + 9 açılıyor; 9 callback aktif; final 10 node 9 tamamlanana kadar locked/callback yok.
- [x] Levent görseli ve `MASTER ART raster + şeffaf hitbox` mimarisini açıkça kabul etti.

---

## 0S - PR #147 production merge kapısı

**Durum:** TAMAMLANDI / MERGED.

- [x] Final PR #147 pre-merge HEAD `4f1e2f60962236990556610f87313dda0b341e8b` doğrulandı.
- [x] Android 16 production/pixel-proof kanıtları PASS.
- [x] Levent açık `Merge et` onayı verdi.
- [x] Expected-head ile squash merge yapıldı.
- [x] Merge SHA `d118aa98c5551cb3b4418f61047f6a730406d963`.
- [x] PR #147 `CLOSED / MERGED`.

---

## 0T - Dynamic progression görünür state düzeltmesi / PR #150

**Durum:** TAMAMLANDI / MERGED.

- [x] Raster demo `12 / 30` state'inin runtime progression ile çelişebildiği tespit edildi.
- [x] Gerçek `X / 30` lokal override eklendi.
- [x] Level 1–10 gerçek `0–3` yıldız state'i lokal override edildi.
- [x] Gerçek locked/open state görünür hale getirildi.
- [x] İlk ikinci-yıldız-satırı denemesi görsel FAIL kabul edildi.
- [x] MASTER ART gerçek star-slot pikselleri ölçüldü; generic node-diameter yıldız konumu kaldırıldı.
- [x] Bonus 8, normal 9 ve büyük final 10 kendi ölçülmüş yıldız yuvasını kullanıyor.
- [x] Android 16 production run `32969604847`: SUCCESS.
- [x] Artifact `9607328059`; digest `sha256:a1c01a5acb1c515b584e6cf1d24dea63ece57eaa9417f279f4b52f17e41ef776`.
- [x] Node 9 unlocked/callback PASS.
- [x] Node 10 locked/no-callback PASS.
- [x] App process failure scan PASS.
- [x] Production screenshot'ta eski demo star kalıntıları temizlendi.
- [x] Production asset contract kabul edilen MASTER ART raster + hitbox + lokal state override mimarisine güncellendi.
- [x] PR #150 PR #132 feature branch'ine merge edildi; merge SHA `d64fcd4ea63f173c6653ff33926b12a6c99ef37d`.

---

## 0U - PR #149 proje hafızası checkpoint merge

**Durum:** TAMAMLANDI / MERGED.

- [x] PR #147 sonrası yaşayan proje hafızası checkpoint'i korundu.
- [x] PR #149 PR #132 feature branch'ine merge edildi.
- [x] Merge SHA `adb4557a9a95dd624166b6b08a9e0ab27b1e4f80`.

---

## 0V - PR #132 final entegrasyon kapısı

**Durum:** TARİHSEL / MERGE ZİNCİRİ TAMAMLANDI.

26 Ağustos production MASTER ART ve dynamic progression zincirinin tarihsel checkpoint'idir. Güncel Kelime Avı aktif işi aşağıdaki 0X maddesidir.

---

## 0W - Kelime Avı production ana navigasyon entegrasyonu

**Durum:** AÇIK / AYRI KAPSAM + AYRI ONAY GEREKİYOR.

`lib/main.dart` mevcut 8×8 içerik dönüşümünün kapsamı değildir. Başlangıç Limanı production rota ekranının gerçek uygulama navigasyonundan açılması ayrı görevdir.

**Bitti ölçütü:**
- [ ] Levent açık kapsam/onay verir.
- [ ] Canlı hedef branch/release yeniden kilitlenir.
- [ ] Minimum navigation diff ayrı branch/PR üzerinde yapılır.
- [ ] Mevcut giriş, reklam, Firebase, BoardMap/67 node ve diğer oyun modları bozulmaz.
- [ ] Analyze/test/Android gerçek cihaz veya Android 16 kabulü PASS.
- [ ] Ayrı açık merge onayı olmadan merge yapılmaz.

---

## 0X - Başlangıç Limanı 8×8 starter-content dönüşümü

**Durum:** DEVAM EDİYOR / STATİK PASS / FLUTTER + ANDROID16 DOĞRULANACAK.

Branch: `feat/kelime-avi-8x8-content-v1-20260829`
Başlangıç SHA: `0e9408ddda511259f588a338b3fcd8192bf92431`
Geçici gate SHA: `7cff26f4a75e1c58beaea2c163f2e89e2c2af154`

**Bitti ölçütü:**
- [x] 10 bölümün tüm gridleri 8×8 olarak üretildi.
- [x] 80 toplam target+bonus kelime eğrisi korundu.
- [x] Her target/bonus exactly-one physical straight-line occurrence statik denetimden geçti.
- [x] Intended/reverse canonical yol eşleşmeleri statik olarak doğrulandı.
- [x] B5 ve B10 yatay+dikey+çapraz yön ailelerini birlikte taşıyor.
- [x] B8/B9/B10 özel kelime sözleşmeleri ve B5/B10 süre eşikleri korunuyor.
- [x] Yeni hard-coded widget gesture yolları canonical 8×8 koordinatlarla statik olarak eşleşiyor.
- [x] Formatter adayı yalnız whitespace + Dart trailing-comma farkı taşıyor; ürün anlamı değişmedi.
- [x] Tek yetkili Actions run `33250841637` incelendi; failure'ın ürün logic değil formatter gate olduğu kanıtlandı.
- [x] QA-only entrypoint'in final scope'a yanlışlıkla girebilme riski tespit edildi; gelecek gate için allowlist şartı belirlendi.
- [ ] Gerçek `dart format --output=none --set-exit-if-changed` PASS.
- [ ] `dart analyze lib/word_hunt` PASS.
- [ ] Focused Word Hunt testleri PASS.
- [ ] Full `flutter test` PASS.
- [ ] `git diff --check` ve korunan alan scope gate PASS.
- [ ] Android 16 B1/B5/B8/B10 ilk viewportta 64/64 hücre görünürlüğü/okunabilirliği PASS.
- [ ] B5 >60 saniye soft-time PASS.
- [ ] Android 16 gerçek `ANKARA` ve ters `BAŞKENT` swipe PASS.
- [ ] Crash/ANR/am_crash taraması temiz.
- [ ] QA-only dosya/araçlar ürün commitinde yok.
- [ ] Temiz ürün commit SHA'sı yazılır.
- [ ] 8×8 PR ancak teknik gate sonrası açılır/güncellenir ve kullanıcı kabulü olmadan Ready yapılmaz.
- [ ] Levent ayrıca açık merge onayı verir.

**Kısıt:** Yeni GitHub Actions koşusu Levent yeniden açık izin vermeden başlatılmaz.

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
