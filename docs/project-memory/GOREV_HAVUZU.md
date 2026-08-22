# Bilgi Rotası - Görev Havuzu

## 0N - 22 Ağustos 2026 / PR #96 Kelime Avı gece doğrulaması

- **Durum:** TEKNİK DOĞRULAMA PASS / PR #96 AÇIK + DRAFT / MERGE YOK / GÖRSEL NİHAİ KULLANICI KABULÜ AÇIK.
- Branch `feat/kelime-avi-clean-release-integration-20260821`; doğrulanan kaynak head `8b4022d939153f88f14c765a61a0962ba0473769`; base canlı head `39c03f169bbdf5dabb207af95c1fccf365400f98`; sürüm `1.68.19+109`.

**Bitti ölçütü:**
- [x] Geçici background transfer parçaları ve materializer workflow final diff'ten temiz.
- [x] JPEG `1080x2340` / `81310` byte / SHA-256 `ea0034e2b3a7713f36bd36d2757815748e2988e831c91f213ad0c7a2eb050d45`.
- [x] Kelime Avı kaynak analizi 0 issue; focused testler 59/59 PASS.
- [x] Linux tam kalite run/job `32543598848` / `96958050560`: 360/360 Flutter PASS; mevcut 92 analyze issue, yeni Kelime Avı issue'su yok.
- [x] Android 16 run/job `32543597270` / `96958047145`: gerçek ekran, packaged asset/runtime load, Activity ve app logcat kapıları PASS.
- [x] Artifact ID `9467915888`, digest `sha256:4c9d2e22a3dc26459b3639db6781b5cb08056366c4f30592da0ac3c4b7b4d696`; üst/alt screenshot saklandı.
- [x] `assets/questions.json`, `lib/main.dart`, BoardMap/67 node, 3B tahta ve release/AdMob/Firebase/Android config kapsam dışı kaldı.
- [ ] Levent artifact screenshot'larını görsel olarak nihai kabul eder veya geri bildirim verir.
- [ ] Ayrı açık onay ve ayrı entegrasyon işi olmadan Kelime Avı production `lib/main.dart` navigasyonuna bağlanmaz.
- [ ] Levent açık merge onayı olmadan PR #96 merge edilmez veya Draft'tan çıkarılmaz.

---

## 0M - 21 Ağustos 2026 / 1.68.19+109 merge ve yayın kapıları

- **Durum:** PR #88 MERGED / release `b0240a7a4009c41326f459a37b8bedeab080d8d8` / `1.68.19+109` / +108 soru bankası korundu / UMP-AdMob + SSV tek gerçek +10 XP PASS / Play yükleme açık.

**Bitti ölçütü:**
- [x] Exact +108 tabanı ve soru bankası koruması doğrulandı.
- [x] Fiziksel banner + rewarded PASS.
- [x] AdMob Verify URL, SSV selective redeploy, açık cutover/readback ve gerçek +10 XP PASS.
- [x] Pre-commit 42/42 focused, 301/301 tüm Flutter, analyze/diff PASS.
- [x] PR #88 exact-head CI, signing/package/manifest ve Android 16 app gate PASS.
- [x] Levent açık merge onayı ve expected-head squash merge PASS.
- [ ] Aynı `gameId` fiziksel no-double PASS.
- [ ] Yarım/başarısız reklam ödül vermez; hak korunur ve retry PASS.
- [ ] Farklı tamamlanan oyunlarda günlük/oturumluk toplam kota yok — fiziksel PASS.
- [ ] Exact merge SHA'dan production `1.68.19+109` AAB; package/version/signing/production AdMob+Firebase profil doğrulaması.
- [ ] Doğrulanmış +109 AAB Play Console upload/install/rollout kabulü.

Kanıt: ürün head `1999a049018b5d23eeda59b0b9d2e0e435cf0a64`; merge `b0240a7a4009c41326f459a37b8bedeab080d8d8`; run/job `32481746889` / `96769404446`; artifact ID `9446694140`; APK SHA `0b9cf5e0b3a9568ea4424818cb4162f677bab3ade4fd214e6dc4d6bcdcefb376`.

---

## 0K - 19 Ağustos 2026 Issue #67 / PR #69 SSV percent-encoding merge checkpoint

Bu bölüm aşağıdaki `0J` içindeki PR #68 ön-merge durumunu **güncel görev durumu açısından geçersiz kılar**; eski bölüm tarihsel denetim izi olarak korunur.

