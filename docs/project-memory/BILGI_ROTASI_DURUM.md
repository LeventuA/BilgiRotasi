# Bilgi Rotası - Güncel Proje Durumu

**Kesim noktası:** 12 Ağustos 2026
**Durum sınıfları:** `DOĞRULANDI`, `RAPORLANDI`, `AÇIK`, `DURDURULDU`

---

## 1. Yayın kaynağı

| Alan | Güncel değer | Durum | Kaynak |
|---|---|---|---|
| Kanonik repo | `ZMilaStudio/BilgiRotasi` | DOĞRULANDI | 12 Ağustos 2026 GitHub canlı sorgusu |
| Android paket adı | `com.leventua.bilgirotasi` | DOĞRULANDI | Release artifact / source |
| Yayın/release dalı | `release/final-closed-test-aab-1.68.8` | DOĞRULANDI | GitHub canlı branch |
| Release HEAD | `bb988e7e4d60a41c1711e70d2ec6125e7136b0d5` | DOĞRULANDI | GitHub canlı branch; docs-only PR #24 merge |
| Son işlevsel release commit'i | `ec20e66e1d52126ce99fa09e29f606ae14a5f7a2` | DOĞRULANDI | PR #23 merge; RC2 #326 source SHA |
| Gerçek paket sürümü | `1.68.14+104` | DOĞRULANDI | Release `pubspec.yaml` |
| `main` dalı | Güncel yayın kaynağı değil | KESİN KARAR | `KARARLAR.md` |
| PR #7 | Açık / Draft / base `main` | DOĞRULANDI | GitHub canlı PR |
| PR #12 | Açık; 3B deterministik geometri | DOĞRULANDI | GitHub canlı PR |
| PR #13 | Açık / Draft; kaynak ödüllü reklam PR'ı | DOĞRULANDI | GitHub canlı PR |
| PR #15 | Açık / Draft; telemetri işi PR #16 üzerinden release'e ulaştı | DOĞRULANDI | GitHub canlı PR |
| PR #21 | Merge edildi; merge commit `2ce47112fce1a0c462ae9f95e8187a6e1d148581` | DOĞRULANDI | GitHub canlı PR |
| PR #23 | Merge edildi; merge commit `ec20e66e1d52126ce99fa09e29f606ae14a5f7a2` | DOĞRULANDI | GitHub canlı PR |
| PR #24 | Merge edildi; docs-only merge commit `bb988e7e4d60a41c1711e70d2ec6125e7136b0d5` | DOĞRULANDI | GitHub canlı PR |
| PR #25 | Açık / Draft; closed-test ödüllü reklam kabul kapısı | DOĞRULANDI | GitHub canlı PR / CI #128 |
| Android geliştirici doğrulaması | Tamamlandı | RAPORLANDI | Levent'in Play doğrulaması |

**Kural:** Branch adındaki `1.68.8`, paket sürümü değildir. Gerçek sürüm her zaman hedef dalın `pubspec.yaml` dosyasından okunur.

---

## 2. RC2 #326 - final Android 16 release gate

Fresh manuel RC2:

- Workflow run: `31614662061`
- Run number: `326`
- Job: `94174350962`
- Event: `workflow_dispatch`
- Branch: `release/final-closed-test-aab-1.68.8`
- Head SHA: `ec20e66e1d52126ce99fa09e29f606ae14a5f7a2`
- Sonuç: **SUCCESS**
- Android 16 deneme 1: **PASS**
- Temiz deneme 2: **SKIPPED**; gerekmedi.

Artifact:

- ID: `9149285776`
- Ad: `BilgiRotasi-1.68.14-104-closed-test-release`
- Boyut: yaklaşık 79 MB
- Digest: `sha256:c69b44f40152ecc256ea5ace57c997bf3c8dafb8c051cdfaf69df288837fd56e`
- AAB: `BilgiRotasi-1.68.14-104-closed-test.aab`
- Paket: `com.leventua.bilgirotasi`
- Sürüm: `1.68.14+104`

`ANDROID16_APP_GATE.txt`:

- `APK_INSTALL=PASS`
- `APP_LAUNCH=PASS`
- `ANALYTICS_CONSENT_HANDLED=PASS`
- `GUEST_LOGIN=PASS`
- `HOME_OYNA=PASS`
- `APP_PID=PASS`
- `APP_LOGCAT=PASS`
- `APP_GATE=PASS`
- `POST_GATE_LOGCAT_BOUNDARY=PASS`

`ANDROID16_VALIDATION_RESULT.txt`:

