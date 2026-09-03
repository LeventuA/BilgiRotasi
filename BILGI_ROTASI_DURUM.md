# Bilgi Rotası – Proje Durumu

**Son güncelleme:** 3 Eylül 2026 — Levent ikinci Kelime Avı paketi için `Gökyüzü Adaları` tema adını ve görsel konsept C **Neşeli & Parlak** yönünü onayladı. Bu onay tema/görsel sanat yönünü kilitler; exact rota kompozisyonu, 10 bölüm adı/node sırası ve teknik görsel mimari henüz kilitli değildir. Canonical release HEAD `3557a7e4f2f2917d61ba61866c6d4c8561994667`; Play yükleme/yayınlama yapılmadı.

## Canlı Sürüm / Release Hattı

- Repo: `ZMilaStudio/BilgiRotasi`.
- Repo içi aktif ürün sürümü: **1.68.19+109**.
- Paket: `com.leventua.bilgirotasi`.
- Canonical release branch: `release/final-closed-test-aab-1.68.8`.
- Canonical release HEAD: **`3557a7e4f2f2917d61ba61866c6d4c8561994667`**.
- PR #169: **CLOSED / MERGED**; merge commit `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
- PR #168: **CLOSED / MERGED**; docs-only merge commit `3557a7e4f2f2917d61ba61866c6d4c8561994667`.
- PR #168 merge edilen HEAD: `150b8ae24395d07dc09270734ef1a8c246542a15`.
- Önceki release HEAD: `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
- `main` güncel/yayın kaynağı olarak varsayılmaz.
- Play Console’a yükleme/yayınlama yapılmadı.

## Kelime Avı — Canonical Ürün Durumu

Canonical gameplay sözleşmesi **8×8 / 64 hücre — LOCKED**.

- İlk paket: **Başlangıç Limanı**.
- 10 bölüm / 30 yıldız.
- Target+bonus eğrisi: B1 5+1, B2 5+1, B3 6+1, B4 6+1, B5 7+1, B6 7+1, B7 8+1, B8 7+2, B9 9+1, B10 9+1; toplam **80**.
- Her target/bonus 8 düz yönde exactly-one fiziksel occurrence taşır; ters gesture aynı canonical kelimeye çözülür.
- B8 bonusları `HIZ` + `SKOR`; B9 bonus `ROKET`; B10 hedef `YOL`, bonus `HAZİNE`.
- B5 60 sn, B10 120 sn soft challenge; hard-fail değildir.
- Nearest-word/autocomplete yoktur.

## Gökyüzü Adaları — Paket 2 Ürün Yönü

- İkinci 10 bölümlük rota/paket adı: **Gökyüzü Adaları — LOCKED**.
- Levent’in seçtiği bağlayıcı görsel yön: **Konsept C — Neşeli & Parlak — LOCKED**.
- Atmosfer: neşeli, renkli, pozitif, eğlenceli, çocuk dostu, hafif ve canlı.
- Görsel dil: açık gök mavisi / camgöbeği / turkuaz gökyüzü; yeşil yüzen adalar; sarı-turuncu sıcak vurgu; destekleyici pembe/mercan ayrıntılar; parlak beyaz bulutlar.
- Temel dünya öğeleri: yüzen çimenli adalar, bulut köprüleri/geçişleri, renkli balon/hava gemileri, rüzgâr yapıları, kuleler ve finalde sıcak-altın Güneş Sarayı hissi.
- Bu kabul **sanat yönü kabulüdür**; kullanıcı tarafından onaylanan konsept görsel final production MASTER ART veya raw Android kabul kanıtı değildir.
- Exact rota kompozisyonu, 10 bölüm adı ve node sıralaması ayrıca kararlaştırılacaktır.
- Başlangıç Limanı `MASTER ART raster + transparent hitbox` istisnası Gökyüzü Adaları’na otomatik taşınmaz. Raster MASTER ART / katmanlı Flutter / modüler asset yaklaşımı ayrıca teknik-görsel karar gerektirir.
- Canonical gameplay geometrisi **8×8 / 64 hücre**, 10 bölüm / 30 yıldız ve paket bazlı QA kararı korunur.
- Henüz Flutter, production asset veya APK üretimine geçilmedi.

## V5 / V6 Kabul ve Teknik Kanıtları

### V5 reference asset — PASS
- Onaylı raster reference asset paketi production’da kullanılır.
- Integration run `33379341765`: **SUCCESS**.

### Found-state — PASS
- Raw Android kullanıcı kabulü: **PASS**.
- Exact tested commit `4dddf00178ef9f14b8edb3fc706114be72f477a4`.
- Android16 run `33486609120`: **SUCCESS**.

### Error-state — PASS
- Raw Android kullanıcı kabulü: **PASS**.
- Fill `0xB35A1F2B`, border `0xFFFF6B57`, transient `280 ms`.
- Android16 run `33524578623`: **SUCCESS**.

### Compact completion/result — PASS
- Targetlar tamam, bonus eksik → otomatik popup yok; bonus aranabilir.
- Tüm target+bonus tamam → popup otomatik; fresh/replay’de tekrar açılabilir.
- Static/productize `33629855060`: SUCCESS; Word Hunt **139/139 PASS**.
- Android16 `33655562508`: SUCCESS; raw Android B5/B10 kullanıcı PASS.

### B5 denge — PASS
- İlk insan ölçümü: 115 sn / 2 hata → 60 sn hedef karşılanmadı.
- Tuning sonrası insan ölçümü: **32 sn**; süre PASS.
- Android16 tuning run `33670657723`: SUCCESS.

### Swipe false-positive — PASS
- Kelime olamayacak kadar kısa gesture cezasız iptal edilir.
- Yalnız exact target/bonus/already-found oluşturan tek trailing hücre kırpılır.
- İlk aktif pointer gesture boyunca kilitlenir.
- İki hücre taşma ve anlamlı gerçek yanlış seçim hata kalır; autocomplete yoktur.
- Ürün commit `749c678b885d6cefec428c603c55a83a4190152c`.
- Fast `33724552713`: SUCCESS.
- Android16 `33724549202`: SUCCESS; gerçek `ANKARA + 1 trailing hücre` → `0/7 → 1/7`, hata `0 → 0`.

## Canonical Release-context Kanıtı — PASS

- Exact test edilmiş ürün HEAD: `2ae95df70b452f735a8db9c5bd0d88827a2ec40a`.
- Kelime Avı Android16 visual proof run `33745646184`: **SUCCESS**; artifact `9887953917`.
- Release APK / AdMob run `33745646210`: **SUCCESS**; artifact `9889920696`.
- PR #158 merge commitinde otomatik workflow tetiklenmedi (`0` run); merge öncesi exact release-context kanıtları final teknik kanıttır.

## Merge Zinciri — TAMAMLANDI

- PR #167 — MERGED → `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.
- PR #163 — MERGED → `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`.
- PR #162 — MERGED → `929bb13177e03a0962464e21f6c174d4b3439349`.
- PR #161 — MERGED → `4aa490e7c2d5e7547dc95f9463dbbb9adeb85e5a`.
- PR #158 — MERGED → `189864c92a605e7bb960460300714049c730ea39`.
- PR #169 — MERGED → `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
- PR #168 — DOCS-ONLY MERGED → `3557a7e4f2f2917d61ba61866c6d4c8561994667`.
- PR #166 tarihsel geliştirme/QA hattıdır; merge edilmeyecek.

