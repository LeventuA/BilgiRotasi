# Bilgi Rotası - Güncel Proje Durumu

**Kesim noktası:** 14 Ağustos 2026
**Durum sınıfları:** `DOĞRULANDI`, `RAPORLANDI`, `AÇIK`, `DURDURULDU`

## 0D. Android launcher icon / PR #38 — 14 Ağustos 2026

- Canlı release tabanı `release/final-closed-test-aab-1.68.8`; başlangıç HEAD `29a5a23d15485922d670f7e7b3f9b7cea2d0260f`; sürüm `1.68.14+104`.
- PR #38 (`fix/text-launcher-icon-20260813`) release dalına merge edildi; merge
  commit'i `37f5ba0b1ea2cc5cfd97ff56beb6c31ba55d33b8`.
- Kullanıcının onayladığı `Bilgi_Rotasi_Android_Icon_512x512.png` kaynak görseli, yeniden tasarlanmadan `assets/branding/app_icon.png` olarak alındı. Kaynak ve repo dosyası SHA-256 değeri `32f9d4144fa5112afd93999fd4b6df3734493f626cc8e96f9b0be1510b9368fa` ile birebir eşleşir.
- `BİLGİ ROTASI` yazısı, pusula ve renkler korunur; splash varlığı ve yapılandırması değişmez. Legacy mdpi/hdpi/xhdpi/xxhdpi/xxxhdpi ile adaptive foreground kaynakları üretildi; adaptive foreground inset değeri `%18` olarak güvenli alana çekildi.
- Regresyon testi 512x512 PNG boyutunu, otoritatif kaynak hash'ini, yoğunluk boyutlarını, adaptive XML/inset sözleşmesini ve splash ayrımını kilitler.
- Yerel `flutter analyze --no-fatal-warnings --no-fatal-infos` PASS (önceden var olan 90 warning/info korunur); hedefli launcher testi PASS; taşınabilir Python 3.12.10 ile tüm Flutter testleri `257/257` PASS; `git diff --check` PASS.
- PR CI #161 / run `31757717142`, job `94637088436`: **SUCCESS**. Kalıcı imzalı test-ID release APK build, paket/manifest ve Android 16 cold-start kapıları PASS.
- Artifact `BilgiRotasi-AdMob-1.68.14-104-kanitlari`: ID `9203624785`, digest `sha256:88a709a875c02d28844bdbfd69c8669acc009ca5846d07e4bb51d9828a908b18`; APK SHA-256 `792a0db0d812acaaaa0e504d1abc61915f020e3bc9f3ec6592bbcc9a3f4ee673`.
- APK metadata: `com.leventua.bilgirotasi`, `1.68.14 (104)`, targetSdk 36; upload sertifikası SHA-1 `00:0E:E4:3F:41:0A:BC:6B:4F:63:4C:4F:71:6D:76:EB:19:08:41:15`.
- Android 16 `APK_INSTALL`, `APP_LAUNCH`, `APP_PID`, `APP_ACTIVITY`, `APP_LOGCAT`, `APP_GATE`, `RELEASE_GATE` = PASS; PID `1991`, `MainActivity` RESUMED/visible; uygulamaya ait crash/ANR/FATAL/process-death kanıtı yok.
- Artifact APK içindeki gerçek 192 px legacy ve 432 px adaptive launcher görselleri doğrudan açılarak onaylanan BİLGİ ROTASI yazılı pusula olduğu doğrulandı.
- Mevcut fiziksel telefondaki Google Play kurulumunu silmeden/üzerine farklı imzalı APK zorlamadan gerçek launcher ekranı kurulumu yapılamadı; bu kabul `DOĞRULANACAK` kalır.

---

## 0E. Issue #37 Firebase genel duyuru altyapısı — 14 Ağustos 2026

- Canlı yayın tabanı `release/final-closed-test-aab-1.68.8`; işe başlama HEAD'i
  `29a5a23d15485922d670f7e7b3f9b7cea2d0260f`, sürüm `1.68.14+104`.
- Ayrı dal: `feat/push-notifications-issue-37`; açık Draft PR #39. Güncel PR
  head'i statik yazılmaz, canlı GitHub PR metadata'sından doğrulanır.
- `firebase_messaging 16.4.3`, Android 13+ `POST_NOTIFICATIONS`, Android
  notification channel ve background entry-point eklendi.
- İlk açılışta izin istenmez. Kullanıcı yalnız Ayarlar'daki anahtarı açarsa
  sistem izni istenir; red/kapatma SDK auto-init, topic ve kurulum tokenını
  kapatır. Hatalar oyun akışına taşınmaz.
