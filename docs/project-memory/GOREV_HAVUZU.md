# Bilgi Rotası - Görev Havuzu

## P0 - Kapalı Test ve soru kalitesi

### BR-P0-001 - Kapalı Test canlı durumunu doğrula

**Durum:** İZLENİYOR

- Son doğrulanan: 12 geçerli testçi
- Son doğrulanan: 4 kesintisiz gün
- Testten ayrılanlar
- Son aktif AAB
- Play Console'un güncel üretim erişimi koşulları

**Bitti ölçütü:** Ekran kanıtı ve tarih `BILGI_ROTASI_DURUM.md` dosyasına yazılır.

---

### BR-P0-002 - 14 açıkça bozuk soruyu düzelt

**Durum:** AÇIK

Liste: `SORU_GERI_BILDIRIM_HAVUZU.md`

**Bitti ölçütü:**

- Gerçek JSON kayıtları incelendi.
- Şıklar ve cevap indeksleri düzeltildi.
- QA/test geçti.
- Ayrı PR merge edildi.
- Yeni AAB Kapalı Test'e yüklendi.
- Sheet satırları bundan sonra kapatıldı.

---

### BR-P0-003 - Kalan 26 benzersiz geri bildirimi değerlendir

**Durum:** AÇIK

- 8 zorluk adayı
- 4 eski açık kayıt
- 13 değerlendirilmemiş soru
- 1 değişiklik gerektirmeyen kayıt

---

### BR-P0-004 - Ödüllü reklam hak sistemi

**Durum:** UYGULANDI / CI PASS / RELEASE'E ENTEGRE / fiziksel cihaz kabulü bekliyor

Kaynak Draft PR #13 açık ve merge edilmemiştir. İşlevsel değişiklik PR #16
entegrasyonu üzerinden release dalına ulaşmıştır.

İstenen:

- tamamlanan oyun başına 1 hak
- aynı oyun için tekrar yok
- yeni tamamlanan oyunla yeniden hak
- günlük/oturumluk toplam kota yok
- +10 XP

Entegrasyon notu: PR #13'ün işlevsel reklam düzeltmesi
`integration/closed-test-next-release` dalında PR #14/#15 değişiklikleriyle
birlikte doğrulandı. PR #13 kaynak Draft PR olarak kalır ve merge edilmiş sayılmaz.

---

### BR-P0-005 - Final kapalı-test entegrasyon adayını doğrula

**Durum:** PR #16 İLE RELEASE'E MERGE EDİLDİ

- Dal: `integration/closed-test-next-release`
- Sürüm: `1.68.13+103` (artırılmadı)
- Kaynak PR #13 ve PR #15 açık/Draft kalır; PR #14 merge edilmiştir.
- Oyun-başına ödül hakkı ve başarılı ödüllü reklam telemetrisi birlikte korunur.
- Yerel tüm Flutter testleri: `237/237 PASS`
- Analyzer: exit `0`; mevcut non-fatal tanılar dışında hata yok
- `git diff --check`: PASS
- GitHub CI run/job/artifact sonucu canlı Draft PR check metadata'sından izlenir.
- Entegrasyon PR #16 release'e merge edilmiştir; bu kayıt yeni RC2, AAB yayını
  veya Play Console değişikliği yapıldığı anlamına gelmez.

---

### BR-P0-006 - Android 16 AdMob PR kapısını kanıta dayalı yap

**Durum:** UYGULANDI / CI PASS / PR #19 İLE RELEASE'E MERGE EDİLDİ

- Dal/PR: `fix/rc2-recurring-system-anr-retry`, Draft PR #19.
- Run #102 kök nedeni: emülatör Android paket servisinde `Broken pipe (32)`;
  uygulama kurulmadan oluşan altyapı hatası.
- Kritik ADB komutları sınırlı retry kullanır; yalnız açık altyapı kanıtı temiz
  ikinci emülatörü açar.
- Uygulama crash/ANR/FATAL/process-death ve kanıtsız kapı hataları FAIL kalır.
- Yerel hedefli testler: `20/20 PASS`; analyzer exit `0`; Bash syntax ve
  `git diff --check` PASS.
- GitHub run #103 (`31519334862`), job `93872230451`: PASS.
- Artifact: `BilgiRotasi-AdMob-1.68.14-104-kanitlari`, ID `9113075092`.
- PR #19 merge commit'i: `8a99530de7cb370d4db0edff9214ad833a8907cf`.

