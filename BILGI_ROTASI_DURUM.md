# Bilgi Rotası – Proje Durumu

**Son güncelleme:** 29 Ağustos 2026

## Canlı Sürüm / Release Hattı

- Kanonik release branch: `release/final-closed-test-aab-1.68.8`
- Release HEAD: `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`
- Sürüm: **1.68.19+109**
- Paket: `com.leventua.bilgirotasi`
- `main` yayın kaynağı olarak varsayılmaz.

## Aktif İş — Kelime Avı Başlangıç Limanı 8×8

29 Ağustos 2026 kullanıcı kararıyla Başlangıç Limanı bölüm grid standardı **8 satır × 8 sütun** oldu. Önceki 6×10 geometrisi yeni ürün hattı için superseded; geçmiş kanıt olarak korunur.

- 8×8 içerik branch: `feat/kelime-avi-8x8-content-v1-20260829`
- Final temiz ürün commit: `052ea7da775db0b58a5ce0c6731a04f251879008`
- Commit adı: `feat(kelime-avi): switch starter levels to 8x8 [skip ci]`
- Draft PR: **#158** — `WIP feat(kelime-avi): Başlangıç Limanı 8x8 production content`
- PR #158: **OPEN / DRAFT / merged=false / mergeable=true**.
- Base: `release/final-closed-test-aab-1.68.8` / `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`.
- Eski PR #156 6×10 hattında OPEN/DRAFT kalır; otomatik kapatma/merge yapılmadı.
- Toplam canonical target+bonus: **80 kelime**.
- Yoğunluk: B1 6, B2 6, B3 7, B4 7, B5 8, B6 8, B7 9, B8 9, B9 10, B10 10.

## 8×8 Final Teknik Gate — PASS

Düzeltilmiş final run:

- Workflow gate commit: `4424285066568ddac874cfa35eb3bae1a62b3394`
- Run: `33251736068`
- Job: `99098467708`
- Sonuç: **SUCCESS**

Doğrulama:
- Dart formatter: PASS.
- `dart analyze lib/word_hunt`: **No issues found**.
- Focused Word Hunt suite: **37/37 PASS**.
- Full Flutter suite: **442/442 PASS**.
- `git diff --check`: PASS.
- Korunan scope gate: PASS.
- Isolated Android QA APK build: PASS.
- QA-only entrypoint/helper dosyaları ürün commitine girmedi.

İlk run `33250841637` yalnız formatter kapısında durmuştu; analyze/test/Android16 çalışmamıştı. Bu tarihsel failure ürün hatası değildi ve final PASS yerine kullanılmaz.

## Android 16 Fiziksel Kanıt — PASS

API 36 / 1080×1920 / 420 dpi:

- B1: **64/64** hücre ilk viewportta görünür, sayaç `0/5`.
- B5: **64/64** hücre görünür, sayaç `0/7`.
- B8: **64/64** hücre görünür, sayaç `0/7`.
- B10: **64/64** hücre görünür, sayaç `0/9`.
- B5 sentetik +65 saniye sonrası hard fail yok; 67–76 saniyede oynanabilir.
- Uzun çapraz `ANKARA` gerçek swipe: `1/7`, `Bilgi kartı açıldı: Ankara`.
- Ters-dikey `BAŞKENT` gerçek swipe: `1/7`, `BAŞKENT bulundu!`.
- `FATAL EXCEPTION`, uygulama ANR veya `am_crash` eşleşmesi yok.

Artifact:
- ID `9714700778`
- Digest `sha256:dfbca264c2f67bb3549a0e336b075c9238f1a0638962dc69392ea8715b9a2092`
- QA APK SHA-256 `d07a68b5f9735f574e8e608afbd4c20d4c1f7cc0c775d5d9f8d0010dfd32c07b`
- Payload decoded SHA-256 `7e4955d6f2545039eafb3e476e5537385ee3d3b359b67be0f886b027ea95be54`

Artifact ekran görüntüleri görsel olarak ayrıca incelendi; B1/B5/B8/B10 8×8 gridleri aynı ekranda okunabilir, ANKARA ve BAŞKENT seçimleri doğru hücreleri boyuyor.

## Aktif Tema Çalışması — Başlangıç Limanı Gece Limanı / Deniz Feneri

Kullanıcı beş özgün aday arasından ilk görseli seçti. Bölüm 1–10 için ana tema yönü **derin lacivert gece limanı + sıcak altın/amber deniz feneri ışığı** olarak sabitlendi. MASTER ART rota ekranı bu kararla değişmez; tema yalnız bölüm içi Kelime Avı ekranına uygulanır.

