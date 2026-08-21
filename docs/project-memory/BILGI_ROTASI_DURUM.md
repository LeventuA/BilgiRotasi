# Bilgi Rotası - Güncel Proje Durumu

## 0N. 1.68.19+109 AdMob/UMP release merge checkpoint — 21 Ağustos 2026

- Kanonik release `release/final-closed-test-aab-1.68.8` exact `b0240a7a4009c41326f459a37b8bedeab080d8d8`; sürüm `1.68.19+109`.
- PR #88 final head `1999a049018b5d23eeda59b0b9d2e0e435cf0a64`, Levent'in açık onayı sonrası expected-head ile squash merge edildi; merge SHA `b0240a7a4009c41326f459a37b8bedeab080d8d8`.
- Merge yalnız `lib/ad_monetization.dart`, `lib/app_build_info.dart`, `pubspec.yaml`, `test/ad_monetization_diagnostics_test.dart`, `test/admob_ump_fallback_test.dart` dosyalarını değiştirdi. `assets/questions.json` +108 ve +109'da aynı blob SHA `b19956972c05bdc58e6b9a0c010a407e6c05613f`; +108'deki 81 gerçek soru düzeltmesi korundu.
- Pre-commit run/job `32481091014` / `96767404086`: focused 42/42, tüm Flutter 301/301, analyze non-fatal policy, diff check PASS; artifact ID `9446124898`, digest `sha256:3c9e11123a9203ba1efce156044e72a3cab2a3b8f116f04ab08cb1d26df60c17`.
- Exact-head run/job `32481746889` / `96769404446`: SUCCESS; signing, release APK, package/manifest ve Android 16 app gate PASS. Artifact ID `9446694140`, digest `sha256:c6615ba1ad6ad80137af0218759fa99f946c78554c7ae54100c779a340abfa9a`; APK SHA-256 `0b9cf5e0b3a9568ea4424818cb4162f677bab3ade4fd214e6dc4d6bcdcefb376`; package `com.leventua.bilgirotasi`, versionCode 109, versionName 1.68.19, targetSdk 36, signer SHA-1 `26:3C:70:7C:FE:2E:2E:52:62:52:C3:8E:9B:AB:59:79:8C:FF:81:94`. App-specific crash/ANR/FATAL yok.
- Fiziksel production: banner PASS, rewarded PASS, AdMob Verify URL PASS, SSV selective redeploy PASS, açık cutover sonrası `ssvEnabled=true` readback PASS, gerçek rewarded -> SSV claim -> +10 XP PASS.
- `KARARLAR.md` değişmedi.
- Açık: fiziksel no-double; yarım/başarısız reklamda hak/retry; farklı oyunlarda toplam kota yok; merge SHA'dan production +109 AAB doğrulaması; Play +109 upload/install/rollout.

---

**Kesim noktası:** 19 Ağustos 2026
**Durum sınıfları:** `DOĞRULANDI`, `RAPORLANDI`, `AÇIK`, `DURDURULDU`

## 0L. Issue #67 / PR #69 SSV percent-encoding düzeltmesi merge checkpoint — 19 Ağustos 2026

Bu bölüm aşağıdaki `0K` içindeki PR #68 ön-merge açık kapılarını ve bölüm 15'teki eski SSV sırasını **güncel durum açısından geçersiz kılar**; eski kayıtlar tarihsel denetim izi olarak korunur.

