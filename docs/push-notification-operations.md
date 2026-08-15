# Bilgi Rotası genel bildirim operasyonu

Bu runbook genel duyuru altyapısını açıklar. Production bildirimi göndermek
ayrı bir yayıncı kararıdır; bu değişiklik hiçbir mesaj veya Firebase deploy
işlemi yapmaz.

## Güvenlik kapısı

1. Firebase Console üst çubuğunda proje kimliğini doğrula:
   `bilgi-rotasi-f255d`.
2. Gönderimden önce hedef ortamı yazılı olarak belirle. Kullanıcı kimliği,
   e-posta veya testçi adresi topic adına ya da mesaja eklenmez.
3. İlk denemeyi production topic'ine yapma. Önce development veya closed-test
   topic'inde fiziksel cihazla title/body, izin ve dokunma davranışını doğrula.
4. Console/CLI ekranında hedef topic'i son kez yeniden oku. Yanlış projeyi veya
   topic'i seçtiysen gönderimi iptal et.

## Topic'ler

| Profil | Topic |
|---|---|
| Development debug | `bilgi_rotasi_announcements_dev` |
| Play kapalı test | `bilgi_rotasi_announcements_closed_test` |
| Production | `bilgi_rotasi_announcements_production` |

Debug/test/CI derlemeleri uzak FCM'ye bağlanmaz. Kullanıcı Ayarlar'daki
`Genel duyuru bildirimleri` anahtarını açıp sistem iznini vermeden cihaz topic'e
abone edilmez.

## Firebase Console ile test gönderimi

1. Firebase Console → Messaging bölümünü aç.
2. Yeni notification campaign/message oluştur.
3. Kısa bir başlık ve gövde yaz. İlk sürüm dış payload'dan route/deep-link
   üretmez; bildirime dokunmak uygulamayı normal başlangıç ekranından açar.
4. Hedef olarak `Topic` seç ve yalnız doğrulanacak ortamın topic adını gir.
5. Android hedefini ve proje kimliğini tekrar kontrol et.
6. Önce closed-test fiziksel cihazına test mesajı gönder.
7. Uygulama foreground, background ve tamamen kapalı durumdayken ayrı ayrı
   doğrula. Foreground'da tek uygulama içi bildirim, background/terminated
   durumda tek Android sistem bildirimi beklenir.
8. Uygulama PID/logcat içinde crash, ANR veya `FATAL EXCEPTION` olmadığını
   kaydet.

## 30 Ağustos duyurusu

30 Ağustos başlık/gövdesi bu PR tarafından production'a gönderilmez. Metin,
zaman ve production hedefi Levent tarafından ayrıca onaylandıktan sonra yukarıdaki
kontrol listesi uygulanır. Yanlış gönderimi geri almak mümkün olmayabileceğinden
production campaign gönder düğmesi son adımdır.

## Fiziksel kabul kaydı

- Android sürümü ve uygulama sürümü
- kullanılan profil/topic
- izin kabul/red davranışı
- foreground/background/terminated teslim sonucu
- bildirim dokunuşuyla güvenli açılış sonucu
- uygulama crash/ANR/FATAL/process-death taraması

Gerçek FCM teslimi görülmeden bu maddeler `DOĞRULANACAK` olarak kalır.
