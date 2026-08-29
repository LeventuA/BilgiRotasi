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

**Durum:** FORMAT/ANALYZE/TEST/APK PASS / ANDROID 16 GÖRSEL GATE ALTYAPI HATASI NEDENİYLE AÇIK.

- Kullanıcı tema seçimi: beş aday içinden **1. görsel**.
- Ana görsel yön: derin lacivert gece limanı + sıcak altın/amber deniz feneri ışığı.
- Clean branch: `feat/kelime-avi-baslangic-limani-theme-clean-v1-20260829`.
- Taban: doğrulanmış 8×8 docs HEAD `69efcd17606d339233e1d9ca6183d9ac37ed5b5c`.
- Formatter sonrası ürün commit: `a91236c9f734e9495e67de46ab6e078d429d681e` — `chore(kelime-avi): apply verified theme formatting [skip ci]`.
- Tema wrapper: `lib/word_hunt/baslangic_limani_theme_screen.dart`.
- Production flow varsayılan level açılışı `BaslangicLimaniThemedLevelScreen` üzerinden mevcut `WordHuntLevelProductionScreen`'e bağlandı.
- `lib/main.dart`, doğrulanmış production screen, 8×8 content, path/scoring, MASTER ART ve reklam/Firebase/release yapılandırması değişmedi.
- Tema branch'inde açık PR yok; Ready/merge yok.

Tema run geçmişi:
- `33260968009`: FAILURE — ilk one-shot gate formatter aşamasında durdu.
- `33274405539`: FAILURE — formatter/analyze/test/APK kapıları geçti; Android 16 scripti uygulama başlamadan shell altyapı hatasıyla durdu.

Run `33274405539` doğrulaması:
- [x] Formatter beklenen 3 dosyayı değiştirdi ve kapsam gate'i tuttu.
- [x] `dart analyze lib/word_hunt`: No issues.
- [x] Focused Word Hunt suite: **138/138 PASS**.
- [x] Full Flutter suite: **444/444 PASS**.
- [x] QA-only entrypoint analyze PASS.
- [x] B1 debug APK build PASS — SHA-256 `7bfa3369d07a1a3b0d7ff1b234144c645afd6dc3182206da96031b49966a93ea`.
- [x] B10 debug APK build PASS — SHA-256 `e0b4c46f1f82b6ea1f7e401ff482b876949a8ab9f88005a0651b99e452370b76`.
- [x] API 36 emülatör boot tamamlandı.
- [ ] B1 APK kurulumu: ÇALIŞMADI — script daha önce durdu.
- [ ] B10 APK kurulumu: ÇALIŞMADI — script daha önce durdu.
- [ ] Android 16 screenshot/UI XML/logcat: ÜRETİLMEDİ.

Kesin failure nedeni:
`reactivecircus/android-emulator-runner@v2` scripti `/usr/bin/sh` ile yürüttü; `set -euo pipefail` komutu `/usr/bin/sh: 1: set: Illegal option -o pipefail` hatası verdi. Bu ürün crash'i değildir; B1 APK kurulmadan önce oluşan QA script POSIX uyumsuzluğudur.

Artifact:
- `9721167449`
- `sha256:a90891532eaf3a279aa5935328529dc8bce712cd13a74069de5083d4f90bf1af`
- Screenshot/UI/logcat yok; analyze/test/formatter patch ve APK hash kanıtları var.

**Bitti ölçütü:**
- [x] Seçilen tema kod katmanı ayrı ve geri alınabilir dosyada oluşturuldu.
- [x] Overlay pointer eventlerini `IgnorePointer` ile engellemiyor.
- [x] Production gameplay flow varsayılan açılışı tema wrapper'a bağlandı.
- [x] Tema widget sözleşme testi yazıldı.
- [x] Rota → Bölüm 1 → tema → production ekran entegrasyon testi yazıldı.
- [x] Diff temiz: production base'e göre yalnız tema dosyaları/testleri + gameplay flow entegrasyonu ve proje hafıza kayıtları.
- [x] Gerçek Dart formatter/analyze PASS.
- [x] Tema testleri gerçek Flutter runner'da PASS.
- [x] B1/B10 debug APK build PASS.
- [x] Formatter farkı branch'e `[skip ci]` commit ile uygulandı; yeni Actions tetiklenmedi.
- [ ] Android QA scripti POSIX uyumlu hale getirilir (`set -eu`) veya açık Bash ile çalıştırılır.
- [ ] Yeni Actions run için kullanıcı izni/bütçe yeniden doğrulanır.
- [ ] Android 16 gerçek B1/B10 tema screenshotı alınır.
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