- Topic'ler kimliksiz ve ortam ayrımlıdır: development, Play closed-test ve
  production. Varsayılan test/CI profilinde uzak FCM kapalıdır.
- Foreground mesaj tek uygulama içi bildirim olarak gösterilir;
  background/terminated notification payload Android/FCM standart davranışını
  kullanır. Dış payload'dan route/deep-link üretilmez.
- Kod-head CI #163: run `31762135840`, job `94650543861`, **SUCCESS**.
  Analyze/tüm testler, release APK, birleşik manifest, kalıcı imza ve Android 16
  cold-start ilk denemede PASS; temiz ikinci emulator gerekmedi.
- Artifact `BilgiRotasi-AdMob-1.68.14-104-kanitlari`, ID `9205231533`, digest
  `sha256:68ac9764e2fe03f0fdfc44cbef5a4334cc9cd4f9f5d616766373ed7c24cc1529`;
  APK SHA-256 `9ac0534f56c4af9fc22173ca145ead77ec61b97016fdfd0eb6e6f2141db1143b`.
- Artifact paketi `com.leventua.bilgirotasi`, sürüm `1.68.14+104`, targetSdk
  36 ve upload SHA-1 `00:0E:E4:3F:41:0A:BC:6B:4F:63:4C:4F:71:6D:76:EB:19:08:41:15`.
- Birleşik manifestte POST_NOTIFICATIONS, Firebase Messaging servis/provider ve
  varsayılan channel metadata'sı doğrulandı. `APP_GATE=PASS`,
  `RELEASE_GATE=PASS`, PID `1976`, MainActivity RESUMED/visible; Bilgi Rotası
  paketine ait crash/ANR/FATAL/process-death eşleşmesi yok.
- Firebase deploy veya gerçek bildirim gönderimi yapılmadı. Auth, Firestore,
  Functions, App Check/Play Integrity ve AdMob davranışı değiştirilmedi.
- **DOĞRULANACAK:** güncel Play closed-test kurulumu üzerinde gerçek FCM
  foreground/background/terminated teslimi, izin red/kabul ve bildirim
  dokunuşuyla güvenli açılış.

---

## 0C. Hakkında & Gizlilik / herkese açık destek iletişimi — 13 Ağustos 2026

Bu bölüm aşağıdaki tarihsel release/main kayıtlarının bu iş için güncel sonucudur.

- Levent, PR #35 ve canlı Pages doğrulamasından sonra PR #34 merge sırasına açık onay verdi.
- PR #35 `fix: update public support contacts`, `main` tabanlı ayrı branch'te hazırlandı; public `docs/` sayfalarındaki destek e-postası `BilgiRotasidestek@gmail.com` olarak güncellendi ve eski beklenti testi yeni adrese hizalandı.
- PR #35 head `b30689cc5df5ac3dde1479be6fe379a23e7c79c9`; Quality Checks #302 ve AdMob PR doğrulaması #150 / run `31703222864` **SUCCESS**; Android 16 cold-start PASS.
- PR #35 Levent'in açık onayıyla `main` dalına squash merge edildi: `3b95e226c4e166864b72b22823ddc69b78589150`.
- GitHub Pages kaynağı `main:/docs`, HTTPS açık ve public; latest Pages build `1149217588` bu merge commit'i `3b95e226...` üzerinden **built** / hata yok olarak tamamladı.
- PR #34 `fix: update about privacy links`, release tabanlı ayrı branch'te `lib/about_privacy.dart` içindeki dört bağlantıyı `https://zmilastudio.github.io/BilgiRotasi/` alanına ve destek e-postasını `BilgiRotasidestek@gmail.com` adresine taşıdı; eski `leventua.github.io` ve `BilgiRotasi10@gmail.com` değerlerini engelleyen regresyon testi eklendi/güncellendi.
- PR #34 head `5fd552a2fe35e3b72a43a1f65162830da702655c`; AdMob PR doğrulaması #148 / run `31700031074`: **SUCCESS**.
- PR #34 Levent'in açık onayıyla `release/final-closed-test-aab-1.68.8` dalına squash merge edildi: `1ca0ff063586b15ef37222f8523f1aeefa1d52b7`.
- Merge sonrası canlı release HEAD `1ca0ff063586b15ef37222f8523f1aeefa1d52b7`; `pubspec.yaml` sürümü değişmedi: `1.68.14+104`.
- Merge sonrası AdMob PR doğrulaması #151 / run `31710501542`, job `94481907601` **SUCCESS** ve Quality Checks #304 / run `31710501544` **SUCCESS** oldu.
- #151 artifact `BilgiRotasi-AdMob-1.68.14-104-kanitlari`, ID `9185415759`, digest `sha256:1b831a41d072ee515f808bb6d967bd54ce3740308fed555e8a0086bc0b024344`; APK SHA-256 `bd83e43b0a6af054b15b65d93e57c5c260da1cdf4e57d765582f2e30f830fd7d`.
- Artifact APK metadata: package `com.leventua.bilgirotasi`, versionCode `104`, versionName `1.68.14`, targetSdk `36`; upload sertifika SHA-1 `00:0E:E4:3F:41:0A:BC:6B:4F:63:4C:4F:71:6D:76:EB:19:08:41:15`.
- Android 16 artifact kapıları `APK_INSTALL`, `APP_LAUNCH`, `APP_PID`, `APP_ACTIVITY`, `APP_LOGCAT`, `APP_GATE`, `RELEASE_GATE` = **PASS**; uygulama PID `2005` ve `MainActivity` RESUMED/visible olarak kaydedildi.
- Android 16 log taramasında Bilgi Rotası paketine ait `FATAL EXCEPTION`, AndroidRuntime FATAL, eksik AdMob application ID veya app-specific process-death kanıtı bulunmadı. Logdaki genel binder `process died` satırları Bilgi Rotası paketine ait değildir.
- AOSP ATD emulatorunda Google Play Store bulunmadığına dair Bilgi Rotası Google Play Services uyarısı vardır; bu cold-start kapısını bozmaz ve fiziksel Play kabulünün yerine geçmez.
- Oynanış, BoardMap, 67 node düzeni, `assets/questions.json` ve sürüm numarası değiştirilmedi.
- `KARARLAR.md` değişmedi; bu iş yeni ürün kararı değil mevcut Hakkında/Gizlilik ve public destek uçlarının düzeltilmesidir.

