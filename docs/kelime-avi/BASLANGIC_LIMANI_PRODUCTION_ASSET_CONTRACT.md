# Başlangıç Limanı — Production Asset Contract

## Bağlayıcı production mimarisi

Bu dosya `görsel oyun üretimstandartı.md` ve `docs/project-memory/KARARLAR.md` ile birlikte okunur.

Başlangıç Limanı için kullanıcı tarafından açıkça kabul edilen production mimarisi:

`MASTER ART RASTER → TRANSPARENT INTERACTION HITBOXES → MINIMUM LOCAL STATE OVERRIDES`

Bu rota, genel `REFERENCE → PRODUCTION-READY LAYERED ASSETS → THIN INTERACTION CODE` standardının kullanıcı tarafından onaylanmış özel uygulamasıdır. Amaç referansı yeniden çizmek değil, bağlayıcı MASTER ART'ın kendi piksellerini görünür taban olarak korurken gerçek oyun state'ini yalnız değişmesi gereken küçük bölgelerde doğru göstermektir.

## Tek görünür kaynak gerçeği

Bağlayıcı MASTER ART:

`assets/word_hunt/baslangic_limani_master_art_visual_proof.jpg`

- Kaynak boyutu: `720×1280`
- SHA-256: `fb4597bb4d37b30cefeec2ba913c591fe9471529f80966830afd5b801a86fca3`
- Android/canonical proof boyutu: `1080×1920`
- Uniform scale: `1.5`
- Crop / stretch / bağımsız yeniden kompozisyon: yok

MASTER ART; gece limanı, rota ışıkları, plaque'lar, başlık, dekoratif çerçeve, pusula, kitap ve temel node sanatını tek görünür raster sahnede taşır.

## Production render sırası

Gerçek Başlangıç Limanı production ekranı aşağıdaki sırayı kullanır:

1. MASTER ART raster sahnesi.
2. Gerçek progression değerlerinden üretilen minimum lokal state override'ları.
3. Görünmez/şeffaf interaction hitbox'ları.

MASTER ART üzerine bütün rota, node, plaque, crown, compass, book veya top chrome ikinci kez çizilmez.

## Dinamik state doğruluğu

MASTER ART içindeki demo state, gerçek progression gerçeğinin önüne geçemez. Kullanıcıya gösterilen state her zaman `WordHuntProgressSnapshot` ve `WordHuntRouteProgressEngine` ile tutarlı olmalıdır.

Production'da lokal override ile dinamik tutulacak alanlar:

- gerçek toplam yıldız: `X / 30`,
- her level için gerçek `0–3` yıldız state'i,
- gerçek locked/open state,
- Başlangıç Limanı özel progression kuralına göre node 9 open görünümü,
- gerektiğinde ileride eklenen başka gerçek runtime state'leri.

Sabit route verisi olduğu sürece MASTER ART içinde kalabilen alanlar:

- `BAŞLANGIÇ LİMANI` başlığı,
- bu rota için sabit `Kapı: 18` gereksinimi,
- `MEYDAN OKUMA`, `BONUS DURAK`, `ROTA FİNALİ` plaque metinleri,
- dekoratif/tematik sanat.

Bu sabitlerden biri ileride runtime verisine dönüşürse o alan da lokal state override'a alınır.

## Progression sözleşmesi

Korunan gerçek oyun davranışı:

- Level 1 başlangıçta açıktır.
- Genel akışta bir sonraki normal durak önceki zorunlu durağın tamamlanmasıyla açılır.
- Başlangıç Limanı'nda level 7 tamamlandığında bonus 8 ve normal 9 birlikte açılır.
- Bonus 8, level 9 için zorunlu geçiş kapısı değildir.
- Level 10, level 9 tamamlanmadan kilitli ve callback üretmeyen durumda kalır.
- Kilitli hitbox callback üretmez.
- Görsel locked/open state, interaction state ile aynı gerçeği gösterir.

## Etkileşim geometrisi

Şeffaf hitbox geometrisi `WordHuntPixelProofLayout` kaynak koordinatlarını kullanır.

