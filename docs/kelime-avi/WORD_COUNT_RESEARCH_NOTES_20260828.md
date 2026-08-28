# Kelime Avı — kelime sayısı araştırma karar notu

Tarih: 2026-08-28

Bu dosya yalnız araştırma kararını kaydeder; product content değişikliği yapmaz.

## İlk rota için önerilen 6x6 kelime yoğunluğu

- Bölüm 1: 2 target + 1 bonus = 3 (tutorial)
- Bölüm 2: 3 target + 1 bonus = 4
- Bölüm 3: 3 target + 1 bonus = 4
- Bölüm 4: 4 target + 1 bonus = 5
- Bölüm 5: 4 target + 1 bonus = 5
- Bölüm 6: 4 target + 1 bonus = 5
- Bölüm 7: 4 target + 1 bonus = 5
- Bölüm 8: 4 target + 2 bonus = 6
- Bölüm 9: 5 target + 1 bonus = 6
- Bölüm 10: 5 target + 1 bonus = 6

## Tasarım ilkeleri

- İlk rota boyunca 6x6 korunur; telefon okunabilirliği için grid büyütülmez.
- Zorluk; kelime sayısı, kesişmeler, yön çeşitliliği, reverse/diagonal ve daha az belirgin başlangıç noktalarıyla artırılır.
- Her target/bonus fiziksel olarak exact-one occurrence taşımalıdır.
- Kelimelerin kontrollü biçimde kesişmesi teşvik edilir; tüm kelimelerin ayrı satırlarda yüzmesi engellenir.
- Bonus opsiyoneldir ve ana hedeflerden sonra da aranabilmelidir.
