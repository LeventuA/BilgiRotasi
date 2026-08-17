# PR #49 — Production rewarded SSV istemci bağlantısı

**Tarih:** 17 Ağustos 2026

## Canlı taban

- Repo: `ZMilaStudio/BilgiRotasi`
- Release: `release/final-closed-test-aab-1.68.8`
- Release taban SHA: `ef3f6d34bb6fa4bedf7159d52062b8cd4de79455`
- Release taban commit: `fix: align production rewarded SSV with per-game rewards (#48)`
- Sürüm: `1.68.16+106`
- Branch: `feat/production-rewarded-ssv-client-20260817`
- Draft PR: #49 — `feat: wire production rewarded SSV client`
- Teknik head: `e777c59ebd2bddd5d9e6120b6b9b42b0a9f7097a`

## Ürün kararı

`KARARLAR.md` reklam sözleşmesi değişmedi: ödüllü reklam kullanıcı isteğiyle açılır, ödül +10 XP'dir, günlük/oturumluk toplam kota yoktur, her tamamlanan oyun bir kez ödül hakkı üretir ve aynı tamamlanan oyun ikinci ödülü vermez.

## İstemci bağlantısı

- Production rewarded akışı reklamı göstermeden önce `issueRewardNonce(gameId)` callable'ını çağırır.
- Geçerli Firebase kullanıcısının `uid` değeri ve callable'ın döndürdüğü `customData`, Google `ServerSideVerificationOptions` üzerinden yüklü RewardedAd'e bağlanır.
- Boş `gameId`, oturumsuz kullanıcı, callable hatası veya boş `customData` production yolunda fail-closed davranır; reklam gösterilmez.
- Test/closed-test yolu Google test reklamlarıyla mevcut davranışı korur.
- Production destek ödülü yalnız `ADMOB_ENVIRONMENT=production` ile birlikte Firebase production runtime aktifse açılır.
- Sonuç kartı kendi tamamlanan `gameId` değerini rewarded gösterimine taşır.

## Teknik commitler

- `6c5870099df65276684150125b157c7fc1b5632e` — `feat: wire production rewarded SSV client`
- İlk diff incelemesinde SSV ile ilgisiz `AdBannerScaffold.floatingActionButton` tip daralması yakalandı ve ayrı commit ile geri alındı:
  `804b39901b340d3754565db0def67927824d18fc` — `fix: preserve ad scaffold API`
- `e777c59ebd2bddd5d9e6120b6b9b42b0a9f7097a` — `test: lock production rewarded SSV client`

Teknik head PR metadata'sı: 3 commit, 2 değişen dosya, +115/-6. Teknik dosyalar yalnız `lib/ad_monetization.dart` ve `test/ad_monetization_test.dart`.

## Teknik-head CI kanıtı

AdMob PR doğrulaması #220:

- Run: `32034061748`
- Job: `95400254716`
- Sonuç: **SUCCESS**
- Analyze + tüm Flutter testleri: **PASS**
- Test-ID release APK build: **PASS**
- Paket + birleşik manifest doğrulaması: **PASS**
- Android 16 clean cold-start attempt 1: **PASS**
- Attempt 1 classifier: **PASS**
- Attempt 2: gerekmedi / SKIPPED
- Final app/release gate: **PASS**

Artifact:

- Ad: `BilgiRotasi-AdMob-1.68.16-106-kanitlari`
- ID: `9290391355`
- Digest: `sha256:90cdc33489b100eb3f19d544699eba54c051cde55528c9c07148807c76c41dcd`
- Head SHA: `e777c59ebd2bddd5d9e6120b6b9b42b0a9f7097a`
- Artifact içi `ADMOB_ANDROID16_VALIDATION_RESULT.txt`: `RESULT=PASS`, `RELEASE_GATE=PASS`, `APP_GATE=PASS`
- Artifact içi app gate: `APK_INSTALL=PASS`, `APP_LAUNCH=PASS`, `APP_PID=PASS`, `APP_ACTIVITY=PASS`, `APP_LOGCAT=PASS`, `APP_GATE=PASS`
- APK SHA-256: `8206c86721418b94d902fb284a927f46fa7a76f03fb70cec310a2dd939787cc3`
- Signing SHA-1: `000ee43f410abc6b4f634c4f716d76eb19084115`

GitHub connector'ın job-log endpoint'i tamamlanmış job için boş içerik döndürdü; ham Actions job-log metni bu araç üzerinden ayrı okunamadı. Buna karşılık yapılandırılmış job adımları, artifact metadata'sı ve artifact içindeki Android 16 cold-start/logcat/gate raporları doğrulandı. Bu araç kısıtı gizlenmemiştir.

## DOĞRULANACAK — XP otoritesi / uzlaştırma

İstemci görünür XP'yi `XpProgressService` ile yerel `bilgi_rotasi_xp_progress_v1` kaydında tutar ve `awardSupportAd()` yerel toplam XP'ye +10 ekler. Hesap bulut snapshot sistemi `bilgi_rotasi_` anahtarlarını senkronize eder.

PR #48 SSV backend'i ise doğrulanmış callback'te ayrı olarak `users/{uid}.serverRewardXp` alanını +10 artırır. Repo içinde `serverRewardXp` alanını okuyup yerel `XpProgressService.totalXp` ile uzlaştıran istemci yolu bulunamadı.

Bu nedenle PR #49 için doğrulanmış iddia **SSV `uid/custom_data/gameId` istemci bağlantısının tamamlanmasıdır**. Tam sunucu-otoriteli XP uzlaştırması çözülmüş veya fiziksel olarak doğrulanmış sayılmaz; sonraki production SSV cutover/acceptance çalışmasında açıkça ele alınmalıdır.

## Kapsam sınırı

Bu PR ile:

- Firebase Functions deploy edilmedi.
- `server_config/rewarded.ssvEnabled` değiştirilmedi.
- AdMob SSV callback URL'si yapılandırılmadı.
- Gerçek production reklamı fiziksel cihazda test edilmedi/tıklanmadı.
- `assets/questions.json`, Firestore Rules, BoardMap, 67 node, 3B tahta, Canlı Düello ve sürüm değiştirilmedi.
- `KARARLAR.md` değişmedi; yeni ürün kararı alınmadı.

## Merge kapısı

Bu dosya commitlendikten sonra oluşan yeni PR head'inde fresh CI yeniden PASS olmadan PR #49 merge edilmeyecek. Ayrıca Levent'in PR #49 için açık merge onayı gerekir.
