# Bilgi Rotası - Açık Sorular ve Canlı Doğrulamalar

> 29 Ağustos 2026 aktif kesimidir. Eski tam kayıtlar Git geçmişi ve `docs/project-memory/archive/` altında korunur.

## Kelime Avı Başlangıç Limanı tema — TEST/APK PASS / ANDROID16 GÖRSEL DOĞRULAMA AÇIK

Kullanıcı beş özgün aday arasından **1. görseli** seçti: derin lacivert gece limanı + sıcak altın/amber deniz feneri ışığı. Tema Bölüm 1–10 ana görsel kimliğidir; MASTER ART rota ekranını değiştirmez.

Canlı clean theme çalışma:
- Branch: `feat/kelime-avi-baslangic-limani-theme-clean-v1-20260829`
- Taban: doğrulanmış 8×8 docs HEAD `69efcd17606d339233e1d9ca6183d9ac37ed5b5c`.
- Formatter sonrası ürün commit: `a91236c9f734e9495e67de46ab6e078d429d681e`.
- Tema wrapper: `lib/word_hunt/baslangic_limani_theme_screen.dart`.
- Production flow: `word_hunt_gameplay_flow.dart` varsayılan açılışı temalı wrapper'a yönlendirildi.
- Doğrulanmış `word_hunt_screens.dart`, 8×8 içerik, path/scoring, `lib/main.dart`, MASTER ART, AdMob/Firebase/signing değişmedi.
- Açık theme PR yok; Ready/merge yok.

Tema Actions geçmişi:
- `33260968009`: FAILURE — ilk one-shot gate formatter aşamasında durdu.
- `33274405539`: FAILURE — formatter/analyze/test/APK geçti; Android16 uygulama capture başlamadan QA script shell hatasıyla durdu.

İkinci run `33274405539` içinde doğrulananlar:
- formatter kapsamı doğru: yalnız 3 dosya değişti,
- `dart analyze lib/word_hunt`: **No issues found**,
- focused Word Hunt: **138/138 PASS**,
- full Flutter: **444/444 PASS**,
- QA-only entrypoint analyze: PASS,
- B1 debug APK: PASS — SHA-256 `7bfa3369d07a1a3b0d7ff1b234144c645afd6dc3182206da96031b49966a93ea`,
- B10 debug APK: PASS — SHA-256 `e0b4c46f1f82b6ea1f7e401ff482b876949a8ab9f88005a0651b99e452370b76`,
- API 36 emülatör boot: PASS.

Kesin Android16 blocker:
- `reactivecircus/android-emulator-runner@v2` scripti `/usr/bin/sh` ile çalıştı.
- Scriptin ilk satırı `set -euo pipefail` idi.
- `/usr/bin/sh` bunu desteklemedi ve `/usr/bin/sh: 1: set: Illegal option -o pipefail` ile çıktı.
- Hata **B1 APK kurulmadan önce** oluştu; uygulama launch edilmedi.
- Dolayısıyla screenshot/UI XML/logcat üretilmedi ve bu run tema runtime PASS sayılmaz.

Artifact:
- ID `9721167449`
- digest `sha256:a90891532eaf3a279aa5935328529dc8bce712cd13a74069de5083d4f90bf1af`
- 7 dosya: analyze, focused/full test logları, formatter patch, B1/B10 APK hashleri, gate HEAD.
- Android screenshot/UI/logcat yok.

Formatter patchindeki doğrulanmış üç dosyalık fark `a91236c9...` ile branch'e `[skip ci]` olarak uygulandı ve bu commit yeni Actions run tetiklemedi.

**DOĞRULANACAK:**
1. Android QA scripti `sh` uyumlu `set -eu` ile mi düzeltilecek, yoksa script açık Bash execution ile mi çalıştırılacak?
2. Yeni Actions koşusu için kullanıcı izni/bütçe ne zaman yeniden açılacak? Mevcut run rerun edilmeyecek.
3. Android 16 gerçek B1/B10 screenshotı seçilen 1. görselin lacivert + sıcak altın liman hissine yeterince yakın mı?
4. Fener/ışık dekoru sayaç, hedef chipleri, grid ve alt status metninin okunabilirliğini bozuyor mu?
5. Kullanıcı gerçek screenshotı görsel olarak kabul ediyor mu; kabul etmezse hangi renk/ışık yoğunluğu ayarlanacak?
6. Runtime görsel gate sonrası clean theme Draft PR açılacak mı?

---

## Kelime Avı Başlangıç Limanı 8×8 — TEKNİK PASS / KULLANICI KABULÜ AÇIK

29 Ağustos 2026 kullanıcı kararıyla starter-content grid standardı **8×8** oldu; önceki 6×10 geometrisi yeni ürün hattı için superseded edildi.

Canlı çalışma:
- Branch: `feat/kelime-avi-8x8-content-v1-20260829`
- Ürün commit: `052ea7da775db0b58a5ce0c6731a04f251879008`
- Draft PR: **#158** — OPEN / DRAFT / merged=false / mergeable=true.
- Base release: `release/final-closed-test-aab-1.68.8` / `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`.
- Sürüm: `1.68.19+109`.
- Eski PR #156 6×10 hattında OPEN/DRAFT kalır; otomatik kapatılmadı.

