# Bilgi Rotası - Güncel Proje Durumu

**Kesim noktası:** 12 Ağustos 2026
**Durum sınıfları:** `DOĞRULANDI`, `RAPORLANDI`, `AÇIK`, `DURDURULDU`

---

## 1. Yayın kaynağı

| Alan | Kesim noktasındaki değer | Durum | Kaynak |
|---|---|---|---|
| Kanonik repo | `ZMilaStudio/BilgiRotasi` | DOĞRULANDI | 8 Ağustos 2026 GitHub canlı sorgusu |
| Android paket adı | `com.leventua.bilgirotasi` | DOĞRULANDI | S04 |
| Yayın/release dalı | `release/final-closed-test-aab-1.68.8` (`8a99530de7cb370d4db0edff9214ad833a8907cf`) | DOĞRULANDI | 12 Ağustos 2026 GitHub canlı sorgusu |
| Gerçek paket sürümü | `1.68.14+104` | DOĞRULANDI | Release dalındaki `pubspec.yaml`, 11 Ağustos 2026 |
| `main` dalı | Güncel yayın kaynağı değil | KESİN KARAR | S06, S07, S09 |
| PR #9 | Merge edildi | RAPORLANDI | S07, S09 |
| PR #10 | Merge edildi | RAPORLANDI | S06, S07, S09 |
| PR #13 | Kaynak PR açık, Draft, merge edilmedi; işlevsel ödüllü reklam düzeltmesi PR #16 ile release'e ulaştı; fiziksel cihaz kabulü bekleniyor | DOĞRULANDI / RAPORLANDI | 11 Ağustos 2026 GitHub canlı durumu |
| PR #14 | Merge edildi (`10 Ağustos 2026`) | DOĞRULANDI | GitHub canlı PR metadata’sı |
| PR #15 | Kaynak PR açık, Draft, merge edilmedi; değişiklikleri PR #16 entegrasyonu üzerinden release'e ulaştı; head canlı GitHub PR metadata’sından doğrulanır | DOĞRULANDI | GitHub canlı PR metadata’sı |
| PR #19 | Merge edildi (`11 Ağustos 2026`); merge commit `8a99530de7cb370d4db0edff9214ad833a8907cf` | DOĞRULANDI | GitHub canlı PR metadata’sı |
| Kapalı test entegrasyon adayı | `integration/closed-test-next-release`; PR #16 ile release'e merge edildi (`10 Ağustos 2026`) | DOĞRULANDI | GitHub canlı PR metadata’sı |
| Android geliştirici doğrulaması | Tamamlandı | RAPORLANDI | Levent'in güncel Play doğrulaması |

**Kural:** Branch adındaki `1.68.8`, paket sürümü değildir. Sürüm hedef dalın `pubspec.yaml` dosyasından okunmalıdır.

---

## 2. Google Play

- `1.68.13+103` önce Dahili Test'te gerçek cihazda doğrulandı.
- Aynı AAB mevcut Kapalı Test kanalına yayımlandı.
- Son doğrulanan Play kapalı test durumu **12 geçerli testçi / 4 kesintisiz gün**dür.
- 8 Ağustos 2026'da Play Console'a bağlı tarayıcı bulunamadığı için sayaç UI'dan
  yeniden okunamadı; 12/4 değeri Levent'in son Play Console doğrulaması olarak
  kaydedildi ve bir sonraki canlı kontrolde tarih/sayaç yeniden okunmalıdır.
- Android geliştirici doğrulaması tamamlandı.
- Uygulama kaydı, paket adı ve ilk AAB yükleme süreci daha önce adım adım tamamlandı.
- Play App Signing SHA değeri production Firebase'e eklenmişti; eski upload/release SHA silinmedi.

**Durum:** Kapalı Test yayını `DOĞRULANDI/RAPORLANDI`; katılım süreci `AÇIK`.

---

## 3. Soru bankası

