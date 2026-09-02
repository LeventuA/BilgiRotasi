# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 3 Eylül 2026 — V6 found/error/compact completion kullanıcı PASS. B5 yeni 8×8 tuning adayı `32 sn` ile 60 sn hedefini karşıladı. UI 2 hata kaydetti fakat Levent bunların bilinçli yanlış seçim değil parmak taşması/fazla temas kaynaklı false-positive olduğunu bildirdi; gerçek niyet hatası 0. Swipe input toleransı açık ürün hatasıdır. Bölüm başına ayrı branch/Action/APK/insan testi terk edildi; üretim/test birimi 10 bölümlük paket olarak kararlaştırıldı. PR #163 OPEN/DRAFT; Ready/merge yok.

> Teknik doğrulukta tek kanonik kaynak canlı `ZMilaStudio/BilgiRotasi` deposu ve ilgili canlı servislerdir. Bu dosya canlı branch/PR/CI/pubspec doğrulamasının yerine geçmez. Eski ayrıntılı checkpointler Git geçmişi ve `docs/project-memory/archive/` altında korunur.

## Kalıcı çalışma kuralı

- Yeni sohbet başında önce bu dosya okunur.
- Ardından `BILGI_ROTASI_DURUM.md`, `docs/project-memory/KARARLAR.md`, `GOREV_HAVUZU.md` ve gerektiğinde `ACIK_SORULAR_VE_DOGRULAMALAR.md` okunur.
- Her görev öncesi canlı hedef branch, `pubspec.yaml`, son commit, PR ve CI yeniden doğrulanır.
- `main` güncel yayın kaynağı varsayılmaz.
- Doğrudan main/release'e rastgele yazılmaz; branch → test → commit → push → PR → inceleme → merge sırası korunur.
- Kritik merge yalnız Levent'in açık onayıyla yapılır.
- Build PASS tek başına çalışma kanıtı değildir; log + workflow + diff + Git geçmişi + gerçek runtime kanıtı birlikte incelenir.
- Görsel acceptance yalnız gerçek/raw Android runtime ile verilir; ImageGen/mockup/QA selector acceptance kanıtı değildir.
- `assets/questions.json` kontrolsüz değiştirilmez; ilgisiz değişiklikler silinmez.
- Doğrulanmayan bilgi `DOĞRULANACAK` yazılır.

## Canlı release hattı

- Repo: `ZMilaStudio/BilgiRotasi`
- Kanonik release branch: `release/final-closed-test-aab-1.68.8`
- Release HEAD: `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`
- Sürüm: **1.68.19+109**
- Paket: `com.leventua.bilgirotasi`
- `lib/main.dart` production ana navigasyon entegrasyonu Kelime Avı V6 görsel işinden ayrı scope/onaydır.

## Başlangıç Limanı rota mimarisi

- Issue #109 `Photo 1.jpg`, rota ekranı için bağlayıcı kaynak olarak kabul edildi.
- Production rota tabanı: MASTER ART raster + transparent interaction hitbox + minimum local state override.
- MASTER ART: `assets/word_hunt/baslangic_limani_master_art_visual_proof.jpg`.
- Progression: level 7 tamamlanınca 8 ve normal 9 açılır; bonus 8, 9 için gate değildir; 10, node 9 tamamlanmadan locked/no-callback.
- BoardMap / 67 node sözleşmesi kontrolsüz değiştirilmez.

## Kelime Avı canonical gameplay sözleşmesi

- Başlangıç Limanı: 10 bölüm / 30 yıldız.
- Canonical gameplay grid: **8×8 / 64 hücre — LOCKED**.
- Önceki 6×10 ürün geometrisi superseded; yalnız tarihsel checkpoint olarak korunur.
- 10 bölüm toplam target+bonus kelime eğrisi korunur: B1 5+1, B2 5+1, B3 6+1, B4 6+1, B5 7+1, B6 7+1, B7 8+1, B8 7+2, B9 9+1, B10 9+1.
- Her target/bonus 8 düz yönde exactly one physical occurrence taşımalıdır; intended ve opposite gesture aynı canonical kelimeye dönmelidir.
- B8 bonusları `HIZ` + `SKOR`; B9 bonus `ROKET`; B10 `YOL` hedef + `HAZİNE` bonus.
- B5 60 sn ve B10 120 sn süreleri **soft challenge**; hard-fail değildir.
- Engine/path/scoring/timer/progression/content görsel tema uğruna değiştirilmez.

