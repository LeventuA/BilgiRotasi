# Bilgi Rotası - Açık Sorular ve Canlı Doğrulamalar

**Kesim noktası:** 12 Ağustos 2026

## Canlı durum

- Kanonik repo: `ZMilaStudio/BilgiRotasi`.
- Release dalı: `release/final-closed-test-aab-1.68.8`.
- Release HEAD: `bb988e7e4d60a41c1711e70d2ec6125e7136b0d5` (docs-only PR #24).
- Son işlevsel release commit'i: `ec20e66e1d52126ce99fa09e29f606ae14a5f7a2`.
- Release sürümü: `1.68.14+104`.
- PR #7 açık/Draft ve `main` karşısında tutuluyor; merge edilmeyecek.
- PR #12 açık; 3B deterministik geometri çalışmasıdır.
- PR #13 açık/Draft; kaynak ödüllü reklam PR'ıdır.
- PR #15 açık/Draft; telemetri değişiklikleri PR #16 üzerinden release'e ulaştı.
- PR #21, #23 ve #24 merge edildi.
- PR #25 açık/Draft: `fix/closed-test-rewarded-acceptance`.
- PR #25 son işlevsel kod head'i: `2cc47846b42cf98b4f8303bb86148cc475060824`.
- PR #25 kod-head CI #128: run `31635781505`, job `94245596601`: **SUCCESS**.
- PR #25 artifact `9157235566`: `BilgiRotasi-AdMob-1.68.14-104-kanitlari`; digest `sha256:e7ab0d5b683454f79c4f1a9555fe027906fa5333ec1b016609452f68b384e5c9`.
- #128 Android 16 attempt 1 PASS; attempt 2 SKIPPED; `APP_GATE=PASS`, `RELEASE_GATE=PASS`; PID `1871`; MainActivity RESUMED/visible; app crash/ANR/FATAL/process-death yok.
- RC2 #326 run `31614662061`, job `94174350962`: **SUCCESS** üzerinde source SHA `ec20e66...`.
- RC2 #326 artifact `9149285776`: `BilgiRotasi-1.68.14-104-closed-test-release`; digest `sha256:c69b44f40152ecc256ea5ace57c997bf3c8dafb8c051cdfaf69df288837fd56e`.
- #326 `APK_INSTALL`, `APP_LAUNCH`, `ANALYTICS_CONSENT_HANDLED`, `GUEST_LOGIN`, `HOME_OYNA`, `APP_PID`, `APP_LOGCAT`, `APP_GATE`, `POST_GATE_LOGCAT_BOUNDARY`, `RELEASE_GATE`, `SETTINGS_TUTORIAL_DIAGNOSTIC` = PASS.
- Android geliştirici doğrulaması tamamlandı.
- Son doğrulanan Play kapalı test değeri: **12 geçerli testçi / 4 kesintisiz gün**. Güncel sayaç UI'dan yeniden okunacak.

## RC2 release doğrulaması

Android 16 mandatory release gate, son işlevsel release SHA `ec20e66...` üzerinde RC2 #326 ile tamamlandı. Eski #319/#321/#322/#323/#325 koşuları yalnız kök neden/regression tarihçesidir.

**Yeni sınır:** PR #25 işlevsel uygulama kodu içerir. PR #25 merge edilirse #326 yeni kodun release kanıtı değildir. Eski #326 rerun edilmeden yeni fresh geniş RC2 çalıştırılmalı ve Guest → Home → Oyna dahil tüm zorunlu gate'ler tekrar PASS olmalıdır.

## PR #25 - closed-test ödüllü reklam kabulü

Kök neden:

- Closed-test AAB `FIREBASE_ENVIRONMENT=production` + `ADMOB_ENVIRONMENT=closed_test` ile üretilir.
- Eski sonuç destek kartı `FirebaseRuntimePolicy.productionEnabled` true olduğunda +10 XP ödülünü tamamen kapatıyordu.
- Bu nedenle RC2 #326 build'i Google demo reklam profili taşısa da BR-P0-004 fiziksel rewarded kabulü yapılamıyordu.

PR #25 çözümü:

- production Firebase + closed-test AdMob => Google demo rewarded + yerel oyun-başına +10 XP izinli
- production Firebase + production AdMob => kapalı
- dev/test Firebase + production AdMob => kapalı
- dev/test Firebase + test AdMob => mevcut test/dev davranışı izinli
- oyun-başına tek hak, aynı oyun ikinci ödül yok ve başarısız reklam sonrası hak korunması değişmez

#128 kanıtı:

- analyzer ve tüm Flutter testleri PASS
- imzalı test-reklam kimlikli release APK PASS
- paket/birleşik manifest PASS
- KVM PASS
- Android 16 attempt 1 PASS; attempt 2 gerekmedi
- final AdMob app/release gate PASS
- artifact ID `9157235566`
- PID `1871`
- Bilgi Rotası crash/ANR/FATAL/process-death kanıtı yok

Açık:

1. Bu proje-memory commit'inden sonra oluşan **final PR #25 head CI** PASS olmalı.
2. Levent açıkça merge onayı vermeden PR #25 merge edilmemeli.
3. Merge sonrası release head/sürüm yeniden doğrulanmalı.
4. Fresh geniş RC2 çalıştırılmalı; #326 rerun edilmemeli.
5. Fresh RC2 PASS olmadan yeni AAB Play'e yüklenmemeli.
6. Ardından Google demo rewarded fiziksel cihaz kabulü yapılmalı.

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

## Firebase production envanteri - repo doğrulandı, canlı deploy açık

Repo/source doğrulaması:

- Production proje: `bilgi-rotasi-f255d`.
- Android package: `com.leventua.bilgirotasi`.
- `.firebaserc` yok; eventual deploy açıkça `--project bilgi-rotasi-f255d` kullanmalı.
- Functions runtime Node 20.
- İstemci Functions region `europe-west1`.
- App Check production provider Play Integrity; dev/test debug.
- 3 composite Firestore index beklenir:
  1. `live_duel_queue`: `questionCount ASC`, `status ASC`, `ratingBucket ASC`
  2. `live_duel_matches`: `status ASC`, `updatedAt ASC`
  3. `live_duel_matches`: `playerUids ARRAY_CONTAINS`, `resultProcessed ASC`
- RC2 #326 source/build doğrulamasında Cloud Functions testleri, Firestore Rules emulator ve production Firebase profile PASS.
- Artifact uzak production DB'yi okumadığını/değiştirmediğini belirtir; canlı deploy durumu bundan çıkarılamaz.

Canlı production proje üzerinden, kör deploy yapmadan:

1. Google Authentication provider durumunu doğrula.
2. Android app SHA fingerprint listesini doğrula.
3. Functions deployed names/revisions/region bilgisini doğrula.
4. Firestore indexes deploy/READY durumunu doğrula.
5. Firestore rules aktif revision/content durumunu doğrula.
6. App Check Play Integrity provider ve enforcement/metrik durumunu doğrula.
7. Enforcement açılacaksa önce gerçek kapalı-test trafiğinin meşru istekleri temiz geçtiğini metriklerle doğrula.

## İmza ayrımı - canlı ekranla çözülecek

Doğrulanan repo/build kayıtları:

- Upload/AAB SHA-1: `00:0E:E4:3F:41:0A:BC:6B:4F:63:4C:4F:71:6D:76:EB:19:08:41:15`.
- Güncel `test/firebase_play_signing_profile_test.dart` Play-signing/OAuth için `26:3C:46:C6:AE:9F:27:C3:B3:38:10:FA:89:8C:D7:EB:93:73:CC:F4` bekler.
- `26:3C...` değeri 1 Ağustos 2026 `972042915d1ef8294335e4372f8550cbdf6213bb` commit'iyle bilinçli biçimde teste eklenmiştir.
- Eski devir kaydında Play App Signing SHA-1 `17:E1:EC:6C:77:4F:B4:59:63:FA:7A:76:51:7D:21:B2:BB:7C:81:1F` olarak geçer.
- Repo içinde `17:E1...` doğrulanamadı.

Doğrulanacak:

1. Play Console → Play app signing ekranında **Uygulama imzalama anahtarı sertifikası SHA-1**.
2. Aynı ekranda **Yükleme anahtarı sertifikası SHA-1**.
3. Firebase Project Settings → Android app fingerprint listesi.
4. `00:0E...`, `26:3C...`, `17:E1...` değerlerinin gerçek rolleri.
5. Yanlış/eski repo testi veya doküman varsa ayrı PR ile düzeltme.

## Production rewarded SSV - deploy edilmemiş / sözleşme çelişkili

`docs/rewarded-ssv-setup.md` açıkça `rewardedSsvCallback` ve `issueRewardNonce` hazırlığının production'a deploy edilmediğini belirtir.

Mevcut aday sözleşme:

- nonce/custom_data
- Google ECDSA doğrulaması
- transaction_id idempotency
- **günlük 3 işlem / toplam +30 XP**
- `server_config/rewarded.ssvEnabled` kapalıyken 503 / bulut XP yok

Günlük 3/+30 XP limiti güncel `KARARLAR.md` içindeki “günlük/oturumluk toplam kota yok” kararıyla çelişir.

**Kural:** Bu sözleşme düzeltilmeden blanket `firebase deploy --only functions` yapılmaz ve `ssvEnabled` açılmaz.

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

`KARARLAR.md` içinde **“Günlük giriş ödülü yok.”** kararı bulunmasına rağmen canlı release source'unda gerçek XP yazımı doğrulandı.

`lib/retention_system.dart::RetentionProgressService.initialize()`:

- yeni gün için login streak'i ilerletir
- `const rewards = <int>[20, 30, 40, 50, 60, 80, 120]` kullanır
- `lastLoginReward` değerini yazar
- `XpProgressService._award(reward, 'Günlük giriş serisi • N. gün')` çağrısını yapar

RC2 #325 ekranındaki `+20 XP • Günlük giriş serisi • 1. gün` bu kaynakla uyumludur.

Açık görev:

1. Ayrı branch aç.
2. Günlük giriş XP ödülünü ürün kararına uygun biçimde kaldır.
3. Retention/XP regression testleri ekle/güncelle.
4. CI + ayrı PR inceleme/merge akışını tamamla.
5. PR #25 ve RC2 validator değişiklikleriyle karıştırma.

## Ayrı açık teknik borç - `RELEASE_READINESS.md`

RC2 #326 artifact'ındaki gerçek `RC1_QUALITY_GATE.md` doğru biçimde sürüm `1.68.14+104` ve toplam soru `8710` raporlar.

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
