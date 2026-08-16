# Bilgi Rotası - Güncel Proje Durumu

**Kesim noktası:** 16 Ağustos 2026
**Durum sınıfları:** `DOĞRULANDI`, `RAPORLANDI`, `AÇIK`, `DURDURULDU`

## 0H. Android 16 tutorial replay gate / PR #44 — 16 Ağustos 2026

Bu bölüm aşağıdaki `0G` PR #43 ön-merge kaydının **güncel durumunu geçersiz kılar**; `0G` tarihsel denetim izi olarak korunur.

- Canlı hedef/yayın dalı `release/final-closed-test-aab-1.68.8`; güncel release HEAD `9371e0aecc4e677c24682e11a31d91ebed54f309` — `fix: align RC1 launcher quality gate (#43)`; canlı sürüm `1.68.16+106`.
- PR #43 Levent'in açık onayıyla release dalına squash merge edildi. PR #43 final PR-head CI #195 / run `31916239947` **SUCCESS** idi; merge commit ve canlı release HEAD `9371e0aecc4e677c24682e11a31d91ebed54f309`.
- Merge sonrası fresh `Closed test release doğrulaması` #9 / run `31942307299`, job `95153144908`, tam olarak bu release SHA üzerinde çalıştı. RC1 kalite kapısı, production Firebase/OAuth doğrulaması, signing, gerçek AAB build, AAB→APK, metadata/profile ve ana Android 16 uygulama kapıları geçti; ancak zorunlu Ayarlar → Eğitimi Yeniden Göster tanısı nedeniyle final `RELEASE_GATE=FAIL` oldu.
- Run #9 artifact `BilgiRotasi-1.68.16-106-closed-test-release`: ID `9262524277`, digest `sha256:1e558a0423b6243d7ded7849b72c7353726ea453e7d70ae4c225914e56df4e0a`. Run #9 gerçek AAB üretti ancak release gate FAIL olduğu için Play yükleme adayı değildir.
- Run #9 kanıtında `APP_GATE=PASS`; Bilgi Rotası paketinde crash/ANR/FATAL/process-death kanıtı yok. `UI_SETTINGS_TUTORIAL_2.tsv` içinde `Yeniden` OCR satırı gerçekten vardır ve merkez koordinatı `440 1718` olarak çözülür.
- Kanıtlanan kök neden OCR/parser veya uygulama davranışı değildir. `retry_capture_screen()` içindeki `attempt` retry sayacı local olmadığı için Bash dinamik kapsamı, `run_settings_tutorial_diagnostic()` dış döngüsündeki aynı adlı `attempt` sayacını değiştiriyordu. Böylece `_2.tsv` doğru çekildiği halde çağıran fonksiyon yanlışlıkla tekrar `_1.tsv` okuyabiliyordu.
- Ayrı branch `fix/br-p0-011-android16-tutorial-gate`; Draft PR #44 açık ve merge edilmemiştir. İlk teşhis commit'i `38a13c58b5e85e3e5798b6c4209dd449216e81b7`; kanıtlanan kök neden düzeltmesi `a6ce0ba08bce5d2454aaeb612f62a271d10e8f28` — `fix: isolate Android 16 tutorial retry counters`.
- Release tabanına göre PR #44 teknik net diff'i yalnız iki dosyadır: `tools/validate_android16_closed_test.sh` ve `test/android16_closed_test_retry_scope_test.dart`. Helper retry sayacı local yapıldı; tutorial taraması bağımsız `tutorial_attempt` kullanıyor; regresyon testi caller sayacının helper tarafından değiştirilememesini gerçek Bash çağrısıyla kilitliyor. Mandatory Android 16 gate koşulları gevşetilmedi.
- PR #44 teknik-head AdMob PR doğrulaması #197 / run `31957410025`, job `95190026025`: **SUCCESS**. İlk Android 16 denemesi PASS; sınıflandırma PASS; ikinci temiz emulator SKIPPED; final zorunlu uygulama kapısı PASS.
- #197 artifact `BilgiRotasi-AdMob-1.68.16-106-kanitlari`: ID `9266476416`, digest `sha256:c9dd5c698b05dcaa263d5d2d592a5bb2f8e303628e1baca5de1a581090f4d242`; APK SHA-256 `67b148a2140e04835d5226148a27605e2416f38e3c3c20695f6d843bfb26500d`.
- #197 artifact sonucu `RESULT=PASS`, `RELEASE_GATE=PASS`, `APP_GATE=PASS`; `APK_INSTALL`, `APP_LAUNCH`, `APP_PID`, `APP_ACTIVITY`, `APP_LOGCAT` = PASS. Paket `com.leventua.bilgirotasi`, versionName `1.68.16`, versionCode `106`, targetSdk 36; MainActivity `RESUMED/visible`, PID `1927`; uygulamaya ait crash/ANR/FATAL/process-death eşleşmesi yok.
- Sürüm numarası, uygulama binary/oynanış davranışı, `assets/questions.json`, BoardMap, 67 node, 3B tahta, launcher/splash ve Firebase/AdMob/FCM ürün davranışı değiştirilmedi. `KARARLAR.md` değişmedi.
- PR #44 henüz Draft/open durumundadır. Bu proje-hafızası güncellemesi sonrası yeni final PR-head CI yeniden tam log/artifact/diff/Git geçmişiyle PASS olmadan PR merge için hazır sayılmaz. Merge, ayrıca Levent'in açık onayını gerektirir.
- PR #44 merge edilirse BR-P0-011'un son kabulü, yeni canlı release HEAD üzerinde **fresh** `Closed test release doğrulaması` PASS ve gerçek `1.68.16+106` AAB artifact üretimidir. Bu yapılmadan Play yükleme veya görev kapanışı yoktur.