- `RESULT=PASS`
- `RELEASE_GATE=PASS`
- `APP_GATE=PASS`
- `SETTINGS_TUTORIAL_DIAGNOSTIC=PASS`

Canlı Bilgi Rotası PID: `3566`.

Artifact log taramasında Bilgi Rotası paketine ait crash, ANR, `FATAL EXCEPTION` veya process death kanıtı bulunmadı.

**Durum:** Android 16 mandatory release gate `DOĞRULANDI / TAMAMLANDI`. Eski RC2 #319/#321/#322/#323/#325 yalnız tarihçe ve regression bağlamıdır; yeniden debug hedefi değildir.

**Önemli:** PR #25 işlevsel uygulama kodu getirir. PR #25 merge edilirse RC2 #326 yeni kodu doğrulamaz; eski #326 rerun edilmeden yeni bir fresh RC2 çalıştırılmalıdır.

---

## 3. RC2 #325 ve PR #23 kök nedeni

RC2 #325'te emulator ve uygulama süreci sağlıklıydı; `GUEST_LOGIN/HOME_OYNA` zinciri tamamlanmadı.

Canlı source ve artifact incelemesi şu kök nedeni gösterdi:

- AUTH ekranında `Misafir` butonuna doğru bir kez basılıyordu.
- Home bekleme döngüsü daha sonra yeniden `Misafir` OCR tokenı arayıp ikinci ADB tap üretebiliyordu.
- Auth → Home geçişi asenkron olduğundan bu gecikmiş dokunuş yanlış Home koordinatına düşebiliyordu.
- Flutter navigation/retention sistemi bu RC2 yönlendirme hatasının kök nedeni değildi.

PR #23 ile post-auth Home döngüsü salt-okunur yapıldı; ikinci `Misafir` tap kaldırıldı. Mandatory `Oyna` gate'i, emulator health sınıflandırması ve gerçek app crash/ANR fail-fast sözleşmesi değiştirilmedi.

PR #23 kod commit'i: `55879a3c5b29d31b25bd0402f8ed623e8afab566`.

Bu düzeltme fresh RC2 #326'da gerçek AAB-derived `Misafir → Home → Oyna` zinciriyle doğrulandı.

---

## 4. Google Play

- `1.68.13+103` daha önce Dahili Test'te gerçek cihazda doğrulandı ve Kapalı Test kanalına yayımlandı.
- Son doğrulanan Play kapalı test durumu **12 geçerli testçi / 4 kesintisiz gün**dür.
- Bu değer güncel Play Console UI'sından yeniden okunmadan ileri gün sayısı tahmin edilmeyecek.
- Android geliştirici doğrulaması tamamlandı.
- `1.68.14+104` için RC2 #326 teknik engeli kalkmıştır.
- `1.68.14+104` AAB'nin Play kapalı test kanalına gerçekten yüklenip yüklenmediği bu kesim noktasında **DOĞRULANACAK** durumundadır.
- PR #25 merge edilirse yeni işlevsel SHA için fresh RC2 PASS olmadan Play'e yeni AAB yüklenmez.

**Durum:** Kapalı test hattı aktif; yeni AAB yükleme kararı öncesi canlı Firebase/Play kabul kontrolleri açık.

---

## 5. Firebase / App Check / Play Integrity

Production Firebase projesi: `bilgi-rotasi-f255d`.

Repo/source envanteri:

- Android package: `com.leventua.bilgirotasi`.
- `firebase.json` Functions için Node 20, Firestore rules/indexes ve emulator yapılandırması içerir.
- Repoda `.firebaserc` yoktur. Her eventual deploy açıkça `--project bilgi-rotasi-f255d` kullanmadan yapılmamalıdır.
- Functions region istemci tarafında `europe-west1` olarak sabittir.
- `firestore.indexes.json` içinde 3 composite index vardır:
  1. `live_duel_queue`: `questionCount ASC`, `status ASC`, `ratingBucket ASC`
  2. `live_duel_matches`: `status ASC`, `updatedAt ASC`
  3. `live_duel_matches`: `playerUids ARRAY_CONTAINS`, `resultProcessed ASC`
- App Check production provider'ı Play Integrity'dir; dev/test profili debug provider kullanır.
- RC2 #326 source/build doğrulamasında Production Firebase profile, Cloud Functions testleri ve Firestore Rules emulator testleri PASS olmuştur.
- RC2 artifact'ı uzak production veritabanını okumadığını/değiştirmediğini belirtir; bu nedenle canlı Functions/Rules/Indexes deploy durumu **DOĞRULANACAK** olarak kalır.