---

## 0B. BR-P1-008 final artifact kabulü — 13 Ağustos 2026

Bu bölüm aşağıdaki tarihsel BR-P1-008 açık/bekliyor kayıtlarının **güncel sonucudur**; eski kayıtlar denetim izi olarak korunur.

- PR #32 `docs: make release head references live` squash merge commit'i: `794205f3ad68c0547f2858d530170af3a7a6bd41`.
- Final `Closed test release doğrulaması`: run `31680750887`, job `94385413742`, source ref `release/final-closed-test-aab-1.68.8`, source SHA `794205f3ad68c0547f2858d530170af3a7a6bd41`: **SUCCESS**.
- Artifact: `BilgiRotasi-1.68.14-104-closed-test-release`; ID `9173824623`; digest `sha256:9c6f081211cff19a3d8857c6b6bb15dc312da17819fe67988f994a333c078d73`.
- Artifact içindeki AAB: `BilgiRotasi-1.68.14-104-closed-test.aab`; gerçek dosya SHA-256 ile `reports/AAB_SHA256.txt` birebir eşleşir: `6904249d00e12e3e671c9a282364dc4791948e9ec45cafecfaae15f8f734d285`.
- Dinamik `reports/RELEASE_READINESS.md`: sürüm `1.68.14+104`, **8.710 soru**, soru SHA-256 `e71c4ff991873499b986952835b9bb8e0995d2791c47ce4085d7ab9a502299d4`, doğru source ref/SHA, doğru AAB adı ve run `31680750887` URL'sini içerir.
- `RELEASE_READINESS.md` içinde eski `1.68.8+98`, `6710`, eski source branch/commit kalıntısı yoktur; trailing whitespace kontrolü **PASS**.
- `RC1_QUALITY_GATE.md`: **BAŞARILI**, `1.68.14+104`, 8.710 soru, kritik hata/uyarı yok.
- Android 16 AAB-derived kabul ilk denemede **PASS**; ikinci deneme gerekmedi. `GUEST_LOGIN=PASS`, `HOME_OYNA=PASS`, `APP_GATE=PASS`, `RELEASE_GATE=PASS`, `SETTINGS_TUTORIAL_DIAGNOSTIC=PASS`.
- Artifact log taramasında Bilgi Rotası paketine ait crash, ANR, `FATAL EXCEPTION` veya process-death kanıtı bulunmadı.
- AAB metadata: package `com.leventua.bilgirotasi`, versionCode `104`, versionName `1.68.14`, targetSdk `36`; upload sertifika SHA-1 `00:0E:E4:3F:41:0A:BC:6B:4F:63:4C:4F:71:6D:76:EB:19:08:41:15`.
- **BR-P1-008 TAMAMLANDI.** Dinamik release-readiness üretimi canlı artifact üzerinde kanıtlandı.
- Bu teknik kabul Play Console'a AAB yüklendiğini, fiziksel Play kabulünü veya Firebase/Play canlı konsol durumlarını tek başına doğrulamaz; bu maddeler ayrı açık görevlerde kalır.
- `KARARLAR.md` değişmedi; ürün kararı değişikliği yoktur.