- **Durum:** PR #68 MERGED / VERIFY-ONLY KODU RELEASE'TE / ADMOB VERIFY URL İLK CANLI DENEME 400 → PERCENT-ENCODING KÖK NEDENİ DOĞRULANDI / PR #69 EXACT-HEAD CI PASS + SQUASH MERGED / CALLBACK REDEPLOY YAPILMADI / `ssvEnabled` KAPALI / PLAY + FİZİKSEL KABUL AÇIK.
- Kanonik release: `release/final-closed-test-aab-1.68.8` / `fe293d87a33772ff9fa65de829ed59d40a263eca` / `1.68.17+107`.
- PR #69 branch `fix/ssv-percent-decoded-signature-20260819`; final head `a01f1d19c6ce40ebec1b9c83ab4ed672f65c8cb7`; merge commit `fe293d87a33772ff9fa65de829ed59d40a263eca`.
- Kök neden: AdMob canlı callback query'sinde `reward_item=%C3%96d%C3%BCl`; Google referans doğrulayıcısı query'yi percent-decode ederken Express `originalUrl` encoded biçimi koruyordu ve ECDSA imza içeriği farklılaşıyordu.
- Düzeltme yalnız `functions/rewarded_ssv.js` + `functions/test/rewarded_ssv.test.js`: query sırası korunarak `signature` öncesi bölüm `decodeURIComponent` ile çözülür; bozuk percent-encoding `invalid-query-encoding` ile fail-closed. Gerçek callback biçimi ve bozuk encoding regresyonu kanonik suite'e eklendi.
- Final exact-head Firebase güvenlik doğrulaması run `32222981893`: SUCCESS; Functions **43/43**, Firestore Rules emulator **6/6** PASS. Final exact-head AdMob PR doğrulaması run `32222981901`: SUCCESS. Tam log + workflow + diff + Git geçmişi birlikte incelendi.
- Levent'in mevcut koşullu merge onayı altında PR #69 review-ready yapıldı; head ve release tabanı yeniden kilitlendikten sonra expected-head SHA ile squash merge edildi.
- Merge sonrası release ile `fe293d87...` karşılaştırması `identical`; `pubspec.yaml` hâlâ `1.68.17+107`.
- Issue #67 merge checkpoint comment `5340502656`.
- Google Play Integrity API'nin Google Cloud Console'da `Enabled` olduğu Levent'in canlı ekran kanıtıyla doğrulandı; Play App Signing/Upload SHA rolleri ayrıca Play Console'dan doğrulanacak.
- Bu adımda production callback redeploy yapılmadı; `ssvEnabled` açılmadı/değişmedi; blanket Functions deploy yapılmadı. Yeni percent-decoding davranışı canlı callback'te henüz kanıtlanmış değildir.
- `KARARLAR.md` değişmedi; ödül ürün sözleşmesi değişmedi.

**Bitti ölçütü:**

- [x] PR #68 verify-only handshake release'e merge edildi.
- [x] AdMob `Verify URL` ilk canlı `HTTP 400` hatasının request biçimi/log kanıtı toplandı ve percent-encoding kök nedeni source + Google referans semantiğiyle doğrulandı.
- [x] PR #69 minimum düzeltme ve gerçek callback regresyon testiyle hazırlandı; bozuk encoding fail-closed kilitlendi.
- [x] PR #69 final exact-head Firebase CI: Functions `43/43` + Rules `6/6` PASS; AdMob CI SUCCESS.
- [x] Levent'in koşullu merge onayı altında PR #69 expected-head kilidiyle squash merge edildi.
- [x] Merge sonrası release HEAD `fe293d87a33772ff9fa65de829ed59d40a263eca`, sürüm `1.68.17+107` olarak doğrulandı.
- [x] Issue #67 uzak checkpoint'i merge sonucu ve güvenlik sınırlarıyla güncellendi.
- [ ] Mevcut yetkili Firebase production execution kanalında yalnız `rewardedSsvCallback` selective redeploy edilir; yeni deploy yolu tahmin edilmez, blanket Functions deploy yapılmaz.
- [ ] Redeploy sonrası normal callback yine `503 SSV_NOT_ENABLED` döner.
- [ ] Legacy AdMob rewarded biriminde `Verify URL` yeniden denenir; `200 SSV_VERIFY_OK` ve verify-only sırasında Firestore write yok kanıtlanır.
- [ ] Play Console'da App Signing SHA-1 / Upload SHA-1 rolleri, versionCode 107 ve production/public listing durumu canlı doğrulanır.
- [ ] Fiziksel gerçek rewarded: tek gameId tek +10, no-double, yarım/başarısız reklamda hak korunur, farklı oyunlarda toplam kota yok.
- [ ] İki cihaz/hesapla Canlı Düello eşleşme → maç → sonuç → leaderboard zinciri PASS.
- [ ] Yalnız bütün canlı kapılar ve ayrıca açık cutover onayı sonrası `server_config/rewarded.ssvEnabled=true` değerlendirilir.

---

## 0J - 19 Ağustos 2026 Issue #67 production SSV canlı cutover

