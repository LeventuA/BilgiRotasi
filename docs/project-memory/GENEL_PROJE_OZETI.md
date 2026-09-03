# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 3 Eylül 2026 — Kelime Avı V8 devir noktası. Canonical 8×8 Başlangıç Limanı; V5 asset, found/error/compact completion, B5 denge ve swipe toleransı PASS. PR #167, #163, #162, #161, #158 ve production ana navigasyon PR #169 merge edildi. Canonical release HEAD artık `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`. PR #169 exact full-suite/release APK/Android16/MASTER ART kanıtları PASS. Docs-only PR #168 READY+mergeable; Play yükleme/yayınlama yapılmadı. WORK V2 aktif.

> Teknik doğrulukta tek kanonik kaynak canlı `ZMilaStudio/BilgiRotasi` deposu ve ilgili canlı servislerdir. Bu dosya canlı branch/PR/CI/pubspec doğrulamasının yerine geçmez. Ayrıntılı eski üretim günlükları Git geçmişinde ve `docs/project-memory/archive/` altında korunur.

## Kalıcı Çalışma Kuralı

- Her görev başında canlı hedef branch, `pubspec.yaml`, son commit, PR ve CI yeniden doğrulanır.
- `main` güncel/yayın kaynağı varsayılmaz.
- Sıra: branch → test → commit → push → PR → inceleme → merge.
- Kritik merge/release yalnız Levent’in açık onayıyla yapılır.
- Build PASS tek başına kanıt değildir; diff, test, workflow, log, Git geçmişi ve gerçek runtime kanıtı birlikte değerlendirilir.
- Görsel kabul yalnız gerçek/raw Android runtime üzerinden verilir; ImageGen/mockup/QA selector kabul kanıtı değildir.
- `assets/questions.json` kontrolsüz değiştirilmez; ilgisiz değişiklikler silinmez.
- Codex yalnız mevcut araçlarla yapılamayan zorunlu yerel kod/test işi olduğunda kullanılır; gereksiz Codex kredisi harcanmaz.

## Canlı Release Hattı

- Repo: `ZMilaStudio/BilgiRotasi`.
- Canonical release branch: `release/final-closed-test-aab-1.68.8`.
- Canonical release HEAD: **`0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`**.
- Aktif ürün sürümü: **1.68.19+109**.
- Paket: `com.leventua.bilgirotasi`.
- PR #158 canonical gameplay paketini release’e taşıdı; merge commit `189864c92a605e7bb960460300714049c730ea39`.
- PR #169 production ana navigasyon entegrasyonunu release’e taşıdı; merge commit `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
- Play Console’a yükleme veya yayınlama yapılmadı.

## Başlangıç Limanı — Bağlayıcı Mimari

- İlk rota/paket: **Başlangıç Limanı**.
- Rota hedefi: 10 bölüm / 30 yıldız.
- Issue #109 `Photo 1.jpg` rota ekranı için bağlayıcı görsel kaynaktır.
- Production rota tabanı: MASTER ART raster + şeffaf hitbox + minimum lokal runtime-state override.
- Level 7 tamamlanınca bonus 8 ve normal 9 birlikte açılır; bonus 8, 9 için gate değildir; 10, node 9 tamamlanmadan locked/no-callback.
- BoardMap / 67 node sözleşmesi kontrolsüz değiştirilmez.

## Canonical Gameplay Sözleşmesi

- Grid: **8×8 / 64 hücre — LOCKED**.
- Önceki 6×10 yalnız tarihsel checkpointtir; ürüne geri dönmez.
- Target+bonus eğrisi: B1 5+1, B2 5+1, B3 6+1, B4 6+1, B5 7+1, B6 7+1, B7 8+1, B8 7+2, B9 9+1, B10 9+1; toplam **80**.
- Her target/bonus 8 düz yönde exactly-one fiziksel occurrence taşır; ters gesture aynı canonical kelimeye çözülür.
- B8 bonusları `HIZ` + `SKOR`; B9 bonus `ROKET`; B10 hedef `YOL`, bonus `HAZİNE`.
- B5 60 sn ve B10 120 sn soft challenge; hard-fail değildir.
- Engine/path/scoring/timer/progression sözleşmesi görsel tema uğruna değiştirilmez.

