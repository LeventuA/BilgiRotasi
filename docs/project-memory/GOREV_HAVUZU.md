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

**Durum:** RELEASE'E ENTEGRE / PR #25 KOD CI PASS / FİZİKSEL KABUL BEKLİYOR

Kesin sözleşme:

- tamamlanan oyun başına 1 hak
- aynı oyun için tekrar yok
- yeni tamamlanan oyunla yeniden hak
- günlük/oturumluk toplam kota yok
- +10 XP

Kaynak Draft PR #13 açık ve merge edilmemiştir. İşlevsel oyun-başına hak sistemi PR #16 üzerinden release'e ulaşmıştır.

Yeni kabul bulgusu:

- `1.68.14+104` kapalı-test AAB'si `FIREBASE_ENVIRONMENT=production` + `ADMOB_ENVIRONMENT=closed_test` kullanır.
- Eski `SupportRewardCard`, production Firebase açıkken +10 XP kartını kapattığı için RC2 #326 build'inde fiziksel rewarded kabul yapılamıyordu.
- PR #25 `fix/closed-test-rewarded-acceptance`, closed-test Google demo reklam profilini production Firebase ile açar; gerçek production reklam profilini SSV cutover tamamlanana kadar fail-closed tutar.
- Son işlevsel PR #25 kod head'i: `2cc47846b42cf98b4f8303bb86148cc475060824`.
- Kod-head CI #128: run `31635781505`, job `94245596601`, **SUCCESS**.
- Artifact: `BilgiRotasi-AdMob-1.68.14-104-kanitlari`, ID `9157235566`, digest `sha256:e7ab0d5b683454f79c4f1a9555fe027906fa5333ec1b016609452f68b384e5c9`.
- Android 16 attempt 1 PASS, attempt 2 SKIPPED; final AdMob app/release gate PASS; PID `1871`; app crash/ANR/FATAL/process-death yok.

**Bitti ölçütü:**

- PR #25 final project-memory head CI PASS.
- Levent açık onayıyla PR #25 release'e merge edildi.
- Merge sonrası fresh geniş RC2 PASS.
- Güncel Play closed-test build'inde Google demo rewarded reklamı fiziksel cihazda tamamlandı.
- +10 XP yalnız tamamlanan reklamda verildi; aynı gameId ikinci ödül vermedi; başarısız reklam sonrası hak doğru kaldı.

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

---

### BR-P0-008 - RC2 analytics consent popup kapısını doğrula

**Durum:** TAMAMLANDI / PR #21 RELEASE'E MERGE EDİLDİ

- RC2 #323 run `31568589298`, job `94025527635`, artifact `9130712889`.
- Kök neden: Analytics consent penceresi açık kalırken eski validator yanlış erken `ANALYTICS_CONSENT_HANDLED=PASS` yazabiliyordu.
- `Değil` OCR eşleşmesi önceliklendirildi; tek ADB tap başarı sayılmaz.
- PASS yalnız auth ekranında `Google|Misafir` gerçekten görüldükten sonra yazılır.
- PR #21 merge commit'i: `2ce47112fce1a0c462ae9f95e8187a6e1d148581`.

---

### BR-P0-009 - Post-auth Misafir tap yarışını kaldır ve final Android 16 RC2 gate'ini geçir

**Durum:** TAMAMLANDI / PR #23 RELEASE'E MERGE EDİLDİ / RC2 #326 PASS

- RC2 #325'te auth sonrası Home bekleme döngüsü `Misafir` OCR tokenına ikinci ADB tap üretebiliyordu.
- Flutter navigasyonu değiştirilmedi; validator post-auth aşaması salt-okunur hale getirildi.
- PR #23 kod commit'i: `55879a3c5b29d31b25bd0402f8ed623e8afab566`.
- PR #23 merge commit'i / son işlevsel release commit'i: `ec20e66e1d52126ce99fa09e29f606ae14a5f7a2`.
- Docs-only PR #24 sonrası release HEAD: `bb988e7e4d60a41c1711e70d2ec6125e7136b0d5`.
- Sürüm: `1.68.14+104`.
- Fresh RC2 #326: run `31614662061`, job `94174350962`, **SUCCESS**.
- Android 16 deneme 1 PASS; temiz deneme 2 gerekmedi ve SKIPPED.
- Artifact: `BilgiRotasi-1.68.14-104-closed-test-release`, ID `9149285776`.
- Artifact digest: `sha256:c69b44f40152ecc256ea5ace57c997bf3c8dafb8c051cdfaf69df288837fd56e`.
- `ANDROID16_APP_GATE.txt`: `APK_INSTALL`, `APP_LAUNCH`, `ANALYTICS_CONSENT_HANDLED`, `GUEST_LOGIN`, `HOME_OYNA`, `APP_PID`, `APP_LOGCAT`, `APP_GATE`, `POST_GATE_LOGCAT_BOUNDARY` = PASS.
- `ANDROID16_VALIDATION_RESULT.txt`: `RESULT=PASS`, `RELEASE_GATE=PASS`, `APP_GATE=PASS`, `SETTINGS_TUTORIAL_DIAGNOSTIC=PASS`.
- PID `3566`; app crash/ANR/FATAL/process-death yok.

**Bitti ölçütü:** Karşılandı. RC2 debugging'e geri dönülmez. Ancak PR #25 merge edilirse yeni işlevsel SHA için fresh RC2 gerekir; #326 rerun edilmez.

---

## P1 - Teknik ve yayın kabul doğrulamaları

### BR-P1-001 - GitHub canlı envanteri

**12 Ağustos 2026 doğrulaması:**

