# Bilgi Rotası – Proje Durumu

## Son Sürüm

**1.53.0+74**

## Son Tamamlanan İş

Canlı düello cevap ve ilerleme sistemi tamamlandı.

- Oyuncunun cevapları Firestore'a gönderiliyor.
- Doğru, yanlış ve cevaplanan soru sayıları tutuluyor.
- Rakibin ilerlemesi canlı izlenebiliyor.
- Her oyuncu yalnızca kendi ilerleme kaydını değiştirebiliyor.
- Otomatik eşleştirme 10, 20 ve 30 soruluk maçları destekliyor.
- İki oyuncuya aynı sorular aynı sırayla atanıyor.

## Sıradaki İş

Oynanabilir Canlı Düello soru ekranı:

- İki oyuncunun skor ve ilerleme çubukları
- Ortak soru sırasının ekranda oynatılması
- Seçilen cevabın canlı maç sistemine gönderilmesi
- Rakibin kaçıncı soruda olduğunun gösterilmesi
- Maç bitişi ve sonuç ekranı
- BR puanı ve lig sonucunun yalnızca bir kez işlenmesi

## Dokunulmaması Gerekenler

- `assets/questions.json` içindeki doğrulanmış soru bankası
- Mevcut Google giriş ve hesap silme sistemi
- Çalışan bulut kayıt sistemi
- Mevcut BR ve lig kayıt yapısı
- Çalışan normal oyun modları
- Firestore koleksiyon adları, geçiş planı olmadan değiştirilmemeli
- `pubspec.yaml` sürümü paket içinde kontrollü artırılmalı

## Kullanılan Çalışma Yöntemi

- Geliştirme GitHub Codespaces üzerinden yapılıyor.
- Kullanıcı çoğunlukla telefondan çalışıyor.
- Komutlar telefonda tek parça yapıştırılabilecek biçimde verilmeli.
- Her paket önce `dart analyze` ve ilgili Flutter testlerini çalıştırmalı.
- Testler başarılı olmadan commit ve push yapılmamalı.
- Uzun ve satır biçimine bağımlı kırılgan metin değiştirme betiklerinden kaçınılmalı.
- Her paketin sonunda bu durum dosyası güncellenmeli.
- Yeni sohbet başladığında önce bu dosya ve `pubspec.yaml` okunmalı.

## Bilinen Durumlar

- Toplam soru sayısı: **6710**
- Önceki RC2 hatası, kalite kapısının eski sürüm `1.48.5+69` beklemesinden kaynaklandı.
- Beklenen sürüm `1.53.0+74` olarak güncellendi.
- Flutter test derleyicisi bir kez geçici olarak çöktü; `.dart_tool` ve `build` temizlenince testler geçti.

## Son Başarılı Canlı Düello Aşamaları

1. BR ve lig altyapısı
2. Otomatik eşleştirme kuyruğu
3. Canlı Düello giriş ve rakip arama ekranları
4. Rakip bulundu ve 3-2-1 ekranı
5. Ortak soru kimlikleri
6. Cevap ve canlı ilerleme altyapısı
