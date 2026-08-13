# Bilgi Rotası - Görev Havuzu

## 0A - 13 Ağustos 2026 PR #29/#30 release-readiness kapanış kesimi

Bu bölüm aşağıdaki tarihsel BR-P1-008 ve release HEAD kayıtlarının **güncel durumunu geçersiz kılar**; eski kayıtlar denetim izi olarak korunur.

- Güncel release branch: `release/final-closed-test-aab-1.68.8`.
- Güncel release HEAD: `d1d5a9ea128d3d36fe26fafe95c97bf473c02548` (PR #30 merge).
- Sürüm: `1.68.14+104`.
- PR #29 `fix: generate release readiness from live build facts` release'e merge edildi: `9aef2bd9ceeeba3a47e85e5a508512967d7db29d`.
- Final closed-test run `31654600408`, uygulama/AAB aşamasından önce `git diff --check` ile kırıldı; kök neden dinamik `RELEASE_READINESS.md` üreticisindeki trailing whitespace idi. Bu koşu release AAB kabul kanıtı değildir.
- PR #30 `fix: remove release readiness trailing whitespace` yalnız `tools/release_readiness_report.py` ve `test/release_readiness_report_test.dart` dosyalarını değiştirdi.
- PR #30 kod head'i `1c809e9f4d02c425705e4812b0daadf87418b9fd`; CI #139 run `31655047190`, job `94307567727`: **SUCCESS**.
- PR #30 Levent'in açık onayıyla release'e merge edildi: `d1d5a9ea128d3d36fe26fafe95c97bf473c02548`.
- **BR-P1-008 uygulama/CI/merge kısmı tamamlandı.** Dinamik rapor gerçek `pubspec.yaml`, `assets/questions.json`, GitHub Actions source SHA/ref ve AAB adından üretilir; trailing whitespace regresyon testiyle kilitlidir.
- **Kapanış için kalan kanıt:** güncel release HEAD `d1d5a9ea...` üzerinde yeni `Closed test release doğrulaması` manuel run'ı çalıştırılmalı; artifact içindeki `reports/RELEASE_READINESS.md` canlı `1.68.14+104`, 8.710 soru, doğru source/AAB ve whitespace'siz içerik göstermelidir.
- Fresh RC2 artifact AAB SHA256 için doğrudan indirilen artifact `reports/AAB_SHA256.txt` + gerçek dosya hash'i otoritatiftir: `6904249d00e12e3e671c9a282364dc4791948e9ec45cafecfaae15f8f734d285`. Aşağıdaki eski `690424c...` satırları tarihsel transkripsiyon hatasıdır ve kullanılmamalıdır.

---

## 0 - 13 Ağustos 2026 fresh RC2 durum güncellemesi

Bu bölüm aşağıdaki tarihsel görev satırlarında kalan “fresh RC2 gerekiyor/bekleniyor” ifadelerinin güncel durumunu geçersiz kılar.

- **BR-P0-004:** Fresh geniş RC2 bitti ölçütü artık `[x]`. Run `31645526580`, job `94278055890`, tested release HEAD `d450c573a122231734437fb097cf17a00e583801`, **SUCCESS**. Fiziksel Play closed-test Google demo rewarded kabulü ve +10 XP/tek-gameId/başarısız reklam yeniden deneme maddeleri hâlâ açık.
- **BR-P0-009:** Güncel işlevsel release (`7a50a199...`) fresh RC2 ile kabul edildi; test kesimi `d450c573...` yalnız docs/proje-hafızası farkı taşır. Android 16 AAB-derived Misafir → Home → Oyna, APP_GATE ve RELEASE_GATE PASS; crash/ANR/FATAL/process-death kanıtı yok.
- **BR-P1-001:** Fresh RC2 artifact `BilgiRotasi-1.68.14-104-closed-test-release`, ID `9160985710`, digest `sha256:0a086fab7c0730321c8768aefb94b7887f365d3cc80bf8fe087da83c7a425815`; AAB SHA256 `690424c771867ce4835019449e8f4cc75e36aeca5779838fa7996a96faaa04e1`.
- **BR-P1-008:** AÇIK kalır. Fresh artifact `RELEASE_READINESS.md` üst bilgisi hâlâ eski `1.68.8+98` / 6.710 soru ve tarihsel source/AAB değerlerini taşır; gerçek AAB/gate kabulünü geçersiz kılmaz.
- Play/Firebase canlı servis kabulü ve fiziksel cihaz kabul maddeleri bu RC2 ile kapanmış sayılmaz.

---

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

**Durum:** RELEASE'E ENTEGRE / PR #25 MERGED / FRESH RC2 + FİZİKSEL KABUL BEKLİYOR

Kesin sözleşme:

- tamamlanan oyun başına 1 hak
- aynı oyun için tekrar yok
- yeni tamamlanan oyunla yeniden hak
- günlük/oturumluk toplam kota yok
- +10 XP

Kaynak Draft PR #13 açık ve merge edilmemiştir. İşlevsel oyun-başına hak sistemi PR #16 üzerinden release'e ulaşmıştır.

Closed-test kabul bulgusu ve düzeltme:

- `1.68.14+104` kapalı-test AAB `FIREBASE_ENVIRONMENT=production` + `ADMOB_ENVIRONMENT=closed_test` kullanır.
- Eski `SupportRewardCard`, production Firebase açıkken +10 XP kartını kapattığı için RC2 #326 build'inde fiziksel rewarded kabul yapılamıyordu.
- PR #25 `fix/closed-test-rewarded-acceptance`, closed-test Google demo reklam profilini production Firebase ile açar; gerçek production reklam profilini SSV cutover tamamlanana kadar fail-closed tutar.
- Son işlevsel kod head'i: `2cc47846b42cf98b4f8303bb86148cc475060824`.
- Kod-head CI #128: run `31635781505`, job `94245596601`, **SUCCESS**.
- Final PR head: `f8939b6f6aa950bda48bedf8b87dc0a51c761916`.
- Final CI #129: run `31637213948`, job `94250454471`, **SUCCESS**.
- Final artifact: `BilgiRotasi-AdMob-1.68.14-104-kanitlari`, ID `9157834250`, digest `sha256:3b2c0347b3d194f84618f8c02863dcd5ad21c76cc7ce7b72b906f0314c8f8c25`.
- PR #25 Levent'in açık onayıyla release'e merge edildi: `7a50a1997c6eade985a3933fd019055dd6a2c791`.

**Bitti ölçütü:**

- [x] PR #25 final project-memory head CI PASS.
- [x] Levent açık onayıyla PR #25 release'e merge edildi.
- [ ] Merge sonrası fresh geniş RC2 PASS.
- [ ] Güncel Play closed-test build'inde Google demo rewarded reklamı fiziksel cihazda tamamlandı.
- [ ] +10 XP yalnız tamamlanan reklamda verildi; aynı gameId ikinci ödül vermedi; başarısız reklam sonrası hak doğru kaldı.

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

**Durum:** TARİHSEL KABUL TAMAMLANDI / PR #23 MERGED / RC2 #326 PASS / GÜNCEL RELEASE İÇİN YENİ RC2 GEREKİYOR

- RC2 #325'te auth sonrası Home bekleme döngüsü `Misafir` OCR tokenına ikinci ADB tap üretebiliyordu.
- Flutter navigasyonu değiştirilmedi; validator post-auth aşaması salt-okunur hale getirildi.
- PR #23 kod commit'i: `55879a3c5b29d31b25bd0402f8ed623e8afab566`.
- PR #23 merge commit'i: `ec20e66e1d52126ce99fa09e29f606ae14a5f7a2`.
- Fresh RC2 #326: run `31614662061`, job `94174350962`, **SUCCESS**.
- Artifact: `BilgiRotasi-1.68.14-104-closed-test-release`, ID `9149285776`, digest `sha256:c69b44f40152ecc256ea5ace57c997bf3c8dafb8c051cdfaf69df288837fd56e`.
- `GUEST_LOGIN`, `HOME_OYNA`, `APP_GATE`, `RELEASE_GATE` ve diğer mandatory gate'ler PASS; PID `3566`; app crash/ANR/FATAL/process-death yok.

**Güncel sınır:** PR #25 sonrasında release HEAD `7a50a199...` oldu. #326 yalnız `ec20e66...` SHA'sını doğrular; güncel release için eski run rerun edilmeden fresh geniş RC2 gerekir.

---

## P1 - Teknik ve yayın kabul doğrulamaları

### BR-P1-001 - GitHub canlı envanteri

**13 Ağustos 2026 doğrulaması:**

- Kanonik repo: `ZMilaStudio/BilgiRotasi`
- Release branch: `release/final-closed-test-aab-1.68.8`
- Release HEAD / son işlevsel release: `7a50a1997c6eade985a3933fd019055dd6a2c791` (PR #25)
- Release sürümü: `1.68.14+104`
- `main` HEAD: `ab9b4f3797a02b92f98f92e439b7edc4c608fec3` (PR #26; yalnız workflow görünürlüğü)
- `main` yayın kaynağı değildir.
- PR #7: açık / Draft / release→main; merge edilmeyecek.
- PR #12: açık; 3B deterministik geometri.
- PR #13: açık / Draft; kaynak rewarded PR.
- PR #15: açık / Draft; telemetri işi PR #16 üzerinden release'e ulaştı.
- PR #21, #23, #24, #25 merge edildi.
- PR #26 main'e merge edildi; manual fresh RC2 workflow'u artık Actions listesinde ACTIVE.
- RC2 #326 SUCCESS fakat güncel `7a50a199...` release SHA'sı için stale; fresh RC2 bekleniyor.

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

Türkiye dışı uygun test bölgesi/debug yöntemiyle UMP onay formını doğrula. Analytics consent ile UMP consent birbirine karıştırılmayacak.

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

**Bitti ölçütü:**

- Ayrı branch'te günlük giriş XP ödülü kaldırıldı; gerekiyorsa yalnız streak istatistiği ürün kararına uygun biçimde korundu.
- Retention/XP testleri ödül verilmemesini kilitledi.
- CI PASS.
- Ayrı PR inceleme/merge akışı tamamlandı.
- RC2/rewarded workflow değişiklikleriyle karıştırılmadı.

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

### BR-P1-011 - Fresh RC2 manuel workflow görünürlüğünü default branch'te etkinleştir

**Durum:** TAMAMLANDI / PR #26 MAIN'E MERGE EDİLDİ

Kök neden:

- `closed-test-release.yml` ve `closed-test-release-core.yml` yalnız release dalındaydı.
- GitHub Actions manuel workflow UI listesinde default branch'te bulunmayan wrapper görünmüyordu.

Uygulama:

- Branch: `ci/expose-closed-test-release-workflow`
- Commit: `3dc820502ba131258824b27776f292a67e85d54e` — `ci: expose closed-test release workflow on main`
- PR #26 merge commit: `ab9b4f3797a02b92f98f92e439b7edc4c608fec3`
- Değişiklik yalnız `.github/workflows/closed-test-release.yml` ve `.github/workflows/closed-test-release-core.yml`.
- Release'teki ve RC2 #326 source SHA'sındaki kanıtlanmış bloblar byte-for-byte kullanıldı.
- Wrapper SHA: `f8fe355ad547c7fc4a5ec48c2809d65796b402df`
- Core SHA: `3afa8793d3f437c63d690c86f3b6dbaaca2ce83a`
- Quality Checks #292: run `31642575342`, job `94268451360`, **SUCCESS**.
- `Closed test release çekirdeği`: workflow ID `333114585`, **ACTIVE**.
- `Closed test release doğrulaması`: workflow ID `333114587`, **ACTIVE**.
- Release branch ve sürüm değişmedi; PR #7 Draft kaldı.

Eski `apply-game-save-isolation-v4.yml` push run `31642536946` config-level failure üretti ve **0 job** çalıştırdı. Bu ayrı tarihsel workflow borcudur ve PR #26'nın iki dosyalık değişimiyle ilişkili değildir.

**Bitti ölçütü:** Karşılandı. `Closed test release doğrulaması` Actions listesinde ACTIVE ve release branch seçilerek `CLOSED_TEST` ile manuel tetiklenebilir.

---

### BR-P1-012 - Eski `apply-game-save-isolation-v4.yml` config-level workflow hatasını incele

**Durum:** AÇIK / AYRI TEKNİK BORÇ

- PR #26 branch push'unda run `31642536946` kırmızı oluştu.
- Run'da **0 job** vardır; uygulama, build veya test çalışmamıştır.
- Bu hata PR #26'nın closed-test workflow eklemesiyle ilişkilendirilmemeli ve fresh RC2 işini bloke etmemelidir.

**Bitti ölçütü:** Workflow dosyası ve tarihsel kullanım amacı ayrı branch'te incelenir; gerekiyorsa güvenli biçimde düzeltilir veya artık kullanılmıyorsa kontrollü kaldırma kararı alınır. Uygulama/release koduyla karıştırılmaz.

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
