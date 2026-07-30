# Google Play Veri Güvenliği formu taslağı

Bu belge Play Console formunu otomatik doldurmaz. Yayıncı, güncel SDK
politikaları ve üretim yapılandırmasıyla karşılaştırarak manuel beyan vermelidir.

| Veri türü | Toplanma / paylaşım | Zorunluluk | Amaç |
|---|---|---|---|
| E-posta, görünen ad, Firebase UID | Google giriş seçilirse toplanır; Firebase ile işlenir | İsteğe bağlı | Hesap yönetimi ve kimlik doğrulama |
| Kullanıcı adı | Çevrimiçi kimlik/sıralama için toplanır ve diğer oyunculara gösterilir | Çevrimiçi özellikler için gerekli | Uygulama işlevi, topluluk |
| Oyun etkinliği, XP, seviye, başarımlar, ayarlar | Hesaplı bulut kayıt seçilirse Firestore’a gönderilir | İsteğe bağlı | Bulut yedekleme ve eşitleme |
| BR ve düello istatistikleri, maç/presence kayıtları | Canlı Düello kullanılırsa Firestore’a gönderilir | Özellik için gerekli | Çevrimiçi maç, güvenlik, sıralama |
| Soru geri bildirimi ve kullanıcı notu | Kullanıcı oy/bildirim gönderirse Apps Script’e gönderilir | İsteğe bağlı | Soru kalitesi ve destek |
| Reklam kimliği, IP/yaklaşık konum, cihaz/uygulama bilgisi, reklam etkileşimi ve tanılama | Google Mobile Ads SDK tarafından toplanabilir/paylaşılabilir | Reklam gösteriminde | Reklam, analiz, güvenlik ve sahtekârlık önleme |
| Yerel hata günlüğü | Yalnız cihazda tutulur; otomatik bulut yedeğine dahil edilmez | Uygulama işlevi | Tanılama ve kurtarma |

## Formda doğrulanacak beyanlar

- İnternet aktarımları Firebase, Google ve Apps Script HTTPS/TLS kanallarını kullanır.
- Kullanıcı uygulama içinden veya destek e-postasıyla silme talep edebilir.
- Google Sign-In/Firebase Auth hesap için; Firestore bulut kayıt ve Canlı Düello
  için; AdMob reklam için kullanılır.
- AdMob SDK veri türleri, Google’ın güncel Data Safety rehberiyle yayın gününde
  tekrar karşılaştırılmalıdır.
- Veriler satılmaz; hizmet sağlayıcı aktarımının Play tanımında “paylaşım”
  istisnasına girip girmediği güncel form açıklamalarına göre manuel seçilmelidir.
- Uygulama 13+ hedeflidir; çocuklara yönelik değildir.
- Hesap silme backend anonimleştirmesi ve saklama temizliği deploy edilmeden
  beyan “tam otomatik silme” olarak işaretlenmemelidir.
