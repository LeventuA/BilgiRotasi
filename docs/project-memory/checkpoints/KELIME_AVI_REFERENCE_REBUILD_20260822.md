# Kelime Avı — Referans sözleşmesi temiz yeniden-kurma checkpoint'i

**Tarih:** 22 Ağustos 2026

## Canlı başlangıç

- Repo: `ZMilaStudio/BilgiRotasi`
- Kanonik release: `release/final-closed-test-aab-1.68.8`
- Görev sırasında yeniden doğrulanan canlı release HEAD: `7e2d4a00d1e56f29aeb6513d40b212454f18a905`
- Release HEAD mesajı: `ci: cap Actions artifact retention`; ürün kodu/sürümü değil CI artifact saklama süreleri değişti.
- Sürüm: `1.68.19+109`
- Foundation: `feat/kelime-avi-clean-release-integration-20260821` / exact `070b7306ccd4e3273e81c0ac2a7ad1f489185d95` / PR #96 Draft.
- Temiz çalışma branch'i: `fix/kelime-avi-reference-contract-rebuild-20260822`
- Ürün PR: #107 Draft.
- Artifact-only doğrulama PR: #108 Draft / **DO NOT MERGE**.

## Kullanıcı kararı / görsel sınır

- PR #98'in son Android ekranı teknik PASS olsa da resmi Başlangıç Limanı referansıyla yeterli görsel ilişkisi olmadığı için kullanıcı tarafından reddedildi.
- PR #98 geometrisi bu temiz hatta taşınmaz.
- Resmi referans ilham değil, bağlayıcı kompozisyon sözleşmesidir.
- 1–4 üst bölgede ferah; 5 merkez-sol ve kart sağında; 6 sol geçiş; 7 merkez/merkez-sağ ve 9'dan belirgin uzak; 8 sağ ve kart sağında; 9 sol/kilitli; 10 alt-orta ve kart sağında; pusula sol alt, kitap sağ alt.
- Referans dışı `Fener`, `Liman`, `Hazine` sahne etiketleri kullanılmaz.

## İlk modüler katman

Yeni `lib/word_hunt/word_hunt_route_stop.dart`:

- `WordHuntRouteStopMetrics.referenceBaseline`
- `WordHuntRouteStopTheme.harbor`
- ortak `WordHuntRouteStop`
- açık/kilitli aynı geometri
- her durakta 3 yıldız yuvası
- kilitli durakta callback yok
- 5/8/10 özel durak ailesi
- tema değişiminde geometri sabit

İlk test: `test/word_hunt_route_stop_test.dart`.

İlk doğrulama kırmızısı ürün kodu değildi: testte iki geçersiz `const Size.square(metrics.normalDiameter)` kullanımı. Beklenti/geometri gevşetilmeden yalnız `const` kaldırıldı.

Düzeltme exact HEAD: `8c733a1129c89ea81320a87e97eaa16ff5881072` — `fix(kelime-avi): keep route-stop geometry assertions runtime-safe`.

Bu HEAD için:
- Kelime Avı focused suite PASS.
- Analiz + tüm Flutter testleri PASS.
- Kelime Avı Android 16 visual-proof run `32584633402` SUCCESS.
- Bu ekran henüz yeni referans prototipi değildi; yalnız ilk bileşenin regresyon kanıtıydı.

## İkinci katman — gerçek 1–10 referans prototipi

- `test/word_hunt_reference_route_screen_test.dart` ile referans hiyerarşisi test-first kilitlendi.
- `lib/word_hunt/word_hunt_reference_route_screen.dart` eklendi.
- Yeni ekran production `lib/main.dart`'a bağlı değildir.
- Eski `WordHuntRouteMapV2Screen` değiştirilmedi; reddedilen PR #98 geometrisi kopyalanmadı.
- Yeni `WordHuntReferenceRouteLayout.stops` 1–10 resmi hiyerarşiyi deterministik normalize koordinatlarla temsil eder.
- 5/8/10 özel etiketleri sağda; 9 sol; 7 ile 9 ayrık; 10 alt-orta.
- `word_hunt_visual_proof_main.dart` yeni referans prototipine yönlendirildi; bundan sonraki Android 16 screenshot'ı gerçek yeni prototipi gösterir.
- Kanonik `.github/workflows/word-hunt-visual-proof.yml` yeni `word_hunt_reference_route_screen_test.dart` dosyasını explicit focused suite'e dahil eder.

### İkinci katman commitleri

- `efe5a4f1d2579c2c39f025bdb42aa771dd59b443` — `test(kelime-avi): lock official reference route hierarchy`
- `18196c97361cd6f361b3575e9735e1650cce4818` — `feat(kelime-avi): build official reference route prototype`
- `58c4f6414c69be1f685a3dd4e8b57ae59542e22e` — `feat(kelime-avi): point visual proof to reference prototype`
- `662b0b3bdf89875fbaae1692663d085726c3d3e6` — `ci(kelime-avi): validate official reference route screen`

Exact `662b0b3...` doğrulama koşuları:
- Kelime Avı Android 16: `32585273281`
- Genel AdMob/release regresyonu: `32585273286`

Bu checkpoint yazılırken Kelime Avı focused suite yeni referans testi dahil **PASS**; APK/Android 16 ve genel regresyonun kalan adımları çalışıyordu. Tam job conclusion görülmeden final SUCCESS sayılmaz.

## Korunan alanlar

Değişmedi:
- `assets/questions.json`
- production `lib/main.dart`
- onaylı `assets/word_hunt/baslangic_limani_bg.jpg`
- oyun/progression mantığı
- BoardMap / 67 node / 3B
- Android / AdMob / Firebase / release config

`KARARLAR.md` değişmedi; yeni ürün kararı üretilmedi, mevcut resmi referans/modüler tema kararı uygulandı.

## Açık kapılar

1. Exact `662b0b3...` iki CI koşusunun final sonucu ve tam logları doğrulanır.
2. Yeni Android 16 artifact'ındaki üst/alt screenshot gerçek referans prototipi olarak incelenir.
3. Levent görsel kabul verir veya net fark bildirir.
4. Görsel kabul olmadan PR #107 → PR #96 veya release merge edilmez.
5. Production ana navigasyon ayrı branch ve ayrı açık onay gerektirir.
