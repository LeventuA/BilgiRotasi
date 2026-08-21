# Bilgi Rotası — Kelime Avı Başlangıç Checkpoint'i

**Tarih:** 20 Ağustos 2026

## Canlı kaynak

- Kanonik release: `release/final-closed-test-aab-1.68.8`
- Exact başlangıç SHA: `9331802b9a2b12d1f4ec6715da96dc7d0f60b24b`
- Sürüm: `1.68.17+107`
- Çalışma branch'i: `feat/home-word-hunt-foundation-20260820`
- Issue: `#73`
- Draft PR: `#74`
- Son doğrulanmış merge-prep head: `fcc713f6094f3a826aaa199ed1d956afd289fc88`

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

Canlı PR #74 toplam **24 dosya** içerir. İlk teknik/ürün kapsamı 22 dosyaydı; görev sonu zorunlu proje-hafızası güncellemeleriyle `docs/project-memory/BILGI_ROTASI_DURUM.md` ve `docs/project-memory/GOREV_HAVUZU.md` de PR kapsamına girdi. PR gövdesi gerçek 24 dosyalık kapsama ve `fcc713f...` merge-prep CI kanıtına hizalanmıştır.

Dokümantasyon / proje hafızası:

- `docs/kelime-avi/ANA_EKRAN_V1.md`
- `docs/kelime-avi/KELIME_AVI_V1.md`
- `docs/kelime-avi/README.md`
- `docs/project-memory/BILGI_ROTASI_DURUM.md`
- `docs/project-memory/GOREV_HAVUZU.md`
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
5. Exact teknik head `c377e904...` için run `32361507978` / job `96401878115` içinde **`Analiz ve tüm testler` SUCCESS** oldu. Bu, dar ekran testi ve günlük callback regresyonu dahil tüm Flutter test aşamasının geçtiğini doğrular.
6. PR kapsam düzeltme head'i `343ebf2d9241888bdbcd31536f79bd62720191ac` için AdMob PR doğrulaması #301 / run `32362882273` **SUCCESS** oldu.
7. Merge-prep docs head `fcc713f6094f3a826aaa199ed1d956afd289fc88` için AdMob PR doğrulaması #302 / run `32377129911` / job `96451136017` **SUCCESS** oldu. Analyze + tüm testler, kalıcı Android imzası, release APK, package/manifest ve Android 16 ilk deneme/final app gate PASS; ikinci temiz emulator gerekmedi.
8. #302 artifact `BilgiRotasi-AdMob-1.68.17-107-kanitlari`, ID `9409986778`, digest `sha256:7b650d890cd7771f372d2ca69b90e6f84560b139227161640633d92a99f1fec6`. İndirilen ZIP SHA-256 digest ile birebir eşleşti. Android 16 `RESULT=PASS`, `APP_GATE=PASS`, `RELEASE_GATE=PASS`; PID `1866`; Bilgi Rotası paketine ait FATAL/ANR/crash/process-death eşleşmesi yok.

Bu checkpoint'i güncelleyen sonraki docs-only commit yeni bir PR HEAD oluşturacaktır. Final CI sonucu burada her docs commit ile tekrar statik SHA kovalanarak dondurulmaz; Draft'tan çıkarma veya merge gibi kritik geçişten hemen önce **canlı mevcut PR HEAD** ve onun workflow/log/artifact sonucu yeniden okunur.

## Korunan alanlar

- `assets/questions.json`: değişmedi.
- `lib/main.dart`: değişmedi.
- mevcut Bilgi Oyunu oynanışı ve ana navigasyon: değişmedi.
- BoardMap / 67 node / 3B: değişmedi.
- Firebase/AdMob/Play config: değişmedi.
- `pubspec.yaml`: değişmedi; `1.68.17+107`.

## Proje-hafızası düzeltmesi

- `GOREV_HAVUZU.md` içindeki Kelime Avı kapsamı 22 → **24 dosya** olarak canlı PR ile hizalandı.
- Önceki kanonik görev-havuzu blobu `538e1055d50c831dad7111de5a91a4f49809a0fb` içinde açık olan `BR-P2-003 - Profesyonel tanıtım videosu`, sadeleştirme sırasında yanlışlıkla düşmüş olduğu için aynı ürün kapsamıyla geri kondu.
- BR-P0-014 içindeki final merge-prep CI ve PR gövdesi maddeleri #302 kanıtıyla tamamlandı olarak işaretlendi.
- `KARARLAR.md` değişmedi; yeni ürün veya teknik karar alınmadı.

## Sonraki açık işler

1. İzole prototip için kullanıcı görsel/onay turunu yap; bu onay olmadan mevcut ana navigasyona entegrasyon yapma.
2. Profil ekranı ve hesap kapsamlı gerçek persistent storage entegrasyonunu ayrı kontrollü görevde ele al.
3. PR #74 Draft olarak kalsın; ayrı açık merge onayı olmadan release'e merge edilmesin.
4. Draft'tan çıkarma veya merge değerlendirmesinden hemen önce canlı PR HEAD + final CI/workflow/artifact sonucu yeniden doğrulansın.

## Merge durumu

Draft PR `#74` açık ve merge edilmemiştir. Bu checkpoint güncellemesi merge yetkisi değildir.
