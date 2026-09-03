# Bilgi Rotası — Görev Havuzu

**Son güncelleme:** 3 Eylül 2026 — PR #167 merge tamamlandı; sıradaki gerçek kapı PR #163 Ready kararı

> Root dosya mevcut V6 çalışma checkpointini taşır. Eski ayrıntılı görev geçmişi `docs/project-memory/GOREV_HAVUZU.md` ve Git geçmişinde korunur.

## Aktif görev — Kelime Avı V6 final karar kapıları

**Durum:** FOUND/ERROR/COMPACT COMPLETION KULLANICI PASS / B5 SÜRE PASS / SWIPE TOLERANSI ANDROID 16 PASS / PR #167 MERGED / PR #163 DRAFT-OPEN / READY-MERGE YOK

**Parent V5:** PR #161 — OPEN / DRAFT

**V6 temel ürün:** PR #162 — OPEN / DRAFT

**Güncel ürün branch:** `fix/kelime-avi-v6-found-path-connector-product-20260901`

**Güncel ürün hattı HEAD:** PR #167 merge sonrası `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4` + yalnız dokümantasyon checkpoint commitleri.

**Compact completion exact product blob:** `6ce2830a7df8eb696a9df589c91c544df7712969`

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
11. B5 60 sn yeni 8×8 yerleşim adayı statik + Android 16 kapısı — **PASS**; ürün commit `44ebec6b...`, run `33670657723`, artifact `9862719927`.
12. B5 adayı kelimeleri, 60 sn timer/yıldız eşiklerini, tekil fiziksel yolları ve yatay+dikey+çapraz yön ailelerini koruma — **PASS**.
13. B5 tuning + swipe toleransını PR #163 tabanlı temiz ürün branch'ine taşıma — **PASS**; ürün commit `749c678b...`.
14. Otomatik fast gate + gerçek Android 16 `ANKARA + bir hücre taşma` kanıtı — **PASS**; run `33724552713` ve `33724549202`, ilerleme `1/7`, hata `0`.
15. PR #167 son diff/review incelemesi ve Levent Ready onayı — **PASS**.
16. PR #167 merge — **PASS**; CLOSED / MERGED, merge commit `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.

### Gerçek insan süre-zorluk sonucu

- B5 ilk ölçüm: **115 sn / 2 hata**; 60 sn soft challenge hedefi → **HEDEF KARŞILANMADI**.
- B10: **109 sn / 4 hata**; 120 sn soft challenge hedefi → **HEDEF KARŞILANDI**.
- B5 tuning sonrası: **32 sn / UI'da 2 false-positive kayıt**. Levent bu iki kaydın bilinçli yanlış seçim olmadığını bildirdi; süre **PASS**, gerçek niyet hatası **0**.
- False-positive input düzeltmesi gerçek Android 16 taşma kanıtıyla **PASS**.

### Açık işler

1. PR #163 için Ready kararı. **AÇIK / kullanıcı onayı gerekli**.
2. PR #163 Ready olursa merge kararı ayrıca alınacak. **AÇIK / ayrı kullanıcı onayı gerekli**.
3. PR #166 tarihsel geliştirme/QA hattıdır; final ürün değişikliği PR #167 üzerinden PR #163’e merge edilmiştir. **PR #166 MERGE YOK**.
4. Sonraki 10 bölümlük paketlerde tek branch + toplu otomatik kapılar + B1/B5/B10 insan örneklemesi + tek Android paket QA akışını uygula. **KABUL EDİLDİ / UYGULANACAK**.
5. `REFERENCE_FONT` exact kaynak mevcut değil; kaynak bulunursa doğrulanacak. **DOĞRULANACAK / DEFERRED**.
6. PR #161 / #162 / #163 Ready kararları ayrı verilecek. **AÇIK**.
7. Production `lib/main.dart` navigasyon entegrasyonu ayrı scope. **AÇIK**.

### Korunan kapsam

- Engine, path evaluation, scoring, timer, progression ve genel içerik sözleşmesi değiştirilmedi.
- `assets/questions.json`, `lib/main.dart`, V5 locked assets, BoardMap/67 node, AdMob/Firebase/release signing, package/version değiştirilmedi.
- Sürüm: **1.68.19+109**.

**PR #167 entegrasyon kapısı kapanmıştır. Sıradaki gerçek karar kapısı PR #163 Ready; merge bunun ardından ayrıca onaylanacaktır.**
