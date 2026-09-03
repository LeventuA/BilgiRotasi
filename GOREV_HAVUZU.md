# Bilgi Rotası — Görev Havuzu

**Son güncelleme:** 3 Eylül 2026 — PR #158 Levent’in ayrı ve açık onayıyla canonical release branch’e merge edildi. Kelime Avı Başlangıç Limanı 8×8 gameplay paketinin release zinciri tamamlandı. Play yayını yapılmadı.

> Root dosya güncel Kelime Avı çalışma checkpointini taşır. Eski ayrıntılı görev geçmişi `docs/project-memory/GOREV_HAVUZU.md` ve Git geçmişinde korunur.

## Aktif görev — Kelime Avı sonrası açık işler

**Durum:** 8×8 LOCKED / V5 ASSET PASS / FOUND-ERROR-COMPLETION USER PASS / B5 SÜRE PASS / SWIPE ANDROID16 PASS / PR #167+#163+#162+#161+#158 MERGED / CANONICAL RELEASE HEAD `189864c9...` / PLAY YAYINI YOK

**Canonical release:** `release/final-closed-test-aab-1.68.8` @ `189864c92a605e7bb960460300714049c730ea39`

**Sürüm:** `1.68.19+109`

### Tamamlanan kapılar

1. Canonical 8×8 / 64 hücre — **PASS**.
2. 10 bölüm / 30 yıldız / 80 target+bonus contract — **PASS**.
3. V5 approved reference asset integration — **PASS**; run `33379341765`.
4. Found-state raw Android kullanıcı kabulü — **PASS**; run `33486609120`.
5. Error-state raw Android kullanıcı kabulü — **PASS**; run `33524578623`.
6. Compact completion popup — **PASS**; run `33655562508`.
7. B5 60 sn tuning — **PASS**; insan sonucu **32 sn**; Android16 `33670657723`.
8. Swipe false-positive dar tolerans — **PASS**; fast `33724552713`, Android16 `33724549202`.
9. PR #167 Ready + merge — **PASS**; `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.
10. PR #163 final review + Ready + merge — **PASS**; `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`.
11. PR #162 final review + Ready + merge — **PASS**; `929bb13177e03a0962464e21f6c174d4b3439349`.
12. PR #161 final review + Ready + merge — **PASS**; `4aa490e7c2d5e7547dc95f9463dbbb9adeb85e5a`.
13. PR #158 obsolete release QA helper cleanup — **PASS**; `2ae95df70b452f735a8db9c5bd0d88827a2ec40a`.
14. PR #158 final diff/review — **PASS**; 37 dosya; protected scope temiz.
15. PR #158 exact release-context Android16 — **PASS**; run `33745646184`, artifact `9887953917`.
16. PR #158 release APK/AdMob exact release-context — **PASS**; run `33745646210`, artifact `9889920696`.
17. PR #158 Ready for Review — **PASS**.
18. PR #158 → canonical release merge — **PASS**; merge commit `189864c92a605e7bb960460300714049c730ea39`.
19. Merge sonrası canonical release HEAD doğrulaması — **PASS**; `189864c9...`.
20. Merge commitinde otomatik workflow tetiklenmemesi — **DOĞRULANDI**; `0` run. Pre-merge exact release-context kanıtları final teknik kanıttır.

### Korunan kapsam

- `assets/questions.json`, `lib/main.dart`, BoardMap/67 node, AdMob/Firebase/release signing, package/version değiştirilmedi.
- Sürüm: **1.68.19+109**.

### Açık işler

1. Production `lib/main.dart` navigasyon entegrasyonu. **AÇIK / ayrı scope-branch-PR**.
2. `REFERENCE_FONT` exact kaynak yok. **DOĞRULANACAK / DEFERRED**.
3. PR #166 tarihsel geliştirme/QA hattıdır. **MERGE YOK**.
4. Sonraki paketlerde tek branch + toplu otomatik kapılar + B1/B5/B10 insan örneklemesi + tek Android paket QA. **KABUL EDİLDİ / UYGULANACAK**.
5. Play yükleme/yayınlama. **AÇIK / ayrıca Levent’in açık onayı gerekli**.

**Kelime Avı Başlangıç Limanı release merge zinciri kapanmıştır. Sıradaki ürün geliştirme işi production ana navigasyon entegrasyonudur; Play yayını ayrıca açık karar gerektirir.**
