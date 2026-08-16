# Bilgi Rotası - Görev Havuzu

## 0F - 16 Ağustos 2026 Android 16 tutorial replay gate / PR #44

Bu bölüm aşağıdaki `0E` PR #43 ön-merge BR-P0-011 kaydının **güncel durumunu geçersiz kılar**; `0E` tarihsel denetim izi olarak korunur.

- **BR-P0-011 Durum:** PR #43 RELEASE'E MERGE EDİLDİ / POST-MERGE CLOSED TEST #9 TUTORIAL VALIDATOR SCOPE BUG NEDENİYLE FAIL / DRAFT PR #44 TEKNİK-HEAD CI #197 PASS / PROJE-HAFIZASI SONRASI FINAL PR-HEAD CI BEKLİYOR / PR #44 MERGE ONAYI BEKLİYOR / MERGE SONRASI FRESH CLOSED TEST PASS BEKLİYOR.
- Canlı hedef dal `release/final-closed-test-aab-1.68.8`; release HEAD `9371e0aecc4e677c24682e11a31d91ebed54f309`; sürüm `1.68.16+106`.
- PR #43 Levent'in açık onayıyla squash merge edildi; merge commit ve canlı release HEAD `9371e0aecc4e677c24682e11a31d91ebed54f309`.
- Fresh post-merge Closed Test #9 / run `31942307299`, job `95153144908` doğru release SHA üzerinde gerçek AAB üretti. RC1 gate ve ana uygulama kapıları geçti; final `APP_GATE=PASS`, `RELEASE_GATE=FAIL`, neden `SETTINGS_TUTORIAL_FAILED_WITHOUT_INFRASTRUCTURE_EVIDENCE`. Run #9 artifact ID `9262524277`, digest `sha256:1e558a0423b6243d7ded7849b72c7353726ea453e7d70ae4c225914e56df4e0a`; bu AAB Play adayı değildir.
- Kanıtlanan kök neden Bash dinamik scope çakışmasıdır: `retry_capture_screen()` içindeki local olmayan `attempt`, dış tutorial döngüsündeki aynı adlı sayacı değiştiriyor ve `_2.tsv` çekildikten sonra `_1.tsv` okunmasına yol açabiliyordu. OCR/parser ve uygulama davranışı kök neden değildir.
- Ayrı branch `fix/br-p0-011-android16-tutorial-gate`; Draft PR #44 açık. Commitler: `38a13c58b5e85e3e5798b6c4209dd449216e81b7` — ilk teşhis; `a6ce0ba08bce5d2454aaeb612f62a271d10e8f28` — `fix: isolate Android 16 tutorial retry counters`.
- Release tabanına göre teknik net diff yalnız `tools/validate_android16_closed_test.sh` + `test/android16_closed_test_retry_scope_test.dart`; helper retry sayacı local, tutorial döngüsü ayrı `tutorial_attempt`; gate koşulları gevşetilmedi. `assets/questions.json`, BoardMap, 67 node, oynanış, launcher/splash ve sürüm değiştirilmedi.
- PR #44 teknik-head AdMob PR doğrulaması #197 / run `31957410025`, job `95190026025`: **SUCCESS**. İlk Android 16 denemesi PASS, classifier PASS, ikinci emulator SKIPPED, final uygulama gate PASS.
- #197 artifact `BilgiRotasi-AdMob-1.68.16-106-kanitlari`: ID `9266476416`, digest `sha256:c9dd5c698b05dcaa263d5d2d592a5bb2f8e303628e1baca5de1a581090f4d242`; APK SHA-256 `67b148a2140e04835d5226148a27605e2416f38e3c3c20695f6d843bfb26500d`; `RESULT=PASS`, `APP_GATE=PASS`, `RELEASE_GATE=PASS`; paket `com.leventua.bilgirotasi`, versionCode 106, versionName 1.68.16, targetSdk 36; app-specific crash/ANR/FATAL/process-death yok.
- `KARARLAR.md` değişmedi; yeni ürün/teknik karar yok. PR #7'ye dokunulmadı. PR #44 merge'i ayrıca Levent'in açık onayını gerektirir.

