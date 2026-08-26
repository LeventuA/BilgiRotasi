# Issue #109 - Başlangıç Limanı node 9 Design QA

## Kaynak ve kanıt

- Görsel kaynak: Issue #109 `Photo 1.jpg`, `720x1280`.
- Kullanıcı kararı: yalnız node 9 locked görünümden normal/open teal-cyan
  görünüme geçer; diğer sahne değişmez.
- Gerçek uygulama kanıtı: Android 16 / API 36, `1080x1920`.
- Exact product head: `29153b127fee8706b7a8b93b45e703847ac99f93`.
- Workflow run/job: `32773565540` / `97579309057`.
- Artifact: `BilgiRotasi-KelimeAvi-PixelProof-29153b127fee8706b7a8b93b45e703847ac99f93`,
  ID `9537442972`.
- Artifact digest:
  `sha256:e20628296464cf70bcdae08b72cfdf776291a9372766a7f544816e2d3eddeef2`.
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
- Levent, gerçek Android screenshot üzerinden görseli açıkça kabul etti.
- Bu kabul merge/Ready onayı değildir; PR Draft kalmalıdır.

final result: passed
