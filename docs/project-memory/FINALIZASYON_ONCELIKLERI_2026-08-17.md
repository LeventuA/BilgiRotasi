# Bilgi Rotası — Üretim Öncesi Finalizasyon Öncelikleri

**Tarih:** 17 Ağustos 2026
**Amaç:** Yeni özellik eklemeden, üretim öncesi yarım kalan entegrasyonları tamamlamak ve tek bir dondurulmuş kaynak sürümünü production adayı haline getirmek.

## Yayın stratejisi

- Bugün yeni özellik geliştirme durdurulur; yalnız production finalizasyonu yapılır.
- Tüm teknik düzeltmeler ayrı branch / test / commit / push / Draft PR / inceleme / açık merge onayı sırasıyla ilerler.
- Final kaynak commit fiziksel ve CI kabulünden sonra dondurulur.
- Google Play production erişimi final kaynak commit hazır olmadan gelirse acele yayın yapılmaz; önce aşağıdaki P0 kapıları tamamlanır.
- Final imzalı APK mevcut Play kurulumunun üzerine veri silmeden kurulabiliyor ve iki cihaz kabulü yapılabiliyorsa ayrıca bir Play closed-test güncellemesi zorunlu değildir; production onayı geldiğinde tek production güncellemesi hedeflenir.
- İmzalı APK mevcut Play kurulumunun üzerine kurulamıyorsa veya Play dağıtımı üzerinde fiziksel kabul zorunlu kalırsa, production onayından önce yalnız **bir son closed-test güncellemesi** yapılır. Bu durumda production sürümü aynı dondurulmuş kaynak davranışından üretilir; yalnız production AdMob profili ve zorunlu yeni versionCode farkı bulunur.
- Closed-test paketlerinde Google test reklamları korunur. Gerçek AdMob kimlikleri yalnız production profilli build'de kullanılır.

## P0 — Bugün bitmeden kapanması gerekenler

### P0.1 — Canlı Düello istemci senkronizasyonu / PR #47

- PR #47 tam diff, Git geçmişi ve CI log/artifact birlikte incelenecek.
- Eşleşme oluşturulduğu halde ikinci oyuncunun `Rakip bulunuyor` ekranında kalması giderilecek.
- `inactive` durumunun yanlış disconnect üretmesi giderilecek; gerçek background yalnız güvenilir lifecycle durumlarında işlenecek.
- Merge yalnız Levent'in açık onayıyla yapılacak.
- Düzeltmeli client ile iki fiziksel cihaz / iki ayrı hesap kabulü tekrarlanacak.
- 10/20/30 soru eşleşme; aynı soru/sıra; skor/ilerleme; normal finalize; BR/lig/leaderboard; tekrar-finalize idempotency; bilinçli ayrılma/forfeit kontrol edilecek.

### P0.2 — `Yarım Kalan Düello` / stale resume doğrulaması

- Videoda gözlenen sonuç sonrası `Yarım Kalan Düello` kartının hangi match kaydından üretildiği canlı veriyle doğrulanacak.
- Tahminle yama yapılmayacak.
- Tamamlanmış/forfeit sonucu işlenmiş maçın yeniden aktif gibi sunulduğu kanıtlanırsa minimum düzeltme ve regresyon testi yapılacak.

### P0.3 — Tüm tamamlanan oyunlarda `Bize destek olmak ister misiniz?`

Kesin ürün kararı korunur:

- Kullanıcıya reklam zorlanmaz.
- Sonuç kartı metni: `Bize destek olmak ister misiniz?`
- Reklam tamamlanırsa `+10 XP`.
- Her **tamamlanan oyun** bir kez hak üretir.
- Aynı oyun ikinci kez ödül vermez.
- Günlük/oturumluk toplam kota yoktur.
- Aktif soru/oyun/canlı maç akışı reklamla kesilmez.
- Abandon/kaçış/forfeit gibi tamamlanmamış veya suistimale açık sonuçlar otomatik olarak ödül hakkı sayılmaz; ürün kararı ve server doğrulamasıyla açıkça sınıflandırılır.

Yapılacaklar:

- Bütün sonuç ekranları envanterlenecek; kart yalnız tek bir modda kalmayacak.
- Tahta, maraton, meydan okuma, günlük görev, hızlı/diğer modlar ve normal tamamlanan Canlı Düello dahil desteklenen her tamamlanmış sonuç için benzersiz `gameId` üretimi doğrulanacak.
- Aynı `gameId` ikinci ödülü açmayacak.
- Reklam yarıda kapanır/başarısız olursa XP verilmemesi ve hak gerçekten tüketilmediyse yeniden deneme davranışı doğrulanacak.

### P0.4 — Production ödüllü reklam SSV güvenlik cutover'ı

Mevcut repo durumu production için tamamlanmış sayılmaz:

- `functions/rewarded_ssv.js` içinde `issueRewardNonce` ve `rewardedSsvCallback` hazırlığı vardır.
- Bu Functions production'a deploy edilmemiştir.
- İstemci şu an production sonuç reklamını bilerek kapatır.
- Mevcut SSV hazırlığındaki günlük `3 reklam / +30 XP` sınırı güncel ürün kararıyla çelişir ve kaldırılmadan/yeniden tasarlanmadan production cutover yapılmaz.

