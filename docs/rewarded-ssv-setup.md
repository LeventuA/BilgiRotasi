# Ödüllü reklam SSV hazırlığı

Tahta jokeri yerel ve rekabetçi olmayan ödül olarak değişmeden kalır. Bulut
hesabına yazılan +10 XP için `rewardedSsvCallback` ve `issueRewardNonce`
hazırlanmıştır; production'a deploy edilmemiştir.

Güvenli akış:

1. Sunucu kısa ömürlü, tek kullanımlık nonce ve `custom_data` üretir.
2. İstemci ödüllü reklamı göstermeden önce AdMob SSV seçeneklerine bu veriyi
   ekler.
3. Callback ham sorgu sırasını değiştirmeden Google ECDSA anahtarıyla doğrulanır.
   Anahtarlar en fazla 24 saat cache edilir.
4. `transaction_id` tekil belge olur; aynı reklam ikinci XP'yi vermez.
5. Günlük üç işlem ve toplam +30 XP limiti sunucuda tutulur.
6. `server_config/rewarded.ssvEnabled` varsayılan/eksik durumda endpoint 503
   döndürür ve bulut XP vermez.

AdMob Console callback URL'si, test aracı, gerçek public key dönüşü ve istemci
custom-data cutover'ı doğrulanmadan `ssvEnabled` açılmamalıdır. Secret veya özel
anahtar gerekmez/commit edilmez. SSV hazır değilken production bulut +10 XP
kapalı kalmalı; yerel joker davranışı devam edebilir.

Doğrulama uygulaması Google'ın resmî SSV kılavuzundaki ham sorguyu değiştirmeme,
`signature`/`key_id`, ECDSA ve 24 saatten uzun anahtar cache etmeme kurallarına
göre hazırlanmıştır:
https://developers.google.com/admob/android/ssv