---

### BR-P0-007 - RC2 runner pre-script ADB hatasını kaldır

**Durum:** TAMAMLANDI / PR #20 RELEASE'E MERGE EDİLDİ

- Run #322: `31528674369`; job `93903134897`; artifact `9117187216`.
- Kesin kök neden: `android-emulator-runner`, proje validator'ından önce
  `disable-animations` settings çağrısında `Broken pipe (32)` aldı.
- Artifact'ta `ANDROID16_*` raporu yoktur; validator hiç başlamadı.
- Dal: `fix/rc2-runner-pre-script-adb-failure`.
- Her iki Android 16 attempt'i `disable-animations: false` kullanır; mandatory
  uygulama ve release gate'leri değiştirilmez.
- Yerel Bash syntax PASS, ilgili Flutter testleri `20/20 PASS`, analyzer exit `0`
  ve `git diff --check` PASS.
- Fiziksel ek kanıt: SM-S938B Android 16/API 36 üzerinde mevcut `1.68.13+103`
  Play kurulumu cold-start/PID/resumed activity/Oyna/logcat kontrollerini geçti.
  Mevcut Google oturumu ve farklı Play-signing sertifikası nedeniyle Misafir
  geçişi ile v104 in-place kurulum güvenli biçimde yapılmadı.
- Draft PR #20 ilk CI run #106 (`31548075906`, job `93964707470`) project
  validator'a ulaştı; ancak sistem `package` ve `activity` servisleri kayboldu.
  Artifact `9123654768` içindeki üç install kanıtı `Broken pipe` ve iki kez
  `Can't find service: package` sonucudur; uygulama crash/ANR kanıtı yoktur.
- `Can't find service: package/activity` yalnız açık emulator altyapı kanıtı
  olarak retry quartet'ine gider; gerçek uygulama hataları fail-fast kalır.
- AdMob PR workflow'undaki iki emulator attempt'i de `disable-animations: false`
  kullanır. Takip hedefli testleri `17/17 PASS`.
- Otomatik run #107 (`31549806040`), job `93969855281`: PASS. İlk deneme explicit
  infrastructure quartet'iyle temiz retry istedi; ikinci denemede tüm AdMob app
  ve release gate'leri PASS. Artifact: `9124476985`.
- Run #108'de iki emulator da `system_server` kaybı ve sistem paketi
  `DeadSystemException` ile explicit infrastructure sonucu üretti; Bilgi Rotası
  süreci yoktu. Action `/dev/kvm` izin eksikliği nedeniyle yazılım emülasyonu
  kullanıyordu. PR ve RC2 workflow'ları emulator öncesi KVM read/write erişimini
  fail-fast hazırlar; uygulama/release gate'leri aynen kalır.
- Son kod değişikliği head'i: `18db0393b18fc661cb532a8d4e1b09653bba4259`.
- PR CI run #109 (`31553712368`), job `93981640719`: PASS. Logda KVM hazırlama
  PASS, `disable animations: false`, `disable Linux hardware acceleration: false`,
  emulator boot ve `bash tools/validate_admob_android16_cold_start.sh` başlangıcı
  doğrulandı. Deneme 1 tüm AdMob uygulama/release gate'lerini geçti; deneme 2
  gerekmedi ve SKIPPED kaldı.
- Artifact: `BilgiRotasi-AdMob-1.68.14-104-kanitlari`, ID `9125437699`.
- Docs-only head için run #110 (`31567372445`) PASS oldu.
- PR #20 Levent onayıyla release'e merge edildi; release head
  `1a113a6aba98324b668aa5f037fa6b08c7d776c3` oldu.

**Bitti ölçütü:** PR #20 merge edildi ve fresh RC2 project validator'a ulaştı.
Fresh RC2'da ortaya çıkan ayrı analytics consent gate hatası BR-P0-008'e taşındı.

---

### BR-P0-008 - RC2 analytics consent popup kapısını doğrula

**Durum:** UYGULANDI / PR #21 KOD CI PASS / MERGE ONAYI BEKLİYOR

- Fresh RC2 #323: run `31568589298`; job `94025527635`; artifact `9130712889`;
  release SHA `1a113a6aba98324b668aa5f037fa6b08c7d776c3`.
- Artifact'ta `APK_INSTALL=PASS`, `APP_LAUNCH=PASS`; uygulama PID/MainActivity
  sağlıklıdır ve Bilgi Rotası crash/ANR/FATAL/process-death kanıtı yoktur.
