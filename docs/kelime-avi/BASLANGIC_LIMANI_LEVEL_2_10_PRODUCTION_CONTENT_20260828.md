# Kelime Avı — Başlangıç Limanı Bölüm 2–10 Production İçeriği

**Tarih:** 28 Ağustos 2026

**Başlangıç release:** `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`

Bu belge `WordHuntStarterContent.baslangicLimani` içindeki Bölüm 2–10 production grid, kelime yoğunluğu ve intended-path sözleşmesidir.

`BASLANGIC_LIMANI_LEVEL_2_10_CONTENT_QA.md` tarihsel ilk QA kaydı olarak korunur. Bu belge güncel production içeriği supersede eder.

## Bağlayıcı ortak kurallar

- Grid boyutu 6×6 kalır; mobil dokunma alanı küçültülmez.
- Bölüm 1 tutorial olarak `2 target + 1 bonus = 3` kelimeyle aynen korunur.
- Yoğunluk: B2=4, B3=4, B4=5, B5=5, B6=5, B7=5, B8=6, B9=6, B10=6.
- Her target/bonus en az 3 harftir.
- Her target/bonus düz sekiz yönde tam **1 fiziksel occurrence** taşır.
- Intended path ileri gesture ile canonical kelimeyi üretir; opposite gesture aynı canonical kelime olarak kabul edilir.
- Zorluk grid hücrelerini küçültmekten değil; kelime sayısı, kesişim, yön ve reverse çeşitliliğinden gelir.
- B8 `TOP` occurrence=1.
- B9 `ROKET` occurrence=1; `AY` target/bonus değildir.
- B10'da `ROTA` geri dönmez; canonical target `YOL` korunur.
- B5/B10 zaman eşikleri bu content PR'da değiştirilmez. Gameplay UX pass'i bunları hard timeout yerine soft challenge olarak netleştirecektir.

Koordinatlar 0-based'dir ve iki uç dahildir.

## Bölüm 2 — İlk dikey yön

```text
SFDÖLL
AGEMİD
EDNAMY
ÜYİBAA
IĞZCNK
DALGAL
```

| Tür | Kelime | Intended path | Yön | Occurrence |
|---|---|---|---|---:|
| Target | DENİZ | `(0,2) → (4,2)` | aşağı `(1,0)` | 1 |
| Target | GEMİ | `(1,1) → (1,4)` | sağ `(0,1)` | 1 |
| Target | DALGA | `(5,0) → (5,4)` | sağ `(0,1)` | 1 |
| Bonus | LİMAN | `(0,4) → (4,4)` | aşağı `(1,0)` | 1 |

Zorluk amacı: Tutorial sonrası ilk dikey çözümü öğretirken yatay hedefi korur; toplam 4 kelime.

## Bölüm 3 — Reverse ve bottom-to-top

```text
SFÖLAD
FPATİK
EIDAYL
ÜYNBAU
IĞCIKK
LDERSO
```

| Tür | Kelime | Intended path | Yön | Occurrence |
|---|---|---|---|---:|
| Target | KİTAP | `(1,5) → (1,1)` | sol/reverse `(0,-1)` | 1 |
| Target | OKUL | `(5,5) → (2,5)` | yukarı/reverse `(-1,0)` | 1 |
| Target | DERS | `(5,1) → (5,4)` | sağ `(0,1)` | 1 |
| Bonus | SINIF | `(5,4) → (1,0)` | yukarı-sol çapraz/reverse `(-1,-1)` | 1 |

Zorluk amacı: Reverse, yukarı ve çapraz seçimi kontrollü biçimde tanıtır; toplam 4 kelime.

## Bölüm 4 — İlk belirgin diagonal

```text
HEDEFK
ZISFUÖ
ALZBAD
MEALDA
AÇYÜIY
NERÜSB
```

