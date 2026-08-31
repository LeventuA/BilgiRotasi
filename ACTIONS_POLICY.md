# ZMila Studio GitHub Actions Politikası — Public Repo

**Kalıcı karar — 31 Ağustos 2026**

Bilgi Rotası public repo olduğu için standart GitHub-hosted runner dakikaları private repo aylık dakika bütçesi gibi kısıtlanmaz. Buna rağmen gereksiz workflow ve artifact üretimi önlenir.

- Public repo CI kalite kapıları normal şekilde kullanılabilir.
- Aynı PR'daki eski koşular `concurrency` + `cancel-in-progress: true` ile iptal edilmelidir.
- `paths` filtreleri ile ilgisiz değişikliklerde ağır Android/görsel doğrulama çalıştırılmamalıdır.
- APK/AAB yalnız test/release ihtiyacında üretilir; rutin PR artifact'i varsayılan değildir.
- Artifact oluşturuluyorsa kısa retention tercih edilir; kalıcı sürüm çıktıları GitHub Release üzerinde tutulur.
- Public dakika avantajı, kontrolsüz workflow çoğaltmak için gerekçe değildir; storage ve bakım maliyeti ayrıca yönetilir.

Özet: Bilgi Rotası'nda dakika kotası rahat, artifact/storage ve gereksiz run sayısı ise yine kontrollü olacaktır.