## V5 / V6 Ürün Kabulü — PASS

### V5 reference asset
- Production mimarisi: approved raster reference assets + dinamik Flutter text/state + canonical 8×8 engine.
- V5 integration run `33379341765`: **SUCCESS**.

### Found-state
- Exact tested commit `4dddf00178ef9f14b8edb3fc706114be72f477a4`.
- Android16 run `33486609120`: **SUCCESS**; raw Android kullanıcı PASS.

### Error-state
- Fill `0xB35A1F2B`, border `0xFFFF6B57`, transient 280 ms.
- Android16 run `33524578623`: **SUCCESS**; raw Android kullanıcı PASS.

### Completion/result
- Targetlar tamam, bonus eksik → otomatik popup yok; bonus aranabilir.
- Tüm target+bonus tamam → popup otomatik açılır; fresh/replay’de tekrar açılabilir.
- Static/productize `33629855060`: SUCCESS, Word Hunt 139/139 PASS.
- Android16 `33655562508`: SUCCESS; raw Android B5/B10 kullanıcı PASS.

### B5 denge
- İlk insan testi: 115 sn / 2 hata → 60 sn hedef karşılanmadı.
- B10 insan testi: 109 sn / 4 hata → 120 sn hedef PASS.
- B5 tuning sonrası: **32 sn** → süre PASS.
- Android16 tuning run `33670657723`: SUCCESS.
- B5 targetları `ANKARA`, `ŞEHİR`, `TÜRKİYE`, `BAŞKENT`, `MECLİS`, `KULE`, `KALE`; bonus `ANIT`.

### Swipe false-positive toleransı
- Kelime olamayacak kadar kısa gesture cezasız iptal edilir.
- Yalnız son hücre çıkarıldığında exact target/bonus/already-found oluşuyorsa tek trailing hücre kırpılır.
- İlk aktif pointer gesture boyunca kilitlenir; ek temas seçime karışmaz.
- İki hücre taşma ve anlamlı gerçek yanlış seçim hata kalır; autocomplete yoktur.
- Ürün commit `749c678b885d6cefec428c603c55a83a4190152c`.
- Fast `33724552713`: SUCCESS.
- Android16 `33724549202`: SUCCESS; gerçek `ANKARA + 1 trailing hücre` → `1/7`, hata `0`.

## Release Merge Zinciri — TAMAMLANDI

- PR #167 — **MERGED** → `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.
- PR #163 — **MERGED** → `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`.
- PR #162 — **MERGED** → `929bb13177e03a0962464e21f6c174d4b3439349`.
- PR #161 — **MERGED** → `4aa490e7c2d5e7547dc95f9463dbbb9adeb85e5a`.
- PR #158 — **MERGED** → `189864c92a605e7bb960460300714049c730ea39`.
- PR #169 — **MERGED** → `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
- PR #166 tarihsel geliştirme/QA hattıdır; merge edilmeyecektir.

## PR #158 Exact Release-context Kanıtı — PASS

- Exact test edilmiş ürün HEAD: `2ae95df70b452f735a8db9c5bd0d88827a2ec40a`.
- Kelime Avı Android16 visual proof run `33745646184`: **SUCCESS**, artifact `9887953917`.
- Release APK / AdMob run `33745646210`: **SUCCESS**, artifact `9889920696`.
- Merge commit `189864c9...` için otomatik workflow tetiklenmedi (`0` run); pre-merge exact release-context CI kanıtları final teknik kanıttır.

## Production Ana Navigasyon Entegrasyonu — PR #169 MERGED

