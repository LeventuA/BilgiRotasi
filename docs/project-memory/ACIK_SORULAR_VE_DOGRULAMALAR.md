# Bilgi Rotası - Açık Sorular ve Canlı Doğrulamalar

**Son güncelleme:** 7 Ağustos 2026

## Çözülen veya kısmen çözülenler

1. Kanonik repo hangisi?
   - `ZMilaStudio/BilgiRotasi` olarak doğrulandı.
   - Proje belgelerindeki eski `LeventuA/BilgiRotasi` kayıtları temizlenmeye devam edecek.

2. `release/final-closed-test-aab-1.68.8` dalının head commit'i nedir?
   - `548e8d3046469688a8dcb050552956cf786e525c` olarak doğrulandı.

3. Aktif `pubspec.yaml` sürümü nedir?
   - `1.68.13+103` olarak doğrulandı.

4. PR #7 hâlâ açık ve Draft mı?
   - Evet; açık, Draft ve merge edilmemiş olarak doğrulandı.
   - Başlığı `release: Bilgi Rotası 1.68.13+103 kapalı test hattı` olarak güncellendi.
   - Release geçmişi, PR #9/#10 kapsamı ve CI kanıtları açıklamasına işlendi.

5. `update/closed-test-next-release` dalı var mı?
   - Evet. Başlangıçta release ile aynı committeydi; birleşik güncelleme çalışması bu dalda başladı.

6. Sonuç ekranındaki ödüllü reklam günlük üç sınırını içeriyor muydu?
   - Evet. `SupportRewardLimiter` içinde günlük tarih/sayaç ve üç reklam sınırı canlı kodda doğrulandı.
   - Günlük sınır kaldırıldı; oyun başına tek hak davranışı dalda uygulandı.
   - Eşzamanlı farklı oyun kayıtlarının birbirini ezmesi ve başarısız reklamdan sonra yeniden denemenin kapanması düzeltildi.
   - Test ve otomatik CI tamamen geçti; fiziksel cihaz kabulü açık kaldı.

7. PR #6 güncel release için hâlâ gerekli mi?
   - Hayır. PR #6 head commit'i güncel release'in doğrudan atasıdır.
   - Güncel release bu commit'in 45 commit ilerisinde ve 0 commit gerisindedir.
   - PR #6 merge edilmeden `superseded / yerine release hattı geçti` gerekçesiyle kapatıldı; branch ve commit geçmişi silinmedi.

8. PR #9 ve PR #10 release'e taşındı mı?
   - Evet.
   - PR #9 merge commit'i: `25f283d87875c766697e43a7b0b9655ceff752b6`; güncel release 3 commit ileride, 0 geride.
   - PR #10 merge commit'i: `34e8df9291ff070f333ea4e6d375b48ed7d01754`; güncel release 1 commit ileride, 0 geride.
   - PR #10 sonrasındaki tek commit PR #11'in proje hafızası belgesidir; uygulama kodunu değiştirmemiştir.

9. `1.68.13+103` release kodunun CI kanıtı var mı?
   - Evet. PR #10 merge commit'i `34e8df9291ff070f333ea4e6d375b48ed7d01754` üzerinde run `30864581523`, job `91853543414` başarıyla tamamlandı.
   - APK artifact ID `8879320751`, SHA-256 `3e8015f512b7710c9997aa7cad854f59aeee796cc2e72d9a3c3d5538f7174f69`.
   - Bu test AdMob kimlikli release APK kanıtıdır; Play'e yüklenen AAB kanıtı değildir.

10. Release dalında kapalı-test AAB üreten doğru hat var mı?
   - Evet. `.github/workflows/android-apk.yml`, `workflow_dispatch` üzerinden `.github/workflows/closed-test-release-core.yml` çağırır.
   - Production Firebase, Google demo/test AdMob kimlikleri ve kalıcı upload anahtarıyla imzalı AAB üretir; AAB metadata/imza ve Android 16 doğrulaması yapar.