Teknik olarak doğrulandı:
- 10 adet 8×8 grid ve 80 toplam target+bonus.
- Her canonical kelime exactly-one physical straight-line occurrence.
- Intended/opposite canonical yol eşleşmeleri.
- B5/B10 yatay+dikey+çapraz yön aileleri.
- B8 `HIZ`+`SKOR`, B9 `ROKET` ve `AY` yok, B10 `YOL`+`HAZİNE` ve `ROTA` yok.
- Dart formatter PASS.
- `dart analyze lib/word_hunt`: No issues.
- Focused Word Hunt suite: **37/37 PASS**.
- Full Flutter suite: **442/442 PASS**.
- `git diff --check` + protected-scope gate PASS.
- QA-only entrypoint/helper dosyaları ürün commitine girmedi.

Final Android 16:
- Run `33251736068`: **SUCCESS**.
- API 36 / 1080×1920 / 420 dpi.
- B1/B5/B8/B10: ilk viewportta **64/64** hücre görünür ve okunabilir.
- B5 +65s soft-time: hard fail yok; 67–76s oynanabilir.
- ANKARA uzun çapraz gerçek swipe: `1/7`, `Bilgi kartı açıldı: Ankara`.
- BAŞKENT ters-dikey gerçek swipe: `1/7`, `BAŞKENT bulundu!`.
- Crash/ANR/FATAL/am_crash taraması temiz.
- Artifact `9714700778`; digest `sha256:dfbca264c2f67bb3549a0e336b075c9238f1a0638962dc69392ea8715b9a2092`.

İlk gate `33250841637` formatter kapısında durmuştu ve analyze/test/Android16 çalışmamıştı; ürün failure değildir. Final run `33251736068` teknik kabul kanıtıdır.

**DOĞRULANACAK — KALANLAR:**
1. Tema uygulanmış gerçek Android 16 8×8 görünümü/oynanışı kullanıcı tarafından kabul ediliyor mu?
2. B5 60 saniye ve B10 120 saniye challenge süreleri gerçek insan playtestinde dengeli mi?
3. Kullanıcı kabulünden sonra PR #158 Ready yapılacak mı?
4. PR #158 merge'i için Levent ayrıca açık merge onayı verecek mi?
5. Eski PR #156 ne zaman/kim tarafından kapatılacak? Otomatik kapatılmayacak.
6. Production `lib/main.dart` ana navigasyon entegrasyonu için ayrı kapsam/onay verilecek mi?

---

## Issue #109 / MASTER ART production — KAPANDI

- Issue #109 `Photo 1.jpg` tek bağlayıcı MASTER ART.
- Görsel ve `MASTER ART raster + şeffaf hitbox` mimari kabulü PASS.
- PR #147 merge SHA `d118aa98c5551cb3b4418f61047f6a730406d963`.

---

## Dynamic progression state — KAPANDI

- Gerçek `X / 30`, yıldız, locked/open state doğrulandı.
- Android 16 run `32969604847`: SUCCESS.
- PR #150 merge SHA `d64fcd4ea63f173c6653ff33926b12a6c99ef37d`.

---

## Kelime Avı production ana navigasyon entegrasyonu — AÇIK / AYRI KAPSAM

- `lib/main.dart` 8×8 starter-content/tema dönüşümünde değiştirilmedi.
- Gerçek uygulama girişine bağlama ayrı branch/PR ve açık onay ister.

---

## 1.68.19+109 release / Play / rewarded canlı kabul — AÇIK

- Aynı `gameId` ikinci +10 XP vermez — fiziksel canlı kabul.
- Yarım/başarısız rewarded reklamda XP yok; hak korunur ve yeniden denenebilir.
- Farklı tamamlanan oyunlarda toplam kota olmaması fiziksel kabul.
- Production +109 package/version/signing/AdMob/Firebase/Play doğrulamaları.

---

## Canlı Düello fiziksel kabulü — AÇIK

İki güncel Play cihazı ve iki ayrı hesapla eşleştirme, soru sırası, skor, sonuç, BR/lig, leaderboard ve kopma davranışı uçtan uca doğrulanacak.

---

## Soru geri bildirimleri — AÇIK

- Her soru metin + 4 seçenek + doğru indeks + açıklama + kategori + zorluk birlikte kontrol edilir.
- `assets/questions.json` kontrolsüz değiştirilmez.
- Gerçek düzeltme merge edilmeden Sheet satırı kapatılmaz.

---

## 3B tahta — DURDURULDU / KARAR BEKLİYOR

- BoardMap / 67 node düzenine dokunulmaz.
- Önce numaralı deterministik geometri.
- 8 konsept rozet / 6 fiziksel rozet eşlemesi çözülmeden ilerlenmez.

---

## Mağaza ve tanıtım — AÇIK

Telefon, tablet, Chromebook, PC ve XR varlıklarının Play Console durumu canlı ekrandan doğrulanacak.
