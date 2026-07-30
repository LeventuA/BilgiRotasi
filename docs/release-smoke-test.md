# 1.68.6 production yayın smoke testi

Sonuçları tarih, cihaz/Android sürümü, artifact SHA-256 ve tester ile kaydedin.
Gerçek reklama test isteği göndermeyin; reklam testleri Google test ID'li
artifact ile yapılır.

- [ ] Temiz kurulum ve eski sürüm üstüne veri kayıpsız güncelleme
- [ ] İnternetsiz ilk açılış ve misafir çevrimdışı oyun
- [ ] Kalıcı imzalı artifact ile Google giriş ve beklenen SHA-1
- [ ] İlk kullanıcı adı, yazım onayı ve sözleşme kabul kaydı
- [ ] İlk 24 saat ücretsiz düzeltme; ikinci denemenin reddi
- [ ] Eski oyuncu migration düzeltmesi (`levetua` → `leventua` dahil genel kural)
- [ ] Normal 30 gün sınırı ve kesin tarih/gün/saat görünümü
- [ ] Türkçe karakter önerisi; küfür/taklit/iletişim bilgisi reddi
- [ ] UMP formu, gizlilik tercihlerini yeniden açma
- [ ] Test banner, test ödüllü reklam ve reklam yüklenmezse oyunun devamı
- [ ] Tahta jokeri ve production bulut +10 XP fallback/SSV durumu
- [ ] İki cihazda revision çakışması ve iki kayıt özetinden seçim
- [ ] Geri yükleme sırasında zorla kapatma sonrası eski kaydın toparlanması
- [ ] İki fiziksel telefonda Canlı Düello; aynı soru ve server skoru
- [ ] Tekrarlanan finalize isteğinin ikinci BR/maç üretmemesi
- [ ] Rakip bildirme, engelleme, listeden kaldırma
- [ ] Engellenmiş iki hesabın yeniden eşleşmemesi
- [ ] Hesaptan çıkış ve misafir/hesap kayıt izolasyonu
- [ ] Hesap silmede işlem ID/aşamaları, kesinti sonrası devam
- [ ] Auth hesabının en son silinmesi; UID/ad anonimleştirme
- [ ] Android 16 cold-start ve logcat'te crash/ANR/Firebase production çağrısı yok
- [ ] Production APK/AAB paket, sürüm, manifest, App ID ve sertifika doğrulaması
