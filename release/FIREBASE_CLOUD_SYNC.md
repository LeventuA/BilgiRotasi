# Bilgi Rotası — Google Girişi ve Bulut Kayıt

## Firebase projesi

- Proje kimliği: `bilgi-rotasi-f255d`
- Android paket adı: `com.leventua.bilgirotasi`
- Kimlik sağlayıcı: Google
- Veritabanı: Cloud Firestore, `(default)`, `eur3`
- Güvenlik: Her kullanıcı yalnızca kendi `users/{uid}` belgesini okuyup yazabilir.

## Kullanıcı akışı

- İlk açılışta Google ile giriş veya Misafir seçilir.
- Misafir kullanıcı Günlük Görev'i görmez.
- Misafir ilerlemesi yalnızca telefonda tutulur.
- Google kullanıcısının XP, başarımlar, kayıtlı oyun, temalar ve tercihleri buluta yazılır.
- İlk Google girişinde uzakta kayıt yoksa mevcut telefon ilerlemesi buluta aktarılır.
- Yeni telefonda aynı Google hesabıyla giriş yapıldığında bulut kaydı geri yüklenir.
- Hesaptan çıkıldığında hesap verisi bulutta kalır ve misafir kaydı geri yüklenir.

## Güvenlik notları

`google-services.json` içindeki proje tanımlayıcıları istemci yapılandırmasıdır.
JKS imza anahtarı ve parolalar yalnızca GitHub Secrets içinde tutulmaya devam eder.

## 1.47.1+63 veri deposu hotfix'i

- Oyun ilerlemesi ve bulut yedeği artık aynı `SharedPreferencesAsync`
  / Android DataStore alanını kullanır.
- Bulut okuması doğrudan sunucudan yapılır.
- Yazılan kayıt sunucudan tekrar okunarak doğrulanır.
- Boş bir eski bulut belgesi, dolu telefon kaydının üzerine yazılmaz.