| Tür | Kelime | Intended path | Yön | Occurrence |
|---|---|---|---|---:|
| Target | HIZLI | `(0,0) → (4,4)` | aşağı-sağ çapraz `(1,1)` | 1 |
| Target | ZAMAN | `(1,0) → (5,0)` | aşağı `(1,0)` | 1 |
| Target | HEDEF | `(0,0) → (0,4)` | sağ `(0,1)` | 1 |
| Target | ÇABUK | `(4,1) → (0,5)` | yukarı-sağ çapraz `(-1,1)` | 1 |
| Bonus | SÜRE | `(5,4) → (5,1)` | sol/reverse `(0,-1)` | 1 |

Zorluk amacı: Dört target ile ilk gerçek yoğunluk artışı; diagonal/vertical/horizontal/reverse karışımı; toplam 5 kelime.

## Bölüm 5 — Meydan Okuma

```text
ATAİŞM
RNEÖEE
NEKLHL
YKSAİA
KVPARK
IİKNIA
```

| Tür | Kelime | Intended path | Yön | Occurrence |
|---|---|---|---|---:|
| Target | ANKARA | `(0,0) → (5,5)` | aşağı-sağ çapraz `(1,1)` | 1 |
| Target | ŞEHİR | `(0,4) → (4,4)` | aşağı `(1,0)` | 1 |
| Target | KENT | `(3,1) → (0,1)` | yukarı/reverse `(-1,0)` | 1 |
| Target | PARK | `(4,2) → (4,5)` | sağ `(0,1)` | 1 |
| Bonus | KALE | `(4,5) → (1,5)` | yukarı/reverse `(-1,0)` | 1 |

Zorluk amacı: Challenge bölümünde horizontal/vertical/diagonal ailelerini birlikte kullanır; toplam 5 kelime. `60/50/35` eşikleri gameplay UX pass'inde soft-challenge olarak ele alınacaktır.

## Bölüm 6 — Orta zorluk

```text
NAMROK
YSFÖAA
LEADĞR
EDŞOAP
AYDİÇO
ÜYBALT
```

| Tür | Kelime | Intended path | Yön | Occurrence |
|---|---|---|---|---:|
| Target | DOĞA | `(4,2) → (1,5)` | yukarı-sağ çapraz `(-1,1)` | 1 |
| Target | ORMAN | `(0,4) → (0,0)` | sol/reverse `(0,-1)` | 1 |
| Target | TOPRAK | `(5,5) → (0,5)` | yukarı/reverse `(-1,0)` | 1 |
| Target | YEŞİL | `(1,0) → (5,4)` | aşağı-sağ çapraz `(1,1)` | 1 |
| Bonus | AĞAÇ | `(1,4) → (4,4)` | aşağı `(1,0)` | 1 |

Zorluk amacı: Uzun ve kısa kelimeleri diagonal/reverse/vertical karıştırır; toplam 5 kelime.

## Bölüm 7 — Artan zorluk

```text
SFÖLAK
DPETEK
EDAÇYO
ÜYİBIV
AÇIRĞA
CLABKN
```

| Tür | Kelime | Intended path | Yön | Occurrence |
|---|---|---|---|---:|
| Target | ARI | `(5,2) → (3,4)` | yukarı-sağ çapraz `(-1,1)` | 1 |
| Target | ÇİÇEK | `(4,1) → (0,5)` | yukarı-sağ çapraz `(-1,1)` | 1 |
| Target | PETEK | `(1,1) → (1,5)` | sağ `(0,1)` | 1 |
| Target | KOVAN | `(1,5) → (5,5)` | aşağı `(1,0)` | 1 |
| Bonus | BAL | `(5,3) → (5,1)` | sol/reverse `(0,-1)` | 1 |

Zorluk amacı: İki diagonal target, yatay ve dikey target ile reverse bonus; toplam 5 kelime.

## Bölüm 8 — Bonus Durak

```text
SFGÖLZ
AODEDI
LSAYPH
ÜYPBOA
NUYOTI
UŞOKRĞ
```

