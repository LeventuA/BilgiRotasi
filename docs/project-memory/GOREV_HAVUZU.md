# Bilgi Rotası - Görev Havuzu

## 0H - 17 Ağustos 2026 Production rewarded SSV / PR #48

- **BR-P1-009 Durum:** ÜRÜN SÖZLEŞMESİ DÜZELTİLDİ / FINAL CI PASS / MERGE ONAYI VERİLDİ / MERGE BEKLİYOR / CLIENT PRODUCTION SSV CUTOVER AYRI SONRAKİ GÖREV.
- Canlı release tabanı: `release/final-closed-test-aab-1.68.8` / `535465af74934fc98efe0e43cde81fae8a712794` / `1.68.16+106`.
- Branch: `fix/final-monetization-20260817`; Draft PR #48. Final doğrulanan teknik head `ea4529954e58820ebd4038355a88fcc1b16d5a91`.
- Eski `rewarded_daily`, `daily-limit` ve `count >= 3` yolu kaldırıldı. Sözleşme artık her tamamlanan oyun için bir kez +10 XP, aynı oyun için ikinci ödül yok, günlük/oturumluk toplam kota yok şeklindedir.
- `issueRewardNonce` zorunlu `gameId` alır; nonce `uid + gameId` ile bağlanır, kısa ömürlü ve tek kullanımlıdır. SSV custom data `uid + nonce + gameId` taşır.
- `rewarded_game_claims` kullanıcı+oyun kimliği için server-side idempotency sağlar; Google `transaction_id` tekrarları ikinci ödül üretmez. Aynı oyun için farklı transaction tekrarında nonce tüketilir fakat XP tekrar artmaz.
- İlk AdMob CI #215 yalnız eski `backend_hardening_test.dart` içindeki `count >= 3` beklentisi nedeniyle FAIL oldu. Bu eski sözleşme beklentisi yeni ürün kararıyla hizalandı; güvenlik kapısı gevşetilmedi.
- Final Firebase güvenlik doğrulaması #18 / run `32021248072`, job `95361205006`: **SUCCESS**. Functions birim testleri **29/29 PASS**, Firestore Rules emulator testleri **6/6 PASS**.
- Final AdMob PR doğrulaması #216 / run `32021248074`, job `95361205147`: **SUCCESS**. Analyze+tüm Flutter testleri, kalıcı signing hazırlığı, test-ID release APK, paket/manifest, Android 16 cold-start deneme 1, classifier ve final app gate PASS; ikinci emulator denemesi gerekmedi.
- Artifact `BilgiRotasi-AdMob-1.68.16-106-kanitlari`, ID `9285744331`, digest `sha256:dc86c7b10865c93cfb2d3a228d1f15950bbdff94f7f298bc8d24f449e85acc5d`.
- Final teknik diff yalnız `functions/rewarded_ssv.js`, `functions/rewarded_ssv_helpers.js`, `functions/test/rewarded_ssv.test.js`, `test/backend_hardening_test.dart`; `assets/questions.json`, BoardMap, 67 node, 3B tahta, Canlı Düello, Firestore Rules ve sürüm değişmedi.
- Production rewarded reklamları hâlâ **kapalıdır**; `server_config/rewarded.ssvEnabled` değiştirilmedi ve hiçbir Firebase deploy yapılmadı. Client production `custom_data`/SSV bağlantısı ayrı branch'te yapılacaktır.
- `KARARLAR.md` değişmedi; mevcut reklam ürün kararı zaten güncel sözleşmeyi tanımlar.
- Levent 17 Ağustos 2026'da, final inceleme temizse PR #48 için açık squash-merge onayı verdi.

**Bitti ölçütü:**

- [x] Günlük 3 reklam / +30 XP sınırı kaldırıldı.
- [x] Oyun başına tek +10 XP, aynı oyun için ikinci ödül yok ve toplam günlük/oturumluk kota yok sözleşmesi server tarafında uygulandı.
- [x] Nonce, `transaction_id`, `uid + gameId` idempotency ve Google imza doğrulama kapıları korundu.
- [x] Eski CI sözleşme beklentisinin ilk kesin hata satırı bulunup minimum test hizalaması yapıldı.
- [x] Firebase #18 Functions 29/29 + Rules 6/6 PASS.
- [x] AdMob #216 analyze+tüm testler+release APK+manifest+Android 16 final gate PASS.
- [x] Final artifact metadata/digest ve diff/Git geçmişi birlikte incelendi.
- [x] Levent koşullu merge onayı verdi.
- [ ] PR #48 release dalına squash merge edildi ve yeni release HEAD doğrulandı.
- [ ] Ayrı client cutover branch'inde production SSV custom data bağlantısı tamamlandı ve CI PASS.
- [ ] Kontrollü Functions deploy + AdMob SSV callback/test + fiziksel production ödül kabulü daha sonraki adımlarda tamamlandı.

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

