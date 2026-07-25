# Beşinci 10.000 Soru — Kolay Seri Kalite Kuralları

- ID aralığı `q43121-q53120` olarak kesintisizdir.
- 10 paket vardır ve her paket tam 1.000 soru içerir.
- 10.000 sorunun tamamında `difficulty: "Kolay"` kullanılmıştır.
- Sorular tek bilgi veya tek işlem ister; iki bilgiyi birleştiren soru yoktur.
- Tuzaklı, yoruma açık ve olumsuz köklü soru kullanılmamıştır.
- Her soruda dört benzersiz seçenek, tek doğru cevap ve kısa açıklama vardır.
- Erişilebilir önceki 33.000 soruyla normalize birebir metin ve soru-doğru cevap karşılaştırması yapılmıştır.
- Kurulum betiği repodaki güncel `assets/questions.json` dosyasını yeniden tarar ve çakışmaları raporlar.
- Sorular yapılandırılmış kayıt ve tek adımlı hesaplamalardan üretilip otomatik QA testlerinden geçirilmiştir; bağımsız insan editörün 10.000 satırı tek tek okuduğu iddia edilmez.
