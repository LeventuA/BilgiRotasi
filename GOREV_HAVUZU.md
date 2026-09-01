# Bilgi Rotası — Görev Havuzu

**Son güncelleme:** 1 Eylül 2026

> Root dosya mevcut V6 çalışma checkpointini taşır. Eski ayrıntılı görev geçmişi `docs/project-memory/GOREV_HAVUZU.md` ve Git geçmişinde korunur.

## Aktif görev — Kelime Avı V6 gameplay görsel hizalama

**Durum:** TEKNİK QA PASS / RAW ANDROID INITIAL + FOUND-STATE KULLANICI GÖRSEL PASS / READY-MERGE YOK

**Parent V5:** PR #161 — `feat/kelime-avi-v5-reference-assets-integration-20260831`

**V6 temel ürün:** PR #162 — `fix/kelime-avi-v6-visual-found-state-20260901`

**Edge-fuse ürün branch:** `fix/kelime-avi-v6-found-path-connector-product-20260901`

**Edge-fuse ürün commit:** `217beb83c31976436a6f26ec43ae4e35a0c7f05c` — `fix(kelime-avi): fuse found cells at visible edges`

**Draft PR:** #163 — `fix(kelime-avi): connect found word cells visually`

### Kapsam

- Canonical gameplay grid 8×8 / 64 hücre korunacak.
- V5 locked reference asset SHA sözleşmesi değişmeyecek.
- Mevcut V6 grid spacing / hücre ölçeği / panel düzeni korunacak.
- Bulunan kelimede ardışık hücrelerin yalnız görünür kenar boşlukları doğal sıcak altın/turuncu edge-fuse ile birleşecek.
- Engine, path evaluation, scoring, timer, progression, içerik, `assets/questions.json` ve `lib/main.dart` değişmeyecek.

### Bitti ölçütü

1. Ürün diffinde canonical 8×8/64 sözleşmesi bozulmamış olacak. **PASS**
2. `dart analyze lib/word_hunt` temiz olacak. **PASS**
3. Focused Kelime Avı testleri geçecek. **138/138 PASS**
4. Android API 36 / 1080×1920 / 420 dpi raw runtime initial ekranı üretilecek. **PASS**
5. Gerçek gesture ile B10 `0/9 → 1/9` found-state üretilecek. **PASS**
6. Edge-fuse iki inter-cell bölgede sıcak altın değişim gate’ini geçecek. **PASS — changed `[520,520]`, warm `[520,520]`**
7. Android’de test edilen dosya ile temiz ürün commitindeki dosya blob’u birebir aynı olacak. **PASS — `f43deaad5328f6263f9479de1738cc1f4ac465e0`**
8. Raw Android initial görüntüsü Levent tarafından kabul edilecek. **PASS — 1 Eylül 2026**
9. Raw Android `YOL / 1/9` edge-fuse found-state Levent tarafından kabul edilecek. **PASS — 1 Eylül 2026**
10. `ERROR_STATE_VISUAL` ve `REFERENCE_FONT` belirsizlikleri çözülecek veya ayrıca açıkça ertelenecek. **DOĞRULANACAK**
11. B5 60s / B10 120s gerçek insan süre-zorluk playtesti tamamlanacak veya ayrıca açıkça ertelenecek. **AÇIK**
12. PR #161 / #162 / #163 Ready kararı ayrı verilecek. **AÇIK**
13. Merge yalnız Levent’in ayrıca açık merge onayıyla yapılacak. **AÇIK**

### Kanıt

- Static edge-fuse tested commit: `4dddf00178ef9f14b8edb3fc706114be72f477a4`.
- Android 16 raw proof run: `33486609120` — **SUCCESS**.
- Artifact: `9792346079`.
- Artifact digest: `sha256:f5a1592ce074a6e0a8f3bc1f7c88baf5bd9ec9b6bf5337327d7368aea83046d8`.
- Y/O/L changed pixels: `[7370, 7236, 7449]`.
- Progress changed pixels: `299`.
- `YOL_SEMANTIC_VISUAL_GATE=PASS`.
- `YOL_EDGE_FUSE_PIXEL_GATE=PASS`.

**Bu görevde görsel kabul kapısı kapanmıştır. Ready/merge kapısı otomatik kapanmış sayılmaz.**