- Son raporlanan aktif soru sayısı: **8.710**
- Eski 6.710 soruya 2.000 Türkiye odaklı kolay soru eklenmişti.
- Son Sheet konuşmasında hiçbir yeni kayıt `Düzeltildi` yapılmadı.
- Son kontrol kesiminde **41 bekleyen olay / 40 benzersiz soru** bulunduğu hesaplanıyor.
- İlk ayıklamada:
  - 14 benzersiz soru açıkça bozuk,
  - 8 soru zorluk incelemesi adayı,
  - 4 eski kayıt ayrıntılı inceleme bekliyor,
  - 13 soru henüz tek tek değerlendirilmemiş,
  - 1 soru için değişiklik gerekmiyor.

Ayrıntılı liste: `SORU_GERI_BILDIRIM_HAVUZU.md`

---

## 4. Soru geri bildirim taşıma sistemi

Son canlı kontrollerde:

- Eski cihaz kuyruğundaki kayıtlar Sheet'e aktarılabildi.
- `1.68.13+103` sürümünden kuyruk dışı canlı kayıtlar Sheet'e ulaştı.
- Bu nedenle geri bildirim taşıma sistemi çalışıyor kabul edilir.
- Ancak soru düzeltme süreci henüz başlamadı veya tamamlanmadı.
- Sheet kayıtları gerçek soru düzeltmesi merge edilmeden kapatılmamalıdır.

**Durum:** Taşıma `DOĞRULANDI`; içerik temizliği `AÇIK`.

---

## 5. 3B oyun tahtası

- Oynanış ve BoardMap değişmeyecek.
- Tahta sözleşmesi 67 noktadır:
  - 30 dış kategori,
  - 30 iç kategori,
  - 6 rozet,
  - 1 merkez.
- Tek Matrix4 ile bütün 2B tahtayı eğme yaklaşımı başarısız bulundu.
- `experiment/original-board-3d-v1` silindi.
- `experiment/true-3d-board-renderer-v2` açıldı; konuşma kesiminde gerçek renderer commit'i yoktu.
- Hiçbir 3B çalışma release dalına merge edilmedi.
- Son görsel kabul edilmedi ve çalışma durduruldu.
- 8 adet kategori rozeti konsepti üretildi; tahtadaki 6 fiziksel rozet noktasına eşleme çözülmedi.

**Durum:** `DURDURULDU`; çalışan oyuna etkisi yok.

---

## 6. Oyun ve hesap sistemleri

Konuşma ve test kayıtlarında mevcut olduğu görülen ana sistemler:

- 2-6 kişilik yerel tahta oyunu
- Serbest Rota
- Soru Maratonu
- Günlük Görev
- Hayatta Kalma
- 60 Saniye
- Takım modu ve diğer hızlı oyun modları
- 10 / 20 / 30 soruluk Meydan Okuma
- Canlı Düello altyapısı ve oyun akışı
- BR ve lig sistemi
- Google giriş / misafir ayrımı
- Bulut kayıt
- Hesap silme
- XP, seviye, başarımlar
- Bilgi Rotası Pasaportu
- Piyon koleksiyonu ve güvenli favori piyon seçimi
- Temalar, jokerler, özel kutular
- Erişilebilirlik ve Sistem Sağlığı

**Dikkat:** Yeni teknik çalışma öncesi canlı release dalında ilgili modülün gerçekten bulunduğu ve testlerin geçtiği doğrulanmalıdır.

- `codex/simplify-game-modes-pawn-rarity` dalında Diğer Oyun Modları ekranı
  daha kompakt hale getirildi; sabit mod sayısı metinleri kaldırıldı.
- Aile Modu ve Turnuva Modu kartları ile bu ekrandaki navigasyon girişleri
  kaldırıldı. Hayatta Kalma, 60 Saniye, Kategori Düellosu, Takım Modu ve
  Karışık Çılgınlık korunur.
- Kariyer bölümündeki ayrı Piyon Nadirlikleri girişi, nadirlik enum/kataloğu ve
  piyon seçicideki nadirlik benzeri `ÖZEL` sınıflandırması kaldırıldı.
