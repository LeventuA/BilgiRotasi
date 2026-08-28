# Kelime Avı — Başlangıç Limanı Bölüm 2–10 Production İçeriği

**Tarih:** 28 Ağustos 2026

**Başlangıç release:** `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`

Bu belge `WordHuntStarterContent.baslangicLimani` içindeki Bölüm 2–10 production grid, kelime ve intended-path sözleşmesidir.

`BASLANGIC_LIMANI_LEVEL_2_10_CONTENT_QA.md` tarihsel ilk QA kaydı olarak korunur. O belgedeki Bölüm 8 `TOP` duplicate ve Bölüm 9 `AY` uyarıları daha önce giderilmiştir; production content bakımından bu belge eski QA'yı supersede eder.

## Bağlayıcı ortak kurallar

- Her grid 6×6'dır.
- Target ve bonus kelimeler en az üç harftir.
- Her target ve bonus düz sekiz yönde tam bir fiziksel occurrence taşır.
- Intended path ileri gesture ile canonical kelimeyi üretir.
- Aynı fiziksel path'in opposite gesture'ı `WordHuntPathEngine` tarafından aynı canonical kelime olarak kabul edilir.
- Bölüm 1 içeriği değiştirilmemiştir.
- Bölüm 8 `TOP` occurrence değeri 1'dir.
- Bölüm 9 `ROKET` occurrence değeri 1'dir; `AY` target/bonus değildir.
- Bölüm 10'da kullanıcı onayıyla `ROTA` yerine `YOL` canonical target olmuştur.
- Bölüm 5 ve Bölüm 10 süre/yıldız eşikleri Android playtest'e kadar provisional olarak aynen korunur.

Koordinatlar 0-based'dir ve iki uç dahildir.

## Bölüm 2 — İlk dikey yön

```text
DDLELA
EUEEİM
NSGAML
İIAIAG
ZİAANİ
İGEMİD
```

| Tür | Kelime | Intended path | Yön | Occurrence |
|---|---|---|---|---:|
| Target | DENİZ | `(0,0) → (4,0)` | aşağı `(1,0)` | 1 |
| Target | GEMİ | `(5,1) → (5,4)` | sağ `(0,1)` | 1 |
| Bonus | LİMAN | `(0,4) → (4,4)` | aşağı `(1,0)` | 1 |

Zorluk amacı: Bölüm 1'den sonra ilk dikey çözümü öğretirken kolay bir yatay hedefi korumak.

## Bölüm 3 — Reverse ve bottom-to-top

```text
GRİÖNY
FPATİK
LIDOSD
USNÖBB
KİCIRG
OCADSİ
```

| Tür | Kelime | Intended path | Yön | Occurrence |
|---|---|---|---|---:|
| Target | KİTAP | `(1,5) → (1,1)` | sol/reverse `(0,-1)` | 1 |
| Target | OKUL | `(5,0) → (2,0)` | yukarı `(-1,0)` | 1 |
| Bonus | SINIF | `(5,4) → (1,0)` | yukarı-sol çapraz `(-1,-1)` | 1 |

Zorluk amacı: reverse, aşağıdan yukarı ve çapraz seçimleri kontrollü biçimde tanıtmak.

## Bölüm 4 — İlk belirgin diagonal

```text
HCHYNF
SIYSÇZ
BDZUYA
EOÇLHM
BAENIA
KERÜSN
```

| Tür | Kelime | Intended path | Yön | Occurrence |
|---|---|---|---|---:|
| Target | HIZLI | `(0,0) → (4,4)` | aşağı-sağ çapraz `(1,1)` | 1 |
| Target | ZAMAN | `(1,5) → (5,5)` | aşağı `(1,0)` | 1 |
| Bonus | SÜRE | `(5,4) → (5,1)` | sol/reverse `(0,-1)` | 1 |

Zorluk amacı: belirgin bir target diagonalini dikey ve reverse bonusla birleştirmek.

## Bölüm 5 — Meydan Okuma

```text
AAKİİŞ
ENÜERE
YEKEÜH
KLNAEİ
EATŞRR
ELAKAA
```

| Tür | Kelime | Intended path | Yön | Occurrence |
|---|---|---|---|---:|
| Target | ANKARA | `(0,0) → (5,5)` | aşağı-sağ çapraz `(1,1)` | 1 |
| Target | ŞEHİR | `(0,5) → (4,5)` | aşağı `(1,0)` | 1 |
| Bonus | KALE | `(5,3) → (5,0)` | sol/reverse `(0,-1)` | 1 |

Zorluk amacı: eski satır-başı kalıbını kaldırıp horizontal/vertical/diagonal bilgisini challenge hissiyle sınamak. `60s / 50s / 35s` eşikleri değiştirilmemiştir ve Android playtest'e kadar provisionaldır.

## Bölüm 6 — Orta zorluk

```text
İNAMRO
TOPÇLŞ
İKNAEA
ŞÇĞKŞĞ
AOYOKA
DEHHNÇ
```

