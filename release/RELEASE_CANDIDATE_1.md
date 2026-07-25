# Bilgi Rotası 1.42.0+52 — Release Candidate 1

Bu sürüm yeni özellik ekleme döneminden yayın öncesi kalite dönemine geçiştir.

## Kalite kapısı

Her `main` dalı güncellemesinde GitHub Actions artık:

1. Soru bankasını doğrular.
2. Kod biçimini kontrol eder.
3. Flutter statik analizini çalıştırır.
4. Otomatik duman testlerini çalıştırır.
5. Release APK üretir.
6. Release AAB üretir.

Bu aşamalardan biri başarısız olursa Android paketleri yayın adayı olarak
kabul edilmez.

## Uygulama içi değişiklikler

- Merkezi sürüm bilgisi
- Hakkında & Gizlilik ekranı
- Sistem Sağlığında Release Candidate kontrol kartı
- Soru bankası, günlük görev ve piyon kataloğu otomatik kontrolleri
- Teknik hata ve ses motoru uyarıları

## Paketler

- `BilgiRotasi-RC1-APK`: Telefon üzerinde beta testi için
- `BilgiRotasi-RC1-AAB`: Play Console hazırlığı için

AAB dosyasını gerçek mağaza yayınına göndermeden önce üretim imzalama
anahtarı ve Play Console yapılandırması ayrıca tamamlanmalıdır.