- 17 piyonluk ana katalog, piyon görselleri/sesleri, favori piyon verisi ve
  geçersiz eski indeksler için güvenli fallback korunur.

**Durum:** Ayrı feature dalında uygulanıp hedefli testlerle doğrulandı; Draft PR
incelemesi ve Levent onayı bekleniyor.

---

## 7. Reklam

Kesim noktasındaki proje kararına göre:

- Aktif soru ve kritik oyun akışlarında reklam bulunmamalı.
- Banner yalnız uygun menü/sonuç ekranlarında kullanılmalı.
- Ödüllü reklam isteğe bağlı olmalı.
- Ödül: `+10 XP`
- Günlük toplam kota kaldırılmalı.
- Her tamamlanan oyun bir adet ödüllü reklam hakkı üretmeli.
- Aynı oyun sonucu ikinci kez ödül vermemeli.

**Durum:** `UYGULANDI / CI PASS / fiziksel cihaz kabulü bekliyor`.
Kaynak PR #13 açık, Draft ve merge edilmemiştir; işlevsel değişiklik PR #16
entegrasyonu üzerinden release dalına ulaşmıştır.

PR #13'ün yalnız işlevsel reklam düzeltmesi entegrasyon adayına taşındı.
Yarış koşullarına dayanıklı oyun-başına hak sistemi ile başarılı ödül sonrası
`rewarded_ad_completed` telemetrisi birlikte korunur. PR #13 kaynak Draft PR
olarak kalır; merge edilmiş sayılmaz.

---

## 7A. Kişisel hesap kimliği göndermeyen pseudonymous kullanım telemetrisi

- `codex/firebase-analytics-telemetry` dalında merkezi ve hata yalıtımlı
  Firebase Analytics katmanı eklendi.
- Kullanıcı izin verdiğinde uygulama süreç başlangıcı `app_process_started` ve
  adlandırılmış ekran geçişleri ölçülür. `app_process_started`, gerçek Google
  Analytics oturumu gibi yorumlanmaz; oturum ölçümü SDK'nın otomatik
  `session_start` metriğine bırakılır.
- Oyun modu seçimi, oyun başlangıcı/tamamlanması/yarıda bırakılması, joker
  kullanımı, ödüllü reklam tamamlanması ve Canlı Düello başlangıç/sonuç olayları
  ölçülür.
- Oyun olayları yalnız oyun modu, kategori, gerekiyorsa zorluk grubu, süre,
  sonuç ve uygulama sürümü gibi hesap kimliği içermeyen boyutları kabul eder.
- Ad, e-posta, Google kullanıcı kimliği, kullanıcı adı ve reklam kimliği için
  servis API'si yoktur; her dokunuş veya her cevap ayrı Analytics olayı değildir.
- Bu telemetri tam anonim değildir: kullanıcı izin verdiğinde Firebase SDK bu
  uygulama kurulumu için pseudonymous bir app-instance ID üretir.
- Analytics varsayılan olarak kapalıdır. Kullanıcı Ayarlar ekranında açıkça izin
  vermeden `analytics_storage` etkinleştirilmez, identifier depolanmaz ve olay
  gönderilmez. Tercih cihazda saklanır ve daha sonra geri alınabilir.
- Tercih `unknown` ise güncelleme sonrasında sürüm başına yalnız bir kez zorlamayan
  izin istemi gösterilir. `Şimdi Değil` seçimi aynı sürümde yeniden sorulmaz;
  kullanıcı daha sonra Ayarlar'dan izin verebilir.
- Android Advertising ID toplaması ve Analytics reklam kişiselleştirme
  sinyalleri manifestte kapalıdır; Analytics consent ayarında reklam depolaması,
  reklam kullanıcı verisi ve reklam kişiselleştirmesi reddedilir.
- Test/dev/prod Firebase ayrımı `FirebaseRuntimePolicy` üzerinden korunur.
  Analytics hataları sessizce yutulur ve oyun akışını engellemez.

