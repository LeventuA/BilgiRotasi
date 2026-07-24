# Bilgi Rotası — Kalıcı İmzalı Derleme Hattı

## Kimlik

- Android paket adı: `com.leventua.bilgirotasi`
- Sürüm: `1.47.0+62`
- Kanal: `RC2`
- Sertifika SHA-1: `00:0E:E4:3F:41:0A:BC:6B:4F:63:4C:4F:71:6D:76:EB:19:08:41:15`
- İmza anahtarı: GitHub Secrets içindeki kalıcı upload anahtarı

## Derleme akışı

GitHub Actions her çalışmada:

1. Temiz Android projesini `com.leventua.bilgirotasi` kimliğiyle oluşturur.
2. Firebase `google-services.json` dosyasını Android uygulama modülüne kopyalar.
3. Google Services Gradle eklentisini uygular ve internet iznini doğrular.
4. Şifreli GitHub Secrets içindeki JKS anahtarını geçici derleme alanına açar.
5. Release APK'yı kalıcı anahtarla imzalar.
6. APK sertifikasının SHA-1 değerini yayın kimliğiyle karşılaştırır.
7. APK'yı artifact paketinin kökünde kolay indirilebilir adla sunar.

## Güvenlik

- JKS dosyası ve parolalar depoya yazılmaz.
- Anahtar yalnızca GitHub Actions çalışırken geçici klasörde bulunur.
- Gerçek imza parolaları loglara yazdırılmaz.
- Firestore erişimi kullanıcı kimliğine göre sınırlandırılır.
- `assets/questions.json` bu kurulumda değiştirilmez.

## Artifact

- Paket adı: `BilgiRotasi-Signed-RC2-1.47.0-62`
- APK: `BilgiRotasi-1.47.0-62-signed.apk`
