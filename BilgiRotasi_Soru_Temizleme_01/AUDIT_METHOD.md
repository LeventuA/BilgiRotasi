# Bilgi Rotası — Soru Kalite Elemesi

Bu paket yeni soru üretmez. Mevcut soru bankasını küçültmek için hazırlanmıştır.

## Korunacak soru standardı

Bir soru ancak şu özellikleri taşıyorsa korunur:

- Tek ve açık bir bilgi sorar.
- Doğal Türkçeyle yazılmıştır.
- Hesaplama alıştırması veya iki sorunun birleşimi değildir.
- Cevabı görmek oyuncuya anlamlı bir bilgi kazandırır.
- Aynı bilgi ya da cümle kalıbı gereğinden fazla tekrar etmez.
- Dört seçeneği yapısal olarak geçerlidir.
- Kısa bir açıklaması vardır.

## Doğrudan elenen soru türleri

- İki farklı sorunun tek soruda birleştirildiği formatlar
- Yol, hız, süre, kuvvet, iş, yüzde ve temel aritmetik alıştırmaları
- Dört olay veya eseri kronolojik sıralama soruları
- Aynı yüzyıl, en yakın tarih ve benzeri seri üretim karşılaştırmaları
- ISO kodları, telefon kodları, internet uzantıları ve idari bölüm veri tabanı soruları
- Nota süresi, ölçü ve aralık hesaplaması gibi tekrarlı müzik teorisi alıştırmaları
- Yılın hangi yüzyıla veya on yıla ait olduğunu soran alıştırmalar
- Aynı doğru cevabı veya aynı cümle kalıbını aşırı tekrar eden sorular
- Doğru seçeneğin uzunluğuyla kendini ele verdiği sorular
- Aşırı uzun, yapay veya birden fazla soru işareti taşıyan metinler

## Denetim kapsamı

Yerel üretim paketlerinde bulunan 43.120 soru; metin yapısı, factKey ailesi,
tekrar yoğunluğu ve seçenek yapısı üzerinden sınıflandırıldı. Temsilî korunan
ve elenen örnekler ayrıca elle incelendi.

`q001-q3000` ile yerel arşivde bulunmayan `q6121-q13120` aralıkları,
betik çalıştırıldığında Codespaces içindeki gerçek `assets/questions.json`
dosyası üzerinde aynı sıkı kurallarla değerlendirilir.

Bu işlem bağımsız bir insan editörün 53.120 soruyu tek tek okuyup onayladığı
anlamına gelmez. Otomatik sınıflandırma, şablon ailesi denetimi, tekrar
filtreleri ve manuel örnek kontrolü birlikte kullanılmıştır.