- Kanonik release `release/final-closed-test-aab-1.68.8`; PR #69 merge sonrası canlı HEAD `fe293d87a33772ff9fa65de829ed59d40a263eca`, gerçek sürüm `1.68.17+107`. Merge SHA ile release karşılaştırması `identical` olarak doğrulandı.
- PR #68 daha önce release'e `60dce6cf80f1665360462f443455e282509ecd95` ile merge edildi. Bu verify-only kodunun production callback redeploy'u bu oturumdaki yetkili execution kanalı eksikliği nedeniyle uygulanmamış ve `ssvEnabled` açılmamıştı.
- AdMob `Verify URL` canlı denemesinde geçerli Google callback'i `HTTP 400` ile reddedildi; Cloud Run request kanıtında `reward_item=%C3%96d%C3%BCl` görüldü. Kök neden, Google'ın referans doğrulayıcısının URI query'sini percent-decode etmesi ile Express `request.originalUrl` değerinin percent-encoded biçimi koruması arasındaki imza içeriği farkı olarak kapatıldı.
- Ayrı branch `fix/ssv-percent-decoded-signature-20260819`, PR #69. Final head `a01f1d19c6ce40ebec1b9c83ab4ed672f65c8cb7`.
- PR #69 net diff yalnız `functions/rewarded_ssv.js` ve `functions/test/rewarded_ssv.test.js`: query sırası korunarak `signature` öncesi imza içeriği `decodeURIComponent` ile percent-decode edilir; bozuk encoding `invalid-query-encoding` ile fail-closed kalır. Canlı biçimdeki `reward_item=%C3%96d%C3%BCl` → `reward_item=Ödül` regresyonu ve bozuk encoding reddi kanonik suite'e eklendi.
- Final exact-head Firebase güvenlik doğrulaması run `32222981893`: **SUCCESS**; tam logda Functions **43/43 PASS**, Firestore Rules emulator **6/6 PASS**. Final exact-head AdMob PR doğrulaması run `32222981901`: **SUCCESS**. Workflow, tam log, diff ve iki commitlik Git geçmişi birlikte incelendi.
- Levent'in mevcut koşullu PR #69 merge onayı altında PR Draft'tan çıkarıldı; head yeniden kilitlenip değişmediği doğrulandıktan sonra expected-head SHA ile squash merge edildi. Merge commit `fe293d87a33772ff9fa65de829ed59d40a263eca`.
- `assets/questions.json`, Flutter oynanışı, Firestore Rules/Indexes, BoardMap/67 node, 3B tahta ve `pubspec.yaml` sürümü PR #69 ile değiştirilmedi.
- Issue #67 üzerinde merge checkpoint comment `5340502656` ile kalıcı uzak kayıt oluşturuldu.
- **Production mutation yapılmadı:** PR #69 merge adımı callback redeploy yapmadı; `ssvEnabled` açılmadı/değişmedi; blanket Functions deploy yapılmadı. Yeni percent-decoding kodunun canlı callback'e ulaştığı henüz kanıtlanmış değildir.
- Google Play Integrity API'nin Google Cloud Console'da `Enabled` olduğu Levent'in canlı ekran kanıtıyla **DOĞRULANDI**. Bu, Play App Signing / Upload SHA rollerini tek başına doğrulamaz; sertifika rolleri Play Console'dan **DOĞRULANACAK**.
- `KARARLAR.md` değişmedi; ürün ödül sözleşmesi değişmedi.

**Açık sonraki kapılar:** mevcut yetkili Firebase production execution kanalında yalnız `rewardedSsvCallback` selective redeploy → normal callback'in yine `503 SSV_NOT_ENABLED` olduğunu doğrulama → legacy AdMob rewarded biriminde `Verify URL` tekrar denemesi ve `200 SSV_VERIFY_OK` + verify-only sırasında Firestore write yok kanıtı → Play App Signing/Upload SHA rol eşlemesi ve versionCode/public listing → fiziksel gerçek rewarded + iki cihaz Canlı Düello kabulü → yalnız bütün kapılar ve ayrıca açık cutover onayı sonrası `server_config/rewarded.ssvEnabled=true` değerlendirmesi.

---

## 0K. Issue #67 production AdMob/Firebase SSV canlı cutover — 19 Ağustos 2026