**Durum:** Uygulandı ve PR #16 entegrasyonu üzerinden release'e ulaştı. Kaynak
PR #15 açık/Draft kalır; bu kayıt tek başına yeni AAB veya Play yayını kanıtı değildir.

---

## 7B. Kapalı test yayın adayı entegrasyonu

- Entegrasyon dalı: `integration/closed-test-next-release`
- Kaynak PR #13 ve PR #15 açık/Draft kalır; PR #14 merge edilmiştir.
- PR #14 ve PR #15 değişiklikleri dalın başlangıcında bulunur; PR #13'ten yalnız
  işlevsel reklam düzeltmesi entegre edilmiştir.
- `admob-pr-validation.yml`, `update/closed-test-next-release` kaynağındaki güncel
  CI akışıyla eşleştirildi.
- Sürüm değiştirilmedi: `1.68.13+103`.
- Yerel doğrulama: `flutter pub get` PASS, tüm Flutter testleri `237/237` PASS,
  analyzer exit `0` ve `git diff --check` PASS.
- GitHub CI run/job/artifact durumu entegrasyon Draft PR'ının canlı check
  metadata'sından doğrulanır.

**Durum:** PR #16 ile release dalına merge edildi. Bu merge tek başına yeni RC2,
AAB üretimi veya Play Console yayını kanıtı değildir.

---

## 7C. Android 16 AdMob PR doğrulama altyapısı

- PR #19'un önceki run #102 (`31511770185`, job `93847084171`) hatası uygulama
  kodundan önce oluştu: emülatör boot ettikten sonra Android paket servisi ilk
  `adb install` çağrısını `Failure calling service package: Broken pipe (32)` ile
  düşürdü. Uygulama kurulmadığı/başlatılmadığı için bu koşu uygulama crash veya
  ANR kanıtı değildir.
- AdMob PR cold-start doğrulaması artık kritik ADB komutlarını sınırlı retry ile
  çalıştırır. Kalıcı altyapı hatası yalnız açık health/result/release-gate
  kanıtlarıyla en fazla bir temiz Android 16 emülatör denemesine izin verir.
- Bilgi Rotası paketindeki crash, ANR, FATAL EXCEPTION veya process death ile
  kanıtsız uygulama kapısı hataları retry edilmez ve FAIL kalır.
- Düzeltme run #103'te (`31519334862`, job `93872230451`) ilk emülatör denemesinde
  PASS oldu; ikinci deneme gerekmedi. Artifact `BilgiRotasi-AdMob-1.68.14-104-kanitlari`
  (ID `9113075092`) içinde `APK_INSTALL`, `APP_LAUNCH`, `APP_PID`, `APP_ACTIVITY`,
  `APP_LOGCAT`, `APP_GATE` ve `RELEASE_GATE` değerlerinin tamamı PASS'tir.

**Durum:** PR #19 release'e merge edildi. Sonraki RC2 #322 yeni bir third-party
runner pre-script altyapı hatasıyla başarısız oldu.

---

## 7D. RC2 #322 runner pre-script ADB hatası

- Manuel RC2 run #322 (`31528674369`), job `93903134897`, release SHA
  `8a99530de7cb370d4db0edff9214ad833a8907cf`, artifact `9117187216`.
- Emülatör `sys.boot_completed=1` ile boot etti. Kullanılan
  `reactivecircus/android-emulator-runner@v2` action SHA'sı
  `a421e43855164a8197daf9d8d40fe71c6996bb0d` idi.
- Action, proje validator'ını başlatmadan önce `disable-animations: true` nedeniyle
  kendi `adb shell settings put` komutlarını çalıştırdı. İkinci settings çağrısı
  `Failure calling service settings: Broken pipe (32)` ile kırıldı ve action
  emülatörü sonlandırdı.