---

## 0A. PR #29/#30 ve güncel release-readiness kesimi — 13 Ağustos 2026

Bu bölüm aşağıdaki tarihsel release HEAD / BR-P1-008 kayıtlarının **güncel durumunu geçersiz kılar**; tarihsel kayıtlar denetim izi olarak korunur.

- Güncel yayın dalı: `release/final-closed-test-aab-1.68.8`.
- PR #30 kod tabanı / merge commit: `d1d5a9ea128d3d36fe26fafe95c97bf473c02548`.
- PR #31 proje-hafızası merge commit: `dcab00bee295c75a817fd4dda0a63be10c5a6d56`.
- Canlı release HEAD bu dosyada statik bir SHA olarak dondurulmaz; her teknik görev başında `release/final-closed-test-aab-1.68.8` dalı GitHub'dan yeniden okunur.
- Paket sürümü değişmedi: `1.68.14+104`.
- PR #29 `fix: generate release readiness from live build facts` release'e merge edildi: `9aef2bd9ceeeba3a47e85e5a508512967d7db29d`.
- PR #29 sonrası manuel final closed-test run `31654600408`, uygulama/AAB aşamasından önce `git diff --check` ile kırıldı. Kök neden Bilgi Rotası uygulaması değil, dinamik `RELEASE_READINESS.md` üreticisindeki satır-sonu boşluklarıydı; bu run release AAB kabul kanıtı değildir.
- PR #30 `fix: remove release readiness trailing whitespace` yalnız `tools/release_readiness_report.py` ve `test/release_readiness_report_test.dart` dosyalarını değiştirdi.
- PR #30 kod head'i `1c809e9f4d02c425705e4812b0daadf87418b9fd`; CI #139 run `31655047190`, job `94307567727`: **SUCCESS**. Analyze/tüm testler, release APK ve Android 16 cold-start kapısı geçti.
- PR #30 Levent'in açık onayıyla release'e merge edildi; merge commit: `d1d5a9ea128d3d36fe26fafe95c97bf473c02548`.
- PR #31 sonrası `dcab00bee295c75a817fd4dda0a63be10c5a6d56` üzerinde Quality Checks #298 / run `31657810165` **SUCCESS** ve AdMob PR doğrulaması #142 / run `31657810270` / job `94316006975` **SUCCESS** oldu.
- #142 artifact `BilgiRotasi-AdMob-1.68.14-104-kanitlari`, ID `9165265578`, digest `sha256:da4a2082ca2139529fe4bee0358b560a966391d41e1548c8b20943184edbf2c3`; APK SHA256 `3bdb9ab250c97f42ab958ff1e037c0ad5eaee9458090d97b850710bf4c928813`. Paket `com.leventua.bilgirotasi`, sürüm `1.68.14+104`, upload-signing SHA-1 `00:0E:E4:3F:41:0A:BC:6B:4F:63:4C:4F:71:6D:76:EB:19:08:41:15`; Android 16 `APP_GATE=PASS` ve `RELEASE_GATE=PASS`; Bilgi Rotası paketine ait crash/ANR/FATAL/process-death eşleşmesi yok. Bu APK kanıtı manuel final Closed Test AAB kabulünün yerine geçmez.
- **BR-P1-008 uygulama/CI/merge kısmı tamamlandı:** rapor artık sürümü `pubspec.yaml`dan, soru sayısı/SHA'yı `assets/questions.json`dan, source SHA/ref ve AAB adını GitHub Actions ortamından dinamik üretir; trailing whitespace regresyon testiyle kilitlidir.
- **Kapanış için kalan kanıt:** bu proje-hafızası temizliği release'e merge edildikten sonra GitHub'dan yeniden okunan **canlı release HEAD** üzerinde yeni `Closed test release doğrulaması` manuel workflow'u çalıştırılmalı ve artifact içindeki `reports/RELEASE_READINESS.md` canlı `1.68.14+104`, 8.710 soru, doğru source SHA/ref, doğru AAB adı ve whitespace'siz raporu göstermelidir.
- Fresh RC2 artifact AAB SHA256 için doğrudan indirilen artifact `reports/AAB_SHA256.txt` ve gerçek AAB dosya hash'i otoritatiftir: `6904249d00e12e3e671c9a282364dc4791948e9ec45cafecfaae15f8f734d285`. Aşağıdaki eski `690424c...` satırları tarihsel transkripsiyon hatasıdır ve kullanılmamalıdır.
- `KARARLAR.md` değişmedi; bu iş ürün kararı değil release kanıt/raporlama düzeltmesidir.

