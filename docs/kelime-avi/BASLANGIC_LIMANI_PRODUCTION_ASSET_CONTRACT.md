# Başlangıç Limanı — Production Asset Contract

## Bağlayıcı standart

Bu dosya `görsel oyun üretimstandartı.md` ile birlikte okunur.

Ana akış:

`REFERENCE → PRODUCTION-READY LAYERED ASSETS → THIN INTERACTION CODE`

Onaylı referans MASTER ART'tır. Premium görsel öğeler final render yolunda `CustomPainter` / Dart Canvas ile yeniden çizilmez.

## Korunan teknik çekirdek

- 1080×1920 canonical coordinate space.
- PR #110'daki `WordHuntCanonicalSceneTransform`.
- 1–10 canonical node merkezleri.
- Segment başına canonical Bézier kontrol noktaları.
- `WordHuntRouteProgressEngine` progression/unlock mantığı.
- Gerçek yıldız sayısı ve dinamik metin.
- Kilitli durakta interaction olmaması.
- Mevcut focused/regresyon test kazanımları.

## Asset klasörü

Hedef klasör:

`assets/word_hunt/baslangic_limani/`

## Production asset listesi

| Asset | Format | Transparan | Runtime state | Not |
| --- | --- | --- | --- | --- |
| `scene.webp` | WebP | Hayır | statik | Gece limanı sahnesi; UI/metin/node içermez. |
| `node_normal.webp` | WebP/PNG | Evet | normal/açık | Teal/cyan premium medalyon gövdesi. |
| `node_locked.webp` | WebP/PNG | Evet | kilitli | Gri/gümüş kilitli medalyon gövdesi. |
| `node_challenge.webp` | WebP/PNG | Evet | challenge | Turuncu/altın özel medalyon. |
| `node_bonus.webp` | WebP/PNG | Evet | bonus | Mor özel medalyon. |
| `node_final.webp` | WebP/PNG | Evet | final | Büyük altın final medalyonu. |
| `challenge_plaque.webp` | WebP/PNG | Evet | statik çerçeve | Dinamik `MEYDAN OKUMA` metni ve gerekiyorsa ikon üstten bindirilir. |
| `bonus_plaque.webp` | WebP/PNG | Evet | statik çerçeve | Dinamik `BONUS DURAK` metni üstten bindirilir. |
| `final_plaque.webp` | WebP/PNG | Evet | statik çerçeve | Dinamik `ROTA FİNALİ` metni üstten bindirilir. |
| `final_crown.webp` | WebP/PNG | Evet | statik | Mücevherli/premium taç; procedural crown yerine kullanılır. |
| `compass_button.webp` | WebP/PNG | Evet | statik | Sol alt kontrol. |
| `book_button.webp` | WebP/PNG | Evet | statik | Sağ alt kontrol. |

Route çizgisi için ilk tercih: mevcut canonical geometriyi koruyan ince interaction code + az sayıda kaliteli route overlay asset. Tek bir procedural neon path final kaliteyi karşılamazsa aşağıdaki state overlay'leri kullanılabilir:

- `route_normal.webp`
- `route_challenge.webp`
- `route_bonus.webp`
- `route_locked.webp`
- `route_final.webp`

## Asset içine gömülmeyecek dinamik öğeler

- bölüm numarası,
- yıldız sayısı/dolu-boş yıldız state'i,
- gerçek progression değeri,
- `BAŞLANGIÇ LİMANI`, `Kapı: 18` ve benzeri değişken metin,
- erişilebilirlik/semantic bilgi,
- tap/gesture davranışı,
- unlock state.

## Canonical yerleşim

PR #110'daki mevcut koordinatlar ilk production pilotunda değiştirilmez; görsel asset boyutları bu sözleşmeye oturtulur:

- Node 1: `(204.12, 456.96)`
- Node 2: `(478.44, 493.44)`
- Node 3: `(693.36, 585.60)`
- Node 4: `(867.24, 716.16)`
- Node 5: `(361.80, 869.76)`
- Node 6: `(180.36, 1059.84)`
- Node 7: `(496.80, 1119.36)`
- Node 8: `(721.44, 1182.72)`
- Node 9: `(254.88, 1338.24)`
- Node 10: `(528.12, 1530.24)`

Bu koordinatlar görsel asset üretimini kolaylaştırmak için keyfi oynatılmaz. Referansla ölçüm sonucu zorunlu bir değişiklik çıkarsa ayrıca test-first ve kullanıcıya görünür gerekçeyle yapılır.

## Procedural final-art kaldırma hedefi

Final Başlangıç Limanı render yolunda aşağıdaki sınıflar/benzerleri premium görsel üretim yöntemi olmayacak:

- `_FinalCrownPainter`
- `_TreasureChestPainter`
- `_FantasyPlaquePainter`
- premium medalyon süsünü oluşturan procedural painter'lar

Kodun kalması gerekiyorsa yalnız test/fallback geliştirme yolu olarak açıkça ayrıştırılır; production asset başarıyla yüklendiğinde kullanılmaz.

## Görsel kalite kapısı

- Asset'ler referansla aynı görsel aile/ışık/doku kalitesinde olmalı.
- Transparan asset kenarlarında halo/çentik/arka plan kalıntısı olmamalı.
- 1080×1920 canonical sahnede yakınlaştırıldığında düşük çözünürlük/pixelation olmamalı.
- Gerçek Android screenshot referansla yan yana incelenmeli.
- Teknik CI PASS görsel kabul değildir.
- Son görsel kabul Levent'e aittir.

## Merge sınırı

Bu pilot ayrı Draft PR üzerinden ilerler. Levent açık görsel kabul ve ayrıca açık merge onayı vermeden Ready/merge yapılmaz.
