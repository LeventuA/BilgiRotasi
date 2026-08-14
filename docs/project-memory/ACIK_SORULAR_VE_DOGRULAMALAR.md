# Bilgi Rotası - Açık Sorular ve Canlı Doğrulamalar

**Kesim noktası:** 14 Ağustos 2026

## PR #38 launcher icon fiziksel kabulü - AÇIK

- Onaylanan 512x512 kaynak, repo varlıkları, APK içindeki legacy/adaptive ikonlar ve Android 16 uygulama kapısı otomatik olarak doğrulandı.
- CI #161 / run `31757717142`, job `94637088436`: SUCCESS; `APP_GATE=PASS`, `RELEASE_GATE=PASS`.
- Mevcut fiziksel cihazda Google Play'den kurulu Bilgi Rotası silinmeyecek ve CI imzalı APK bu kurulumun üzerine zorlanmayacak.
- **DOĞRULANACAK:** uyumlu imzalı bir fiziksel build/Play sürümüyle gerçek launcher gridinde dairesel ve yuvarlatılmış-kare maske görünümü. APK indirme/önizleme ekranı bu gerçek kurulum kabulünün yerine geçmez.

---

## BR-P1-008 final artifact kabulü - KAPALI

Aşağıdaki tarihsel ‘artifact kabulü açık / yeni run gerekli’ kayıtları artık kapanmıştır.

- PR #32 merge commit: `794205f3ad68c0547f2858d530170af3a7a6bd41`.
- Final `Closed test release doğrulaması` run `31680750887`, job `94385413742`: **SUCCESS** ve doğru release SHA'yı test etti.
- Artifact `BilgiRotasi-1.68.14-104-closed-test-release`: ID `9173824623`, digest `sha256:9c6f081211cff19a3d8857c6b6bb15dc312da17819fe67988f994a333c078d73`.
- AAB SHA-256: `6904249d00e12e3e671c9a282364dc4791948e9ec45cafecfaae15f8f734d285`; `reports/AAB_SHA256.txt` ile gerçek AAB dosya hash'i eşleşir.
- `reports/RELEASE_READINESS.md`: `1.68.14+104`, 8.710 soru, soru SHA-256 `e71c4ff991873499b986952835b9bb8e0995d2791c47ce4085d7ab9a502299d4`, source ref `release/final-closed-test-aab-1.68.8`, source SHA `794205f3ad68c0547f2858d530170af3a7a6bd41`, doğru AAB adı ve run `31680750887` URL'si doğrulandı.
- Eski `1.68.8+98`, `6710` ve eski source değerleri yok; trailing whitespace yok.
- Android 16 ilk AAB-derived deneme PASS; ikinci deneme gerekmedi. `GUEST_LOGIN`, `HOME_OYNA`, `APP_GATE`, `RELEASE_GATE`, `SETTINGS_TUTORIAL_DIAGNOSTIC` PASS; app-specific crash/ANR/FATAL/process-death kanıtı yok.
- **BR-P1-008 artık açık konu değildir.**
- Play Console güncel sürüm/sayaç, fiziksel Google/rewarded/Canlı Düello kabulü ve Firebase/Play canlı servis kontrolleri ayrı açık doğrulamalar olarak devam eder.
- `KARARLAR.md` değişmedi.

---

## PR #29/#30 release-readiness düzeltmesi - GÜNCEL DURUM

Bu bölüm aşağıdaki tarihsel BR-P1-008 / release HEAD kayıtlarının güncel durumunu geçersiz kılar.

