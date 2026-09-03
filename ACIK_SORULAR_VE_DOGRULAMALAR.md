# Bilgi Rotası — Açık Sorular ve Doğrulamalar

**Son güncelleme:** 3 Eylül 2026 — PR #162 merge tamamlandı; açık zincir PR #161’e taşındı

## Kelime Avı V6

Kapanan kabul/doğrulama kapıları:
- `USER_VISUAL_ACCEPTANCE_INITIAL` — Raw Android initial görünüm: **PASS / KAPANDI**.
- `USER_VISUAL_ACCEPTANCE_FOUND` — Edge-fuse found-state: **PASS / KAPANDI**; Android 16 run `33486609120`.
- `ERROR_STATE_VISUAL` — Bordo/kırmızı error-state: **PASS / KAPANDI**; Android 16 run `33524578623`.
- `COMPLETION_AUTO_REPLAY` — **PASS / KAPANDI**.
- `COMPLETION_POPUP_VISUAL` — Premium liman temalı sonuç popup’ı: **PASS / KAPANDI**.
- `COMPLETION_POPUP_COMPACT_VISUAL` — **PASS / KAPANDI**; final Android 16 run `33655562508`.
- `B5_60S_BALANCE_DECISION` — tuning sonrası **32 sn / PASS / KAPANDI**.
- `SWIPE_FALSE_POSITIVE_MISTAKES` — Fast `33724552713` + Android 16 `33724549202`: **PASS / KAPANDI**.
- `PR_167_READY_MERGE` — **PASS / KAPANDI**; merge `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.
- `PR_163_READY_MERGE` — **PASS / KAPANDI**; merge `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`.
- `PR_162_READY_MERGE` — **PASS / KAPANDI**; merge `929bb13177e03a0962464e21f6c174d4b3439349`.

İnsan süre-zorluk sonucu:
- B5 ilk ölçüm: **115 sn / 2 hata**; 60 sn soft challenge karşılanmadı.
- B10: **109 sn / 4 hata**; 120 sn soft challenge **PASS**.
- B5 tuning sonrası: **32 sn / UI’da 2 false-positive kayıt**; süre PASS, bilinçli gerçek hata 0.

Açık kalanlar:
- `PR_161_READY_DECISION` — Parent V5/V6 birleşik PR #161 final inceleme + Ready kararı: **AÇIK**.
- `PR_161_MERGE_DECISION` — Ready sonrasında ayrıca Levent’in açık merge onayı gerekir: **AÇIK**.
- `PARENT_PR_158_CHAIN_DECISION` — PR #161 sonrası parent #158 zincir kararı: **AÇIK**.
- `PACKAGE_BASED_QA_IMPLEMENTATION` — 10 bölümlük tek branch, B1/B5/B10 insan örneklemesi ve tek paket QA APK: **KARAR VERİLDİ / UYGULANACAK**.
- `REFERENCE_FONT` — Runtime generic `serif`; exact aile mevcut kaynaklardan kanıtlanamıyor: **DOĞRULANACAK / DEFERRED**.
- `PRODUCTION_MAIN_NAVIGATION` — `lib/main.dart` production ana navigasyon entegrasyonu ayrı scope: **AÇIK**.
- `RELEASE_INTEGRATION` — PR zinciri tamamlandıktan sonra exact release-context entegrasyonu/CI ayrı kapıdır: **AÇIK**.
- `PLAY_RELEASE` — Play yayını ayrıca açık karar gerektirir: **AÇIK**.

## Merge güvenliği

- PR #161 merge edilmeden önce final diff/review + Ready kapısı tamamlanacak.
- PR #161 ve sonraki parent/release merge’leri Levent’in ayrı ve açık onayı olmadan yapılmayacak.
- Görsel/teknik PASS, Ready veya merge onayı değildir.
