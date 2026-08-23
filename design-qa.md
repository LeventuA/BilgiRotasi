# Issue #109 - Başlangıç Limanı Design QA

> **Düzeltme kaydı (24 Ağustos 2026):** Önceki `passed` kaydı Levent'in gerçek
> Android 16 incelemesinde geçersiz kılındı. Bu rapor, eski screenshot'ları
> referans almayan dört yeni exact-head Android turundan sonra yeniden
> hazırlanmıştır. Teknik PASS tek başına görsel kabul sayılmamıştır.

## Kaynak ve kanıt

- Tek bağlayıcı tasarım kaynağı: Issue #109'a eklenen `Photo 1.jpg` (`720x1280`).
- Gerçek uygulama kanıtı: Android 16 / API 36, `1080x1920` screenshot.
- Exact product head: `5523cafcd11d30f7c9ecceb7193d0de84fd6b07a`.
- Workflow run/job: `32667921483` / `97264162349`.
- Artifact: `BilgiRotasi-KelimeAvi-VisualProof-5523cafcd11d30f7c9ecceb7193d0de84fd6b07a`, ID `9500663308`.
- Artifact digest: `sha256:8ccb91a19a858ee0f35b1ae9e7ffc4d0695f8803366b9ac923d56e31712ea08e`.
- Android screenshot: `WORD_HUNT_ROUTE_MAP_ANDROID16_TOP.png`.
- Android screenshot SHA-256: `2542ec29f6bab3630f5e5d0b20e053248133a8a28a864bf6137d53940966148f`.
- Yan yana son karşılaştırma SHA-256: `78870dd5f36ec5c9a77c46b9730776ccadc02c9cfd9f7b626d97eee4066c8a60`.

## Karşılaştırma sonucu

Referans `1080x1920` boyutuna normalize edilip exact-head Android screenshot ile
aynı `2160x1920` karşılaştırma tuvaline yerleştirildi. Yeni kanıt turlarında
bulunan panel taşması, node/medalyon ölçeği, özel ikon kalitesi ve özel etiket
kırılmaları giderildi. Son turda background composition, node size, medallion
visual quality, number size, stars, route glow, special plaques, final crown,
upper panel ve bottom controls ayrı ayrı yeniden incelendi.

| Alan | Sonuç | Kanıt |
| --- | --- | --- |
| 1-10 rota geometrisi | PASS | Normalize merkezler referans koordinatlarıyla widget testinde kilitli. |
| Üst başlık ve bilgi paneli | PASS | Başlık/panel hiyerarşisi, serif tipografi, altın ince süsler ve dinamik ilerleme korunuyor. |
| Medalyonlar ve yıldızlar | PASS | Normal, meydan okuma, bonus, kilit ve final durumları ayrı; final taçı ve kilit durumu birlikte görünür. |
| Rota renkleri | PASS | Cyan, amber, mor, kesikli kilit ve sıcak altın final katmanları mevcut. |
| Özel etiketler | PASS | `MEYDAN OKUMA`, `BONUS DURAK`, `ROTA FİNALİ` tam ve kırpılmadan okunuyor. |
| Alt kontroller ve dış çerçeve | PASS | Pusula/kitap kontrolleri ile iki katmanlı ince çerçeve referans hiyerarşisinde. |
| Davranış | PASS | Progression/unlock motoru değişmedi; kilitli final altın hedef olarak görünür fakat etkileşim vermez. |
| Android runtime | PASS | Asset runtime load PASS; app-specific crash/ANR/FATAL/process-death eşleşmesi `0`. |

Dinamik kanıt state'i gerçek `21 / 30` ilerlemeyi gösterir; referanstaki statik
`12 / 30` değeri sahte veriyle kopyalanmadı. Arka plan bağlayıcı referansın
kompozisyonuna göre yeniden üretilmiş temiz bir sahne asset'idir; yazı, rota,
node, yıldız, kilit, buton, panel veya özel durak etiketi asset içine gömülmedi.
Kaynak ve paketlenmiş asset birebir eşittir (`1080x2340`, `693174` byte,
SHA-256 `dc81e99f752e878e09ce8f165ea7e4b49943e2270f64ded4d05b27ee837b0ce4`).

## Açık bulgular

P0: yok.

P1: yok.

P2: yok.

Levent'in artifact screenshot'ı üzerinden nihai ürün kabulü ve merge kararı
ayrı, açık bir kullanıcı kapısıdır; PR bu nedenle Draft kalır.

final result: passed
