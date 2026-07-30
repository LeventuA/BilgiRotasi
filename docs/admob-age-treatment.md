# AdMob yaş ve rıza sinyalleri

Bilgi Rotası 13 yaş ve üzeri kullanıcıları hedefler; 13 yaş altındaki çocukları
hedeflemez. Bununla birlikte uygulama güvenilir bir yaş doğrulaması toplamaz ve
13–15 yaş kullanıcılar bazı bölgelerde dijital rıza yaşının altında olabilir.
Bu nedenle kullanıcının yaşı bilinmiyorken reklam veya UMP isteğine “rıza
yaşının üzerindedir” ya da “rıza yaşının altındadır” şeklinde sabit bir sinyal
eklenmez.

Mevcut `google_mobile_ads: 9.0.0` entegrasyonunda:

- UMP `ConsentRequestParameters` varsayılan/unspecified davranışla oluşturulur.
- `RequestConfiguration` içinde under-age-of-consent alanı belirtilmez.
- Uygulama 13 yaş altını hedeflemediği için COPPA child-directed değeri `no`
  olarak kalır.
- Reklam içeriği en fazla `T/Teen` düzeyiyle sınırlandırılır.

Google’ın güncel Android Mobile Ads belgeleri, eski TFCD ve TFUA alanlarından
`AgeRestrictedTreatment` yaş uygulamasına geçişi ve reklam isteklerinde `tfat`
parametresini açıklar:

- https://developers.google.com/ad-manager/mobile-ads-sdk/android/targeting#set_the_age_treatment
- https://developers.google.com/admob/flutter/privacy/gdpr#tag_for_under_age_of_consent

Flutter eklentisinin projede kullanılan sürümü uygun ve belgelenmiş bir
`AgeRestrictedTreatment`/TFAT API’si sunmadığı için bu projeye hayalî bir Dart
alanı veya platforma özel geçici köprü eklenmez. `google_mobile_ads` uygun API’yi
sunduğunda bağımlılık yükseltmesi, Android/iOS davranış doğrulaması ve otomatik
testlerle ayrı bir geçiş yapılmalıdır.