| Tür | Kelime | Intended path | Yön | Occurrence |
|---|---|---|---|---:|
| Target | SPOR | `(2,1) → (5,4)` | aşağı-sağ çapraz `(1,1)` | 1 |
| Target | TOP | `(4,4) → (2,4)` | yukarı/reverse `(-1,0)` | 1 |
| Target | OYUN | `(4,3) → (4,0)` | sol/reverse `(0,-1)` | 1 |
| Target | HIZ | `(2,5) → (0,5)` | yukarı/reverse `(-1,0)` | 1 |
| Bonus | KOŞU | `(5,3) → (5,0)` | sol/reverse `(0,-1)` | 1 |
| Bonus | GOL | `(0,2) → (2,0)` | aşağı-sol çapraz `(1,-1)` | 1 |

Zorluk amacı: İlk 6 kelimelik bölüm; iki bonus ile daha dolu ama eğlenceli mixed-direction yapı.

## Bölüm 9 — İleri seviye

```text
YRSSFÖ
ALORAD
ZYEKAD
UANYEM
ŞENÜGT
ÜYUYDU
```

| Tür | Kelime | Intended path | Yön | Occurrence |
|---|---|---|---|---:|
| Target | MARS | `(3,5) → (0,2)` | yukarı-sol çapraz/reverse `(-1,-1)` | 1 |
| Target | UZAY | `(3,0) → (0,0)` | yukarı/reverse `(-1,0)` | 1 |
| Target | GÜNEŞ | `(4,4) → (4,0)` | sol/reverse `(0,-1)` | 1 |
| Target | DÜNYA | `(5,4) → (1,0)` | yukarı-sol çapraz/reverse `(-1,-1)` | 1 |
| Target | UYDU | `(5,2) → (5,5)` | sağ `(0,1)` | 1 |
| Bonus | ROKET | `(0,1) → (4,5)` | aşağı-sağ çapraz `(1,1)` | 1 |

Zorluk amacı: Beş target + ROKET; reverse/diagonal/vertical/horizontal karışımı; toplam 6 kelime. `AY` geri dönmez.

## Bölüm 10 — Rota Finali

Canonical target listesi: `PUSULA`, `YOL`, `BİLGİ`, `YÖN`, `HEDEF`

Canonical bonus: `YILDIZ`

```text
BFMAEN
GİEŞSL
YILDIZ
OÖGGET
LYNLİH
ALUSUP
```

| Tür | Kelime | Intended path | Yön | Occurrence |
|---|---|---|---|---:|
| Target | PUSULA | `(5,5) → (5,0)` | sol/reverse `(0,-1)` | 1 |
| Target | YOL | `(2,0) → (4,0)` | aşağı `(1,0)` | 1 |
| Target | BİLGİ | `(0,0) → (4,4)` | aşağı-sağ çapraz `(1,1)` | 1 |
| Target | YÖN | `(2,0) → (4,2)` | aşağı-sağ çapraz `(1,1)` | 1 |
| Target | HEDEF | `(4,5) → (0,1)` | yukarı-sol çapraz/reverse `(-1,-1)` | 1 |
| Bonus | YILDIZ | `(2,0) → (2,5)` | sağ `(0,1)` | 1 |

Zorluk amacı: Beş target + bonus; yatay/dikey/diagonal/reverse bilgilerini finalde birleştirir. `ROTA` geri dönmez.

## Otomatik doğrulama

`test/word_hunt_starter_content_test.dart`:

1. 6×6 gridleri,
2. Bölüm 1 canonical snapshotını,
3. 3→6 kelime yoğunluk eğrisini,
4. her target/bonus için exact 1 physical occurrence'ı,
5. intended koordinat ve yönleri,
6. gerçek `WordHuntPathEngine` forward/opposite gesture davranışını,
7. bilgi kartı bütünlüğünü,
8. B8 `TOP=1`, B9 `ROKET=1`, `AY` yok ve B10 `ROTA` yok regresyonlarını

kilitler.

## Kapsam sınırı

Bu PR yalnız content, content testleri ve production QA belgesidir. Bonus-after-targets UX düzeltmesi ve soft-challenge timer semantiği ayrı gameplay fix branch/PR'da uygulanacaktır. MASTER ART, route geometry, progression, AdMob/Firebase, Android config, package/version ve `assets/questions.json` bu pass'te değişmez.
