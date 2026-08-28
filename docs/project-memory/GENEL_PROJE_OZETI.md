# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 28 Ağustos 2026 — Kelime Avı Başlangıç Limanı 6×10 ürün kodu, normal PR CI ve Android 16 gerçek runtime/gesture QA kapıları PASS. Final QA run `33202898863` üzerinde source gate + B1 + B5 + B8 + B10 tamamı SUCCESS oldu. B5'te gerçek `adb input swipe` ile uzun çapraz `ANKARA` ve ters-dikey `BAŞKENT` seçimleri gerçek Android 16 emülatörde doğrulandı; scroll sonrası sayaç tekrar görünür alana alındığında her iki temiz açılışta da `1/7` doğrulandı. Ürün kaynaklı crash/ANR yok. Teknik Android 16 checkpointi kapandı; sıradaki kapı kullanıcı görsel/oynanış kabulü ve B5/B10 insan süre dengesi playtestidir. PR #156 DRAFT kalır; kullanıcı onayı olmadan Ready/merge yok.

> Teknik doğrulukta tek kanonik kaynak canlı `ZMilaStudio/BilgiRotasi` deposu ve ilgili canlı servislerdir. Bu dosya canlı branch/PR/CI/pubspec doğrulamasının yerine geçmez.

## Kalıcı çalışma kuralı

- Yeni sohbet başında önce bu dosya okunur.
- Ardından ilgili Kelime Avı checkpoint dosyaları ve gerekiyorsa `BILGI_ROTASI_DURUM.md`, `KARARLAR.md`, `GOREV_HAVUZU.md`, `ACIK_SORULAR_VE_DOGRULAMALAR.md` okunur.
- Her substantive sohbet mesajından sonra bu dosya güncellenir.
- Her görev öncesi canlı hedef branch, son commit, ilgili PR ve CI yeniden doğrulanır.
- Doğrudan `main` veya release dalına kod yazılmaz; branch/PR kullanılır.
- Kritik merge için Levent'in açık onayı gerekir.
- Build/CI PASS tek başına görsel veya ürün kabulü değildir.
- 28 Ağustos 2026 kontrolünde canlı repo/feature branch üzerinde `KARARLAR.md`, `GOREV_HAVUZU.md` ve `ACIK_SORULAR_VE_DOGRULAMALAR.md` bulunamadı: **DOĞRULANACAK**. Dosya adları/taslak uploadlar canlı GitHub kaynağı yerine geçirilmeyecek.

## Canlı release hattı

- Repo: `ZMilaStudio/BilgiRotasi`
- Kanonik release: `release/final-closed-test-aab-1.68.8`
- Release HEAD: `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`
- Sürüm: `1.68.19+109`
- Paket: `com.leventua.bilgirotasi`
- `main` yayın kaynağı olarak varsayılmaz.
- PR #155 production Bölüm 1 gameplay merge edildi; merge commit `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`.

## Başlangıç Limanı bağlayıcı görsel/mimari

`MASTER ART RASTER → TRANSPARENT INTERACTION HITBOXES → MINIMUM LOCAL STATE OVERRIDES`

- Issue #109 `Photo 1.jpg` bağlayıcı görsel kaynak.
- Repo MASTER ART: `assets/word_hunt/baslangic_limani_master_art_visual_proof.jpg`.
- PR #146 / eski ChatGPT-generated hedef asset'ler görsel kaynak değildir.
- Route progression: 7 tamamlanınca 8+9 açılır; bonus 8 gate değildir; 10 node 9 tamamlanmadan locked/no-callback kalır.

## Bölüm 1 production gameplay — TAMAMLANDI

- Eski product head: `4edd4090862bbbdcc8e7422b913fae7d7d758540`.
- Android 16 production QA accepted: run `33113510959`, 126/126 PASS.
- PR #155 merge edildi ve release'e girdi.

## AKTİF ÜRÜN KARARI — Başlangıç Limanı 6×10 redesign

