# Android yedekleme politikası

Bilgi Rotası hesap oturumu, Firebase UID, rastgele geri bildirim cihaz kimliği,
bekleyen geri bildirim, kayıtlı oyun ve diğer SharedPreferences durumunun
Android Auto Backup veya cihazdan cihaza aktarım ile başka cihaza kopyalanmasını
engeller.

- Android 11 ve öncesi: `res/xml/backup_rules.xml`
- Android 12 ve sonrası: `res/xml/data_extraction_rules.xml`
- Manifest, her iki kaynağı açıkça bağlar.

Kurallar mevcut cihazdaki veriyi silmez. Hesaplı ilerleme Firebase bulut kaydı
üzerinden kullanıcı seçimiyle eşitlenir. Misafir ilerlemesi yereldir ve yeni
cihaza otomatik taşınmaz. Release smoke testinde mevcut sürümün üstüne güncelleme
ile yerel kaydın aynı cihazda korunduğu ayrıca doğrulanmalıdır.
