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

**Durum:** UYGULANDI / CI PASS / DRAFT PR İNCELEMESİ BEKLİYOR

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
- RC2 workflow_dispatch çalıştırılmadı; release merge'i Levent onayı bekler.

---

## P1 - Teknik doğrulama

### BR-P1-001 - GitHub canlı envanteri

**11 Ağustos 2026 doğrulaması:**

- Kanonik repo: `ZMilaStudio/BilgiRotasi`
- Release head: `fcf253e2358ffb6e74f4ac9dddbab8b64ac15509`
- Release sürümü: `1.68.14+104`
- PR #13: açık / Draft / merge edilmedi; ödüllü reklam işi UYGULANDI / CI PASS /
  fiziksel cihaz kabulü bekliyor
- PR #14: merge edildi (10 Ağustos 2026)
- PR #15: kaynak PR açık / Draft / merge edilmedi; değişiklikleri PR #16 üzerinden
  release'e ulaştı; head canlı GitHub PR metadata’sından doğrulanır
- PR #19: açık / Draft / merge edilmedi; Android 16 AdMob PR kapısı run #103 ile
  PASS
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
