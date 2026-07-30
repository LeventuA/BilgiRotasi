# app-ads.txt kurulum rehberi

Depoya tahmini veya uydurma bir `app-ads.txt` satırı eklenmemelidir.

1. AdMob panelinde Bilgi Rotası uygulamasını açın ve Google’ın gösterdiği gerçek
   `app-ads.txt` satırını aynen alın.
2. Play Console’da uygulama için doğrulanmış geliştirici web alanını belirleyin.
3. Dosya bu alanın **kökünde** erişilebilir olmalıdır. Örneğin:
   `https://leventua.github.io/app-ads.txt`.
4. `https://leventua.github.io/BilgiRotasi/app-ads.txt` proje alt yoludur ve
   mağazada geliştirici alanı `https://leventua.github.io` ise kök dosyanın
   yerini tutmaz.
5. Kök yayın için `leventua.github.io` adlı ayrı GitHub Pages deposu veya
   doğrulanmış özel alan/Firebase Hosting kullanılabilir.
6. Yayından sonra AdMob tarama durumunu ve dosyanın düz metin HTTP 200 yanıtını
   doğrulayın.

Gerçek AdMob satırı elde edilene kadar dosya oluşturulması beklemektedir.
