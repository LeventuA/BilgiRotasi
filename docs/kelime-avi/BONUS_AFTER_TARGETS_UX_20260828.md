# Kelime Avı — hedefler tamamlandıktan sonra bonus UX kararı

Tarih: 28 Ağustos 2026

## Onaylanan davranış

- Ana targetların tamamlanması yıldız hesabı için süreyi ve hata sayısını dondurur.
- Grid, `Bölümü Tamamla` butonuna basılana kadar etkileşimli kalır.
- Oyuncu targetlar bittikten sonra kalan bonus kelimeleri bulabilir.
- Bonus kelimeler completion için zorunlu değildir.
- Bonus arama aşamasındaki yanlış seçimler kazanılmış yıldızları düşürmez.
- Sonuç penceresi yalnız `Bölümü Tamamla` ile açılır.
- B5/B10 `timeLimitSeconds` hard fail değildir; yıldız eşikleri soft challenge olarak kullanılır. Süre aşımı oyunu zorla kapatmaz.

## Kapsam

Bu belge content-density PR #156 üzerine stacked gameplay UX fix sözleşmesidir.
