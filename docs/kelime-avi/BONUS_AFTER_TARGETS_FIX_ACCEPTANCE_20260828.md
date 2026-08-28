# Kelime Avı — ana hedeflerden sonra bonus arama kabul sözleşmesi

Tarih: 2026-08-28

## Hata

Ana hedeflerin sonuncusu bulunduğunda production ekran `_completionElapsedSeconds` alanını doldurup aynı alan üzerinden pointer girişini de kilitliyor. Sonuç olarak tamamlanmamış bonus kelime, `Bölümü Tamamla` butonuna basılmadan önce bile artık seçilemiyor.

## Kabul edilen davranış

- Son ana hedef bulunduğu anda ana skor süresi dondurulur.
- Ana skor hata sayısı da aynı anda dondurulur; opsiyonel bonus araması kazanılmış yıldızı düşürmez.
- Sonuç penceresi otomatik açılmaz.
- Grid `Bölümü Tamamla` butonuna basılana kadar etkileşimli kalır.
- Kalan bonus kelimeler bu aralıkta bulunabilir ve sonuçta gösterilir.
- Bonus kelimeler completion için zorunlu değildir.
- `Bölümü Tamamla` sonucu yalnız kullanıcı basışıyla açar.
- Result ekranında kullanılan süre ve hata sayısı ana hedeflerin tamamlandığı andaki dondurulmuş değerlerdir.
