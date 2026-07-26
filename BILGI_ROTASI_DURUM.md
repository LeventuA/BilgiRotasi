# Bilgi Rotası – Proje Durumu

## Son Sürüm

**1.60.0+81**

## Son Tamamlanan İş

Canlı Düello için Lig ve Sıralama merkezi eklendi.

- Canlı Düello ekranına **Lig ve Sıralama** düğmesi eklendi.
- Kullanıcının genel sırası ve güncel BR puanı gösteriliyor.
- Sonraki lige kalan BR ve ilerleme çubuğu gösteriliyor.
- Maç, galibiyet, mağlubiyet, beraberlik, kazanma oranı,
  en iyi seri ve en yüksek BR istatistikleri gösteriliyor.
- BR puanına göre ilk 100 oyuncu listeleniyor.
- Kullanıcının kendi satırı sıralamada vurgulanıyor.
- Son 10 dereceli maç ve BR değişimleri gösteriliyor.
- Yalnızca güvenli rekabet istatistiklerini taşıyan
  `live_duel_leaderboard` koleksiyonu eklendi.
- Hesap silindiğinde sıralama kaydı da siliniyor.
- Sıralama güvenlik kuralları eklendi.

## Sıradaki İş

- Firestore kurallarını `bilgi-rotasi-f255d` projesine dağıtma
- Yeni 1.60.0+81 APK'yı iki telefona kurma
- İki hesabın ilk 100 listesinde görünmesini doğrulama
- Maç sonrasında BR, sıra ve son maçların yenilendiğini doğrulama
- 20 ve 30 soruluk Canlı Düello testlerine devam etme

## Dokunulmaması Gerekenler

- `assets/questions.json` içindeki doğrulanmış soru bankası
- Mevcut Google giriş ve hesap silme sistemi
- Çalışan bulut kayıt sistemi
- Çalışan normal oyun modları
- Firestore koleksiyon adları geçiş planı olmadan değiştirilmemeli

## Bilinen Durumlar

- Toplam soru sayısı: **6710**
- Sıralama yalnızca Google hesabıyla giriş yapan oyuncuları kapsar.
- Sıralama belgesi, oyuncu Canlı Düello ekranını açtığında veya
  maç sonucu kaydedildiğinde otomatik güncellenir.
