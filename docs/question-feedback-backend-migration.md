# Soru geri bildirimi backend geçiş planı

## Mevcut durum

Uygulama zorluk oylarını ve hatalı soru bildirimlerini sabit bir HTTPS Google
Apps Script adresine JSON düz metin olarak gönderiyor. İstemci alan/yerel kuyruk
sınırı ve cihaz başına kısa süreli hız sınırı uygular. Bunlar uç noktayı
dışarıdan gelen spam’e karşı tek başına korumaz.

## Hedef mimari

1. Uç noktayı Firebase callable/HTTP Cloud Function veya kimlik doğrulamalı API
   Gateway arkasına taşıyın.
2. App Check tokenını doğrulayın; hesaplı kullanıcıda Firebase Auth UID’yi,
   misafirde App Check ile ilişkili sınırlı kurulum kimliğini kullanın.
3. Sunucu tarafında UID/kurulum/IP karması için kayan pencere hız sınırı,
   gövde boyutu ve şema doğrulaması uygulayın.
4. HTML/script içeriğini hiçbir zaman render etmeyin; depolama ve moderasyon
   ekranlarında kaçışlayarak düz metin gösterin.
5. Apps Script’i yalnız yeni backend’in yetkili çağrısına açın veya tamamen
   kaldırın. Anahtarları Remote Config’e koymak güvenlik sınırı değildir.
6. Eski istemciler için geçiş dönemi ve kötüye kullanım ölçümü tanımlayın;
   yeni endpoint doğrulanmadan mevcut akışı gizlice kapatmayın.
7. Emulator/integration testlerinde başarı, hız sınırı, büyük gövde, bozuk JSON,
   yinelenen event ID ve App Check/Auth reddi senaryolarını çalıştırın.

Cloud Function ve Apps Script erişim değişikliği bu PR’da deploy edilmemiştir.
