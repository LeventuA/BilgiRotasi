# Bilgi Rotası - Güncel Proje Durumu

**Son canlı doğrulama:** 6 Ağustos 2026  
**Durum sınıfları:** `DOĞRULANDI`, `UYGULANDI`, `RAPORLANDI`, `AÇIK`, `DURDURULDU`, `DOĞRULANACAK`

---

## 1. Yayın ve çalışma kaynağı

| Alan | Güncel değer | Durum |
|---|---|---|
| Kanonik repo | `ZMilaStudio/BilgiRotasi` | DOĞRULANDI |
| Eski repo adı | `LeventuA/BilgiRotasi` | ESKİ SAHİPLİK / güncel işlem adresi değil |
| Android paket adı | `com.leventua.bilgirotasi` | DOĞRULANDI |
| Yayın/release dalı | `release/final-closed-test-aab-1.68.8` | DOĞRULANDI |
| Release head | `548e8d3046469688a8dcb050552956cf786e525c` | DOĞRULANDI |
| Release son commit | `docs: Bilgi Rotası proje hafızası V2` | DOĞRULANDI |
| Gerçek paket sürümü | `1.68.13+103` | DOĞRULANDI (`pubspec.yaml`) |
| Birleşik güncelleme dalı | `update/closed-test-next-release` | DOĞRULANDI |
| Birleşik güncelleme PR'ı | PR #13 | AÇIK / DRAFT / MERGE EDİLMEDİ |
| PR #13 tabanı | `release/final-closed-test-aab-1.68.8` | DOĞRULANDI |
| PR #13 merge durumu | Çatışmasız / `mergeable: true` | DOĞRULANDI |
| Ödüllü reklam düzeltme commit'i | `f9d5ab900d0644a969d251ee9fd8e814650857af` | DOĞRULANDI / CI PASS |
| `main` dalı | Güncel yayın kaynağı değil | KESİN KARAR |
| PR #7 | Açık, Draft, merge edilmemiş | DOĞRULANDI |
| PR #6 | Açık, Draft; eski hotfix hattı | DOĞRULANDI / güncel taban değil |
| PR #12 | Açık, Draft; deterministik 67-node geometri | DOĞRULANDI / birleşik güncellemeden ayrı |

`update/closed-test-next-release` dalı release ile aynı `548e8d3...` commitinden başlamıştır. Doğrudan `main` veya release dalına yazılmamıştır.

**Kural:** Branch adındaki `1.68.8`, paket sürümü değildir. Sürüm hedef dalın `pubspec.yaml` dosyasından okunmalıdır.

---

## 2. Google Play Kapalı Test

6 Ağustos 2026 tarihli Play Console ekranlarından raporlanan durum:

- Aktif sürüm: `1.68.13`
- Sürüm kodu: `103`
- Yayın tarihi: 4 Ağustos 2026, 09:49
- Test listesinde bulunan kişi: 20
- Google'ın katılımcı saydığı kişi: 12
- 14 günlük sürede geçen süre: 2 gün

Bu çalışma sırasında Play Console'a yeni yükleme veya yayın yapılmamıştır.

**Kural:**

- Kapalı test duraklatılmayacak.
- Testçi listesinden kimse çıkarılmayacak.
- Yalnız soru düzeltmeleri için ayrı APK/AAB çıkarılmayacak.
- Levent açıkça onaylamadan merge veya Play Console yayını yapılmayacak.

---

## 3. Soru bankası ve geri bildirimler

Son raporlanan aktif soru sayısı: **8.710**.

6 Ağustos 2026 canlı Sheet özeti:

- Toplam bekliyor: 73
- Soru hatalı bildirimi: 28
- Benzersiz hatalı soru: 26
- Zorluk bildirimi: 44
- Diğer kayıt: 1
- Son eklenen hatalı soru: `q56421`

İlk doğrulanan örnekler:

- `q61081`: Soru “ilk kez hangi yıl” biçiminde netleştirilmeli; cevap 2009.
- `q60513`: Doğru cevap Anadolu yaban koyunu; şıklar yeniden hazırlanmalı.
- `q60872`: Doğru cevap Busenaz Sürmeneli; şıklar yeniden hazırlanmalı.
- `q60813`: Doğru cevap Sırbistan; diğer şıklar aynı bağlamda hazırlanmalı.
- `q60766`: Doğru cevap Anadolu Efes; diğer şıklar aynı bağlamda hazırlanmalı.

### 6 Ağustos çalışma sonucu

Bağlı GitHub aracında `assets/questions.json` çok büyük ve tek satırlı olduğu için içerik güvenilir biçimde okunamamıştır. Kod araması da bu dosyadaki hedef kimlikleri döndürmemiştir. Bu nedenle:

