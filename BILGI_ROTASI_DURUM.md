# Bilgi Rotası – Proje Durumu

## Son Sürüm

**1.54.0+75**

## Son Tamamlanan İş

Oynanabilir Canlı Düello soru ekranı tamamlandı.

- Rakip bulundu ekranındaki 3-2-1 sayımı gerçek maça bağlandı.
- Ortak soru kimlikleri cihazdaki soru bankasından çözülüyor.
- İki oyuncunun doğru sayısı ve soru ilerlemesi canlı gösteriliyor.
- Dört seçenekli cevap ekranı çalışıyor.
- Cevaplar Firestore ilerleme sistemine gönderiliyor.
- Doğru ve yanlış cevap geri bildirimi gösteriliyor.
- Oyuncu bitirdiğinde rakibin tamamlaması bekleniyor.
- İki oyuncu bitirdiğinde galibiyet, beraberlik veya yenilgi gösteriliyor.
- İlerleme kaydı ekran yeniden açıldığında sıfırlanmıyor.
- Uygulama içindeki eski sürüm etiketi düzeltildi.
- Kalite kapısı artık AppBuildInfo ile pubspec sürümünü karşılaştırıyor.

## Sıradaki İş

Canlı Düello sonucunun güvenli ve yalnızca bir kez işlenmesi:

- Maç sonucu için atomik Firestore işlemi
- Kazanan ve beraberlik kaydının maç belgesine yazılması
- BR puanı değişimi
- Lig ve yerleştirme maçı güncellemesi
- İki cihaz aynı anda sonuç yazsa bile tek işlemin kabul edilmesi
- Maçtan ayrılma ve bağlantı kopması
- Hükmen galibiyet ve yenilgi
- Gerçek iki telefonla canlı test

## Dokunulmaması Gerekenler

- `assets/questions.json` içindeki doğrulanmış soru bankası
- Mevcut Google giriş ve hesap silme sistemi
- Çalışan bulut kayıt sistemi
- Mevcut BR ve lig kayıt yapısı
- Çalışan normal oyun modları
- Firestore koleksiyon adları geçiş planı olmadan değiştirilmemeli

## Kullanılan Çalışma Yöntemi

- Geliştirme GitHub Codespaces üzerinden yapılıyor.
- Kullanıcı çoğunlukla telefondan çalışıyor.
- Büyük terminal metinleri yerine yüklenebilir kurulum dosyaları tercih edilmeli.
- Her paket analiz, ilgili test ve RC2 kalite kapısından geçmeli.
- Yerel Flutter derleyicisi çökerse gerçek hata ile ortam çökmesi ayrılmalı.
- Her paketin sonunda bu durum dosyası güncellenmeli.

## Bilinen Durumlar

- Toplam soru sayısı: **6710**
- Sonuç ekranı çalışıyor ancak BR ve lig henüz kalıcı işlenmiyor.
- Maçtan ayrılma ve bağlantı kopması henüz eklenmedi.
- Codespaces Flutter test derleyicisi zaman zaman ortam kaynaklı çöküyor.

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