---

## 0. Fresh RC2 güncel kabul kesimi — 13 Ağustos 2026

Bu bölüm aşağıdaki tarihsel bölümlerde kalan “fresh RC2 gerekli/bekleniyor” ifadelerinin **güncel durumunu geçersiz kılar**; tarihsel kayıtlar silinmemiştir.

- Release branch: `release/final-closed-test-aab-1.68.8`.
- Fresh RC2'nin test ettiği release HEAD: `d450c573a122231734437fb097cf17a00e583801`.
- Son işlevsel release commit'i: `7a50a1997c6eade985a3933fd019055dd6a2c791` (PR #25). `7a50a199... → d450c573...` farkı proje-hafızası/docs değişiklikleridir; uygulama işlevsel içeriği değişmemiştir.
- Paket sürümü: `1.68.14+104`.
- Fresh manuel RC2 workflow run: `31645526580`; job: `94278055890`; sonuç: **SUCCESS**.
- Artifact: `BilgiRotasi-1.68.14-104-closed-test-release`; ID `9160985710`; digest `sha256:0a086fab7c0730321c8768aefb94b7887f365d3cc80bf8fe087da83c7a425815`.
- AAB SHA256: `690424c771867ce4835019449e8f4cc75e36aeca5779838fa7996a96faaa04e1`.
- Android 16 AAB-derived `Misafir → Home → Oyna` zinciri ilk denemede PASS; ikinci temiz deneme gerekmedi ve SKIPPED.
- `APK_INSTALL`, `APP_LAUNCH`, `APP_PID`, `APP_ACTIVITY`, `APP_LOGCAT`, `FIREBASE_AUTH_UI`, `FRESH_USER_AUTH_GATE`, `ANALYTICS_CONSENT_GATE`, `GUEST_LOGIN_GATE`, `HOME_PLAY_GATE`, `APP_GATE`, `RELEASE_GATE` = **PASS**.
- Flutter analyze/test, soru kapıları (8.710 soru), Functions testleri, Firestore Rules emulator, closed-test AdMob ve production Firebase release profile kontrolleri **PASS**.
- Artifact/log incelemesinde Bilgi Rotası paketine ait crash, ANR, `FATAL EXCEPTION` veya process-death kanıtı bulunmadı.
- **BR-P1-008 açık kalır:** fresh artifact içindeki `reports/RELEASE_READINESS.md` hâlâ eski `1.68.8+98`, eski source/AAB ve 6.710 soru gibi tarihsel metinler taşır. Bu rapor kusuru gerçek AAB/gate kabulünü geçersiz kılmaz.
- Fresh RC2 teknik kabulü tamamlandı; ancak Play Console güncel kanal/sayaç/sürüm, Play signing SHA rolleri ve Firebase canlı Auth/SHA/Functions/Rules/Indexes/App Check durumu hâlâ canlı servislerden **DOĞRULANACAK**.
- Güncel Play kurulumu üzerinde Google giriş/oturum, Misafir→Google veri izolasyonu, öğretici, Google demo rewarded ve Canlı Düello fiziksel kabulü hâlâ açıktır.

---

## 1. Yayın kaynağı

| Alan | Güncel değer | Durum | Kaynak |
|---|---|---|---|
| Kanonik repo | `ZMilaStudio/BilgiRotasi` | DOĞRULANDI | 13 Ağustos 2026 GitHub canlı sorgusu |
| Android paket adı | `com.leventua.bilgirotasi` | DOĞRULANDI | Release artifact / source |
| Yayın/release dalı | `release/final-closed-test-aab-1.68.8` | DOĞRULANDI | GitHub canlı branch |
| Release HEAD | `7a50a1997c6eade985a3933fd019055dd6a2c791` | DOĞRULANDI | PR #25 merge |
| Son işlevsel release commit'i | `7a50a1997c6eade985a3933fd019055dd6a2c791` | DOĞRULANDI | PR #25 merge |
| Gerçek paket sürümü | `1.68.14+104` | DOĞRULANDI | Release `pubspec.yaml` |
| `main` HEAD | `ab9b4f3797a02b92f98f92e439b7edc4c608fec3` | DOĞRULANDI | PR #26 merge; yalnız workflow görünürlüğü |
| `main` dalı | Güncel yayın kaynağı değil | KESİN KARAR | `KARARLAR.md` |
| PR #7 | Açık / Draft / release → `main` | DOĞRULANDI | GitHub canlı PR; merge edilmeyecek |
| PR #12 | Açık; 3B deterministik geometri | DOĞRULANDI | GitHub canlı PR |
| PR #13 | Açık / Draft; kaynak ödüllü reklam PR'ı | DOĞRULANDI | GitHub canlı PR |
| PR #15 | Açık / Draft; telemetri işi PR #16 üzerinden release'e ulaştı | DOĞRULANDI | GitHub canlı PR |
| PR #21 | Merge edildi; `2ce47112fce1a0c462ae9f95e8187a6e1d148581` | DOĞRULANDI | GitHub |
| PR #23 | Merge edildi; `ec20e66e1d52126ce99fa09e29f606ae14a5f7a2` | DOĞRULANDI | GitHub |
| PR #24 | Merge edildi; docs-only `bb988e7e4d60a41c1711e70d2ec6125e7136b0d5` | DOĞRULANDI | GitHub |
| PR #25 | Merge edildi; `7a50a1997c6eade985a3933fd019055dd6a2c791` | DOĞRULANDI | GitHub / final CI #129 |
| PR #26 | Merge edildi; `ab9b4f3797a02b92f98f92e439b7edc4c608fec3` | DOĞRULANDI | GitHub; manual RC2 workflow'unu default branch'te görünür yaptı |
| Android geliştirici doğrulaması | Tamamlandı | RAPORLANDI | Levent'in Play doğrulaması |

