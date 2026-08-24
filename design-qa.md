# Issue #109 - Başlangıç Limanı node 9 Design QA

## Kaynak ve kanıt

- Görsel kaynak: Issue #109 `Photo 1.jpg`, `720x1280`.
- Kullanıcı kararı: yalnız node 9 locked görünümden normal/open teal-cyan
  görünüme geçer; diğer sahne değişmez.
- Gerçek uygulama kanıtı: Android 16 / API 36, `1080x1920`.
- Exact product head: `320f15486e1767e66698ce75a443787df09ad75c`.
- Workflow run/job: `32767726614` / `97560895182`.
- Artifact: `BilgiRotasi-KelimeAvi-PixelProof-320f15486e1767e66698ce75a443787df09ad75c`,
  ID `9535342463`.
- Artifact digest:
  `sha256:64abb81573916b2b2a68aef356c806d88e07911eb05b5c03b0cae4091cfd51e0`.
- Uygulama screenshot'ı: artifact içindeki `ANDROID16.png`.
- Tam karşılaştırma: artifact içindeki `SIDE_BY_SIDE.png`.
- Piksel farkı: artifact içindeki `DIFF.png`.
- Durum: 9 için görsel open override; progression/interaction mantığı değişmedi.

## Karşılaştırma

Referans ve Android screenshot aynı `1080x1920` sahne uzayında karşılaştırıldı.
Bağlayıcı raster aynı `1.5` uniform transform ile korunur. Beklenen tek büyük
fark node 9 alanındadır: kilit ikonu ve gri medalyon yerine mevcut normal
`node_normal.webp` teal-cyan ailesi ve ortalanmış `9` görünür. Yıldız satırı,
rota kontrol noktaları ve çevre pikselleri yerinde kalır.

| Yüzey | Sonuç |
| --- | --- |
| Tipografi | Node 9 rakamı normal duraklarla uyumlu açık serif görünümde ve ortalı. |
| Spacing/geometri | Node 9 merkezi `254.88, 1338.24`; rota ve yıldız satırı taşınmadı. |
| Renk/token | Gri locked medalyon teal-cyan normal durak ailesiyle örtüldü. |
| Asset kalitesi | Yeni sanat üretilmedi; mevcut normal node asset'i kullanıldı. |
| İçerik | Kilit ikonu yok, `9` okunur; diğer metin ve sahne değişmedi. |
| Android runtime | İki gerekli asset yüklendi; APK asset byte-paritesi PASS. |

## Bulgular

- P0: yok.
- P1: yok.
- P2: yok.
- Levent'in gerçek Android screenshot üzerinden açık görsel kabulü henüz yok;
  PR Draft kalmalıdır.

final result: blocked
