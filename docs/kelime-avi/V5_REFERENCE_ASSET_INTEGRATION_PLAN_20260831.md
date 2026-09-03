# Kelime Avı V5 — Minimal Reference Asset Integration Plan

Tarih: 31 Ağustos 2026

Hedef branch: `feat/kelime-avi-v5-reference-assets-integration-20260831`

Kaynak branch başlangıç SHA: `5362c09431e65cf683455bae6f67d29d4d680466`

Sürüm: `1.68.19+109` — değiştirilmeyecek.

## Amaç

Onaylı V5 reference assetlerini mevcut `WordHuntLevelProductionScreen` presentation katmanına minimum diff ile bağlamak.

Bu çalışma gameplay yeniden yazımı değildir.

## Kesin koruma

- Canonical grid: **8×8**.
- 10 bölüm / 80 target+bonus.
- Grid coordinates, intended/reverse swipe, timer, scoring, mistake sayacı, bonus, result ve progression davranışı.
- `lib/main.dart` kapsam dışı.
- `assets/questions.json` kapsam dışı.
- MASTER ART route / BoardMap / 67 node kapsam dışı.
- Firebase / AdMob / signing / package / version kapsam dışı.

## Mevcut kodda yapılacak minimum sunum değişiklikleri

### 1. Background

Mevcut:

`assets/word_hunt/baslangic_limani_gameplay_bg.jpg`

Yerine:

`assets/word_hunt/v5_reference_assets/harbor_background_1080x1920.png`

`Stack`, `SafeArea`, gesture ve layout akışı korunur.

### 2. Header geri butonu

Mevcut Material `Icons.arrow_back_rounded` çizimi yerine onaylı:

`icon_back.png`

kullanılır. `IconButton` / hitbox / `onBack` davranışı korunur.

Başlık ve `Başlangıç Limanı` dinamik/metin katmanı Phase 1'de değiştirilmez. `REFERENCE_FONT = DOĞRULANACAK` olarak kalır.

### 3. Üç metric panel

`_HarborMetricPlate` procedural gradient/border/rivet çizimi yerine:

`status_panel_empty.png`

shell olarak kullanılır.

Dinamik değerler aynı kalır:

- bulunan / toplam,
- hata,
- elapsed seconds.

Material ikonlar yerine onaylı assetler kullanılır:

- `icon_search.png`
- `icon_mistake.png`
- `icon_timer.png`

Metric state ve key'ler korunur.

### 4. Target / bonus plaque

`_HarborWordPlate` procedural shell yerine:

- normal target: `word_plaque_empty.png`
- bonus: `bonus_plaque_empty.png`

kullanır.

Kelime metni dinamik overlay kalır.

**DOĞRULANACAK:** bağlayıcı reference initial state'te found target/bonus plaque state'ini göstermediği için yeni found plaque asseti uydurulmaz. Phase 1'de mevcut found davranışı minimum overlay olarak korunur; final Android görsel QA'da ayrıca değerlendirilir.

### 5. Grid cell

`_HarborGridCell` procedural idle/active chrome yerine:

- idle: `cell_idle.png`
- selected veya found: `cell_selected_found.png`

kullanır.

Harf dinamik overlay kalır.

`row`, `column`, `extent`, pointer geometry, GridView, 8×8 count ve widget key'leri değişmez.

**DOĞRULANACAK:** `error == true` için bağlayıcı reference state'i yoktur. `cell_error.png` oluşturulmaz. Error state Phase 1'de mevcut minimum visual overlay ile korunur ve ayrıca görsel onay ister.

### 6. Instruction panel

`_HarborInstructionPlate` procedural panel + ayrı Material anchor/compass yerine:

`instruction_panel_empty.png`

tek shell olarak kullanır.

Anchor/compass dekorları bu asset içinde bake edilmiştir; `icon_anchor.png` ve `icon_compass.png` production overlay olarak kullanılmaz.

Status metni dinamik overlay kalır.

## Asset bundle

Flutter asset directory declaration recursive alt klasörü garanti etmediğinden, gerekirse `pubspec.yaml` altında yalnız şu directory kaydı eklenir:

`- assets/word_hunt/v5_reference_assets/`

`version: 1.68.19+109` kesinlikle değişmez.

## Phase 1 bilinçli olarak değiştirmeyecek

- typography / font ailesi,
- error-cell özel raster state,
- found target/bonus için yeni raster state,
- completion button görseli,
- gameplay davranışı.

Bu alanlar ilk gerçek Android 16 render sonrası yalnız görünür fark varsa ayrı küçük karar olarak ele alınır.

## Test planı

Entegrasyon commitinden sonra:

1. `dart format --output=none --set-exit-if-changed` ilgili Dart dosyaları.
2. `dart analyze lib/word_hunt`.
3. Focused Word Hunt tests.
4. Full Flutter test suite.
5. `git diff --check` + protected-scope diff incelemesi.
6. Public repo standard GitHub-hosted Actions kullanılabilir; Actions dakika limiti bu repo için çalışma freni değildir. Artifact/cache retention yine kontrol edilir.
7. Android 16 B1/B5/B8/B10 screenshot.
8. B1/B5/B8/B10 64/64 cell visibility.
9. B5 ANKARA ve reverse BAŞKENT swipe.
10. B5 soft-time.
11. FATAL/ANR/am_crash/process-death taraması.
12. Binding reference ile side-by-side görsel QA.

## Teslim kapısı

- Screenshot görmeden görsel PASS yok.
- PR Draft kalır.
- Ready ayrı kullanıcı kararıdır.
- Merge ayrı açık kullanıcı onayıdır.
