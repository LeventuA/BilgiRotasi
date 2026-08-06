# Bilgi Rotası - Açık Sorular ve Canlı Doğrulamalar

**Son güncelleme:** 6 Ağustos 2026

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

5. `update/closed-test-next-release` dalı var mı?
   - Evet. Başlangıçta release ile aynı committeydi; birleşik güncelleme çalışması bu dalda başladı.

6. Sonuç ekranındaki ödüllü reklam günlük üç sınırını içeriyor muydu?
   - Evet. `SupportRewardLimiter` içinde günlük tarih/sayaç ve üç reklam sınırı canlı kodda doğrulandı.
   - Günlük sınır kaldırıldı; oyun başına tek hak davranışı dalda uygulandı.
   - Test/CI/PR ve fiziksel cihaz kabulü henüz tamamlanmadı.

## Açık ve doğrulanacak konular

1. Kapalı Test'te güncel aktif katılımcı sayısı kaç?
2. 14 günlük sayaç hangi kesin tarih/saatte tamamlanacak?
3. Testten ayrılan katılımcı var mı?
4. `update/closed-test-next-release` üzerindeki ödüllü reklam testleri ve CI tamamen geçiyor mu?
5. Fiziksel cihazda aynı tamamlanan oyun ikinci kez `+10 XP` vermiyor mu?
6. Fiziksel cihazda yeni tamamlanan her oyun yeni reklam hakkı üretiyor mu?
7. Reklam tamamlanmadan kapatılırsa XP verilmediği gerçek cihazda doğrulanıyor mu?
8. Tahtadaki Rastgele Joker Kazan reklamı dört aktif jokerden birini rastgele `+1` vermeye devam ediyor mu?
9. Büyük ve tek satırlı `assets/questions.json` dosyası mevcut bağlı GitHub aracı dışında hangi güvenilir yöntemle eksiksiz okunacak?
10. Canlı JSON'daki 26 benzersiz hatalı soru kaydı, Sheet kayıtlarıyla birebir eşleşiyor mu?
11. `q56421` ve diğer yeni kayıtlar `SORU_GERI_BILDIRIM_HAVUZU.md` dosyasına hangi son listeyle eklenecek?
12. 73 bekleyen Sheet kaydından herhangi biri daha sonra düzeltildi veya yinelendi mi?
13. Zorluk bildirimlerinden hangileri birden fazla bağımsız kullanıcı tarafından işaretlendi?
14. Production Firebase'de hangi Functions, rules ve indexes gerçekten deploy edilmiş?
15. UMP onay akışı EEA testinde çalışıyor mu?
16. Canlı Düello iki güncel kapalı test cihazında uçtan uca sorunsuz mu?
17. Son AAB'nin tam kaynak commit'i ve artifact kanıtı nedir?
18. PR #9 ve PR #10'un merge commitleri ve release'e taşıdığı kapsam nedir?
19. `experiment/true-3d-board-renderer-v2` hâlâ açık mı?
20. 8 rozet konseptinden hangi 6'sı tahtada kullanılacak?
21. PR #12'deki numaralı deterministik geometri Levent tarafından görsel olarak onaylanacak mı?
22. Telefon/tablet/Chromebook/PC/XR varlıklarının hangileri Play Console'a gerçekten yüklendi?
23. Onaylanmış bir final tanıtım videosu daha sonra üretildi mi?

## Güvenlik notu

Canlı `assets/questions.json` kayıtları eksiksiz okunmadan soru dosyasına tahmine dayalı değişiklik yapılmayacak. Sheet satırları gerçek düzeltmeler merge edilip doğrulanmadan kapatılmayacak.