- Aktif clean theme branch: `feat/kelime-avi-baslangic-limani-theme-clean-v1-20260829`
- Branch tabanı: 8×8 doğrulanmış docs HEAD `69efcd17606d339233e1d9ca6183d9ac37ed5b5c`.
- Formatter sonrası ürün HEAD: `a91236c9f734e9495e67de46ab6e078d429d681e`.
- Formatter commit: `chore(kelime-avi): apply verified theme formatting [skip ci]`.
- Tema katmanı: `lib/word_hunt/baslangic_limani_theme_screen.dart`.
- Production flow çağrı noktası: `lib/word_hunt/word_hunt_gameplay_flow.dart`; varsayılan level açılışı temalı wrapper'a yönlendirildi.
- Mevcut doğrulanmış `lib/word_hunt/word_hunt_screens.dart`, path/scoring, 8×8 içerik ve `lib/main.dart` değiştirilmedi.
- Tema wrapper'ı mevcut `WordHuntLevelProductionScreen`'i kullanır; overlay `IgnorePointer` olduğu için gesture hit-testing'i ele geçirmez.
- Tema branch'i için açık PR yok; Ready/merge yok.

### Tema teknik gate kanıtı

Tema branch'inde iki Actions run vardır:

1. `33260968009` — FAILURE. İlk one-shot gate formatter aşamasında durdu; runtime kanıtı değildir.
2. `33274405539` — FAILURE. Ancak failure ürün/runtime değil, Android QA script shell altyapısındadır.

İkinci run `33274405539` içinde Android aşamasından önce doğrulananlar:
- `dart format`: beklenen 3 dosyayı değiştirdi; kapsam gate'i doğru çalıştı.
- `dart analyze lib/word_hunt`: **No issues found**.
- Focused Word Hunt suite: **138/138 PASS**.
- Full Flutter suite: **444/444 PASS**.
- QA-only entrypoint analyze: PASS.
- B1 debug APK build: PASS — SHA-256 `7bfa3369d07a1a3b0d7ff1b234144c645afd6dc3182206da96031b49966a93ea`.
- B10 debug APK build: PASS — SHA-256 `e0b4c46f1f82b6ea1f7e401ff482b876949a8ab9f88005a0651b99e452370b76`.
- Gate HEAD: `f3447be9094046cd8c4cb4f7d1f1523ab35cec48`.

Android 16 emülatörü API 36 olarak başarıyla boot etti. Ardından `reactivecircus/android-emulator-runner@v2` scripti `/usr/bin/sh` ile çalıştırdığı için ilk komut `set -euo pipefail` üzerinde `/usr/bin/sh: 1: set: Illegal option -o pipefail` hatası oluştu. Bu hata **B1 APK kurulmadan önce** meydana geldi. Bu nedenle tema için Android screenshot/UI XML/logcat üretilemedi ve gerçek tema runtime görünümü hâlâ **DOĞRULANACAK**.

Run `33274405539` artifact:
- ID `9721167449`
- Digest `sha256:a90891532eaf3a279aa5935328529dc8bce712cd13a74069de5083d4f90bf1af`
- İçerik: analyze/test logları, formatter patch, B1/B10 APK hashleri ve gate HEAD; screenshot/UI/logcat yok.

Formatter artifactindeki doğrulanmış üç dosyalık fark branch'e `a91236c9...` commit'iyle uygulandı. Bu `[skip ci]` commit yeni Actions run tetiklemedi.

## Korunan Alanlar

Tema çalışmasında değiştirilmedi:
- `lib/main.dart`
- `pubspec.yaml`
- `assets/questions.json`
- `assets/word_hunt`
- `lib/word_hunt/word_hunt_screens.dart`
- `lib/word_hunt/word_hunt_path.dart`
- `lib/word_hunt/word_hunt_models.dart`
- MASTER ART / route geometry / BoardMap / 67 node
- AdMob / Firebase / Android release-signing
- package name / version

## Kalan Gerçek Kapılar

1. Tema Android 16 gate scriptinde POSIX uyumsuz `set -euo pipefail` kullanılmamalı; `sh` uyumlu `set -eu` veya açık Bash execution kullanılmalı.
2. Yeni Actions koşusu açılmadan önce izin/bütçe yeniden doğrulanmalı; mevcut iki başarısız run rerun edilmez.
3. Gerçek Android 16'da B1 ve B10 tema ekran görüntüsü/UI/logcat alınmalı.
4. Kullanıcı seçilen gece-limanı/deniz-feneri görünümünün yakınlığını ve okunabilirliğini görsel olarak onaylamalı.
5. Tema sonrasında B5 ve B10 sürelerinin gerçek insan playtest dengesi.
6. PR #158 ve tema hattı kullanıcı kabulünden önce Ready yapılmaz.
7. Merge yalnız Levent'in ayrıca açık merge onayıyla yapılır.
8. `lib/main.dart` production ana navigasyon entegrasyonu ayrı kapsam/onaydır.

## Kanonik Devir Dosyası

Ayrıntılı geçmiş ve sonraki sıra:
`docs/project-memory/GENEL_PROJE_OZETI.md`
