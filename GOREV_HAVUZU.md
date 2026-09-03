# Bilgi Rotası — Görev Havuzu

**Son güncelleme:** 3 Eylül 2026 — PR #162 merge tamamlandı; sıradaki gerçek kapı PR #161 final inceleme + Ready kararı

> Root dosya güncel Kelime Avı çalışma checkpointini taşır. Eski ayrıntılı görev geçmişi `docs/project-memory/GOREV_HAVUZU.md` ve Git geçmişinde korunur.

## Aktif görev — Kelime Avı final zincir kapıları

**Durum:** FOUND/ERROR/COMPACT COMPLETION KULLANICI PASS / B5 SÜRE PASS / SWIPE TOLERANSI ANDROID 16 PASS / PR #167 MERGED / PR #163 MERGED / PR #162 MERGED / PR #161 DRAFT-OPEN / RELEASE-MERGE YOK

**Güncel parent branch:** `feat/kelime-avi-v5-reference-assets-integration-20260831`

**Güncel PR:** #161 — **OPEN / DRAFT / mergeable=true / merge yok**

**PR #162 merge commit:** `929bb13177e03a0962464e21f6c174d4b3439349`

**PR #163 merge commit:** `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`

**PR #167 merge commit:** `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`

**Compact completion exact tested blob:** `6ce2830a7df8eb696a9df589c91c544df7712969`

### Tamamlanan kapılar

1. Canonical 8×8 / 64 hücre korunması — **PASS**.
2. Edge-fuse found-state raw Android kullanıcı kabulü — **PASS**; run `33486609120`.
3. Error-state bordo/kırmızı ayrımı — **PASS**; run `33524578623`.
4. Completion otomatik tetikleme/replay regression — **PASS**.
5. Premium + kompakt completion popup — **PASS**.
6. Compact static/productize gate — **PASS**; run `33629855060`, Word Hunt **139/139 PASS**.
7. Compact Android 16 B5/B10 runtime — **PASS**; run `33655562508`.
8. B5 60 sn tuning — **PASS**; Android 16 run `33670657723`; insan süresi **32 sn**.
9. Swipe false-positive dar tolerans — **PASS**.
10. Fast checks — **PASS**; run `33724552713`.
11. Android 16 gerçek `ANKARA + 1 trailing hücre` — **PASS**; run `33724549202`, ilerleme `1/7`, hata `0`.
12. PR #167 Ready + merge — **PASS**; merge `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.
13. PR #163 final diff/review + Ready + merge — **PASS**; merge `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`.
14. PR #162 final diff/review + Ready — **PASS**.
15. PR #162 merge — **PASS**; Levent açık onayıyla merge `929bb13177e03a0962464e21f6c174d4b3439349`.
16. PR #162 merge hedefinin release/main değil PR #161 parent branch’i olması — **PASS**.

### Gerçek insan süre-zorluk sonucu

- B5 ilk ölçüm: **115 sn / 2 hata**; 60 sn soft challenge hedefi karşılanmadı.
- B10: **109 sn / 4 hata**; 120 sn soft challenge hedefi karşılandı.
- B5 tuning sonrası: **32 sn / UI’da 2 false-positive kayıt**; süre PASS, bilinçli gerçek hata 0.
- Swipe düzeltmesi gerçek Android 16 taşma kanıtıyla PASS.

### Açık işler

1. PR #161 final diff/review canlı kontrolü. **AÇIK**.
2. PR #161 Ready kararı. **AÇIK / Levent onayı gerekli**.
3. PR #161 Ready olursa merge kararı ayrıca alınacak. **AÇIK / ayrı Levent onayı gerekli**.
4. Parent PR #158 zincir kararı ayrıca ele alınacak. **AÇIK**.
5. PR #166 tarihsel geliştirme/QA hattıdır; merge edilmeyecek. **MERGE YOK**.
6. Sonraki paketlerde tek branch + toplu otomatik kapılar + B1/B5/B10 insan örneklemesi + tek Android paket QA uygulanacak. **KABUL EDİLDİ / UYGULANACAK**.
7. `REFERENCE_FONT` exact kaynak mevcut değil. **DOĞRULANACAK / DEFERRED**.
8. Production `lib/main.dart` navigasyon entegrasyonu ayrı scope. **AÇIK**.
9. Release entegrasyonu ve Play yayını ayrıca açık karar gerektirir. **AÇIK**.

### Korunan kapsam

- `assets/questions.json`, `lib/main.dart`, locked V5 assets, BoardMap/67 node, AdMob/Firebase/release signing, package/version değiştirilmedi.
- Sürüm: **1.68.19+109**.

**PR #162 entegrasyon kapısı kapanmıştır. Sıradaki gerçek karar kapısı PR #161 Ready; release/main’e geçiş bunun parçası değildir.**
