# Kelime Avı — Başlangıç Limanı Bölüm 2–10 İçerik QA

**Tarih:** 27 Ağustos 2026

Bu QA, `WordHuntStarterContent.baslangicLimani` içindeki mevcut Bölüm 2–10 verisini production gameplay'e taşımadan önce inceler. Bu belge içerikleri kendiliğinden değiştirmez.

## Özet sonuç

- Bütün grid'ler 6×6 ve dikdörtgen: **PASS**.
- Bütün target/bonus kelimeler düz 8 yönde en az bir kez çözülebilir: **PASS**.
- Bütün `infoCardIds` mevcut bilgi kartlarına gider ve kart kelimesi ilgili level target/bonus listesinde bulunur: **PASS**.
- Türkçe karakter kullanılan kelimeler grid ile eşleşir: **PASS**.
- Bölüm 8 `TOP`: **iki farklı fiziksel çözüm hattı** var.
- Bölüm 9 bonus `AY`: **beş farklı fiziksel çözüm hattı** var.
- Bölüm 2–10 hedef/bonuslarının büyük çoğunluğu satır başından yatay olarak yerleştirilmiş; zorluk/8-yön çeşitliliği production içerik açısından henüz yeterince gelişmiyor.

Mevcut `WordHuntContentValidator` yalnız kelimenin en az bir düz 8-yön hattında bulunmasını denetler; birden fazla fiziksel occurrence kalite hatası olarak raporlanmaz. Bu nedenle aşağıdaki iki bulgu mevcut validator'dan geçebilir.

---

## Bölüm 2 — `baslangic-2`

Grid:
- `DENİZİ`
- `GEMİCİ`
- `LİMANI`
- `MAVİLİ`
- `SAHİLİ`
- `DALGAS`

Canonical çözümler, 0-based:
- target `DENİZ`: `(0,0) → (0,4)` — tek fiziksel hat.
- target `GEMİ`: `(1,0) → (1,3)` — tek fiziksel hat.
- bonus `LİMAN`: `(2,0) → (2,4)` — tek fiziksel hat.
- info card: `info-deniz` → `DENİZ` — eşleşme PASS.

**Durum:** yapısal PASS. İçerik hâlâ Bölüm 1 ile aynı yatay öğretici kalıpta.

---

## Bölüm 3 — `baslangic-3`

Grid:
- `KİTAPI`
- `OKULDA`
- `SINIFI`
- `KALEML`
- `DERSİM`
- `OYUNLA`

Canonical çözümler:
- `KİTAP`: `(0,0) → (0,4)` — tek hat.
- `OKUL`: `(1,0) → (1,3)` — tek hat.
- bonus `SINIF`: `(2,0) → (2,4)` — tek hat.
- `info-kitap` → `KİTAP` — PASS.

**Durum:** yapısal PASS; yatay kalıp devam ediyor.

---

## Bölüm 4 — `baslangic-4`

Grid:
- `HIZLIK`
- `ZAMANI`
- `SÜRELİ`
- `HEDEFL`
- `ÇABUKS`
- `OYUNCU`

Canonical çözümler:
- `HIZLI`: `(0,0) → (0,4)` — tek hat.
- `ZAMAN`: `(1,0) → (1,4)` — tek hat.
- bonus `SÜRE`: `(2,0) → (2,3)` — tek hat.

**Durum:** yapısal PASS; yine yalnız belirgin yatay yerleşim.

---

## Bölüm 5 — Meydan Okuma

Grid:
- `ANKARA`
- `ŞEHİRL`
- `KALELİ`
- `TÜRKİY`
- `ROTASI`
- `GEZİCİ`

Canonical çözümler:
- `ANKARA`: `(0,0) → (0,5)` — tek hat.
- `ŞEHİR`: `(1,0) → (1,4)` — tek hat.
- bonus `KALE`: `(2,0) → (2,3)` — tek hat.
- `info-ankara` → `ANKARA` — PASS.

Zaman:
- limit 60s,
- 2 yıldız: en fazla 50s + en fazla 1 hata,
- 3 yıldız: en fazla 35s + 0 hata.

**Durum:** yapısal PASS. Ancak 'Meydan Okuma' için kelimelerin üçü de satır başında açıkça yatay; 35/50/60 saniye eşikleri statik olarak mümkün görünse de gerçek oynanış zorluğu cihazda ölçülmeden production kalite kabulü verilmemeli.

---

## Bölüm 6 — `baslangic-6`

Grid:
- `DOĞADA`
- `ORMANI`
- `AĞAÇLI`
- `ÇİÇEKL`
- `YEŞİLL`
- `TOPRAK`

Canonical çözümler:
- `DOĞA`: `(0,0) → (0,3)` — tek hat.
- `ORMAN`: `(1,0) → (1,4)` — tek hat.
- bonus `AĞAÇ`: `(2,0) → (2,3)` — tek hat.

**Durum:** yapısal PASS; yatay kalıp devam ediyor.

---

## Bölüm 7 — `baslangic-7`

