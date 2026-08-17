# PR #48 — Production rewarded SSV final doğrulama

**Tarih:** 17 Ağustos 2026

## Canlı taban

- Repo: `ZMilaStudio/BilgiRotasi`
- Release: `release/final-closed-test-aab-1.68.8`
- PR #48 taban SHA: `535465af74934fc98efe0e43cde81fae8a712794`
- Sürüm: `1.68.16+106`
- Branch: `fix/final-monetization-20260817`
- Final teknik head: `ea4529954e58820ebd4038355a88fcc1b16d5a91`

## Ürün sözleşmesi

Mevcut `KARARLAR.md` reklam kararı değişmedi: her tamamlanan oyun bir kez +10 XP hakkı üretir; aynı tamamlanan oyun ikinci ödülü vermez; günlük/oturumluk toplam kota yoktur.

PR #48 eski production SSV hazırlığındaki `rewarded_daily`, `daily-limit` ve `count >= 3` yolunu kaldırır. `issueRewardNonce` zorunlu `gameId` alır; nonce `uid + gameId` ile bağlanır. SSV custom data `uid + nonce + gameId` taşır. `rewarded_game_claims` kullanıcı+oyun düzeyinde idempotency sağlar; Google `transaction_id` tekrarları veya aynı oyun için ikinci callback yeniden XP üretemez.

## CI ve hata izi

İlk AdMob run #215 yalnız eski `test/backend_hardening_test.dart` sözleşmesinin hâlâ `count >= 3` beklemesi nedeniyle FAIL oldu. İlk kesin hata bu beklentiydi; ürün/güvenlik kapısı gevşetilmeden test güncel kararla hizalandı.

Final head üzerinde:

- Firebase güvenlik doğrulaması #18 / run `32021248072`, job `95361205006`: **SUCCESS**.
- Functions birim testleri: **29/29 PASS**.
- Firestore Rules emulator: **6/6 PASS**.
- AdMob PR doğrulaması #216 / run `32021248074`, job `95361205147`: **SUCCESS**.
- Analyze + tüm Flutter testleri: **PASS**.
- Test-ID release APK, paket/birleşik manifest, signing hazırlığı: **PASS**.
- Android 16 cold-start deneme 1 + classifier + final app/release gate: **PASS**; ikinci deneme gerekmedi.
- Artifact: `BilgiRotasi-AdMob-1.68.16-106-kanitlari`, ID `9285744331`, digest `sha256:dc86c7b10865c93cfb2d3a228d1f15950bbdff94f7f298bc8d24f449e85acc5d`.

## Final kapsam

Teknik değişiklikler yalnız:

- `functions/rewarded_ssv.js`
- `functions/rewarded_ssv_helpers.js`
- `functions/test/rewarded_ssv.test.js`
- `test/backend_hardening_test.dart`

Bu kayıt dışında `assets/questions.json`, BoardMap, 67 node, 3B tahta, Canlı Düello, Firestore Rules ve sürüm değişmedi.

## Yayın/deploy sınırı

PR #48 production reklamlarını açmaz. `server_config/rewarded.ssvEnabled` değiştirilmedi; Firebase Functions deploy edilmedi; AdMob SSV callback adresi yapılandırılmadı. Bunlar client production SSV bağlantısı tamamlandıktan sonra ayrı kontrollü adımlardır.

Levent, final inceleme temizse PR #48 için squash merge onayı verdi. Merge sonrası sıradaki ayrı görev production client `custom_data`/SSV bağlantısıdır. Functions deploy, AdMob callback/test ve fiziksel production reward kabulü bu iki iş bittikten sonraya bırakılmıştır.
