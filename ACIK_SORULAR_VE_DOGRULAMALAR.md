# Bilgi Rotası — Açık Sorular ve Doğrulamalar

**Son güncelleme:** 3 Eylül 2026 — Paket 2 adı `Gökyüzü Adaları` ve görsel yön `C — Neşeli & Parlak` Levent tarafından onaylandı. Tema/görsel yön kapısı kapandı; 10 bölüm adı/node sırası ve görsel teknik mimari açık kaldı. Canonical release HEAD `3557a7e4f2f2917d61ba61866c6d4c8561994667`; Play yükleme/yayınlama ayrı açık karardır.

## Kelime Avı

### Kapanan kabul/doğrulama kapıları

- `USER_VISUAL_ACCEPTANCE_INITIAL` — **PASS / KAPANDI**.
- `USER_VISUAL_ACCEPTANCE_FOUND` — **PASS / KAPANDI**; Android16 `33486609120`.
- `ERROR_STATE_VISUAL` — **PASS / KAPANDI**; Android16 `33524578623`.
- `COMPLETION_AUTO_REPLAY` — **PASS / KAPANDI**.
- `COMPLETION_POPUP_COMPACT_VISUAL` — **PASS / KAPANDI**; Android16 `33655562508`.
- `B5_60S_BALANCE_DECISION` — tuning sonrası 32 sn: **PASS / KAPANDI**.
- `SWIPE_FALSE_POSITIVE_MISTAKES` — Fast `33724552713` + Android16 `33724549202`: **PASS / KAPANDI**.
- `PR_167_READY_MERGE` — **PASS / KAPANDI**; merge `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.
- `PR_163_READY_MERGE` — **PASS / KAPANDI**; merge `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`.
- `PR_162_READY_MERGE` — **PASS / KAPANDI**; merge `929bb13177e03a0962464e21f6c174d4b3439349`.
- `PR_161_FINAL_REVIEW` — **PASS / KAPANDI**.
- `PR_161_READY_DECISION` — **PASS / KAPANDI**.
- `PR_161_MERGE_DECISION` — **PASS / KAPANDI**; merge `4aa490e7c2d5e7547dc95f9463dbbb9adeb85e5a`.
- `PR_158_RELEASE_QA_CLEANUP` — **PASS / KAPANDI**; commit `2ae95df70b452f735a8db9c5bd0d88827a2ec40a`.
- `PR_158_FINAL_DIFF_REVIEW` — 37 dosya; protected scope temiz; review/thread yok: **PASS / KAPANDI**.
- `PR_158_ANDROID16_RELEASE_CONTEXT` — run `33745646184`, job `100617364648`: **SUCCESS / KAPANDI**; artifact `9887953917`.
- `PR_158_RELEASE_APK_ADMOB_CONTEXT` — run `33745646210`, job `100617365147`: **SUCCESS / KAPANDI**; artifact `9889920696`.
- `PR_158_READY_DECISION` — **PASS / KAPANDI**.
- `PR_158_RELEASE_MERGE_DECISION` — Levent’in ayrı ve açık onayıyla **PASS / KAPANDI**; canonical release merge commit `189864c92a605e7bb960460300714049c730ea39`.
- `PRODUCTION_MAIN_NAVIGATION` — PR #169 ile **PASS / KAPANDI**; exact head `ffa1454ba8fb47da21ca6caa50b0a5495e0149c1`, merge commit `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
- `PR_169_FULL_SUITE_RELEASE_ANDROID16` — run `33754851284`: **SUCCESS / KAPANDI**.
- `PR_169_VISUAL_MASTER_ART_ANDROID16` — run `33754851205`: **SUCCESS / KAPANDI**; 126 test; artifact `9893332600`.
- `PR_169_READY_DECISION` — Levent’in `Devam et` onayıyla **PASS / KAPANDI**.
- `PR_169_RELEASE_MERGE_DECISION` — Levent’in ayrı `Merge et` onayıyla **PASS / KAPANDI**; merge `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
- `PR_169_RELEASE_HEAD_VERIFY` — canonical release HEAD `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`: **PASS / KAPANDI**.
- `PR_168_MERGEABILITY_RECHECK` — ilk kısa `mergeable=false` görünümü GitHub yeniden hesaplaması sonrası `mergeable=true`: **PASS / KAPANDI**.
- `PR_168_DOCS_MERGE_DECISION` — Levent’in `Devam et` onayıyla **PASS / KAPANDI**; merge `3557a7e4f2f2917d61ba61866c6d4c8561994667`.
- `PR_168_RELEASE_HEAD_VERIFY` — canonical release HEAD `3557a7e4f2f2917d61ba61866c6d4c8561994667`: **PASS / KAPANDI**.
- `NEXT_ROUTE_THEME_NAME` — Paket 2 adı **Gökyüzü Adaları**: **PASS / LOCKED / KAPANDI**.
- `NEXT_ROUTE_VISUAL_DIRECTION` — Konsept **C — Neşeli & Parlak**: **PASS / LOCKED / KAPANDI**.

### Gökyüzü Adaları bağlayıcı görsel yön özeti

- Neşeli, renkli, pozitif, eğlenceli, çocuk dostu, hafif ve canlı atmosfer.
- Açık gök mavisi/camgöbeği/turkuaz ana palet; yeşil yüzen adalar; sarı-turuncu sıcak vurgular; destekleyici pembe/mercan ayrıntılar; parlak beyaz bulutlar.
- Yüzen çimenli adalar, bulut geçişleri, renkli balon/hava gemileri, rüzgâr yapıları, kuleler ve sıcak-altın final sarayı hissi.
- Konsept onayı final production MASTER ART veya raw Android görsel PASS değildir.

### İnsan süre-zorluk sonucu

- B5 ilk ölçüm: 115 sn / 2 hata; 60 sn soft challenge karşılanmadı.
- B10: 109 sn / 4 hata; 120 sn soft challenge **PASS**.
- B5 tuning sonrası: 32 sn; süre **PASS**.

### Açık kalanlar

- `GOKYUZU_ADALARI_ROUTE_STRUCTURE` — 10 bölüm adı + rota/node sıralaması: **AÇIK / SIRADAKİ KULLANICI ÜRÜN KARARI**.
- `GOKYUZU_ADALARI_VISUAL_TECH_ARCHITECTURE` — MASTER ART raster / katmanlı Flutter / modüler asset yaklaşımı: **AÇIK / GÖRSEL YÖNDEN AYRI TEKNİK KARAR**. Başlangıç Limanı MASTER ART istisnası otomatik genellenmez.
- `GOKYUZU_ADALARI_CONTENT_PACKAGE` — 80 target+bonus içerik ve 8×8 grid paketi: **BEKLİYOR / ROTA YAPISI SONRASI**.
- `PACKAGE_BASED_QA_IMPLEMENTATION` — 10 bölümlük tek branch, B1/B5/B10 insan örneklemesi ve tek paket QA APK: **KARAR VERİLDİ / UYGULANACAK**.
- `REFERENCE_FONT` — Runtime generic `serif`; exact aile mevcut kaynaklardan kanıtlanamıyor: **DOĞRULANACAK / DEFERRED**.
- `PLAY_RELEASE` — Play yükleme/yayınlama ayrıca açık karar gerektirir: **AÇIK**.

## Merge güvenliği

- PR #158 canonical release branch’e merge edilmiştir; merge commit `189864c92a605e7bb960460300714049c730ea39`.
- PR #169 canonical release branch’e merge edilmiştir; merge commit `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
- PR #168 docs-only checkpoint canonical release branch’e merge edilmiştir; merge commit `3557a7e4f2f2917d61ba61866c6d4c8561994667`.
- PR #168 merge commitinde otomatik PR workflow’u tetiklenmemiştir (`0` run); ürün kodu değişmemiştir.
- Gökyüzü Adaları tema/görsel yön kararı docs-only PR #170 branch’inde kaydedilir; ürün kodu üretilmez.
- Play yayını yapılmamıştır.
