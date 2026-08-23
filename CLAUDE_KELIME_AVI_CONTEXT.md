# Claude — Kelime Avı Başlangıç Limanı inceleme paketi

Bu export paketi yalnız analiz içindir. Ürün davranışını veya progression sistemini değiştirmek için bağlayıcı değildir.

## Kaynak

- Repo: `ZMilaStudio/BilgiRotasi`
- Kaynak branch: `fix/kelime-avi-approved-reference-pixel-match-20260823`
- Kaynak PR: `#110`
- Kaynak docs HEAD: `305dfb8cda2fd478ae85ccebb75aa919666c2217`
- Ürün kodu HEAD: `dc9360f4a965605330b1a5ad3c145e7868760fc7`
- Sürüm: `1.68.19+109`

## İncelenecek dosyalar

- `lib/word_hunt/word_hunt_models.dart`
- `lib/word_hunt/word_hunt_progress.dart`
- `lib/word_hunt/word_hunt_progress_codec.dart`
- `lib/word_hunt/word_hunt_starter_content.dart`
- `lib/word_hunt/word_hunt_reference_route_screen.dart`
- `lib/word_hunt/word_hunt_route_stop.dart`
- `lib/word_hunt/word_hunt_visual_proof_main.dart`
- `test/word_hunt_reference_route_screen_test.dart`
- `test/word_hunt_route_stop_test.dart`
- `pubspec.yaml`

## Kritik kurallar

1. Yeni progression/repository/controller sistemi oluşturma.
2. `WordHuntProgressSnapshot`, `WordHuntRouteProgressEngine` ve mevcut codec tek kaynak olarak korunacak.
3. `word_hunt_route_map_screen.dart` ve `word_hunt_route_map_v2_screen.dart` görsel referans değildir.
4. Paketle birlikte verilen `BASLANGIC_LIMANI_ONAYLI_REFERANS_1080x1920.png` tek bağlayıcı görsel referanstır.
5. Tam ekran screenshot production UI olarak gömülmeyecek.
6. Background statik sahne asset'i; node/rota/yıldız/kilit/plaka/panel dinamik Flutter katmanları olarak kalacak.
7. Önce kod yazmadan A–J teknik/görsel uygulama planı çıkarılacak.
