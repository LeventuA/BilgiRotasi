# Bilgi Rotası — Kelime Avı Başlangıç Checkpoint'i

**Tarih:** 20 Ağustos 2026

## Canlı kaynak

- Kanonik release: `release/final-closed-test-aab-1.68.8`
- Exact başlangıç SHA: `9331802b9a2b12d1f4ec6715da96dc7d0f60b24b`
- Sürüm: `1.68.17+107`
- Çalışma branch'i: `feat/home-word-hunt-foundation-20260820`
- Issue: `#73`
- Draft PR: `#74`

## Kullanıcı kararı

Mevcut yayınlanmış/çalışan Bilgi Rotası oyununa bu hazırlık aşamasında dokunulmayacak. Yeni ana ekran mimarisi ve Kelime Avı ayrı feature hattında izole hazırlanacak.

### Ana ekran ürün kararı

- Ana oyun girişleri `Bilgi Oyunu` ve `Kelime Avı` olacak.
- `Oyna`, entegrasyon zamanı `Bilgi Oyunu` adını alacak.
- `Ayarlar` ana karttan çıkıp profil hizasında üst ikon olacak.
- `Kariyer` ve `Sosyal` ana ekrandan kalkıp Profil içine taşınacak.
- `Günlük Görevler` ana ekranda destek alanı olarak kalacak.
- Yeni oyunlar daha sonra aynı mod-kart yapısına eklenebilecek.

### Görsel yön

- Koyu gece/lacivert zemin.
- Altın pusula ve rota dili.
- Bilgi Oyunu turkuaz, Kelime Avı mor/indigo vurgu.
- Eski dashboard grafik dili yeni oyun-merkezi diliyle aşamalı değiştirilecek.

### Kelime Avı ilk kapsam

- İlk rota: `Başlangıç Limanı`.
- 10 bölüm.
- Normal, meydan okuma, bonus durak ve rota finali.
- 1–3 yıldız.
- Sıralı bölüm kilit açma.
- Rota finali + yıldız eşiği.
- Bilgi kartları.
- Gelecekte Kayıp Kelime, Bilgi Zinciri ve Canlanan Harita varyasyonlarına açık veri modeli.

## Üretilenler

Dokümantasyon:

- `docs/kelime-avi/README.md`
- `docs/kelime-avi/ANA_EKRAN_V1.md`
- `docs/kelime-avi/KELIME_AVI_V1.md`

İzole yeni çekirdek:

- `lib/word_hunt/word_hunt_models.dart`
- `lib/word_hunt/word_hunt_progress.dart`

Testler:

- `test/word_hunt_models_test.dart`
- `test/word_hunt_progress_test.dart`

Bu dosyaların hiçbiri mevcut `main.dart` veya ana navigasyona bağlanmadı.

## Korunan alanlar

- `assets/questions.json`: değişmedi.
- `lib/main.dart`: değişmedi.
- mevcut oyun ekranları: değişmedi.
- BoardMap / 67 node / 3B: değişmedi.
- Firebase/AdMob/Play config: değişmedi.
- `pubspec.yaml`: değişmedi.

## Test kanıtı

GitHub Actions run `32344056578`, job `96348908375`:

- setup adımları PASS.
- dependency graph PASS.
- **Analyze + tüm Flutter testleri PASS**; yeni Kelime Avı testleri suite'e dahil.
- signing hazırlığı PASS.
- Bu checkpoint yazılırken release APK / Android 16 kalan kapılar hâlâ çalışıyor; tam workflow sonucu ayrıca doğrulanacak.

Container üzerinden yerel clone denemesi dış ağ DNS erişimi olmadığı için yapılamadı; canlı test kanıtı GitHub Actions'tan alınmıştır.

## Sonraki açık işler

1. Kelime seçim/path motoru + test.
2. Progress serialize/restore + hesap-scope güvenli anahtarlar.
3. Başlangıç Limanı örnek veri paketi + validator.
4. Rota/level ekran prototipleri.
5. Profil ekranı prototipi.
6. Kullanıcı görsel onayından sonra mevcut ana navigasyona kontrollü entegrasyon.

## Merge durumu

Draft PR `#74` açık. Kullanıcı ayrıca açık merge onayı vermeden release'e merge yok.
