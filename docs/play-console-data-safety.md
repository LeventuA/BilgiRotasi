# Google Play Veri Güvenliği formu taslağı

Bu belge Play Console formunu otomatik doldurmaz. Yayıncı, güncel SDK
politikaları ve üretim yapılandırmasıyla karşılaştırarak manuel beyan vermelidir.

> **PR #15 notu:** Firebase Analytics için aşağıdaki satır bir yayın öncesi
> doğrulama taslağıdır. Bu belge Play Console'u değiştirmez. Production SDK
> davranışı, Firebase Console ayarları ve güncel Play Data Safety tanımları
> doğrulanmadan Console yanıtları güncellenmemelidir.

| Veri türü | Toplanma / paylaşım | Zorunluluk | Amaç |
|---|---|---|---|
| E-posta, görünen ad, Firebase UID | Google giriş seçilirse toplanır; Firebase ile işlenir | İsteğe bağlı | Hesap yönetimi ve kimlik doğrulama |
| Kullanıcı adı | Çevrimiçi kimlik/sıralama için toplanır ve diğer oyunculara gösterilir | Çevrimiçi özellikler için gerekli | Uygulama işlevi, topluluk |
| Oyun etkinliği, XP, seviye, başarımlar, ayarlar | Hesaplı bulut kayıt seçilirse Firestore’a gönderilir | İsteğe bağlı | Bulut yedekleme ve eşitleme |
| Pseudonymous app-instance ID; ekran, oyun modu, kategori, zorluk grubu, süre ve sonuç olayları; uygulama sürümü | Kullanıcı Analytics'e açıkça izin verirse Firebase Analytics tarafından işlenir | İsteğe bağlı; varsayılan kapalı | Analiz, ürün iyileştirme ve kapalı test davranışını ölçme |
| FCM kurulum tokenı, uygulama/cihaz teknik bilgisi ve genel duyuru topic aboneliği | Kullanıcı Ayarlar'dan bildirimleri açarsa Firebase Cloud Messaging tarafından işlenir; token hesap verisine yazılmaz veya uygulama sunucusunda saklanmaz | İsteğe bağlı; varsayılan kapalı | Uygulama işlevi ve genel duyuru teslimi |
| BR ve düello istatistikleri, maç/presence kayıtları | Canlı Düello kullanılırsa Firestore’a gönderilir | Özellik için gerekli | Çevrimiçi maç, güvenlik, sıralama |
| Soru geri bildirimi ve kullanıcı notu | Kullanıcı oy/bildirim gönderirse Apps Script’e gönderilir | İsteğe bağlı | Soru kalitesi ve destek |
| Reklam kimliği, IP/yaklaşık konum, cihaz/uygulama bilgisi, reklam etkileşimi ve tanılama | Google Mobile Ads SDK tarafından toplanabilir/paylaşılabilir | Reklam gösteriminde | Reklam, analiz, güvenlik ve sahtekârlık önleme |
| Yerel hata günlüğü | Yalnız cihazda tutulur; otomatik bulut yedeğine dahil edilmez | Uygulama işlevi | Tanılama ve kurtarma |

## Formda doğrulanacak beyanlar

- İnternet aktarımları Firebase, Google ve Apps Script HTTPS/TLS kanallarını kullanır.
- Kullanıcı uygulama içinden veya destek e-postasıyla silme talep edebilir.
- Google Sign-In/Firebase Auth hesap için; Firestore bulut kayıt ve Canlı Düello
  için; AdMob reklam için kullanılır.
- Firebase Analytics consent'i UMP reklam consent'inden ayrıdır. Analytics
  varsayılan kapalıdır; izin verildiğinde pseudonymous app-instance ID üretir,
  izin geri alındığında koleksiyon kapanır ve yerel Analytics verisi sıfırlanır.
- Analytics için uygulama etkileşimleri, cihaz/diğer tanımlayıcılar ve tanılama
  veri türlerinin güncel SDK davranışında Play tarafından nasıl sınıflandırıldığı
  yayın öncesinde doğrulanmalıdır. Reklam kimliği Analytics tarafında kapalıdır.
- Firebase Cloud Messaging SDK veri türleri ve FCM tokenının Play Data Safety
  sınıflandırması yayın öncesinde güncel Google SDK beyanıyla doğrulanmalıdır.
  Play Console bu belgeyle otomatik olarak değiştirilmez.
- AdMob SDK veri türleri, Google’ın güncel Data Safety rehberiyle yayın gününde
  tekrar karşılaştırılmalıdır.
- Veriler satılmaz; hizmet sağlayıcı aktarımının Play tanımında “paylaşım”
  istisnasına girip girmediği güncel form açıklamalarına göre manuel seçilmelidir.
- Uygulama 13+ hedeflidir; çocuklara yönelik değildir.
- 13–15 yaş kullanıcılar bazı bölgelerde dijital rıza yaşının altında olabilir.
  Güvenilir yaş doğrulaması bulunmadığından reklam ve UMP istekleri bütün
  kullanıcıların rıza yaşının üzerinde veya altında olduğunu varsayan sabit
  under-age sinyali göndermez.
- Hesap silme backend anonimleştirmesi ve saklama temizliği deploy edilmeden
  beyan “tam otomatik silme” olarak işaretlenmemelidir.
