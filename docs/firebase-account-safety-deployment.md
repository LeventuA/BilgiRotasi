# Firebase hesap güvenliği dağıtım rehberi

Bu dal yalnızca dağıtıma hazır kodu ve testleri içerir. Cloud Functions üretime
dağıtılmamış, App Check zorlaması açılmamış ve mevcut istemci hesap silme akışı
sunucu fonksiyonuna geçirilmemiştir.

## Hazırlık

1. Firebase projesinde Blaze planı ve Node.js 20 çalışma zamanını doğrulayın.
2. Yerel Firebase CLI oturumunun doğru projeyi gösterdiğini kontrol edin.
3. `firebase use` ile test ve production proje takma adlarını ayrı tutun.
4. Yönetici hesabına yalnız Firebase Admin SDK ile `admin` veya `moderator`
   custom claim'i verin. Servis hesabı anahtarını depoya koymayın.
5. Firestore için gereken sorgu indekslerini emulator/staging çıktısına göre
   oluşturun.

## Güvenli sıra

1. `functions` klasöründe bağımlılıkları temiz kurulumla yükleyin ve `npm test`
   çalıştırın.
2. Firestore Rules emulator testlerini staging proje ayarlarıyla çalıştırın.
3. Önce `adminResetUsername` fonksiyonunu staging'e dağıtın ve audit belgesini
   doğrulayın.
4. `requestAccountDeletion` fonksiyonunu staging'de sahte hesapla doğrulayın:
   kesinti sonrası aynı işlem kimliğiyle devam etmeli, ortak maç rakibinin skoru
   korunmalı ve Authentication hesabı en son silinmelidir.
5. Production dağıtımından sonra Flutter istemcisini callable fonksiyona geçiren
   ayrı cutover değişikliğini yayınlayın. O zamana kadar uygulama içinde
   “sunucu silme tamamlandı” iddiasında bulunmayın.
6. App Check metriklerini izleyip geçerli gerçek istemci oranı yeterli olduktan
   sonra `adminResetUsername` için enforcement'ı koruyun. Hesap silme fonksiyonunda
   enforcement ancak kullanıcıları kilitlemeyeceği doğrulandıktan sonra açılmalıdır.

## Geri alma

Yeni callable fonksiyon sürümünü geri alın; Firestore kurallarını gevşetmeyin.
`account_deletion_operations` kayıtlarını silmeyin: yeniden deneme ve destek
incelemesi için kişisel UID tamamlanan işlemde kaldırılır, operasyon durumu
saklanır.