### Amaç / davranış
- Bilgi Rotası production **Oyna** menüsüne `Kelime Avı` kartı eklendi.
- Kart `WordHuntProductionEntryScreen` üzerinden MASTER ART kullanan `WordHuntReferenceRouteScreen` production rotasına açılır.
- Açık rota node’u canonical `WordHuntLevelProductionScreen` gameplay ekranını açar.
- İlerleme `WordHuntProgressCodec` ile Firebase UID / guest scope’una göre `SharedPreferencesAsync` üzerinde cihazda saklanır.
- Başka hesap scope’una ait veri fail-closed reddedilir; bozuk/eski veri oyunun açılmasını engellemez.
- Bölüm sonucu mevcut `WordHuntProgressSnapshot` sözleşmesiyle best yıldız ve açılan bilgi kartlarını kaydeder.
- Geri / bilgi / pusula / kitap callbackleri production davranışına bağlıdır.

### Branch / PR / diff
- Branch: `feat/kelime-avi-production-navigation-20260903`.
- PR #169: **CLOSED / MERGED**.
- Merge öncesi base: `release/final-closed-test-aab-1.68.8` @ `189864c92a605e7bb960460300714049c730ea39`.
- Exact merged HEAD: **`ffa1454ba8fb47da21ca6caa50b0a5495e0149c1`**.
- Merge commit: **`0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`**.
- Final ürün farkı yalnız **4 dosya / +259 / -0**:
  - `lib/main.dart` — yalnız production entry importu (+1),
  - `lib/main_navigation.dart` — Kelime Avı Oyna kartı (+21),
  - `lib/word_hunt/word_hunt_production_entry_screen.dart` — production route/persistence glue,
  - `test/word_hunt_menu_entry_test.dart` — menü entry testi.
- Geçici one-shot üretim workflow’u final PR diff’inden kaldırıldı.
- `assets/questions.json`, BoardMap/67 node, canonical 8×8 content, Firebase rules/model, AdMob/signing/Android config, package/version değişmedi.

### Üretim / test kanıtları
- Focused üretim run `33754274810`: **SUCCESS**; 62 focused test PASS.
- Minimum-diff run `33754621892`: **SUCCESS**; formatter kaynaklı gereksiz `main_navigation.dart` churn kaldırıldı; minimum-diff commit `2d9fd0b63e3891d52c0e7376a8c0e5702dfb2dff`.
- Normal PR full-suite/release APK/Android16 run `33754851284`: **SUCCESS**; job `100646698982` SUCCESS.
  - analyze + tüm testler PASS,
  - kalıcı signing setup PASS,
  - test Ad ID’li release APK PASS,
  - package/merged manifest PASS,
  - Android 16 cold-start + AdMob process gate PASS,
  - kanıt artifact’i yüklendi.
- Kelime Avı Android16 görsel run `33754851205`: **SUCCESS**; job `100646698474` SUCCESS.
  - exact PR HEAD checkout `ffa1454...`,
  - `dart analyze lib/word_hunt`: **No issues found**,
  - focused suite **126/126 PASS**,
  - MASTER ART source/package byte+SHA karşılaştırması `SOURCE_EQUALS_PACKAGED=YES count=2`,
  - visual proof APK SHA256 `679a4be8d5766498f4c6b531d1766e7da604aadabd1f4bd9ee1405ccc3d2ad9e`,
  - Android API 36 emulator install/open/real screencap/activity/process/crash/ANR gate PASS,
  - MASTER ART side-by-side/diff/geometry kanıtları üretildi,
  - artifact `9893332600`, digest `sha256:2d0fa14825f59a735a9606be809025b2f69d4daa09121bb065bb622d25e30001`.
- Açık review/review thread blocker yoktu.
- Ready kapısı Levent’in 3 Eylül 2026 `Devam et` onayıyla geçildi.
- Merge kapısı Levent’in 3 Eylül 2026 ayrı `Merge et` onayıyla geçildi.
- Merge commitinde otomatik PR workflow’u tetiklenmedi (`0` run); exact PR HEAD’deki iki SUCCESS hattı final teknik kanıt olarak korunur.

## Docs-only Checkpoint PR #168

