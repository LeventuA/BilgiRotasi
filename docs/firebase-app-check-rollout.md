# Firebase App Check aşamalı devreye alma

Kod hazırdır; Firebase Console enforcement bu dal tarafından açılamaz ve açılmış
sayılmamalıdır.

- Production release, `FIREBASE_ENVIRONMENT=production` ile Play Integrity
  provider kullanır.
- Development yalnız debug build ve açık
  `FIREBASE_ENVIRONMENT=development` seçimiyle debug provider kullanır.
- Varsayılan/test/CI profili Firebase ağ erişimini başlatmaz; debug token veya
  production secret gerekmez.
- Debug token, servis hesabı ve Play Integrity anahtarı repoya yazılmaz.

Dağıtım sırası:

1. Android uygulamasını Firebase App Check içinde Play Integrity ile kaydedin.
2. Production imzalı staging sürümünü internal test kanalında çalıştırın.
3. Functions, Firestore ve Authentication App Check metriklerini en az bir
   yayın döngüsü izleyin.
4. Geçerli istek oranı ve eski sürüm dağılımı kabul edilebilir olmadan
   enforcement açmayın. Yeni callable fonksiyonlarda kod içindeki
   `enforceAppCheck: false` değerleri bu ölçüm döneminde korunur.
5. Önce düşük riskli callable fonksiyonlarda, sonra Firestore'da enforcement
   açın. Hesap silme erişimini yanlışlıkla engellemediğinizi ayrıca doğrulayın.
6. Sorunda Console enforcement'ı kapatın; Play Integrity provider kodunu debug
   provider ile değiştirmeyin.