| Tür | Kelime | Intended path | Yön | Occurrence |
|---|---|---|---|---:|
| Target | DOĞA | `(5,0) → (2,3)` | yukarı-sağ çapraz `(-1,1)` | 1 |
| Target | ORMAN | `(0,5) → (0,1)` | sol/reverse `(0,-1)` | 1 |
| Bonus | AĞAÇ | `(2,5) → (5,5)` | aşağı `(1,0)` | 1 |

Zorluk amacı: diagonal, reverse ve vertical yolları orta seviyede karıştırmak.

## Bölüm 7 — Artan zorluk

```text
ELLABP
NEEPNK
PDOKEA
VNIÇAP
ERİKLV
AÇPADĞ
```

| Tür | Kelime | Intended path | Yön | Occurrence |
|---|---|---|---|---:|
| Target | ARI | `(5,0) → (3,2)` | yukarı-sağ çapraz `(-1,1)` | 1 |
| Target | ÇİÇEK | `(5,1) → (1,5)` | yukarı-sağ çapraz `(-1,1)` | 1 |
| Bonus | BAL | `(0,4) → (0,2)` | sol/reverse `(0,-1)` | 1 |

Zorluk amacı: iki farklı uzunluktaki diagonal target ve reverse bonusla Bölüm 6'nın üzerine çıkmak.

## Bölüm 8 — Bonus Durak

```text
SAAAIA
KPZKHR
YAOUAA
ILORİP
ZAUTKO
IUŞOKT
```

| Tür | Kelime | Intended path | Yön | Occurrence |
|---|---|---|---|---:|
| Target | SPOR | `(0,0) → (3,3)` | aşağı-sağ çapraz `(1,1)` | 1 |
| Target | TOP | `(5,5) → (3,5)` | yukarı/reverse `(-1,0)` | 1 |
| Bonus | KOŞU | `(5,4) → (5,1)` | sol/reverse `(0,-1)` | 1 |

Zorluk amacı: Bonus Durak'ta kısa, eğlenceli ve mixed yönler sunmak. Eski `TOP` duplicate uyarısı tarihsel kalmıştır; production gridde `TOP = 1` doğrulanır.

## Bölüm 9 — İleri seviye mixed directions

```text
NRIZDN
NSONÜR
YYRKGE
AÖEAEY
ZÜÜÜMT
UZEGÜL
```

| Tür | Kelime | Intended path | Yön | Occurrence |
|---|---|---|---|---:|
| Target | MARS | `(4,4) → (1,1)` | yukarı-sol çapraz/reverse `(-1,-1)` | 1 |
| Target | UZAY | `(5,0) → (2,0)` | yukarı/reverse `(-1,0)` | 1 |
| Bonus | ROKET | `(0,1) → (4,5)` | aşağı-sağ çapraz `(1,1)` | 1 |

Zorluk amacı: ileri seviye diagonal ve reverse yolları birleştirmek. Eski iki harfli `AY` uyarısı tarihsel kalmıştır; production canonical bonus yalnız `ROKET`tir.

## Bölüm 10 — Rota Finali

Kullanıcı kararı: 6×6 içinde dört eski kelimeyle yatay, dikey, çapraz ve reverse çeşitliliğinin aynı anda kurulamadığı deterministik aramayla doğrulandığı için target `ROTA`, 28 Ağustos 2026'da `YOL` ile değiştirilmiştir.

Canonical target listesi: `PUSULA`, `YOL`, `BİLGİ`

Canonical bonus: `YILDIZ`

```text
PUSULA
KİYABT
EEOİİN
YILDIZ
AGHAİE
İKKERE
```

| Tür | Kelime | Intended path | Yön | Occurrence |
|---|---|---|---|---:|
| Target | PUSULA | `(0,0) → (0,5)` | sağ `(0,1)` | 1 |
| Target | YOL | `(1,2) → (3,2)` | aşağı `(1,0)` | 1 |
| Target | BİLGİ | `(1,4) → (5,0)` | aşağı-sol çapraz/reverse `(1,-1)` | 1 |
| Bonus | YILDIZ | `(3,0) → (3,5)` | sağ `(0,1)` | 1 |

Zorluk amacı: finalde yatay, dikey, diagonal ve reverse bilgisini birleştirmek; eski ilk dört satır-prefix düzenine dönmemek. `120s / 100s / 75s` eşikleri değiştirilmemiştir ve Android playtest'e kadar provisionaldır.

## Otomatik doğrulama

`test/word_hunt_starter_content_test.dart` her Bölüm 2–10 için şunları doğrular:

1. Exact 6×6 grid.
2. Canonical target/bonus listesi.
3. Her kelime için tam bir fiziksel occurrence.
4. Occurrence'ın bu belgede kayıtlı intended koordinatlarla eşleşmesi.
5. Forward path'in target/bonus türü ve canonical kelimesi.
6. Opposite gesture'ın aynı canonical kelimeye dönmesi.
7. Bilgi kartı referanslarının varlığı ve kelime bütünlüğü.
8. Bölüm 1 canonical snapshotının değişmemesi.

## Kapsam sınırı

Bu pass yalnız content, content testi ve production QA belgesidir. Gameplay navigation, UI, route, progression, MASTER ART, reklam, Firebase, Android/release yapılandırması, paket ve sürüm değiştirilmemiştir.
