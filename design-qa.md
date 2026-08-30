# Kelime Avı V5 gameplay tema design QA

**Source visual truth path**

`C:/Users/User/Documents/GitHub/BilgiRotasi/.codex-remote-attachments/019faac7-96fb-7af2-a3da-b3143e690687/e350864b-a42a-43ff-a8d0-7070d3ab359a/1-Photo-1.jpg`

**Implementation screenshot path**

Yok. Yerel Android SDK/emülatör bulunmuyor; uygulama içi browser yakalama aracı da kullanılabilir bir browser bulamadı. Kullanıcı bu görevde yeni manuel Actions workflow dispatch'ini yasakladı.

**Viewport and normalization**

- Hedef Android kanıtı: 1080×1920, 420 dpi.
- Widget regresyon viewport'u: 411×731 mantıksal piksel.
- Kaynak görsel: 720×1280 piksel.
- Uygulama screenshot'ı bulunmadığından yoğunluk/crop normalizasyonu ve aynı-tuval karşılaştırması yapılamadı.

**State**

Bölüm 1, Bölüm 5, Bölüm 8 ve Bölüm 10 initial gameplay durumları hedeflenir. Android runtime görsel state'i henüz yakalanmadı.

**Full-view comparison evidence**

Bloke. Kaynak görsel açılıp incelendi; uygulamanın gerçek Android render'ı olmadan görsel eşleşme kararı verilmedi.

**Focused region comparison evidence**

Bloke. Başlık, üç durum plakası, hedef/bonus etiketleri, 8×8 grid, seçili/found state ve alt talimat plakası için aynı cihaz screenshot'ı yoktur.

**Findings**

- [P1] Gerçek Android 16 görsel kanıtı eksik.
  - Etki: Tipografi, spacing, crop, glow, okunabilirlik ve ilk viewport yerleşimi kaynak referansla görsel olarak kabul edilemez.
  - Düzeltme: İzin verilen mevcut Android 16 QA hattında B1/B5/B8/B10 screenshot artifact'i üret; kaynakla aynı tuvalde karşılaştır; fark varsa aynı Draft PR'da düzelt.

**Comparison history**

- 30 Ağustos 2026: Kaynak referans açıldı ve mevcut temiz liman background asset'i incelendi. Geçerli rendered Android implementation artifact'i bulunmadığı için ilk görsel karşılaştırma bloke kaldı. Sahte PASS verilmedi.

**Implementation checklist**

- [ ] Android 16 B1/B5/B8/B10 screenshot'larını üret.
- [ ] 1080×1920 aynı-tuval referans karşılaştırmasını yap.
- [ ] Typography, spacing, colors, image crop/quality ve copy yüzeylerini değerlendir.
- [ ] B5 ANKARA ve ters BAŞKENT gerçek swipe state'lerini doğrula.
- [ ] Levent'in açık görsel kabulünü al.

**final result: blocked**
