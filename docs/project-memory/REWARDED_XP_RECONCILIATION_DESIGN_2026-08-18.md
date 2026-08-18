# Rewarded XP — Server/Local Uzlaştırma Tasarımı

**Tarih:** 18 Ağustos 2026
**Durum:** Tasarım / deploy yok / merge onayı yok

## Canlı kaynakta doğrulanan mevcut davranış

- Yerel XP `lib/xp_progression.dart` içinde SharedPreferences tabanlı `bilgi_rotasi_xp_progress_v1` kaydında tutulur.
- Closed-test/test destek reklamında `awardSupportAd()` yerelde doğrudan `+10 XP` verir.
- Production rewarded SSV `functions/rewarded_ssv.js` içinde geçerli ve ilk kez gelen `uid + gameId` claim'i için `users/{uid}.serverRewardXp` değerini `+10` artırır; `rewarded_game_claims` aynı oyunu idempotent yapar.
- Production istemcide SSV kullanılırken aynı +10 XP'yi ayrıca optimistic local uygulamak çift sayım riski yaratır.
- `AccountCloudService` yerel XP/progress blob'u bulut kullanıcı kaydıyla senkronize eder. Bu nedenle salt cihaz-local bir `serverRewardXpApplied` watermark'ı çoklu cihazda güvenli değildir; cihazlar aynı server toplamını ayrı ayrı yerel XP'ye ekleyip sonra ortak cloud XP'ye taşıyabilir.

## Güvenlik gereksinimleri

1. Aynı tamamlanmış oyun yalnız bir kez reward claim üretir.
2. Aynı server reward, tek cihazda veya çoklu cihazda toplam XP'ye yalnız bir kez uygulanır.
3. Production'da reklam callback'i tek başına yerel +10 yazamaz; ödül server-confirmed olmalıdır.
4. Closed-test/test Google demo davranışı production SSV'ye bağımlı hale getirilmez.
5. Ağ/Functions hatası oyunun final sonucunu bozmaz; reward beklemede kalabilir.
6. Client, başka kullanıcının claim/XP durumunu sorgulayamaz veya uid seçemez.
7. Retry, app restart ve ikinci cihaz ödülü tekrar uygulamamalıdır.

## Önerilen mimari

### A. Server-authoritative cumulative watermark

`users/{uid}` altında server-owned iki alan tutulur:

- `serverRewardXp`: SSV'nin doğrulanmış toplamı.
- `rewardedXpApplied`: kanonik kullanıcı XP'sine daha önce uygulanmış server reward toplamı.

Yeni authenticated callable örneğin `reconcileRewardedXp()`:

1. `context.auth.uid` dışında uid kabul etmez.
2. Firestore transaction içinde kullanıcı kaydını tekrar okur.
3. `serverRewardXp` ve `rewardedXpApplied` sayılarını normalize eder.
4. `delta = max(0, serverRewardXp - rewardedXpApplied)` hesaplar.
5. `delta == 0` ise idempotent no-op döner.
6. `delta > 0` ise aynı transaction içinde kanonik hesap XP'sine **bir kez** ekler ve `rewardedXpApplied = serverRewardXp` yazar.
7. Son canonical XP / applied total / delta döner.

Bu model retry ve çoklu cihazda güvenlidir; watermark cihazda değil ortak sunucudadır.

### B. Kanonik XP sahipliği çözülmeden uygulanmamalı

Mevcut `users/{uid}.xp` alanı AccountCloudService tarafından client/cloud sync kapsamında yönetiliyor. Server transaction'ın aynı alana yazması, istemcinin eski snapshot'ı tekrar upload etmesi halinde lost-update riski doğurabilir.

Bu nedenle kodlamadan önce şu sözleşme seçilmelidir:

**Önerilen:** `users/{uid}.xp` için merge semantiği server-reward delta'yı kaybetmeyecek biçimde ayrıştırılsın. En temiz model:

- `baseXp` / mevcut oyun XP'si client-sync alanı olarak kalır.
- `serverRewardXp` server-only cumulative alan olur.
- gösterilen/kanonik toplam XP = `baseXp + serverRewardXp` veya server-owned hesaplanan toplam üzerinden okunur.

Ancak mevcut progression/seviye sistemi doğrudan tek `totalXp` beklediği için bu ayrım geniş migration gerektirebilir.

**Daha küçük geçiş alternatifi:** `reconcileRewardedXp()` kanonik `xp` ve watermark'ı transactionla günceller; AccountCloudService de cloud snapshot uygularken server tarafından daha yeni canonical XP'yi düşürmeyecek monotonic/merge kuralına geçirilir. Bu seçenek minimum migrationla uygulanabilir ama focused multi-device test zorunludur.

## PR #53'ün yeri

Draft PR #53'teki `getRewardedGameState(gameId)` caller-scoped ve read-only claim sorgusu UI için faydalıdır; belirli oyunun server tarafından claim edilip edilmediğini gösterebilir. Fakat tek başına çoklu cihaz XP uzlaştırmasını çözmez ve güncel release'e rebase edilmeden merge edilmemelidir.

## Production istemci davranışı

- Production rewarded tamamlandığında optimistic `awardSupportAd()` çağrısı yapılmaz.
- SSV claim doğrulandıktan/reconciliation tamamlandıktan sonra UI server-confirmed XP durumunu yeniler.
- Network gecikmesinde `Ödül doğrulanıyor`/yeniden kontrol edilebilir durum kullanılabilir; aynı `gameId` yeniden claim oluşturmaz.
- Closed-test/test profilinde mevcut Google demo + yerel +10 davranışı fiziksel test kolaylığı için korunabilir; production SSV path'iyle karıştırılmaz.

## Zorunlu test matrisi

- tek cihaz, ilk claim +10
- aynı gameId duplicate callback => toplam değişmez
- app restart sonrası retry => değişmez
- iki cihaz aynı hesap, aynı serverRewardXp => yalnız tek delta
- iki farklı tamamlanmış gameId => +20 toplam
- callable timeout sonrası transaction gerçekleşmişse retry no-op
- auth yok / başka uid denemesi => fail-closed
- malformed/negative server counters => fail-closed veya normalize, XP azaltılmaz
- eski cloud snapshot server reward'u geri alamaz
- production optimistic local +10 yok
- closed-test demo reward +10 regresyonu PASS

## Uygulama sırası

1. Güncel release'ten ayrı branch.
2. Önce server/client XP ownership sözleşmesini testlerle kilitle.
3. #53'teki read-only claim state değişikliğini güncel release diff'iyle yeniden değerlendir; gerekiyorsa temiz cherry-pick/reimplementation.
4. Reconciliation callable + multi-device/idempotency unit testleri.
5. Client production path değişikliği + focused Flutter testleri.
6. Full Functions/Rules + Flutter + Android CI.
7. Draft PR inceleme.
8. Levent açık merge onayı.
9. Merge sonrası production DRY-RUN/okuma doğrulaması.
10. Ayrı açık onay olmadan Firebase deploy veya `ssvEnabled` cutover yapılmaz.
