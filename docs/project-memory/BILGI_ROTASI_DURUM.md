# Bilgi Rotası - Güncel Proje Durumu

**Son canlı doğrulama:** 7 Ağustos 2026  
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
| Release son commit | `docs: Bilgi Rotası proje hafızası V2` | DOĞRULANDI / yalnız belge |
| Gerçek paket sürümü | `1.68.13+103` | DOĞRULANDI (`pubspec.yaml`) |
| Son işlevsel release commit'i | `34e8df9291ff070f333ea4e6d375b48ed7d01754` | DOĞRULANDI / PR #10 merge |
| Birleşik güncelleme dalı | `update/closed-test-next-release` | DOĞRULANDI |
| Birleşik güncelleme PR'ı | PR #13 | AÇIK / DRAFT / MERGE EDİLMEDİ |
| PR #13 tabanı | `release/final-closed-test-aab-1.68.8` | DOĞRULANDI |
| PR #13 merge durumu | Çatışmasız / `mergeable: true` | DOĞRULANDI |
| Ödüllü reklam düzeltme commit'i | `f9d5ab900d0644a969d251ee9fd8e814650857af` | DOĞRULANDI / CI PASS |
| `main` dalı | Güncel yayın kaynağı değil | KESİN KARAR |
| PR #7 | `release: Bilgi Rotası 1.68.13+103 kapalı test hattı` | AÇIK / DRAFT / MERGE EDİLMEDİ |
| PR #6 | Eski `1.68.7+97` hotfix | KAPALI / MERGE EDİLMEDİ / YERİNE RELEASE HATTI GEÇTİ |
| PR #9 | Merge commit `25f283d87875c766697e43a7b0b9655ceff752b6` | MERGE EDİLDİ / RELEASE İÇİNDE |
| PR #10 | Merge commit `34e8df9291ff070f333ea4e6d375b48ed7d01754` | MERGE EDİLDİ / RELEASE İÇİNDE |
| PR #11 | Merge commit `548e8d3046469688a8dcb050552956cf786e525c` | MERGE EDİLDİ / YALNIZ PROJE BELGELERİ |
| PR #12 | Açık, Draft; deterministik 67-node geometri | DOĞRULANDI / BİRLEŞİK GÜNCELLEMEDEN AYRI / CODEX'E BIRAKILDI |

`update/closed-test-next-release` dalı release ile aynı `548e8d3...` commitinden başlamıştır. Doğrudan `main` veya release dalına yazılmamıştır.

Canlı commit karşılaştırmaları:

- Güncel release, PR #6 head commit'inin 45 commit ilerisinde ve 0 commit gerisindedir; PR #6 bu nedenle `superseded` olarak kapatıldı.
- Güncel release, PR #9 merge commit'inin 3 commit ilerisinde ve 0 commit gerisindedir.
- Güncel release, PR #10 merge commit'inin 1 commit ilerisinde ve 0 commit gerisindedir.
- PR #10 sonrasındaki tek commit PR #11'in proje hafızası belgesidir; uygulama kodunu değiştirmemiştir.

**Kural:** Branch adındaki `1.68.8`, paket sürümü değildir. Sürüm hedef dalın `pubspec.yaml` dosyasından okunmalıdır.

---

## 2. Google Play Kapalı Test ve geliştirici doğrulaması

### Kapalı test

7 Ağustos 2026 Play Console üretim erişimi ekranından canlı doğrulanan durum:

- Google'ın geçerli saydığı test kullanıcısı: **12**
- 12 test kullanıcısıyla kesintisiz geçen süre: **4 gün**
- Gereken süre: **14 gün**
- Kalan süre, sayaç kesintisiz ilerlerse yaklaşık **10 gün**
- `Üretime başvur` düğmesi henüz kapalı; 14 günlük koşul tamamlanmadı.

Son doğrulanan kapalı-test sürümü:

- Aktif sürüm: `1.68.13`
- Sürüm kodu: `103`
- Yayın tarihi: 4 Ağustos 2026, 09:49
- Test listesinde bulunan kişi: 20

Kesin bitiş tarih/saatini Play Console belirler. 4 günlük sayaçtan hareketle 17 Ağustos 2026 civarı beklenebilir; bu tarih kesin kabul edilmeyecek ve canlı sayaçla doğrulanacaktır.

### Android geliştirici doğrulaması

7 Ağustos 2026 Play Console ekranlarından:

- Hesap ana sayfası, **tüm uygulamaların Android geliştirici doğrulaması şartlarını karşılamak için başarıyla kaydedildiğini** bildiriyor.
- Bilgi Rotası paket adı `com.leventua.bilgirotasi` durum olarak **Kayıtlı** görünüyor.
- Paket kaydında **3 anahtar** görünüyor.
- Paket kaydının son güncelleme tarihi: **1 Ağustos 2026**.
- Kimlik bilgileri Play Console geliştirici hesabından alınıyor; ek doğrulama hatası görünmüyor.
- Yeni paket adı kaydı veya yeni imza anahtarı oluşturma gerekmiyor.

**Durum:** Android geliştirici doğrulaması `DOĞRULANDI / TAMAM`.

Bu çalışma sırasında Play Console'a yeni yükleme veya yayın yapılmamıştır.

Release dalında imzalı kapalı-test AAB üreten workflow doğrulandı:

