# Bilgi Rotası — Açık Sorular ve Doğrulamalar

**Son güncelleme:** 3 Eylül 2026 — Gökyüzü Adaları rota mock V2 Levent tarafından görsel olarak onaylandı. V2 ile alt genel menü kaldırıldı; Başlangıç Limanı rota kabuğu korunup yalnız rota içi köşe kontrolleri bırakıldı. 10 bölüm aynı UI/progression dilini paylaşacak, her bölüm landmark/ada kimliğiyle ayrışacak. Sıradaki açık üretim gerçek şeffaf Sheet A–E ve 48 atomik production asset QA’dır. Canonical release HEAD `3557a7e4f2f2917d61ba61866c6d4c8561994667`; Play yayını yapılmadı.

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
- `PR_158_RELEASE_MERGE_DECISION` — **PASS / KAPANDI**; merge `189864c92a605e7bb960460300714049c730ea39`.
- `PRODUCTION_MAIN_NAVIGATION` — **PASS / KAPANDI**; PR #169 merge `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
- `PR_169_FULL_SUITE_RELEASE_ANDROID16` — run `33754851284`: **SUCCESS / KAPANDI**.
- `PR_169_VISUAL_MASTER_ART_ANDROID16` — run `33754851205`: **SUCCESS / KAPANDI**; 126 test; artifact `9893332600`.
- `PR_169_READY_DECISION` — **PASS / KAPANDI**.
- `PR_169_RELEASE_MERGE_DECISION` — **PASS / KAPANDI**; merge `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
- `PR_169_RELEASE_HEAD_VERIFY` — **PASS / KAPANDI**.
- `PR_168_MERGEABILITY_RECHECK` — **PASS / KAPANDI**.
- `PR_168_DOCS_MERGE_DECISION` — **PASS / KAPANDI**; merge `3557a7e4f2f2917d61ba61866c6d4c8561994667`.
- `PR_168_RELEASE_HEAD_VERIFY` — **PASS / KAPANDI**.
- `NEXT_ROUTE_THEME_NAME` — **Gökyüzü Adaları / PASS / LOCKED / KAPANDI**.
- `NEXT_ROUTE_VISUAL_DIRECTION` — **C — Neşeli & Parlak / PASS / LOCKED / KAPANDI**.
- `GOKYUZU_ADALARI_ROUTE_STRUCTURE` — 10 bölüm adı + sıra **PASS / LOCKED / KAPANDI**.
- `GOKYUZU_ADALARI_VISUAL_TECH_ARCHITECTURE` — **modüler asset yaklaşımı / PASS / LOCKED / KAPANDI**.
- `GOKYUZU_ADALARI_ASSET_CONTRACT` — **48 atomik asset / 5 sprite sheet / PASS / PLAN HAZIR**.
- `GOKYUZU_ADALARI_ROUTE_MOCK_V2_VISUAL` — alt genel menüsüz düzeltilmiş rota mock V2: **PASS / LEVENT ONAYI / KAPANDI**.
- `GOKYUZU_ADALARI_ROUTE_SHELL` — Başlangıç Limanı ile tutarlı rota kabuğu, rota içi köşe kontrolleri, alt genel menü yok: **PASS / LOCKED / KAPANDI**.
- `GOKYUZU_ADALARI_LEVEL_VISUAL_VARIATION` — aynı UI/progression kabuğu + bölüm başına farklı landmark/ada kimliği: **PASS / LOCKED / KAPANDI**.

### Gökyüzü Adaları kilitli rota

1. Rüzgâr Kapısı
2. Bulut Bahçesi
3. Kuş Geçidi
4. Gökkuşağı Köprüsü
5. Fırtına Kulesi
6. Hava Gemisi Limanı
7. Ay İskelesi
8. Gizli Ada — bonus
9. Yıldız Gözlemevi
10. Güneş Sarayı

### Açık kalanlar

- `GOKYUZU_ADALARI_PRODUCTION_SPRITE_SHEETS` — yazısız/etiketsiz, şeffaf arka planlı Sheet A–E production export: **AKTİF / SIRADAKİ ÜRETİM**.
- `GOKYUZU_ADALARI_ATOMIC_ASSET_QA` — production sheet'leri 48 atomik asset'e ayırma, transparanlık/kenar/ışık/stil/ölçek kontrolü: **BEKLİYOR**.
- `GOKYUZU_ADALARI_FLUTTER_ROUTE` — modüler rota Flutter entegrasyonu: **BEKLİYOR / atomik QA sonrası**.
- `GOKYUZU_ADALARI_CONTENT_PACKAGE` — 80 target+bonus içerik ve 8×8 grid paketi: **BEKLİYOR**.
- `PACKAGE_BASED_QA_IMPLEMENTATION` — 10 bölümlük tek branch, B1/B5/B10 insan örneklemesi ve tek paket QA APK: **KARAR VERİLDİ / UYGULANACAK**.
- `REFERENCE_FONT` — **DOĞRULANACAK / DEFERRED**.
- `PLAY_RELEASE` — **AÇIK / ayrı Levent onayı gerekli**.

## Merge güvenliği

- PR #158 canonical release'e merge edildi: `189864c92a605e7bb960460300714049c730ea39`.
- PR #169 canonical release'e merge edildi: `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
- PR #168 docs-only merge edildi: `3557a7e4f2f2917d61ba61866c6d4c8561994667`.
- Gökyüzü Adaları karar/asset planı docs-only PR #170 branch'inde tutulur; ürün kodu/Play işlemi henüz yapılmaz.
- PR #170 ayrı açık onay olmadan merge edilmez.
- Play yayını yapılmamıştır.

