# Bilgi Rotası — Açık Sorular ve Doğrulamalar

**Son güncelleme:** 3 Eylül 2026 — PR #161 final diff/review PASS; sıradaki açık kapı Ready kararı

## Kelime Avı

Kapanan kabul/doğrulama kapıları:
- `USER_VISUAL_ACCEPTANCE_INITIAL` — **PASS / KAPANDI**.
- `USER_VISUAL_ACCEPTANCE_FOUND` — **PASS / KAPANDI**; Android 16 `33486609120`.
- `ERROR_STATE_VISUAL` — **PASS / KAPANDI**; Android 16 `33524578623`.
- `COMPLETION_AUTO_REPLAY` — **PASS / KAPANDI**.
- `COMPLETION_POPUP_COMPACT_VISUAL` — **PASS / KAPANDI**; Android 16 `33655562508`.
- `B5_60S_BALANCE_DECISION` — tuning sonrası **32 sn / PASS / KAPANDI**.
- `SWIPE_FALSE_POSITIVE_MISTAKES` — Fast `33724552713` + Android 16 `33724549202`: **PASS / KAPANDI**.
- `PR_167_READY_MERGE` — **PASS / KAPANDI**; merge `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.
- `PR_163_READY_MERGE` — **PASS / KAPANDI**; merge `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`.
- `PR_162_READY_MERGE` — **PASS / KAPANDI**; merge `929bb13177e03a0962464e21f6c174d4b3439349`.
- `PR_161_FINAL_REVIEW` — **PASS / KAPANDI**; 33 dosya, protected scope temiz, review/thread yok, tek-kullanımlık QA workflow/script temizlendi.

İnsan süre-zorluk sonucu:
- B5 ilk ölçüm: **115 sn / 2 hata**; 60 sn soft challenge karşılanmadı.
- B10: **109 sn / 4 hata**; 120 sn soft challenge **PASS**.
- B5 tuning sonrası: **32 sn / UI’da 2 false-positive kayıt**; süre PASS, bilinçli gerçek hata 0.

Açık kalanlar:
- `PR_161_READY_DECISION` — PR #161 teknik Ready adayıdır; **AÇIK / Levent’in açık onayı gerekli**.
- `PR_161_MERGE_DECISION` — Ready sonrasında ayrıca Levent’in açık merge onayı gerekir: **AÇIK**.
- `PARENT_PR_158_CHAIN_DECISION` — PR #161 sonrası parent #158 zincir kararı: **AÇIK**.
- `PACKAGE_BASED_QA_IMPLEMENTATION` — 10 bölümlük tek branch, B1/B5/B10 insan örneklemesi ve tek paket QA APK: **KARAR VERİLDİ / UYGULANACAK**.
- `REFERENCE_FONT` — Runtime generic `serif`; exact aile mevcut kaynaklardan kanıtlanamıyor: **DOĞRULANACAK / DEFERRED**.
- `PRODUCTION_MAIN_NAVIGATION` — `lib/main.dart` production ana navigasyon entegrasyonu ayrı scope: **AÇIK**.
- `RELEASE_INTEGRATION` — PR zinciri tamamlandıktan sonra exact release-context entegrasyonu/CI ayrı kapıdır: **AÇIK**.
- `PLAY_RELEASE` — Play yayını ayrıca açık karar gerektirir: **AÇIK**.

## Merge güvenliği

- PR #161 Ready yapılmadan merge edilmeyecek.
- PR #161 ve sonraki parent/release merge’leri Levent’in ayrı ve açık onayı olmadan yapılmayacak.
- Görsel/teknik PASS, Ready veya merge onayı değildir.