## 8×8 teknik temel — PASS

- 8×8 branch: `feat/kelime-avi-8x8-content-v1-20260829`; Draft PR #158 tarihsel/temel 8×8 hattıdır.
- Temiz 8×8 product commit: `052ea7da775db0b58a5ce0c6731a04f251879008`.
- Final gate run `33251736068`: SUCCESS.
- `dart analyze`, focused tests, full Flutter test, diff/scope gate ve Android 16 64/64 render doğrulamaları PASS.
- B1/B5/B8/B10 64/64 hücre görünür; B5 ANKARA ve ters BAŞKENT gerçek gesture PASS; crash/ANR/FATAL yok.
- Eski 6×10 teknik checkpointler Git geçmişinde korunur ve yeni 8×8 acceptance yerine kullanılmaz.

## V5/V6 gameplay görsel mimarisi

31 Ağustos 2026’dan itibaren gameplay görsel dili gece limanı, koyu lacivert + bronz/altın premium referanstır.

- Flattened referans screenshot tüm ekran olarak production'a gömülmez.
- Production: approved V5 raster reference asset pack + dinamik Flutter text/state + canonical 8×8 engine.
- Locked production asset pack; background, idle/found cell, status/word/bonus/instruction plakaları ve back/search/mistake/timer ikonlarından oluşur.
- Grid/kelime/hücre state’i asset içine bake edilmez.
- QA selector veya image-edit görüntüsü kullanıcı kabul kanıtı değildir.

## V6 found-state — KULLANICI PASS

- Güncel ürün hattının parent görsel PR’ı: #162 — OPEN/DRAFT.
- Found-path ürün branch/PR: `fix/kelime-avi-v6-found-path-connector-product-20260901` / Draft PR #163.
- Kabul edilen görünüm: found hücrelerin kendi kutu/formu korunur; yalnız komşu found hücrelerin görünür aralıkları sıcak altın/turuncu edge-fuse ile doğal biçimde birleşir. Uzun merkez bar/kapsül görünümü kullanılmaz.
- Exact edge-fuse tested commit: `4dddf00178ef9f14b8edb3fc706114be72f477a4`.
- Exact tested blob: `f43deaad5328f6263f9479de1738cc1f4ac465e0`.
- Android 16 run `33486609120`: SUCCESS; focused **138/138 PASS**; gerçek B10 `YOL 0/9 → 1/9`; semantic + edge-fuse pixel gates PASS.
- Raw Android B10 initial ve `YOL / 1/9` ekranları Levent tarafından **PASS** edildi.

## V6 error-state — KULLANICI PASS

- Başarı altınından ayrışması için error-state bordo/kırmızı olarak kabul edildi.
- Fill `0xB35A1F2B`; border `0xFFFF6B57`; 280 ms transient süre değişmedi.
- Clean tested commit `0d845fc75bbe7b92c3d778ccfbcbde2761fa56de`.
- Android 16 run `33524578623`: SUCCESS; invalid F-Z-C gesture `0 hata → 1 hata`; **138/138 PASS**.
- Raw Android error-state kullanıcı görsel kabulü: **PASS**.

## Reference font denetimi

- Gameplay runtime `fontFamily: 'serif'` kullanır.
- `pubspec.yaml` içinde custom `fonts:` tanımı yok; tracked `.ttf/.otf/.woff/.woff2` kaynağı bulunmadı.
- KAYNAK_DEFTERI/teknik docs/README/Issue #109 exact font ailesi vermiyor.
- `REFERENCE_FONT = DOĞRULANACAK / SOURCE LIMITATION`; spekülatif font değişikliği yapılmadı.
- Audit run `33530045077`: SUCCESS.