- Kanonik release `release/final-closed-test-aab-1.68.8`; görev başlangıcında canlı HEAD `7cf17591ba12cbb422c0e2e34609795546258784`, gerçek sürüm `1.68.17+107` olarak yeniden doğrulandı. PR #65 merged durumdadır.
- Legacy production AdMob hesabı kanonik monetizasyon hesabı olarak doğrulandı. Canlı App ID `ca-app-pub-7452194004008791~7046504043`, banner `ca-app-pub-7452194004008791/4228769011`, rewarded `ca-app-pub-7452194004008791/4974874471` release source ile birebir eşleşti. Yeni duplicate AdMob hesabı production için kullanılmayacak; ödeme yöntemi/banka ve public store bağlantısı ayrıca doğrulanacak.
- Firebase production projesi `bilgi-rotasi-f255d`. Google Auth sağlayıcısı Levent'in canlı gözlemiyle etkin; Android fingerprint listesinde upload SHA-1 `00:0E:E4:3F:41:0A:BC:6B:4F:63:4C:4F:71:6D:76:EB:19:08:41:15` ile `26:3C...`, `D4:BA...` SHA-1 ve `60:EC...` SHA-256 kayıtları görüldü. Son iki kaydın gerçek sertifika rolleri Play Console ile **DOĞRULANACAK**.
- App Check Android sağlayıcısı Play Integrity olarak doğrulandı. Firestore ve Authentication `Monitoring`; enforcement açılmadı. Üç composite Firestore index canlıda `Enabled` ve repo ile birebir eşleşiyor. Canlı Firestore Rules son yayın kesimi hardened repo Rules'tan eski; Rules cutover bilerek yapılmadı.
- Firestore kök koleksiyonlarında `server_config` yok; `server_config/rewarded` ve `ssvEnabled` yok. Bu durum true olarak yorumlanmadı.
- Levent'in açık `Onaylıyorum, 3 SSV Function'ını deploy edelim.` onayıyla yalnız `issueRewardNonce`, `getRewardedGameState`, `rewardedSsvCallback` production `bilgi-rotasi-f255d/europe-west1` hattına selective deploy edildi. Mevcut 7 Function korundu; toplam canlı Function 10. Blanket Functions deploy, Rules/Indexes deploy veya config açılışı yapılmadı.
- Deploy sonrası `rewardedSsvCallback` canlı probe `HTTP/2 503` + `SSV_NOT_ENABLED` döndürdü: fail-closed kapısı **PASS**.
- AdMob SSV `Verify URL` işleminin başarılı HTTP callback gereksinimi ile mevcut `ssvEnabled`-önce 503 sırası arasında blokaj bulundu. `ssvEnabled=true` ile kestirme yapılmadı. Ayrı branch `fix/ssv-verify-url-handshake-20260819`, Draft PR #68 açıldı.
- PR #68 verify-only tasarımı: yalnız `user_id=bilgi-rotasi-ssv-verify` + `custom_data=bilgi-rotasi-ssv-verify-v1` birlikte geldiğinde Google ECDSA imzası doğrulanır; geçerli istekte `200 SSV_VERIFY_OK`, geçersiz imzada `400 INVALID_SIGNATURE`. Bu yol nonce/claim/transaction/XP yazmaz. Normal disabled callback `503 SSV_NOT_ENABLED` kalır.
- Teknik commitler: `94a7d883ebff0b857b3bdd2335c10fd7ee65b8c6` — `fix: allow signed AdMob SSV URL verification`; `d7e015533d94be21768554c19266830d5fadc035` — `test: run SSV verify handshake in canonical suite`.
- İlk ayrı test dosyasının `npm test` explicit listesine girmediği tam CI logundan yakalandı; yanlış PASS kabul edilmedi. Testler kanonik `functions/test/rewarded_ssv.test.js` içine taşındı. Final teknik head Firebase güvenlik run `32197564562`: **SUCCESS**, Functions `42/42`, Firestore Rules emulator `6/6` PASS; yeni verify-only ve normal 503 regresyon testleri gerçek suite içinde geçti.
- `docs/rewarded-ssv-setup.md`, `GOREV_HAVUZU.md` ve `ACIK_SORULAR_VE_DOGRULAMALAR.md` aynı PR branch'inde güncellendi. `KARARLAR.md` değişmedi; ödül ürün sözleşmesi değişmedi, yalnız güvenli AdMob URL doğrulama handshake'i eklendi.
- `assets/questions.json`, BoardMap/67 node, 3B tahta, Flutter oynanışı ve `pubspec.yaml` sürümü değiştirilmedi.

**Açık sonraki kapılar:** PR #68 final docs-head AdMob/Firebase CI PASS → Levent ayrı merge onayı → merge sonrası canlı release HEAD kilidi → yalnız güncellenmiş callback production redeploy'u için ayrı Levent onayı → normal 503 probe → AdMob Verify URL PASS + write-free kanıt → fiziksel gerçek rewarded/iki cihaz Canlı Düello/Play signing-versionCode-public listing kabulü → ancak tüm kanıtlar + ayrı cutover onayı sonrası `ssvEnabled=true` değerlendirmesi.

---

## 0J. Issue #64 production-readiness kapanış adayı — 18 Ağustos 2026

- Canlı başlangıç kaynağı `release/final-closed-test-aab-1.68.8` / `05b8882dbcc1e9ffbb59350239d366ee66fd3950` / `1.68.17+107`; PR #63 bu SHA ile merge edilmiştir.
- Çalışma branch'i `fix/final-production-readiness-20260818`; kod commit'i `8b8913548c208e94a9deacacacabf7d4d6a26be4`; Draft PR #65 açık ve merge edilmemiştir. Güncel PR head'i statik kopyadan değil canlı GitHub metadata'sından doğrulanır.
- Günlük giriş serisi korunur fakat giriş nedeniyle XP verilmez. Eski `lastLoginReward` / `lastLoginRewardDate` alanları ödülsüz sözleşmeye güvenle taşınır; aynı gün, ardışık gün, boş state ve eski state testleri XP'nin değişmediğini doğrular. Günlük/haftalık görev XP'leri değişmedi.
- PR #63 sözleşmesi repo/test düzeyinde doğrulandı: tamamlanan her `gameId` en fazla tek +10 XP; farklı oyunlara günlük/oturumluk kota yok; production hesaplı sonuçta nonce + SSV server claim; misafir sonuç ve tahta jokeri yerel; aktif normal soru ve Canlı Düello maç ekranlarında reklam yok.
- Production SSV için yalnız `issueRewardNonce`, `getRewardedGameState` ve `rewardedSsvCallback` endpoint'lerini, explicit `--project bilgi-rotasi-f255d` ile `europe-west1` bölgesinde hedefleyen kontrollü plan belgelendi. Deploy/config değişikliği yapılmadı; `ssvEnabled` callback ve fiziksel kabul tamamlanana kadar fail-closed kalır.
- Yerel kanıt: hedefli Flutter `25/25`, tüm Flutter `295/295`, Functions `40/40`, Firestore Rules emulator `6/6` PASS; analyze error sayısı 0 (mevcut 92 warning/info; non-fatal koşu PASS); `git diff --check` PASS.
- Fresh release run #13 / `32170570288`, job `95820471266`, exact release SHA üzerinde AAB build/metadata/imza adımlarını geçti fakat OCR hazırlığında 60 dakikadan uzun takıldı; Android 16 kapısına ulaşmadan artifactsız iptal edildi. Eski koşu rerun edilmedi.
- Yerine exact aynı release SHA üzerinde fresh run #14 / `32176210749`, job `95838654578`: **SUCCESS**. Artifact `BilgiRotasi-1.68.17-107-closed-test-release`, ID `9339668986`, digest `sha256:b021e611e071ea3a105607b3ff427ac3a5c67b13603770951572ab12e10b6b32`; gerçek AAB SHA-256 ve `reports/AAB_SHA256.txt` eşleşmesi `fb8d94867f4890c22ddcc62bdd7f361c8ca9efd9807e5c952bd99fab158944ad`.
- Run #14 package `com.leventua.bilgirotasi`, version `1.68.17+107`, targetSdk 36, upload SHA-1 `00:0E:E4:3F:41:0A:BC:6B:4F:63:4C:4F:71:6D:76:EB:19:08:41:15`, production Firebase `bilgi-rotasi-f255d`, closed-test Google demo reklam profili ve 8.710 soru/source SHA/ref readiness alanlarını doğruladı.
- Android 16 zorunlu kapı ilk AAB-derived denemede `APP_GATE=PASS`, `RELEASE_GATE=PASS`; install, launch, guest login, Home/Oyna, PID ve app logcat PASS. Bilgi Rotası paketinde crash/ANR/FATAL/process-death eşleşmesi 0. Gate sonrasındaki Ayarlar/öğretici sırasında başka sistem paketindeki ANR/global input kanıtı nedeniyle tanı `INFRASTRUCTURE_INCONCLUSIVE`; workflow kararı gereği release gate PASS ve fiziksel Play Internal Testing Ayarlar/öğretici kabulü zorunlu kalır.
- Draft PR #65 docs-head `5f7b28475aea2fc0789e4954d5907a2f28273e3a` AdMob run `32178111832`, job `95844597170`: SUCCESS; artifact `BilgiRotasi-AdMob-1.68.17-107-kanitlari`, ID `9340171407`, digest `sha256:2e12636945044911e9b730e54c159e8f470cf62c94b91c3cf92a4f746249c317`, APK SHA-256 `12f1339fd6ebfa0186711d0385d84c73a951781e54d0ce1e5a46638bdf654e88`; Android 16 `RESULT/APP_GATE/RELEASE_GATE=PASS`. Firebase güvenlik run `32178111912` da SUCCESS. Güncel PR head/check sonucu statik kopyadan değil canlı GitHub metadata'sından doğrulanır.
- `assets/questions.json`, BoardMap/67 node, 3B tahta, pubspec sürümü, Android/release workflow'ları, aktif soru ve Canlı Düello maç davranışı değiştirilmedi.

---

## 0I. `1.68.17+107` release merge / PR #60 — 18 Ağustos 2026

Bu bölüm aşağıdaki `0H` ve daha eski canlı release HEAD/sürüm kayıtlarını **güncel durum açısından geçersiz kılar**; eski bölümler tarihsel denetim izi olarak korunur.

- Kanonik yayın dalı `release/final-closed-test-aab-1.68.8`.
- PR #60 (`chore: prepare closed-test 1.68.17+107`) final head `8254a0b55664f5d50983ab8b3c534580d9f92672`; final head son commit'i `fix: sync app build info to 1.68.17+107`.
- PR #60 final diff yalnız iki sürüm metadata dosyasıdır: `pubspec.yaml` ve `lib/app_build_info.dart`; `1.68.16+106` → `1.68.17+107`. Ürün davranışı, `assets/questions.json`, Canlı Düello, Firebase/AdMob backend, signing, BoardMap/67 node ve 3B tahta değişmedi.
- Exact-head `AdMob PR doğrulaması` #248 / run `32105875494`: **SUCCESS**. Analyze + tüm testler, kalıcı imzalı release APK, package/manifest doğrulaması ve Android 16 / API 36 cold-start uygulama kapısı PASS.
- Levent 18 Ağustos 2026'da açıkça `Merge et` onayı verdi. PR #60 exact-head kilidiyle squash merge edildi.
- Merge commit ve güncel canlı release HEAD: `03df0a925cc3a0515f86d11e817da619172703fe` — `chore: prepare closed-test 1.68.17+107 (#60)`.
- Merge sonrası canlı release `pubspec.yaml` yeniden okundu ve gerçek sürüm **`1.68.17+107`** olarak doğrulandı.
- **DOĞRULANACAK:** `03df0a9...` canlı release HEAD üzerinde fresh `Closed test release doğrulaması` çalıştırılmalı; workflow/job/log, AAB artifact, release-readiness, Android 16 gate ve AAB hash/metadata birlikte incelenmeden +107 AAB final Play adayı sayılmamalı.
- Google Play üretim erişimi/onayı teknik kalite kapılarını kaldırmaz. Production AdMob/Firebase profilli AAB üretimi ve Play production yüklemesi ayrı kontrollü görevdir; bu merge işlemi production deploy/yükleme yapmadı.
- Proje hafızası güncellemesi `docs/record-pr60-merge-20260818` branch'inde hazırlanır; `KARARLAR.md` değişmez çünkü yeni ürün/teknik karar alınmadı.

---

## 0H. Android 16 tutorial replay gate / PR #44 — 16 Ağustos 2026

Bu bölüm aşağıdaki `0G` PR #43 öncesi/sonrası Android 16 kayıtlarının bu görev için **güncel durumunu geçersiz kılar**; eski bölümler tarihsel denetim izi olarak korunur.

- Canlı yayın dalı `release/final-closed-test-aab-1.68.8`; canlı release HEAD `9371e0aecc4e677c24682e11a31d91ebed54f309`; gerçek sürüm `1.68.16+106`.
- PR #43 release'e merge edildikten sonra fresh `Closed test release doğrulaması` #9 / run `31942307299`, job `95153144908` doğru release SHA üzerinde gerçek AAB üretti. Ana uygulama kapısı PASS oldu; tutorial replay tanısı finalde `RESULT=FAIL`, `APP_GATE=PASS`, `RELEASE_GATE=FAIL`, `REASON=SETTINGS_TUTORIAL_FAILED_WITHOUT_INFRASTRUCTURE_EVIDENCE` verdi.
- Run #9 için validatorın ilk açık hata mesajı: `Settings/tutorial diagnostic failed without emulator infrastructure evidence.` App crash/ANR/FATAL/process-death ve emulator-unhealthy kanıtı yoktu; D-032 gereği hata altyapı retry'ı olarak gizlenmedi.
- Run #9 artifact `BilgiRotasi-1.68.16-106-closed-test-release`, ID `9262524277`, digest `sha256:1e558a0423b6243d7ded7849b72c7353726ea453e7d70ae4c225914e56df4e0a`. `UI_SETTINGS_TUTORIAL_2.tsv` içinde `Yeniden` kontrolü gerçekten görünürken tutorial dialog/closed kanıtları oluşmadı.
- Kök neden OCR/parser veya uygulama davranışı değil, `retry_capture_screen()` içindeki local olmayan `attempt` değişkeninin Bash dinamik kapsamıyla dış tutorial döngüsünün `attempt` sayacını ezmesiydi. Böylece `_2.tsv` doğru çekilse bile helper dönüşünde yanlış label okunabiliyordu.
- Düzeltme branch'i `fix/br-p0-011-android16-tutorial-gate`; Draft PR #44 açık ve merge edilmedi. Teknik commitler: `38a13c58b5e85e3e5798b6c4209dd449216e81b7` — `fix: make Android 16 tutorial replay gate deterministic`; `a6ce0ba08bce5d2454aaeb612f62a271d10e8f28` — `fix: isolate Android 16 tutorial retry counters`.
- Teknik net diff yalnız `tools/validate_android16_closed_test.sh` + `test/android16_closed_test_retry_scope_test.dart`: helper retry sayacı local yapıldı, tutorial taraması ayrı `tutorial_attempt` kullanıyor ve gerçek Bash regresyon testi caller sayacının değişmediğini kilitliyor. Mandatory release gate/infra sınıflandırması gevşetilmedi.
- Teknik-head AdMob PR doğrulaması #197 / run `31957410025`, job `95190026025`: **SUCCESS**. Ardından proje-hafızası head'i `c5595c0aa38e7c1458e268061563943d38e79a37` üzerinde final AdMob PR doğrulaması #201 / run `31962756913`, job `95203168990`: **SUCCESS**. `Analiz ve tüm testler`, release APK build, paket/manifest ve Android 16 deneme/classifier/final app gate PASS; ikinci emulator denemesi gerekmedi.
- #201 artifact `BilgiRotasi-AdMob-1.68.16-106-kanitlari`, ID `9267811261`, digest `sha256:23750143b62cd7de04d77a24d223626a475d89e871550ff81266f66bc4963443`; APK SHA-256 `cf807552ac1b1a239988d99f5e78125a76722681410b25bb6b8a5cf7cbc2a973`; `RESULT=PASS`, `APP_GATE=PASS`, `RELEASE_GATE=PASS`; app-specific crash/ANR/FATAL/process-death yok.
- Sürüm, ürün davranışı, `assets/questions.json`, BoardMap, 67 node, 3B tahta, launcher/splash ve Firebase/AdMob/FCM ürün davranışı değiştirilmedi. `KARARLAR.md` değişmedi; mevcut Android 16 D-032 sınıflandırma kararı korunur. PR #7'ye dokunulmadı.
- PR #44 Draft olarak açık tutulur. Bu belgeyi taşıyan güncel PR head'inin CI sonucu GitHub'dan canlı okunur; statik bir “son docs-head CI” SHA'sı burada dondurulmaz.
- **BR-P0-011 henüz kapanmadı:** Levent'in ayrıca açık merge onayı olmadan PR #44 merge edilmeyecek. Merge sonrası yeni canlı release HEAD üzerinde fresh `Closed test release doğrulaması` PASS ve gerçek `1.68.16+106` AAB artifact üretilmeden AAB Play Kapalı Test yükleme adayı sayılmayacak.

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
- Android 16 `APK_INSTALL`, `APP_LAUNCH`, `APP_PID`, `APP_ACTIVITY`, `APP_LOGCAT`, `APP_GATE`, `RELEASE_GATE` = PASS; PID `1991`, `MainActivity` RESUMED/visible; uygulamaya ait crash/ANR/FATAL/process-death kanıtı yok.
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
- Production topic'e gerçek mesaj gönderimi ayrı Levent kararı gerektirir; bu
  fiziksel closed-test kabulü production gönderim yetkisi değildir. PR #39 merge
  edilmemiştir; PR #40 main'e merge edilmiştir.
- `KARARLAR.md` değişmedi; ürün kararı değişmedi, mevcut ortam izolasyonu ve açık
  kullanıcı izni kararı teknik olarak sertleştirildi.

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
- **Kapanış için kalan kanıt:** bu proje-hafızası temizliği release'e merge edildikten sonra GitHub'dan yeniden okunan **canlı release HEAD** üzerinde yeni bir fresh geniş RC2 çalıştırılacak ve Guest → Home → Oyna dahil tüm zorunlu gate'ler yeniden PASS olmalıdır.
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

1. PR #68 final docs-head CI sonuçlarını tam log/artifact/diff/Git geçmişiyle kapat.
2. CI PASS ise Levent'ten PR #68 için ayrı açık merge onayı al; kendi kendine merge etme.
3. Merge sonrası canlı release HEAD/sürümü tekrar kilitle ve yalnız `rewardedSsvCallback` production redeploy'u için ayrı açık onay al.
4. Redeploy sonrası normal callback'in `503 SSV_NOT_ENABLED` kaldığını doğrula; ardından legacy AdMob rewarded biriminde verify-only User ID/custom data ile `Verify URL` PASS ve write-free davranışı kanıtla.
5. `ssvEnabled` açmadan fiziksel gerçek rewarded kabulünün ön koşullarını tamamla; tek +10/no-double/failure-right-preserved/no-total-quota kanıtını al.
6. Play Console'da versionCode 107, production/public listing ve App Signing/Upload SHA rollerini canlı doğrula.
7. İki ayrı cihaz/hesapla Canlı Düello eşleşme → maç → sonuç → leaderboard zincirini doğrula.
8. Yalnız bütün canlı kapılar + ayrı cutover onayı sonrası `server_config/rewarded.ssvEnabled=true` değerlendir.
9. Soru geri bildirim düzeltmelerini ayrı branch/PR düzeninde sürdür; `assets/questions.json` kontrolsüz değişmesin.
10. 3B tahta işine 6-rozet eşlemesi ve geometri onayı olmadan dönme.