- **Durum:** 3 SSV FUNCTION SELECTIVE DEPLOY PASS / FAIL-CLOSED 503 PASS / VERIFY URL BLOKAJI İÇİN DRAFT PR #68 / FIREBASE CI PASS / ADMOB FINAL CI BEKLİYOR / MERGE-REDEPLOY-CUTOVER YOK.
- Kanonik release başlangıcı: `release/final-closed-test-aab-1.68.8` / `7cf17591ba12cbb422c0e2e34609795546258784` / `1.68.17+107`.
- Legacy production AdMob App ID/banner/rewarded ID'leri canlı Console'da repo ile birebir eşleşti; yeni duplicate AdMob hesabı kullanılmayacak.
- Firebase canlı envanteri doğrulandı: Google Auth etkin, Android SHA listesi mevcut, Play Integrity provider kayıtlı, App Check enforcement kapalı/Monitoring, üç composite index `Enabled`; hardened repo Firestore Rules henüz canlıya cutover edilmedi.
- Levent'in açık production deploy onayıyla yalnız `issueRewardNonce`, `getRewardedGameState`, `rewardedSsvCallback` `bilgi-rotasi-f255d/europe-west1` hattına deploy edildi; mevcut 7 Function korundu. `server_config/rewarded` ve `ssvEnabled` oluşturulmadı.
- Canlı callback probe `HTTP 503` + `SSV_NOT_ENABLED` ile fail-closed PASS.
- AdMob `Verify URL` başarılı yanıt ihtiyacı ile disabled callback'in 503 kapısı çakıştığı için ayrı branch `fix/ssv-verify-url-handshake-20260819` açıldı; Draft PR #68.
- Teknik commitler: `94a7d883ebff0b857b3bdd2335c10fd7ee65b8c6` — `fix: allow signed AdMob SSV URL verification`; `d7e015533d94be21768554c19266830d5fadc035` — `test: run SSV verify handshake in canonical suite`.
- Verify-only yol yalnız `user_id=bilgi-rotasi-ssv-verify` + `custom_data=bilgi-rotasi-ssv-verify-v1` birlikte geldiğinde çalışır; Google ECDSA imzası zorunludur, geçerli istekte `200 SSV_VERIFY_OK` döner ve hiçbir nonce/claim/transaction/XP yazımı yapmaz. Normal disabled callback `503 SSV_NOT_ENABLED` olarak kalır.
- Firebase güvenlik run `32197564562`: SUCCESS; Functions `42/42`, Firestore Rules emulator `6/6` PASS. İlk ayrı test dosyasının `npm test` explicit listesine girmediği CI logundan yakalandı; testler kanonik `rewarded_ssv.test.js` içine taşındı ve gerçek suite içinde PASS olduğu doğrulandı.
- Doküman commitleri aynı PR branch'inde ilerler; `KARARLAR.md` değişmez çünkü ürün ödül sözleşmesi değişmedi, yalnız güvenli AdMob doğrulama handshake'i uygulandı.

**Bitti ölçütü:**

- [x] Legacy production AdMob App ID/banner/rewarded ID repo ile canlıda eşleşti.
- [x] Firebase Auth/SHA/Functions/Indexes/App Check canlı envanteri toplandı; Rules cutover'ın ayrı olduğu kaydedildi.
- [x] Levent açık onayı sonrası yalnız üç SSV Function selective deploy edildi; diğer Function'lar korunuyor.
- [x] `ssvEnabled` eksik/kapalıyken canlı callback `503 SSV_NOT_ENABLED` PASS.
- [x] Verify-only düzeltme ayrı branch/Draft PR ile hazırlandı ve normal fail-closed davranış regresyon testiyle kilitlendi.
- [x] Firebase güvenlik CI final teknik head'de Functions `42/42` + Rules `6/6` PASS.
- [ ] PR #68 docs-head AdMob PR doğrulaması tam log/artifact/Android 16 kapılarıyla SUCCESS.
- [ ] Levent ayrıca açık merge onayı verir; PR #68 release'e merge edilir.
- [ ] Merge sonrası güncel release HEAD kilitlenir ve yalnız güncellenmiş `rewardedSsvCallback` production redeploy'u ayrıca açık Levent onayıyla yapılır.
- [ ] Redeploy sonrası normal callback yine `503 SSV_NOT_ENABLED`; AdMob Verify URL test User ID/custom data ile PASS ve verify-only sırasında Firestore write yok.
- [ ] Fiziksel gerçek rewarded: tek gameId tek +10, no-double, yarım/başarısız reklamda hak korunur, farklı oyunlarda toplam kota yok.
- [ ] Play versionCode/signing/public listing ve iki cihaz Canlı Düello canlı kabulü tamamlanır.
- [ ] Yalnız tüm kapılar ve ayrıca açık cutover onayı sonrası `ssvEnabled=true` değerlendirilir.

---

## 0I - 18 Ağustos 2026 Issue #64 production-readiness kapanış adayı

- **Durum:** DRAFT PR #65 / KOD VE YEREL TESTLER PASS / EXACT RELEASE CLOSED TEST #14 SUCCESS / DOCS-HEAD CI SUCCESS / DEPLOY VE MERGE YOK.
- Başlangıç release: `05b8882dbcc1e9ffbb59350239d366ee66fd3950`, `1.68.17+107`; branch `fix/final-production-readiness-20260818`; kod commit'i `8b8913548c208e94a9deacacacabf7d4d6a26be4`.
- Günlük login XP sıfırlandı; streak ve eski state migration'ı korunup dört regresyon senaryosuyla kilitlendi.
- PR #63 rewarded/SSV sözleşmesi ve public-key imza doğrulaması testlerle kilitlendi; oyun-başına idempotency korunur ve günlük/oturumluk kota yoktur.
- Production deploy planı yalnız üç SSV endpoint'ini explicit proje/bölge ile seçer. Credential değerleri repoya yazılmadı; deploy ve `ssvEnabled` açılışı yapılmadı.
- Fresh run #13 / `32170570288` OCR hazırlığında 60 dakikayı aşarak artifactsız iptal edildi. Aynı exact release SHA üzerinde yeni run #14 / `32176210749`, job `95838654578`: SUCCESS; artifact ID `9339668986`, digest `sha256:b021e611e071ea3a105607b3ff427ac3a5c67b13603770951572ab12e10b6b32`, AAB SHA-256 `fb8d94867f4890c22ddcc62bdd7f361c8ca9efd9807e5c952bd99fab158944ad`.
- Run #14 AAB/package/version/targetSdk/upload SHA/readiness PASS. Android 16 `APP_GATE=PASS`, `RELEASE_GATE=PASS`, uygulama paketinde crash/ANR/FATAL/process-death 0. Gate sonrası Ayarlar/öğretici tanısı sistem ANR/global input nedeniyle `INFRASTRUCTURE_INCONCLUSIVE`; fiziksel Play kabulü açık kalır.
- PR #65 docs-head `5f7b28475aea2fc0789e4954d5907a2f28273e3a`: AdMob run `32178111832` / job `95844597170` ve Firebase güvenlik run `32178111912` SUCCESS. AdMob artifact ID `9340171407`, digest `sha256:2e12636945044911e9b730e54c159e8f470cf62c94b91c3cf92a4f746249c317`, APK SHA-256 `12f1339fd6ebfa0186711d0385d84c73a951781e54d0ce1e5a46638bdf654e88`, Android 16 `RESULT/APP_GATE/RELEASE_GATE=PASS`. Güncel PR head/check sonucu canlı GitHub metadata'sından okunur.

