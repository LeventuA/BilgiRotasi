# Bilgi Rotası — Görev Havuzu

**Son güncelleme:** 3 Eylül 2026 — PR #161 merge tamamlandı; PR #158 release-parent temizliği ve exact release-context CI PASS. Sıradaki gerçek kapı PR #158 Ready kararıdır.

> Root dosya güncel Kelime Avı çalışma checkpointini taşır. Eski ayrıntılı görev geçmişi `docs/project-memory/GOREV_HAVUZU.md` ve Git geçmişinde korunur.

## Aktif görev — Kelime Avı final release zincir kapıları

**Durum:** 8×8 LOCKED / V5 ASSET PASS / FOUND-ERROR-COMPLETION USER PASS / B5 SÜRE PASS / SWIPE ANDROID16 PASS / PR #167+#163+#162+#161 MERGED / PR #158 RELEASE-CONTEXT CI PASS / PR #158 DRAFT-OPEN / READY-MERGE YOK

**Güncel release-parent branch:** `feat/kelime-avi-8x8-content-v1-20260829`

**Güncel PR:** #158 — **OPEN / DRAFT / mergeable=true / merge yok**

**Exact release-context test edilmiş HEAD:** `2ae95df70b452f735a8db9c5bd0d88827a2ec40a`

**Canonical release:** `release/final-closed-test-aab-1.68.8` @ `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`

**PR #161 merge commit:** `4aa490e7c2d5e7547dc95f9463dbbb9adeb85e5a`

**PR #162 merge commit:** `929bb13177e03a0962464e21f6c174d4b3439349`

**PR #163 merge commit:** `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`

**PR #167 merge commit:** `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`

### Tamamlanan kapılar

1. Canonical 8×8 / 64 hücre — **PASS**.
2. 10 bölüm / 30 yıldız / 80 target+bonus contract — **PASS**.
3. V5 approved reference asset integration — **PASS**; run `33379341765`.
4. Edge-fuse found-state raw Android kullanıcı kabulü — **PASS**; run `33486609120`.
5. Error-state raw Android kabulü — **PASS**; run `33524578623`.
6. Compact completion popup — **PASS**; run `33655562508`.
7. B5 60 sn tuning — **PASS**; run `33670657723`; insan süresi **32 sn**.
8. Swipe false-positive dar tolerans — **PASS**; fast `33724552713`, Android16 `33724549202`.
9. PR #167 Ready + merge — **PASS**; `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.
10. PR #163 final review + Ready + merge — **PASS**; `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`.
11. PR #162 final review + Ready + merge — **PASS**; `929bb13177e03a0962464e21f6c174d4b3439349`.
12. PR #161 final review + Ready — **PASS**.
13. PR #161 Levent’in ayrı açık merge onayıyla merge — **PASS**; `4aa490e7c2d5e7547dc95f9463dbbb9adeb85e5a`; hedef PR #158 branch’i, release değil.
14. PR #158 obsolete release QA helper cleanup — **PASS**; commit `2ae95df70b452f735a8db9c5bd0d88827a2ec40a`.
15. PR #158 final diff — **PASS**; 37 dosya; `lib/main.dart`, `assets/questions.json`, BoardMap/67 node, Firebase/AdMob/signing/package/version diff dışında.
16. PR #158 açık review/review thread — **YOK / PASS**.
17. PR #158 Kelime Avı exact release-context Android16 — **PASS**; run `33745646184`, job `100617364648`, artifact `9887953917`, digest `0f2fbcfc...`.
18. PR #158 release APK/AdMob exact release-context — **PASS**; run `33745646210`, job `100617365147`, artifact `9889920696`, digest `447b8299...`.
19. Release APK + manifest/AdMob/signature + Android16 cold-start — **PASS**; ikinci emulator denemesi gerekmedi.
20. Canonical release branch’in test sırasında değişmemesi — **PASS**; HEAD hâlâ `3a0f722a...`.

### Gerçek insan süre-zorluk sonucu

- B5 ilk ölçüm: 115 sn / 2 hata; 60 sn hedef karşılanmadı.
- B10: 109 sn / 4 hata; 120 sn hedef PASS.
- B5 tuning sonrası: **32 sn**; süre PASS.
- Swipe düzeltmesi gerçek Android16 taşma kanıtıyla PASS.

### Açık işler

1. PR #158 Ready for Review kararı. **AÇIK / ayrı Levent onayı gerekli**.
2. PR #158 canonical release merge kararı. **AÇIK / Ready sonrasında ayrı Levent onayı gerekli**.
3. PR #166 tarihsel geliştirme/QA hattıdır. **MERGE YOK**.
4. Sonraki paketlerde tek branch + toplu otomatik kapılar + B1/B5/B10 insan örneklemesi + tek Android paket QA. **KABUL EDİLDİ / UYGULANACAK**.
5. `REFERENCE_FONT` exact kaynak yok. **DOĞRULANACAK / DEFERRED**.
6. Production `lib/main.dart` navigasyon entegrasyonu ayrı scope. **AÇIK**.
7. Play yükleme/yayınlama ayrıca açık karar gerektirir. **AÇIK**.

### Korunan kapsam

- `assets/questions.json`, `lib/main.dart`, BoardMap/67 node, AdMob/Firebase/release signing, package/version değiştirilmedi.
- Sürüm: **1.68.19+109**.

**PR #158 teknik release-context kapıları kapanmıştır. Sıradaki gerçek karar yalnız PR #158 Ready; bu onay release merge veya Play yayını anlamına gelmez.**