Bilinen/doğrulanmış geçmiş:

- Daha önce yanlış Dizily Google Cloud bağlantısı kaldırılıp doğru Bilgi Rotası projesi bağlandı.
- Bir aşamada Firestore App Check ekranında `66/66` ve `%100 doğrulanmış istek` görüldü.

Canlı servisten yeniden doğrulanacaklar:

- Google Auth provider
- Android SHA kayıtları ve hangi sertifikanın hangi amaçla kullanıldığı
- Functions deploy sürümü/names/region
- Firestore indexes ve READY durumu
- Firestore rules aktif sürümü
- App Check / Play Integrity enforcement ve güncel metrikler

**Kural:** Kör veya toplu Firebase deploy yapılmaz.

---

## 6. İmza ayrımı ve açık çelişki

RC2/AAB upload signing SHA-1:

`00:0E:E4:3F:41:0A:BC:6B:4F:63:4C:4F:71:6D:76:EB:19:08:41:15`

Güncel release testi `test/firebase_play_signing_profile_test.dart`, Play-signing/OAuth SHA-1 olarak şunu bekler:

`26:3C:46:C6:AE:9F:27:C3:B3:38:10:FA:89:8C:D7:EB:93:73:CC:F4`

Bu değer 1 Ağustos 2026 tarihli `972042915d1ef8294335e4372f8550cbdf6213bb` commit'iyle bilinçli biçimde teste eklenmiştir.

Eski devir/proje notlarında Play App Signing SHA-1 olarak ayrıca şu değer bulunur:

`17:E1:EC:6C:77:4F:B4:59:63:FA:7A:76:51:7D:21:B2:BB:7C:81:1F`

Repo içinde `17:E1...` değeri doğrulanamadı. Bu nedenle `26:3C...` ile `17:E1...` arasındaki fark tahminle kapatılmayacak. Play Console'daki **Uygulama imzalama anahtarı sertifikası** ve **Yükleme anahtarı sertifikası** SHA-1 değerleri, ardından Firebase Android app fingerprint listesi canlı ekranla karşılaştırılacaktır.

---

## 7. Soru bankası ve geri bildirim

- Aktif soru bankası: **8.710 soru**.
- Eski 6.710 soruya 2.000 Türkiye odaklı kolay soru eklenmişti.
- Son kontrol kesiminde **41 bekleyen olay / 40 benzersiz soru** kaydı bulunuyordu.
- İlk ayıklamada:
  - 14 benzersiz soru açıkça bozuk,
  - 8 soru zorluk incelemesi adayı,
  - 4 eski kayıt ayrıntılı inceleme bekliyor,
  - 13 soru henüz tek tek değerlendirilmemiş,
  - 1 kayıt için değişiklik gerekmiyor.

Her soru düzeltmesinde soru metni, dört seçenek, doğru indeks, açıklama, kategori ve zorluk birlikte kontrol edilir. Sheet satırı gerçek soru düzeltmesi merge edilmeden kapatılmaz. `assets/questions.json` kontrolsüz değiştirilmez.

---

## 8. Reklam ve Analytics

### Reklam - kesin ürün sözleşmesi

- aktif soru ve kritik oyun akışında reklam yok
- banner yalnız uygun menü/sonuç ekranlarında
- ödüllü reklam isteğe bağlı
- ödül `+10 XP`
- günlük/oturumluk toplam kota yok
- her tamamlanan oyun bir ödüllü reklam hakkı üretir
- aynı tamamlanmış oyun ikinci ödülü vermez

PR #16 ile yerel oyun-başına hak sistemi release'e taşındı. Ancak `1.68.14+104` kapalı-test AAB'si `FIREBASE_ENVIRONMENT=production` + `ADMOB_ENVIRONMENT=closed_test` ile üretildiği halde eski `SupportRewardCard` production Firebase açıkken +10 XP kartını kapatıyordu. Bu nedenle BR-P0-004 fiziksel kapalı-test ödül kabulü mevcut RC2 #326 build'inde yapılamıyordu.

### PR #25 - closed-test ödüllü reklam kabul kapısı

Branch: `fix/closed-test-rewarded-acceptance`.

Son işlevsel kod head'i: `2cc47846b42cf98b4f8303bb86148cc475060824`.

Çözüm:

- Production Firebase + `closed_test` AdMob profilinde Google demo rewarded reklamı ve yerel oyun-başına +10 XP kabul akışı açık olur.
- Gerçek `ADMOB_ENVIRONMENT=production` profilinde, Firebase profili yanlışlıkla dev/test olsa bile +10 XP destek ödülü fail-closed kalır.
- Oyun-başına tek hak, aynı oyun ikinci ödül yok ve başarısız reklam sonrası hakkın korunması değişmez.

Güncel kod-head CI #128:

- Run: `31635781505`
- Job: `94245596601`
- Sonuç: **SUCCESS**
- Analyzer + tüm Flutter testleri: PASS
- İmzalı test-reklam kimlikli release APK: PASS
- Paket/birleşik manifest: PASS
- KVM hazırlığı: PASS
- Android 16 deneme 1: PASS
- Deneme 2: SKIPPED; gerekmedi
- Final AdMob Android 16 app gate: PASS
- Artifact: `BilgiRotasi-AdMob-1.68.14-104-kanitlari`
- Artifact ID: `9157235566`
- Digest: `sha256:e7ab0d5b683454f79c4f1a9555fe027906fa5333ec1b016609452f68b384e5c9`
- Artifact `ADMOB_ANDROID16_APP_GATE.txt`: `APK_INSTALL`, `APP_LAUNCH`, `APP_PID`, `APP_ACTIVITY`, `APP_LOGCAT`, `APP_GATE` = PASS
- Artifact `ADMOB_ANDROID16_VALIDATION_RESULT.txt`: `RESULT=PASS`, `RELEASE_GATE=PASS`, `APP_GATE=PASS`
- PID: `1871`; MainActivity `RESUMED/visible`
- Bilgi Rotası crash/ANR/FATAL/process-death eşleşmesi yok

Bu AdMob PR CI, geniş Guest → Home → Oyna RC2'nin yerine geçmez. PR #25 merge edilirse fresh geniş RC2 zorunludur.

### Production SSV - ayrı açık konu

`functions/rewarded_ssv.js` ve `docs/rewarded-ssv-setup.md` production SSV'nin **henüz deploy edilmediğini** açıkça belirtir. Mevcut aday SSV sözleşmesi günlük 3 işlem / toplam +30 XP limiti taşır; bu, güncel `KARARLAR.md` içindeki “günlük/oturumluk toplam kota yok” kararıyla çelişir. Bu nedenle blanket `firebase deploy --only functions` yapılmayacak; production SSV sözleşmesi ayrı branch/görevde ürün kararına uyarlanıp test edilmeden deploy edilmeyecektir.

### Analytics

- Analytics varsayılan kapalıdır.
- Kullanıcı açıkça izin vermeden `analytics_storage` etkinleşmez.
- Telemetri tam anonim değildir; izin sonrası Firebase SDK pseudonymous app-instance ID üretebilir.
- Ad/e-posta/Google-Firebase kullanıcı kimliği/açık kullanıcı adı/reklam kimliği uygulama olay parametresi değildir.
- Reklam amaçlı consent değerleri reddedilir.
- UMP ve Analytics consent birbirinden ayrıdır.

---

## 9. Ayrı açık ürün hatası - günlük giriş XP

`KARARLAR.md` içinde **“Günlük giriş ödülü yok.”** kararı bulunmasına rağmen `lib/retention_system.dart::RetentionProgressService.initialize()` canlı release üzerinde gerçek XP ödülü üretmektedir.

Kesin source kanıtı:

- ödül dizisi: `20, 30, 40, 50, 60, 80, 120`
- yeni gün/streak hesaplandığında `lastLoginReward` yazılır
- ardından `XpProgressService._award(reward, 'Günlük giriş serisi • N. gün')` çağrılır

RC2 #325'te görülen `+20 XP • Günlük giriş serisi • 1. gün` bu kodla uyumludur. Bu, RC2 #325 Kariyer yönlendirmesinin kök nedeni değildir; ayrı ürün/karar tutarsızlığıdır.

**Durum:** `AÇIK / KÖK KAYNAK DOĞRULANDI`. Ayrı branch'te kaldırılacak ve retention/XP regression testleri eklenecek; PR #25'e karıştırılmayacak.

---

## 10. `RELEASE_READINESS.md` bayat rapor içeriği

RC2 #326 artifact'ındaki gerçek paket ve kalite raporları doğru biçimde `1.68.14+104` ve **8.710 soru** gösterir.

Buna rağmen artifact içindeki `reports/RELEASE_READINESS.md` dosyasının bazı bölümleri hâlâ eski `1.68.8+98`, eski kaynak commit/AAB adı ve `6.710 / 6710 soru` gibi tarihsel metinler taşır.