**Bitti ölçütü:**

- [x] Login XP = 0; streak ve eski state uyumluluğu testli.
- [x] Rewarded/SSV gameId idempotency, kotasız farklı oyunlar, misafir/joker ayrımı ve reklamsız aktif maç ekranları repo testleriyle doğrulandı.
- [x] Flutter `295/295`, Functions `40/40`, Rules emulator `6/6`, hedefli Flutter `25/25`, non-fatal analyze ve diff check PASS.
- [x] Güvenli/selective production SSV deploy planı hazır; deploy/config açılışı yapılmadı.
- [x] Fresh run #14 tam log + artifact + AAB SHA + Android 16 APP/RELEASE gate ile PASS; Ayarlar/öğretici fiziksel kabulü altyapı tanısı nedeniyle açık.
- [x] Draft PR #65 docs-head AdMob/Firebase CI tam log/artifact/diff/geçmiş incelemesiyle PASS; güncel head kontrolleri canlı GitHub metadata'sından doğrulanır.
- [ ] Play/Firebase canlı konsol ve fiziksel cihaz maddeleri aşağıdaki açık doğrulama listesiyle kanıtlanır.
- [ ] Levent ayrı açık merge onayı verir; bu PR kendi kendine merge edilmez.

---

## 0H - 18 Ağustos 2026 PR #60 / `1.68.17+107` merge ve yayın kapısı

Bu bölüm aşağıdaki `0G` ve daha eski kesimlerdeki canlı release HEAD/sürüm kayıtlarını **güncel durum açısından geçersiz kılar**; eski bölümler tarihsel denetim izi olarak korunur.

- **Yayın +107 durumu:** PR #60 LEVENT'İN AÇIK ONAYIYLA SQUASH MERGE EDİLDİ / CANLI RELEASE `1.68.17+107` / POST-MERGE FRESH CLOSED TEST RELEASE DOĞRULAMASI BEKLİYOR / PRODUCTION AAB HENÜZ YAYIN ADAYI SAYILMIYOR.
- Canlı yayın dalı: `release/final-closed-test-aab-1.68.8`.
- PR #60 final head: `8254a0b55664f5d50983ab8b3c534580d9f92672`; son commit `fix: sync app build info to 1.68.17+107`.
- PR #60 exact-head AdMob PR doğrulaması #248 / run `32105875494`: **SUCCESS**. Analyze + tüm testler, kalıcı imzalı release APK, package/manifest doğrulaması ve Android 16 / API 36 cold-start uygulama kapısı PASS.
- Final diff yalnız `pubspec.yaml` ve `lib/app_build_info.dart` sürüm senkronizasyonudur: `1.68.16+106` → `1.68.17+107`. Ürün davranışı, `assets/questions.json`, Canlı Düello, Firebase/AdMob backend, signing, BoardMap/67 node ve 3B tahta değişmedi.
- Levent 18 Ağustos 2026'da açıkça `Merge et` onayı verdi; PR #60 squash merge edildi.
- Merge commit / güncel release HEAD: `03df0a925cc3a0515f86d11e817da619172703fe` — `chore: prepare closed-test 1.68.17+107 (#60)`.
- Merge sonrası canlı `pubspec.yaml` sürümü GitHub'dan yeniden okundu: **`1.68.17+107`**.
- **DOĞRULANACAK:** merge commit `03df0a9...` üzerinde fresh `Closed test release doğrulaması` çalıştırılıp tam log, workflow, artifact ve AAB metadata/hash birlikte incelenecek. Bu kanıt alınmadan +107 AAB final Play adayı veya production artifact'i sayılmayacak.
- Production yayına erişim onayının gelmiş olması teknik kapıları atlama yetkisi değildir; production AdMob/Firebase profilli AAB üretimi ve Play yüklemesi ayrı kontrollü görevdir.
- `KARARLAR.md` değişmedi; yeni ürün/teknik karar alınmadı.

**Bitti ölçütü:**

- [x] PR #60 final diff yalnız iki sürüm metadata dosyası olarak doğrulandı.
- [x] Exact-head CI #248 tam PASS.
- [x] Levent açık merge onayı verdi.
- [x] PR #60 exact head kilidiyle squash merge edildi.
- [x] Canlı release `pubspec.yaml` = `1.68.17+107` olarak yeniden doğrulandı.
- [ ] Merge sonrası fresh `Closed test release doğrulaması` doğru release HEAD üzerinde SUCCESS.
- [ ] Fresh artifact içindeki AAB, release-readiness, Android 16 gate ve hash/metadata birlikte PASS.
- [ ] Yalnız bu kanıttan sonra production AAB hazırlığı/yükleme adımı ayrıca yürütülür.