## Production Ana Navigasyon Entegrasyonu — PR #169 MERGED

- Branch: `feat/kelime-avi-production-navigation-20260903`.
- PR #169: **CLOSED / MERGED**.
- Exact merged HEAD: **`ffa1454ba8fb47da21ca6caa50b0a5495e0149c1`**.
- Merge commit: **`0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`**.
- Final ürün diff’i yalnız 4 dosya / 259 ekleme / 0 silme:
  - `lib/main.dart`: production entry importu (+1),
  - `lib/main_navigation.dart`: Oyna menüsü Kelime Avı kartı (+21),
  - `lib/word_hunt/word_hunt_production_entry_screen.dart`: production route/persistence glue,
  - `test/word_hunt_menu_entry_test.dart`: menü entry sözleşmesi.
- `assets/questions.json`, BoardMap/67 node, canonical 8×8 içerik, Firebase rules/model, AdMob/signing/Android config ve package/version değişmedi.
- Oyna menüsü → `WordHuntProductionEntryScreen` → MASTER ART `WordHuntReferenceRouteScreen` → canonical `WordHuntLevelProductionScreen` akışı canonical release içindedir.
- Progress `WordHuntProgressCodec` ile Firebase UID / guest scope’una göre cihazda saklanır; başka hesap verisi fail-closed reddedilir.

