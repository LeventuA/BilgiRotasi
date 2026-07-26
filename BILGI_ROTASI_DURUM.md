# Bilgi Rotası – Proje Durumu

## Son Sürüm

**1.56.0+77**

## Son Tamamlanan İş

Canlı Düello bağlantı kopması, yeniden bağlanma ve hükmen sonuç sistemi tamamlandı.

- Oyuncuların maç içindeki aktif, arka plan ve ayrıldı durumları Firestore'da tutuluyor.
- Uygulama arka plana geçtiğinde 60 saniyelik yeniden bağlanma süresi başlıyor.
- Oyuncu 60 saniye içinde dönerse maç kaldığı yerden devam ediyor.
- Süre dolarsa rakip hükmen galip, bağlantısı kesilen oyuncu hükmen mağlup oluyor.
- Maçtan bilinçli ayrılma için onay penceresi eklendi.
- Bilinçli ayrılma anında hükmen yenilgi ve BR sonucu işleniyor.
- Hükmen sonuç da normal sonuç gibi atomik ve yalnızca bir kez kaydediliyor.
- Sonuç ekranında hükmen galibiyet veya yenilgi açıkça gösteriliyor.
- Rakibin geri dönüş süresi maç ekranında saniye saniye gösteriliyor.
- Canlı Düello ana ekranında yarım kalan maça dönme kartı eklendi.
- Yarım maç varken yeni eşleştirme başlatılamıyor.
- Firestore kuralları bağlantı durumunu ve hükmen sonucu doğruluyor.

## Sıradaki İş

Canlı Düello gerçek cihaz ve sunucu doğrulaması:

- Firestore kurallarını Firebase projesine dağıtma
- İki farklı telefon ve iki Google hesabıyla eşleştirme testi
- Normal maç bitişi testi
- Bir telefonu 30 saniye arka planda tutup geri dönme testi
- Bir telefonu 60 saniyeden uzun kapalı tutup hükmen sonuç testi
- Bilinçli maçtan ayrılma testi
- Uygulamayı yeniden açıp yarım maça dönme testi
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
- Firestore kuralları dosyada güncellendi; Firebase projesine dağıtılması gerekiyor.
- İstemci cevap doğruluğunu gönderiyor; sunucu tarafı soru doğrulaması yayın öncesinde güçlendirilmeli.
- Gerçek iki telefonla uçtan uca test henüz yapılmadı.

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