---

## 0G - 16 Ağustos 2026 PR #44 final doğrulama durumu

Bu bölüm aşağıdaki `0F` Android 16 tutorial replay kaydının **güncel durumunu geçersiz kılar**; `0F` ve daha eski bölümler tarihsel denetim izi olarak korunur.

- **BR-P0-011 Durum:** PR #43 RELEASE'E MERGE EDİLDİ / FRESH CLOSED TEST #9 TUTORIAL VALIDATOR SCOPE BUG NEDENİYLE FAIL / DRAFT PR #44 MİNİMUM DÜZELTME + REGRESYON TESTİ HAZIR / TEKNİK-HEAD CI #197 PASS / FINAL DOĞRULANMIŞ HEAD CI #201 PASS / PROJE HAFIZASI GÜNCELLENDİ / MERGE ONAYI BEKLİYOR / MERGE SONRASI FRESH CLOSED TEST PASS BEKLİYOR.
- Canlı release: `release/final-closed-test-aab-1.68.8` / `9371e0aecc4e677c24682e11a31d91ebed54f309` / `1.68.16+106`.
- Fresh Closed Test #9 / run `31942307299`, job `95153144908`: `APP_GATE=PASS`, final `RELEASE_GATE=FAIL`, `REASON=SETTINGS_TUTORIAL_FAILED_WITHOUT_INFRASTRUCTURE_EVIDENCE`. Run #9 artifact ID `9262524277`, digest `sha256:1e558a0423b6243d7ded7849b72c7353726ea453e7d70ae4c225914e56df4e0a`; bu AAB Play adayı değildir.
- İlk açık validator hata mesajı `Settings/tutorial diagnostic failed without emulator infrastructure evidence.` oldu. Artifact'ta `UI_SETTINGS_TUTORIAL_2.tsv` içinde `Yeniden` kontrolü görünür olduğu halde tutorial dialog/closed kanıtı oluşmadı; app crash/ANR/FATAL/process-death veya emulator-unhealthy kanıtı yoktur.
- Kök neden: `retry_capture_screen()` içindeki local olmayan `attempt`, Bash dinamik kapsamıyla dış tutorial döngüsündeki aynı sayacı değiştiriyordu; doğru `_2.tsv` çekildikten sonra yanlış label okunabiliyordu. OCR/parser veya ürün davranışı kök neden değildir.
- PR #44 branch `fix/br-p0-011-android16-tutorial-gate`; teknik net diff yalnız `tools/validate_android16_closed_test.sh` + `test/android16_closed_test_retry_scope_test.dart`. Helper sayacı `local attempt`, tutorial döngüsü ayrı `tutorial_attempt`; gerçek Bash regresyon testi caller sayacının korunmasını kilitliyor. Mandatory release gate ve D-032 infra/app sınıflandırması gevşetilmedi.
- Teknik commitler: `38a13c58b5e85e3e5798b6c4209dd449216e81b7` — `fix: make Android 16 tutorial replay gate deterministic`; `a6ce0ba08bce5d2454aaeb612f62a271d10e8f28` — `fix: isolate Android 16 tutorial retry counters`.
- Teknik-head AdMob PR doğrulaması #197 / run `31957410025`, job `95190026025`: **SUCCESS**. Son doğrulanan proje-hafızası head'i `c5595c0aa38e7c1458e268061563943d38e79a37` üzerinde AdMob PR doğrulaması #201 / run `31962756913`, job `95203168990`: **SUCCESS**; analyze+tüm testler, release APK, paket/manifest, Android 16 attempt/classifier/final app gate PASS; ikinci emulator gerekmedi.
- #201 artifact `BilgiRotasi-AdMob-1.68.16-106-kanitlari`: ID `9267811261`, digest `sha256:23750143b62cd7de04d77a24d223626a475d89e871550ff81266f66bc4963443`; APK SHA-256 `cf807552ac1b1a239988d99f5e78125a76722681410b25bb6b8a5cf7cbc2a973`; `RESULT=PASS`, `APP_GATE=PASS`, `RELEASE_GATE=PASS`; app-specific crash/ANR/FATAL/process-death yok.
- Proje-hafızası güncellemeleri runtime davranışını değiştirmez. Bu belgeyi taşıyan güncel PR head'inin CI sonucu GitHub'dan canlı okunur; statik “son docs-head CI SHA” kaydı bitti ölçütüne dönüştürülmez.
- Sürüm, `assets/questions.json`, BoardMap, 67 node, 3B tahta, launcher/splash, Firebase/AdMob/FCM ürün davranışı değişmedi. `KARARLAR.md` değişmedi. PR #7'ye dokunulmadı.

**Bitti ölçütü:**