- Kanonik repo: `ZMilaStudio/BilgiRotasi`
- Release branch: `release/final-closed-test-aab-1.68.8`
- Release HEAD: `bb988e7e4d60a41c1711e70d2ec6125e7136b0d5` (docs-only PR #24)
- Son işlevsel release commit'i: `ec20e66e1d52126ce99fa09e29f606ae14a5f7a2`
- Release sürümü: `1.68.14+104`
- PR #7: açık / Draft / base `main`; merge edilmeyecek.
- PR #12: açık; 3B deterministik geometri.
- PR #13: açık / Draft; kaynak rewarded PR.
- PR #15: açık / Draft; telemetri işi PR #16 üzerinden release'e ulaştı.
- PR #21, #23, #24: merge edildi.
- PR #25: açık / Draft; kod-head CI #128 PASS.
- RC2 #326: SUCCESS; PR #25 merge edilirse yeni kod için fresh RC2 gerekir.

---

### BR-P1-002 - Firebase production envanteri

**Durum:** REPO ENVANTERİ DOĞRULANDI / CANLI DEPLOY DURUMU AÇIK

Repo/source:

- Production proje: `bilgi-rotasi-f255d`
- Android package: `com.leventua.bilgirotasi`
- `.firebaserc`: yok; deploy yapılacaksa açık `--project bilgi-rotasi-f255d` zorunlu.
- Functions runtime: Node 20.
- İstemci Functions region: `europe-west1`.
- App Check production provider: Play Integrity; dev/test: debug.
- 3 composite index:
  - `live_duel_queue`: questionCount/status/ratingBucket
  - `live_duel_matches`: status/updatedAt
  - `live_duel_matches`: playerUids ARRAY_CONTAINS/resultProcessed
- RC2 #326 source/build doğrulamasında Functions testleri, Firestore Rules emulator ve production Firebase profile PASS.

Canlı servisten doğrulanacak:

- Google Auth provider
- Android package ve SHA kayıtları
- Functions deployed names/revisions/region
- Firestore rules active revision
- Firestore indexes READY durumu
- App Check / Play Integrity enforcement ve metrikler

**Kural:** Kör/toplu Firebase deploy yapılmaz.

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

**Durum:** AÇIK / KÖK KAYNAK DOĞRULANDI

`KARARLAR.md` içinde **“Günlük giriş ödülü yok.”** kararı bulunmasına rağmen canlı release `lib/retention_system.dart::RetentionProgressService.initialize()` gerçek XP ödülü vermektedir.

Doğrulanan kaynak davranışı:

- ödül dizisi `20, 30, 40, 50, 60, 80, 120`
- login streak yeni günde ilerletilir
- `lastLoginReward` yazılır
- `XpProgressService._award(reward, 'Günlük giriş serisi • N. gün')` çağrılır

RC2 #325 `+20 XP • Günlük giriş serisi • 1. gün` ekranı bu kaynakla uyumludur.

**Bitti ölçütü:**

- Ayrı branch'te günlük giriş XP ödülü kaldırıldı; gerekiyorsa yalnız streak istatistiği ürün kararına uygun biçimde korundu.
- Retention/XP testleri ödül verilmemesini kilitledi.
- CI PASS.
- Ayrı PR inceleme/merge akışı tamamlandı.
- PR #25 / RC2 validator değişiklikleriyle karıştırılmadı.

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

### BR-P1-009 - Production rewarded SSV sözleşmesini ürün kararıyla uyumlu hale getir

**Durum:** AÇIK / PRODUCTION'A DEPLOY EDİLMEMİŞ

`docs/rewarded-ssv-setup.md` ve `functions/rewarded_ssv.js` mevcut SSV hazırlığının production'a deploy edilmediğini belirtir. Aday backend günlük 3 işlem / toplam +30 XP limiti taşır; bu, güncel “günlük/oturumluk toplam kota yok” kararıyla çelişir.

**Kural:** Bu sözleşme düzeltilmeden `firebase deploy --only functions` toplu deploy yapılmaz ve `server_config/rewarded.ssvEnabled` açılmaz.

**Bitti ölçütü:**

- Production SSV ürün sözleşmesi tamamlanan oyun başına tek hak ve toplam günlük/oturumluk kota yok kararına uyarlanır.
- Nonce / transaction id idempotency / Google ECDSA doğrulaması korunur.
- Functions testleri yeni sözleşmeyi kilitler.
- AdMob SSV callback/test aracı ve istemci `custom_data` cutover fiziksel/staging kanıtıyla doğrulanır.
- Ayrı kontrollü deploy ve sonrasında production rewarded açılışı yapılır.

---

### BR-P1-010 - Play/Firebase signing SHA rolünü canlı konsoldan kesinleştir

**Durum:** AÇIK

- Upload/AAB SHA-1: `00:0E:E4:3F:41:0A:BC:6B:4F:63:4C:4F:71:6D:76:EB:19:08:41:15`
- Güncel release testi Play-signing/OAuth için `26:3C:46:C6:AE:9F:27:C3:B3:38:10:FA:89:8C:D7:EB:93:73:CC:F4` bekler.
- Eski devir kaydında `17:E1:EC:6C:77:4F:B4:59:63:FA:7A:76:51:7D:21:B2:BB:7C:81:1F` Play App Signing olarak geçer.

**Bitti ölçütü:** Play Console uygulama imzalama ve upload sertifika SHA-1 ekranı ile Firebase Android app fingerprint listesi karşılaştırılır; üç değerin rolleri kesin kaydedilir ve yanlış/eski test/doküman varsa ayrı PR ile düzeltilir.

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