- Branch: `docs/kelime-avi-v8-post-release-merge-20260903`.
- PR #168: **OPEN / READY / mergeable=true / merged=false**.
- PR #169 merge’i sonrası ilk kısa `mergeable=false` görünümü GitHub yeniden hesaplamasında `mergeable=true` oldu; teknik blocker yok.
- Current release `0c84aefd...` ile docs branch diverged; merge base `189864c9...`dir. Current PR changed-file listesi yine yalnız dört checkpoint belgesidir: `ACIK_SORULAR_VE_DOGRULAMALAR.md`, `BILGI_ROTASI_DURUM.md`, `GOREV_HAVUZU.md`, `docs/project-memory/GENEL_PROJE_OZETI.md`.
- PR #168 ayrı açık Levent onayı olmadan merge edilmeyecek.

## Ölçeklenebilir Üretim/Test — KALICI KARAR

- Temel üretim birimi 10 bölümlük rota/pakettir.
- Bölüm başına ayrı branch/Android Action/APK/insan testi yapılmaz.
- Her bölüm otomatik 8×8, kelime sayısı, exactly-one occurrence, yön, reverse gesture, timer/yıldız ve render kapılarından geçer.
- İnsan denge örneklemesi varsayılan B1 + B5 + B10; otomatik outlier varsa yalnız ilgili ek bölüm oynanır.
- Android16 tam runtime paket tamamlanınca, engine/ortak UI değişiminde ve release entegrasyonu öncesinde çalışır.

## WORK V2 — AKTİF

- Mikro değişiklik → tam test → rapor → bekleme döngüsü kullanılmaz.
- İlişkili işler mümkün olan en büyük mantıklı üretim bloğunda tamamlanır.
- Çözülebilen hata/fixture/test sorunları kullanıcıyı test operatörü yapmadan giderilir ve yeniden doğrulanır.
- Kullanıcı ürün yönü, gerçek görsel/fiziksel kabul ve Ready/merge/release kararlarında devreye girer.

## Reference Font

- Runtime `fontFamily: 'serif'` kullanır.
- Repo içinde exact custom font kaynağı yoktur.
- `REFERENCE_FONT = DOĞRULANACAK / DEFERRED`; spekülatif font değişikliği yapılmaz.

## Korunan Alanlar

- `assets/questions.json` kontrolsüz değiştirilmez.
- BoardMap / 67 node değiştirilmez.
- Canonical 8×8 / 64 hücre sözleşmesi korunur.
- Firebase / AdMob / release signing değişiklikleri ayrı scope gerektirir.
- package name / version değişmedi.

## Kalan Aktif Sıra — V8 BURADAN DEVAM ETSİN

1. Her görev başında canonical release branch, `pubspec.yaml`, son commit ve ilgili açık PR/CI durumunu canlı doğrula.
2. Found/error/completion/B5/swipe kabul kapıları yeni belirti yoksa yeniden açılmaz.
3. PR #167/#163/#162/#161/#158/#169 merge zinciri — **PASS / TAMAMLANDI**.
4. Canonical release HEAD — `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
5. Production ana navigasyon entegrasyonu — **PASS / CANONICAL RELEASE İÇİNDE**.
6. Docs-only PR #168 — **READY / mergeable=true / merge kararı ayrıca açık Levent onayı gerektirir**.
7. `REFERENCE_FONT` — **DOĞRULANACAK / DEFERRED**.
8. Play yükleme/yayınlama — **ayrı açık Levent onayı gerektirir**.

**SON DURUM: 8×8 LOCKED / V5 ASSET PASS / FOUND PASS / ERROR PASS / COMPACT COMPLETION PASS / B5 SÜRE PASS / SWIPE ANDROID16 PASS / PR #167+#163+#162+#161+#158+#169 MERGED / PRODUCTION ANA NAVİGASYON CANONICAL RELEASE İÇİNDE / CANONICAL RELEASE HEAD `0c84aefd...` / PR #168 DOCS-ONLY READY+MERGEABLE / WORK V2 AKTİF / PLAY YAYINI YOK.**
