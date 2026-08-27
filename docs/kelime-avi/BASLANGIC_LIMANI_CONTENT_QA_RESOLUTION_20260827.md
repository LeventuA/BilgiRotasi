# Kelime Avı — Başlangıç Limanı İçerik QA Çözümü

**Tarih:** 27 Ağustos 2026

Bu belge `BASLANGIC_LIMANI_LEVEL_2_10_CONTENT_QA.md` içindeki iki somut içerik bulgusunun kullanıcı kararıyla çözüldüğünü kaydeder.

## Bağlayıcı yeni kural

- Hedef (`targetWords`) ve bonus (`bonusWords`) kelimeler **en az 3 harf** olmalıdır.
- `WordHuntDefinitionValidator` bu kuralı otomatik olarak reddetme seviyesinde uygular.
- İki harfli kelimeler yeni içerikte target/bonus olarak kullanılamaz.

## Bölüm 8 — TOP duplicate çözümü

Önceki grid:
- `SPORCU`
- `TOPLAR`
- `KOŞUCU`
- `TAKIMI`
- `HIZLAR`
- `OYUNCU`

`TOP` iki fiziksel hatta oluşuyordu. İkinci tesadüfi çapraz hattı kırmak için yalnız filler satırı değiştirildi:

- `TAKIMI` → `RAKİBİ`

Yeni durumda:
- `SPOR`: tek hat `(0,0) → (0,3)`
- `TOP`: tek hat `(1,0) → (1,2)`
- `KOŞU`: tek hat `(2,0) → (2,3)`

Bu değişiklik Bölüm 8'in spor temasını korur ve intended kelimeleri değiştirmez.

## Bölüm 9 — AY kaldırıldı

`AY` iki harfli olduğu için bonus kelime olmaktan çıkarıldı.

Yeni bonus:
- `ROKET`

Mevcut `ROKETS` satırında:
- `ROKET`: tek hat `(4,0) → (4,4)`

Target kelimeler değişmedi:
- `MARS`
- `UZAY`

## Regression kilidi

`test/word_hunt_starter_content_test.dart` artık şunları doğrular:
- bütün target/bonus kelimeler >= 3 harf,
- validator 2 harfli target/bonusu reddeder,
- Bölüm 8 `TOP` occurrence sayısı tam 1,
- Bölüm 9 bonusu `ROKET`, `AY` değil,
- `ROKET` occurrence sayısı tam 1.

## Kapsam

Bu çözüm Bölüm 1 production gameplay implementasyonunu bloklamaz. Diğer Bölüm 2–10 zorluk/8-yön çeşitliliği konusu ayrı content pass olarak açık kalır.
