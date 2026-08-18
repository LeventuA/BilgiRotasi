# Bilgi Rotası — +107 Fiziksel Kabul Planı

**Tarih:** 18 Ağustos 2026

Bu plan, PR #55 ve PR #57 davranışlarını içeren ilk Play Kapalı Test dağıtımı üzerinde uygulanacaktır. Uygulama silinmeyecek, uygulama verileri temizlenmeyecek ve mevcut hesap/XP/ayarlar korunacaktır.

## Ön koşullar

- Play'den dağıtılan paket en az `1.68.17+107` olmalı ve kaynak SHA'sı dağıtım artifact'iyle doğrulanmalı.
- Test iki gerçek Android cihaz ve iki ayrı kullanıcı hesabıyla yapılmalı.
- Closed-test AdMob profili Google test reklamlarını kullanmalı; gerçek production reklamlarına test tıklaması yapılmamalı.

## A. İlk kullanım / Analytics / bildirim kabulü

1. Güncel sürüm normal güncelleme yoluyla açılır.
2. Eski otomatik `Kullanım Analizine izin verilsin mi?` popup'ı görünmemeli.
3. Analytics varsayılan kapalı kalmalı; Ayarlar > Kullanım Analizi üzerinden sonradan açılabilmeli/kapatılabilmeli.
4. Google veya Misafir seçimi sonrasında ana ekranda bir kez bildirim çağrısı görünmeli.
5. `Şimdi Değil` seçildiğinde Android `POST_NOTIFICATIONS` sistem izin ekranı açılmamalı; oyun normal devam etmeli ve ilk-kullanım çağrısı tekrar gösterilmemeli.
6. Ayrı temiz first-run senaryosunda `Bildirimleri Aç` seçildiğinde Android sistem izin ekranı açılmalı.
7. İzin kabul edilirse uygulama içi bildirim ayarı açık olmalı; reddedilirse oyun eksiksiz çalışmalı.
8. Ayarlar'daki bildirim anahtarı her iki durumda da çalışmaya devam etmeli.

## B. Canlı Düello — normal maç

1. İki cihazda iki ayrı hesapla Canlı Düello açılır.
2. İki oyuncu da 10 soru seçer ve `Rakip Bul`a yakın zamanda basar.
3. İki cihaz da ilk denemede aynı `matchId` maçına girmeli.
4. Her soruda iki cihazda soru metni ve seçenek sırası aynı olmalı.
5. `q1214` veya başka `Maç sorusu cihazda bulunamadı` hatası görülmemeli.
6. Gerçek bağlantı kesintisi yokken false `rakip bağlantısı kesildi` / hükmen sonuç oluşmamalı.
7. Normal maç tamamlanmalı ve final skor iki cihazda tutarlı olmalı.
8. Sonuçtan lobby'ye dönüşte BR ve dereceli maç sayısı gecikmeden güncel değer göstermeli; eski değer kısa süreli geri gelmemeli.
9. Tamamlanan maç `Yarım Kalan Düello` olarak yeniden görünmemeli ve `Maça Dön` yolu açılmamalı.
10. Normal tamamlanan maç sonucunda `Bize destek olmak ister misiniz?` destek kartı görünmeli.
11. Closed-test Google rewarded reklamı kullanıcı seçerse açılmalı; tam izlenip reward callback geldikten sonra tam `+10 XP` verilmelidir.
12. Aynı `live_duel:<matchId>` için ikinci kez +10 XP alınamamalıdır.
13. Reklam kapatılır/başarısız olursa XP verilmemeli ve oyun sonucu bozulmamalıdır.

## C. Canlı Düello — kasıtlı ayrılma / forfeit

1. Yeni ayrı maç başlatılır.
2. Oyunculardan biri kasıtlı olarak maçtan ayrılır.
3. Hükmen sonuç doğru tarafa uygulanmalı ve BR sonucu yalnız bir kez işlenmelidir.
4. Hükmen/kaçış sonucunda `SupportRewardCard` / +10 XP reklam hakkı gösterilmemelidir.
5. Lobby'ye dönünce tamamlanmış forfeit maçı `Yarım Kalan Düello` olarak kalmamalıdır.

## D. Reklam regresyonu

- Aktif soru ekranında reklam gösterilmemeli.
- Standart yerel/tahta oyun sonucu destek kartını korumalı.
- Reklam akışı crash, ANR, process death veya navigation kilidi oluşturmamalı.

## Bitti ölçütü

Bu fiziksel kabul ancak A+B+C+D tamamı PASS olduğunda kapatılır. CI/emülatör başarısı iki cihazlı Play kabulünün yerine geçmez. Başarısız adım varsa ekran/video + sürüm + saat + hesap rolü + mümkünse matchId kaydedilir ve görev açık kalır.