- `assets/questions.json` değiştirilmedi.
- Hiçbir soru için tahmine dayalı yama yapılmadı.
- Sheet satırları kapatılmadı.
- Soru düzeltme işi `DOĞRULANACAK/AÇIK` kaldı.

Soru düzeltmesine ancak canlı JSON kayıtları eksiksiz okunabildiğinde devam edilecek. Her kayıt için metin, dört seçenek, doğru indeks, açıklama, kategori ve zorluk birlikte kontrol edilecek.

Ayrıntılı liste: `SORU_GERI_BILDIRIM_HAVUZU.md`.

---

## 4. Soru geri bildirim taşıma sistemi

- Eski cihaz kuyruğundaki kayıtların Sheet'e aktarılabildiği raporlandı.
- `1.68.13+103` sürümünden kuyruk dışı canlı kayıtlar Sheet'e ulaştı.
- Taşıma sistemi çalışıyor kabul edilir.
- İçerik temizliği tamamlanmadı.
- Sheet kayıtları gerçek soru düzeltmesi merge edilip doğrulanmadan kapatılmayacak.

**Durum:** Taşıma `DOĞRULANDI`; içerik temizliği `AÇIK`.

---

## 5. Ödüllü reklam ve joker sistemi

### Tahtadaki reklam

Tahtadaki **Rastgele Joker Kazan** reklamı XP vermez. Reklam tamamlanınca şu dört jokerden biri rastgele `+1` olur:

- 50:50
- Soru Değiştir
- İkinci Şans
- Kategori Değiştir

Bu akışa, BoardMap'e, oynanışa veya 67 node düzenine dokunulmamıştır.

### Sonuç ekranındaki destek reklamı

Kesin ürün kararı:

- Her tamamlanan oyun bir reklam hakkı üretir.
- Aynı tamamlanan oyun ikinci kez ödül vermez.
- Yeni tamamlanan oyun yeni hak üretir.
- Günlük veya oturumluk toplam sınır yoktur.
- Ödül `+10 XP`'dir.

PR #13 kapsamındaki `update/closed-test-next-release` dalında:

- günlük tarih ve sayaç sınırı kaldırıldı,
- boş oyun kimliği reddedildi,
- aynı oyun kimliğinin ikinci talebi kalıcı olarak engellendi,
- eski 200 kayıt budaması kaldırıldı; çok eski oyunların tekrar hak kazanması önlendi,
- bütün hak kayıtları tek seri kuyrukta yürütülerek eşzamanlı farklı oyun taleplerinin birbirini ezmesi önlendi,
- reklam tamamlanmaz veya ödül callback'i gelmezse kalıcı hak yeniden okunarak aynı ekranda tekrar deneme açık bırakıldı,
- farklı tamamlanan oyunlar için genel kota kaldırıldı,
- sonuç ekranındaki eski günlük kota metinleri temizlendi,
- ilgili birim ve regresyon testleri yeni karara göre güncellendi.

Eklenen regresyon testleri:

- aynı oyun yalnız bir kez,
- farklı oyunlara genel kota yok,
- 250 oyundan sonra ilk oyun tekrar açılamaz,
- eşzamanlı aynı taleplerden yalnız biri kazanır,
- eşzamanlı farklı oyun taleplerinin ikisi de kalıcı tutulur,
- boş kimlik reddedilir,
- yeni limiter örneğinde de tekrar verilmez,
- reklam callback'i başarısızsa XP verilmez,
- başarısız reklamdan sonra hak duruyorsa kart yeniden denenebilir,
- gerçek ödül verildiyse sonuç kartı yeniden açılmaz.

Kod ve test commit'i: `f9d5ab900d0644a969d251ee9fd8e814650857af` (`fix: ödüllü reklam hakkını yarış koşullarına karşı koru`).

**Durum:** `UYGULANDI — DRAFT PR #13 AÇIK — CI PASS — FİZİKSEL CİHAZ KABULÜ DOĞRULANACAK`.

---

## 6. CI doğrulaması

`.github/workflows/admob-pr-validation.yml` push koşusu, ödüllü reklam düzeltme commit'i `f9d5ab900d0644a969d251ee9fd8e814650857af` üzerinde tamamlandı.

Canlı kanıt:

- Workflow: `AdMob PR doğrulaması`
- Run ID: `31111600703`
- Tetikleyici: `push`
- Branch: `update/closed-test-next-release`
- Job: `analyze-test-release-cold-start`
- Job ID: `92650502426`
- Sonuç: `success`

Başarıyla tamamlanan kapılar:

- Flutter bağımlılık grafiği,
- `flutter analyze`,
- tüm Flutter testleri,
- production AdMob kimlik testi,
- `git diff --check`,
- kalıcı anahtarla imzalı release APK,
- paket/sürüm/manifest/AdMob App ID kontrolü,
- sertifika SHA-1 kontrolü,
- Android bağımlılık kontrolü,
- Android 16 emülatör cold-start, uygulama PID ve logcat kontrolü,
- APK ve kanıt artifact yükleme.

