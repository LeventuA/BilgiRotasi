# Kelime Avı — hedefler tamamlandıktan sonra bonus UX kararı

Tarih: 2026-08-28

## Sorun

Production ekranda ana hedeflerin sonuncusu bulunduğunda `_completionElapsedSeconds` atanıyor ve timer duruyor. Aynı alan pointer girişini de kilitlediği için oyuncu ana hedefleri bitirdikten sonra henüz bulmadığı bonus kelimeyi seçemiyor.

## Beklenen davranış

- Ana hedeflerin tamamlanması skoru ve süreyi dondurur.
- Sonuç penceresi kendiliğinden açılmaz.
- Grid, `Bölümü Tamamla` butonuna basılana kadar etkileşimli kalır.
- Oyuncu bu arada kalan bonus kelimeleri bulabilir.
- Bonus kelimeler bölüm completion için zorunlu değildir.
- Sonuç ekranı yalnız `Bölümü Tamamla` butonuyla açılır.
- Bonus arama sırasında yapılan seçimlerin ana hedeflerde dondurulmuş süreyi değiştirmemesi gerekir.

## Kapsam

Bu karar yalnız production gameplay UX davranışını düzeltir. İçerik sayısı/difficulty ayrı content-pass kararıdır.
