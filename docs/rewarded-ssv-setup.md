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
8. `server_config/rewarded.ssvEnabled` varsayılan/eksik durumda callback 503
   döndürür ve sunucu claim'i oluşmaz.

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

Doğrulama uygulaması Google'ın resmî SSV kılavuzundaki ham sorguyu değiştirmeme,
`signature`/`key_id`, ECDSA ve 24 saatten uzun anahtar cache etmeme kurallarına
göre hazırlanmıştır:
https://developers.google.com/admob/android/ssv
