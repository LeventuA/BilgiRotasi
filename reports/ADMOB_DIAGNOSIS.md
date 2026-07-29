# AdMob tanılama özeti

## Kanıtlanan bulgular

- Fiziksel cihazlarda açılan reklamsız `1.68.4+94` tabanının kilit dosyası
  zaten `path_provider_android 2.3.1`, `jni 1.0.0` ve `jni_flutter 1.0.1`
  bağımlılıklarını içerir. Bu zincir tek başına önceki açılış çökmesinin kök
  nedeni olamaz.
- `1.68.3+93` için başarılı görünen eski AdMob workflow'u gerçek uygulama
  açılışı yapmamış; analiz, test ve APK/AAB derlemesiyle sınırlı kalmıştır.
  Dolayısıyla başarılı build sonucu fiziksel açılış kanıtı değildir.
- Önceki `path_provider_android 2.2.23` override denemesi gerçek bir crash
  stack trace ile doğrulanmamıştır. Bu entegrasyonda override kullanılmaz.

## Bağımlılık farkı

`1.68.4+94` tabanına doğrudan `google_mobile_ads 9.0.0` eklenmiştir. Yeni
transitif paketler:

- `webview_flutter 4.14.1`
- `webview_flutter_android 4.13.0`
- `webview_flutter_platform_interface 2.15.1`
- `webview_flutter_wkwebview 3.26.0`

Mevcut `path_provider_android`, `jni` ve `jni_flutter` sürümleri değişmemiştir.

## Güvenli açılış yaklaşımı

- `MobileAds.instance.initialize()` uygulamanın `main()` açılış yolunda
  çağrılmaz.
- SDK yalnız banner veya isteğe bağlı ödüllü reklam gerçekten istendiğinde
  tembel olarak başlatılır.
- Başlatma, yükleme ve gösterim hataları yakalanır; oyun akışı reklamsız devam
  eder.
- Resmî `MobileAdsInitProvider` kaldırılmaz. Birleşik release APK manifesti ve
  Android 16 cold-start sonucu PR doğrulama workflow'unda denetlenir.

## Yerel doğrulama

- `flutter analyze --no-fatal-warnings --no-fatal-infos`: geçti; tabanda
  önceden bulunan 91 uyarı/bilgi raporlandı.
- `flutter test test/ad_monetization_test.dart --reporter expanded`: 6/6 geçti.
- `flutter test --concurrency=1 --reporter expanded`: 123/123 geçti.
- Yerel Android 16 sistem görüntüsü kurulumu disk alanı yetersizliği nedeniyle
  tamamlanamadı. Aynı cold-start/logcat kontrolü
  `.github/workflows/admob-pr-validation.yml` içinde temiz API 36 emulatoründe
  zorunlu tutulmuştur.