- [x] PR #43 release'e merge edildi ve merge sonrası fresh Closed Test #9 doğru release SHA üzerinde çalıştırıldı.
- [x] Run #9 ilk kesin hata mesajı, artifact ekran/OCR kanıtı ve validator source birlikte incelendi.
- [x] Run #9 kök nedeni Bash retry scope çakışması olarak kanıtlandı.
- [x] PR #44 minimum validator düzeltmesi + gerçek Bash regresyon testiyle kök nedeni giderdi; release gate gevşetilmedi.
- [x] PR #44 teknik-head CI #197 `APP_GATE=PASS` / `RELEASE_GATE=PASS`.
- [x] Son doğrulanan PR head CI #201 analyze+tüm testler+release APK+Android 16 final gate ile PASS.
- [x] `BILGI_ROTASI_DURUM.md` ve `GOREV_HAVUZU.md` güncel Run #9 / PR #44 kanıtlarıyla aynı branch üzerinde güncellendi; yeni ürün/teknik karar olmadığı için `KARARLAR.md` değişmedi.
- [ ] Levent'in ayrıca açık merge onayı verildi.
- [ ] PR #44 release dalına merge edildi.
- [ ] Merge sonrası yeni canlı release HEAD üzerinde fresh `Closed test release doğrulaması` PASS ve gerçek `1.68.16+106` AAB artifact üretildi.
- [ ] Yalnız fresh post-merge release gate PASS sonrası BR-P0-011 kapanır ve AAB Play Kapalı Test yükleme adayı sayılır.

---

## 0F - 16 Ağustos 2026 Android 16 tutorial replay gate / PR #44

Bu bölüm aşağıdaki `0E` PR #43 ön-merge BR-P0-011 kaydının **güncel durumunu geçersiz kılar**; `0E` tarihsel denetim izi olarak korunur.

- **BR-P0-011 Durum:** PR #43 RELEASE'E MERGE EDİLDİ / POST-MERGE CLOSED TEST #9 TUTORIAL VALIDATOR SCOPE BUG NEDENİYLE FAIL / DRAFT PR #44 TEKNİK-HEAD CI #197 PASS / PROJE-HAFIZASI SONRASI FINAL PR-HEAD CI BEKLİYOR / MERGE ONAYI BEKLİYOR / MERGE SONRASI FRESH CLOSED TEST PASS BEKLİYOR.
- Canlı release: `release/final-closed-test-aab-1.68.8` / `9371e0aecc4e677c24682e11a31d91ebed54f309` / `1.68.16+106`.
- PR #43 Levent'in açık onayıyla release'e merge edildi. Fresh post-merge Closed Test #9 / run `31942307299`, job `95153144908` doğru release SHA üzerinde gerçek AAB üretti; `APP_GATE=PASS`, final `RELEASE_GATE=FAIL`, neden `SETTINGS_TUTORIAL_FAILED_WITHOUT_INFRASTRUCTURE_EVIDENCE`. Artifact ID `9262524277`, digest `sha256:1e558a0423b6243d7ded7849b72c7353726ea453e7d70ae4c225914e56df4e0a`; bu AAB Play adayı değildir.
- Kök neden kanıtlandı: `retry_capture_screen()` içindeki local olmayan `attempt`, Bash dinamik kapsamı nedeniyle dış tutorial döngüsündeki aynı sayacı değiştiriyordu; `_2.tsv` doğru çekildiği halde `_1.tsv` okunabiliyordu. OCR/parser veya uygulama davranışı kök neden değildir.
- PR #44 branch `fix/br-p0-011-android16-tutorial-gate`; teknik net diff yalnız `tools/validate_android16_closed_test.sh` + `test/android16_closed_test_retry_scope_test.dart`. Helper retry sayacı local, tutorial döngüsü ayrı `tutorial_attempt`; mandatory gate koşulları gevşetilmedi.
- Teknik commitler: `38a13c58b5e85e3e5798b6c4209dd449216e81b7` ve kök neden düzeltmesi `a6ce0ba08bce5d2454aaeb612f62a271d10e8f28` — `fix: isolate Android 16 tutorial retry counters`.
- PR #44 teknik-head AdMob PR doğrulaması #197 / run `31957410025`, job `95190026025`: **SUCCESS**. Artifact ID `9266476416`, digest `sha256:c9dd5c698b05dcaa263d5d2d592a5bb2f8e303628e1baca5de1a581090f4d242`; APK SHA-256 `67b148a2140e04835d5226148a27605e2416f38e3c3c20695f6d843bfb26500d`; `RESULT=PASS`, `APP_GATE=PASS`, `RELEASE_GATE=PASS`; paket `com.leventua.bilgirotasi`, versionCode 106, versionName 1.68.16, targetSdk 36; app-specific crash/ANR/FATAL/process-death yok.
- Sürüm, ürün davranışı, `assets/questions.json`, BoardMap, 67 node, 3B tahta, launcher/splash, Firebase/AdMob/FCM davranışı değişmedi. `KARARLAR.md` değişmedi. PR #7'ye dokunulmadı.

**Bitti ölçütü:**

