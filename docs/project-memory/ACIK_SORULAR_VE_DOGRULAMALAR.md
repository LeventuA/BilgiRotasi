# Bilgi Rotası - Açık Sorular ve Canlı Doğrulamalar

> 30 Ağustos 2026 aktif kesimidir. Eski tam kayıtlar Git geçmişi ve `docs/project-memory/archive/` altında korunur.

## Kelime Avı Başlangıç Limanı tema — V4 TEKNİK PASS / GÖRSEL RED / REFERANS-BİREBİR REWORK

Canlı branch:
`feat/kelime-avi-baslangic-limani-theme-clean-v1-20260829`

V4 teknik kanıt:
- Run `33278797412`: **SUCCESS**.
- Job `99170289209`.
- B1/B10 build/install/launch + screenshot + UI XML + logcat PASS.
- API36 / 1080×1920 / 420 dpi PASS.
- Crash/ANR/FATAL/am_crash temiz.
- Artifact `9722440135`, digest `sha256:bf91d7591b4348b3268983f9938a9042631729b8ad7a126c27e6ba35504f3a70`.

Ancak V4 gerçek ekranları kullanıcı tarafından **seçilen referansla arasında uçurum olduğu** gerekçesiyle görsel olarak reddedildi.

### Bağlayıcı referans kararı

30 Ağustos 2026'da kullanıcının sohbet içinde yeniden gönderdiği **Bölüm 10 / Başlangıç Limanı** gece-limanı ekranı, bölüm içi tema için birebir hedeftir.

- “Yakın”, “benzer”, “ilham alınmış” kabul edilmez.
- ChatGPT/Codex kendi çizimini, ek dekorunu, sanat yorumunu veya alternatif stilini katmaz.
- Referanstaki gece limanı + sağ üst deniz feneri + amber ışık huzmesi + su yansıması + sol liman feneri + lacivert-altın metal paneller/chipler + lacivert-altın tile + amber selection/found glow + çapa/pusula alt paneli aynı görsel dilde hedeflenir.
- Gerçek oyun 8×8 kalır; referanstaki örnek grid/harfler canonical veriyi değiştirmez.

**DOĞRULANACAK — KALANLAR:**
1. Referans görselin production asset/material olarak repoda hangi güvenli biçimde tutulacağı netleştirilecek mi, yoksa yalnız canlı kullanıcı referansı + kodla yeniden üretim mi kullanılacak?
2. Yeni uygulama gerçek Android16 B1/B10 ekranlarında referansa yeterince sadık mı?
3. Arka plan/fener/su/lantern kompozisyonu referanstaki konum ve oranlara yeterince yakın mı?
4. Sayaç/chip/tile/alt panel şekil, trim, gölge ve amber parıltı dili referansa yeterince yakın mı?
5. Tema görsel sadakati artırılırken 8×8 grid okunabilirliği ve gesture hitboxları korunuyor mu?
6. Yeni screenshot/UI XML/logcat ve crash/ANR taraması temiz mi?
7. Levent açıkça görsel PASS veriyor mu?
8. Görsel PASS sonrası clean theme Draft PR açılacak mı?
9. Theme PR ve PR #158 için Ready/merge ayrı açık onayla mı ilerleyecek? Evet; otomatik ilerleme yok.

---

## Kelime Avı Başlangıç Limanı 8×8 — TEKNİK PASS / KULLANICI KABULÜ AÇIK

- Branch: `feat/kelime-avi-8x8-content-v1-20260829`.
- Ürün commit: `052ea7da775db0b58a5ce0c6731a04f251879008`.
- Draft PR #158: **OPEN / DRAFT / merged=false / mergeable=true**.
- Base release: `release/final-closed-test-aab-1.68.8` / `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`.
- Sürüm: `1.68.19+109`.
- Final run `33251736068`: SUCCESS.
- 10 adet 8×8 grid / 80 target+bonus; static/path/reverse sözleşmesi PASS.
- Focused Word Hunt **37/37**, full Flutter **442/442 PASS**.
- Android16 B1/B5/B8/B10 64/64; soft-time ve gerçek ANKARA/ters BAŞKENT swipe PASS.

**DOĞRULANACAK:**
1. Nihai referans-birebir tema dahil 8×8 görünüm kullanıcı tarafından kabul ediliyor mu?
2. B5 60 saniye ve B10 120 saniye challenge süreleri gerçek insan playtestinde dengeli mi?
3. Kullanıcı kabulünden sonra PR #158 Ready yapılacak mı?
4. PR #158 merge'i için Levent ayrıca açık merge onayı verecek mi?
5. Eski PR #156 ne zaman/kim tarafından kapatılacak? Otomatik kapatılmayacak.
6. Production `lib/main.dart` ana navigasyon entegrasyonu için ayrı kapsam/onay verilecek mi?

---

## Issue #109 / MASTER ART production — KAPANDI

- Issue #109 `Photo 1.jpg` tek bağlayıcı rota MASTER ART.
- MASTER ART raster + şeffaf hitbox mimari kabulü PASS.

## Kelime Avı production ana navigasyon entegrasyonu — AÇIK / AYRI KAPSAM

- `lib/main.dart` 8×8 starter-content/tema dönüşümünde değiştirilmedi.
- Gerçek uygulama girişine bağlama ayrı branch/PR ve açık onay ister.

## Diğer korunan açık başlıklar

- 1.68.19+109 Play/rewarded canlı kabul maddeleri.
- İki cihaz Canlı Düello uçtan uca fiziksel kabulü.
- Soru geri bildirimleri: gerçek düzeltme merge edilmeden Sheet kapatılmaz.
- 3B tahta: BoardMap/67 node korunur; rozet eşlemesi çözülmeden ilerlenmez.
- Mağaza/tanıtım varlıklarının canlı Play Console durumu.