- Sonuç: `RESULT=FAIL`, `RELEASE_GATE=FAIL`,
  `REASON=MANDATORY_APP_GATE_INCOMPLETE`.
- Kesin kök neden: `Kullanım Analizine İzin Verilsin mi?` penceresi açık kalırken
  eski validator tek ADB dokunuşundan sonra `ANALYTICS_CONSENT_HANDLED=PASS` yazdı.
- #323 OCR kanıtında `Şimdi Değil` aksiyonu yaklaşık y=1240'tadır; eski fallback
  `760 1065` yanlış bölgedeydi. Eski birleşik OCR pattern'i ilk `Şimdi` eşleşmesini
  seçebiliyordu.
- Dal: `fix/rc2-analytics-consent-gate`.
- Son kod değişikliği commit'i: `2b247e9c86d00827e4539ac442ff9f242b6931ee`
  — `fix: verify Android 16 analytics consent dismissal`.
- `Değil` OCR eşleşmesi önceliklidir; `Şimdi` yalnız fallback. Koordinat fallback'i
  #323 kanıtına göre `785 1240`.
- Tek ADB tap artık PASS sayılmaz; consent bounded retry ile tekrar yakalanır.
  `ANALYTICS_CONSENT_HANDLED=PASS` yalnız `Google|Misafir` auth ekranı gerçekten
  görüldükten sonra yazılır.
- Emulator unhealthy exit `75` korunur; mandatory app/release gate'leri
  gevşetilmez.
- Regression testi yanlış erken PASS'i, OCR önceliğini, fallback koordinatını ve
  infra exit `75` korumasını kilitler.
- PR #21 AdMob PR CI #112 (`31573637930`), job `94040784202`: PASS. Analyze+tüm
  testler, release APK, package/manifest, KVM hazırlığı, Android 16 cold-start
  attempt 1, classifier, final app gate ve artifact upload PASS; attempt 2
  gerekmedi ve SKIPPED kaldı.
- Artifact: `BilgiRotasi-AdMob-1.68.14-104-kanitlari`, ID `9132178688`, digest
  `sha256:2fea7fcc9b3d3acde16d08a56912a980476245d20b34dbb05baac1229460eb7ef`.
- #112 AdMob cold-start CI'dır; gerçek consent → Misafir → Oyna geniş RC2
  doğrulamasının yerine geçmez.
- PR #21 açık/Draft; Levent açık onayı olmadan merge edilmeyecek.
- #323 rerun edilmeyecek.

**Bitti ölçütü:**

- PR #21'in güncel head CI'ı PASS.
- Levent açık onayıyla PR #21 release'e merge edildi.
- Merge sonrasında release head/sürüm yeniden doğrulandı.
- Eski #323 rerun edilmeden fresh `android-apk.yml` koşusu
  `confirmation=CLOSED_TEST` ile oluşturuldu.
- Fresh RC2'de analytics consent penceresi gerçekten kapandı.
- `APK_INSTALL`, `APP_LAUNCH`, `GUEST_LOGIN`, `HOME_OYNA`, `APP_PID`,
  `APP_LOGCAT`, `APP_GATE`, `RELEASE_GATE` tamamı PASS.
- Bu gate PASS olmadan Play'e AAB yüklenmedi.

---

## P1 - Teknik doğrulama

### BR-P1-001 - GitHub canlı envanteri

**12 Ağustos 2026 doğrulaması:**

- Kanonik repo: `ZMilaStudio/BilgiRotasi`
- Release head: `1a113a6aba98324b668aa5f037fa6b08c7d776c3`
- Release sürümü: `1.68.14+104`
- PR #13: açık / Draft / merge edilmedi; ödüllü reklam işi UYGULANDI / CI PASS /
  fiziksel cihaz kabulü bekliyor
- PR #14: merge edildi (10 Ağustos 2026)
- PR #15: kaynak PR açık / Draft / merge edilmedi; değişiklikleri PR #16 üzerinden
  release'e ulaştı; head canlı GitHub PR metadata’sından doğrulanır
- PR #19: 11 Ağustos 2026'da release'e merge edildi
- PR #20: release'e merge edildi; release head `1a113a6...`
- PR #21: açık/Draft; son kod değişikliği `2b247e9...`; kod CI #112 PASS
- Android geliştirici doğrulaması: tamamlandı
- Son Play bilgisi: 12 geçerli testçi / 4 kesintisiz gün; UI yeniden okuması açık