28 Ağustos 2026 kullanıcı onayıyla eski 6×6 / 3→6 kelimelik plan supersede edildi.

Canonical grid:
- **10 satır × 6 sütun** (`rowCount=10`, `columnCount=6`).

Canonical toplam kelime eğrisi target + bonus dahil:
- B1 = 6 (`5 target + 1 bonus`)
- B2 = 6 (`5 + 1`)
- B3 = 7 (`6 + 1`)
- B4 = 7 (`6 + 1`)
- B5 = 8 (`7 + 1`)
- B6 = 8 (`7 + 1`)
- B7 = 9 (`8 + 1`)
- B8 Bonus Durak = 9 (`7 target + 2 bonus`)
- B9 = 10 (`9 + 1`)
- B10 Final = 10 (`9 + 1`)

Toplam canonical target/bonus: **80 kelime**.

Content kuralları:
- Her target/bonus en az 3 harf.
- Her target/bonus 8 düz yönde **exactly 1 physical occurrence** taşımalı.
- Intended path ve opposite gesture gerçek `WordHuntPathEngine` üzerinden aynı canonical kelimeye dönmeli.
- Zorluk kelime sayısı, kesişim, diagonal/vertical/reverse yönler ve daha uzun kelimelerle artar.
- B9 `AY` geri dönmez; `ROKET` bonus korunur.
- B10 `ROTA` geri dönmez; `YOL` korunur.

## PR #156 — AKTİF / DRAFT / WIP

- URL: `https://github.com/ZMilaStudio/BilgiRotasi/pull/156`
- Base: `release/final-closed-test-aab-1.68.8`
- Base SHA: `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`
- Head branch: `feat/kelime-avi-content-pass-v1-20260828`
- 6×10 starter-content temel commit: `aee37c0b169b0acc72a9036e15d914412b826ae4`
- Doğrulanmış gameplay/UI ürün commit: `8d431826585eb6c52248e85bb3ac2e80fc89bb9f` — `feat(kelime-avi): support 6x10 gameplay and bonus finish UX`.
- Android 16 QA başlamadan önce doğrulanan PR head: `ef9c61939ae8312a8d4aa07648271b59ae82d1b7`.
- PR canlı durum son kontrolde: **OPEN / DRAFT / mergeable=true / merged=false**.
- **Merge yok.** PR Draft/WIP kalır; kullanıcı görsel/oynanış onayı olmadan Ready/merge yapılmaz.
- 10 yeni 6×10 grid ve toplam 80 canonical target/bonus exactly-one occurrence sözleşmesi testlerle korunuyor.

## 6×10 gameplay/UI + bonus/soft-time — UYGULANDI / DOĞRULANDI

Ürün commit `8d431826585eb6c52248e85bb3ac2e80fc89bb9f` ile:
- production ve prototype grid `columnCount / rowCount` oranında rectangular render olur,
- hit-testing row/column sayısına göre dinamik çalışır,
- 6×10 canonical gesture/test yolları gerçek gridlerle hizalandı,
- son ana targetta elapsed + mistake snapshot donar,
- grid bonus aramak için açık kalır,
- bonus completion için zorunlu değildir,
- targetlar bittikten sonraki yanlış bonus araması kazanılmış yıldızı düşürmez,
- sonuç yalnız `Bölümü Tamamla` ile açılır,
- `timeLimitSeconds` hard fail değil **soft challenge** olarak davranır.

Doğrulama:
- Geçici doğrulama workflow run `33180924115`: **SUCCESS**.
- Word Hunt suite: **136/136 PASS**.
- `dart analyze lib/word_hunt`: **PASS / No issues**.
- `git diff --check`: **PASS**.
- Ürün commit atıldı ve geçici `.github/workflows/tmp-kelime-6x10-screen-patch.yml` ile `tools/tmp_kelime_6x10_screen_patch.py` aynı committe kaldırıldı.
- Ara run `33179048605` de aynı ürün patchinde 136/136 + analyze + diff-check PASS vermiş, yalnız geçici dosyayı `git rm` ile silme adımında durmuştu; run `33180924115` bu taşıma/temizlik adımını başarıyla tamamladı.

