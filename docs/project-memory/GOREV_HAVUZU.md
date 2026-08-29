# Bilgi Rotası - Görev Havuzu

> 30 Ağustos 2026 aktif kesimidir. Eski tam görev kayıtları Git geçmişi ve `docs/project-memory/archive/` altında korunur. Teknik gerçek her zaman canlı GitHub ve ilgili canlı servislerdir.

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

`lib/main.dart` 8×8 starter-content/tema kapsamı değildir.

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
- Draft PR #158: OPEN / DRAFT / merged=false.
- Final gate run `33251736068`: **SUCCESS**.
- Artifact `9714700778` / `sha256:dfbca264c2f67bb3549a0e336b075c9238f1a0638962dc69392ea8715b9a2092`.

**Bitti ölçütü:**
- [x] 10 bölümün tüm gridleri 8×8 üretildi.
- [x] 80 toplam target+bonus kelime eğrisi korundu.
- [x] Her target/bonus exactly-one physical straight-line occurrence statik denetimden geçti.
- [x] Intended/reverse canonical yol eşleşmeleri doğrulandı.
- [x] B5/B10 yön aileleri ve B8/B9/B10 özel kelime sözleşmeleri korundu.
- [x] Dart formatter/analyze PASS.
- [x] Focused Word Hunt **37/37**, full Flutter **442/442 PASS**.
- [x] Protected-scope + diff gate PASS.
- [x] Android16 B1/B5/B8/B10 **64/64** görünürlük PASS.
- [x] B5 soft-time + ANKARA + ters BAŞKENT gerçek swipe PASS.
- [x] Crash/ANR/FATAL taraması temiz.
- [x] Temiz ürün commit ve Draft PR #158 oluşturuldu.
- [ ] B5/B10 gerçek insan süre dengesi playtesti.
- [ ] Levent gerçek 8×8/tema görünümünü kabul eder.
- [ ] Kullanıcı kabulünden sonra ayrıca Ready kararı verilir.
- [ ] Levent ayrıca açık merge onayı verir.

---

## 0Y - Başlangıç Limanı gece-limanı / deniz-feneri tema uygulaması

**Durum:** TEKNİK RUNTIME GATE PASS / KULLANICI GÖRSEL KABULÜ BEKLENİYOR.

- Kullanıcı tema seçimi: beş aday içinden **1. görsel**.
- Ana yön: derin lacivert gece limanı + sıcak altın/amber deniz feneri ışığı.
- Branch: `feat/kelime-avi-baslangic-limani-theme-clean-v1-20260829`.
- Doğrulanmış tema ürün SHA: `a91236c9f734e9495e67de46ab6e078d429d681e`.
- Tema wrapper: `lib/word_hunt/baslangic_limani_theme_screen.dart`.
- Production flow temalı wrapper üzerinden mevcut `WordHuntLevelProductionScreen`'i açar.
- `lib/main.dart`, production screen, 8×8 içerik, path/scoring, MASTER ART ve reklam/Firebase/release yapılandırması değişmedi.
- Açık theme PR yok; Ready/merge yok.

Tarihsel tema runları:
- `33260968009`: formatter aşamasında FAILURE.
- `33274405539`: Android runner `/usr/bin/sh` pipefail altyapı FAILURE.
- `33277364738`: heredoc satır-satır `sh -c` altyapı FAILURE.
Bu üç run ürün runtime failure sayılmaz.

Final V4 gate:
- Run `33278797412`: **SUCCESS**.
- Job `99170289209`.
- Gate/trigger SHA `4671a3989155b801c9da6b7d0ec7a7e1a545d465`.
- Artifact `9722440135` / `sha256:bf91d7591b4348b3268983f9938a9042631729b8ad7a126c27e6ba35504f3a70`.

**Bitti ölçütü:**
- [x] Tema katmanı ayrı ve geri alınabilir dosyada oluşturuldu.
- [x] Overlay `IgnorePointer`; gameplay pointer akışını engellemiyor.
- [x] Production gameplay flow temalı wrapper'a bağlandı.
- [x] Tema widget ve rota→tema→production flow testleri yazıldı.
- [x] Korunan ürün alanları değişmedi.
- [x] Formatter **0 diff**.
- [x] `dart analyze lib/word_hunt`: No issues.
- [x] Tema testleri **2/2 PASS**.
- [x] QA-only entrypoint analyze PASS.
- [x] B1/B10 debug APK build PASS.
- [x] API36 emulator / KVM PASS.
- [x] Android runner tek-komut Bash çözümü PASS.
- [x] B1 APK install + launch PASS.
- [x] B10 APK install + launch PASS.
- [x] B1/B10 screenshot + UI XML + logcat üretildi.
- [x] B1 **64/64**, `0/5`, `0 hata`; B10 **64/64**, `0/9`, `0 hata`.
- [x] Crash/ANR/FATAL/am_crash taraması temiz.
- [x] V4 geçici workflow `[skip ci]` ile kaldırıldı.
- [ ] Levent gerçek screenshotların seçilen tema görseline yeterince yakınlığını kabul eder.
- [ ] Gerekirse yalnız tema atmosferi/ışık yoğunluğu screenshot üzerinden güçlendirilir; grid/oyun mantığına dokunulmaz.
- [ ] Görsel kabulden sonra clean theme Draft PR açılır.
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