**Bitti ölçütü:**

- [x] PR #43 final docs-head CI tam log/artifact/diff/Git geçmişiyle PASS.
- [x] PR #43 release dalına merge edildi; release HEAD `9371e0aecc4e677c24682e11a31d91ebed54f309`.
- [x] Merge sonrası fresh Closed Test #9 doğru release SHA üzerinde çalıştırıldı ve gerçek `1.68.16+106` AAB üretildi; final gate FAIL ayrıca kayıt altına alındı.
- [x] Run #9 tutorial replay failure kök nedeni gerçek artifact + validator kaynak + bağımsız Bash reprodüksiyonuyla dynamic-scope counter collision olarak kanıtlandı.
- [x] PR #44 minimal validator düzeltmesi ve gerçek Bash regresyon testiyle kök nedeni giderdi; Android 16 release gate gevşetilmedi.
- [x] PR #44 teknik-head CI #197 release APK + Android 16 `APP_GATE=PASS` / `RELEASE_GATE=PASS` / temiz app logcat kanıtıyla PASS.
- [ ] Bu proje-hafızası güncellemesi sonrası **yeni final PR #44 head CI** tam log/artifact/final diff/Git geçmişiyle PASS.
- [ ] Levent'in ayrıca açık onayı sonrası PR #44 release dalına merge edildi.
- [ ] PR #44 merge sonrası **yeni canlı release HEAD** üzerinde fresh `Closed test release doğrulaması` PASS ve gerçek `1.68.16+106` AAB artifact üretildi.
- [ ] Yalnız yukarıdaki fresh post-merge release gate PASS sonrası BR-P0-011 kapanır ve AAB Play Kapalı Test yükleme adayı sayılır.

---

## 0E - 16 Ağustos 2026 RC1 launcher quality gate / PR #43

- **BR-P0-011 Durum:** DRAFT PR #43 / TEKNİK HEAD CI PASS / LEVENT MERGE ONAYI VERDİ / FINAL DOCS-HEAD CI BEKLİYOR / POST-MERGE FRESH CLOSED TEST BEKLİYOR.
- Canlı hedef dal `release/final-closed-test-aab-1.68.8`; PR #43 taban SHA'sı `84d671735d371282f909ac45f6c42d2721ca9d63`; sürüm `1.68.16+106`.
- Fresh `Closed test release doğrulaması` #8 / run `31910656517`, AAB üretiminden önce RC1 kalite kapısında bayat `assets/branding/app_icon_foreground.png` zorunluluğuyla durdu. Güncel kanonik launcher kaynağı `assets/branding/app_icon.png`; launcher görseli/asset'i değiştirilmedi.
- Teknik commit `7d3166f3a4a2d8009e57af29065a442123a9ec79` — `fix: align RC1 launcher quality gate`; değişiklik yalnız `tools/rc1_quality_gate_impl.py` ve `test/launcher_icon_contract_test.dart` dosyalarında. `assets/questions.json`, BoardMap, 67 node, oynanış, splash ve sürüm değiştirilmedi.
- AdMob PR doğrulaması #194 / run `31912671944` / job `95079995092`: **SUCCESS**. `flutter analyze` temiz, tüm Flutter testleri PASS, release APK build PASS, Android 16 `APP_GATE=PASS` ve `RELEASE_GATE=PASS`, app-specific FATAL/ANR sayıları 0.
- #194 artifact `BilgiRotasi-AdMob-1.68.16-106-kanitlari`: ID `9249278155`, digest `sha256:d3f25a816c60f4b5f2245254b591e4aed7a7765be928b7a5ad5a59a445bdd7ff`; APK SHA-256 `1841b19e721cff440954478b12844194d816f24a2f7f14426ed19fbdb8f1a16e`.
- Tam workflow logu, artifact metadata'sı, PR diff'i ve Git geçmişi birlikte incelendi. PR teknik head'inde 1 commit / 2 dosya / 13 ekleme / 1 silme vardır.
- `KARARLAR.md` değişmedi; mevcut D-032 launcher kararı korunur.
- Levent 16 Ağustos 2026'da açık merge onayı verdi. Merge, bu proje-hafızası commit'i üzerindeki yeni PR-head CI tamamen PASS olmadan yapılmayacak.

