# Bulut kayıt revision ve güvenli geri yükleme

Yeni bulut kaydı `revision`, sunucu `updatedAt`, rastgele kalıcı
`deviceInstallationId` ve son yazan cihaz bilgisini taşır. Transaction,
istemcinin beklediği revision değişmişse eski kaydın yeniyi ezmesini reddeder.
İki farklı kayıt bulunduğunda kullanıcı “Bu telefonun kaydı” ile “Bulut kaydı”
özetlerini, XP/seviye, veri/kayıt sayısı ve son eşitleme zamanını görüp seçim
yapar.

Geri yükleme hedefi önce tamamen decode edilir; 700 KB, 500 alan ve şema sınırı
doğrulanır. Mevcut kayıt bir journal içine alınır. Yazma yarıda kalır veya
uygulama kapanırsa sonraki açılış journal yedeğini geri yükler. Başarıdan sonra
journal kaldırılır.

Eski schema 1 snapshot'lar okunur ve bir sonraki başarılı yazımda schema 2'ye
geçer. Production öncesi iki fiziksel cihazda aynı hesapla çakışma ve zorla
kapatma testi yapılmalıdır.