11. Android geliştirici doğrulaması tamam mı?
   - Evet. 7 Ağustos 2026 Play Console ana sayfası tüm uygulamaların Android geliştirici doğrulaması şartları için başarıyla kaydedildiğini bildirdi.
   - Bilgi Rotası `com.leventua.bilgirotasi` paket adı `Kayıtlı` durumunda; 3 anahtar görünüyor.
   - Yeni paket kaydı veya yeni imza anahtarı gerekmiyor.

12. Kapalı testte Google'ın güncel saydığı testçi ve süre nedir?
   - 7 Ağustos 2026 ekranında 12 geçerli test kullanıcısı ve 4 kesintisiz gün doğrulandı.
   - Gerekli süre 14 gün; `Üretime başvur` henüz etkin değil.

## Açık ve doğrulanacak konular

1. 12 geçerli test kullanıcısı 14 günlük koşul tamamlanana kadar kesintisiz korunacak mı?
2. 14 günlük sayaç hangi kesin tarih/saatte tamamlanacak ve `Üretime başvur` ne zaman etkinleşecek?
3. Testten ayrılan katılımcı var mı; geçerli sayı 12'nin altına düşüyor mu?
4. Play Console'a yüklenen `1.68.13+103` AAB'nin özgül workflow_dispatch run ID'si, artifact ID'si ve SHA-256 değeri nedir?
5. Fiziksel cihazda aynı tamamlanan oyun ikinci kez `+10 XP` vermiyor mu?
6. Fiziksel cihazda yeni tamamlanan her oyun yeni reklam hakkı üretiyor mu?
7. Reklam tamamlanmadan kapatılırsa XP verilmediği ve hakkın yeniden denenebildiği gerçek cihazda doğrulanıyor mu?
8. Tahtadaki Rastgele Joker Kazan reklamı dört aktif jokerden birini rastgele `+1` vermeye devam ediyor mu?
9. Büyük ve tek satırlı `assets/questions.json` dosyası mevcut bağlı GitHub aracı dışında hangi güvenilir yöntemle eksiksiz okunacak?
10. Canlı JSON'daki 26 benzersiz hatalı soru kaydı, Sheet kayıtlarıyla birebir eşleşiyor mu?
11. `q56421` ve diğer yeni kayıtlar `SORU_GERI_BILDIRIM_HAVUZU.md` dosyasına hangi son listeyle eklenecek?
12. 73 bekleyen Sheet kaydından herhangi biri daha sonra düzeltildi veya yinelendi mi?
13. Zorluk bildirimlerinden hangileri birden fazla bağımsız kullanıcı tarafından işaretlendi?
14. Production Firebase'de hangi Functions, rules ve indexes gerçekten deploy edilmiş?
15. UMP onay akışı EEA testinde çalışıyor mu?
16. Canlı Düello iki güncel kapalı test cihazında uçtan uca sorunsuz mu?
17. Play Console'daki sürüm kodu `103`, doğrulanan AAB artifact'iyle birebir eşleşiyor mu?
18. Production Firebase açıkken sonuç reklamı kartının beklenen ürün davranışı nedir?
19. `experiment/true-3d-board-renderer-v2` hâlâ açık mı?
20. 8 rozet konseptinden hangi 6'sı tahtada kullanılacak?
21. PR #12'deki numaralı deterministik geometri Levent tarafından görsel olarak onaylanacak mı?
22. Telefon/tablet/Chromebook/PC/XR varlıklarının hangileri Play Console'a gerçekten yüklendi?
23. Onaylanmış bir final tanıtım videosu daha sonra üretildi mi?

## Güvenlik notu

Canlı `assets/questions.json` kayıtları eksiksiz okunmadan soru dosyasına tahmine dayalı değişiklik yapılmayacak. Sheet satırları gerçek düzeltmeler merge edilip doğrulanmadan kapatılmayacak. PR #13, Levent açıkça onaylamadan merge edilmeyecek.