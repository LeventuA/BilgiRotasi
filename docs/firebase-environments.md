# Firebase development / production ayrımı

- Varsayılan `FIREBASE_ENVIRONMENT=test`: Firebase Core, Authentication,
  Firestore ve Functions ağ bağlantısı başlatılmaz. CI ve Android 16 cold-start
  bu profildedir.
- `development`: yalnız debug build; Firebase App Check debug provider.
  Ayrı development Firebase projesi ve onun `google-services.json` dosyası
  gerekir.
- `production`: yalnız release build; Play Integrity provider. Production
  workflow hem `ADMOB_ENVIRONMENT=production` hem
  `FIREBASE_ENVIRONMENT=production` verir.

Production AdMob seçilip Firebase test seçili (veya tersi) bir artifact
yayınlanmamalıdır. Workflow testleri iki define'ın birlikte bulunduğunu
doğrular. Development `google-services.json`, App Check debug tokenları ve
service account dosyaları commit edilmez.

## FCM duyuru profilleri

Push ortamı varsayılan olarak güvenli biçimde kapalıdır. Ayrı bir
`PUSH_ENVIRONMENT` verilmezse merkezî politika mevcut derleme profillerini şöyle
eşler:

- `ADMOB_ENVIRONMENT=test` + Firebase test: FCM uzak bağlantısı ve topic yok.
- Firebase development debug: `bilgi_rotasi_announcements_dev`.
- `ADMOB_ENVIRONMENT=closed_test`: `bilgi_rotasi_announcements_closed_test`.
- `ADMOB_ENVIRONMENT=production`: `bilgi_rotasi_announcements_production`.

`PUSH_ENVIRONMENT` yalnız kontrollü test/operasyon gerektiğinde bu eşlemeyi
açıkça geçersiz kılar. CI ve Android 16 test profili production/closed-test
topic'ine bağlanmaz. Topic adında Firebase UID, kullanıcı adı, e-posta veya
başka kullanıcı kimliği bulunmaz.