**Kural:** Branch adındaki `1.68.8`, paket sürümü değildir. Gerçek sürüm her zaman hedef dalın `pubspec.yaml` dosyasından okunur.

---

## 2. RC2 #326 - tarihsel kabul kanıtı ve güncel sınır

Fresh manuel RC2 #326:

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

PID `3566`; artifact log taramasında Bilgi Rotası paketine ait crash, ANR, `FATAL EXCEPTION` veya process death kanıtı bulunmadı.

**Güncel sınır:** PR #25 işlevsel uygulama kodu release'e `7a50a199...` ile merge edildi. Bu nedenle RC2 #326 artık **güncel release HEAD için kabul kanıtı değildir**. Eski #326 rerun edilmeyecek; `7a50a199...` üzerinde yeni bir fresh geniş RC2 çalıştırılacak ve Guest → Home → Oyna dahil tüm zorunlu gate'ler yeniden PASS olmalıdır.

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
Bu düzeltme RC2 #326'da gerçek AAB-derived `Misafir → Home → Oyna` zinciriyle doğrulandı.

---

## 4. Google Play

- `1.68.13+103` daha önce Dahili Test'te gerçek cihazda doğrulandı ve Kapalı Test kanalına yayımlandı.
- Son doğrulanan Play kapalı test durumu **12 geçerli testçi / 4 kesintisiz gün**dür.
- Bu değer güncel Play Console UI'sından yeniden okunmadan ileri gün sayısı tahmin edilmeyecek.
- Android geliştirici doğrulaması tamamlandı.
- `1.68.14+104` için eski RC2 #326 teknik kanıtı yalnız `ec20e66...` SHA'sına aittir.
- PR #25 sonrası güncel release `7a50a199...` için fresh RC2 PASS olmadan yeni AAB Play'e yüklenmez.
- `1.68.14+104` AAB'nin Play kapalı test kanalına daha önce gerçekten yüklenip yüklenmediği canlı Console'dan **DOĞRULANACAK** durumundadır. Eğer versionCode 104 zaten yüklenmişse aynı versionCode yeniden yüklenemez; sürüm artırımı ayrı kontrollü görev olur.

**Durum:** Kapalı test hattı aktif; fresh RC2 ve canlı Firebase/Play kabul kontrolleri açık.

---

## 5. Firebase / App Check / Play Integrity

Production Firebase projesi: `bilgi-rotasi-f255d`.

Repo/source envanteri:

- Android package: `com.leventua.bilgirotasi`.
- `firebase.json` Functions için Node 20, Firestore rules/indexes ve emulator yapılandırması içerir.
- Repoda `.firebaserc` yoktur. Eventual deploy açıkça `--project bilgi-rotasi-f255d` kullanmadan yapılmamalıdır.
- Functions region istemci tarafında `europe-west1` olarak sabittir.
- `firestore.indexes.json` içinde 3 composite index vardır:
  1. `live_duel_queue`: `questionCount ASC`, `status ASC`, `ratingBucket ASC`
  2. `live_duel_matches`: `status ASC`, `updatedAt ASC`
  3. `live_duel_matches`: `playerUids ARRAY_CONTAINS`, `resultProcessed ASC`
