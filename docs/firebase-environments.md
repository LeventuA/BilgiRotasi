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
