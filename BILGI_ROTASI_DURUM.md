# Bilgi Rotası – Proje Durumu

## Son Sürüm

**1.58.0+79**

## Son Tamamlanan İş

Canlı Düello karışık kategori ve sabit zorluk dağılımı tamamlandı.

- 10 soruluk maçlar: 5 Kolay, 3 Orta, 2 Zor.
- 20 soruluk maçlar: 10 Kolay, 6 Orta, 4 Zor.
- 30 soruluk maçlar: 15 Kolay, 9 Orta, 6 Zor.
- Altı kategori maç boyunca dengeli dağıtılıyor.
- Aynı kategori art arda getirilmiyor.
- Aynı maç tohumu iki cihazda aynı soru sırasını üretmeye devam ediyor.
- Soru planı sürümü 2'ye çıkarıldı.
- Eski soru planıyla oluşturulmuş yarım maçlar yeni sürümde
  devam kartına alınmıyor.
- Firestore kuralları `bilgi-rotasi-f255d` projesinde yayında.
- Canlı Düello Oyna menüsünden erişilebilir durumda.

## Sıradaki İş

Canlı Düello gerçek iki cihaz testi:

- Yeni 1.58.0+79 APK'yı iki telefona kurma
- 10 soruda 5/3/2 zorluk dağılımını doğrulama
- Altı kategorinin karışık geldiğini doğrulama
- 20 ve 30 soruluk maçları doğrulama
- 30 saniye arka plan ve geri dönüş testi
- 60 saniye sonunda hükmen sonuç testi
- Bilinçli ayrılma testi
- Yarım maça dönüş testi
- BR ve lig sonucunu iki hesapta doğrulama
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
- Gerçek iki telefonla uçtan uca test devam ediyor.
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
18. Karışık kategori ve sabit zorluk dağılımı