**Bitti ölçütü:**

- [x] Fresh Closed Test #8 kök nedeni gerçek RC1 kalite kapısında bulundu; uygulama/launcher asset hatası olmadığı doğrulandı.
- [x] RC1 gate güncel `assets/branding/app_icon.png` sözleşmesine hizalandı ve kaldırılan ayrı foreground kaynağının yeniden zorunlu tutulması regresyon testiyle engellendi.
- [x] Teknik diff yalnız `tools/rc1_quality_gate_impl.py` + `test/launcher_icon_contract_test.dart`; `assets/questions.json` ve ürün davranışı değişmedi.
- [x] Teknik head analyze + tüm Flutter testleri + release APK + Android 16 APP_GATE/RELEASE_GATE/logcat kapıları PASS.
- [x] Levent açık merge onayı verdi.
- [ ] Proje-hafızası commit'i sonrası yeni final PR-head CI tam log/artifact/diff/Git geçmişiyle PASS.
- [ ] PR #43 release dalına merge edildi.
- [ ] Merge sonrası canlı release HEAD üzerinde yeni `Closed test release doğrulaması` PASS ve gerçek `1.68.16+106` AAB artifact'i üretildi.

---

## 0D - 15 Ağustos 2026 Issue #37 release kapanışı

Bu bölüm aşağıdaki tarihsel `BR-P0-010` satırlarını **güncel olarak geçersiz kılar**; eski kayıtlar denetim izi olarak korunur.

- **BR-P0-010 Durum:** TAMAMLANDI / PR #39 RELEASE'E SQUASH MERGE EDİLDİ / FİZİKSEL FCM + ADB/LOGCAT PASS / FINAL CI PASS.
- Levent açık merge onayı verdi; PR #39 merge commit'i ve güncel release HEAD `bb0897f5c8bff9f2257dd5dde437bcf732448914`.
- Final PR head `c343e68c5452b9bf7205e6fd0860ae16734073b3`; AdMob PR doğrulaması #190 / run `31903365510` / job `95057405310`: **SUCCESS**.
- Final artifact `BilgiRotasi-AdMob-1.68.14-104-kanitlari`: ID `9251835873`, digest `sha256:7f5c5d408f39452a1590317e45b9bcb033d98abf68c7019538e2ad07dd26ae8e`.
- Fiziksel Play closed-test `1.68.15+105` FCM izin kabul/red, foreground/background/terminated, tap, in-app disable sonrası no-delivery ve öğretici yeniden gösterme **PASS**.
- Fiziksel ADB/logcat final ZIP SHA-256 `cd1930a7bbc55cd448815bb2662cfc5b2f9785a8d7001cd0bb736301ae3cbba7`; PID başlangıç/son aynı, MainActivity visible/top-resumed, FATAL/ANR/crash/process-death yok.
- Public Analytics + FCM gizlilik/Pages PR #40 ile main'e merge edildi; Pages build `1152991654` **built**.
- Release sürümü `1.68.14+104`; production topic'e gerçek mesaj gönderilmedi ve production bildirimi ayrı Levent kararı gerektirir.
- GitHub Issue #37 metadata durumu bu docs-kapanış PR'ı hazırlanırken hâlâ OPEN; bu PR merge edildikten sonra issue ayrı işlemle `completed` kapatılacaktır.

**Bitti ölçütü:**

- [x] Analyze, tüm Flutter testleri ve push profil testleri PASS.
- [x] Release APK ve birleşik manifestte FCM SDK/izin/channel doğrulandı.
- [x] Android 16 APP_GATE/RELEASE_GATE PASS; CI app-specific hata yok.
- [x] Güncel Play closed-test fiziksel cihazında izin kabul/red doğrulandı.
- [x] Gerçek FCM foreground/background/terminated teslimi ve dokunma açılışı doğrulandı.
- [x] Uygulama içi kapatma sonrası closed-test mesajının gelmediği doğrulandı.
- [x] Ayarlar → Eğitimi Yeniden Göster fiziksel cihazda açılıp kapandı.
- [x] Fiziksel ADB/logcat crash/ANR/FATAL/process-death taraması PASS.
- [x] Levent açık onayı sonrası PR #39 release'e merge edildi.