## Completion davranışı ve sonuç popup’ı — KULLANICI PASS

2 Eylül 2026’de kullanıcının gerçek oynayışında eski completion akışının güvenilir biçimde yeniden açılmadığı görüldü ve eski Material/mavi popup görsel olarak reddedildi.

Yeni kabul edilen sözleşme:
- Ana targetlar tamam, bonus eksik → otomatik popup **yok**; bonus aranabilir, manuel `Bölümü Tamamla` yolu kalır.
- Tüm target+bonus tamam → completion popup **otomatik** açılır.
- Fresh/replay oturumunda popup yeniden otomatik açılabilir; session koruması yeni oturumda resetlenir.
- Sonuç UI Başlangıç Limanı temasına ait koyu lacivert, bronz/altın, krem serif premium paneldir; standart Material dialog/mor button kullanılmaz.

İlk premium popup kullanıcı tarafından güzel bulundu fakat büyük/kaba görüldü. Kullanıcının onayıyla kompaktlaştırıldı:
- `maxWidth: 300`
- padding `18,15,18,15`
- result button height `44`
- yıldız/ikon/boşluklar orantılı küçültüldü.

Exact compact kanıt:
- Tested product commit: `7fa81663cb93c3f9f43b5c1bb7cd8f4d11929fd8`.
- Exact tested `word_hunt_screens.dart` blob: `6ce2830a7df8eb696a9df589c91c544df7712969`.
- Static/productize run `33629855060`: SUCCESS; analyze + Word Hunt **139/139 PASS**.
- Final clean Android 16 run `33655562508`: SUCCESS.
- Android runtime: B5 target-only no-dialog PASS; B5 all-words auto-dialog PASS; B5 fresh replay auto-dialog PASS; B10 target-only no-dialog PASS; B10 all-words auto-dialog PASS; process failure scan PASS.
- Raw Android kompakt B5/B10 popup ekranları Levent tarafından **PASS** edildi.

## PR #163 exact productization — GÜNCEL

- Branch: `fix/kelime-avi-v6-found-path-connector-product-20260901`.
- PR #163: **OPEN / DRAFT / merged=false**.
- Compact completion exact tested blob, QA workflow/script taşınmadan productize edildi.
- Güncel ürün commit: `9a6fede2c4aed4fdbaa6c9ba427fa84e0ce418da` — `fix(kelime-avi): compact completion result dialog`.
- Güncel `lib/word_hunt/word_hunt_screens.dart` blob: **`6ce2830a7df8eb696a9df589c91c544df7712969`**, exact tested blob ile birebir.
- `lib/main.dart`, `assets/questions.json`, locked V5 assets, BoardMap/67 node, AdMob/Firebase/signing, package/version değiştirilmedi.
- Ready yapılmadı; merge yapılmadı.

## Gerçek insan süre-zorluk playtesti — MIXED

Levent’in gerçek oynayış kayıtları:
- **B5: 115 saniye / 2 hata / tüm 7 target + bonus ANIT.** 60 sn soft challenge → **HEDEF KARŞILANMADI**.
- **B10: 109 saniye / 4 hata / tüm 9 target + bonus HAZİNE.** 120 sn soft challenge → **HEDEF KARŞILANDI**.

Bu değerler insan playtestidir. Android QA otomasyonundaki yaklaşık 20/23 saniyelik scripted completion süreleri insan zorluk ölçümü değildir ve denge kararı için kullanılmaz.

B5 60 sn soft challenge hard-fail değildir. Kullanıcıdan ayrıca tuning/denge kararı alınmadan timer, içerik veya scoring değiştirilmez.

### B5 60 sn yeni yerleşim adayı — TEKNİK PASS

