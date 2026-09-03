# Bilgi Rotası — Görev Havuzu

**Son güncelleme:** 3 Eylül 2026 — PR #161 final inceleme PASS; tek-kullanımlık QA workflow/script temizlendi; Ready ayrı Levent onayı bekliyor

> Root dosya güncel Kelime Avı çalışma checkpointini taşır. Eski ayrıntılı görev geçmişi `docs/project-memory/GOREV_HAVUZU.md` ve Git geçmişinde korunur.

## Aktif görev — Kelime Avı final zincir kapıları

**Durum:** V5 ASSET PASS / FOUND-ERROR-COMPLETION KULLANICI PASS / B5 SÜRE PASS / SWIPE ANDROID 16 PASS / PR #167 MERGED / PR #163 MERGED / PR #162 MERGED / PR #161 DRAFT-OPEN / READY-MERGE YOK

**Güncel parent branch:** `feat/kelime-avi-v5-reference-assets-integration-20260831`

**Güncel PR:** #161 — **OPEN / DRAFT / mergeable=true / merge yok**

**PR #162 merge commit:** `929bb13177e03a0962464e21f6c174d4b3439349`

**PR #163 merge commit:** `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`

**PR #167 merge commit:** `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`

### Tamamlanan kapılar

1. Canonical 8×8 / 64 hücre korunması — **PASS**.
2. V5 approved reference asset integration — **PASS**; run `33379341765`.
3. Edge-fuse found-state raw Android kullanıcı kabulü — **PASS**; run `33486609120`.
4. Error-state — **PASS**; run `33524578623`.
5. Compact completion popup — **PASS**; run `33655562508`.
6. B5 60 sn tuning — **PASS**; run `33670657723`; insan süresi **32 sn**.
7. Swipe false-positive dar tolerans — **PASS**; fast `33724552713`, Android16 `33724549202`.
8. PR #167 Ready + merge — **PASS**; merge `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.
9. PR #163 final diff/review + Ready + merge — **PASS**; merge `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`.
10. PR #162 final diff/review + Ready + merge — **PASS**; merge `929bb13177e03a0962464e21f6c174d4b3439349`.
11. PR #161 tek-kullanımlık `.github/workflows/apply-word-hunt-v5-reference-assets.yml` ve `tools/qa/apply_word_hunt_v5_reference_assets.py` temizliği — **PASS**.
12. PR #161 final diff/review — **PASS**; 33 dosya, korunan ürün alanları diff dışında, açık review/thread yok.
13. PR #161 final inceleme sonrası ürün kodu değişmedi; PR #162 mergeinden sonra yalnız checkpoint belgeleri ve QA-only dosya temizliği var — **PASS**.

### Gerçek insan süre-zorluk sonucu

- B5 ilk ölçüm: **115 sn / 2 hata**; 60 sn soft challenge hedefi karşılanmadı.
- B10: **109 sn / 4 hata**; 120 sn soft challenge hedefi karşılandı.
- B5 tuning sonrası: **32 sn / UI’da 2 false-positive kayıt**; süre PASS, bilinçli gerçek hata 0.

### Açık işler

1. PR #161 Ready kararı. **AÇIK / Levent onayı gerekli**.
2. PR #161 Ready olursa merge kararı ayrıca alınacak. **AÇIK / ayrı Levent onayı gerekli**.
3. Parent PR #158 zincir kararı ayrıca ele alınacak. **AÇIK**.
4. PR #166 tarihsel geliştirme/QA hattıdır; merge edilmeyecek. **MERGE YOK**.
5. Sonraki paketlerde tek branch + toplu otomatik kapılar + B1/B5/B10 insan örneklemesi + tek Android paket QA uygulanacak. **KABUL EDİLDİ / UYGULANACAK**.
6. `REFERENCE_FONT` exact kaynak mevcut değil. **DOĞRULANACAK / DEFERRED**.
7. Production `lib/main.dart` navigasyon entegrasyonu ayrı scope. **AÇIK**.
8. Release entegrasyonu ve Play yayını ayrıca açık karar gerektirir. **AÇIK**.

### Korunan kapsam

- `assets/questions.json`, `lib/main.dart`, BoardMap/67 node, AdMob/Firebase/release signing, package/version değiştirilmedi.
- Sürüm: **1.68.19+109**.

**PR #161 final inceleme kapısı kapanmıştır. Sıradaki gerçek karar kapısı PR #161 Ready; release/main’e geçiş bunun parçası değildir.**