Bu durum AAB'nin veya RC2 #326 gate sonucunun yanlış olduğu anlamına gelmez; raporu üreten şablon/kaynak metin bayattır.

**Durum:** `AÇIK`. Ayrı branch/PR ile dinamikleştirilecek; sırf bu metin için RC2 #326 yeniden çalıştırılmayacak.

---

## 11. Oyun ve hesap sistemleri

Canlı release üzerinde yeni teknik çalışmadan önce tek tek source/test ile yeniden doğrulanmak kaydıyla mevcut ana sistemler:

- 2-6 kişilik yerel tahta oyunu
- Serbest Rota
- Soru Maratonu
- Günlük Görev
- Hayatta Kalma
- 60 Saniye
- Takım modu ve diğer hızlı oyun modları
- 10 / 20 / 30 soruluk Meydan Okuma
- Canlı Düello
- BR ve lig
- Google giriş / misafir ayrımı
- bulut kayıt
- hesap silme
- XP, seviye, başarımlar
- Bilgi Rotası Pasaportu
- piyon koleksiyonu ve favori piyon seçimi
- temalar, jokerler, özel kutular
- erişilebilirlik ve Sistem Sağlığı

Canlı Düello için iki güncel Play kapalı test cihazıyla uçtan uca fiziksel kabul hâlâ gereklidir.

---

## 12. 3B oyun tahtası

- Oynanış, BoardMap ve 67 node sözleşmesi değişmeyecek.
- 30 dış kategori + 30 iç kategori + 6 rozet + 1 merkez korunacak.
- Tek Matrix4 ile bütün 2B sahneyi eğme yaklaşımı kullanılmayacak.
- Önce numaralı deterministik geometri.
- Kullanıcı görsel onayı olmadan stil/Flutter/APK aşamasına geçilmeyecek.
- 8 kategori rozeti konsepti ile 6 fiziksel rozet noktası eşleştirilmeden ilerlenmeyecek.
- `tools/board_renderer/` kullanıcı alanına kontrolsüz dokunulmayacak.

**Durum:** `DURDURULDU / karar bekliyor`; release hattına etkisi yok.

---

## 13. Mağaza ve tanıtım

Hazırlanan varlıklar arasında telefon, tablet planı, PC ve Android XR görselleri ile Instagram setleri bulunur. Onaylı final tanıtım videosu yoktur.

Canlı Play Console'da telefon/tablet/Chromebook/PC/XR varlıklarının `hazır / yüklendi / reddedildi / yeniden yapılacak` durumu yeniden okunmalıdır.

---

## 14. Şu anda ilk yapılacak işler

1. PR #25 proje-memory commit'i sonrası oluşan **final PR head** CI'ını PASS olarak doğrula; yalnız bundan sonra Levent'ten merge onayı iste.
2. PR #25 merge edilirse release head/sürümü yeniden doğrula ve eski #326'yı rerun etmeden fresh geniş RC2 çalıştır.
3. Play Console'dan uygulama imzalama ve upload SHA-1 ekran kanıtını al; `26:3C...` / `17:E1...` çelişkisini çöz.
4. Firebase Console'da Google Auth, Android SHA'lar, Functions, Rules, Indexes ve App Check envanterini canlı doğrula; kör deploy yapma.
5. Play Console'da güncel kapalı test AAB sürümünü, testçi sayısını ve kesintisiz gün sayacını tarihli kanıtla yeniden oku.
6. Fresh RC2 ve servis kontrolleri temizse güncel AAB'nin Kapalı Test yükleme durumunu netleştir.
7. Güncel Play kurulumu üzerinden Google giriş, oturum korunması, Misafir → Google geçişi, hesap izolasyonu, Ayarlar/öğretici ve Google demo ödüllü reklam kabulünü fiziksel cihazda doğrula.
8. İki ayrı cihaz/hesapla Canlı Düello eşleşme → maç → sonuç → leaderboard zincirini doğrula.
9. Günlük giriş XP karar çelişkisini ayrı branch/görev olarak çöz.
10. Production SSV günlük 3/+30 XP sözleşmesini ürün kararıyla uyumlu hale getirmeden deploy etme.
11. `RELEASE_READINESS.md` bayat şablonunu ayrı teknik görev olarak düzelt.
12. Soru geri bildirim düzeltmelerini ayrı branch/PR düzeninde sürdür.
13. 3B tahta işine 6-rozet eşlemesi ve geometri onayı olmadan dönme.