- Giriş workflow'u: `.github/workflows/android-apk.yml`
- Çekirdek workflow: `.github/workflows/closed-test-release-core.yml`
- Tetikleyici: `workflow_dispatch` ve `CLOSED_TEST` onayı
- Yapılandırma: production Firebase + Google demo/test AdMob kimlikleri
- Çıktı: `BilgiRotasi-<sürüm>-<kod>-closed-test.aab`
- Doğrulama: AAB sürüm/manifest/imza, Firebase/AdMob profili ve Android 16 cold-start

Play Console'a yüklenen `1.68.13+103` AAB'nin özgül workflow_dispatch run ID'si ve artifact SHA-256 değeri mevcut GitHub bağlantısından doğrulanamadı. PR #10 üzerindeki başarılı APK artifact'i AAB kanıtı sayılmadı. Kesin AAB-run eşleşmesi `DOĞRULANACAK` olarak kalır.

**Kural:**

- Kapalı test duraklatılmayacak.
- Testçi listesinden kimse çıkarılmayacak.
- Geçerli testçi sayısı 12'nin altına düşürülmeyecek; mümkünse birkaç ek geçerli testçiyle güvenlik payı korunacak.
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

### PR #13 ödüllü reklam doğrulaması

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

### PR #10 / `1.68.13+103` release kod doğrulaması

PR #10 merge commit'i `34e8df9291ff070f333ea4e6d375b48ed7d01754` üzerinde:

- Workflow: `AdMob PR doğrulaması`
- Run ID: `30864581523`
- Job ID: `91853543414`
- Sonuç: `success`
- Flutter analiz ve tüm testler: PASS
- İmzalı release APK, paket/sürüm/manifest/sertifika: PASS
- Android 16 cold-start: PASS
- Artifact ID: `8879320751`
- Artifact: `BilgiRotasi-AdMob-1.68.13-103-kanitlari`
- Artifact SHA-256: `3e8015f512b7710c9997aa7cad854f59aeee796cc2e72d9a3c3d5538f7174f69`

Bu ikinci artifact test AdMob kimlikli release APK kanıtıdır; Play Console'a yüklenen AAB değildir.

Workflow tetikleyici kapsamındaki önceki değişiklikler korunmuştur:

- PR tabanı olarak `release/final-closed-test-aab-1.68.8`,
- push dalı olarak `update/closed-test-next-release`,
- yalnız `docs/project-memory/**` değişikliklerinde ağır Android doğrulamasını atlayan `paths-ignore`.

**Durum:** Otomatik CI `DOĞRULANDI / PASS`. Fiziksel cihazda gerçek rewarded reklam ve XP kabulü ayrı olarak `DOĞRULANACAK`. Play'e yüklenen AAB'nin özgül run/artifact eşleşmesi de `DOĞRULANACAK`.

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
- Play Console'da 12 test kullanıcısının 14 günlük kesintisiz koşulu tamamlaması.

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
- Son işlevsel release commit'i: `34e8df9291ff070f333ea4e6d375b48ed7d01754`
- Kod/test commit'i: `f9d5ab900d0644a969d251ee9fd8e814650857af`
- Draft PR: #13
- PR durumu: açık, Draft, merge edilmemiş, çatışmasız
- PR #6: kapalı, merge edilmemiş, superseded
- PR #7: açık, Draft; başlık ve release envanteri güncellendi
- PR #9 ve PR #10: release içinde doğrulandı
- PR #12: değiştirilmedi; 3B tahta çalışması Codex'e bırakıldı
- CI run: `31111600703` / PASS
- CI job: `92650502426` / PASS
- PR #13 release APK artifact: `5395999980`
- PR #10 CI run: `30864581523` / PASS
- PR #10 release APK artifact: `8879320751`
- Play Console: 12 geçerli test kullanıcısı / 4 kesintisiz gün
- Android geliştirici doğrulaması: tüm uygulamalar başarıyla kaydedilmiş / Bilgi Rotası paketi Kayıtlı
- Soru bankası: değiştirilmedi
- Sürüm: artırılmadı (`1.68.13+103`)
- Merge: yapılmadı
- Play Console yayını: yapılmadı

---

## 11. Sıradaki işler

1. Kapalı testte en az 12 geçerli testçiyi kesintisiz tut; mümkünse birkaç ek geçerli testçiyle güvenlik payı oluştur.
2. Play Console sayacını periyodik kontrol et; 14 gün tamamlanınca `Üretime başvur` aşamasını birlikte doldur.
3. Fiziksel cihazda sonuç ekranı rewarded reklam ve `+10 XP` kabul testlerini çalıştır.
4. Production Firebase açıkken sonuç reklamının beklenen ürün davranışını netleştir ve doğrula.
5. Play Console'a yüklenen `1.68.13+103` AAB'nin workflow_dispatch run ID'sini ve artifact SHA-256 değerini canlı Actions/Play kanıtıyla eşleştir.
6. Büyük canlı `assets/questions.json` dosyasını güvenilir bir repo checkout'u veya dosya indirme yöntemiyle oku.
7. 26 benzersiz hatalı soruyu topluca incele ve doğrulanan düzeltmeleri aynı birleşik güncellemeye ekle.
8. Zorluk bildirimlerinde tek kullanıcı oyuyla kör değişiklik yapma.
9. Levent onayı olmadan merge veya Play Console yayını yapma.