- [x] PR #43 final docs-head CI PASS ve PR #43 release'e merge edildi.
- [x] Merge sonrası fresh Closed Test #9 doğru release SHA üzerinde çalıştırıldı; AAB üretildi ve final tutorial gate FAIL ayrıca kaydedildi.
- [x] Run #9 kök nedeni artifact + validator kaynak + Bash scope davranışıyla kanıtlandı.
- [x] PR #44 minimal validator düzeltmesi ve gerçek Bash regresyon testiyle kök nedeni giderdi; release gate gevşetilmedi.
- [x] PR #44 teknik-head CI #197 Android 16 `APP_GATE=PASS` / `RELEASE_GATE=PASS` ve temiz app logcat kanıtıyla PASS.
- [ ] Bu proje-hafızası güncellemesi sonrası yeni final PR #44 head CI tam log/artifact/final diff/Git geçmişiyle PASS.
- [ ] Levent'in ayrıca açık onayı sonrası PR #44 release'e merge edildi.
- [ ] PR #44 merge sonrası yeni canlı release HEAD üzerinde fresh `Closed test release doğrulaması` PASS ve gerçek `1.68.16+106` AAB artifact üretildi.
- [ ] Yalnız fresh post-merge release gate PASS sonrası BR-P0-011 kapanır ve AAB Play Kapalı Test yükleme adayı sayılır.

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
- Final PR head `c343e68c5452b9bf7205e6fd0860ae16734073b3`; AdMob PR doğrulaması #190 / run `31903365510`, job `95057405310`: **SUCCESS**.
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
- Fiziksel ADB/logcat kabulü **PASS**: Android 16 / Play closed-test
  `1.68.15+105`; final ZIP SHA-256
  `cd1930a7bbc55cd448815bb2662cfc5b2f9785a8d7001cd0bb736301ae3cbba7`;
  başlangıç/son PID `14450`, MainActivity iki uçta visible/top-resumed,
  FATAL/ANR/crash/process-death yok ve test saatinde yeni exit-info kaydı yok.
- Public Analytics + FCM gizlilik/Pages güncellemesi PR #40 ile `main` dalına
  squash merge edildi: `c7b3be9925344f3c8f6bc608a1f7d98a42c0a210`. GitHub Pages build
  `1152991654` bu commit üzerinde **built**; PR #39 ile karıştırılmaz.
- Production bildirimi veya Firebase deploy yapılmamıştır.

**Bitti ölçütü:**

- [x] Analyze, tüm Flutter testleri ve push profil testleri PASS.
- [x] Release APK ve birleşik manifestte FCM SDK/izin/channel doğrulandı.
- [x] Android 16 APP_GATE/RELEASE_GATE PASS; CI app-specific hata yok.
- [x] Güncel Play closed-test fiziksel cihazında izin kabul/red doğrulandı.
- [x] Gerçek FCM foreground/background/terminated teslimi ve dokunma açılışı doğrulandı.
- [x] Uygulama içi kapatma sonrası closed-test mesajının gelmediği doğrulandı.
- [x] Ayarlar → Eğitimi Yeniden Göster fiziksel cihazda açılıp kapandı.
- [x] Fiziksel ADB/logcat crash/ANR/FATAL/process-death taraması PASS.
- [ ] Levent açık onayı sonrası merge kararı verildi.

---

## 0B - 13 Ağustos 2026 BR-P1-008 final artifact kabulü

Bu bölüm aşağıdaki tarihsel BR-P1-008 açık/bekliyor kayıtlarını **güncel olarak geçersiz kılar**.

- Final release source SHA: `794205f3ad68c0547f2858d530170af3a7a6bd41` (`release/final-closed-test-aab-1.68.8`).
- `Closed test release doğrulaması` run `31680750887` / job `94385413742`: **SUCCESS**.
- Artifact ID `9173824623`; digest `sha256:9c6f081211cff19a3d8857c6b6bb15dc312da17819fe67988f994a333c078d73`; AAB SHA-256 `6904249d00e12e3e671c9a282364dc4791948e9ec45cafecfaae15f8f734d285`.
- Dinamik `reports/RELEASE_READINESS.md` gerçek `1.68.14+104`, 8.710 soru, soru SHA-256 `e71c4ff991873499b986952835b9bb8e0995d2791c47ce4085d7ab9a502299d4`, source ref/SHA, AAB adı ve workflow run URL'sini içerir.
- Eski `1.68.8+98`, `6710` ve tarihsel source değerleri final readiness artifact'ında yoktur; trailing whitespace **PASS**.
- Android 16 AAB-derived `Misafir → Home → Oyna`, `APP_GATE`, `RELEASE_GATE` ve ayarlar/öğretici tanısı PASS; app-specific crash/ANR/FATAL/process-death yok.
- **BR-P1-008 bitti ölçütü karşılandı ve görev kapatıldı.**
- Bu run aynı zamanda güncel release HEAD için fresh geniş teknik RC kabulünü sağlar; Play/Firebase canlı servis ve fiziksel cihaz kabul maddeleri ayrıca açık kalır.

---

## 0A - 13 Ağustos 2026 PR #29/#30 release-readiness kapanış kesimi

Bu bölüm aşağıdaki tarihsel BR-P1-008 ve release HEAD kayıtlarının **güncel durumunu geçersiz kılar**; eski kayıtlar denetim izi olarak korunur.

