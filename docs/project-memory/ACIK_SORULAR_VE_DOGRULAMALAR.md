# Bilgi Rotası - Açık Sorular ve Canlı Doğrulamalar

**Kesim noktası:** 12 Ağustos 2026

## Canlı durum

- Kanonik repo: `ZMilaStudio/BilgiRotasi`.
- Release dalı: `release/final-closed-test-aab-1.68.8`.
- Release HEAD: `ec20e66e1d52126ce99fa09e29f606ae14a5f7a2`.
- Release sürümü: `1.68.14+104`.
- PR #7 açık/Draft ve `main` karşısında tutuluyor; merge edilmeyecek.
- PR #12 açık; 3B deterministik geometri çalışmasıdır.
- PR #13 açık/Draft; ödüllü reklam fiziksel kabulü bekliyor.
- PR #15 açık/Draft; telemetri değişiklikleri PR #16 üzerinden release'e ulaştı.
- PR #21 merge edildi.
- PR #23 merge edildi.
- RC2 #326 run `31614662061`, job `94174350962`: **SUCCESS**.
- Artifact `9149285776`: `BilgiRotasi-1.68.14-104-closed-test-release`.
- Artifact digest: `sha256:c69b44f40152ecc256ea5ace57c997bf3c8dafb8c051cdfaf69df288837fd56e`.
- Android 16 deneme 1 PASS; deneme 2 gerekmedi.
- `APK_INSTALL`, `APP_LAUNCH`, `ANALYTICS_CONSENT_HANDLED`, `GUEST_LOGIN`, `HOME_OYNA`, `APP_PID`, `APP_LOGCAT`, `APP_GATE`, `POST_GATE_LOGCAT_BOUNDARY` = PASS.
- `RESULT=PASS`, `RELEASE_GATE=PASS`, `APP_GATE=PASS`, `SETTINGS_TUTORIAL_DIAGNOSTIC=PASS`.
- Bilgi Rotası PID: `3566`.
- Bilgi Rotası crash/ANR/FATAL/process-death kanıtı yok.
- Android geliştirici doğrulaması tamamlandı.
- Son doğrulanan Play kapalı test değeri: **12 geçerli testçi / 4 kesintisiz gün**. Güncel sayaç UI'dan yeniden okunacak.

## RC2 release doğrulaması

Android 16 mandatory release gate artık açık konu değildir. RC2 #326 gerçek AAB-derived zincirde başarıyla geçti.

Eski #319/#321/#322/#323/#325 koşuları yalnız kök neden ve regression tarihçesidir; yeniden debug hedefi değildir.

## Play kapalı test kabulü - açık doğrulamalar

1. Play Console'da güncel aktif kapalı test AAB sürümünü tarihli ekranla doğrula.
2. Geçerli testçi sayısını ve kesintisiz gün sayacını yeniden oku; eski 12/4 değerini ileri tarih için tahmin etme.
3. `1.68.14+104` AAB'nin Play kapalı test kanalına yüklenip yüklenmediğini canlı Console'dan doğrula.
4. Google hesabıyla girişin gerçek Play kurulumu üzerinde çalıştığını doğrula.
5. Uygulamayı yeniden açınca Google oturumunun korunduğunu doğrula.
6. Misafir → Google geçişinde kayıtların doğru hesaba bağlandığını ve başka hesaba veri sızmadığını doğrula.
7. Eğitimin beklenen davranışını ve Ayarlar'dan açılıp `Anladım` ile kapanmasını fiziksel cihazda doğrula.
8. Kapalı test sürümünde yalnız Google demo reklam kreatiflerinin göründüğünü doğrula.
9. Ödüllü reklamın tamamlanan oyun başına tek hak, `+10 XP`, ikinci ödül engeli ve başarısız reklam sonrası yeniden deneme sözleşmesini fiziksel cihazda doğrula.

## Firebase production envanteri - açık

Kör deploy yapılmadan canlı production proje üzerinden:

1. Google Authentication provider durumunu doğrula.
2. `com.leventua.bilgirotasi` Android uygulamasındaki SHA kayıtlarını ve sertifika rollerini doğrula.
3. Functions deploy sürümünü doğrula.
4. Firestore indexes deploy/ready durumunu doğrula.
5. Firestore rules deploy sürümünü doğrula.
6. Dev/prod ayrımının canlı yapılandırmada korunduğunu doğrula.
7. App Check provider'ın Play Integrity olduğunu ve enforcement durumunu doğrula.
8. Enforcement açılacaksa önce gerçek kapalı-test trafiğinin meşru istekleri temiz geçtiği metriklerle doğrula.

## İmza ayrımı - doğrulanacak kullanım rolleri

- Play App Signing tarafında daha önce kaydedilen SHA-1: `17:E1:EC:6C:77:4F:B4:59:63:FA:7A:76:51:7D:21:B2:BB:7C:81:1F`.
- RC2 #326 AAB/upload signing zincirinde görülen SHA-1: `00:0E:E4:3F:41:0A:BC:6B:4F:63:4C:4F:71:6D:76:EB:19:08:41:15`.

