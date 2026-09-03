# Kelime Avı V5 — Reference Asset Contract

Tarih: 31 Ağustos 2026

Bu dosya Başlangıç Limanı gameplay ekranının bağlayıcı referansından kontrollü türetilen ve kullanıcı tarafından görsel QA ile kabul edilen production asset sözleşmesini kilitler.

## Değiştirilemez ürün kuralı

- Canonical gameplay grid **8×8** olarak kalır.
- 6×10 veya başka grid geometrisine geri dönülmez.
- Hiçbir raster asset içine grid geometrisi bake edilmez.
- Gameplay engine, swipe, timer, scoring, bonus, progression ve 10 bölüm / 80 target+bonus sözleşmesi görsel entegrasyon uğruna değiştirilmez.

## Production için LOCKED / USER PASS assetler

| Asset | SHA-256 | Durum |
|---|---|---|
| `harbor_background_1080x1920.png` | `0482adfa9ce8b2eb3b3637a7ef9976984650368a43f539f999842437a69d4368` | LOCKED / PASS |
| `cell_idle.png` | `052ac36a48cd0bac06bfbd6221e28c77bd32a4b1e9f08ded0e7fabefbf56c529` | LOCKED / PASS |
| `cell_selected_found.png` | `57d620263cae231c4b8983cc8fab7732db7733a78fae9e620abaaec7dc8aac87` | LOCKED / PASS |
| `status_panel_empty.png` | `0f5fd5aac1f94fa644a3f19c4147e2747fd639b0041a12e94df8198201fc95f4` | LOCKED / PASS |
| `word_plaque_empty.png` | `90d15d496a1a22fdee1014ffc2921ef8569863570b3c61141417cf9fb941c04a` | LOCKED / PASS |
| `bonus_plaque_empty.png` | `e3bfe4b5a958ec945a76cdd0cc48d2ae3e93f4340ccf5b778ad63663787a79bf` | LOCKED / PASS |
| `instruction_panel_empty.png` | `71aa162fc3dd24ef6f84c04792c87eb8800e63ff8b92b933bab13f2b72731c5c` | LOCKED / PASS |
| `icon_back.png` | `4d086841a7fc4cb4bb194ab72fd3f9f34c3d84adc836b965ab15e651ac92b24f` | LOCKED / PASS |
| `icon_search.png` | `da26169dc521284e58144453ce756053a1b153e7c467d90a860d1cf5c2ec71fe` | LOCKED / PASS |
| `icon_mistake.png` | `b77fe3628dc98162e1d739d649dffc426ec293f88579716c25e459de2e0d6253` | LOCKED / PASS |
| `icon_timer.png` | `f276c862e3ecae30853ff8d0f3fe8e08d2878e1357d67a4eb3e13c95affa54ec` | LOCKED / PASS |

Beklenen production klasörü:

`assets/word_hunt/v5_reference_assets/`

## Production dışında

- `icon_anchor.png`: `UNUSED / REJECTED` — instruction panel assetinin içinde dekor zaten bake edilmiştir; ayrı overlay kullanılmaz.
- `icon_compass.png`: `UNUSED / REJECTED` — instruction panel assetinin içinde dekor zaten bake edilmiştir; ayrı overlay kullanılmaz.
- Bu iki dosya otomatik silinmez; ilgisiz yerel değişikliklere dokunulmaz.

## Açık doğrulamalar

- `ERROR_STATE_VISUAL = DOĞRULANACAK` — bağlayıcı referansta hata hücresi state'i görünmediği için `cell_error.png` uydurulmaz.
- `REFERENCE_FONT = DOĞRULANACAK` — font ailesi doğrulanmadan rastgele font asseti eklenmez.

## Entegrasyon sınırı

Entegrasyon yalnız presentation katmanını değiştirir:

- background raster asset,
- status panel raster shell + dinamik ikon/metin,
- target/bonus raster plaque shell + dinamik kelime,
- idle/found raster cell shell + dinamik harf,
- instruction panel raster shell + dinamik status metni,
- back/search/mistake/timer ikon assetleri.

`lib/main.dart`, `assets/questions.json`, MASTER ART rota/BoardMap/67 node, Firebase, AdMob, signing, package ve version kapsam dışıdır.

`pubspec.yaml` sürümü değiştirilemez. Asset bundle için yalnız teknik olarak gerekliyse `assets/word_hunt/v5_reference_assets/` directory kaydı eklenebilir.

## QA kapısı

Asset entegrasyonu sonrasında en az:

- canonical 8×8 / 64 hücre,
- B1/B5/B8/B10 ilk viewport,
- gerçek ANKARA ve ters BAŞKENT swipe,
- B5 soft-time,
- Flutter analyze + focused/full test,
- Android 16 screenshot/artifact,
- crash/ANR/FATAL/process-death taraması,
- bağlayıcı referans ile side-by-side görsel inceleme

yapılmadan görsel/teknik PASS verilmez.

PR Ready ve merge ayrı kullanıcı onayı ister.
