# Bilgi Rotası 1.68.8+98 Kapalı Test Yayın Hazırlığı

## Yayın özeti

- Kaynak: `hotfix/release-login-tutorial-1.68.7` dalındaki doğrulanmış `73ee39c6d32eb49944db2eef0e89477a23c78e70` commit'i.
- Hedef paket: `com.leventua.bilgirotasi`.
- Firebase profili: production, proje `bilgi-rotasi-f255d`, callable Functions bölgesi `europe-west1`.
- Reklam profili: `closed_test`; Google'ın demo App ID, banner ve ödüllü reklam birimleri kullanılır.
- Production AdMob profili korunur ve yalnız `ADMOB_ENVIRONMENT=production` ile seçilir.
- Hedef AAB: `BilgiRotasi-1.68.8-98-closed-test.aab`.
- Beklenen imza SHA-1: `00:0E:E4:3F:41:0A:BC:6B:4F:63:4C:4F:71:6D:76:EB:19:08:41:15`.

## Korunan düzeltmeler

- Google ile girişte sabit web client ID kaldırılmıştır; platform yapılandırması kullanılır.
- İlk açılış eğitimi otomatik açılmaz. Eğitim yalnız Ayarlar içindeki “Eğitimi Yeniden Göster” seçeneğinden açılır ve “Anladım” ile kapanır.
- Misafir ve Google hesap verilerinin ayrımı ile önceki güvenlik/gizlilik düzeltmeleri korunur.

## Lig ve sıralama teşhisi

İstemci daha önce kullanıcının `live_duel_leaderboard` belgesi gerçekten var mı diye bakmadan, kendisinden yüksek puanlı kayıt sayısına bir ekleyerek sıra üretiyordu. Boş koleksiyonda bu hesap `#1` gösteriyor, aynı anda “Henüz sıralamaya giren oyuncu yok” mesajı çıkıyordu.

Düzeltme, kullanıcının `users/{uid}.publicPlayerId` değerini okuyup karşılık gelen leaderboard belgesinin varlığını doğrular. Belge yoksa sıra `—`; belge varsa üstündeki gerçek kayıt sayısından sıra hesaplanır. Boş ve dolu durumlar otomatik testlerle kapsanır.

Uzak production veritabanı bu değişiklik sırasında okunmadı veya değiştirilmedi. Dolayısıyla boş listenin operasyonel nedeni (henüz tamamlanmış dereceli maç olmaması ya da backend/rules dağıtımının eksik olması) yayın öncesinde Firebase Console üzerinden ayrıca doğrulanmalıdır.

## Otomatik kalite ve paket kapıları

Manuel `Closed test release doğrulaması` workflow'u şu kontrolleri geçmeden başarılı olmaz:

- Flutter analyze, tüm Flutter testleri ve hedefli Firebase/AdMob profil testleri.
- Cloud Functions birim testleri ve Firestore Rules emulator testleri.
- `git diff --check` ve bağımlılık grafiği.
- Kalıcı keystore secret'larının eksiksizliği; debug imzaya geri dönüş yoktur.
- APK/AAB paket adı, dinamik sürüm adı/kodu, release/debuggable durumu ve sertifika SHA-1.
- Production Firebase proje kaynağı ile kapalı-test Google demo AdMob kimlikleri.
- AAB içinde keystore, `key.properties`, service account, `google-services.json` veya private key bulunmaması.
- Bundletool ile AAB'den üretilen APK setinin Android 16 emülatöre kurulması.
- Cold-start, giriş ekranı, misafir devamı, ana ekran ve eğitimin Ayarlar'dan açılıp kapanması; fatal logcat ve çalışan süreç kontrolü.

## Yerel doğrulama sonucu

