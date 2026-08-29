# Bilgi Rotası – Proje Durumu

**Son güncelleme:** 30 Ağustos 2026

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
- Doğrulanmış formatter ürün SHA: `a91236c9f734e9495e67de46ab6e078d429d681e`.
- Tema katmanı: `lib/word_hunt/baslangic_limani_theme_screen.dart`.
- Production flow çağrı noktası: `lib/word_hunt/word_hunt_gameplay_flow.dart`; varsayılan level açılışı temalı wrapper'a yönlendirildi.
- Mevcut doğrulanmış `lib/word_hunt/word_hunt_screens.dart`, path/scoring, 8×8 içerik ve `lib/main.dart` değiştirilmedi.
- Tema wrapper'ı mevcut `WordHuntLevelProductionScreen`'i kullanır; overlay `IgnorePointer` olduğu için gesture hit-testing'i ele geçirmez.
- Tema branch'i için açık PR yok; Ready/merge yok.

### Tema teknik gate kanıtı

Tema branch'inde **3 Actions run** vardır:

1. `33260968009` — FAILURE. İlk one-shot gate formatter aşamasında durdu; runtime kanıtı değildir.
2. `33274405539` — FAILURE. Formatter/analyze/test/APK kapıları geçti; Android QA scripti `/usr/bin/sh` altında `set -euo pipefail` nedeniyle B1 kurulmadan önce durdu.
3. `33277364738` — FAILURE. Formatter artık **0 değişiklik**, analyze ve iki odak tema testi PASS, B1/B10 APK build PASS, API 36 emulator boot PASS. Ancak `android-emulator-runner@v2` çok satırlı `script:` içeriğini satır satır `/usr/bin/sh -c` ile yürüttüğü için `bash <<'BASH'` satırı ayrı, sonraki `set -euo pipefail` satırı yine ayrı `sh` komutu oldu. Hata yine **B1 APK kurulmadan önce** oluştu.

Run `33277364738` gerçek kanıtı:
- `dart format --set-exit-if-changed`: **4 dosya / 0 changed PASS**.
- `dart analyze lib/word_hunt`: **No issues found**.
- Tema widget + production-flow testleri: **2/2 PASS**.
- QA-only entrypoint analyze: PASS.
- B1 debug APK build: PASS.
- B10 debug APK build: PASS.
- KVM: PASS.
- Android 16 / API 36 emulator boot: PASS; 1080×1920 / 420 dpi yapılandırması hazırlandı.
- Uygulama launch/capture: ÇALIŞMADI; script runner semantiği nedeniyle B1 kurulmadan önce kesildi.
- Screenshot/UI XML/logcat: ÜRETİLMEDİ.

Run `33277364738` artifact:
- ID `9722014382`
- Digest `sha256:0daf6164323008f0d947febe77af00ff82fd94166d54b534d810e1644f42fd28`
- Runtime screenshot/UI/logcat yok; 5 adet analyze/test/APK hash/head kanıt dosyası var.

### Hazır v4 Android görsel gate — RUN BAŞLATILMADI

Run3 sonrası kalıcı düzeltme hazırlandı:
- Workflow: `.github/workflows/tmp-kelime-theme-android16-gate-v4.yml`
- Hazırlama commit: `bfa10d3617d9a104f71ce78b86e39754f55e22ea`
- Commit adı: `ci(kelime-avi): prepare Android16 visual gate v4 [skip ci]`
- Trigger: **yalnız `workflow_dispatch`**; dosyanın eklenmesi yeni Actions run başlatmadı.
- Android komutları önce normal `shell: bash` adımında `/tmp/theme_android16_proof.sh` dosyasına yazılıyor ve `bash -n` ile denetleniyor.
- `android-emulator-runner` içindeki `script:` artık tek satır: `bash /tmp/theme_android16_proof.sh`.
- Böylece action'ın satır satır `/usr/bin/sh -c` yürütme davranışı Bash script içeriğini parçalayamıyor.
- V4 henüz çalıştırılmadı; runtime tema görünümü hâlâ **DOĞRULANACAK**.

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

1. Hazır v4 `workflow_dispatch` gate için yeni Actions izni/bütçe doğrulanmalı; mevcut 3 failure run rerun edilmez.
2. V4 ile gerçek Android 16 B1 ve B10 tema screenshot/UI XML/logcat alınmalı.
3. Kullanıcı seçilen gece-limanı/deniz-feneri görünümünün yakınlığını ve okunabilirliğini görsel olarak onaylamalı.
4. Tema sonrasında B5 ve B10 sürelerinin gerçek insan playtest dengesi.
5. PR #158 ve tema hattı kullanıcı kabulünden önce Ready yapılmaz.
6. Merge yalnız Levent'in ayrıca açık merge onayıyla yapılır.
7. `lib/main.dart` production ana navigasyon entegrasyonu ayrı kapsam/onaydır.

## Kanonik Devir Dosyası

Ayrıntılı geçmiş ve sonraki sıra:
`docs/project-memory/GENEL_PROJE_OZETI.md`
