# Bilgi Rotası — Kelime Avı v1 Hazırlık Hattı

Bu klasör, Bilgi Rotası'nın mevcut çalışan oyununa dokunmadan hazırlanacak yeni **Kelime Avı** modu ve yeni ana ekran bilgi mimarisinin ürün/teknik sözleşmesini tutar.

## Canlı başlangıç kilidi

- Kanonik release: `release/final-closed-test-aab-1.68.8`
- Exact başlangıç SHA: `9331802b9a2b12d1f4ec6715da96dc7d0f60b24b`
- Sürüm: `1.68.17+107`
- Çalışma branch'i: `feat/home-word-hunt-foundation-20260820`
- Takip: GitHub Issue #73

## Kesin güvenlik sınırı

Bu hazırlık fazında aşağıdakiler **değiştirilmeyecek**:

- `assets/questions.json`
- BoardMap ve 67 node düzeni
- 3B tahta
- mevcut Bilgi Oyunu modlarının oynanış davranışı
- Firebase production yapılandırması
- AdMob production yapılandırması
- release veya main dalındaki runtime kodu

Yeni tasarım ve Kelime Avı önce bu branch'te izole hazırlanır. Mevcut ana navigasyona entegrasyon, ayrı kullanıcı onayı ve test kapısından sonra yapılır.

## Ürün omurgası

Bilgi Rotası ana ekranı uzun vadede bir **oyun merkezi** olur.

Ana girişler:

1. **Bilgi Oyunu** — mevcut tahta, maraton, meydan okuma ve diğer bilgi oyunları.
2. **Kelime Avı** — rota, yıldız, kelime bulma ve bilgi kartı deneyimi.
3. **Günlük Görevler** — günlük/haftalık hedef ve ödüller.

Destek alanları:

- **Profil** — seviye, XP, kariyer, rozetler, koleksiyon ve sosyal özet.
- **Ayarlar** — ana kart değil; profil hizasında üst ikon.

## Yeni görsel yön

- Koyu gece/lacivert arka plan.
- Altın pusula ve rota çizgileri.
- Bilgi Oyunu için turkuaz/camgöbeği vurgu.
- Kelime Avı için mor/indigo vurgu.
- Ödül ve ilerleme için altın.
- Büyük, okunabilir, dokunmatik kartlar.
- Eski dashboard hissi yerine daha belirgin oyun merkezi hissi.

## Kelime Avı v1 hedefi

İlk hedef yüzlerce bölüm değil, sağlam ve genişletilebilir çekirdektir:

- 1 rota: **Başlangıç Limanı**
- 10 durak/bölüm
- normal / meydan okuma / bonus / rota finali bölüm türleri
- harf tablosunda sürükleyerek kelime seçimi
- 1–3 yıldız değerlendirmesi
- kilit açma ve rota ilerleme
- bilgi kartları
- yerel ilerleme kaydı

İlk çekirdek kanıtlandıktan sonra yeni rotalar veri odaklı eklenir.

## Geleceğe açık özgün mekanikler

Veri modeli daha sonra şu varyasyonları destekleyebilmelidir:

- **Kayıp Kelime:** kelime verilmez, bilgi ipucundan cevap bulunur.
- **Bilgi Zinciri:** bulunan kelime bir sonraki ilişkili kelimeyi açar.
- **Canlanan Harita:** doğru kelimeler rota dünyasında görsel değişim üretir.
- **Gizli Bilgi:** isteğe bağlı özel kelimeler bilgi parçası kazandırır.

## Uygulama sırası

1. Ana ekran ve profil sözleşmesini kesinleştir.
2. Kelime Avı veri modellerini izole ekle ve test et.
3. Rota/progress motorunu izole ekle ve test et.
4. Kelime seçme/doğrulama motorunu izole ekle ve test et.
5. İlk rota ekranlarını oluştur.
6. Kullanıcı görsel onayından sonra ana navigasyona kontrollü entegrasyon yap.

## v1 bitti ölçütü

- İlk 10 bölümlük rota baştan sona oynanabilir.
- İlerleme kapanıp açıldığında korunur.
- Yıldız ve kilit açma kuralları deterministiktir.
- Bilgi kartları kelime verisiyle güvenli eşleşir.
- Mevcut Bilgi Oyunu regresyonları etkilenmez.
- `assets/questions.json` değiştirilmez.
- Release'e merge yalnız açık kullanıcı onayından sonra yapılır.
