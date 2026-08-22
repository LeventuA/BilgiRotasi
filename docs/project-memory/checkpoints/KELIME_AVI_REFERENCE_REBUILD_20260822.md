# Kelime Avı — Referans sözleşmesi temiz yeniden-kurma checkpoint'i

**Tarih:** 22 Ağustos 2026

## Canlı başlangıç ve final kesim

- Repo: `ZMilaStudio/BilgiRotasi`
- Kanonik release: `release/final-closed-test-aab-1.68.8`
- Görev sırasında yeniden doğrulanan canlı release HEAD: `7e2d4a00d1e56f29aeb6513d40b212454f18a905`
- Release HEAD mesajı: `ci: cap Actions artifact retention`; ürün kodu/sürümü değil CI artifact saklama süreleri değişti.
- Sürüm: `1.68.19+109`
- Foundation: `feat/kelime-avi-clean-release-integration-20260821` / exact `070b7306ccd4e3273e81c0ac2a7ad1f489185d95` / PR #96 Draft.
- Temiz çalışma branch'i: `fix/kelime-avi-reference-contract-rebuild-20260822`
- Ürün PR: #107 Draft / merge yok.
- Artifact-only doğrulama PR: #108 Draft / **DO NOT MERGE**.
- Final teknik/görsel-proof HEAD: `6f94498860a7cdfe08d1e4d2bdd77fe84fa1b9b0`.

## Kullanıcı kararı / görsel sınır

- PR #98'in son Android ekranı teknik PASS olsa da resmi Başlangıç Limanı referansıyla yeterli görsel ilişkisi olmadığı için kullanıcı tarafından reddedildi.
- PR #98 geometrisi bu temiz hatta taşınmadı.
- Resmi referans ilham değil, bağlayıcı kompozisyon sözleşmesidir.
- 1–4 üst bölgede ferah; 5 merkez-sol ve kart sağında; 6 sol geçiş; 7 merkez/merkez-sağ ve 9'dan belirgin uzak; 8 sağ ve kart sağında; 9 sol/kilitli; 10 alt-orta ve kart sağında; pusula sol alt, kitap sağ alt.
- Referans dışı `Fener`, `Liman`, `Hazine` sahne etiketleri kullanılmaz.

## Modüler rota durağı

`lib/word_hunt/word_hunt_route_stop.dart`:

- `WordHuntRouteStopMetrics.referenceBaseline`
- `WordHuntRouteStopTheme.harbor`
- ortak `WordHuntRouteStop`
- açık/kilitli aynı geometri
- her durakta 3 yıldız yuvası
- kilitli durakta callback yok
- 5/8/10 özel durak ailesi
- tema değişiminde geometri sabit

Test: `test/word_hunt_route_stop_test.dart`.

İlk doğrulama kırmızısı ürün kodu değildi: testte iki geçersiz `const Size.square(metrics.normalDiameter)` kullanımı. Beklenti/geometri gevşetilmeden yalnız `const` kaldırıldı.

## Resmi 1–10 referans prototipi

- `test/word_hunt_reference_route_screen_test.dart` ile referans hiyerarşisi test-first kilitlendi.
- `lib/word_hunt/word_hunt_reference_route_screen.dart` eklendi.
- Yeni ekran production `lib/main.dart`'a bağlı değildir.
- Eski `WordHuntRouteMapV2Screen` değiştirilmedi; reddedilen PR #98 geometrisi kopyalanmadı.
- 5/8/10 özel etiketleri sağda; 9 sol; 7 ile 9 ayrık; 10 alt-orta.
- `word_hunt_visual_proof_main.dart` yeni referans prototipine yönlendirildi.
- Kanonik `.github/workflows/word-hunt-visual-proof.yml` yeni rota-durak ve referans-ekran testlerini explicit focused suite'e dahil eder.

## Gerçek Android görüntüsünden yakalanan iki kusur ve test-first düzeltme

### 1. 3 / 4 üst bölge sıkışması

İlk yeni Android 16 proof'unda 3 numaranın yıldız alanı 4 numaraya fazla yaklaşıyordu.

- `4649df65e4976fd051b70624974cad9a48b29e87` — `test(kelime-avi): prevent upper route-stop overlap`
- `5affdc892bde7a90bfada7501a503b38f390ea4f` — `fix(kelime-avi): separate upper reference stops`
- 4. durak: `Offset(0.66, 0.30)` → `Offset(0.77, 0.35)`.

Regresyon testi 3 ve 4 widget kutularının çakışmamasını ve en az 8 px düşey nefes payını kilitler.

### 2. 7 yıldızları / Bonus 8 çakışması

