# Bilgi Rotası — Yeni Ana Ekran v1 Sözleşmesi

## Amaç

Ana ekranı uygulama-dashboard görünümünden çıkarıp Bilgi Rotası'nın oyunlarını taşıyan sade bir **oyun merkezi** haline getirmek.

Bu belge mevcut runtime'ı değiştirmez; entegrasyon öncesi ürün sözleşmesidir.

## Ekran hiyerarşisi

### 1. Üst alan

Sol/üst profil alanı:

- avatar
- kullanıcı adı
- seviye rozeti
- XP ilerleme çubuğu
- kısa ünvan (ör. `Kelime Yolcusu`)

Sağ/üst eylemler:

- `Ayarlar` ikon butonu
- varsa bildirim ikon butonu

Ayarlar artık büyük ana ekran kartı değildir.

### 2. Marka alanı

- Yeni Bilgi Rotası pusula/rota grafik dili
- `BİLGİ ROTASI`
- `Zarı at, bilginle yolu aç.` sloganı

Bu alan ana oyun kartlarını ezmeyecek kadar kompakt tutulur.

### 3. Ana oyun kartları

İki eşdeğer ana kart yan yana veya küçük ekranlarda iki kolon düzeninde gösterilir.

#### Bilgi Oyunu

- Eski `Oyna` girişinin yeni adı.
- Mevcut modlara açılır.
- Alt metin: `Sorular, maraton ve meydan okumalar`.
- Görsel dil: turkuaz/camgöbeği.
- Mevcut Bilgi Oyunu davranışı entegrasyon aşamasında korunur.

#### Kelime Avı

- Yeni oyun modu.
- Alt metin: `Rotalar, yıldızlar ve kelime macerası`.
- Görsel dil: mor/indigo.
- Kartın ilk entegrasyonda açacağı hedef, Kelime Avı rota merkezi olur.

Yeni oyunlar ileride aynı ana oyun kartı sözleşmesiyle eklenebilir.

### 4. Günlük Görevler

Ana oyun kartlarının altında yatay destek kartı:

- günlük görev ilerlemesi
- tamamlanan / toplam görev sayısı
- ödül veya XP özeti
- tek dokunuşla Günlük merkezine geçiş

Günlük, ana oyunlardan görsel olarak bir kademe daha düşük öncelikte olur.

### 5. Gelecek içerik alanı

İlk sürümde isteğe bağlı sade bir `Yeni modlar yolda` alanı kullanılabilir. Bu alan reklam banner'ı gibi görünmemeli ve ana navigasyonun parçası sayılmamalıdır.

## Ana ekrandan kaldırılan bağımsız kartlar

### Kariyer

Ana ekrandan kaldırılır. İçeriği Profil > Kariyer altında korunur:

- XP/seviye
- istatistikler
- başarımlar
- koleksiyon
- Bilgi Rotası Pasaportu
- ilgili kariyer içeriği

### Sosyal

Ana ekrandan kaldırılır. İçeriği Profil > Sosyal altında korunur:

- aile rekorları
- paylaşım
- sosyal/kariyer özetleri
- gelecekte eklenebilecek arkadaş/grup ögeleri

### Ayarlar

Ana ekrandaki büyük kart kaldırılır. Profil hizasında üst ikon olarak erişilir.

## Profil ekranı

Önerilen üst düzey sekmeler:

1. **Profil**
2. **Kariyer**
3. **Sosyal**

Profil özetinde:

- avatar
- kullanıcı adı
- seviye
- XP
- ünvan
- genel rozet sayısı
- Kelime Avı toplam yıldızı
- tamamlanan rota/bölüm
- bilgi kartı koleksiyonu ilerlemesi

Quiz ve Kelime Avı istatistikleri aynı profile ait olur ancak oyun-modu özel metrikler birbirine karıştırılmaz.

## Görsel sistem

- Ana zemin: koyu lacivert / gece mavisi.
- Pusula/rota: altın.
- Bilgi Oyunu: turkuaz.
- Kelime Avı: mor/indigo.
- Günlük: sıcak altın/turuncu vurgu.
- Kartlar: büyük radius, güçlü kontrast, az metin.
- Emoji prototip aşamasında kullanılabilir; finalde özgün ikon/asset seti tercih edilir.

## Erişilebilirlik

- Dokunma hedefleri küçük olmayacak.
- Metin/ikon kontrastı korunacak.
- Kritik bilgi yalnız renkle anlatılmayacak.
- Büyük yazı ölçeklerinde kart başlıkları taşmamalı.

## Entegrasyon güvenlik kapısı

Bu ekran mevcut uygulamaya bağlanmadan önce:

- yeni widget'lar izole test edilmiş olmalı,
- Bilgi Oyunu kartı mevcut PlayCenter akışına doğru yönlenmeli,
- Günlük görünürlük/account policy korunmalı,
- Kariyer/Sosyal içerik kaybı olmadan Profil içine taşınmalı,
- Ayarlar davranışı değişmeden yalnız giriş noktası değişmeli,
- mevcut oyun kayıtları ve hesap verileri etkilenmemeli.
