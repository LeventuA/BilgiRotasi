# Bilgi Rotası – Proje Durumu

## Son Sürüm

**1.55.0+76**

## Son Tamamlanan İş

Canlı Düello atomik sonuç ve BR/lig işleme sistemi tamamlandı.

- İki oyuncu da bitmeden maç sonucu kesinleştirilemiyor.
- Skorlar, kazanan veya beraberlik sonucu maç belgesine tek transaction ile yazılıyor.
- İki cihaz aynı anda sonuç yazmaya çalışsa bile maç yalnızca bir kez tamamlanıyor.
- Her kullanıcının BR sonucu kendi bulut profilinde yalnızca bir kez uygulanıyor.
- Kullanıcı başına maç kimliğiyle idempotent sonuç kaydı tutuluyor.
- Galibiyet, yenilgi, beraberlik, seri, en yüksek BR ve son maçlar güncelleniyor.
- Sonuç ekranında kazanılan veya kaybedilen BR ile lig değişimi gösteriliyor.
- Canlı Düello profili yerel kayıtla birlikte Firestore kullanıcı belgesine de yazılıyor.
- Hesap silinirken Canlı Düello sonuç alt koleksiyonu da temizleniyor.
- Firestore kuralları tamamlanmış maç sonucunu ilerleme belgelerine göre doğruluyor.

## Sıradaki İş

Canlı Düello bağlantı kopması ve hükmen sonuç sistemi:

- Maçtan ayrılma isteği
- Bağlantı kesilme zaman damgası
- Yeniden bağlanma süresi
- Süre dolunca hükmen galibiyet veya yenilgi
- Yarım kalan maçların açılışta geri yüklenmesi
- Gerçek iki telefonla canlı test
- Firestore kurallarının Firebase projesine dağıtım doğrulaması

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
- İstemci cevap doğruluğunu gönderiyor; sunucu tarafı soru doğrulaması yayın öncesinde güçlendirilmeli.
- Firestore kural dosyası güncellendi; Firebase projesindeki dağıtım ayrıca doğrulanmalı.
- Maçtan ayrılma ve bağlantı kopması henüz eklenmedi.

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
