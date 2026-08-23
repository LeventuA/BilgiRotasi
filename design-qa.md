# Issue #109 - Başlangıç Limanı Design QA

## Kaynak ve kanıt

- Tek bağlayıcı tasarım kaynağı: Issue #109'a eklenen `Photo 1.jpg` (`720x1280`).
- Gerçek uygulama kanıtı: Android 16 / API 36, `1080x1920` screenshot.
- Exact head: `dc9360f4a965605330b1a5ad3c145e7868760fc7`.
- Workflow run/job: `32630447439` / `97172319614`.
- Artifact: `BilgiRotasi-KelimeAvi-VisualProof-dc9360f4a965605330b1a5ad3c145e7868760fc7`, ID `9490988424`.
- Artifact digest: `sha256:d94c0b793d9aead8062f0ccd9baf1efbcce0ca5969be0e29d701dbda00464e91`.
- Android screenshot: `WORD_HUNT_ROUTE_MAP_ANDROID16_TOP.png`.
- Yan yana son karşılaştırma SHA-256: `686ca416438929740ccf4690d9924ba2b27e07c424a0cd75709c7e1c44730ffb`.

## Karşılaştırma sonucu

Referans ve exact-head Android screenshot aynı `1080x1920` karşılaştırma tuvaline yerleştirildi. Dört görsel kanıt turunda bulunan panel yüksekliği, üst düğme ölçeği, rota kalınlığı, medalyon oranı, panel süsü ve final etiket kırpılması giderildi.

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

Dinamik kanıt state'i gerçek `21 / 30` ilerlemeyi gösterir; referanstaki statik `12 / 30` değeri sahte veriyle kopyalanmadı. Arka plan, ayrı ve daha önce onaylı `assets/word_hunt/baslangic_limani_bg.jpg` asset'i olarak korunur; UI veya rota görselin içine gömülmedi.

## Açık bulgular

P0: yok.  
P1: yok.  
P2: yok.

final result: passed
