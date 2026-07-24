# Bilgi Rotası — Kalıcı İmzalı Derleme Hattı

## Kimlik

- Android paket adı: `com.leventua.bilgirotasi`
- Sürüm: `1.46.1+61`
- Sertifika SHA-1: `00:0E:E4:3F:41:0A:BC:6B:4F:63:4C:4F:71:6D:76:EB:19:08:41:15`
- İmza anahtarı: GitHub Secrets içindeki kalıcı upload anahtarı

## Derleme akışı

GitHub Actions her çalışmada:

1. Temiz Android projesini `com.leventua.bilgirotasi` kimliğiyle oluşturur.
2. Şifreli GitHub Secrets içindeki JKS anahtarını geçici derleme alanına açar.
3. `build.gradle.kts` dosyasını release imzası için yapılandırır.
4. Release APK'yı kalıcı anahtarla imzalar.
5. APK sertifikasının SHA-1 değerini yayın kimliğiyle karşılaştırır.
6. APK'yı artifact paketinin kökünde kolay indirilebilir adla sunar.

## Güvenlik

- JKS dosyası ve parolalar depoya yazılmaz.
- Anahtar yalnızca GitHub Actions çalışırken geçici klasörde bulunur.
- Gerçek değerler loglara yazdırılmaz.
- `assets/questions.json` bu kurulumda değiştirilmez.

## Artifact

- Paket adı: `BilgiRotasi-Signed-RC1-1.46.1-61`
- APK: `BilgiRotasi-1.46.1-61-signed.apk`