---

## 0G. RC1 launcher quality gate / PR #43 — 16 Ağustos 2026

- Canlı hedef/yayın dalı `release/final-closed-test-aab-1.68.8`; PR #43 taban SHA'sı `84d671735d371282f909ac45f6c42d2721ca9d63`; hedef sürüm `1.68.16+106`.
- Fresh `Closed test release doğrulaması` #8 / run `31910656517`, gerçek release HEAD üzerinde AAB üretiminden önce RC1 kalite kapısında `assets/branding/app_icon_foreground.png` eksikliğiyle durdu. Canlı kaynak/diff incelemesi bunun launcher asset hatası değil, `tools/rc1_quality_gate_impl.py` içindeki bayat `REQUIRED_FILES` beklentisi olduğunu doğruladı.
- Güncel kanonik launcher kaynağı `assets/branding/app_icon.png`; mevcut launcher/splash asset'leri değiştirilmedi.
- Ayrı branch `fix/rc1-launcher-quality-gate-20260816`; Draft PR #43 açık. Teknik commit `7d3166f3a4a2d8009e57af29065a442123a9ec79` — `fix: align RC1 launcher quality gate`.
- Teknik diff **yalnız iki dosya**: `tools/rc1_quality_gate_impl.py` ve `test/launcher_icon_contract_test.dart`. Gate'ten kaldırılan ayrı foreground kaynak zorunluluğu silindi; test, `app_icon.png` zorunluluğunu ve eski `app_icon_foreground.png` beklentisinin geri gelmemesini kilitler.
- `assets/questions.json`, BoardMap, 67 node düzeni, oynanış, Firebase/AdMob/FCM ürün davranışı, launcher görseli, splash ve sürüm numarası değiştirilmedi.
- Teknik-head AdMob PR doğrulaması #194 / run `31912671944` / job `95079995092`: **SUCCESS**. `flutter analyze`: no issues; tüm Flutter testleri PASS; release APK build PASS; Android 16 `ANDROID16_APP_GATE=PASS` ve `ANDROID16_RELEASE_GATE=PASS`; app-specific FATAL/ANR sayıları 0.
- #194 artifact `BilgiRotasi-AdMob-1.68.16-106-kanitlari`: ID `9249278155`, digest `sha256:d3f25a816c60f4b5f2245254b591e4aed7a7765be928b7a5ad5a59a445bdd7ff`; APK SHA-256 `1841b19e721cff440954478b12844194d816f24a2f7f14426ed19fbdb8f1a16e`.
- PR #43 canlı Git geçmişi: 1 teknik commit, 2 değişen dosya, 13 ekleme, 1 silme. Tam workflow logu, artifact metadata'sı, PR diff'i ve Git geçmişi birlikte incelendi.
- `KARARLAR.md` değişmedi; mevcut D-032 launcher kararı bu kalite-kapısı hizalamasında korunur.
- Levent 16 Ağustos 2026'da açık merge onayı verdi. **Merge henüz yapılmadı**; önce bu proje-hafızası commit'i üzerindeki yeni final PR-head CI'ın tam log/artifact/diff/Git geçmişiyle PASS olması zorunlu.
- PR #43 bitti ölçütündeki son teknik yayın kabulü merge sonrasıdır: canlı release HEAD üzerinde yeni `Closed test release doğrulaması` PASS olmalı ve gerçek `1.68.16+106` AAB artifact'i üretilmelidir.

