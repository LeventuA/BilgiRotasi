# Bilgi Rotası - Görev Havuzu

**Güncel kesim:** 20 Ağustos 2026

> 19 Ağustos 2026 ve öncesindeki ayrıntılı görev havuzu denetim izi Git geçmişinde ve önceki blob `538e1055d50c831dad7111de5a91a4f49809a0fb` içinde aynen korunur. Bu dosya, güncel çalışmayı öne almak ve tarihsel/bayat durumların yeni görevleri gölgelemesini önlemek için aktif görevler odaklı tutulur. Ayrıntılı teknik tarihçe `BILGI_ROTASI_DURUM.md`, `ACIK_SORULAR_VE_DOGRULAMALAR.md` ve checkpoint dosyalarında da korunur.

## BR-P0-014 - Issue #73 / Draft PR #74 Kelime Avı foundation ve home hub CI

**Durum:** DRAFT PR #74 / FOUNDATION + İZOLE PROTOTİP HAZIR / RESPONSIVE CI BLOCKER GİDERİLDİ / MERGE-PREP HEAD #302 FULL CI SUCCESS / PR GÖVDESİ GÜNCEL / GÖRSEL ONAY + STORAGE AYRI / MERGE YOK

- Kanonik release tabanı: `release/final-closed-test-aab-1.68.8`.
- PR başlangıç base SHA: `9331802b9a2b12d1f4ec6715da96dc7d0f60b24b`.
- Sürüm: `1.68.17+107`.
- Branch: `feat/home-word-hunt-foundation-20260820`.
- Issue: #73.
- Draft PR: #74.
- Canlı PR kapsamı: **24 dosya**; `docs/kelime-avi`, proje-hafızası/checkpoint kayıtları, `lib/word_hunt/*` ve ilgili `test/*`.
- Foundation: `Başlangıç Limanı` 10 bölüm / 30 yıldız / 6 bilgi kartı; 8 yönlü seçim yolu; progress codec; validator; yıldız puanlama; izole 6×6 bölüm ve home hub prototipleri.
- İlk kırmızı head: `0ac0ef303936221f0c923701f974b3f8be00a83f`.
- İlk kırmızı run: `32348243734`.
- Runtime düzeltme commit'i: `a9bb89ed1f80790ddbe9c81e79d83d2347c2e2da` — `fix: stabilize home hub responsive layout`.
- Bu commit üzerindeki run `32361294613` / job `96401221605` dar `360×800` regresyonunu PASS etti. Kalan tek hata, varsayılan `800×600` widget test yüzeyinde ekran dışında kalan `Günlük Görevler` kartına scroll etmeden `tap()` yapılmasıydı (`Expected 1 / Actual 0`).
- Test düzeltme commit'i: `c377e9043b039c2e1368704fcd875cc60bf8f597` — `test: scroll home hub daily card into view`.
- Exact teknik head `c377e904...` üzerinde AdMob PR doğrulaması #297 / run `32361507978` / job `96401878115`: `Analiz ve tüm testler` **SUCCESS**.
- Checkpoint commit'i: `6b8b956e9e4d151dd4cb35582ea74bdf3cf59374` — `docs: refresh word hunt checkpoint`.
- Durum dosyası commit'i: `0a9eafd9a2e149071fcc89a6213e2ab889541f51` — `docs: record word hunt CI checkpoint`.
- PR kapsam düzeltme head'i `343ebf2d9241888bdbcd31536f79bd62720191ac` üzerinde AdMob PR doğrulaması #301 / run `32362882273`: **SUCCESS**; head SHA ve base SHA canlı workflow metadata'sıyla eşleşir.
- Merge-prep docs head `fcc713f6094f3a826aaa199ed1d956afd289fc88` üzerinde AdMob PR doğrulaması #302 / run `32377129911` / job `96451136017`: **SUCCESS**. Analyze + tüm testler, kalıcı Android imzası, release APK, package/manifest ve Android 16 ilk deneme/final app gate PASS; ikinci temiz emulator gerekmedi.
- #302 artifact: `BilgiRotasi-AdMob-1.68.17-107-kanitlari`, ID `9409986778`, digest `sha256:7b650d890cd7771f372d2ca69b90e6f84560b139227161640633d92a99f1fec6`; indirilen ZIP hash'i digest ile birebir eşleşti. Android 16 `RESULT/APP_GATE/RELEASE_GATE=PASS`; PID `1866`; Bilgi Rotası'na ait FATAL/ANR/crash/process-death eşleşmesi yok.
- PR #74 gövdesi gerçek 24 dosyalık kapsam, `fcc713f...` final merge-prep CI ve artifact kanıtıyla güncellendi; PR Draft kaldı ve merge edilmedi.
- Bundan sonraki docs-only bookkeeping commitleri final CI kanıtını statik SHA zinciriyle sonsuza kadar kovalamaz. Draft'tan çıkarma veya merge gibi kritik geçişten hemen önce **canlı mevcut HEAD** ve onun workflow/log/artifact sonucu yeniden okunur.
- `assets/questions.json`, `lib/main.dart`, mevcut Bilgi Oyunu oynanışı/ana navigasyon, BoardMap/67 node/3B, Firebase/AdMob/Play config ve `pubspec.yaml` değiştirilmedi.
- `KARARLAR.md` değişmedi.

