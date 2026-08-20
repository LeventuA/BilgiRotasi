# Bilgi Rotası — Kelime Avı v1 Oyun Sözleşmesi

## Amaç

Kelime Avı, klasik harf tablosu oyununun Bilgi Rotası kimliğiyle birleştiği, rota ilerlemeli bir yan oyun/mod olacak.

İlk sürümün hedefi içerik miktarı değil; tekrar kullanılabilir, deterministik ve test edilebilir çekirdektir.

## İlk rota: Başlangıç Limanı

Toplam 10 durak:

1. Normal
2. Normal
3. Normal
4. Normal
5. Meydan Okuma
6. Normal
7. Normal
8. Bonus Durak
9. Normal
10. Rota Finali

İlk rota öğretici niteliğinde olur. Harf tabloları küçük başlar ve sonraki bölümlerde çapraz/ters yön gibi yeni yerleşimler kontrollü biçimde eklenebilir.

## Bölüm türleri

### Normal

- hedef kelimeleri bul
- süre zorunlu değil
- temel yıldız hedefleri

### Meydan Okuma

- süre, hata sınırı veya seri hedefi gibi tek ek kural
- ana mekanik değişmez

### Bonus Durak

- kaybetme baskısı düşük
- ekstra bilgi kartı / ipucu / kozmetik ilerleme gibi ödül
- ana rotayı geçmek için zorunlu yapılmayabilir

### Rota Finali

- rotadaki öğrenilen kuralları birleştirir
- sonraki rotanın açılmasında zorunlu kapıdır

## Yıldız sistemi

Her bölüm en fazla 3 yıldız verir.

Örnek genel sözleşme:

- 1 yıldız: bölümü tamamla
- 2 yıldız: orta performans hedefini tamamla
- 3 yıldız: ustalık hedefini tamamla

Yıldız kriterleri bölüm verisinde tanımlanır; kod içine bölüm-bazlı sabit koşullar gömülmez.

## Rota açma kuralı

Başlangıç önerisi:

- rota finalini tamamla
- rota içindeki 30 olası yıldızdan en az 18 yıldız topla

Ama geçiş kolay, yüzde yüz tamamlama daha zor olmalı. Tüm bölümlerde 3 yıldız zorunluluğu yoktur.

## Kelime seçme mekaniği

- Oyuncu ilk harfe dokunur ve parmağını komşu harfler üzerinde sürükler.
- Seçim bırakıldığında kelime doğrulanır.
- Aynı hücre bir kelime içinde tekrar kullanılmayacak şekilde başlanır; ileride özel kuralla değişebilir.
- Geçerli yönler bölüm verisine bağlı olabilir: yatay, dikey, çapraz.
- Doğru kelime görsel/işitsel geri bildirim verir.
- Yanlış seçim oyuncuyu ağır cezalandırmaz.

## Veri modeli gereksinimleri

Bir rota en az:

- `id`
- `title`
- `theme`
- `unlockRule`
- `levels`
- `routeReward`

alanlarını taşımalıdır.

Bir bölüm en az:

- `id`
- `routeId`
- `index`
- `type`
- `grid`
- `targetWords`
- `bonusWords`
- `starRules`
- `infoCardIds`
- isteğe bağlı `timeLimitSeconds`

alanlarını taşımalıdır.

Bir bilgi kartı en az:

- `id`
- `word`
- `title`
- `shortFact`
- `category`

alanlarını taşımalıdır.

## Bilgi Rotası farkı

Kelime bulunduğunda bazı kelimeler kısa bir bilgi kartı açar.

Örnek:

- Kelime: `EFES`
- Başlık: `Efes`
- Kısa bilgi: `İzmir'in Selçuk ilçesinde bulunan önemli bir antik kenttir.`

Kart okunması zorunlu değildir; oyun akışını kesmeden keşif hissi verir.

## Özgün genişleme noktaları

### Kayıp Kelime

Hedef kelime doğrudan yazılmaz. Oyuncu kısa bilgi ipucundan cevabı çıkarıp tabloda bulur.

### Bilgi Zinciri

Bir kelime, ilişkili bir sonraki kelime/ipucunu açar.

### Canlanan Harita

Özel kelimeler rota dioramasını değiştirir: köprü açılır, nehir dolar, ışık yanar vb.

Bu mekanikler ilk çekirdeğin parçası olmak zorunda değildir; veri modelinin bunlara engel olmaması yeterlidir.

## İlerleme kaydı

Oyuncu için en az:

- bölüm bazında en iyi yıldız
- tamamlanan bölüm
- rota yıldız toplamı
- açılan rota
- kazanılan bilgi kartları

saklanmalıdır.

İlk aşamada yerel ve hesap-scope güvenli kayıt tercih edilir. Mevcut Bilgi Rotası hesap/kayıt verileriyle çakışan anahtarlar kullanılmaz.

## İlk içerik kalite kapısı

- Türkçe karakterler doğru çalışmalı.
- Kelime grid içinde gerçekten çözülebilir olmalı.
- Aynı hedef kelime aynı bölümde tekrar etmemeli.
- Bilgi kartı kelimeyle eşleşmeli.
- Yıldız hedefleri imkânsız olmamalı.
- Rota kilit kuralı deterministik olmalı.

## Kodlama fazı test sırası

1. Veri parse/model testleri.
2. Grid + hedef kelime doğrulama testleri.
3. Seçim path doğrulama testleri.
4. Yıldız hesaplama testleri.
5. Rota unlock testleri.
6. Progress serialize/restore testleri.
7. Ardından ekran/widget testleri.

## Kapsam dışı — ilk çekirdek

- Online multiplayer
- küresel leaderboard
- yüzlerce bölüm
- mağaza/IAP
- yeni reklam entegrasyonu
- ana Bilgi Oyunu runtime değişiklikleri
- mevcut soru bankasının Kelime Avı için dönüştürülmesi
