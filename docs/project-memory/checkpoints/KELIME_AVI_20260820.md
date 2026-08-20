# Bilgi Rotası — Kelime Avı Başlangıç Checkpoint'i

**Tarih:** 20 Ağustos 2026

## Canlı kaynak

- Kanonik release: `release/final-closed-test-aab-1.68.8`
- Exact başlangıç SHA: `9331802b9a2b12d1f4ec6715da96dc7d0f60b24b`
- Sürüm: `1.68.17+107`
- Çalışma branch'i: `feat/home-word-hunt-foundation-20260820`
- Issue: `#73`
- Draft PR: `#74`
- Son teknik head: `c377e9043b039c2e1368704fcd875cc60bf8f597`

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
- Türkçe uyumlu 8 yönlü seçim yolu.
- Hesap kapsamlı ilerleme codec'i.
- Yıldız puanlama ve içerik validator'ı.
- İzole 6×6 oynanabilir bölüm prototipi.
- Gelecekte Kayıp Kelime, Bilgi Zinciri ve Canlanan Harita varyasyonlarına açık veri modeli.

## Güncel PR kapsamı

Canlı PR #74 toplam 22 dosya içerir. İlk PR açıklamasındaki 7 dosyalık liste artık bayattır ve PR gövdesi final teknik kanıta göre güncellenecektir.

Dokümantasyon:

- `docs/kelime-avi/ANA_EKRAN_V1.md`
- `docs/kelime-avi/KELIME_AVI_V1.md`
- `docs/kelime-avi/README.md`
- bu checkpoint

İzole yeni çekirdek/prototip:

- `lib/word_hunt/home_hub_prototype.dart`
- `lib/word_hunt/home_hub_screen.dart`
- `lib/word_hunt/word_hunt_content_validator.dart`
- `lib/word_hunt/word_hunt_models.dart`
- `lib/word_hunt/word_hunt_path.dart`
- `lib/word_hunt/word_hunt_progress.dart`
- `lib/word_hunt/word_hunt_progress_codec.dart`
- `lib/word_hunt/word_hunt_scoring.dart`
- `lib/word_hunt/word_hunt_screens.dart`
- `lib/word_hunt/word_hunt_starter_content.dart`

Testler:

- `test/home_hub_prototype_test.dart`
- `test/word_hunt_models_test.dart`
- `test/word_hunt_path_test.dart`
- `test/word_hunt_progress_codec_test.dart`
- `test/word_hunt_progress_test.dart`
- `test/word_hunt_prototype_screens_test.dart`
- `test/word_hunt_scoring_test.dart`
- `test/word_hunt_starter_content_test.dart`

## CI blocker ve düzeltme

PR head `0ac0ef303936221f0c923701f974b3f8be00a83f` üzerinde AdMob PR doğrulaması run `32348243734` başarısızdı.

1. `lib/word_hunt/home_hub_screen.dart` içindeki dikey `SingleChildScrollView` altında bulunan ana mod `Row`'u `CrossAxisAlignment.stretch` kullanıyor, kart içindeki `Column` ise `Spacer()` taşıyordu. Sınırsız dikey ölçü altında bu kombinasyon kaldırıldı.
2. Commit `a9bb89ed1f80790ddbe9c81e79d83d2347c2e2da` — `fix: stabilize home hub responsive layout`: yalnız ilgili `Row` stretch davranışı kaldırıldı ve `Spacer()` bounded boşlukla değiştirildi.
3. Run `32361294613` / job `96401221605` sonucunda `360×800` dar ekran regresyon testi **PASS** oldu. Kalan tek hata, `Günlük Görevler` kartının varsayılan widget test yüzeyinde ekran dışında (`y=648`, kök `800×600`) iken testin scroll etmeden `tap()` çağırmasıydı; callback `Expected 1 / Actual 0` ile kaldı.
4. Commit `c377e9043b039c2e1368704fcd875cc60bf8f597` — `test: scroll home hub daily card into view`: test `ensureVisible` + `pumpAndSettle` sonrası karta dokunur; runtime küçültülmedi.
5. Exact teknik head `c377e904...` için run `32361507978` / job `96401878115` içinde **`Analiz ve tüm testler` SUCCESS** oldu. Bu, dar ekran testi ve günlük callback regresyonu dahil tüm Flutter test aşamasının geçtiğini doğrular. Proje hafızası commitleri yeni head oluşturacağı için final PR-head CI sonucu statik olarak bu checkpoint'e dondurulmaz; GitHub'dan son head üzerinde canlı okunur.

## Korunan alanlar

- `assets/questions.json`: değişmedi.
- `lib/main.dart`: değişmedi.
- mevcut Bilgi Oyunu oynanışı ve ana navigasyon: değişmedi.
- BoardMap / 67 node / 3B: değişmedi.
- Firebase/AdMob/Play config: değişmedi.
- `pubspec.yaml`: değişmedi; `1.68.17+107`.

## Sonraki açık işler

1. Tüm proje-hafızası güncellemelerinden sonraki final PR #74 head'inde AdMob PR doğrulamasını tam workflow/log/artifact/Android 16 kapılarıyla doğrula.
2. İzole prototip için kullanıcı görsel/onay turu tamamlanmadan mevcut ana navigasyona entegrasyon yapma.
3. Profil ekranı ve hesap kapsamlı gerçek storage entegrasyonunu ayrı kontrollü adımda ele al.
4. PR #74 Draft olarak kalsın; ayrı açık merge onayı olmadan release'e merge edilmesin.

## Merge durumu

Draft PR `#74` açık ve merge edilmemiştir. Bu checkpoint güncellemesi merge yetkisi değildir.