Artifact kanıtı:

- Artifact ID: `5395999980`
- Ad: `bilgi-rotasi-release-apk`
- Boyut: `60.922.207` bayt
- SHA-256: `caf6033b51d233a9bce633b8ca19f69ab91ff2160c33b11b0ec7e50dc36eafd9`
- Süresi dolmuş değil.

Workflow tetikleyici kapsamındaki önceki değişiklikler korunmuştur:

- PR tabanı olarak `release/final-closed-test-aab-1.68.8`,
- push dalı olarak `update/closed-test-next-release`,
- yalnız `docs/project-memory/**` değişikliklerinde ağır Android doğrulamasını atlayan `paths-ignore`.

**Durum:** Otomatik CI `DOĞRULANDI / PASS`. Fiziksel cihazda gerçek rewarded reklam ve XP kabulü ayrı olarak `DOĞRULANACAK`.

---

## 7. 3B oyun tahtası

- Oynanış ve BoardMap değişmeyecek.
- Tahta sözleşmesi 67 noktadır:
  - 30 dış kategori,
  - 30 iç kategori,
  - 6 rozet,
  - 1 merkez.
- Tek Matrix4 ile bütün 2B tahtayı eğme yaklaşımı kullanılmayacak.
- PR #12 deterministik numaralı geometri çalışmasıdır; birleşik güncelleme dalına merge edilmemiştir.
- 8 kategori rozeti ile 6 fiziksel rozet noktası eşlemesi hâlâ açıktır.
- Kullanıcı onayı olmadan stil, Flutter veya APK aşamasına geçilmeyecektir.

---

## 8. Cihaz doğrulaması

Cihaz gerektiren ve bu çalışma kapsamında tamamlanamayan doğrulamalar:

- gerçek ödüllü reklamın gösterilmesi,
- reklam tamamlanmadan kapatıldığında ödül verilmemesi ve hakkın yeniden denenebilmesi,
- gerçek `+10 XP` yazımı,
- aynı oyun sonucunda ikinci reklam hakkının kapalı kalması,
- yeni tamamlanan oyunda yeni hakkın açılması,
- production Firebase açıkken sonuç reklamı kartının beklenen ürün davranışı,
- tahtadaki rastgele joker reklamının korunması,
- Google giriş,
- fiziksel Android 16 cold-start ve logcat,
- iki telefonlu Canlı Düello,
- Play Console kapalı test kabulü.

---

## 9. Mağaza ve tanıtım

Hazırlanan varlıklar arasında:

- 8 telefon görseli
- Tablet görsel seti planı/çalışması
- 600 x 400 PC logosu
- 6 PC ekran görüntüsü
- 6 Android XR görseli
- Instagram kare görsel seti

bulunuyor.

Tanıtım videolarının 15/30/60 saniyelik birçok seti üretildi; onaylı final tanıtım videosu yoktur.

Ayrıntı: `MAGAZA_VE_TANITIM_VARLIKLARI.md`.

---

## 10. Bu çalışma sonunda kanıt

- Branch: `update/closed-test-next-release`
- Base: `release/final-closed-test-aab-1.68.8`
- Release base SHA: `548e8d3046469688a8dcb050552956cf786e525c`
- Kod/test commit'i: `f9d5ab900d0644a969d251ee9fd8e814650857af`
- Draft PR: #13
- PR durumu: açık, Draft, merge edilmemiş, çatışmasız
- Değiştirilen uygulama dosyası: `lib/ad_monetization.dart`
- Değiştirilen test dosyası: `test/ad_monetization_test.dart`
- CI run: `31111600703` / PASS
- CI job: `92650502426` / PASS
- Release APK artifact: `5395999980`
- Soru bankası: değiştirilmedi
- Sürüm: artırılmadı (`1.68.13+103`)
- Merge: yapılmadı
- Play Console yayını: yapılmadı

---

## 11. Sıradaki işler

1. Fiziksel cihazda sonuç ekranı rewarded reklam ve `+10 XP` kabul testlerini çalıştır.
2. Production Firebase açıkken sonuç reklamının beklenen ürün davranışını netleştir ve doğrula.
3. Büyük canlı `assets/questions.json` dosyasını güvenilir bir repo checkout'u veya dosya indirme yöntemiyle oku.
4. 26 benzersiz hatalı soruyu topluca incele ve doğrulanan düzeltmeleri aynı birleşik güncellemeye ekle.
5. Zorluk bildirimlerinde tek kullanıcı oyuyla kör değişiklik yapma.
6. Levent onayı olmadan merge veya Play Console yayını yapma.
