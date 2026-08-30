# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 30 Ağustos 2026 — Başlangıç Limanı 8×8 teknik hattı PASS. Bölüm içi tema V4 de teknik olarak Android16 runtime PASS aldı, ancak kullanıcı tarafından görsel olarak **reddedildi**. Yeni bağlayıcı karar: kullanıcının 30 Ağustos'ta yeniden gönderdiği **Bölüm 10 / Başlangıç Limanı gece limanı ekranı**, tema için “ilham” değil **mümkün olan en yüksek sadakatle birebir hedef**tir. ChatGPT/Codex kendi çizimini, ek dekorunu veya sanat yorumunu katmayacaktır. PR #158 hâlâ OPEN/DRAFT; theme PR yok; Ready/merge yok.

> Teknik doğrulukta tek kanonik kaynak canlı `ZMilaStudio/BilgiRotasi` deposu ve ilgili canlı servislerdir. Bu dosya canlı branch/PR/CI/pubspec doğrulamasının yerine geçmez. Eski ayrıntılı checkpointler Git geçmişi ve `docs/project-memory/archive/` altında korunur.

## Kalıcı çalışma kuralı

- Her görev başında `BILGI_ROTASI_DURUM.md`, ilgili `KARARLAR.md`, `GOREV_HAVUZU.md` ve canlı GitHub durumu okunur.
- Canlı target branch, `pubspec.yaml`, son commit ve PR durumu doğrulanmadan kod değişikliği yapılmaz.
- `main` güncel yayın kaynağı varsayılmaz.
- Doğrudan main/release'e yazılmaz; branch → test → commit → push → PR → inceleme → merge sırası korunur.
- Kritik merge yalnız Levent'in açık onayıyla yapılır.
- Build PASS tek başına kanıt değildir; log + diff + workflow + Git geçmişi + runtime birlikte değerlendirilir.
- `assets/questions.json` kontrolsüz değiştirilmez.
- Doğrulanmayan bilgi `DOĞRULANACAK` olarak işaretlenir.

## Canlı release hattı

- Repo: `ZMilaStudio/BilgiRotasi`
- Kanonik release branch: `release/final-closed-test-aab-1.68.8`
- Release HEAD: `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`
- Sürüm: `1.68.19+109`
- Paket: `com.leventua.bilgirotasi`

## MASTER ART / rota sözleşmesi

`MASTER ART RASTER → TRANSPARENT INTERACTION HITBOXES → MINIMUM LOCAL STATE OVERRIDES`

- Issue #109 `Photo 1.jpg` Başlangıç Limanı **rota ekranı** için tek bağlayıcı görsel kaynak.
- MASTER ART / route geometry bölüm içi 8×8 tema çalışmasında değiştirilmez.
- BoardMap / 67 node / 3B tahta kapsamı kapalıdır.

## Başlangıç Limanı 8×8 — AKTİF ÜRÜN STANDARDI

29 Ağustos 2026 bağlayıcı kullanıcı kararı:
- Bölüm 1–10 **8 satır × 8 sütun**.
- Önceki 6×10 superseded; tarihsel teknik kanıt olarak korunur.
- 10 bölüm / 30 yıldız / toplam 80 target+bonus kelime.
- Her canonical kelime 8 düz yönde exactly-one physical occurrence taşır.
- Intended/opposite gesture aynı canonical kelimeye döner.
- B5/B10 yön çeşitliliği korunur.
- B8 bonus `HIZ` + `SKOR`; B9 bonus `ROKET`; B10 hedef `YOL`, bonus `HAZİNE`; `AY` ve `ROTA` geri dönmez.
- B5/B10 süreleri soft challenge: 60 / 120 saniye.

