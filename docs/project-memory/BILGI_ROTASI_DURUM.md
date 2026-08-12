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
| Release HEAD | `ec20e66e1d52126ce99fa09e29f606ae14a5f7a2` | DOĞRULANDI | GitHub canlı branch |
| Gerçek paket sürümü | `1.68.14+104` | DOĞRULANDI | Release `pubspec.yaml` |
| `main` dalı | Güncel yayın kaynağı değil | KESİN KARAR | `KARARLAR.md` |
| PR #7 | Açık / Draft / base `main` | DOĞRULANDI | GitHub canlı PR |
| PR #12 | Açık; 3B deterministik geometri | DOĞRULANDI | GitHub canlı PR |
| PR #13 | Açık / Draft; ödüllü reklam fiziksel kabulü bekliyor | DOĞRULANDI | GitHub canlı PR |
| PR #15 | Açık / Draft; telemetri işi PR #16 üzerinden release'e ulaştı | DOĞRULANDI | GitHub canlı PR |
| PR #21 | Merge edildi; merge commit `2ce47112fce1a0c462ae9f95e8187a6e1d148581` | DOĞRULANDI | GitHub canlı PR |
| PR #23 | Merge edildi; merge commit `ec20e66e1d52126ce99fa09e29f606ae14a5f7a2` | DOĞRULANDI | GitHub canlı PR |
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
- Play App Signing SHA production Firebase'e daha önce eklenmişti; canlı Console envanteri yeniden doğrulanmalıdır.
- `1.68.14+104` için RC2 teknik engeli artık kalkmıştır.
- Ancak `1.68.14+104` AAB'nin Play kapalı test kanalına gerçekten yüklenip yüklenmediği bu kesim noktasında **DOĞRULANACAK** durumundadır; otomatik varsayım yapılmaz.

**Durum:** Kapalı test hattı aktif; yeni AAB yükleme kararı öncesi canlı Firebase/Play kabul kontrolleri açık.

---

## 5. Firebase / App Check / Play Integrity

Production Firebase projesi: `bilgi-rotasi-f255d`.

Bilinen/doğrulanmış geçmiş:

- Android package: `com.leventua.bilgirotasi`.
- App Check provider: Play Integrity.
- Daha önce yanlış Dizily Google Cloud bağlantısı kaldırılıp doğru Bilgi Rotası projesi bağlandı.
- Bir aşamada Firestore App Check ekranında `66/66` ve `%100 doğrulanmış istek` görüldü.

RC2 #326 workflow'u production Firebase/OAuth build yapılandırmasını ve AAB metadata profilini PASS etti. Bu sonuç **canlı production backend deploy envanterinin yerine geçmez**.

Canlı servisten yeniden doğrulanacaklar:

- Google Auth provider
- Android SHA kayıtları ve hangi sertifikanın hangi amaçla kullanıldığı
- Functions deploy sürümü
- Firestore indexes ve hazır olma durumu
- Firestore rules deploy sürümü
- App Check / Play Integrity enforcement durumu

**Kural:** Kör Firebase deploy yapılmaz.

---

## 6. İmza ayrımı

Play tarafında daha önce konuşulan Play App Signing SHA-1:

`17:E1:EC:6C:77:4F:B4:59:63:FA:7A:76:51:7D:21:B2:BB:7C:81:1F`

RC2 #326 AAB/upload signing zincirinde görülen SHA-1:

`00:0E:E4:3F:41:0A:BC:6B:4F:63:4C:4F:71:6D:76:EB:19:08:41:15`

Bu iki sertifika aynı şey olarak yorumlanmayacak. Play Console/Firebase tarafında kullanım rolleri canlı kaynaktan doğrulanacak.

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

Her soru düzeltmesinde birlikte kontrol edilecek:

- soru metni
- dört seçenek
- doğru indeks
- açıklama
- kategori
- zorluk

