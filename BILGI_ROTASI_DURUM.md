# Bilgi Rotası – Proje Durumu

## Son Sürüm

**1.59.0+80**

## Son Tamamlanan İş

Ana sayfa üst bölümündeki gereksiz kartlar kaldırıldı.

- **Oyuna Başla** kartı ana sayfadan kaldırıldı.
- **Günlük Görev** kartı ana sayfadan kaldırıldı.
- Kayıt kontrolü sırasında yükleme kartı gösterilmiyor.
- Ana sayfada yalnızca gerçek bir kayıtlı oyun varsa
  **Devam Eden Oyun** kartı gösteriliyor.
- Kayıt yoksa hesap kartından sonra doğrudan **Bölümler** alanı geliyor.
- Kayıtlı oyundaki **Oyuna Devam Et** ve **Kayıtlı Oyunu Sil**
  işlemleri korunuyor.
- Ana sayfa düzenini koruyan otomatik kaynak sözleşmesi testi eklendi.
- Canlı Düello karışık kategori ve sabit zorluk dağılımı korunuyor.
- Firestore kuralları `bilgi-rotasi-f255d` projesinde yayında.

## Sıradaki İş

- Yeni 1.59.0+80 APK ile ana sayfayı doğrulama
- Kayıtsız durumda üst kartların görünmediğini kontrol etme
- Kayıt oluşturup yalnızca Devam Eden Oyun kartının çıktığını kontrol etme
- Canlı Düello iki cihaz testlerine devam etme
- 20 ve 30 soruluk maçları doğrulama
- Hükmen sonuç ve yarım maça dönüş senaryolarını kontrol etme

## Dokunulmaması Gerekenler

- `assets/questions.json` içindeki doğrulanmış soru bankası
- Mevcut Google giriş ve hesap silme sistemi
- Çalışan bulut kayıt sistemi
- Çalışan normal oyun modları
- Firestore koleksiyon adları geçiş planı olmadan değiştirilmemeli

## Bilinen Durumlar

- Toplam soru sayısı: **6710**
- Gerçek iki telefonla uçtan uca test devam ediyor.
- Ana sayfa kayıt kartı doğrudan `GameSaveService.load()` sonucuna bağlıdır.
