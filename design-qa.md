# Kelime Avı V5 gameplay tema design QA

**Source visual truth path**

`C:/Users/User/Documents/GitHub/BilgiRotasi/.codex-remote-attachments/019faac7-96fb-7af2-a3da-b3143e690687/e350864b-a42a-43ff-a8d0-7070d3ab359a/1-Photo-1.jpg`

**Implementation screenshot path**

GitHub Actions run `33308127773`, job `99248192399`, artifact `9731244720` içindeki gerçek Android 16 gameplay görüntüleri:

- `01_B1_INITIAL.png`
- `02_B5_INITIAL.png`
- `03_B8_INITIAL.png`
- `04_B10_INITIAL.png`
- `05_B5_ANKARA_FOUND.png`
- `06_B5_BASKENT_REVERSE_FOUND.png`
- `07_B5_AFTER_65_SECONDS.png`

**Viewport and normalization**

- Hedef Android kanıtı: 1080×1920, 420 dpi.
- Widget regresyon viewport'u: 411×731 mantıksal piksel.
- Kaynak görsel: 720×1280 piksel.
- Artifact görüntülerinin tamamı 1080×1920 ve 420 dpi Android 16 render'ıdır.
- Kaynak referansın 6×10 geometrisi değil; gece limanı, lacivert-altın chrome, tipografi, plaka, hücre ve found-state görsel dili karşılaştırıldı. Ürün geometrisi canonical 8×8 kaldı.

**State**

Bölüm 1, Bölüm 5, Bölüm 8 ve Bölüm 10 initial gameplay durumları; ayrıca gerçek ADB swipe sonrası ANKARA, ters BAŞKENT ve B5 74 saniye soft-time durumu yakalandı.

**Full-view comparison evidence**

PASS. Dört initial screenshot'ta başlık, üç durum plakası, hedef/bonus etiketleri, 8×8 grid ve alt talimat plakası aynı ilk viewportta görünür. Siyah boşluk, clipping veya RenderFlex overflow gözlenmedi.

**Focused region comparison evidence**

PASS. ANKARA ve ters BAŞKENT gerçek ADB swipe sonrasında hedef etiketi ile doğru altı hücrede okunabilir sıcak-altın found state oluşturdu. B5 74 saniyede gameplay açık ve kullanılabilir kaldı.

**Findings**

- P0: yok.
- P1: yok.
- [P2] Ürün 8×8 geometrisi nedeniyle grid hücreleri referansın 6×10 hücrelerinden doğal olarak daha geniştir; bu, bağlayıcı canonical 8×8 kararının beklenen sonucudur ve görsel dil ihlali değildir.
- [P2] Teknik görsel kanıt PASS olsa da Levent'in artifact görüntülerini görerek vereceği nihai kullanıcı kabulü beklenmektedir.

**Comparison history**

- 30 Ağustos 2026: Kaynak referans açıldı ve mevcut temiz liman background asset'i incelendi. Geçerli rendered Android implementation artifact'i bulunmadığı için ilk görsel karşılaştırma bloke kaldı. Sahte PASS verilmedi.
- 30 Ağustos 2026: Run `33308127773` SUCCESS. Artifact `9731244720` içindeki yedi gerçek Android 16 render'ı referans tema ile incelendi. Teknik görsel kanıt PASS; kullanıcı kabulü PENDING.

**Implementation checklist**

- [x] Android 16 B1/B5/B8/B10 screenshot'larını üret.
- [x] 1080×1920 referans-tema karşılaştırmasını yap.
- [x] Typography, spacing, colors, image crop/quality ve copy yüzeylerini değerlendir.
- [x] B5 ANKARA ve ters BAŞKENT gerçek swipe state'lerini doğrula.
- [ ] Levent'in açık görsel kabulünü al.

**technical visual evidence: PASS**

**final user acceptance: PENDING**
