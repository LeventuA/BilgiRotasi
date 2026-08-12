# Bilgi Rotası - Görev Havuzu

## P0 - Kapalı Test ve soru kalitesi

### BR-P0-001 - Kapalı Test canlı durumunu doğrula

**Durum:** İZLENİYOR

- Son doğrulanan: 12 geçerli testçi
- Son doğrulanan: 4 kesintisiz gün
- Güncel Play Console sayacı yeniden okunacak.
- Son aktif Play AAB sürümü canlı ekrandan yeniden doğrulanacak.

**Bitti ölçütü:** Tarihli Play Console ekran kanıtı ve güncel sayaç `BILGI_ROTASI_DURUM.md` dosyasına yazılır.

---

### BR-P0-002 - 14 açıkça bozuk soruyu düzelt

**Durum:** AÇIK

Liste: `SORU_GERI_BILDIRIM_HAVUZU.md`

**Bitti ölçütü:**

- Gerçek JSON kayıtları incelendi.
- Soru metni, dört şık, doğru indeks, açıklama, kategori ve zorluk birlikte doğrulandı.
- QA/test geçti.
- Ayrı PR merge edildi.
- Yeni AAB Kapalı Test'e yüklendi.
- Sheet satırları ancak bundan sonra kapatıldı.

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

Kaynak Draft PR #13 açık ve merge edilmemiştir. İşlevsel değişiklik PR #16 entegrasyonu üzerinden release dalına ulaşmıştır.

İstenen sözleşme:

- tamamlanan oyun başına 1 hak
- aynı oyun için tekrar yok
- yeni tamamlanan oyunla yeniden hak
- günlük/oturumluk toplam kota yok
- +10 XP

**Bitti ölçütü:** Güncel Play kapalı test sürümünde gerçek cihazda ödül, tekrar engeli ve başarısız reklam sonrası yeniden deneme davranışı kabul edilir.

---

### BR-P0-005 - Final kapalı-test entegrasyon adayını doğrula

**Durum:** TAMAMLANDI / PR #16 RELEASE'E MERGE EDİLDİ

- Dal: `integration/closed-test-next-release`
- Entegrasyon kesimi: `1.68.13+103`
- PR #13 ve PR #15 kaynak Draft PR olarak açık kalır.
- Ödüllü reklam hakkı ve pseudonymous telemetri release hattına taşındı.
- Entegrasyon testleri ve analyze kapıları PASS oldu.

---

### BR-P0-006 - Android 16 AdMob PR kapısını kanıta dayalı yap

**Durum:** TAMAMLANDI / PR #19 RELEASE'E MERGE EDİLDİ

- Run #102 kök nedeni uygulama kurulmadan önce Android paket servisinde `Broken pipe (32)` idi.
- Kritik ADB işlemleri bounded retry kullanır.
- Yalnız açık emulator altyapı kanıtı temiz ikinci emülatöre izin verir.
- Bilgi Rotası crash/ANR/FATAL/process-death sonucu doğrudan FAIL kalır.
- PR #19 merge commit'i: `8a99530de7cb370d4db0edff9214ad833a8907cf`.

---

### BR-P0-007 - RC2 runner pre-script ADB hatasını kaldır

**Durum:** TAMAMLANDI / PR #20 RELEASE'E MERGE EDİLDİ

- RC2 #322 run `31528674369`, job `93903134897`.
- Kök neden: `android-emulator-runner`, proje validator'ından önce `disable-animations` settings çağrısında `Broken pipe (32)` ile kırıldı.
- Android 16 attempt'lerinde `disable-animations: false` kullanılır.
- `/dev/kvm` read/write erişimi emulator başlamadan önce fail-fast doğrulanır.
- Mandatory app/release gate'leri gevşetilmedi.
- PR #20 merge sonrası bu altyapı katmanı doğrulandı.

---

### BR-P0-008 - RC2 analytics consent popup kapısını doğrula

**Durum:** TAMAMLANDI / PR #21 RELEASE'E MERGE EDİLDİ

