# Bilgi Rotası — Görev Havuzu

**Son güncelleme:** 2 Eylül 2026

> Root dosya mevcut V6 çalışma checkpointini taşır. Eski ayrıntılı görev geçmişi `docs/project-memory/GOREV_HAVUZU.md` ve Git geçmişinde korunur.

## Aktif görev — Kelime Avı V6 final karar kapıları

**Durum:** FOUND/ERROR/COMPACT COMPLETION TEKNİK + RAW ANDROID + KULLANICI GÖRSEL PASS / HUMAN TIMING MIXED / READY-MERGE YOK

**Parent V5:** PR #161 — OPEN / DRAFT

**V6 temel ürün:** PR #162 — OPEN / DRAFT

**Güncel ürün branch:** `fix/kelime-avi-v6-found-path-connector-product-20260901`

**Güncel ürün commit:** `9a6fede2c4aed4fdbaa6c9ba427fa84e0ce418da`

**Exact product blob:** `6ce2830a7df8eb696a9df589c91c544df7712969`

**Draft PR:** #163 — OPEN / DRAFT / merge yok

### Tamamlanan kapılar

1. Canonical 8×8 / 64 hücre korunması — **PASS**.
2. Edge-fuse found-state raw Android kullanıcı kabulü — **PASS**; run `33486609120`.
3. Error-state bordo/kırmızı ayrımı — **PASS**; run `33524578623`.
4. Completion otomatik tetikleme/replay regression — **PASS**.
5. Premium completion popup tasarımı — **PASS**.
6. Kullanıcı isteğiyle kompakt popup — **PASS**.
7. Compact static/productize gate — **PASS**; run `33629855060`, analyze + Word Hunt **139/139 PASS**.
8. Compact Android 16 B5/B10 runtime — **PASS**; final clean run `33655562508`.
9. Exact tested compact blob’un PR #163 ürün branch’ine taşınması — **PASS**; product commit `9a6fede2...`, blob `6ce2830...`.
10. QA-only workflow/scriptlerin ürün branch’ine taşınmaması — **PASS**.

### Gerçek insan süre-zorluk sonucu

- B5: **115 sn / 2 hata**; 60 sn soft challenge hedefi → **HEDEF KARŞILANMADI**.
- B10: **109 sn / 4 hata**; 120 sn soft challenge hedefi → **HEDEF KARŞILANDI**.
- Overall: **MIXED**. Scripted Android QA süreleri insan playtesti değildir.

### Açık işler

1. B5 60 sn soft challenge için denge/tuning kararı verilecek. **AÇIK**.
2. `REFERENCE_FONT` exact kaynak mevcut değil; kaynak bulunursa doğrulanacak. **DOĞRULANACAK / DEFERRED**.
3. PR #161 / #162 / #163 Ready kararı ayrı verilecek. **AÇIK**.
4. Production `lib/main.dart` navigasyon entegrasyonu ayrı scope. **AÇIK**.
5. Merge yalnız Levent’in ayrıca açık merge onayıyla yapılacak. **AÇIK**.

### Korunan kapsam

- Engine, path evaluation, scoring, timer, progression ve içerik değiştirilmedi.
- `assets/questions.json`, `lib/main.dart`, V5 locked assets, BoardMap/67 node, AdMob/Firebase/release signing, package/version değiştirilmedi.
- Sürüm: **1.68.19+109**.

**Görsel acceptance kapıları kapanmıştır; Ready/merge kapısı otomatik kapanmış sayılmaz.**
