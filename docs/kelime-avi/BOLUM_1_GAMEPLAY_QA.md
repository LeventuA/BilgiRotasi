# Kelime Avı — Başlangıç Limanı Bölüm 1 Gameplay QA

**Tarih:** 27 Ağustos 2026

Bu dosya `baslangic-1` için implementation/test öncesi kesin içerik QA sözleşmesidir.

## Canonical grid

6×6, satır/sütun kullanıcı gösterimi 1 tabanlıdır:

| Satır | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| 1 | K | A | L | E | M | S |
| 2 | M | A | S | A | L | I |
| 3 | E | L | M | A | L | I |
| 4 | B | İ | L | G | İ | N |
| 5 | O | Y | U | N | C | U |
| 6 | R | O | T | A | S | I |

Kaynak: `WordHuntStarterContent.baslangicLimani`, level `baslangic-1`.

## Hedef kelimeler

### KALEM

- Tek fiziksel hat: **satır 1, sütun 1 → 5**.
- 0-based cell path: `(0,0) → (0,1) → (0,2) → (0,3) → (0,4)`.
- İleri okuma: `KALEM`.
- Ters gesture: `(0,4) → (0,3) → (0,2) → (0,1) → (0,0)`; okunan ham dize `MELAK`, engine reverse matching ile canonical `KALEM` kabul edilir.
- Grid içinde ikinci yatay/dikey/çapraz fiziksel KALEM hattı yoktur.

### MASA

- Tek fiziksel hat: **satır 2, sütun 1 → 4**.
- 0-based cell path: `(1,0) → (1,1) → (1,2) → (1,3)`.
- İleri okuma: `MASA`.
- Ters gesture: `(1,3) → (1,2) → (1,1) → (1,0)`; ham dize `ASAM`, canonical `MASA` kabul edilir.
- Grid içinde ikinci fiziksel MASA hattı yoktur.

## Bonus kelime

### ELMA

- Tek fiziksel hat: **satır 3, sütun 1 → 4**.
- 0-based cell path: `(2,0) → (2,1) → (2,2) → (2,3)`.
- İleri okuma: `ELMA`.
- Ters gesture: `(2,3) → (2,2) → (2,1) → (2,0)`; ham dize `AMLE`, canonical `ELMA` kabul edilir.
- Grid içinde ikinci fiziksel ELMA hattı yoktur.
- Bonus kelime level completion için zorunlu değildir.

## İçerik QA sonucu

- Grid: 6×6 ve dikdörtgen.
- Hedef kelimeler grid içinde çözülebilir: PASS.
- Bonus kelime grid içinde çözülebilir: PASS.
- Aynı hedefin birden fazla tesadüfi fiziksel hattı: YOK.
- Ters gesture mevcut `WordHuntPathEngine` sözleşmesiyle desteklenir.
- Bölüm 1 süreli değildir.
- Bölüm 1 öğretici olduğu için hedef/bonus kelimelerin yatay ve kolay okunur olması **bilinçli olarak korunur**.
- Dikey/çapraz öğretimi sonraki seviyelere bırakılabilir; Bölüm 1 verisi bunu kanıtlamak için yapay olarak zorlaştırılmayacaktır.

## Yıldız sözleşmesi

Mevcut level verisi:

- `twoStarMaxMistakes: 2`
- `threeStarMaxMistakes: 0`

Beklenti:
- bölüm tamamlanırsa minimum 1 yıldız,
- 0 hata → 3 yıldız,
- 1–2 hata → 2 yıldız,
- 3+ hata → 1 yıldız.

Scoring implementation bu beklentiyle test edilmelidir; test sonucu mevcut `WordHuntScoringEngine` davranışıyla uyuşmazsa veri sessizce değiştirilmez, açık bug/risk olarak raporlanır.

## Codex koordinat testleri

Widget/engine testlerinde magic gesture üretmek yerine yukarıdaki 0-based canonical cell path'ler kullanılmalıdır. En az:

- KALEM forward,
- KALEM reverse,
- MASA forward,
- ELMA forward,
- invalid/non-straight path,
- repeated KALEM

senaryoları deterministik olarak doğrulanır.
