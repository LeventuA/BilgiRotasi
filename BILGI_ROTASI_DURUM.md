# Bilgi Rotası – Proje Durumu

**Son güncelleme:** 1 Eylül 2026

## Canlı Sürüm / Release Hattı

- Repo içi aktif ürün sürümü: **1.68.19+109**.
- Paket: `com.leventua.bilgirotasi`.
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

### V6 ürün hattı

- Branch: `fix/kelime-avi-v6-visual-found-state-20260901`.
- Ana ürün commit: `e62314cb5874f6b290c70a59061255440c6f00e9`.
- Commit adı: `fix(kelime-avi): productize verified V6 cell visuals`.
- Draft PR: **#162** — `fix(kelime-avi): productize Android-verified V6 cell visuals`.
- PR #162 base: `feat/kelime-avi-v5-reference-assets-integration-20260831`.
- Merge yapılmadı; Levent’in ayrı ve açık merge onayı zorunludur.

V6 ürün değişikliği:
- `_harborGridSpacing`: `3.0 → 1.5`.
- Hücre asset görsel ölçeği: `1.12`.
- Aktif/found hücrelerde sıcak altın glow.
- Bulunan hedef kelime plakasında sıcak turuncu found-state tonu.
- Başarılı seçimden sonra instruction panelinde canonical instruction metni korunur.
- Engine/path/scoring/timer/progression/içerik sözleşmeleri değiştirilmedi.

## Deterministik Ürünleştirme Gate — PASS

Run: `33443015882` — **SUCCESS**.

Doğrulama:
- Clean product base: `d70dc2739b5c9552189bd7fef11ce3f3af4cc238`.
- Base `word_hunt_screens.dart` blob: `e3fc4c50b8d5600c6b111a91313c6a47d7c98653`.
- Android koşusunda kullanılan exact preview patch script + Dart formatter uygulandı.
- Final product file blob: `d415876b1311362a8de6220cfcfe2978fce514dd`.
- `dart analyze lib/word_hunt`: **No issues found**.
- Focused Kelime Avı suite: **138/138 PASS**.
- `git diff --check`: PASS.
- Protected-scope gate: PASS.

## Gerçek Android 16 Raw Kanıt — PASS

Run: `33436607792` — **SUCCESS**.

Koşul:
- Android API: **36**.
- Çözünürlük: **1080×1920**.
- Density: **420 dpi**.
- Static suite: **138/138 PASS**.
- Android runtime candidate file blob: `d415876...`; ürün commitindeki blob ile birebir aynıdır.

B10 gerçek gesture kanıtı:
- Initial: `0/9`.
- İlk 900 ms sentetik swipe semantic değişiklik üretmedi ve PASS sayılmadı.
- 1800 ms gerçek YOL swipe başarılı oldu.
- Found-state: **`1/9`**.
- YOL hücre changed-pixels: `[7370, 7236, 7449]`.
- Progress panel changed-pixels: `299`.
- `YOL_SEMANTIC_VISUAL_GATE=PASS`.

Artifact:
- ID: `9775000736`.
- Digest: `sha256:f145e7e5901db55fa6dd1d71c89d246ce1c70a99a26cc790ad1b81ae8ed9aabd`.

Bu kanıt image-edit/mockup değildir; raw Android emulator screenshotlarından üretilmiştir.

## Korunan Alanlar

V6 çalışmasında değiştirilmedi:
- canonical 8×8 / 64 hücre içerik geometrisi
- `assets/questions.json`
- `lib/main.dart`
- `assets/word_hunt/v5_reference_assets/**`
- 11 locked V5 reference asset SHA sözleşmesi
- BoardMap / 67 node
- Firebase / AdMob / release signing
- package name / version

PR #161 head’ine karşı **ürün kodu farkı yalnız `lib/word_hunt/word_hunt_screens.dart`** dosyasındadır. Zorunlu proje hafıza dosyaları ayrıca aynı çalışma branch’inde güncellenir.

## Görev / Karar Dosyaları

- `GOREV_HAVUZU.md`: canlı repoda görev başlangıcında yoktu; mevcut V6 görevi doğrulanmış kanıtlarla yeniden oluşturuldu. Eski görev havuzu geçmişi **DOĞRULANACAK**.
- `ACIK_SORULAR_VE_DOGRULAMALAR.md`: canlı repoda görev başlangıcında yoktu; mevcut açık V6 kapılarıyla oluşturuldu.
- `KARARLAR.md`: canlı repoda görev başlangıcında bulunamadı. Bu görevde yeni kullanıcı ürün kararı eklenmedi; kanonik konumu **DOĞRULANACAK**.

## Kalan Gerçek Kapılar

1. Raw Android B10 initial ekranının Levent tarafından görsel kabulü.
2. Raw Android B10 `YOL / 1/9` found-state ekranının Levent tarafından görsel kabulü.
3. `ERROR_STATE_VISUAL = DOĞRULANACAK`.
4. `REFERENCE_FONT = DOĞRULANACAK`.
5. B5 60s / B10 120s gerçek insan süre-zorluk playtesti.
6. PR #161 ve PR #162 Ready kararları ayrıca verilecek.
7. Production `lib/main.dart` navigasyon entegrasyonu ayrı scope/onaydır.
8. Merge yalnız Levent’in ayrı ve açık merge onayıyla yapılır.

## Kanonik Ayrıntılı Devir

`docs/project-memory/GENEL_PROJE_OZETI.md`