Bu iki sertifika birbirine karıştırılmayacak; Firebase ve Play Console'daki amaçları canlı kaynaktan doğrulanacak.

## Canlı Düello fiziksel kabulü - açık

İki güncel kapalı test cihazı ve iki ayrı hesapla:

1. Otomatik eşleştirme.
2. 10 / 20 / 30 soru seçimi.
3. İki oyuncuya aynı soruların aynı sırada gelmesi.
4. Skor/ilerleme tutarlılığı.
5. Maçın tamamlanması.
6. Sonucun tek sefer kaydedilmesi.
7. BR/lig güncellemesinin tek sefer işlenmesi.
8. Leaderboard güncellemesi.
9. Leaderboard boşken `#1` yerine `—` gösterilmesi.
10. Kopma/ayrılma akışlarının veri bozmaması.

## Analytics consent doğrulaması

1. Yeni kurulumda Analytics varsayılan kapalı mı?
2. Kullanıcı izin vermeden `analytics_storage` etkinleşmiyor ve olay gönderilmiyor mu?
3. Tercih cihazda saklanıp yeniden açılışta doğru yükleniyor mu?
4. İzin geri alındığında koleksiyon kapanıyor ve yerel Analytics verisi sıfırlanıyor mu?
5. `ad_storage`, `ad_user_data` ve `ad_personalization` denied kalıyor mu?
6. Analytics kapalıyken çevrimdışı/çevrimiçi oyun akışları eksiksiz çalışıyor mu?

## Play Data Safety ve gizlilik politikası

Yayın öncesinde:

1. Firebase Analytics nedeniyle gerçekten toplanan veri türlerini production SDK davranışıyla doğrula.
2. Formda yalnız kanıtlanan veri türlerini işaretle.
3. Analytics consent'in isteğe bağlı oluşunu ve reklam consent değerlerinin ayrı/denied durumunu doğru beyan et.
4. Gizlilik politikası pseudonymous app-instance ID, olay kapsamı, amaç, saklama/silme ve izni geri alma yolunu açıklasın.
5. UMP reklam consent'i ile Analytics consent'inin ayrı mekanizmalar olduğu açıkça korunsun.
6. Politika URL'si ile Play Data Safety cevaplarını production build/Firebase ayarlarıyla karşılaştır.

## Ayrı açık ürün hatası - günlük giriş XP

`KARARLAR.md` içinde **“Günlük giriş ödülü yok.”** kararı bulunmasına rağmen RC2 #325 ekran kanıtında `+20 XP • Günlük giriş serisi • 1. gün` görüldü.

Doğrulanacak:

1. Canlı release retention/XP kaynak kodunda bu ödülü üreten yol.
2. Kararla çelişiyorsa ayrı branch'te kaldırılması.
3. İlgili testlerin eklenmesi/güncellenmesi.
4. RC2 validator değişikliklerinden ayrı tutulması.

## Ayrı açık teknik borç - `RELEASE_READINESS.md`

RC2 #326 artifact'ındaki gerçek `RC1_QUALITY_GATE.md` doğru biçimde:

- sürüm `1.68.14+104`
- toplam soru `8710`

raporluyor.

Buna rağmen `reports/RELEASE_READINESS.md` içinde eski `1.68.8+98`, eski kaynak commit/AAB adı ve 6.710 soru gibi tarihsel metinler kalmıştır.

Doğrulanacak:

1. Bu raporu üreten kaynak dosya/script.
2. Sürüm, SHA, AAB adı ve soru sayısının workflow'dan dinamik alınması.
3. Değişikliğin ayrı branch/PR ve hedefli testlerle doğrulanması.
4. Sırf rapor metni için RC2 #326'nın yeniden çalıştırılmaması.

## Soru geri bildirimleri

1. Sheet'teki yeni olaylar ve bekleyen 40 benzersiz soru yeniden incelenecek.
2. Her soru için metin, dört seçenek, doğru indeks, açıklama, kategori ve zorluk birlikte doğrulanacak.
3. `assets/questions.json` kontrolsüz değiştirilmeyecek.
4. Sheet satırı gerçek soru düzeltmesi merge edilmeden kapatılmayacak.

## Mağaza varlıkları

Telefon, tablet, Chromebook, PC ve XR varlıklarının Play Console yükleme durumu canlı ekrandan `hazır / yüklendi / reddedildi / yeniden yapılacak` biçiminde kaydedilecek.

## 3B tahta

- Oynanış, BoardMap ve 67 node düzenine dokunulmayacak.
- Önce numaralı deterministik geometri.
- 8 konsept rozet / 6 fiziksel rozet eşlemesi çözülmeden ilerlenmeyecek.
- Kullanıcı görsel onayı olmadan stil/Flutter/APK aşamasına geçilmeyecek.
- `tools/board_renderer/` alanına kontrolsüz müdahale edilmeyecek.