## PR CI + Android 16 gerçek production QA

- PR head hattında normal PR CI iki ana gate PASS:
  - `Kelime Avı Android 16 görsel kanıtı` run `33185702627`: **SUCCESS**.
  - `AdMob PR doğrulaması` run `33185702636`: **SUCCESS**.
- Standart görsel kanıt MASTER ART/route regresyonunu doğrular; 6×10 gerçek level gameplay kabulü sayılmaz.
- Gerçek 6×10 production runtime kanıtı için ayrı ve **merge edilmeyecek** QA branch: `qa/kelime-avi-6x10-runtime-android16-20260828`.
- QA branch izole entrypoint `lib/word_hunt/word_hunt_android16_qa_main.dart` üzerinden gerçek `WordHuntLevelProductionScreen` kullanır; `lib/main.dart` değişmez.
- QA workflow: `.github/workflows/qa-word-hunt-6x10-android16.yml`.

### Android 16 QA deneme 1

- Run `33185224461`, QA head `333662783546d8adde4282960b1803d6c8f6e368`: **FAILURE**.
- `QA source gate` PASS ve B1/B5/B8/B10 izole APK buildleri PASS.
- Capture script `/usr/bin/sh` altında `set -euo pipefail` nedeniyle uygulama install/launch öncesi durdu.
- Bu run ürün crash/layout sonucu değildir.

### Android 16 QA deneme 2

- QA-only shell düzeltmesi commit `e46a84f42c2d07fa244f5057be7360da12c92f3f`: `set -eu`.
- Run `33199050082`: genel sonuç **FAILURE**.
- Dört gerçek artifact bundle üretildi, uygulamalar açıldı ve screenshot/log/UI capture alındı.
- Failure ürün kaynaklı değildi: emulator-runner script satırlarını ayrı `/usr/bin/sh -c` çağrılarıyla çalıştırdığı için çok satırlı crash-scan `if/then/fi` bloğu syntax error verdi.

### Android 16 QA deneme 3 — temiz runtime PASS

- QA-only commit `68f2f5e87b821be5e36aca510e998e79198eb1cd` — `ci(qa): make crash scan runner-safe`.
- Run `33201090483`: **SUCCESS**.
- `QA source gate`: SUCCESS.
- B1/B5/B8/B10 runtime joblarının tamamı SUCCESS.
- B5 +65 saniye sentetik clock offset ile hard fail olmadan oynanabilir kaldı; soft-time davranışı gerçek Android 16 zincirinde doğrulandı.
- 1080×1920 / 420 dpi screenshotlarda 6 sütun okunaklı ve hedef etiketlerinde taşma yok; 10 satır ilk viewporta tamamen sığmıyor fakat gerçek `ScrollView` ile erişiliyor.

### Android 16 QA deneme 4 — gesture false-negative teşhisi

- QA-only commit `ef95cdcca8d39638da9d6b8aa2d621b507a16c8d` — `test(qa): prove long B5 swipes on Android16`.
- Run `33201994740`: genel **FAILURE**, fakat B1/B8/B10 SUCCESS.
- B5 ilk gerçek uzun çapraz swipe sırasında `ANKARA` başarıyla bulundu; artifact screenshotında altı hücre yeşil ve `Bilgi kartı açıldı: Ankara` görüldü.
- Job yalnız `1/7` sayacını aynı kaydırılmış viewportta aradığı için false-negative verdi; sayaç scroll ile görünür alan dışına çıkmıştı.
- Ürün yaması yapılmadı; QA doğrulaması düzeltildi.

### Android 16 QA deneme 5 — FINAL TEKNİK CHECKPOINT PASS