- `tools/validate_android16_closed_test.sh` hiç başlamadığı için artifact'ta
  `ANDROID16_*` raporu yoktur. Bu koşu uygulama crash/ANR kanıtı değildir.
- `fix/rc2-runner-pre-script-adb-failure` dalında her iki Android 16 attempt'i
  `disable-animations: false` kullanır. Animasyon kapatma release gate değildir;
  third-party action'ın project scriptinden önce kırılgan settings çağrısı yapması
  engellenir. Mandatory app/release gate sözleşmesi değişmez.
- Fiziksel ek kanıt: SM-S938B, Android 16/API 36. Cihazdaki mevcut Play kurulumu
  `1.68.13+103` cold-start oldu; PID ve resumed `MainActivity` canlı kaldı, ana
  ekranda Oyna ve test banner'ı görüldü, Oyna bölümü açıldı ve uygulama paketine
  ait crash/ANR/FATAL/process-death eşleşmesi bulunmadı.
- Cihaz mevcut Google oturumundaydı; kullanıcı verisini değiştirmemek için çıkış
  veya Misafir geçişi yapılmadı. Run #322 artifact'ı universal APK içermedi ve
  cihaz Play-signing SHA-1'i upload sertifikasından farklı olduğu için v104 in-place
  kurulumu güvenli biçimde yapılamadı. Bu fiziksel test CI Android 16 gate'in
  yerine geçmez.
- Draft PR #20 ilk otomatik CI run #106'da (`31548075906`, job `93964707470`)
  project validator'a ulaştı. Emülatörün paket servisi ilk kurulumda `Broken
  pipe`, sonraki iki kurulumda `Can't find service: package`; activity servisi de
  `Can't find service: activity` verdi. Artifact `9123654768` uygulama crash/ANR
  kanıtı içermedi.
- Validator yalnız ilk ifadeyi altyapı saydığından run #106'yı yanlışlıkla
  `APK_INSTALL_FAILED_WITHOUT_INFRASTRUCTURE_EVIDENCE` olarak sınıflandırdı.
  `Can't find service: package/activity` artık açık emulator altyapı kanıtıdır;
  uygulama crash/ANR/FATAL/process-death kontrolü bundan önce çalışmaya devam
  eder. AdMob PR workflow'undaki iki action attempt'i de validator öncesi settings
  ADB çağrısı yapmamak için `disable-animations: false` kullanır.

**Durum:** Takip düzeltmesinin yerel hedefli kontrolleri PASS; Draft PR #20'nin
yeni otomatik PR CI doğrulaması bekleniyor.

---

## 8. Mağaza ve tanıtım

Hazırlanan varlıklar arasında:

- 8 telefon görseli
- Tablet görsel seti planı/çalışması
- 600 x 400 PC logosu
- 6 PC ekran görüntüsü
- 6 Android XR görseli
- Instagram kare görsel seti

bulunuyor.

Tanıtım videolarının 15/30/60 saniyelik birçok seti üretildi; Levent tarafından yetersiz bulundu. Onaylı final tanıtım videosu yoktur.

Ayrıntı: `MAGAZA_VE_TANITIM_VARLIKLARI.md`

---

## 9. Şu anda ilk yapılacak işler

1. Play Console'da son doğrulanan 12 geçerli testçi / 4 kesintisiz gün sayacını
   bir sonraki erişimde tarihli ekran kanıtıyla yeniden doğrula.
2. Sheet'teki soru geri bildirimlerini soru bankasının gerçek kayıtlarıyla incele.
3. Açıkça bozuk sorular için release dalından ayrı düzeltme branch'i aç.
4. Soru düzeltmelerini test et, PR aç, incele ve merge et.
5. Yeni AAB'yi mevcut Kapalı Test kanalına güncelleme olarak yükle.
6. PR #13 ödüllü reklam değişikliğinin fiziksel cihaz kabul testini tamamla;
   uygulanmış ve CI PASS durumunu geriye götürme.
7. 3B tahta çalışmasına, geometri ve 6-rozet eşlemesi çözülmeden dönme.