### PR #169 doğrulama kanıtları

- Focused production run `33754274810`: **SUCCESS**; 62 focused test PASS.
- Minimum-diff run `33754621892`: **SUCCESS**.
- Full-suite / release APK / Android16 run `33754851284`: **SUCCESS**; job `100646698982` SUCCESS.
- Kelime Avı Android16 görsel run `33754851205`: **SUCCESS**; job `100646698474` SUCCESS; focused suite **126/126 PASS**.
- MASTER ART kaynak/paket SHA+byte eşitliği: `SOURCE_EQUALS_PACKAGED=YES count=2`.
- Visual artifact `9893332600`; digest `sha256:2d0fa14825f59a735a9606be809025b2f69d4daa09121bb065bb622d25e30001`.
- Merge commitinde otomatik PR workflow’u tetiklenmedi (`0` run); exact PR HEAD’deki iki SUCCESS hattı teknik kanıt olarak korunur.

## Docs-only Checkpoint PR #168 — MERGED

- Branch: `docs/kelime-avi-v8-post-release-merge-20260903`.
- PR #168: **CLOSED / MERGED**.
- Exact merged HEAD: `150b8ae24395d07dc09270734ef1a8c246542a15`.
- Merge commit: `3557a7e4f2f2917d61ba61866c6d4c8561994667`.
- Kapsam yalnız dört belgeydi: `ACIK_SORULAR_VE_DOGRULAMALAR.md`, `BILGI_ROTASI_DURUM.md`, `GOREV_HAVUZU.md`, `docs/project-memory/GENEL_PROJE_OZETI.md`.
- Ürün kodu, sürüm, asset, Firebase/AdMob/signing, `lib/main.dart`, `assets/questions.json` ve BoardMap/67 node değişmedi.
- Merge commitinde otomatik PR workflow’u tetiklenmedi (`0` run); docs-only olduğu için yeni ürün testi gerektiren bir kod farkı oluşmadı.

## Korunan Alanlar

- `assets/questions.json` kontrolsüz değiştirilmez.
- Canonical 8×8 / 64 hücre sözleşmesi değiştirilmez.
- BoardMap / 67 node değiştirilmez.
- Firebase / AdMob / release signing kapsam dışıdır.
- package name / version değişmedi.

## Kalan Gerçek Kapılar

1. Gökyüzü Adaları **10 bölüm adı + rota/node sıralaması** — **AÇIK / kullanıcı ürün kararı gerekli**.
2. Gökyüzü Adaları **görsel teknik mimarisi** — MASTER ART raster / katmanlı Flutter / modüler asset yaklaşımı — **AÇIK / görsel konseptten ayrı karar**.
3. `REFERENCE_FONT` exact kaynak — **DOĞRULANACAK / DEFERRED**.
4. Play yükleme/yayınlama — **AÇIK / ayrıca Levent’in açık onayı gerekli**.

**Durum:** 8×8 LOCKED / BAŞLANGIÇ LİMANI RELEASE PASS / GÖKYÜZÜ ADALARI TEMA LOCKED / KONSEPT C NEŞELİ & PARLAK LOCKED / FLUTTER-ASSET-APK ÜRETİMİ BAŞLAMADI / CANONICAL RELEASE HEAD `3557a7e4...` / PLAY YAYINI YOK.
