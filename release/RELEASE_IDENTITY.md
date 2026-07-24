# Bilgi Rotası — Kalıcı Yayın Kimliği

- Android uygulama kimliği: `com.leventua.bilgirotasi`
- İmza anahtar takma adı: `bilgi_rotasi_upload`
- Sertifika SHA-1: `00:0E:E4:3F:41:0A:BC:6B:4F:63:4C:4F:71:6D:76:EB:19:08:41:15`
- Sertifika SHA-256: `3B:36:82:4E:F1:47:6B:68:89:A0:24:D0:46:7B:5C:EA:89:03:AA:7E:EE:B4:5B:46:87:C5:BA:A8:E4:60:F2:78`
- Anahtar türü: `RSA-4096`
- Geçerlilik: `10000 gün`

## Güvenlik

Gerçek keystore ve parolalar depoya eklenmez. GitHub Actions için yalnızca
şifreli GitHub Secrets kullanılır:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

Yerel özel dosyalar `.private/` altında tutulur ve Git tarafından yok sayılır.
`BILGI_ROTASI_IMZA_YEDEGI.zip` güvenli, kişisel bir yerde saklanmalıdır.
