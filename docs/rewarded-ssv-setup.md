# Ödüllü reklam SSV hazırlığı

Tahta jokeri yerel ve rekabetçi olmayan ödül olarak değişmeden kalır. Production
Google hesabında sonuç ekranından kazanılan +10 XP için `issueRewardNonce`,
`rewardedSsvCallback` ve caller-scoped `getRewardedGameState` sözleşmesi kullanılır.

## Güncel ürün sözleşmesi

- Her tamamlanan oyun en fazla bir +10 XP ödül hakkı üretir.
- Aynı tamamlanan oyun ikinci kez XP üretmez.
- Farklı tamamlanan oyunlar için günlük veya oturumluk toplam kota yoktur.
- `transaction_id` idempotency ve oyun-başına claim birlikte korunur.
- Misafir sonuç ödülü Firebase Auth UID olmadığı için yerel hak olarak kalır.
- Tahta üzerindeki rastgele joker reklamı bulut XP üretmediği için SSV kullanmaz.

## Güvenli production akışı

1. Sunucu kısa ömürlü, tek kullanımlık nonce ve `custom_data` üretir; veriler
   Firebase Auth UID ve tamamlanan `gameId` ile bağlıdır.
2. İstemci, production Google hesabı + sonuç XP akışında ödüllü reklamı
   göstermeden önce AdMob SSV seçeneklerine bu veriyi ekler.
3. Callback ham sorgu sırasını değiştirmeden Google ECDSA anahtarıyla doğrulanır;
   doğrulama anahtarları en fazla 24 saat cache edilir.
4. `transaction_id` tekil belge olur; Google aynı callback'i tekrar gönderirse
   ikinci XP üretilmez.
5. `rewarded_game_claims` aynı kullanıcı + tamamlanan oyun için tek claim tutar;
   başka tamamlanan oyunlara günlük/oturumluk toplam kota uygulanmaz.
6. Callback doğrulanırsa sunucu +10 XP claim'ini ve `serverRewardXp` denetim
   toplamını yazar.
7. İstemci, Google reward callback'ini tek başına yeterli saymaz; sınırlı süre
   `getRewardedGameState(gameId)` ile sunucu claim'ini doğrular. Claim
   doğrulanmazsa yerel +10 XP verilmez ve yerel oyun hakkı tüketilmez.
8. `server_config/rewarded.ssvEnabled` varsayılan/eksik durumda normal ödül callback'i
   503 döndürür ve sunucu claim'i oluşmaz.

## Canlı açılış kapısı

Repo sözleşmesi ile production deploy/cutover aynı şey değildir. Aşağıdakiler
canlı servis üzerinden ayrıca doğrulanmadan `ssvEnabled` açılmamalı ve production
rewarded hazır sayılmamalıdır:

- `issueRewardNonce`, `getRewardedGameState` ve `rewardedSsvCallback` fonksiyonlarının
  doğru production Firebase projesine kontrollü deploy'u,
- AdMob Console SSV callback URL'si ve test aracının başarılı doğrulaması,
- gerçek Google verifier public-key dönüşü,
- fiziksel production/staging akışında tamamlanan reklam -> tek +10 XP,
- aynı `gameId` için ikinci ödül yok ve başarısız/yarım reklam sonrası hakkın
  korunması.

Bu doğrulamalar tamamlanana kadar durum **DOĞRULANACAK** olarak kalır. Secret,
özel anahtar, testçi e-postası veya parola repoya eklenmez.

## Kontrollü production deploy planı

Kanonik Firebase projesi `bilgi-rotasi-f255d`, üç endpoint'in region'ı
`europe-west1`'dır. Repoda `.firebaserc` olmadığı için bütün salt-okunur envanter
ve deploy komutları explicit `--project bilgi-rotasi-f255d` taşır.

Önce mevcut canlı envanter salt-okunur olarak alınır:

```sh
firebase functions:list --project bilgi-rotasi-f255d
gcloud functions list --v2 --regions europe-west1 --project bilgi-rotasi-f255d
```

Canlı revision, region ve isimler kayıt altına alındıktan sonra yetkili operatör
yalnız aşağıdaki üç fonksiyonu seçerek deploy eder; blanket `--only functions`
kullanılmaz:

```sh
firebase deploy \
  --only functions:issueRewardNonce,functions:getRewardedGameState,functions:rewardedSsvCallback \
  --project bilgi-rotasi-f255d
```

Deploy kimliği için yerel/CI ortamında Application Default Credentials gerekir.
Desteklenen credential adları değerleri repoya yazılmadan şunlardır:

- `GOOGLE_APPLICATION_CREDENTIALS` (yetkili deploy service-account JSON yolunu
  gösteren ortam değişkeni), veya
- `gcloud auth application-default login` ile oluşturulan operatör ADC oturumu.

CI daha sonra Workload Identity Federation'a geçirilirse provider ve deploy
service account tanımları secret/değişken olarak tutulmalıdır; mevcut repoda bu
isimler tanımlıymış gibi varsayılmaz. SSV doğrulama kodu için ayrıca private key
runtime secret'ı yoktur; Google verifier public key'leri resmi HTTPS endpoint'inden
alınır.

## AdMob callback ve güvenli açılış sırası

Production callback adresi:

```text
https://europe-west1-bilgi-rotasi-f255d.cloudfunctions.net/rewardedSsvCallback
```

1. Deploy sonrasında üç endpoint'in isim/region/revision envanteri yeniden alınır.
2. `server_config/rewarded.ssvEnabled` eksik veya `false` bırakılır; normal callback'in
   `503 SSV_NOT_ENABLED` ile fail-closed kaldığı doğrulanır.
3. AdMob Console production rewarded biriminin SSV test aracında yalnız URL doğrulaması
   için şu sabit test değerleri kullanılır:

```text
User ID: bilgi-rotasi-ssv-verify
Custom data: bilgi-rotasi-ssv-verify-v1
```

4. Callback bu iki değer birlikte geldiğinde dahi Google ECDSA imzasını zorunlu
   doğrular. İmza geçersizse `400 INVALID_SIGNATURE`; imza geçerliyse yalnız
   `200 SSV_VERIFY_OK` döndürür. Verify-only yol nonce, claim, transaction veya XP
   yazmaz ve `ssvEnabled` açmaz.
5. Verify-only değerleri dışında kalan normal callback'lerde `ssvEnabled` eksik/false
   iken `503 SSV_NOT_ENABLED` davranışı korunur.
6. AdMob `Verify URL` aracı PASS olduktan sonra public-key/imza akışı ve write-free
   davranış canlı log/veri kanıtıyla doğrulanır.
7. Gerçek test transaction'ının tek kayıt oluşturduğu, aynı `transaction_id` ve aynı
   `gameId` tekrarlarının ikinci XP üretmediği gözlenir.
8. Fiziksel production/staging Google hesabında tamamlanan oyun için tek +10 XP,
   başarısız/yarım reklamda XP verilmemesi ve hakkın korunması doğrulanır.
9. Ancak bu kanıtlar kaydedildikten ve ayrıca açık cutover onayı verildikten sonra
   `ssvEnabled: true` düşünülebilir.

Doğrulama uygulaması Google'ın resmî SSV kılavuzundaki ham sorguyu değiştirmeme,
`signature`/`key_id`, ECDSA ve 24 saatten uzun anahtar cache etmeme kurallarına
göre hazırlanmıştır:
https://developers.google.com/admob/android/ssv
