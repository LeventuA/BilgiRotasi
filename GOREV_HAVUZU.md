# Bilgi Rotası — Görev Havuzu

**Son güncelleme:** 3 Eylül 2026 — Production ana navigasyon entegrasyonu PR #169 tüm teknik/Android16 kapıları geçerek Levent’in `Devam et` onayıyla Ready for Review yapıldı. Merge ve Play yayını yapılmadı.

> Root dosya güncel Kelime Avı çalışma checkpointini taşır. Eski ayrıntılı görev geçmişi `docs/project-memory/GOREV_HAVUZU.md` ve Git geçmişinde korunur.

## Aktif görev — Kelime Avı production entegrasyonu

**Durum:** 8×8 LOCKED / V5 ASSET PASS / FOUND-ERROR-COMPLETION USER PASS / B5 SÜRE PASS / SWIPE ANDROID16 PASS / PR #167+#163+#162+#161+#158 MERGED / PR #169 READY / PLAY YAYINI YOK

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
13. PR #158 cleanup/final review/exact release-context — **PASS**.
14. PR #158 → canonical release merge — **PASS**; merge commit `189864c92a605e7bb960460300714049c730ea39`.
15. Merge sonrası canonical release HEAD doğrulaması — **PASS**; `189864c9...`.
16. Production ana navigasyon branch’i — **PASS**; `feat/kelime-avi-production-navigation-20260903`.
17. PR #169 final minimum ürün diff’i — **PASS**; yalnız 4 dosya, 259 ekleme / 0 silme; protected scope temiz.
18. PR #169 focused production validation — **PASS**; run `33754274810`, 62 test.
19. PR #169 minimum-diff yeniden doğrulaması — **PASS**; run `33754621892`.
20. PR #169 full-suite + release APK + Android16 cold-start/AdMob — **PASS**; run `33754851284`, job `100646698982`.
21. PR #169 Kelime Avı Android16 görsel/MASTER ART — **PASS**; run `33754851205`, job `100646698474`; 126 test; artifact `9893332600`.
22. PR #169 review/thread kontrolü — **PASS**; blocker yok.
23. PR #169 Ready for Review — **PASS**; Levent’in 3 Eylül 2026 `Devam et` onayıyla. Exact Ready HEAD `ffa1454ba8fb47da21ca6caa50b0a5495e0149c1`.

### PR #169 scope

- `lib/main.dart`: yalnız production entry importu.
- `lib/main_navigation.dart`: Oyna menüsüne Kelime Avı kartı.
- `lib/word_hunt/word_hunt_production_entry_screen.dart`: production route + UID/guest-scoped local persistence glue.
- `test/word_hunt_menu_entry_test.dart`: menü entry sözleşmesi.
- `assets/questions.json`, BoardMap/67 node, canonical content, Firebase rules/model, AdMob/signing/Android config, package/version değişmedi.

### Açık işler

1. **PR #169 → canonical release merge — AÇIK / ayrıca Levent’in ayrı ve açık onayı gerekli.**
2. `REFERENCE_FONT` exact kaynak yok — **DOĞRULANACAK / DEFERRED**.
3. PR #166 tarihsel geliştirme/QA hattıdır — **MERGE YOK**.
4. Sonraki paketlerde tek branch + toplu otomatik kapılar + B1/B5/B10 insan örneklemesi + tek Android paket QA — **KABUL EDİLDİ / UYGULANACAK**.
5. Play yükleme/yayınlama — **AÇIK / ayrıca Levent’in açık onayı gerekli**.

**Sıradaki gerçek karar kapısı PR #169 merge’idir. Ready teknik kapısı kapanmıştır; merge ve Play yayını otomatik yapılmayacaktır.**
