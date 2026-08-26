# Başlangıç Limanı — Production Pilot Durumu

Bu dosya, tarihsel asset-first WIP işaretinin final production durumuna güncellenmiş halidir.

- Teknik temel: PR #110 progression / interaction çekirdeği korunur.
- Bağlayıcı görsel kaynak: Issue #109 `Photo 1.jpg` MASTER ART.
- Kabul edilen production mimarisi: **MASTER ART raster görünür taban + şeffaf interaction hitbox + yalnız gerçek runtime state için minimum lokal override**.
- Premium görünür sahne procedural olarak yeniden çizilmez.
- Gerçek `X / 30`, level 1–10 yıldızları ve locked/open görünümü runtime progression ile senkron tutulur.
- Başlangıç Limanı özel kuralı: level 7 tamamlanınca bonus 8 ve normal 9 birlikte açılır; bonus 8, node 9 için zorunlu geçiş kapısı değildir.
- Node 10, node 9 tamamlanmadan kilitli ve callback üretmeyen durumda kalır.
- Production `WordHuntReferenceRouteScreen` kabul edilen MASTER ART tabanını kullanır.
- MASTER ART üzerindeki rota/node/plaque/control sanatı ikinci kez görünür katman olarak çizilmez.
- Ayrı raster node/control dosyaları yalnız gerekli lokal override, fallback veya test sözleşmesi için repoda bulunabilir; production görünür sahnenin tamamını yeniden kompoze etmez.
- Görsel kullanıcı kabulü ve mimari kabul PASS'tır.
- PR #132 final merge'i için ayrıca güncel exact-head doğrulaması ve Levent'in açık merge onayı gerekir.

`render entegrasyonu devam ediyor` şeklindeki eski WIP durumu artık geçerli değildir.