**Bitti ölçütü:**

- [x] Canlı base/branch/sürüm/PR durumu doğrulandı; `main` güncel varsayılmadı.
- [x] Canlı **24 dosyalık** PR kapsamı ve korunan alanlar doğrulandı.
- [x] Responsive runtime blocker minimum diff ile giderildi; `360×800` regresyonu PASS.
- [x] Off-screen günlük kart test problemi tam CI logundan kanıtlandı ve gerçek scroll davranışına hizalandı.
- [x] Exact teknik head üzerinde analyze + tüm Flutter testleri + diff check PASS.
- [x] PR kapsam düzeltme head'i `343ebf2...` üzerinde AdMob PR doğrulaması #301 / run `32362882273` SUCCESS.
- [x] `BILGI_ROTASI_DURUM.md`, `GOREV_HAVUZU.md` ve Kelime Avı checkpoint'i 24 dosyalık gerçek kapsama hizalandı; yeni karar olmadığı için `KARARLAR.md` değişmedi.
- [x] Merge-prep head `fcc713f...` üzerinde AdMob PR doğrulaması #302 / run `32377129911` tam workflow/artifact/Android 16 kapılarıyla SUCCESS.
- [x] PR #74 gövdesi gerçek 24 dosyalık kapsam ve `fcc713f...` final merge-prep CI kanıtıyla güncellendi; Draft durumda kaldı.
- [x] Kullanıcı görsel/onay turu olmadan mevcut ana navigasyona entegrasyon yapılmadı; entegrasyon ayrıca onaylandıktan sonra ele alınır.
- [x] Ayrı açık merge onayı olmadan PR #74 release'e merge edilmedi.

**Sonraki faz kapısı:** foundation/izole prototip hazırlığı teknik olarak tamamlandı. Kullanıcı görsel onayı ve gerçek hesap-scope persistent storage/entegrasyon ayrı kontrollü görevlerdir. Draft/merge durum değişikliğinden hemen önce canlı PR HEAD ve CI yeniden doğrulanır.

---

## BR-P0-015 - Issue #67 production AdMob/Firebase SSV canlı cutover

**Durum:** RELEASE KODU HAZIR / `ssvEnabled` KAPALI / CANLI CALLBACK REDEPLOY + VERIFY URL + FİZİKSEL KABUL AÇIK

- Kanonik release ve ayrıntılı kanıt `BILGI_ROTASI_DURUM.md` bölüm 0L/0K ile `ACIK_SORULAR_VE_DOGRULAMALAR.md` içinde tutulur.
- Percent-decoding düzeltmesi release'e ulaşmıştır; yeni callback kodunun production revision'a selective redeploy'u ve AdMob `Verify URL` tekrar denemesi açık kalır.
- Blanket Functions deploy yapılmaz; `ssvEnabled=true` yalnız tüm canlı kapılar ve ayrıca açık cutover onayı sonrası değerlendirilir.

**Bitti ölçütü:**