- Güncel release branch: `release/final-closed-test-aab-1.68.8`.
- PR #30 kod tabanı / merge commit: `d1d5a9ea128d3d36fe26fafe95c97bf473c02548`.
- PR #31 proje-hafızası merge commit: `dcab00bee295c75a817fd4dda0a63be10c5a6d56`.
- Canlı release HEAD statik olarak bu dosyada dondurulmaz; her teknik görev başında GitHub'dan yeniden okunur.
- Sürüm: `1.68.14+104`.
- PR #29 `fix: generate release readiness from live build facts` release'e merge edildi: `9aef2bd9ceeeba3a47e85e5a508512967d7db29d`.
- Final closed-test run `31654600408`, uygulama/AAB aşamasından önce `git diff --check` ile kırıldı; kök neden dinamik `RELEASE_READINESS.md` üreticisindeki trailing whitespace idi. Bu koşu release AAB kabul kanıtı değildir.
- PR #30 `fix: remove release readiness trailing whitespace` yalnız `tools/release_readiness_report.py` ve `test/release_readiness_report_test.dart` dosyalarını değiştirdi.
- PR #30 kod head'i `1c809e9f4d02c425705e4812b0daadf87418b9fd`; CI #139 run `31655047190`, job `94307567727`: **SUCCESS**.
- PR #30 Levent'in açık onayıyla release'e merge edildi: `d1d5a9ea128d3d36fe26fafe95c97bf473c02548`.
- PR #31 sonrası `dcab00bee295c75a817fd4dda0a63be10c5a6d56` üzerinde Quality Checks #298 / run `31657810165` **SUCCESS**; AdMob PR doğrulaması #142 / run `31657810270` / job `94316006975` **SUCCESS**. #142 artifact ID `9165265578`, digest `sha256:da4a2082ca2139529fe4bee0358b560a966391d41e1548c8b20943184edbf2c3`, APK SHA256 `3bdb9ab250c97f42ab958ff1e037c0ad5eaee9458090d97b850710bf4c928813`; Android 16 app/release gate PASS ve app-specific crash/ANR/FATAL/process-death eşleşmesi yok. Bu APK kanıtı final AAB kabulü değildir.
- **BR-P1-008 uygulama/CI/merge kısmı tamamlandı.** Dinamik rapor gerçek `pubspec.yaml`, `assets/questions.json`, GitHub Actions source SHA/ref ve AAB adından üretilir; trailing whitespace regresyon testiyle kilitlidir.
- **Kapanış için kalan kanıt:** bu docs temizliği merge edildikten sonra GitHub'dan yeniden okunan **canlı release HEAD** üzerinde yeni `Closed test release doğrulaması` manuel run'ı çalıştırılmalı; artifact içindeki `reports/RELEASE_READINESS.md` canlı `1.68.14+104`, 8.710 soru, doğru source SHA/ref, doğru AAB adı ve whitespace'siz içerik göstermelidir.
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

**Durum:** TAMAMLANDI / FINAL RELEASE ARTIFACT KANITI PASS

**Final kanıt:** run `31680750887` / job `94385413742` SUCCESS; artifact `9173824623` / `sha256:9c6f081211cff19a3d8857c6b6bb15dc312da17819fe67988f994a333c078d73`; source `794205f3ad68c0547f2858d530170af3a7a6bd41`; AAB SHA-256 `6904249d00e12e3e671c9a282364dc4791948e9ec45cafecfaae15f8f734d285`. Dinamik readiness `1.68.14+104`, 8.710 soru, doğru source/AAB/run bilgilerini içerir ve eski tarihsel sabitleri taşımaz.

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

### BR-P1-013 - Hakkında & Gizlilik bağlantıları ve public destek iletişimini düzelt

**Durum:** TAMAMLANDI / PR #34 + #35 MERGED / PAGES BUILT

- PR #35 main tarafında public `docs/` destek iletişimini `BilgiRotasidestek@gmail.com` olarak güncelledi; head `b30689cc5df5ac3dde1479be6fe379a23e7c79c9`, squash merge `3b95e226c4e166864b72b22823ddc69b78589150`.
- GitHub Pages kaynağı `main:/docs`; build `1149217588` merge commit'i üzerinde `built`.
- PR #34 release tarafında dört Hakkında & Gizlilik URL'sini `zmilastudio.github.io/BilgiRotasi` alanına ve destek e-postasını yeni adrese taşıdı; eski `leventua.github.io` ve `BilgiRotasi10@gmail.com` değerlerini engelleyen regresyon testi eklendi/güncellendi.
- PR #34 head `5fd552a2fe35e3b72a43a1f65162830da702655c`; AdMob PR doğrulaması #148 / run `31700031074`: **SUCCESS**.
- PR #34 Levent'in açık onayıyla `release/final-closed-test-aab-1.68.8` dalına squash merge edildi: `1ca0ff063586b15ef37222f8523f1aeefa1d52b7`.
- Merge sonrası canlı release HEAD `1ca0ff063586b15ef37222f8523f1aeefa1d52b7`; `pubspec.yaml` sürümü değişmedi: `1.68.14+104`.
- Merge sonrası AdMob PR doğrulaması #151 / run `31710501542`, job `94481907601` **SUCCESS** ve Quality Checks #304 / run `31710501544` **SUCCESS** oldu.
- #151 artifact `BilgiRotasi-AdMob-1.68.14-104-kanitlari`, ID `9185415759`, digest `sha256:1b831a41d072ee515f808bb6d967bd54ce3740308fed555e8a0086bc0b024344`; APK SHA-256 `bd83e43b0a6af054b15b65d93e57c5c260da1cdf4e57d765582f2e30f830fd7d`.
- #151 artifact APK'sı `1.68.14 (104)` / targetSdk 36 ve Android 16 `APP_GATE=PASS`, `RELEASE_GATE=PASS` olarak doğrulandı; app-specific FATAL/process-death kanıtı yok.
- Canlı release `pubspec.yaml`: `1.68.14+104`.
- Oynanış / BoardMap / 67 node / `assets/questions.json` / sürüm numarası değiştirilmedi.

**Bitti ölçütü:** Karşılandı. Public Pages yeni iletişimi built durumda servis ediyor; uygulama release dalı yeni uçları kullanıyor; regresyon beklentileri güncellendi ve ilgili CI/Android 16 kapıları PASS.

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