Sheet satırı gerçek soru düzeltmesi merge edilmeden kapatılmaz. `assets/questions.json` kontrolsüz değiştirilmez.

---

## 8. Reklam ve Analytics

### Reklam

Kesin ürün sözleşmesi:

- aktif soru ve kritik oyun akışında reklam yok
- banner yalnız uygun menü/sonuç ekranlarında
- ödüllü reklam isteğe bağlı
- ödül `+10 XP`
- günlük/oturumluk toplam kota yok
- her tamamlanan oyun bir ödüllü reklam hakkı üretir
- aynı tamamlanmış oyun ikinci ödülü vermez

İşlevsel ödüllü reklam değişikliği PR #16 entegrasyonu üzerinden release'e ulaştı. Kaynak PR #13 açık/Draft kalır; fiziksel cihaz kabulü henüz açıktır.

### Analytics

- Analytics varsayılan kapalıdır.
- Kullanıcı açıkça izin vermeden `analytics_storage` etkinleşmez.
- Telemetri tam anonim değildir; izin sonrası Firebase SDK pseudonymous app-instance ID üretebilir.
- Ad/e-posta/Google-Firebase kullanıcı kimliği/açık kullanıcı adı/reklam kimliği uygulama olay parametresi değildir.
- Reklam amaçlı consent değerleri reddedilir.
- UMP ve Analytics consent birbirinden ayrıdır.

---

## 9. Ayrı açık ürün hatası - günlük giriş XP

`KARARLAR.md` içinde **“Günlük giriş ödülü yok.”** kararı bulunmasına rağmen RC2 #325 ekran kanıtında:

`+20 XP • Günlük giriş serisi • 1. gün`

görüldü.

Bu, RC2 #325'in Kariyer ekranına gitmesinin kök nedeni değildir; ayrı ürün/karar tutarsızlığıdır.

**Durum:** `AÇIK`. Retention/XP kaynağı ayrı branch'te incelenecek; RC2 validator düzeltmesine karıştırılmayacak.

---

## 10. `RELEASE_READINESS.md` bayat rapor içeriği

RC2 #326 artifact'ındaki gerçek paket ve kalite raporları doğru biçimde `1.68.14+104` ve **8.710 soru** gösterir.

Buna rağmen artifact içindeki `reports/RELEASE_READINESS.md` dosyasının bazı bölümleri hâlâ eski:

- `1.68.8+98`
- eski `hotfix/release-login-tutorial-1.68.7` kaynak bilgisi
- eski AAB adı
- `6.710 / 6710 soru`
- eski tarihsel run açıklamaları

Bu durum AAB'nin veya RC2 #326 gate sonucunun yanlış olduğu anlamına gelmez; **raporu üreten şablon/kaynak metin bayattır**.

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

1. RC2 #326 sonucunu proje hafızasına işleyen docs-only PR'ı incele ve merge et.
2. Production Firebase canlı envanterini doğrula; kör deploy yapma.
3. Play Console'da güncel kapalı test AAB sürümünü, 12 testçi sayısını ve kesintisiz gün sayacını tarihli kanıtla yeniden oku.
4. Servis tarafında engel yoksa `1.68.14+104` AAB'nin Kapalı Test'e yükleme durumunu netleştir.
5. Güncel Play kurulumu üzerinden Google giriş, oturum korunması, Misafir → Google geçişi, hesap izolasyonu, Ayarlar/öğretici ve demo reklam kabulünü fiziksel cihazda doğrula.
6. İki ayrı cihaz/hesapla Canlı Düello eşleşme → maç → sonuç → leaderboard zincirini doğrula.
7. Günlük giriş XP karar çelişkisini ayrı görev olarak çöz.
8. `RELEASE_READINESS.md` bayat şablonunu ayrı teknik görev olarak düzelt.
9. Soru geri bildirim düzeltmelerini ayrı branch/PR düzeninde sürdür.
10. 3B tahta işine 6-rozet eşlemesi ve geometri onayı olmadan dönme.