- Güncel release branch: `release/final-closed-test-aab-1.68.8`.
- PR #30 kod tabanı / merge commit: `d1d5a9ea128d3d36fe26fafe95c97bf473c02548`.
- PR #31 proje-hafızası merge commit: `dcab00bee295c75a817fd4dda0a63be10c5a6d56`.
- Canlı release HEAD statik olarak bu dosyada dondurulmaz; her teknik görev başında GitHub'dan yeniden okunur.
- Sürüm: `1.68.14+104`.
- PR #29 dinamik `RELEASE_READINESS.md` üretimini release'e taşıdı; merge commit `9aef2bd9ceeeba3a47e85e5a508512967d7db29d`.
- Bu merge sonrasındaki manuel final closed-test run `31654600408`, `git diff --check` tarafından trailing whitespace nedeniyle AAB aşamasından önce durduruldu. Bu uygulama hatası değildir ve release artifact kabulü sayılamaz.
- PR #30 yalnız rapor üreticisindeki satır-sonu boşluklarını kaldırdı ve regresyon testi ekledi. Kod head `1c809e9f4d02c425705e4812b0daadf87418b9fd`; CI #139 run `31655047190`, job `94307567727`: **SUCCESS**.
- PR #30 merge commit: `d1d5a9ea128d3d36fe26fafe95c97bf473c02548`.
- PR #31 sonrası `dcab00bee295c75a817fd4dda0a63be10c5a6d56` üzerinde Quality Checks #298 / run `31657810165` **SUCCESS**; AdMob PR doğrulaması #142 / run `31657810270` / job `94316006975` **SUCCESS**. #142 artifact ID `9165265578`, digest `sha256:da4a2082ca2139529fe4bee0358b560a966391d41e1548c8b20943184edbf2c3`, APK SHA256 `3bdb9ab250c97f42ab958ff1e037c0ad5eaee9458090d97b850710bf4c928813`; Android 16 app/release gate PASS ve app-specific crash/ANR/FATAL/process-death eşleşmesi yok. Bu APK kanıtı final AAB kabulü değildir.
- **BR-P1-008 uygulama/CI/merge tamamlandı; artifact kabulü henüz açık.** Güncel release HEAD üzerinde yeni `Closed test release doğrulaması` manuel run'ı çalıştırılmalı ve `reports/RELEASE_READINESS.md` içindeki sürüm/source/AAB/soru sayısı ile whitespace kontrolü artifact üzerinden doğrulanmalıdır.
- Fresh RC2'nin eski proje-hafızası satırlarındaki `690424c...` AAB SHA256 değeri transkripsiyon hatasıdır. Doğrudan indirilen artifact `reports/AAB_SHA256.txt` ve gerçek AAB hash'i: `6904249d00e12e3e671c9a282364dc4791948e9ec45cafecfaae15f8f734d285`.
- `KARARLAR.md` değişmedi.

Açık sonraki adım:

1. Bu proje-hafızası temizliği merge edildikten sonra GitHub'dan yeniden okunan **canlı release HEAD** üzerinde `Closed test release doğrulaması` → `confirmation=CLOSED_TEST` ile **yeni** run başlat.
2. Tam job logu + artifact birlikte incelensin.
3. `reports/RELEASE_READINESS.md`: `1.68.14+104`, 8.710 soru, doğru source SHA/ref, doğru AAB adı ve trailing whitespace yok.
4. Android 16 mandatory gate'ler PASS ve Bilgi Rotası crash/ANR/FATAL/process-death kanıtı yoksa yeni AAB Play Kapalı Test yükleme adayıdır.

---

## Fresh RC2 release doğrulaması - TAMAMLANDI

Bu bölüm aşağıdaki tarihsel “Fresh RC2 release doğrulaması - AÇIK” kaydının güncel sonucudur ve o gereksinimi kapatır.

- Branch: `release/final-closed-test-aab-1.68.8`.
- Test edilen release HEAD: `d450c573a122231734437fb097cf17a00e583801`.
- Son işlevsel release: `7a50a1997c6eade985a3933fd019055dd6a2c791`; `7a50a199... → d450c573...` farkı docs/proje-hafızasıdır.
- Sürüm: `1.68.14+104`.
- Workflow run `31645526580`, job `94278055890`: **SUCCESS**.
- Artifact `BilgiRotasi-1.68.14-104-closed-test-release`, ID `9160985710`, digest `sha256:0a086fab7c0730321c8768aefb94b7887f365d3cc80bf8fe087da83c7a425815`.
- AAB SHA256 `690424c771867ce4835019449e8f4cc75e36aeca5779838fa7996a96faaa04e1`.
- AAB-derived Android 16 Misafir → Home → Oyna mandatory akışı PASS; `APP_GATE=PASS`, `RELEASE_GATE=PASS`; ilk deneme SUCCESS, ikinci deneme gerekmedi.
- Analyze/test, 8.710 soru kalite kapıları, Functions, Firestore Rules emulator, closed-test AdMob ve production Firebase release profile kontrolleri PASS.
- Bilgi Rotası paketine ait crash/ANR/FATAL/process-death kanıtı bulunmadı.

Fresh RC2 ile kapanmayan canlı doğrulamalar:

1. Play Console güncel kapalı-test AAB sürümü, geçerli testçi ve kesintisiz gün sayacı.
2. Play App Signing / Upload SHA rolleri ve Firebase Android fingerprint eşleşmesi.
3. Firebase canlı Google Auth, Functions, Rules, Indexes ve App Check durumları.
4. Güncel Play kurulumunda Google giriş/oturum, Misafir→Google izolasyonu, öğretici, Google demo rewarded ve Canlı Düello fiziksel kabulü.
5. **BR-P1-008:** fresh artifact `RELEASE_READINESS.md` eski `1.68.8+98`, eski source/AAB ve 6.710 soru metnini taşımaya devam ediyor; ayrı teknik borç olarak açık.
6. BR-P1-007 günlük giriş XP karar çelişkisi ve BR-P1-009 production SSV kota çelişkisi ayrı görevlerde açık.

## Canlı durum

