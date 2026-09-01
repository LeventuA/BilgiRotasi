# Bilgi Rotası – Proje Durumu

**Son güncelleme:** 1 Eylül 2026

## Canlı Sürüm / Release Hattı

- Repo içi aktif ürün sürümü: **1.68.19+109**.
- Paket: `com.leventua.bilgirotasi`.
- Canonical release branch: `release/final-closed-test-aab-1.68.8` / `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`.
- `main` yayın kaynağı olarak varsayılmaz; release/ürün branch ve PR durumu her görevde yeniden doğrulanır.

## Aktif İş — Kelime Avı V6 gameplay görsel hizalama

Canonical gameplay sözleşmesi **8×8 / 64 hücre** olarak kilitlidir. 6×10 veya başka grid geometrisi bu çalışma kapsamında ürüne geri dönmez.

### Parent V5 hattı

- PR #161: `feat(kelime-avi): integrate approved V5 reference assets`.
- Durum: **OPEN / DRAFT / merged=false**.
- Base: `feat/kelime-avi-8x8-content-v1-20260829`.
- Head: `feat/kelime-avi-v5-reference-assets-integration-20260831`.
- Doğrulanmış parent head: `9cfa12aeafd29d6197c91c79361648508adf400d`.
- 11 V5 production reference asset SHA sözleşmesi locked kalır.

### V6 temel ürün hattı

- Branch: `fix/kelime-avi-v6-visual-found-state-20260901`.
- Ana ürün commit: `e62314cb5874f6b290c70a59061255440c6f00e9`.
- Draft PR: **#162** — OPEN / DRAFT / merge yok.
- `_harborGridSpacing = 1.5`, hücre görsel ölçeği `1.12` ve V6 found-state sunumu korunur.

### V6 found-path edge-fuse hattı — KULLANICI GÖRSEL PASS

- Ürün branch: `fix/kelime-avi-v6-found-path-connector-product-20260901`.
- Draft PR: **#163** — OPEN / DRAFT / merged=false / mergeable=true.
- Test edilmiş edge-fuse commit: `4dddf00178ef9f14b8edb3fc706114be72f477a4` — `fix(kelime-avi): fuse found cells at visible edges`.
- Android’de test edilen `word_hunt_screens.dart` blob: `f43deaad5328f6263f9479de1738cc1f4ac465e0`.
- Temiz ürün commit: `217beb83c31976436a6f26ec43ae4e35a0c7f05c` — `fix(kelime-avi): fuse found cells at visible edges`.
- Temiz ürün commitindeki `word_hunt_screens.dart` blob’u **birebir `f43deaad...`**.
- Found hücre formu korunur; yalnız ardışık found hücrelerin görünür kenar boşlukları sıcak altın/turuncu edge-fuse ile kaynaştırılır.
- QA menüsü kullanıcı görsel kabul kanıtı değildir; kabul yalnız raw Android oyun ekranı üzerinden verilir.

## Edge-fuse Statik + Android 16 Kanıtı — PASS

Raw Android 16 run: `33486609120` — **SUCCESS**.

- Exact tested target SHA: `4dddf00178ef9f14b8edb3fc706114be72f477a4`.
- API 36 / 1080×1920 / 420 dpi.
- `dart analyze lib/word_hunt`: **No issues found**.
- Focused Kelime Avı: **138/138 PASS**.
- QA APK build: PASS.
- Gerçek B10 YOL gesture: `0/9 → 1/9` PASS.
- Y/O/L changed pixels: `[7370, 7236, 7449]`.
- Progress panel changed pixels: `299`.
- `YOL_SEMANTIC_VISUAL_GATE=PASS`.
- Edge-fuse iki boşluk changed pixels: `[520, 520]`.
- Edge-fuse iki boşluk warm pixels: `[520, 520]`.
- `YOL_EDGE_FUSE_PIXEL_GATE=PASS`.
- Artifact: `9792346079`.
- Artifact digest: `sha256:f5a1592ce074a6e0a8f3bc1f7c88baf5bd9ec9b6bf5337327d7368aea83046d8`.

## Kullanıcı Görsel Kabulü — PASS

1 Eylül 2026’da Levent’e aynı run’dan çıkan **ham Android 16** B10 initial ve `YOL / 1/9` found-state ekranları gösterildi.

- Raw B10 initial görünüm: **PASS**.
- Raw B10 edge-fuse `YOL / 1/9` found-state: **PASS**.
- Kabul edilen hedef: ayrı hücre formu korunurken bulunan kelimenin komşu hücreleri yalnız aradaki görünür boşlukta doğal sıcak altın/turuncu birleşim oluşturur.
- Image-edit / mockup / QA selector ekranı kabul kanıtı değildir.

## Korunan Alanlar

Bu çalışmada değiştirilmedi:
- canonical 8×8 / 64 hücre içerik geometrisi
- `assets/questions.json`
- `lib/main.dart`
- `assets/word_hunt/v5_reference_assets/**`
- 11 locked V5 reference asset SHA sözleşmesi
- BoardMap / 67 node
- Firebase / AdMob / release signing
- package name / version

PR #163’te ürün kodu değişikliği `lib/word_hunt/word_hunt_screens.dart` ile sınırlıdır; proje hafıza dosyaları ayrıca güncellenir.

## Görev / Karar Dosyaları

- Root `GOREV_HAVUZU.md` mevcut V6 checkpointini taşır; eski ayrıntılı görev geçmişi `docs/project-memory/GOREV_HAVUZU.md` ve Git geçmişinde korunur.
- Root `ACIK_SORULAR_VE_DOGRULAMALAR.md` açık kapıları taşır.
- Kanonik karar dosyası: `docs/project-memory/KARARLAR.md`.
- Kanonik ayrıntılı devir: `docs/project-memory/GENEL_PROJE_OZETI.md`.

## Kalan Gerçek Kapılar

1. `ERROR_STATE_VISUAL = DOĞRULANACAK`.
2. `REFERENCE_FONT = DOĞRULANACAK`.
3. B5 60s / B10 120s gerçek insan süre-zorluk playtesti.
4. PR #161 / #162 / #163 Ready kararları ayrıca verilecek.
5. Production `lib/main.dart` navigasyon entegrasyonu ayrı scope/onaydır.
6. Merge yalnız Levent’in ayrı ve açık merge onayıyla yapılır.

**Durum:** V6 INITIAL + EDGE-FUSE FOUND-STATE RAW ANDROID GÖRSEL PASS / PR #163 DRAFT / READY YOK / MERGE YOK.