Git/CI:
- Branch `feat/kelime-avi-8x8-content-v1-20260829`.
- Ürün commit `052ea7da775db0b58a5ce0c6731a04f251879008`.
- Final run `33251736068`: **SUCCESS**.
- Focused Word Hunt **37/37**, full Flutter **442/442 PASS**.
- Android16 B1/B5/B8/B10 **64/64** görünürlük.
- B5 soft-time + gerçek ANKARA + ters BAŞKENT swipe PASS.
- Crash/ANR/FATAL taraması temiz.
- Artifact `9714700778`, digest `sha256:dfbca264c2f67bb3549a0e336b075c9238f1a0638962dc69392ea8715b9a2092`.

PR #158:
- Başlık: `WIP feat(kelime-avi): Başlangıç Limanı 8x8 production content`.
- Base: `release/final-closed-test-aab-1.68.8`.
- Head: `feat/kelime-avi-8x8-content-v1-20260829`.
- Durum: **OPEN / DRAFT / merged=false / mergeable=true**.
- Kullanıcı kabulünden önce Ready yok; merge yalnız ayrıca açık onayla.

Eski PR #156 6×10 tarihsel hatta OPEN/DRAFT kalır; otomatik kapatılmaz.

## Başlangıç Limanı bölüm içi tema — V4 TEKNİK PASS, GÖRSEL RED

Clean theme branch:
`feat/kelime-avi-baslangic-limani-theme-clean-v1-20260829`

Görev başındaki canlı HEAD:
`02951f63445ee064e7856c6b36873052ae2f54df`

Önceki tema uygulaması:
- `lib/word_hunt/baslangic_limani_theme_screen.dart` mevcut production ekranı wrapper olarak sarıyordu.
- `word_hunt_gameplay_flow.dart` varsayılan level açılışını temalı wrapper'a yönlendiriyordu.
- `word_hunt_screens.dart`, path/scoring, canonical 8×8 content, `lib/main.dart`, MASTER ART, AdMob/Firebase/signing/version korunmuştu.

### V4 teknik runtime kanıtı

- Trigger SHA `4671a3989155b801c9da6b7d0ec7a7e1a545d465`.
- Run `33278797412`: **SUCCESS**.
- Job `99170289209`.
- Formatter: 4 dosya / 0 changed.
- `dart analyze lib/word_hunt`: No issues.
- Tema widget + flow testleri: **2/2 PASS**.
- B1/B10 debug APK build/install/launch PASS.
- Android16 API36 / 1080×1920 / 420 dpi PASS.
- B1/B10 screenshot + UI XML + logcat üretildi.
- Crash/ANR/FATAL/am_crash eşleşmesi yok.
- Artifact `9722440135`.
- Digest `sha256:bf91d7591b4348b3268983f9938a9042631729b8ad7a126c27e6ba35504f3a70`.

**Önemli:** Bu teknik PASS görsel kabul değildir. Kullanıcı V4 screenshotlarını seçilen temadan çok uzak buldu ve reddetti.

## 30 Ağustos bağlayıcı tema hedefi — REFERANSIN KENDİSİ

Kullanıcının 30 Ağustos 2026'da sohbet içinde yeniden gönderdiği **Bölüm 10 / Başlangıç Limanı** ekranı artık bölüm içi tema için tek bağlayıcı görsel hedeftir.

Bu kararın anlamı:
- Referans “ilham”, “yaklaşık yön”, “benzer tema” veya serbest yorum alanı değildir.
- **Mümkün olan en yüksek sadakatle aynı görünüm hedeflenecektir.**
- ChatGPT/Codex kendi sanat yönünü, ek çizimini, alternatif dekorunu, farklı stilini veya “iyileştirme” yorumunu katmayacaktır.
- Önceki hafif overlay yaklaşımı nihai görsel yön olarak **superseded** edilmiştir.
- `a91236c9f734e9495e67de46ab6e078d429d681e` yalnız tarihsel teknik tema checkpointidir; nihai görsel değildir.