---

## 0C - 14 Ağustos 2026 launcher icon / PR #38

- **Durum:** RELEASE'E MERGE EDİLDİ / CI PASS / FİZİKSEL LAUNCHER KURULUMU DOĞRULANACAK.
- PR #38 merge commit'i: `37f5ba0b1ea2cc5cfd97ff56beb6c31ba55d33b8`.
- Onaylanan 512x512 PNG kaynak SHA-256: `32f9d4144fa5112afd93999fd4b6df3734493f626cc8e96f9b0be1510b9368fa`; repo kaynağıyla birebir eşleşir.
- Legacy ve adaptive Android ikonları yeniden üretildi; `%18` adaptive inset ile yazı/pusula güvenli alanda tutuldu; splash değiştirilmedi.
- Yerel analyze PASS, hedefli test PASS, tüm Flutter testleri `257/257` PASS, diff check PASS.
- PR CI #161 / run `31757717142`, job `94637088436`: SUCCESS; artifact ID `9203624785`, digest `sha256:88a709a875c02d28844bdbfd69c8669acc009ca5846d07e4bb51d9828a908b18`.
- APK SHA-256 `792a0db0d812acaaaa0e504d1abc61915f020e3bc9f3ec6592bbcc9a3f4ee673`; Android 16 APP_GATE/RELEASE_GATE PASS; app-specific crash/ANR/FATAL/process-death yok.
- APK içindeki gerçek legacy/adaptive launcher varlıkları görsel olarak doğrulandı.
- Bitti ölçütünde kalan tek kabul: Play kurulumunu silmeden uyumlu imzalı build ile fiziksel Android launcher ekranı doğrulaması.

---

## BR-P0-010 - Issue #37 Firebase genel duyuru altyapısı

**Durum:** DRAFT PR #39 / KOD-HEAD CI PASS / FİZİKSEL FCM + ADB/LOGCAT KABULÜ PASS / MERGE KARARI BEKLİYOR

- Ayrı dal `feat/push-notifications-issue-37`; PR #39 Draft/açık ve release/main'e
  merge edilmemiştir. Güncel PR head'i canlı GitHub metadata'sından doğrulanır.
- FCM bağımlılığı, Android 13+ izin akışı, notification channel,
  foreground/background/terminated davranışı ve güvenli normal açılış uygulanmıştır.
- Topic migration sertleştirildi: ortam değişiminde diğer bilinen topic'ler
  temizlenir; cleanup hatası token reset ile izole edilir, tamamlanamazsa kalıcı
  pending-cleanup kaydı sonraki açılışta retry edilir. Yeni ortama güvenli
  temizlik olmadan abone olunmaz.
- `PUSH_ENVIRONMENT` override'ı build profilini genişletemez; AdMob + Firebase
  profiliyle uyuşmazlık `test` ortamına fail-closed düşer.
- Kod commit'leri: `c7f8227` — `fix: harden push environment isolation` ve
  `5c13762` — `test: keep push profile validation isolated`.
- İlk CI run `31805647373` mevcut backend hardening sözleşmesi nedeniyle FAIL;
  sözleşme gevşetilmeden düzeltildi. Final kod-head AdMob PR doğrulaması #169,
  run `31806178473`, job `94785535777`: **SUCCESS**.
- Final artifact ID `9221592169`, digest
  `sha256:a39afe0417742f67711d12ef7b12b90df3d7d0725da5314bea767ae7d18a4434`;
  APK SHA-256 `4721a8486c516d94b5ff65ff8e1835492359a657c85463b1f276afefffebcbfa`.
  Android 16 `APP_GATE`/`RELEASE_GATE` PASS ve CI app-specific crash taraması temiz.
- Fiziksel Play closed-test `1.68.15+105`: izin kabul/red, foreground,
  background, terminated, bildirim tap ile normal açılış, uygulama içi kapatma
  sonrası no-delivery ve Ayarlar öğretici yeniden gösterme **PASS**.
