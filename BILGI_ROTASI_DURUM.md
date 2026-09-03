# Bilgi Rotası – Proje Durumu

**Son güncelleme:** 3 Eylül 2026 — Kelime Avı production ana navigasyon entegrasyonu PR #169 exact Android 16/full-suite kanıtlarıyla doğrulandı ve Levent’in ayrı `Devam et` onayıyla **Ready for Review** yapıldı. PR #169 merge edilmedi; Play yükleme/yayınlama yapılmadı.

## Canlı Sürüm / Release Hattı

- Repo: `ZMilaStudio/BilgiRotasi`.
- Repo içi aktif ürün sürümü: **1.68.19+109**.
- Paket: `com.leventua.bilgirotasi`.
- Canonical release branch: `release/final-closed-test-aab-1.68.8`.
- Canonical release HEAD: **`189864c92a605e7bb960460300714049c730ea39`**.
- PR #158: **CLOSED / MERGED**; merge commit `189864c92a605e7bb960460300714049c730ea39`.
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
- PR #166 tarihsel geliştirme/QA hattıdır; merge edilmeyecek.

## Production Ana Navigasyon Entegrasyonu — PR #169 READY

- Branch: `feat/kelime-avi-production-navigation-20260903`.
- PR #169: **OPEN / READY FOR REVIEW / mergeable=true / merged=false**.
- Base: `release/final-closed-test-aab-1.68.8` @ `189864c92a605e7bb960460300714049c730ea39`.
- Exact Ready HEAD: **`ffa1454ba8fb47da21ca6caa50b0a5495e0149c1`**.
- Final ürün diff’i yalnız 4 dosya / 259 ekleme / 0 silme:
  - `lib/main.dart`: production entry importu (+1),
  - `lib/main_navigation.dart`: Oyna menüsü Kelime Avı kartı (+21),
  - `lib/word_hunt/word_hunt_production_entry_screen.dart`: production route/persistence glue,
  - `test/word_hunt_menu_entry_test.dart`: menü entry sözleşmesi.
- `assets/questions.json`, BoardMap/67 node, canonical 8×8 içerik, Firebase rules/model, AdMob/signing/Android config ve package/version değişmedi.
- Oyna menüsü → `WordHuntProductionEntryScreen` → MASTER ART `WordHuntReferenceRouteScreen` → canonical `WordHuntLevelProductionScreen` akışı bağlandı.
- Progress `WordHuntProgressCodec` ile Firebase UID / guest scope’una göre cihazda saklanır; başka hesap verisi fail-closed reddedilir.

### PR #169 doğrulama kanıtları

- Focused production run `33754274810`: **SUCCESS**; 62 focused test PASS.
- Minimum-diff run `33754621892`: **SUCCESS**; formatter churn temizlendi.
- Full-suite / release APK / Android16 run `33754851284`: **SUCCESS**; job `100646698982` SUCCESS; analyze + tüm testler, imza, release APK, manifest/paket ve Android16 cold-start/AdMob gate PASS.
- Kelime Avı Android16 görsel run `33754851205`: **SUCCESS**; job `100646698474` SUCCESS.
- Görsel hatta `dart analyze lib/word_hunt`: **No issues found**; focused suite **126/126 PASS**.
- MASTER ART kaynak/paket SHA+byte eşitliği: `SOURCE_EQUALS_PACKAGED=YES count=2`.
- Android API 36 gerçek ekran yakalama, activity/process/crash/ANR kontrolleri PASS.
- Visual artifact `9893332600`; digest `sha256:2d0fa14825f59a735a9606be809025b2f69d4daa09121bb065bb622d25e30001`.
- Açık review/review thread blocker yok.
- Ready kapısı Levent’in 3 Eylül 2026 `Devam et` onayıyla geçildi.

## Korunan Alanlar

- `assets/questions.json` kontrolsüz değiştirilmez.
- Canonical 8×8 / 64 hücre sözleşmesi değiştirilmez.
- BoardMap / 67 node değiştirilmez.
- Firebase / AdMob / release signing kapsam dışıdır.
- package name / version değişmedi.
- PR #169 merge edilene kadar canonical release HEAD `189864c9...` olarak kalır.

## Kalan Gerçek Kapılar

1. PR #169 → canonical release merge — **AÇIK / ayrıca Levent’in ayrı ve açık onayı gerekli**.
2. `REFERENCE_FONT` exact kaynak — **DOĞRULANACAK / DEFERRED**.
3. Play yükleme/yayınlama — **AÇIK / ayrıca Levent’in açık onayı gerekli**.

**Durum:** 8×8 LOCKED / V5 ASSET PASS / FOUND PASS / ERROR PASS / COMPACT COMPLETION PASS / B5 SÜRE PASS / SWIPE ANDROID16 PASS / PR #167+#163+#162+#161+#158 MERGED / PR #169 READY + ANDROID16/FULL-SUITE PASS / CANONICAL RELEASE HEAD `189864c9...` / PLAY YAYINI YOK.