- Kanonik repo: `ZMilaStudio/BilgiRotasi`.
- Release dalı: `release/final-closed-test-aab-1.68.8`.
- Release HEAD / son işlevsel release commit'i: `7a50a1997c6eade985a3933fd019055dd6a2c791` (PR #25).
- Release sürümü: `1.68.14+104`.
- `main` HEAD: `ab9b4f3797a02b92f98f92e439b7edc4c608fec3` (PR #26; yalnız workflow görünürlüğü). `main` yayın kaynağı değildir.
- PR #7 açık/Draft ve release→`main`; merge edilmeyecek.
- PR #12 açık; 3B deterministik geometri çalışmasıdır.
- PR #13 açık/Draft; kaynak ödüllü reklam PR'ıdır.
- PR #15 açık/Draft; telemetri değişiklikleri PR #16 üzerinden release'e ulaştı.
- PR #21, #23, #24 ve #25 merge edildi.
- PR #25 final head `f8939b6f6aa950bda48bedf8b87dc0a51c761916`; CI #129 run `31637213948`, job `94250454471`: **SUCCESS**.
- PR #25 final artifact `9157834250`: `BilgiRotasi-AdMob-1.68.14-104-kanitlari`; digest `sha256:3b2c0347b3d194f84618f8c02863dcd5ad21c76cc7ce7b72b906f0314c8f8c25`.
- PR #25 merge commit / güncel release HEAD: `7a50a1997c6eade985a3933fd019055dd6a2c791`.
- PR #26 main'e merge edildi: `ab9b4f3797a02b92f98f92e439b7edc4c608fec3`.
- `Closed test release çekirdeği` workflow ID `333114585`: **ACTIVE**.
- `Closed test release doğrulaması` workflow ID `333114587`: **ACTIVE**.
- RC2 #326 run `31614662061`, job `94174350962`: **SUCCESS** üzerinde source SHA `ec20e66e1d52126ce99fa09e29f606ae14a5f7a2`.
- RC2 #326 artifact `9149285776`: `BilgiRotasi-1.68.14-104-closed-test-release`; digest `sha256:c69b44f40152ecc256ea5ace57c997bf3c8dafb8c051cdfaf69df288837fd56e`.
- #326 `APK_INSTALL`, `APP_LAUNCH`, `ANALYTICS_CONSENT_HANDLED`, `GUEST_LOGIN`, `HOME_OYNA`, `APP_PID`, `APP_LOGCAT`, `APP_GATE`, `POST_GATE_LOGCAT_BOUNDARY`, `RELEASE_GATE`, `SETTINGS_TUTORIAL_DIAGNOSTIC` = PASS.
- **Ancak #326 güncel `7a50a199...` release SHA'sını doğrulamaz. Fresh geniş RC2 zorunludur.**
- Android geliştirici doğrulaması tamamlandı.
- Son doğrulanan Play kapalı test değeri: **12 geçerli testçi / 4 kesintisiz gün**. Güncel sayaç UI'dan yeniden okunacak.

## Fresh RC2 release doğrulaması - AÇIK

Android 16 mandatory release gate `ec20e66...` üzerinde RC2 #326 ile tarihsel olarak tamamlandı. PR #25 işlevsel uygulama kodu release'e merge edildiği için güncel release `7a50a199...` için yeni kabul gerekir.

**Yapılacak:**

1. GitHub Actions → `Closed test release doğrulaması`.
2. Branch: `release/final-closed-test-aab-1.68.8`.
3. `confirmation`: `CLOSED_TEST`.
4. Yeni bir fresh run başlat; eski #326'yı rerun etme.
5. Tam workflow/job/log/artifact birlikte incelenecek.
6. Guest → Home → Oyna dahil mandatory gate'lerin tamamı PASS olmalı.
7. Bilgi Rotası crash/ANR/FATAL/process-death kanıtı olmamalı.
8. Fresh RC2 PASS olmadan yeni AAB Play'e yüklenmemeli.

## GitHub Actions manuel workflow görünürlüğü - ÇÖZÜLDÜ

Kök neden:

- `.github/workflows/closed-test-release.yml` ve `.github/workflows/closed-test-release-core.yml` release dalında vardı ama default branch `main` üzerinde yoktu.
- Bu nedenle manuel `workflow_dispatch` UI listesinde `Closed test release doğrulaması` görünmüyordu.

Düzeltme ve kanıt:

- Branch: `ci/expose-closed-test-release-workflow`.
- Commit: `3dc820502ba131258824b27776f292a67e85d54e`.
- Commit adı: `ci: expose closed-test release workflow on main`.
- PR #26 Levent'in açık `Düzelt ve merge et` onayıyla main'e merge edildi.
- Merge commit: `ab9b4f3797a02b92f98f92e439b7edc4c608fec3`.
- Değişiklik yalnız iki workflow dosyasıdır.
- Wrapper blob SHA: `f8fe355ad547c7fc4a5ec48c2809d65796b402df`.
- Core blob SHA: `3afa8793d3f437c63d690c86f3b6dbaaca2ce83a`.
- Bu bloblar release ve RC2 #326 source commit'indeki kanıtlanmış bloblarla birebir aynıdır.
- Quality Checks #292: run `31642575342`, job `94268451360`, **SUCCESS**.
- GitHub Actions API her iki workflow'u da ACTIVE kaydetmiştir.
- Release branch, release sürümü ve PR #7 değişmedi.

Ayrı teknik borç: eski `.github/workflows/apply-game-save-isolation-v4.yml` branch push'unda run `31642536946` config-level kırmızı üretti ancak **0 job** çalıştırdı. Bu PR #26 uygulama/test hatası değildir; ayrı görevde incelenecek.

## PR #25 - closed-test ödüllü reklam kabulü

Kök neden:

- Closed-test AAB `FIREBASE_ENVIRONMENT=production` + `ADMOB_ENVIRONMENT=closed_test` ile üretilir.
- Eski sonuç destek kartı `FirebaseRuntimePolicy.productionEnabled` true olduğunda +10 XP ödülünü tamamen kapatıyordu.
- Bu nedenle RC2 #326 build'i Google demo reklam profili taşısa da BR-P0-004 fiziksel rewarded kabul yapılamıyordu.

PR #25 çözümü:

- production Firebase + closed-test AdMob => Google demo rewarded + yerel oyun-başına +10 XP izinli
- production Firebase + production AdMob => kapalı
- dev/test Firebase + production AdMob => kapalı
- dev/test Firebase + test AdMob => test/dev davranışı izinli
- oyun-başına tek hak, aynı oyun ikinci ödül yok ve başarısız reklam sonrası hak korunması değişmez

Kanıt:

- Kod-head CI #128: run `31635781505`, job `94245596601`, SUCCESS.
- Final head CI #129: run `31637213948`, job `94250454471`, SUCCESS.
- Final artifact ID `9157834250`.
- PR #25 release'e merge edildi: `7a50a199...`.

Açık:

1. Fresh geniş RC2 `7a50a199...` üzerinde PASS olmalı.
2. Ardından güncel Play kurulumu üzerinde Google demo rewarded fiziksel kabulü yapılmalı.
3. Reklam tamamlanırsa +10 XP verilmeli; aynı gameId ikinci ödülü vermemeli.
4. Reklam başarısız/yarım kalırsa XP verilmemeli ve hak doğru biçimde yeniden denenebilir kalmalı.

## Play kapalı test kabulü - açık doğrulamalar

1. Play Console'da güncel aktif kapalı test AAB sürümünü tarihli ekranla doğrula.
2. Geçerli testçi sayısını ve kesintisiz gün sayacını yeniden oku; eski 12/4 değerini ileri tarih için tahmin etme.
3. `1.68.14+104` AAB'nin Play kapalı test kanalına yüklenip yüklenmediğini canlı Console'dan doğrula.
4. Eğer versionCode 104 daha önce yüklenmişse aynı kodla yeni AAB yüklenemeyeceğini hesaba kat; sürüm bump'ı ayrı kontrollü branch/PR olur.
5. Google hesabıyla girişin gerçek Play kurulumu üzerinde çalıştığını doğrula.
6. Uygulamayı yeniden açınca Google oturumunun korunduğunu doğrula.
7. Misafir → Google geçişinde kayıtların doğru hesaba bağlandığını ve başka hesaba veri sızmadığını doğrula.
8. Eğitimin beklenen davranışını ve Ayarlar'dan açılıp `Anladım` ile kapanmasını fiziksel cihazda doğrula.
9. Kapalı test sürümünde yalnız Google demo reklam kreatiflerinin göründüğünü doğrula.
10. Ödüllü reklamın tamamlanan oyun başına tek hak, `+10 XP`, ikinci ödül engeli ve başarısız reklam sonrası yeniden deneme sözleşmesini fiziksel cihazda doğrula.

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
- Eski devir kaydında Play App Signing SHA-1 `17:E1:EC:6C:77:4F:B4:59:63:FA:7A:76:51:7D:21:B2:BB:7C:81:1F` olarak geçer.
- Repo içinde `17:E1...` doğrulanamadı.

Doğrulanacak:

1. Play Console uygulama imzalama ekranında **Uygulama imzalama anahtarı sertifikası SHA-1**.
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

Açık görev:

1. Ayrı branch aç.
2. Günlük giriş XP ödülünü ürün kararına uygun biçimde kaldır.
3. Retention/XP regression testleri ekle/güncelle.
4. CI + ayrı PR inceleme/merge akışını tamamla.
5. RC2/rewarded workflow değişiklikleriyle karıştırma.

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