- `flutter analyze --no-fatal-warnings --no-fatal-infos`: PASS. Mevcut kod tabanında 91 non-fatal warning/info raporlandı; yeni analiz hatası yoktur.
- Tüm Flutter testleri: PASS, 200/200.
- Kapalı-test AdMob profili: PASS, 1/1.
- Production AdMob profilinin korunması: PASS, 1/1.
- Production Firebase profili: PASS, 1/1.
- Cloud Functions: PASS, 20/20.
- Firestore Rules emulator: PASS, 6/6. İlk çalıştırma Java PATH'te olmadığı için başlamadı; Android Studio JBR ile tekrarlandığında geçti.
- RC1 soru/asset kalite kapısı: PASS; 6710 soru. Kapıdaki eski `1.68.6+96` sabitlemesi dinamik sürüm biçimi ve `AppBuildInfo` eşleşmesi kontrolüyle değiştirildi.
- `git diff --check`: PASS.
- Üç profil testinin ilk paralel yerel çağrısı Flutter araç kilidi nedeniyle zaman aşımına uğradı; testler ardışık tekrarlandığında üçü de geçti.
- İlk GitHub Actions denemesinde APK ve AAB üretildi, ancak Bundletool 1.18.3 `env:` parola önekini kabul etmediği için APK seti kapısında durdu. Parolalar süreç argümanına konmadan, izinleri sınırlandırılmış geçici dosyalarla `file:` biçimine geçirildi; sonraki başarılı run kabul kanıtıdır.
- İkinci GitHub Actions denemesinde Bundletool geçti ve sertifika doğru SHA-1'i gösterdi; karşılaştırma için AAB SHA-1 değerindeki iki nokta ayraçları kaldırılmadığından metadata adımı yanlış negatif verdi. Normalizasyon APK ile aynı hale getirildi; sonraki başarılı run kabul kanıtıdır.
- Üçüncü GitHub Actions denemesinde ayrı APK derlemesi GitHub runner'da olağandışı uzun sürdü. Yayın ürünü AAB olduğundan yinelenen standalone APK derlemesi kaldırıldı; paket/badging/imza ve Android 16 kontrolleri artık zorunlu olarak AAB'den Bundletool ile türetilen universal APK üzerinde yapılır.
- Dördüncü GitHub Actions denemesinde Android 16 emülatörü açıldıktan sonra runner'ın kendi animasyon ayarı ADB `Broken pipe` hatası verdi; uygulama test betiği başlamadan altyapı adımı durdu.
- Aynı run'ın yeniden denemesinde emülatör açıldı, ancak `android-emulator-runner` betiği `/bin/sh` ile başlattığı için Bash'e özgü `set -o pipefail` kabul edilmedi. Betik taşınabilir `set -eu` kullanacak şekilde düzeltildi; sonraki başarılı run kabul kanıtıdır.
- Sonraki denemede yeni kabuk koruma testinin `coreWorkflow` değişkeni test kurulum bloğunda yerel bırakıldığı için analyze kapısı hatayı yakaladı ve build başlamadan durdu. Değişken grup kapsamına taşındı; sonraki başarılı run kabul kanıtıdır.
- Sonraki denemede emülatör açıldı, fakat `android-emulator-runner` her `script:` satırını ayrı süreçte çalıştırdığı için `APKS` değişkeni kurulum satırına taşınmadı. Android 16 doğrulaması tek Bash sürecinde çalışan `tools/validate_android16_closed_test.sh` dosyasına taşındı; sonraki başarılı run kabul kanıtıdır.
- Sonraki denemede AAB-derived APK seti Android 16'ya kuruldu; düşük kaynaklı emülatörde bloklayan cold-start ve UI Automator hiyerarşi üretimi zaman aşımına uğradı. Emülatör belleği artırıldı, başlatma bloklamayan moda alındı, UI dump süreleri sınırlandı ve logcat/activity/process tanıları çıkışta zorunlu artifact dosyalarına bağlandı; sonraki başarılı run kabul kanıtıdır.

Yerelde 8 GB RAM sınırı nedeniyle release AAB üretilmedi. İmzalı AAB, metadata ve Android 16 doğrulamasının yetkili sonucu yalnız GitHub Actions workflow sonucudur.

## Production backend için manuel dağıtım sırası

Bu branch ve workflow backend dağıtımı yapmaz. Yetkili operatör kapalı testten önce/sonra aşağıdaki sırayı kontrollü uygulamalıdır:

1. Firebase Console'da Google oturum açma sağlayıcısını, Android paketini ve beklenen SHA-1 kaydını doğrula.
2. Functions testleri geçtikten sonra `firebase deploy --project bilgi-rotasi-f255d --only functions` ile callable backend'i dağıt.
3. Gerekli indeksleri `firebase deploy --project bilgi-rotasi-f255d --only firestore:indexes` ile dağıt ve indekslerin hazır olmasını bekle.
4. Bu workflow'un ürettiği kapalı-test AAB'sini Google Play kapalı test kanalına yükle; Google giriş, kayıt izolasyonu ve iki cihazlı Canlı Düello smoke testlerini yap.
5. Uyumlu istemci doğrulandıktan sonra sıkı kuralları `firebase deploy --project bilgi-rotasi-f255d --only firestore:rules` ile dağıt.
6. App Check/Play Integrity zorlamasını yalnız gözlem metrikleri temiz ve kapalı-test istemcisi uyumlu olduktan sonra etkinleştir.

## Manuel kapalı-test kontrol listesi

- Google hesabıyla giriş ve uygulamayı yeniden açınca oturumun korunması.
- Misafir → Google geçişinde kayıtların doğru hesaba bağlanması; başka hesaba veri sızmaması.
- Eğitimin otomatik açılmaması; Ayarlar'dan açılıp “Anladım” ile kapanması.
- İki ayrı fiziksel cihaz/hesapla Canlı Düello eşleşme, maç bitişi, sonuç kaydı ve leaderboard güncellemesi.
- Leaderboard boşken `#1` yerine `—`; oyuncu belgesi oluştuktan sonra tutarlı sıra.
- Kapalı-test sürümünde yalnız Google demo reklam kreatifleri.

## Bilinen riskler ve geri alma

- CI emülatörü gerçek Google hesap seçicisini ve iki cihazlı Canlı Düello'yu doğrulayamaz; bunlar fiziksel cihaz kapalı testinde zorunludur.
- Production Firestore içeriği otomatik workflow tarafından okunmaz; leaderboard veri varlığı manuel doğrulanır.
- Başarısızlıkta Play kapalı test kanalında önceki AAB aktif bırakılır, backend/rules dağıtımı durdurulur ve ilgili Functions/Rules sürümü Firebase release geçmişinden geri alınır.
- Bu branch main'e otomatik yazmaz, PR Draft kalır ve hiçbir workflow deployment yapmaz.
