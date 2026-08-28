# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 28 Ağustos 2026 — Kelime Avı 6×10 ürün kodu ve normal PR CI PASS; Android 16 runtime QA shell sorunu QA-only branch'te düzeltildi ve ikinci B1/B5/B8/B10 matrix koşusu başladı.

> Teknik doğrulukta tek kanonik kaynak canlı `ZMilaStudio/BilgiRotasi` deposu ve ilgili canlı servislerdir. Bu dosya canlı branch/PR/CI/pubspec doğrulamasının yerine geçmez.

## Kalıcı çalışma kuralı

- Yeni sohbet başında önce bu dosya okunur.
- Ardından ilgili Kelime Avı checkpoint dosyaları ve gerekiyorsa `BILGI_ROTASI_DURUM.md`, `KARARLAR.md`, `GOREV_HAVUZU.md`, `ACIK_SORULAR_VE_DOGRULAMALAR.md` okunur.
- Her substantive sohbet mesajından sonra bu dosya güncellenir.
- Her görev öncesi canlı hedef branch, son commit, ilgili PR ve CI yeniden doğrulanır.
- Doğrudan `main` veya release dalına kod yazılmaz; branch/PR kullanılır.
- Kritik merge için Levent'in açık onayı gerekir.
- Build/CI PASS tek başına görsel veya ürün kabulü değildir.

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
- Bu özet güncellemesinden hemen önce canlı PR head: `5f68d28cf402bd100310839493a8a03e978c9e98`; bu özet commit'i branch head'ini ayrıca ilerletir.
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
- İlk QA run `33185224461`, QA head `333662783546d8adde4282960b1803d6c8f6e368`: **FAILURE**; ürün kaynaklı değil QA shell uyumsuzluğuydu.
- İlk run'da `QA source gate` PASS ve B1/B5/B8/B10 izole APK buildleri PASS; capture script `/usr/bin/sh` altında `set -euo pipefail` yüzünden uygulama install/launch öncesi durdu.
- QA-only shell düzeltmesi commit `e46a84f42c2d07fa244f5057be7360da12c92f3f`: emulator-runner script'i POSIX uyumlu `set -eu` kullanıyor; ürün branch'i değiştirilmedi.
- İkinci QA run `33199050082` bu exact QA head üzerinde başladı.
- İkinci run `QA source gate`: **SUCCESS**.
- B1/B5/B8/B10 Android16 runtime matrix işleri aynı anda başladı; son canlı kontrolde dört job da izole QA APK build aşamasındaydı.
- B5 için 65 saniyelik sentetik clock offset korunur; hard fail olmadan oynanabilirlik ve soft-time davranışı capture aşamasında doğrulanacak.
- Matrix tamamlandığında gerçek screenshot/log/UI artifacts görsel olarak incelenecek: 10×6 grid yüksekliği, taşma/kaydırma, hücre okunabilirliği, uzun vertical/diagonal gesture kullanılabilirliği ve B5 soft-time.
- B5/B10 süre eşikleri teknik olarak uygulanmış olsa da gerçek insan zorluk dengesi Android playtest ile ayrıca değerlendirilmelidir.

## Korunan alanlar

Açık kapsam olmadan değişmez:
- `lib/main.dart`
- `assets/questions.json`
- BoardMap / 67 node / 3B tahta
- MASTER ART bytes ve kabul edilmiş route art mimarisi
- AdMob / Firebase / Android release/signing config
- package name
- `version: 1.68.19+109`

## Sıradaki aktif sıra

1. QA run `33199050082` B1/B5/B8/B10 matrix capture işlerini tamamlasın.
2. Dört artifact setini indir ve gerçek screenshot/log/UI kanıtlarını incele.
3. 6×10 telefonda kullanılabilir değilse yalnız ürün branch'inde dar layout/gesture erişilebilirliği düzeltmesi yap; content standardını geri alma.
4. Görsel/runtime PASS sonrası bonus-after-target gesture + sonuç davranışını gerekirse QA otomasyonuyla ayrıca kanıtla.
5. Kullanıcı görsel/oynanış kabulünden sonra PR #156 Ready kararı verilebilir.
6. Merge ancak Levent'in açık merge onayıyla release branch'e yapılır.

Diğer Bilgi Rotası açık işleri diğer project-memory dosyalarında korunur; bu özet onları silmez.