- [ ] Yalnız `rewardedSsvCallback` güncel kodla kontrollü/selective redeploy edilir.
- [ ] Normal callback disabled durumda yine `503 SSV_NOT_ENABLED` verir.
- [ ] Legacy AdMob `Verify URL` geçerli imzayla `200 SSV_VERIFY_OK` verir ve verify-only sırasında Firestore write oluşmaz.
- [ ] Fiziksel gerçek rewarded: tek tamamlanan oyun = tek +10 XP; aynı gameId no-double; yarım/başarısız reklamda hak korunur; farklı oyunlarda toplam kota yok.
- [ ] Tüm kapılar ve ayrı cutover onayı olmadan `ssvEnabled` açılmaz.

---

## BR-P0-002 - Açık soru geri bildirimlerini gerçek kayıtlarla düzelt

**Durum:** AÇIK

- Soru geri bildirim havuzundaki açık kayıtlar ayrı branch/PR akışında ele alınır.
- Her soru için metin, dört seçenek, doğru indeks, açıklama, kategori ve zorluk birlikte doğrulanır.
- `assets/questions.json` kontrolsüz değiştirilmez.
- Sheet kaydı gerçek soru düzeltmesi merge edilmeden kapatılmaz.

**Bitti ölçütü:** gerçek JSON kaydı doğrulandı → test/QA PASS → ayrı PR merge edildi → ilgili Sheet kaydı ancak bundan sonra kapatıldı.

---

## BR-P1-003 - Canlı Düello fiziksel release kabulü

**Durum:** AÇIK / FİZİKSEL KABUL GEREKİYOR

**Bitti ölçütü:** iki ayrı güncel cihaz/hesapta 10/20/30 seçenekleri, otomatik eşleştirme, aynı soru/sıra, skor/ilerleme, maç sonucu, BR/lig tek-sefer işleme, leaderboard ve kopma/ayrılma akışları uçtan uca PASS.

---

## BR-P1-004 - UMP testi

**Durum:** AÇIK

Türkiye dışı uygun test bölgesi/debug yöntemiyle UMP onay formı doğrulanır; Analytics consent ile UMP consent karıştırılmaz.

---

## BR-P1-010 - Play/Firebase signing SHA rollerini canlı konsoldan kesinleştir

**Durum:** AÇIK / DOĞRULANACAK

Play Console uygulama imzalama ve upload sertifika SHA-1 ekranı ile Firebase Android fingerprint listesi canlı karşılaştırılır; roller tahminle eşlenmez.

---

## BR-P1-012 - Eski config-level GitHub Actions teknik borcu

**Durum:** AÇIK / AYRI TEKNİK BORÇ

Eski `apply-game-save-isolation-v4.yml` config-level workflow hatası uygulama/release kodundan ayrı incelenir; 0-job kırmızı koşular uygulama testi olarak yorumlanmaz.

---

## BR-P2-001 - 3B tahta 8 rozet / 6 fiziksel pozisyon eşlemesi

**Durum:** DURDURULDU / KARAR BEKLİYOR

- Oynanış, BoardMap ve 67 node düzenine dokunulmaz.
- Önce 8 kategori rozeti ile 6 fiziksel rozet noktası eşleştirilir.
- Sonra numaralı deterministik geometri doğrulanır.
- Kullanıcı görsel onayı olmadan stil/Flutter/APK aşamasına geçilmez.
- Bütün 2B sahneyi tek Matrix4 ile eğme yaklaşımı kullanılmaz.

---

## BR-P2-003 - Profesyonel tanıtım videosu

**Durum:** AÇIK

Eski yetersiz setleri final kabul etme. Gerçek kurgu, efekt, ses ve güçlü açılış üret.

---

## BR-P2-004 - Mağaza varlık denetimi

**Durum:** AÇIK

Telefon, tablet, Chromebook, PC ve XR varlıklarının `hazır / yüklendi / reddedildi / yeniden yapılacak` durumu canlı Play Console ile kaydedilir.

---

## P3 - Yayın sonrası ürün havuzu

- Dünya Turnuvası
- Gelişmiş lig sezonları
- Klan
- Raid
- Günün Sorusu
- Dünya Haritası
- Arkadaşımla Oyna oda kodu