Bitti ölçütü:

- SSV modeli `her tamamlanan gameId için en fazla bir +10 XP` kararına bağlanır; günlük toplam kota kullanılmaz.
- Nonce kısa ömürlü ve tek kullanımlık kalır.
- `transaction_id` idempotency korunur.
- `gameId`/UID server tarafında nonce/custom data ile bağlanır; client tek başına XP yazamaz.
- Google SSV imzası ve `key_id` doğrulaması fail-closed kalır.
- AdMob callback URL ve test aracıyla gerçek callback doğrulanır.
- `server_config/rewarded.ssvEnabled` yalnız gerçek kabul PASS sonrası açılır.
- İlgili Functions kontrollü deploy edilir; ilgisiz Functions değiştirilmez.

### P0.5 — Production AdMob finalizasyonu

- Production App ID, banner ve rewarded unit ID'leri canlı konfigürasyonla doğrulanır.
- Kalıcı release signing sertifikası production guard ile doğrulanır.
- UMP/privacy akışı fiziksel cihazda doğrulanır.
- `app-ads.txt` yayın ve AdMob doğrulama durumu kontrol edilir.
- Production AAB'de Google demo/test kimlikleri kullanılmadığı statik/artifact kontrolüyle kanıtlanır.
- Gerçek reklamlar geliştirici/test cihazında normal kullanıcı trafiği gibi tıklanmaz; gerekiyorsa AdMob test-device mekanizması kullanılır.
- Production ödüllü `+10 XP` ancak P0.4 SSV kapısı PASS olduktan sonra açılır.

### P0.6 — Canlı Düello Firebase kapanışı

- Production'da yazılmış 8.710 `live_duel_answer_keys` ve `live_duel_config/question_catalog` korunur ve son read-only sayım/hash doğrulaması yapılır.
- Kanonik 3 composite index READY kalmalıdır.
- Altı Canlı Düello callable Function + `claimUsername` ACTIVE doğrulanır.
- `cleanupLiveDuelData` scheduler ihtiyacı ve production deploy'u kontrollü tamamlanır; ilgisiz Functions'a dokunulmaz.
- Uyumlu final client fiziksel kabul edilmeden closed-write Firestore Rules cutover yapılmaz.
- Final client kabulünden sonra gerekli Rules cutover yapılırsa Rules emulator testi + production read/write smoke birlikte kanıtlanır.

### P0.7 — Final regresyon ve yayın kapısı

Final kaynak commit için en az:

- `flutter analyze` PASS.
- Tüm Flutter testleri PASS.
- Firebase Functions testleri PASS.
- Firestore Rules emulator testleri PASS.
- Android 16 release gate PASS; crash/ANR/FATAL/process-death yok.
- Google giriş / misafir / hesap izolasyonu / bulut kayıt regresyonu PASS.
- FCM izin/ayar regresyonu PASS.
- Öğretici yeniden gösterme PASS.
- Ad banner allow-list ve aktif soru ekranında reklam olmaması PASS.
- Ödüllü reklam başarısızlık/başarı/idempotency PASS.
- Canlı Düello iki cihaz kabulü PASS.
- `assets/questions.json`, BoardMap, 67 node ve 3B tahta bu finalizasyon işlerinde kontrolsüz değiştirilmez.

## P1 — P0 sonrası paketleme

- Final versionName/versionCode, canlı `pubspec.yaml` ve Play kullanılan kodlar kontrol edilerek seçilir; önceden tahmin edilmez.
- `BILGI_ROTASI_DURUM.md`, `GOREV_HAVUZU.md`, değişen karar varsa `KARARLAR.md`, yeni açık doğrulama varsa `ACIK_SORULAR_VE_DOGRULAMALAR.md` final kanıtlarla güncellenir.
- Final branch/commit/PR/test/artifact SHA'ları kaydedilir.
- Kaynak commit dondurulur; bundan sonra yalnız blocker düzeltmesi kabul edilir.

## Production onayı geldiğinde

- P0/P1 tamamlanmadan yayın yapılmaz.
- Mümkünse dondurulmuş final kaynak committen tek production güncellemesi üretilir.
- Closed-test üzerinde son Play kabulü zorunlu olmuşsa production build aynı davranışsal kaynak sürümden, gerçek AdMob profili ve yeni zorunlu versionCode ile üretilir.
- Production rollout sonrası ilk saat/gün crash, ANR, Firebase Function hataları, AdMob/SSV callback ve canlı düello hata oranları izlenir.

## Şu anki canlı referans

- Release branch: `release/final-closed-test-aab-1.68.8`
- Release HEAD: `45ab749afc46621d86bb50848048beda96e9171f`
- Sürüm: `1.68.16+106`
- Canlı Düello istemci düzeltmesi: Draft PR #47 / head `f78c1d80a187042d341165aa57ddd738beb41a8e`
- PR #47 AdMob PR doğrulaması #213 / run `32010929783`: `SUCCESS` (tam log/diff/artifact incelemesi merge kapısından önce ayrıca yapılır).
- Merge yapılmamıştır.