- App Check production provider'ı Play Integrity'dir; dev/test profili debug provider kullanır.
- RC2 #326 source/build doğrulamasında Production Firebase profile, Cloud Functions testleri ve Firestore Rules emulator testleri PASS olmuştur.
- RC2 artifact'ı uzak production veritabanını okumadığını/değiştirmediğini belirtir; canlı Functions/Rules/Indexes deploy durumu bundan çıkarılamaz.

Canlı servisten yeniden doğrulanacaklar:

- Google Auth provider
- Android SHA kayıtları ve roller
- Functions deployed names/revisions/region
- Firestore indexes READY durumu
- Firestore rules aktif sürümü
- App Check / Play Integrity enforcement ve güncel metrikler

**Kural:** Kör veya toplu Firebase deploy yapılmaz.

---

## 6. İmza ayrımı ve açık çelişki

RC2/AAB upload signing SHA-1:

`00:0E:E4:3F:41:0A:BC:6B:4F:63:4C:4F:71:6D:76:EB:19:08:41:15`

Güncel release testi `test/firebase_play_signing_profile_test.dart`, Play-signing/OAuth SHA-1 olarak şunu bekler:

`26:3C:46:C6:AE:9F:27:C3:B3:38:10:FA:89:8C:D7:EB:93:73:CC:F4`

Eski devir/proje notlarında Play App Signing SHA-1 olarak ayrıca şu değer bulunur:

`17:E1:EC:6C:77:4F:B4:59:63:FA:7A:76:51:7D:21:B2:BB:7C:81:1F`

Repo içinde `17:E1...` değeri doğrulanamadı. `26:3C...` ile `17:E1...` arasındaki fark tahminle kapatılmayacak. Play Console'daki **Uygulama imzalama anahtarı sertifikası** ve **Yükleme anahtarı sertifikası** SHA-1 değerleri, ardından Firebase Android app fingerprint listesi canlı ekranla karşılaştırılacaktır.

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

### PR #25 - closed-test ödüllü reklam kabul kapısı

Kök neden: `1.68.14+104` closed-test AAB `FIREBASE_ENVIRONMENT=production` + `ADMOB_ENVIRONMENT=closed_test` ile üretilmesine rağmen eski `SupportRewardCard`, production Firebase açıkken +10 XP kartını kapatıyordu.

Çözüm:

- production Firebase + `closed_test` AdMob => Google demo rewarded + yerel oyun-başına +10 XP açık
- production Firebase + production AdMob => kapalı
- dev/test Firebase + production AdMob => kapalı
- dev/test Firebase + test AdMob => test/dev davranışı açık
- oyun-başına tek hak, aynı oyun ikinci ödül yok ve başarısız reklam sonrası hakkın korunması değişmedi

Kanıt:

- Son işlevsel kod head'i: `2cc47846b42cf98b4f8303bb86148cc475060824`
- Kod-head CI #128: run `31635781505`, job `94245596601`, **SUCCESS**
- Final PR head: `f8939b6f6aa950bda48bedf8b87dc0a51c761916`
- Final CI #129: run `31637213948`, job `94250454471`, **SUCCESS**
- Final artifact: `BilgiRotasi-AdMob-1.68.14-104-kanitlari`, ID `9157834250`
- Digest: `sha256:3b2c0347b3d194f84618f8c02863dcd5ad21c76cc7ce7b72b906f0314c8f8c25`
- Final artifact app/release gate PASS; Bilgi Rotası crash/ANR/FATAL/process-death eşleşmesi yok
- PR #25 Levent'in açık onayıyla release'e merge edildi: `7a50a1997c6eade985a3933fd019055dd6a2c791`

**Açık kabul:** Bu AdMob PR CI geniş Guest → Home → Oyna RC2'nin yerine geçmez. Güncel release HEAD için fresh geniş RC2 ve ardından fiziksel Google demo rewarded kabulü zorunludur.

### Production SSV - ayrı açık konu

`functions/rewarded_ssv.js` ve `docs/rewarded-ssv-setup.md` production SSV'nin **henüz deploy edilmediğini** belirtir. Mevcut aday SSV sözleşmesi günlük 3 işlem / toplam +30 XP limiti taşır; bu, güncel `KARARLAR.md` içindeki “günlük/oturumluk toplam kota yok” kararıyla çelişir. Blanket `firebase deploy --only functions` yapılmayacak; SSV sözleşmesi ayrı branch/görevde ürün kararına uyarlanıp test edilmeden deploy edilmeyecektir.

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
- `XpProgressService._award(reward, 'Günlük giriş serisi • N. gün')` çağrılır

RC2 #325'te görülen `+20 XP • Günlük giriş serisi • 1. gün` bu kodla uyumludur. Bu, RC2 #325 Kariyer yönlendirmesinin kök nedeni değildir; ayrı ürün/karar tutarsızlığıdır.

