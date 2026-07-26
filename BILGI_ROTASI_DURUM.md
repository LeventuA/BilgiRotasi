# Bilgi Rotası – Proje Durumu

## Son Sürüm

**1.61.0+82**

## Son Tamamlanan İş

Canlı Düello arka plan geri dönüş süresi iyileştirildi.

- Uygulama kısa süreliğine arka plana geçtiğinde verilen geri dönüş süresi
  60 saniyeden **3 dakikaya** çıkarıldı.
- Mesajlaşma, kısa telefon görüşmesi veya uygulamalar arası geçiş yüzünden
  maçın gereksiz yere hükmen kaybedilmesi azaltıldı.
- Rakip ekranda kalan süreyi saniye saniye görmeye devam ediyor.
- **Ayrıl ve yenilgiyi kabul et** seçeneği hâlâ anında hükmen sonuç üretiyor.
- Firestore güvenlik kuralındaki azami geri dönüş süresi 190 saniyeye
  çıkarıldı.
- 3 dakikalık tolerans için otomatik testler eklendi.
- Lig ve Sıralama merkezi çalışır durumda.

## Sıradaki İş

- Firestore kurallarını `bilgi-rotasi-f255d` projesine yeniden dağıtma
- Yeni 1.61.0+82 APK'yı iki telefona kurma
- Bir telefonu 2 dakika arka planda tutup geri dönme testi
- Bir telefonu 3 dakika 10 saniye arka planda tutup hükmen sonuç testi
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
- Bilinçli ayrılma ile geçici arka plan durumu ayrı davranır.