Kaynak uzay: `720×1280`.

Level merkezleri:

- 1: `(136.08, 304.64)`
- 2: `(318.96, 328.96)`
- 3: `(462.24, 390.40)`
- 4: `(578.16, 477.44)`
- 5: `(241.20, 579.84)`
- 6: `(120.24, 706.56)`
- 7: `(331.20, 746.24)`
- 8: `(480.96, 788.48)`
- 9: `(169.92, 892.16)`
- 10: `(352.08, 1020.16)`

1080×1920 proof'ta bu değerler tam `1.5×` ölçeklenir. Görünür sahne ve hitbox'lar aynı transform alanında kalır.

## Yıldız yuvaları

MASTER ART'taki demo yıldızları ayrı ikinci satır oluşturarak değil, kendi ölçülmüş yuvalarının TAM üstünde maskelenip gerçek state ile değiştirilir.

1–10 yıldız yuvaları 720×1280 MASTER ART kaynak piksellerinden ölçülür. Özellikle bonus 8, normal 9 ve büyük final 10 generic node-diameter hesabıyla konumlandırılmaz.

Final 10'un yıldızları referanstaki büyük görsel hiyerarşiyi koruyan ayrı boyutta render edilir.

## Lokal override sınırı

Lokal state override:

- yalnız değişen state bölgesini kapsar,
- MASTER ART'ın rota/arka plan/plaque sanatını yeniden üretmez,
- ikinci bir görünür node/route sistemi oluşturmaz,
- gerçek state ile raster demo state arasındaki çelişkiyi kapatmak için kullanılır.

Yeni bir override eklenmeden önce şu soru sorulur:

> Bu piksel bölgesi runtime state yüzünden gerçekten değişmek zorunda mı?

Cevap hayırsa MASTER ART pikseli korunur.

## Layered asset klasörünün durumu

`assets/word_hunt/baslangic_limani/` altındaki ayrı node/plaque/control asset'leri tarihsel üretim, fallback, test veya lokal state override ihtiyacı için repoda kalabilir.

Bunların varlığı production'da tüm sahnenin layered olarak tekrar render edileceği anlamına gelmez.

Özellikle production görünür tabanı `scene.webp + ayrı node/plaque` kompozisyonu değildir; kabul edilen MASTER ART raster sahnesidir.

## Yasaklar

Başlangıç Limanı production final-art yolunda aşağıdakiler yapılmaz:

- MASTER ART'a benzeyen yeni sahnenin baştan çizilmesi,
- `CustomPainter` / Dart Canvas ile premium final art yeniden üretimi,
- MASTER ART üstüne ikinci tam rota/node/plaque sistemi bindirmek,
- yalnız teknik CI geçti diye görsel PASS ilan etmek,
- gerçek progression ile çelişen sabit demo state göstermek,
- crop/zoom/stretch ile bağlayıcı geometriyi keyfi değiştirmek.

## Korunan teknik çekirdek

- Flutter/Dart production sistemi.
- `WordHuntRouteProgressEngine`.
- `WordHuntProgressSnapshot`.
- Mevcut 1–10 level/domain sözleşmesi.
- Level callback davranışları.
- `assets/questions.json`.
- BoardMap / 67 node / 3B çekirdeği.
- AdMob / Firebase / Android release yapılandırması.
- Paket ve sürüm sözleşmesi.

## Görsel kalite kapısı

Merge öncesi en az:

- focused Kelime Avı testleri PASS,
- `dart analyze lib/word_hunt` temiz,
- `git diff --check` PASS,
- Android 16 gerçek production route screenshot,
- MASTER ART ↔ production side-by-side,
- MASTER ART ↔ production diff,
- crash / ANR / FATAL / process-death taraması,
- gerçek progression state'lerinin görünür doğrulaması

aranır.

Teknik CI PASS tek başına görsel kabul değildir. Son görsel kabul kullanıcıya aittir.

## Merge sınırı

Bu pilot PR #132 entegrasyon hattında ilerler. PR #132'nin daha üst hedefe merge edilmesi ayrıca açık kullanıcı merge onayı gerektirir.