## Kelime Avı V9 — Gökyüzü Adaları Asset Intake Checkpoint — 5 Eylül 2026

- Canonical release: `release/final-closed-test-aab-1.68.8` @ `3557a7e4f2f2917d61ba61866c6d4c8561994667`; sürüm `1.68.19+109`.
- Başlangıç Limanı release/gameplay/görsel/navigasyon PASS; yeni belirti yok, yeniden açılmadı.
- İçerik PR #171: OPEN / DRAFT; exact HEAD `4ec33de7438fcbd15ed63b1ae2adda127da3be8c`; Ready/merge yapılmadı.
- Firestorage file id `01a06e6342ff774994dd33280571724e`: 42 chunk index `0..41`, 42/42 expected Git blob SHA ve strict base64 decode PASS.
- Rebuilt ZIP: 557120 bayt PASS; SHA256 `d219c6233fa27f5e3e04687ec5fd15dab1f24500584e78d6a7c80036ee68f5ca` PASS; ZIP integrity PASS.
- Runtime asset QA: 48/48 WebP PASS; 41 core + 7 optional island variant PASS; 48/48 decode/alpha PASS. Bu raw Android görsel PASS değildir.
- Materialization run `33923955868`, job `101188228034`: SUCCESS.
- Asset branch `feat/kelime-avi-gokyuzu-runtime-assets`; tek temiz commit `8508e6bfe03d0772cf2bd371d9d3ea4b4177b7fb` (`feat(kelime-avi): add gokyuzu runtime assets`); parent exact canonical `3557a7e4f2f2917d61ba61866c6d4c8561994667`.
- Exact compare: ahead_by=1, behind_by=0, total_commits=1; yalnız `assets/word_hunt/gokyuzu_adalari/*.webp`; 48 changed file. Final ürün tree'sinde transfer XLSX/ZIP/workflow/chunk kalıntısı yok.
- Asset PR #172: OPEN / DRAFT; base `3557a7e4...`, head `8508e6bf...`, 1 commit / 48 file; Ready/merge yapılmadı.
- Bu checkpoint sırasında #172 otomatik kontrolleri sürüyor; ASSET_PR_PASS henüz verilmedi.
- Flutter rota entegrasyonu #172 gerçek PASS sonrası ayrı branch/PR olarak BEKLİYOR.
- Android 16 raw screenshot + crash/ANR/log ve Levent gerçek cihaz görsel kabulü BEKLİYOR.
- `assets/questions.json`, BoardMap/67 node, Firebase, AdMob, signing, package/version ve Play release'e dokunulmadı. Play yalnız Levent'in ayrı açık onayıyla.