- QA-only commit `e12b99513ea6235e857f7c855006e6d1abb2080e` — `test(qa): verify B5 swipe progress after scroll`.
- Run `33202898863`: **SUCCESS**.
- `QA source gate` + B1 + B5 + B8 + B10: **tamamı SUCCESS**.
- Final artifactler exact QA head `e12b99513ea6235e857f7c855006e6d1abb2080e`:
  - B1 artifact `9698756485`, digest `sha256:3b61cb53f341fd0bd2da64534ccc9ab40a7ded624a9b8e6bd6f131a926ab65d9`.
  - B5 artifact `9698763595`, digest `sha256:51d433b506098cf9ee80bc1e533fa28270e8f5aaa518fdf52fd53d000508f2fe`.
  - B8 artifact `9698747021`, digest `sha256:40b2dfaa1c3302ea0df9aadf2d7a3440c1d285de2144e83b4d04266d54c2868f`.
  - B10 artifact `9698699535`, digest `sha256:85deed6965a4a36c6a0cfa728a38f2d8a95fc8f9f5d8e16a0b5031562214da7d`.
- B5 gerçek cihaz/emülatör kanıtı:
  - Physical size `1080x1920`, density `420`.
  - Config marker: `level=5 rows=10 cols=6 targets=7 bonus=1 timeOffset=65`.
  - Ready marker iki temiz açılışta da mevcut.
  - Crash/ANR/am_crash eşleşmesi yok.
  - Uzun çapraz `ANKARA`: gerçek `adb input swipe`; altı fiziksel hücre yeşil; `Bilgi kartı açıldı: Ankara`; viewport üste döndürülünce `1/7`, `0 hata`.
  - Ters-dikey `BAŞKENT`: ayrı temiz app launch; gerçek `adb input swipe`; yedi fiziksel hücre yeşil; `BAŞKENT bulundu!`; viewport üste döndürülünce `1/7`, `0 hata`.
- Sonuç: **6×10 rectangular geometry + ScrollView erişimi + uzun diagonal + uzun reverse vertical gesture + B5 soft-time Android 16 teknik checkpointi PASS.**
- Bu PASS kullanıcı görsel zevk/onayı veya insan zorluk dengesi onayı değildir.

## Korunan alanlar

Açık kapsam olmadan değişmez:
- `lib/main.dart`
- `assets/questions.json`
- BoardMap / 67 node / 3B tahta
- MASTER ART bytes ve kabul edilmiş route art mimarisi
- AdMob / Firebase / Android release/signing config
- package name
- `version: 1.68.19+109`

## Sıradaki aktif sıra — YENİ SOHBET BURADAN DEVAM ETSİN

1. Canlı feature branch/PR/CI durumunu tekrar doğrula; PR #156 **Draft** kalır, merge/Ready yapma.
2. Android 16 teknik 6×10 runtime/gesture checkpointi tamamlandı; tekrar aynı QA'yı körlemesine çalıştırma.
3. Kullanıcıya B1/B5/B8/B10 gerçek Android 16 görünümünü ve özellikle B5 gesture kanıtını göstererek **görsel/oynanış kabulü** al.
4. B5 ve B10 challenge süreleri için gerçek insan playtesti yap; teknik soft-time PASS ile zorluk dengesini birbirine karıştırma.
5. Mevcut widget sözleşmesinde bonus-after-target + frozen score + `Bölümü Tamamla` sonucu PASS. Kullanıcı/gerçek cihazda yeni belirti çıkmadıkça sırf kanıt çoğaltmak için yeni QA harness üretme.
6. Kullanıcı 6×10 telefonda kullanılabilir değil derse yalnız ürün branch'inde dar layout/gesture erişilebilirliği düzeltmesi yap; content standardını geri alma.
7. Kullanıcı görsel/oynanış kabulünden sonra PR #156 Ready kararı verilebilir.
8. Merge ancak Levent'in açık merge onayıyla release branch'e yapılır.

Diğer Bilgi Rotası açık işleri diğer project-memory dosyalarında korunur; bu özet onları silmez.
