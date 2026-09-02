# Bilgi Rotası — Açık Sorular ve Doğrulamalar

**Son güncelleme:** 2 Eylül 2026 — B5 tuning adayı Android teknik PASS

## Kelime Avı V6

Kapanan kabul/doğrulama kapıları:
- `USER_VISUAL_ACCEPTANCE_INITIAL` — Raw Android initial görünüm: **PASS / KAPANDI**.
- `USER_VISUAL_ACCEPTANCE_FOUND` — Edge-fuse found-state: **PASS / KAPANDI**; Android 16 run `33486609120`.
- `ERROR_STATE_VISUAL` — Bordo/kırmızı error-state: **PASS / KAPANDI**; Android 16 run `33524578623`; fill `0xB35A1F2B`, border `0xFFFF6B57`, 280 ms unchanged.
- `COMPLETION_AUTO_REPLAY` — Tüm target+bonus tamamlanınca otomatik popup ve fresh replay’de yeniden tetikleme: **PASS / KAPANDI**.
- `COMPLETION_POPUP_VISUAL` — Premium liman temalı sonuç popup’ı: **PASS / KAPANDI**.
- `COMPLETION_POPUP_COMPACT_VISUAL` — Kullanıcı isteğiyle küçültülen kompakt sonuç popup’ı: **PASS / KAPANDI — 2 Eylül 2026**.
- Exact compact tested commit: `7fa81663cb93c3f9f43b5c1bb7cd8f4d11929fd8`.
- Exact compact tested/product blob: `6ce2830a7df8eb696a9df589c91c544df7712969`.
- Final clean Android 16 compact run: `33655562508` — **SUCCESS**.
- PR #163 ürünizasyon commit: `9a6fede2c4aed4fdbaa6c9ba427fa84e0ce418da`.

İnsan süre-zorluk doğrulaması:
- `B5_60S_HUMAN_PLAYTEST` — **115 sn / 2 hata**; 60 sn soft challenge hedefi **KARŞILANMADI**. Test tamamlandı, denge kararı açık.
- `B10_120S_HUMAN_PLAYTEST` — **109 sn / 4 hata**; 120 sn soft challenge hedefi **KARŞILANDI / PASS**.
- Overall human timing: **MIXED**. Scripted QA 20/23 sn değerleri insan playtesti değildir.

Açık kalanlar:
- `B5_60S_TUNED_HUMAN_PLAYTEST` — Yeni 8×8 B5 yerleşim adayı (`44ebec6b...`) Android 16 run `33670657723` ile teknik PASS aldı; gerçek kullanıcı süresi/hatası: **BEKLİYOR**.
- `B5_60S_BALANCE_DECISION` — Yeni adayın insan testi sonrası kabul/red ve ürünizasyon kararı: **AÇIK**.
- `REFERENCE_FONT` — Runtime generic `serif`; custom font asset/source yok. Exact aile mevcut kaynaklardan kanıtlanamıyor: **DOĞRULANACAK / DEFERRED**.
- `PR_161_READY_DECISION` — Parent V5 PR #161 Ready kararı: **AÇIK**.
- `PR_162_READY_DECISION` — V6 visual PR #162 Ready kararı: **AÇIK**.
- `PR_163_READY_DECISION` — Güncel V6 ürün PR #163 Ready kararı: **AÇIK**.
- `PRODUCTION_MAIN_NAVIGATION` — `lib/main.dart` production ana navigasyon entegrasyonu ayrı scope: **AÇIK**.

## Merge güvenliği

PR #161, #162 veya #163, Levent’in ayrı ve açık merge onayı olmadan merge edilmeyecek. Görsel PASS, Ready veya merge onayı değildir.