- Branch: `tune/kelime-avi-v6-b5-60s-layout-20260902`; HEAD `5ef394e784051e9b955e99fb3382f523fb8413d3`.
- Ürün değişikliği: `44ebec6b830a288df66f4fa16e2611dfa2165bae` — yalnız `lib/word_hunt/word_hunt_starter_content.dart` içindeki B5 grid harf yerleşimi.
- Korundu: 8×8/64 hücre, yedi target + bonus ANIT, 60 sn soft challenge, yıldız/hata eşikleri, tekil fiziksel yollar, yatay+dikey+çapraz yön aileleri.
- Android 16 run `33670657723`: SUCCESS; analyze PASS; aday testleri 3/3 PASS; 64 hücre render + tam raster screenshot + process-failure scan PASS.
- Artifact `9862719927`; APK SHA-256 `9a83695e1c62323a2ce61697bdb59aab16d91c8393be74c2725e40c0cea5a1c2`.
- Levent insan testi: **32 sn / UI 2 hata**; süre hedefi ve tuning adayı **PASS**. İki hata bilinçli yanlış seçim değildir; parmak taşması/fazla temas kaynaklı input false-positive olarak raporlandı.

### Swipe input toleransı — AÇIK

- Kodda pointer endpoint doğrudan hücreye çevriliyor; tek hücre tap/release `notAWord` sayılabiliyor ve doğru kelimeden bir hücre taşma bütün seçimi hataya çevirebiliyor.
- Dar çözüm: kelime olamayacak kadar kısa gesture cezasız iptal; tam bir target/bonustan yalnız bir trailing hücre taşılmışsa son hücreyi kırpıp kabul; gesture boyunca tek aktif pointer.
- Gerçek, yeterince uzun ve anlamlı yanlış düz seçim hata sayılmaya devam eder. “En yakın kelimeyi bul” türü geniş otomatik düzeltme yapılmaz.
- Değişiklik path engine yerine input-normalization katmanında uygulanmalı ve paket bazlı Android kapısından önce hedefli widget/unit testleriyle doğrulanmalıdır.

## Paket bazlı üretim ve risk bazlı test — KALICI KARAR

- Bir rota/paket 10 bölüm olarak tek içerik branch’inde üretilir; bölüm başına branch/Android Action/APK yapılmaz.
- Tüm bölümler otomatik 8×8, kelime sayısı, exactly-one occurrence, yön, reverse gesture, timer/yıldız ve render kapılarından geçer.
- İnsan denge örneklemesi varsayılan B1+B5+B10’dur; otomatik outlier varsa yalnız ilgili ek bölüm oynanır.
- Ortak gameplay görseli onaylıysa salt içerik değişikliklerinde yeniden görsel kabul istenmez.
- Android 16 tam runtime: paket tamamlanınca, engine/ortak UI değişince ve release entegrasyonu öncesinde çalışır.
- Tek paket QA APK’sı B1–B10 seçici taşır. Hata yalnız ilgili bölümde düzeltilir; bütün paket yeniden üretilmez.

## Kalan aktif sıra — YENİ SOHBET BURADAN DEVAM ETSİN

1. Her görev başında release branch, PR #163 head, `pubspec.yaml` ve PR durumunu canlı doğrula.
2. Found-state, error-state ve compact completion kullanıcı görsel acceptance kapıları **KAPALI/PASS**; yeni belirti yoksa bunları yeniden test etme.
3. Swipe false-positive input düzeltmesini hedefli testlerle uygula; ardından kabul edilen B5 tuning gridini PR #163 ürün hattına exact blob/scope kapısıyla taşı.
4. B10 120 sn human playtest kapısı **PASS**.
5. `REFERENCE_FONT` exact kaynak bulunmadığı sürece source limitation/deferred kalır; görseli spekülatif fontla değiştirme.
6. PR #161 / #162 / #163 Ready kararları ayrı kullanıcı onayı ister.
7. Merge yalnız Levent’in açık merge onayıyla yapılır.
8. Production `lib/main.dart` ana navigasyon entegrasyonu ayrı scope/branch/PR işidir.

**SON DURUM: V6 8×8 LOCKED / FOUND PASS / ERROR PASS / COMPACT COMPLETION PASS / B5 SÜRE PASS / SWIPE FALSE-POSITIVE HATA AÇIK / PAKET BAZLI QA KABUL / PR #163 DRAFT-OPEN / READY YOK / MERGE YOK.**