**Durum:** `AÇIK / KÖK KAYNAK DOĞRULANDI`. Ayrı branch'te kaldırılacak ve retention/XP regression testleri eklenecek.

---

## 10. `RELEASE_READINESS.md` bayat rapor içeriği

RC2 #326 artifact'ındaki gerçek paket ve kalite raporları doğru biçimde `1.68.14+104` ve **8.710 soru** gösterir. Buna rağmen `reports/RELEASE_READINESS.md` içinde eski `1.68.8+98`, eski kaynak commit/AAB adı ve 6.710 soru gibi tarihsel metinler kalmıştır.

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

## 14. GitHub Actions fresh RC2 görünürlüğü

Kök neden: `.github/workflows/closed-test-release.yml` ve `.github/workflows/closed-test-release-core.yml` release dalında vardı ancak default branch `main` üzerinde yoktu; bu nedenle GitHub Actions manuel workflow listesinde `Closed test release doğrulaması` görünmüyordu.

Düzeltme:

- Branch: `ci/expose-closed-test-release-workflow`
- Commit: `3dc820502ba131258824b27776f292a67e85d54e` — `ci: expose closed-test release workflow on main`
- PR: #26
- Merge commit: `ab9b4f3797a02b92f98f92e439b7edc4c608fec3`
- Değişiklik: yalnız iki workflow dosyası; release'teki RC2 #326 ile doğrulanmış bloblar byte-for-byte taşındı
- Wrapper blob SHA: `f8fe355ad547c7fc4a5ec48c2809d65796b402df`
- Core blob SHA: `3afa8793d3f437c63d690c86f3b6dbaaca2ce83a`
- Quality Checks #292: run `31642575342`, job `94268451360`, **SUCCESS**
- GitHub Actions kayıt durumu: `Closed test release çekirdeği` workflow ID `333114585` **ACTIVE**
- GitHub Actions kayıt durumu: `Closed test release doğrulaması` workflow ID `333114587` **ACTIVE**
- Release branch ve `1.68.14+104` sürümü değişmedi.
- PR #7 açık/Draft kaldı.

Eski `.github/workflows/apply-game-save-isolation-v4.yml` push workflow'u bu branch push'unda config-level kırmızı üretti ve **0 job** çalıştırdı. Bu, PR #26 değişikliğiyle ilişkili uygulama/test hatası değildir; ayrı tarihsel workflow teknik borcu olarak ele alınacaktır.

---

## 15. Şu anda ilk yapılacak işler

1. GitHub Actions → `Closed test release doğrulaması` workflow'unu `release/final-closed-test-aab-1.68.8` üzerinde `confirmation=CLOSED_TEST` ile manuel başlat; eski #326'yı rerun etme.
2. Yeni fresh RC2'nin tam workflow/job/log/artifact kanıtını incele; Guest → Home → Oyna, app/release gate ve crash/ANR kontrollerinin tamamı PASS olmalı.
3. Play Console'dan uygulama imzalama ve upload SHA-1 ekran kanıtını al; `26:3C...` / `17:E1...` çelişkisini çöz.
4. Firebase Console'da Google Auth, Android SHA'lar, Functions, Rules, Indexes ve App Check envanterini canlı doğrula; kör deploy yapma.
5. Play Console'da güncel kapalı test AAB sürümünü, testçi sayısını ve kesintisiz gün sayacını tarihli kanıtla yeniden oku.
6. Fresh RC2 ve servis kontrolleri temizse güncel AAB'nin Kapalı Test yükleme durumunu netleştir.
7. Güncel Play kurulumu üzerinden Google giriş, oturum korunması, Misafir → Google geçişi, hesap izolasyonu, Ayarlar/öğretici ve Google demo ödüllü reklam kabulünü fiziksel cihazda doğrula.
8. İki ayrı cihaz/hesapla Canlı Düello eşleşme → maç → sonuç → leaderboard zincirini doğrula.
9. Günlük giriş XP karar çelişkisini ayrı branch/görev olarak çöz.
10. Production SSV günlük 3/+30 XP sözleşmesini ürün kararıyla uyumlu hale getirmeden deploy etme.
11. `RELEASE_READINESS.md` bayat şablonunu ayrı teknik görev olarak düzelt.
12. Eski `apply-game-save-isolation-v4.yml` config-level workflow borcunu ayrı görevde incele; bu düzeltmeyle karıştırma.
13. Soru geri bildirim düzeltmelerini ayrı branch/PR düzeninde sürdür.
14. 3B tahta işine 6-rozet eşlemesi ve geometri onayı olmadan dönme.