## P0 - Kapalı Test ve soru kalitesi

### BR-P0-001 - Kapalı Test canlı durumunu doğrula

**Durum:** İZLENİYOR

- Son doğrulanan: 12 geçerli testçi
- Son doğrulanan: 4 kesintisiz gün
- Güncel Play Console sayacı yeniden okunacak.
- Son aktif Play AAB sürümü canlı ekrandan yeniden doğrulanacak.

**Bitti ölçütü:** Tarihli Play Console ekran kanıtı ve güncel sayaç `BILGI_ROTASI_DURUM.md` dosyasına yazılır.

---

### BR-P0-004 - Ödüllü reklam hak sistemi

**Durum:** RELEASE'E ENTEGRE / PRODUCTION SSV CUTOVER DEVAM EDİYOR

Kesin sözleşme:

- tamamlanan oyun başına 1 hak
- aynı oyun için tekrar yok
- yeni tamamlanan oyunla yeniden hak
- günlük/oturumluk toplam kota yok
- +10 XP

Closed-test Google demo rewarded davranışı release hattında mevcuttur. Production AdMob profili ise server-side verification tamamlanana kadar fail-closed tutulur. Güncel production SSV backend sözleşmesi BR-P1-009 / PR #48 altında izlenir.

**Bitti ölçütü:**

- [x] Yerel oyun-başına hak/tek ödül sözleşmesi release'e entegre edildi.
- [x] Production SSV backend günlük kota çelişkisi PR #48'de giderildi ve CI PASS.
- [ ] Client production SSV `custom_data` akışı ayrı branch'te bağlandı.
- [ ] Kontrollü production Functions deploy ve AdMob callback doğrulandı.
- [ ] Fiziksel production ödüllü reklam tamamlandığında +10 XP tek kez işlendi; yarım/başarısız reklamda XP verilmedi.

---

## P1 - Teknik ve yayın kabul doğrulamaları

### BR-P1-003 - Canlı Düello release doğrulaması

**Durum:** AÇIK / PR #47 RELEASE'E MERGE EDİLDİ / FİZİKSEL YENİDEN KABUL 18:30 SONRASI

- PR #47 squash merge sonrası release HEAD `535465af74934fc98efe0e43cde81fae8a712794`.
- 10/20/30 iki cihaz kabulü, eşleşmede arama ekranında kalmama ve aktif oyuncuda yanlış bağlantı-kesildi uyarısının kalktığı fiziksel olarak yeniden doğrulanacak.

---

### BR-P1-009 - Production rewarded SSV sözleşmesini ürün kararıyla uyumlu hale getir

**Durum:** PR #48 FINAL CI PASS / MERGE BEKLİYOR / PRODUCTION DEPLOY YOK

- Günlük 3 işlem / +30 XP sınırı kaldırıldı.
- Her tamamlanan oyun için bir kez +10 XP; aynı oyun için ikinci ödül yok; günlük/oturumluk toplam kota yok.
- Nonce `uid + gameId` ile bağlanır; Google transaction tekrarları ve oyun claim'i idempotenttir.
- Final head `ea4529954e58820ebd4038355a88fcc1b16d5a91`.
- Firebase #18: Functions 29/29, Rules 6/6 PASS.
- AdMob #216: analyze+tüm testler+release APK+Android 16 final gate PASS.
- Artifact ID `9285744331`, digest `sha256:dc86c7b10865c93cfb2d3a228d1f15950bbdff94f7f298bc8d24f449e85acc5d`.
- Production rewarded, `ssvEnabled`, Functions deploy ve AdMob callback henüz açılmadı.

**Bitti ölçütü:**

- [x] Backend ürün sözleşmesi düzeltildi.
- [x] Functions + Rules + Flutter/Android CI PASS.
- [ ] PR #48 squash merge edildi.
- [ ] Client production SSV akışı bağlandı.
- [ ] Kontrollü deploy/callback/fiziksel kabul tamamlandı.

---

## P2 - Görsel ve pazarlama

### BR-P2-001 - 3B tahta için 6 rozet eşlemesini çöz

**Durum:** DURDURULDU / KARAR BEKLİYOR

Çalışmaya yeniden başlamadan önce gerçek 6 kategori ve 8 konsept arasındaki seçim netleşmeli.

### BR-P2-002 - Numaralı geometri önizlemesi

67 node deterministik debug katmanında doğrulanacak. Oynanış, BoardMap ve node sırası değişmeyecek; görsel onay olmadan stil/Flutter/APK yok.

---

## P3 - Yayın sonrası

- Dünya Turnuvası
- Gelişmiş lig sezonları
- Klan
- Raid
- Günün Sorusu
- Dünya Haritası
- Arkadaşımla Oyna oda kodu