- RC2 #323 run `31568589298`, job `94025527635`, artifact `9130712889`.
- Kök neden: Analytics consent penceresi açık kalırken eski validator yanlış erken `ANALYTICS_CONSENT_HANDLED=PASS` yazabiliyordu.
- `Değil` OCR eşleşmesi önceliklendirildi; tek ADB tap başarı sayılmaz.
- PASS yalnız auth ekranında `Google|Misafir` gerçekten görüldükten sonra yazılır.
- PR #21 merge commit'i: `2ce47112fce1a0c462ae9f95e8187a6e1d148581`.
- Bu düzeltme sonraki geniş RC2 zincirinde korundu.

---

### BR-P0-009 - Post-auth Misafir tap yarışını kaldır ve final Android 16 RC2 gate'ini geçir

**Durum:** TAMAMLANDI / PR #23 RELEASE'E MERGE EDİLDİ / RC2 #326 PASS

- RC2 #325'te auth sonrası Home bekleme döngüsü `Misafir` OCR tokenına ikinci ADB tap üretebiliyordu.
- Flutter navigasyonu değiştirilmedi; validator post-auth aşaması salt-okunur hale getirildi.
- PR #23 kod commit'i: `55879a3c5b29d31b25bd0402f8ed623e8afab566`.
- PR #23 merge commit'i / güncel release HEAD: `ec20e66e1d52126ce99fa09e29f606ae14a5f7a2`.
- Sürüm: `1.68.14+104`.
- Fresh RC2 #326: run `31614662061`, job `94174350962`, **SUCCESS**.
- Android 16 deneme 1 PASS; temiz deneme 2 gerekmedi ve SKIPPED.
- Artifact: `BilgiRotasi-1.68.14-104-closed-test-release`, ID `9149285776`.
- Artifact digest: `sha256:c69b44f40152ecc256ea5ace57c997bf3c8dafb8c051cdfaf69df288837fd56e`.
- `ANDROID16_APP_GATE.txt`: `APK_INSTALL`, `APP_LAUNCH`, `ANALYTICS_CONSENT_HANDLED`, `GUEST_LOGIN`, `HOME_OYNA`, `APP_PID`, `APP_LOGCAT`, `APP_GATE`, `POST_GATE_LOGCAT_BOUNDARY` = PASS.
- `ANDROID16_VALIDATION_RESULT.txt`: `RESULT=PASS`, `RELEASE_GATE=PASS`, `APP_GATE=PASS`, `SETTINGS_TUTORIAL_DIAGNOSTIC=PASS`.
- Canlı uygulama PID: `3566`.
- Bilgi Rotası crash/ANR/FATAL/process-death kanıtı yok.

**Bitti ölçütü:** Karşılandı. RC2 debugging'e geri dönülmez; yayın kabul aşamasına geçilir.

---

## P1 - Teknik ve yayın kabul doğrulamaları

### BR-P1-001 - GitHub canlı envanteri

**12 Ağustos 2026 doğrulaması:**

- Kanonik repo: `ZMilaStudio/BilgiRotasi`
- Release branch: `release/final-closed-test-aab-1.68.8`
- Release HEAD: `ec20e66e1d52126ce99fa09e29f606ae14a5f7a2`
- Release sürümü: `1.68.14+104`
- PR #7: açık / Draft / base `main`; merge edilmeyecek.
- PR #12: açık; 3B deterministik geometri çalışması.
- PR #13: açık / Draft; ödüllü reklam fiziksel kabulü bekliyor.
- PR #15: açık / Draft; telemetri işi PR #16 üzerinden release'e ulaştı.
- PR #21: merge edildi.
- PR #23: merge edildi.
- RC2 #326: SUCCESS.

---

### BR-P1-002 - Firebase production envanteri

**Durum:** AÇIK / CANLI SERVİSTEN DOĞRULANACAK

- Google Auth sağlayıcısı
- Android package ve SHA kayıtları
- Functions deploy sürümü
- Firestore rules
- Firestore indexes ve hazır olma durumu
- Dev/prod ayrımı
- App Check / Play Integrity provider ve enforcement durumu

**Kural:** Kör Firebase deploy yapılmaz.

---

### BR-P1-003 - Canlı Düello release doğrulaması

**Durum:** AÇIK / FİZİKSEL KABUL GEREKİYOR

- 10/20/30
- otomatik eşleştirme
- iki cihazda aynı sorular ve sıra
- skor/ilerleme
- maç sonucu
- BR/lig tek sefer işleme
- leaderboard güncellemesi
- boş leaderboard'da `—`
- kopma/ayrılma akışları