Referansta korunacak görsel kimlik:
- koyu, premium gece limanı arka planı,
- sağ üstte belirgin deniz feneri,
- sola doğru yayılan sıcak amber fener ışık huzmesi,
- karanlık deniz ve sıcak ışık yansımaları,
- sol tarafta liman feneri/lantern ve rıhtım detayları,
- koyu lacivert metal yüzey + altın/bronze trim/rivet sayaç panelleri,
- aynı metal dilde target/bonus chipleri,
- koyu lacivert beveled harf hücreleri + altın kenarlar,
- selection/found durumunda güçlü sıcak amber glow,
- alt bölümde lacivert-altın bilgi paneli + çapa/pusula motifleri,
- serif/premium metin dili ve sıcak krem-altın tipografi hissi.

### İçerik/oynanış sınırı

Referans görselin örnek harf ve kelime dizilimi **oyun verisi değildir**.

Production'da:
- canonical gerçek grid **8×8** kalır,
- 80 kelime sözleşmesi korunur,
- path/scoring/gesture motoru değişmez,
- B5/B10 soft-time korunur,
- MASTER ART rota ekranı değişmez,
- `lib/main.dart` ayrı kapsam kalır,
- BoardMap/67 node, AdMob/Firebase/signing/version açılmaz.

## Aktif sonraki görev — REFERANS-BİREBİR TEMA REWORK

Aynı clean theme branch üzerinde yapılacak:

1. Referans kompozisyonu production ekran boyutuna taşımak.
2. Gece limanı / fener / amber beam / su yansıması / liman detaylarını referans konum-oranlarına yaklaştırmak.
3. Sayaç panelleri, target/bonus chipleri, harf tile'ları ve alt bilgi panelini referanstaki metal lacivert-altın stile geçirmek.
4. Selection/found amber glow'u referanstaki yoğunluk ve hissine yaklaştırmak.
5. Gerçek 8×8 layout ve gesture hitboxlarını bozmamak.
6. Formatter/analyze/tema+regresyon testlerini geçirmek.
7. Android16 B1/B10 build/install/launch + screenshot/UI XML/logcat almak.
8. Yeni screenshotı referansla **yan yana** insan gözüyle değerlendirmek.
9. Levent açıkça görsel PASS vermeden theme PR Ready/merge yapmamak.

## Korunan alanlar

Açık kapsam olmadan değiştirilmez:
- `lib/main.dart`
- `pubspec.yaml`
- `assets/questions.json`
- MASTER ART / route geometry
- `word_hunt_path.dart`
- `word_hunt_models.dart`
- canonical 8×8 content
- BoardMap / 67 node / 3B tahta
- AdMob / Firebase / Android release-signing
- package/version

## Kalan açık kapılar

1. Referans-birebir yeni tema uygulaması.
2. Android16 yeni B1/B10 görsel/runtime kanıtı.
3. Levent açık görsel PASS.
4. B5/B10 gerçek insan süre dengesi playtesti.
5. PR #158 için ayrıca Ready kararı.
6. Merge yalnız Levent'in ayrıca açık onayıyla.
7. Production `lib/main.dart` ana navigasyon entegrasyonu ayrı branch/PR kapsamı.

## Bu checkpointte yapılan dokümantasyon

30 Ağustos 2026 kullanıcı kararı sonrası:
- `KARARLAR.md`: referansın birebir hedef olduğu yeni bağlayıcı karar eklendi.
- `BILGI_ROTASI_DURUM.md`: V4 görsel red + exact-reference rework durumu işlendi.
- `GOREV_HAVUZU.md`: 0Y tema görevi referans-birebir yeniden uygulama olarak açıldı.
- `ACIK_SORULAR_VE_DOGRULAMALAR.md`: yeni acceptance/görsel doğrulama kapıları yazıldı.
- Bu `GENEL_PROJE_OZETI.md`: yeni kanonik devir özeti olarak güncellendi.

Bu doküman güncellemesi ürün kodu değiştirmez; yeni Actions run veya PR/Ready/merge kararı değildir.
