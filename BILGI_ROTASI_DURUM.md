# Bilgi Rotası – Proje Durumu

## Son Sürüm

**1.57.0+78**

## Son Tamamlanan İş

Canlı Düello, Oyna menüsüne görünür ve doğrudan açılabilir bir oyun modu olarak bağlandı.

- Oyna ekranına **Canlı Düello** kartı eklendi.
- Kart, Meydan Okuma ile Diğer Oyun Modları arasına yerleştirildi.
- Karttan Canlı Düello giriş ekranı doğrudan açılıyor.
- Menü açıklamasında gerçek rakip, BR ve 10/20/30 soru seçenekleri belirtiliyor.
- Menü bağlantısını koruyan otomatik regresyon testi eklendi.
- Firestore bağlantı, yeniden bağlanma ve hükmen sonuç kuralları
  `bilgi-rotasi-f255d` projesine dağıtıldı.
- GitHub Actions APK ve AAB dosya adları güncel sürüme bağlandı.

## Sıradaki İş

Canlı Düello gerçek iki cihaz testi:

- Yeni `1.57.0+78` APK'yı iki telefona kurma
- İki farklı Google hesabıyla 10 soruluk normal maç
- Bir telefonu 30 saniye arka planda tutup geri dönme
- Bir telefonu 60 saniyeden uzun arka planda tutup hükmen sonuç
- Bilinçli maçtan ayrılma
- Uygulamayı yeniden açıp yarım maça dönme
- Sonuç, BR ve lig değişimini iki hesapta doğrulama
- İstemci cevap doğruluğunu sunucu tarafında güçlendirme

## Dokunulmaması Gerekenler

- `assets/questions.json` içindeki doğrulanmış soru bankası
- Mevcut Google giriş ve hesap silme sistemi
- Çalışan bulut kayıt sistemi
- Çalışan normal oyun modları
- Firestore koleksiyon adları geçiş planı olmadan değiştirilmemeli

## Kullanılan Çalışma Yöntemi

- Geliştirme GitHub Codespaces üzerinden yapılıyor.
- Kullanıcı çoğunlukla telefondan çalışıyor.
- Paketler ZIP içinde Python kurulum dosyası olarak hazırlanmalı.
- ZIP GitHub ana klasörüne yüklenip Codespaces'te pull edilerek kurulmalı.
- Her paket analiz, ilgili test ve RC2 kalite kapısından geçmeli.
- Testler tek tek ve `--concurrency=1` ile çalıştırılmalı.
- Her paketin sonunda bu durum dosyası güncellenmeli.

## Bilinen Durumlar

- Toplam soru sayısı: **6710**
- Firestore kuralları Firebase projesine başarıyla dağıtıldı.
- Gerçek iki telefonla uçtan uca test henüz yapılmadı.
- İstemci cevap doğruluğunu gönderiyor; sunucu tarafı soru doğrulaması
  yayın öncesinde güçlendirilmeli.

## Son Başarılı Canlı Düello Aşamaları

1. BR ve lig altyapısı
2. Otomatik eşleştirme kuyruğu
3. Canlı Düello giriş ve rakip arama ekranları
4. Rakip bulundu ve 3-2-1 ekranı
5. Ortak soru kimlikleri
6. Cevap ve canlı ilerleme altyapısı
7. Oynanabilir soru ekranı
8. Canlı skor ve ilerleme çubukları
9. Maç sonu sonuç ekranı
10. Atomik maç sonucu
11. Tek seferlik BR ve lig güncellemesi
12. Bulut profil ve idempotent sonuç kaydı
13. Bağlantı durumu ve 60 saniyelik yeniden bağlanma
14. Hükmen galibiyet ve yenilgi
15. Yarım kalan maça geri dönme
16. Firestore kurallarının gerçek projeye dağıtılması
17. Oyna menüsüne Canlı Düello girişi