### BR-P1-002 - Firebase production envanteri

- Auth sağlayıcıları
- SHA kayıtları
- Functions
- Firestore rules/indexes
- Dev/prod ayrımı

### BR-P1-003 - Canlı Düello release doğrulaması

- 10/20/30
- otomatik eşleştirme
- aynı sorular
- skor/ilerleme
- maç sonucu
- BR/lig tek sefer işleme
- iki telefon testi
- kopma/ayrılma akışları

### BR-P1-004 - UMP testi

Türkiye dışı uygun test bölgesi/debug yöntemiyle onay formunu doğrula.

### BR-P1-005 - Oyun modları ve piyon sistemini sadeleştir — UYGULANDI / DRAFT PR BEKLİYOR

- Diğer Oyun Modları üst alanı ve kartları kompaktlaştırıldı.
- Sabit mod sayısı yerine `Farklı mücadele modları` başlığı kullanıldı.
- Aile Modu ve Turnuva Modu kartları/navigasyon girişleri kaldırıldı.
- Piyon kataloğu korunarak ayrı nadirlik modeli, ekranı, etiketleri ve
  nadirlik temelli görsel vurgu kaldırıldı.
- Favori piyon kaydı ile geçersiz eski indeks fallback'i korunur.
- Hedefli sadeleştirme testleri ve sistem smoke testleri PASS'tir.

### BR-P1-006 - Pseudonymous kapalı test kullanım telemetrisi — UYGULANDI / DRAFT PR BEKLİYOR

- `firebase_analytics` merkezi, hata yalıtımlı bir servis arkasına eklendi.
- Uygulama süreç başlangıcı, ekran, oyun seçimi/başlangıç/tamamlanma/yarıda bırakma,
  joker, ödüllü reklam ve Canlı Düello yaşam döngüsü olayları bağlandı.
- Parametre sözleşmesi hesap kimliği içermeyen oyun boyutlarıyla sınırlandı; kullanıcı kimliği ve
  serbest parametre haritası kabul edilmez.
- Firebase SDK'nın izin sonrasında pseudonymous app-instance ID ürettiği açıkça
  belgelenir; telemetri tam anonim olarak adlandırılmaz.
- Analytics varsayılan kapalıdır; açık kullanıcı tercihi cihazda saklanır,
  geri alınabilir ve izin yokken oyun eksiksiz çalışır.
- `app_process_started` yalnız uygulama süreç başlangıcını belirtir; GA oturum
  metriği olarak kullanılmaz ve oturum sayımı otomatik `session_start` ile yapılır.
- Tercih `unknown` ise sürüm başına bir kez zorlamayan izin istemi gösterilir;
  `Şimdi Değil` sonrasında kullanıcı Ayarlar'dan istediği zaman açabilir.
- Android Advertising ID toplaması ve Analytics reklam kişiselleştirme
  sinyalleri kapatıldı; reklam amaçlı consent değerleri reddedilir.
- Soru ekranındaki her dokunuş veya her cevap için olay üretilmez.
- Unit/widget sözleşme testleri Analytics hatalarının oyuna taşmadığını,
  izinli parametreleri ve adlandırılmış ekran ölçümünü doğrular.
- AAB üretimi/yayını bu görevin kapsamında değildir.

---

## P2 - Görsel ve pazarlama

### BR-P2-001 - 3B tahta için 6 rozet eşlemesini çöz

Çalışmaya yeniden başlamadan önce gerçek 6 kategori ve 8 konsept arasındaki seçim netleşmeli.

### BR-P2-002 - Numaralı geometri önizlemesi

67 node'u görsel debug katmanında doğrula. Onay alınmadan süsleme veya APK yok.

### BR-P2-003 - Profesyonel tanıtım videosu

Eski setleri yeniden kullanma. Gerçek kurgu, efekt, ses ve güçlü açılış üret.

### BR-P2-004 - Mağaza varlık denetimi

Telefon, tablet, Chromebook, PC ve XR için:
`hazır / yüklendi / reddedildi / yeniden yapılacak`

durumunu canlı Play Console ile kaydet.

---

## P3 - Yayın sonrası

- Dünya Turnuvası
- Gelişmiş lig sezonları
- Klan
- Raid
- Günün Sorusu
- Dünya Haritası
- Arkadaşımla Oyna oda kodu