Grid:
- `ARILAR`
- `ÇİÇEKÇ`
- `BALLAR`
- `KANATL`
- `KOVANI`
- `DOĞADA`

Canonical çözümler:
- `ARI`: `(0,0) → (0,2)` — tek hat.
- `ÇİÇEK`: `(1,0) → (1,4)` — tek hat.
- bonus `BAL`: `(2,0) → (2,2)` — tek hat.
- `info-ari` → `ARI` — PASS.

**Durum:** yapısal PASS; yatay kalıp devam ediyor.

---

## Bölüm 8 — Bonus Durak

Grid:
- `SPORCU`
- `TOPLAR`
- `KOŞUCU`
- `TAKIMI`
- `HIZLAR`
- `OYUNCU`

Çözümler:
- target `SPOR`: `(0,0) → (0,3)` — tek hat.
- target `TOP`: **iki fiziksel hat**:
  1. `(1,0) → (1,2)` — yatay canonical yerleşim,
  2. `(3,0) → (2,1) → (1,2)` — yukarı-sağ çapraz tesadüfi ikinci çözüm.
- bonus `KOŞU`: `(2,0) → (2,3)` — tek hat.

**Durum:** teknik PASS / içerik kalite uyarısı.

`TOP` için iki çözüm motor açısından geçerlidir ve ikisi de aynı canonical target'a gider. Ancak Bonus Durak production'a alınmadan önce bunun **bilinçli tasarım mı, tesadüfi duplicate occurrence mı** olduğuna karar verilmelidir. Varsayılan öneri: tek intended hat kalacak şekilde grid revize edilir; bu iş Bölüm 1 implementation kapsamına alınmaz.

---

## Bölüm 9 — `baslangic-9`

Grid:
- `MARSIN`
- `UZAYLI`
- `AYLARI`
- `YILDIZ`
- `ROKETS`
- `GEZEGE`

Canonical çözümler:
- target `MARS`: `(0,0) → (0,3)` — tek hat.
- target `UZAY`: `(1,0) → (1,3)` — tek hat.
- `info-mars` → `MARS` — PASS.

Bonus `AY` **beş farklı fiziksel hatta** bulunur:
1. `(1,2) → (1,3)`
2. `(1,2) → (2,1)`
3. `(2,0) → (2,1)`
4. `(2,0) → (3,0)`
5. `(2,3) → (1,3)`

**Durum:** teknik PASS / belirgin içerik kalite uyarısı.

İki harfli `AY`, mevcut harf dağılımında çok kolay tesadüfi tekrar üretmektedir. Production Bölüm 9 öncesi bonus kelime veya grid yeniden tasarlanmalıdır. Bölüm 1 implementasyonu sırasında değiştirilmez.

---

## Bölüm 10 — Rota Finali

Grid:
- `PUSULA`
- `ROTASI`
- `BİLGİN`
- `YILDIZ`
- `HEDEFE`
- `KEŞİFL`

Canonical çözümler:
- `PUSULA`: `(0,0) → (0,5)` — tek hat.
- `ROTA`: `(1,0) → (1,3)` — tek hat.
- `BİLGİ`: `(2,0) → (2,4)` — tek hat.
- bonus `YILDIZ`: `(3,0) → (3,5)` — tek hat.
- `info-pusula` → `PUSULA` — PASS.

Zaman:
- limit 120s,
- 2 yıldız: en fazla 100s + en fazla 2 hata,
- 3 yıldız: en fazla 75s + 0 hata.

**Durum:** yapısal PASS. Ancak Rota Finali için dört kelimenin de satır başından direkt yatay okunması final zorluğunu yeterince yükseltmiyor. Production final içerik tasarımında intentional vertical/diagonal/reverse yerleşim önerilir.

---

## Genel production içerik kararı

### Şimdi değiştirilmeyecek

Bölüm 1 implementation branch'inde Bölüm 2–10 content grid'leri değiştirilmez. Böylece ilk gameplay slice'ın scope'u büyümez.

### Bölüm 1 kabulünden sonra yapılacak content pass

Bölüm 2–10 productionlaştırılmadan önce:

1. Her level için intended solution paths açıkça tanımlansın.
2. Bölüm 2–4'te kontrollü şekilde dikey/çapraz/reverse öğretimi başlasın.
3. Bölüm 5 challenge gerçek oynanış zorluğuna göre yeniden dengelensin.
4. Bölüm 8 `TOP` duplicate occurrence kararı verilsin.
5. Bölüm 9 `AY` 5-occurrence sorunu giderilsin.
6. Bölüm 10 final grid'i öğrendiğimiz yönleri birleştirecek şekilde güçlendirilsin.
7. Her revize grid `WordHuntContentValidator` + occurrence-count QA + widget/engine testlerinden geçirilsin.
8. Star/time eşikleri gerçek Android cihaz/emulator playtest ölçümüyle doğrulansın.

## QA hükmü

**Bölüm 2–10 verisi teknik olarak parse/solve edilebilir; fakat tamamı production içerik kalitesi açısından hazır kabul edilmemelidir.**

Bölüm 1 production gameplay çalışması bu bulgular nedeniyle bloklanmaz.