---

### BR-P1-004 - UMP testi

**Durum:** AÇIK

Türkiye dışı uygun test bölgesi/debug yöntemiyle UMP onay formunu doğrula. Analytics consent ile UMP consent birbirine karıştırılmayacak.

---

### BR-P1-005 - Oyun modları ve piyon sistemini sadeleştir

**Durum:** UYGULANDI / DRAFT PR HATTI AÇIK

- Diğer Oyun Modları üst alanı ve kartları kompaktlaştırıldı.
- Aile Modu ve Turnuva Modu kartları/navigasyon girişleri kaldırıldı.
- Piyon kataloğu korunarak ayrı nadirlik modeli/etiketleri kaldırıldı.
- Favori piyon kaydı ve geçersiz eski indeks fallback'i korunur.

---

### BR-P1-006 - Pseudonymous kapalı test kullanım telemetrisi

**Durum:** UYGULANDI / RELEASE'E PR #16 ÜZERİNDEN ENTEGRE

- Analytics varsayılan kapalıdır.
- Kullanıcı izin verdiğinde pseudonymous app-instance ID oluşabileceği açıkça kabul edilir; sistem tam anonim olarak adlandırılmaz.
- Ad/e-posta/Firebase-Google kullanıcı kimliği/açık kullanıcı adı/reklam kimliği olay parametresi değildir.
- `app_process_started`, ekran ve oyun yaşam döngüsü olayları merkezi servisten geçer.
- Reklam amaçlı consent değerleri denied kalır.
- UMP ve Analytics consent ayrı mekanizmalardır.

---

### BR-P1-007 - Günlük giriş XP karar çelişkisini kaldır

**Durum:** AÇIK

`KARARLAR.md` içinde **“Günlük giriş ödülü yok.”** kararı bulunmasına rağmen RC2 #325 ekran kanıtında `+20 XP • Günlük giriş serisi • 1. gün` görüldü.

**Bitti ölçütü:**

- retention/XP kaynak kodu canlı release üzerinden incelendi.
- Ürün kararına aykırı ödül varsa ayrı branch'te kaldırıldı.
- İlgili testler güncellendi ve PASS oldu.
- Ayrı PR inceleme/merge akışı tamamlandı.
- RC2 validator hotfix'iyle karıştırılmadı.

---

### BR-P1-008 - `RELEASE_READINESS.md` bayat rapor şablonunu düzelt

**Durum:** AÇIK

RC2 #326 artifact'ındaki gerçek AAB ve kalite raporları `1.68.14+104` / 8.710 soru gösterirken `reports/RELEASE_READINESS.md` içinde eski `1.68.8+98`, eski kaynak commit ve 6.710 soru gibi tarihsel metinler kalmıştır.

**Bitti ölçütü:**

- Raporu üreten kaynak/script canlı release üzerinde bulunur.
- Dinamik sürüm, commit, AAB adı ve soru sayısı gerçek workflow değerlerinden üretilir.
- Yeni değişiklik ayrı branch/PR ile test edilir.
- Sırf rapor metni için RC2 #326 rerun edilmez.

---

## P2 - Görsel ve pazarlama

### BR-P2-001 - 3B tahta için 6 rozet eşlemesini çöz

**Durum:** DURDURULDU / KARAR BEKLİYOR

Çalışmaya yeniden başlamadan önce gerçek 6 kategori ve 8 konsept arasındaki seçim netleşmeli.

### BR-P2-002 - Numaralı geometri önizlemesi

67 node deterministik debug katmanında doğrulanacak. Oynanış, BoardMap ve node sırası değişmeyecek; görsel onay olmadan stil/Flutter/APK yok.

### BR-P2-003 - Profesyonel tanıtım videosu

Eski yetersiz setleri final kabul etme. Gerçek kurgu, efekt, ses ve güçlü açılış üret.

### BR-P2-004 - Mağaza varlık denetimi

Telefon, tablet, Chromebook, PC ve XR için `hazır / yüklendi / reddedildi / yeniden yapılacak` durumu canlı Play Console ile kaydedilecek.

---

## P3 - Yayın sonrası

- Dünya Turnuvası
- Gelişmiş lig sezonları
- Klan
- Raid
- Günün Sorusu
- Dünya Haritası
- Arkadaşımla Oyna oda kodu
