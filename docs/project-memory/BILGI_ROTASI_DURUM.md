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
| `main` dalı | Güncel yayın kaynağı değil | KESİN KARAR |
| PR #7 | Açık, Draft, merge edilmemiş | DOĞRULANDI |
| PR #6 | Açık, Draft; eski hotfix hattı | DOĞRULANDI / güncel taban değil |
| PR #12 | Açık, Draft; deterministik 67-node geometri | DOĞRULANDI / birleşik güncellemeden ayrı |

`update/closed-test-next-release` dalı 6 Ağustos 2026'da release ile aynı `548e8d3...` commitinden başlamıştır. Doğrudan `main` veya release dalına yazılmamıştır.

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

Canlı kodda eski günlük üç reklam sınırı `SupportRewardLimiter` içinde doğrulandı. `update/closed-test-next-release` dalında:

- günlük tarih ve sayaç sınırı kaldırıldı,
- boş oyun kimliği reddedildi,
- aynı oyun kimliğinin ikinci talebi engellendi,
- farklı tamamlanan oyunlar için genel kota kaldırıldı,
- son 200 oyun kimliği saklanmaya devam edildi,
- ilgili birim testleri yeni karara göre güncellendi.

**Durum:** `UYGULANDI — TEST/CI/PR BEKLİYOR`. Fiziksel reklam gösterimi ve gerçek XP kabulü cihaz olmadan doğrulanamaz.

---

## 6. 3B oyun tahtası

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

## 7. CI ve cihaz doğrulaması

Ödüllü reklam değişikliği için birim test dosyası güncellendi; ancak bu kayıt yazılırken GitHub Actions sonucu henüz alınmamıştır. Test geçmeden görev `BİTTİ` sayılmaz.

Cihaz gerektiren ve bu çalışma kapsamında tamamlanamayan doğrulamalar:

- gerçek ödüllü reklamın gösterilmesi,
- reklam tamamlanmadan kapatıldığında ödül verilmemesi,
- gerçek `+10 XP` yazımı,
- Google giriş,
- Android 16 cold-start ve logcat,
- iki telefonlu Canlı Düello,
- Play Console kapalı test kabulü.

---

## 8. Mağaza ve tanıtım

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

## 9. Sıradaki işler

1. Ödüllü reklam diff'ini ve birim testleri CI ile doğrula.
2. `update/closed-test-next-release` dalından release dalına Draft PR aç.
3. Büyük canlı `assets/questions.json` dosyasını güvenilir bir repo checkout'u veya dosya indirme yöntemiyle oku.
4. 26 benzersiz hatalı soruyu topluca incele ve doğrulanan düzeltmeleri aynı birleşik güncellemeye ekle.
5. Zorluk bildirimlerinde tek kullanıcı oyuyla kör değişiklik yapma.
6. Cihaz gerektiren kabul testlerini daha sonra fiziksel cihazlarda çalıştır.
7. Levent onayı olmadan merge veya Play Console yayını yapma.
