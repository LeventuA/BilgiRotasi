# Kelime Avı — WORK V2 / Hızlı Otonom Üretim

**Yürürlük:** 3 Eylül 2026

Bu çalışma modeli mevcut proje özeti, GitHub geçmişi, onaylanmış ürün kararları ve canonical kuralları değiştirmez. Üretim hızını ve çalışma yöntemini belirler.

## Ana çalışma döngüsü

`HEDEF → TOPLU ÜRETİM → TOPLU DOĞRULAMA → KENDİ KENDİNE DÜZELTME → YENİDEN DOĞRULAMA → GÜÇLÜ ADAY / TAMAMLANMIŞ SONUÇ`

- Mikro değişiklik, rapor ve kullanıcıyı bekleme döngüsü kullanılmaz.
- Birbiriyle ilişkili işler mümkün olan en büyük mantıklı batch içinde tamamlanır.
- Başarısız yaklaşım yeni ürün kararı gerektirmiyorsa alternatif uygulanır ve yeniden doğrulanır.
- Kullanıcı geliştirici veya sürekli test operatörü değildir.

## Test ve GitHub

- Testler mikro adımlarda değil mantıklı checkpointlerde toplanır.
- Focused test, analyze, ilgili regression ve gerektiğinde Android/gerçek gameplay kanıtı birlikte değerlendirilir.
- Çözülebilir test hataları kullanıcı izni beklenmeden düzeltilip yeniden test edilir.
- Repo, branch, HEAD, commit, PR, CI ve Actions durumu canlı GitHub araçlarıyla kendiliğinden kontrol edilir.
- Araç/yetki yokluğu ancak mevcut araçlar yeniden keşfedilip kontrol edildikten sonra gerçek engel sayılır.

## Kullanıcıya dönülecek gerçek kapılar

1. Birden fazla ürün yönü arasında karar.
2. Gerçek insan görsel tercihi.
3. Yalnız fiziksel cihazda değerlendirilebilecek kabul.
4. Merge veya release onayı.
5. Dış servis, hesap, izin veya erişim engeli.
6. Çözülemeyen proje kararı çelişkisi.

## Canonical ve görsel kalite

- Canonical 8×8 gameplay ve onaylanmış bölüm/kelime/bonus/oynanış kararları korunur.
- Eski 6×10 veya superseded tasarımlara dönülmez.
- Başlangıç Limanı görselinde referans/onaylanmış dil esas alınır.
- Teknik olarak çalışan fakat görsel olarak zayıf çözüm tamamlanmış sayılmaz.
- Görsel batch; arka plan, kontrast, grid okunabilirliği, found/error seçimi, HUD ve ilgili yüzeyleri birlikte değerlendirir.
- Güçlü aday oyuna entegre edilir, toplu teknik doğrulamadan ve gerektiğinde Android kanıtından sonra kullanıcı görsel kabulüne getirilir.

## Dokümantasyon ve teslim

- Dokümantasyon üretimin önüne geçmez; önemli checkpoint sonunda fark bazlı güncellenir.
- Checkpoint kaydı önemli değişiklik, test sonucu, karar, reddedilen önemli yaklaşım, açık kapı ve commit/PR/run bilgisi taşır.
- Kullanıcıya sonuç dönüşü gerçekten tamamlanan işi, PASS doğrulamaları, kalan gerçek riski ve gereken tek sonraki kararı içerir.

## Merge ve release sınırı

- Teknik hazırlık otomatik merge/release yetkisi değildir.
- Levent’in açık onayı olmadan merge veya release yapılmaz.
- Merge öncesindeki düzeltme, test, CI inceleme ve kanıt hazırlığı mümkün olduğunca tamamen bitirilir.
