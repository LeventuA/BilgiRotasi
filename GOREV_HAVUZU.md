# Bilgi Rotası — Görev Havuzu

**Son güncelleme:** 3 Eylül 2026 — PR #163 merge tamamlandı; sıradaki gerçek kapı PR #162 Ready kararı

> Root dosya güncel V6 çalışma checkpointini taşır. Eski ayrıntılı görev geçmişi `docs/project-memory/GOREV_HAVUZU.md` ve Git geçmişinde korunur.

## Aktif görev — Kelime Avı V6 final zincir kapıları

**Durum:** FOUND/ERROR/COMPACT COMPLETION KULLANICI PASS / B5 SÜRE PASS / SWIPE TOLERANSI ANDROID 16 PASS / PR #167 MERGED / PR #163 MERGED / PR #162 DRAFT-OPEN / READY-MERGE YOK

**Parent V5:** PR #161 — OPEN / DRAFT

**Güncel V6 branch:** `fix/kelime-avi-v6-visual-found-state-20260901`

**Güncel V6 PR:** #162 — **OPEN / DRAFT / mergeable=true / merge yok**

**PR #163 merge commit:** `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`

**PR #167 merge commit:** `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`

**Compact completion exact tested blob:** `6ce2830a7df8eb696a9df589c91c544df7712969`

### Tamamlanan kapılar

1. Canonical 8×8 / 64 hücre korunması — **PASS**.
2. Edge-fuse found-state raw Android kullanıcı kabulü — **PASS**; run `33486609120`.
3. Error-state bordo/kırmızı ayrımı — **PASS**; run `33524578623`.
4. Completion otomatik tetikleme/replay regression — **PASS**.
5. Premium completion popup — **PASS**.
6. Kompakt completion popup — **PASS**.
7. Compact static/productize gate — **PASS**; run `33629855060`, Word Hunt **139/139 PASS**.
8. Compact Android 16 B5/B10 runtime — **PASS**; run `33655562508`.
9. B5 60 sn yeni 8×8 tuning adayı — **PASS**; run `33670657723`.
10. B5 tuning sonrası insan süresi — **32 sn / PASS**.
11. Swipe false-positive dar tolerans — **PASS**.
12. Fast checks — **PASS**; run `33724552713`.
13. Android 16 gerçek `ANKARA + 1 trailing hücre` — **PASS**; run `33724549202`, ilerleme `1/7`, hata `0`.
14. PR #167 Ready + merge — **PASS**; merge `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.
15. PR #163 final diff/review — **PASS**; korunan alanlar diff dışında, açık review/thread yok.
16. PR #163 Ready — **PASS**.
17. PR #163 merge — **PASS**; Levent açık onayıyla merge `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`.
18. PR #163 merge hedefinin release/main değil PR #162 V6 branch’i olması — **PASS**.

### Gerçek insan süre-zorluk sonucu

- B5 ilk ölçüm: **115 sn / 2 hata**; 60 sn soft challenge hedefi karşılanmadı.
- B10: **109 sn / 4 hata**; 120 sn soft challenge hedefi karşılandı.
- B5 tuning sonrası: **32 sn / UI’da 2 false-positive kayıt**; süre PASS, bilinçli gerçek hata 0.
- Swipe düzeltmesi gerçek Android 16 taşma kanıtıyla PASS.

### Açık işler

1. PR #162 final diff/review canlı kontrolü. **AÇIK**.
2. PR #162 Ready kararı. **AÇIK / kullanıcı onayı gerekli**.
3. PR #162 Ready olursa merge kararı ayrıca alınacak. **AÇIK / ayrı kullanıcı onayı gerekli**.
4. PR #161 zincir Ready/merge kararı ayrıca ele alınacak. **AÇIK**.
5. PR #166 tarihsel geliştirme/QA hattıdır; merge edilmeyecek. **MERGE YOK**.
6. Sonraki paketlerde tek branch + toplu otomatik kapılar + B1/B5/B10 insan örneklemesi + tek Android paket QA uygulanacak. **KABUL EDİLDİ / UYGULANACAK**.
7. `REFERENCE_FONT` exact kaynak mevcut değil. **DOĞRULANACAK / DEFERRED**.
8. Production `lib/main.dart` navigasyon entegrasyonu ayrı scope. **AÇIK**.
9. Release entegrasyonu ve Play yayını ayrıca açık karar gerektirir. **AÇIK**.

### Korunan kapsam

- `assets/questions.json`, `lib/main.dart`, locked V5 assets, BoardMap/67 node, AdMob/Firebase/release signing, package/version değiştirilmedi.
- Sürüm: **1.68.19+109**.

**PR #163 entegrasyon kapısı kapanmıştır. Sıradaki gerçek karar kapısı PR #162 Ready; release/main’e geçiş bunun parçası değildir.**