`5affdc8...` Android 16 görüntüsünde 7 numaranın yıldızlarından ikisi Bonus 8 özel durağın arkasında kalıyordu.

- `164ee61dfbe177afe3da4f60cf38cd03610298ad` — 7/8 çakışma regresyon testi.
- `b36f92f3794d3c8cb6e8a0e0da70726a7bd34bf3` — `fix(kelime-avi): clear level 7 stars from bonus stop`
- 7: `Offset(0.52, 0.58)` → `Offset(0.41, 0.64)`.
- 8: `Offset(0.58, 0.69)` → `Offset(0.60, 0.69)`.

İlk test ikinci şartta zorunlu düşey boşluk istediği için yanlış eksende kırıldı; asıl `seven.overlaps(eight) == false` şartı zaten PASS idi. Çakışma şartı kaldırılmadan doğru yatay güvenlik boşluğuna çevrildi:

- `6f94498860a7cdfe08d1e4d2bdd77fe84fa1b9b0` — `test(kelime-avi): validate horizontal clearance for bonus stop`.

## Final exact-head kanıtı

Exact HEAD: `6f94498860a7cdfe08d1e4d2bdd77fe84fa1b9b0`.

### Kelime Avı Android 16 görsel kanıtı

- Workflow run: `32592905067`
- Job: `97079377331`
- Sonuç: **SUCCESS**
- Focused suite: **PASS**
- `dart analyze lib/word_hunt`: **0 issue**
- İzole APK ve asset doğrulaması: **PASS**
- Android 16 gerçek ekran çekimi: **PASS**
- Artifact ID: `9480899184`
- Artifact adı: `BilgiRotasi-KelimeAvi-VisualProof-6f94498860a7cdfe08d1e4d2bdd77fe84fa1b9b0`
- Artifact digest: `sha256:c1cd002a9be8563df0620fa96c2cd5d7759fa1504e2c421301c4c7a4097717fb`
- `SOURCE_EQUALS_PACKAGED=YES`
- Runtime `[WORD_HUNT_ASSET_LOADED] path=assets/word_hunt/baslangic_limani_bg.jpg`
- `MainActivity` / Bilgi Rotası process görünür ve proof kapıları PASS.

Gerçek Android 16 ekranının gözle incelemesinde:

- 3/4 ayrımı temiz.
- 7'nin üç yıldızı tamamen görünür.
- Bonus 8 yıldız alanını kapatmıyor.
- 5 `MEYDAN OKUMA`, 8 `BONUS DURAK`, 10 `ROTA FİNALİ` kartları düğümlerin sağında.
- 9 solda/kilitli.
- 10 alt-orta.
- Pusula sol alt, kitap sağ alt.
- Onaylı gece limanı background asset'i korunuyor.

Bu gözle inceleme **kullanıcı nihai görsel onayı değildir**; yalnız teknik/görsel-proof değerlendirmesidir.

### Genel uygulama regresyonu

- `AdMob PR doğrulaması` run: `32592905065`
- Job: `97079377374`
- Sonuç: **SUCCESS**
- Analiz + tüm Flutter testleri: **PASS**
- Kalıcı imza hazırlığı: **PASS**
- Release APK: **PASS**
- Paket / birleşik manifest: **PASS**
- Android 16 cold-start deneme 1: **PASS**
- Deneme 2: gerekmedi / SKIPPED
- Final app/release gate: **PASS**

## Korunan alanlar

Değişmedi:

- `assets/questions.json`
- production `lib/main.dart`
- onaylı `assets/word_hunt/baslangic_limani_bg.jpg`
- oyun/progression mantığı
- BoardMap / 67 node / 3B
- Android / AdMob / Firebase / release config

`KARARLAR.md` değişmedi; yeni ürün kararı üretilmedi, mevcut resmi referans/modüler tema kararı uygulandı.

## Durum / açık kapılar

**TEKNİK PASS / ANDROID 16 GÖRSEL KANIT PASS / PR #107 AÇIK + DRAFT / MERGE YOK / LEVENT NİHAİ GÖRSEL KABULÜ AÇIK.**

1. Levent exact `6f94498...` Android 16 ekranını resmi Başlangıç Limanı referansına göre görsel olarak kabul eder veya net fark bildirir.
2. Görsel kabul olmadan PR #107 → PR #96 merge edilmez.
3. Levent ayrıca açık merge onayı vermeden PR #96 → release merge edilmez.
4. Production ana navigasyon ayrı branch ve ayrı açık onay gerektirir.
5. PR #108 yalnız artifact doğrulama hattıdır; **merge edilmez**.