---

## 0F. Issue #37 FCM release kapanışı — 15 Ağustos 2026

Bu bölüm aşağıdaki `0E` Issue #37 ön-merge kaydını **güncel olarak geçersiz kılar**; tarihsel kayıt denetim izi olarak korunur.

- Kanonik yayın dalı `release/final-closed-test-aab-1.68.8`; PR #39 merge öncesi release HEAD `37f5ba0b1ea2cc5cfd97ff56beb6c31ba55d33b8`, sürüm `1.68.14+104` idi.
- Levent'in açık `PR #39'u merge et` onayı sonrası PR #39 Draft'tan çıkarıldı ve release dalına **squash merge** edildi.
- PR #39 merge commit'i ve güncel release HEAD: `bb0897f5c8bff9f2257dd5dde437bcf732448914` — `feat: add Firebase push notification infrastructure (#39)`.
- Merge sonrası canlı `pubspec.yaml` sürümü değişmedi: `1.68.14+104`; `firebase_messaging: ^16.4.3` release dalında mevcuttur.
- Final PR head `c343e68c5452b9bf7205e6fd0860ae16734073b3`; AdMob PR doğrulaması #190 / run `31903365510` / job `95057405310`: **SUCCESS**. Analyze+tüm testler, kalıcı imza, release APK, manifest doğrulaması ve Android 16 cold-start/final app gate PASS; ikinci temiz deneme gerekmedi.
- Final PR-head artifact `BilgiRotasi-AdMob-1.68.14-104-kanitlari`: ID `9251835873`, digest `sha256:7f5c5d408f39452a1590317e45b9bcb033d98abf68c7019538e2ad07dd26ae8e`.
- Fiziksel Play closed-test `1.68.15+105` üzerinde bildirim izni kabul/red, foreground, background, terminated/swipe-away, bildirim tap ile normal açılış, uygulama içi kapatma sonrası no-delivery ve Ayarlar öğretici yeniden gösterme **PASS**.
- Fiziksel ADB/logcat kabulü **PASS**: final ZIP `BilgiRotasi_FINAL_ADB_20260815_220727.zip`, SHA-256 `cd1930a7bbc55cd448815bb2662cfc5b2f9785a8d7001cd0bb736301ae3cbba7`; `PID_START=14450` = `PID_END=14450`; MainActivity başlangıç/sonda visible/top-resumed; Bilgi Rotası için FATAL/ANR/am_crash/am_proc_died/native crash/beklenmeyen process-death yok; test saatinde yeni exit-info kaydı yok.
- Analytics + FCM public gizlilik açıklaması PR #40 ile `main` dalına daha önce squash merge edildi: `c7b3be9925344f3c8f6bc608a1f7d98a42c0a210`; GitHub Pages build `1152991654` **built** ve hata yok.
- `assets/questions.json`, BoardMap, 67 node düzeni, Auth/Firestore/Functions/App Check/AdMob ürün davranışı ve sürüm numarası bu kapanış işiyle değiştirilmedi.
- Production topic'e gerçek mesaj gönderilmedi; production bildirimi hâlâ ayrı açık Levent kararı gerektirir.
- GitHub Issue #37 bu docs-kapanış PR'ı hazırlanırken metadata olarak hâlâ **OPEN** durumundadır. Teknik kabul ve release merge tamamlanmıştır; issue'nun `completed` kapatılması bu proje-hafızası PR'ı merge edildikten sonra ayrı repo-metadata işlemi olarak yapılacaktır.
- `KARARLAR.md` değişmedi; ürün kararı değişmedi.

---

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
- Android 16 `APK_INSTALL`, `APP_LAUNCH`, `APP_PID`, `APP_ACTIVITY`, `APP_LOGCAT`, `APP_GATE`, `RELEASE_GATE` = PASS; PID `1991`, MainActivity RESUMED/visible; uygulamaya ait crash/ANR/FATAL/process-death kanıtı yok.
- Artifact APK içindeki gerçek 192 px legacy ve 432 px adaptive launcher görselleri doğrudan açılarak onaylanan BİLGİ ROTASI yazılı pusula olduğu doğrulandı.
- Mevcut fiziksel telefondaki Google Play kurulumunu silmeden/üzerine farklı imzalı APK zorlamadan gerçek launcher ekranı kurulumu yapılamadı; bu kabul `DOĞRULANACAK` kalır.

---

## 0E. Issue #37 Firebase genel duyuru altyapısı — 14 Ağustos 2026

- Canlı yayın tabanı `release/final-closed-test-aab-1.68.8`; güncel release HEAD
  `37f5ba0b1ea2cc5cfd97ff56beb6c31ba55d33b8`; release sürümü `1.68.14+104`.
- Ayrı dal `feat/push-notifications-issue-37`; Draft PR #39 açık ve release/main'e
  merge edilmemiştir. PR head'i her teknik işlemde canlı GitHub metadata'sından
  yeniden doğrulanır.
- `firebase_messaging 16.4.3`, Android 13+ `POST_NOTIFICATIONS`, notification
  channel, background entry-point, foreground uygulama içi gösterim ve güvenli
  normal uygulama açılışı uygulanmıştır. İlk açılışta izin istenmez.
- Ortam topic izolasyonu sertleştirildi: development, closed-test ve production
  topic'leri bilinen tek küme olarak yönetilir; ortam değişiminde diğer topic'ler
  temizlenmeden yeni topic aboneliği açılmaz. Unsubscribe başarısızsa token
  sıfırlanır; uzak temizlik de başarısızsa `push_notifications_cleanup_pending_v1`
  ile sonraki açılışta tekrar denenir.
- `PUSH_ENVIRONMENT` artık tek başına daha geniş bir ortama geçiş açamaz; yalnız
  AdMob + Firebase runtime profilinden çıkarılan ortamı doğrular. Uyuşmazlıkta
  `test` profiline fail-closed düşülür.
- İlk sertleştirme commit'i `c7f8227d0c5a75e5ee2d5f66bd9ff3edbeb9a2ab`
  (`fix: harden push environment isolation`). İlk CI run `31805647373`, mevcut
  `backend_hardening_test` PR workflow'unda production Firebase define'ını
  yasakladığı için FAIL oldu; yeni FCM unit testleri bu koşuda PASS'ti.
- Güvenlik sözleşmesi gevşetilmeden workflow eski güvenli haline döndürüldü ve
  saf profil çözümleme testi eklendi. Commit `5c137622822e11fe7e3fe545a48cee97f8061ced`
  (`test: keep push profile validation isolated`). Final kod-head AdMob PR
  doğrulaması #169 / run `31806178473`, job `94785535777`: **SUCCESS**.
- Final CI artifact `BilgiRotasi-AdMob-1.68.14-104-kanitlari`: ID `9221592169`,
  digest `sha256:a39afe0417742f67711d12ef7b12b90df3d7d0725da5314bea767ae7d18a4434`;
  APK SHA-256 `4721a8486c516d94b5ff65ff8e1835492359a657c85463b1f276afefffebcbfa`.
  Paket `com.leventua.bilgirotasi`, versionCode `104`, versionName `1.68.14`,
  targetSdk 36; upload SHA-1 `00:0E:E4:3F:41:0A:BC:6B:4F:63:4C:4F:71:6D:76:EB:19:08:41:15`.
- Artifact Android 16 kanıtında `APK_INSTALL`, `APP_LAUNCH`, `APP_PID`,
  `APP_ACTIVITY`, `APP_LOGCAT`, `APP_GATE`, `RELEASE_GATE` = PASS; PID `1869`,
  MainActivity RESUMED/visible ve CI logunda Bilgi Rotası paketine ait
  crash/ANR/FATAL/process-death eşleşmesi yok.
- Fiziksel Google Play closed-test `1.68.15+105` kabulünde bildirim izni kabulü,
  foreground teslim, background teslim, terminated/swipe-away teslim ve
  bildirim dokunuşuyla normal açılış **PASS**. Uygulama içi duyuru anahtarı
  kapatıldıktan sonra closed-test topic mesajı gelmedi (**PASS**). Android sistem
  bildirim izni reddedildiğinde oyun normal çalışmaya devam etti (**PASS**).
  `Ayarlar → Eğitimi Yeniden Göster` fiziksel cihazda açılıp kapandı (**PASS**).
- Fiziksel ADB/logcat kabulü 15 Ağustos 2026'da **PASS**. İlk metadata ZIP'i
  `BilgiRotasi_Fiziksel_Logcat_20260815_215920.zip` Android 16 üzerinde gerçek
  Play closed-test `1.68.15+105` / versionCode 105 / targetSdk 36 kurulumunu
  doğruladı. Final kanıt ZIP'i `BilgiRotasi_FINAL_ADB_20260815_220727.zip`;
  SHA-256 `cd1930a7bbc55cd448815bb2662cfc5b2f9785a8d7001cd0bb736301ae3cbba7`.
- Final ADB penceresi `22:07:28 → 22:07:40`; `PID_START=14450` ve
  `PID_END=14450`. `ACTIVITY_START.txt` ve `ACTIVITY_END.txt` aynı
  `com.leventua.bilgirotasi/.MainActivity` kaydını `visible=true`,
  `visibleRequested=true` ve `topResumedActivity` olarak gösterir. Full logcat
  taramasında Bilgi Rotası için `FATAL EXCEPTION`, ANR/`am_anr`, `am_crash`,
  `am_proc_died`, native tombstone/signal veya beklenmeyen process-death kaydı
  yoktur. `PROCESS_EXIT_INFO.txt` test saatinde yeni uygulama çıkışı içermez;
  görülen tarihsel kayıtlar 14 Ağustos kullanıcı `REMOVE TASK` ve izin değişimi
  olaylarıdır. Ayrı PID `14546` üzerindeki Firebase Installations/Messaging
  hatası Samsung Game Launcher sürecine aittir, Bilgi Rotası sürecine değil.
- Public Analytics + FCM gizlilik açıklaması main tabanlı PR #40 ile squash merge
  edildi: `c7b3be9925344f3c8f6bc608a1f7d98a42c0a210`. GitHub Pages kaynağı `main:/docs`;
  build `1152991654` bu commit üzerinde **built** ve hata yok. Güncel destek adresi
  `BilgiRotasidestek@gmail.com` korunur.
