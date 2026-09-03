# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 3 Eylül 2026 — Kelime Avı V8 devir noktası. Canonical 8×8 Başlangıç Limanı; V5 asset, found/error/compact completion, B5 denge ve swipe toleransı PASS. PR #167, #163, #162, #161 ve #158 merge edildi. Levent’in ayrı açık onayıyla PR #158 canonical release branch’e merge edildi; release HEAD artık `189864c92a605e7bb960460300714049c730ea39`. Play yükleme/yayınlama yapılmadı. WORK V2 aktif.

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

- Repo: `ZMilaStudio/BilgiRotasi`
- Canonical release branch: `release/final-closed-test-aab-1.68.8`
- Canonical release HEAD: **`189864c92a605e7bb960460300714049c730ea39`**
- Aktif ürün sürümü: **1.68.19+109**
- Paket: `com.leventua.bilgirotasi`
- PR #158 canonical release’e merge edildi.
- Merge edilen PR HEAD: `49e24dfc57b251cd2dc8d96d1a88f3b257276b51`.
- Merge commit: `189864c92a605e7bb960460300714049c730ea39`.
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

## V5 Reference Asset Entegrasyonu — PASS

- Production mimarisi: approved raster reference assets + dinamik Flutter text/state + canonical 8×8 engine.
- 11 production asset exact SHA sözleşmesi korunur.
- V5 integration run `33379341765`: **SUCCESS**; exact asset SHA, format, analyze, focused Word Hunt tests, `git diff --check` ve protected-scope gate PASS.
- `pubspec.yaml` yalnız `assets/word_hunt/v5_reference_assets/` klasörünü kaydeder.

## V6 Görsel / Davranış Kabulü

### Found-state — PASS
- Found hücreler kendi kutu formunu korur; yalnız komşu found hücre boşluğu sıcak altın/turuncu edge-fuse ile birleşir.
- Exact tested commit `4dddf00178ef9f14b8edb3fc706114be72f477a4`.
- Android16 run `33486609120`: SUCCESS; raw Android kullanıcı PASS.

### Error-state — PASS
- Fill `0xB35A1F2B`, border `0xFFFF6B57`, transient 280 ms.
- Android16 run `33524578623`: SUCCESS; raw Android kullanıcı PASS.

### Completion/result — PASS
- Targetlar tamam, bonus eksik → otomatik popup yok; bonus aranabilir.
- Tüm target+bonus tamam → popup otomatik açılır; fresh/replay’de tekrar açılabilir.
- Exact tested compact blob `6ce2830a7df8eb696a9df589c91c544df7712969`.
- Static/productize `33629855060`: SUCCESS, Word Hunt 139/139 PASS.
- Android16 `33655562508`: SUCCESS; raw Android B5/B10 kullanıcı PASS.

## B5 Denge — PASS

- İlk insan testi: 115 sn / 2 hata → 60 sn hedef karşılanmadı.
- B10 insan testi: 109 sn / 4 hata → 120 sn hedef PASS.
- B5 tuning sonrası: **32 sn** → süre PASS.
- Android16 tuning run `33670657723`: SUCCESS.
- B5 targetları `ANKARA`, `ŞEHİR`, `TÜRKİYE`, `BAŞKENT`, `MECLİS`, `KULE`, `KALE`; bonus `ANIT`.

## Swipe False-positive Toleransı — PASS

- Kelime olamayacak kadar kısa gesture cezasız iptal edilir.
- Yalnız son hücre çıkarıldığında exact target/bonus/already-found oluşuyorsa tek trailing hücre kırpılır.
- İlk aktif pointer gesture boyunca kilitlenir; ek temas seçime karışmaz.
- İki hücre taşma ve anlamlı gerçek yanlış seçim hata kalır; autocomplete yoktur.
- Ürün commit `749c678b885d6cefec428c603c55a83a4190152c`.
- Fast `33724552713`: SUCCESS.
- Android16 `33724549202`: SUCCESS; gerçek `ANKARA + 1 trailing hücre` → `1/7`, hata `0`.

## PR Zinciri — TAMAMLANDI

- PR #167 — **CLOSED / MERGED** → `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.
- PR #163 — **CLOSED / MERGED** → `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`.
- PR #162 — **CLOSED / MERGED** → `929bb13177e03a0962464e21f6c174d4b3439349`.
- PR #161 — **CLOSED / MERGED** → `4aa490e7c2d5e7547dc95f9463dbbb9adeb85e5a`.
- PR #158 — **CLOSED / MERGED** → `189864c92a605e7bb960460300714049c730ea39`.
- PR #166 tarihsel geliştirme/QA hattıdır; merge edilmeyecektir.

## PR #158 — Final Release Entegrasyonu

- Branch: `feat/kelime-avi-8x8-content-v1-20260829`.
- Base: canonical release `release/final-closed-test-aab-1.68.8`.
- Cleanup commit `2ae95df70b452f735a8db9c5bd0d88827a2ec40a` — `chore(kelime-avi): remove obsolete release QA helpers`.
- Obsolete V5 gameplay QA workflow/entrypoint/script/test/helper/reference dosyaları ve superseded `assets/word_hunt/baslangic_limani_gameplay_bg.jpg` release diff’inden çıkarıldı.
- Cleanup ürün kodunu değiştirmedi; onaylı V5 reference background runtime’da kalır.
- Final PR diff: **37 dosya**.
- `lib/main.dart`, `assets/questions.json`, BoardMap/67 node, Firebase/AdMob/signing ve package/version diff dışında.
- Açık review/review thread yoktu.
- Ready kararı ayrı açık onayla PASS edildi.
- Release merge kararı ayrıca açık onayla PASS edildi.
- Merge method: `merge`.
- Merge commit: `189864c92a605e7bb960460300714049c730ea39`.

## PR #158 Exact Release-context Kanıtı — PASS

Exact test edilmiş ürün HEAD: `2ae95df70b452f735a8db9c5bd0d88827a2ec40a`.

### Kelime Avı Android16 visual proof
- Run `33745646184`: **SUCCESS**; job `100617364648`.
- Focused static/test, proof APK/asset, Android16 install/open/screenshot/activity/logcat/process scan ve MASTER ART comparison PASS.
- Artifact `9887953917` — `kelime-avi-android16-visual-proof`.
- Digest `sha256:0f2fbcfc4022e4e8422912139349412969916496f96d4d29d80bdec8865176c5`.

### Release APK / AdMob
- Run `33745646210`: **SUCCESS**; job `100617365147`.
- Analyze + full tests, release signing setup, release APK, manifest/AdMob/signature gates ve Android16 cold-start PASS; ikinci Android denemesi gerekmedi.
- Artifact `9889920696` — `BilgiRotasi-AdMob-1.68.19-109-kanitlari`.
- Digest `sha256:447b82994aa25002e6f520f2de2b4ba598adcf769d80cb7aa7a767faf2f95c00`.

Test edilmiş ürün HEAD `2ae95df7...` ile merge edilen HEAD `49e24dfc...` arasındaki 5 commit yalnız `BILGI_ROTASI_DURUM.md`, `GOREV_HAVUZU.md`, `ACIK_SORULAR_VE_DOGRULAMALAR.md` ve `docs/project-memory/GENEL_PROJE_OZETI.md` dosyalarını değiştirdi; ürün kodu değişmedi.

Merge commit `189864c9...` için otomatik workflow tetiklenmedi (`0` run). Bu nedenle pre-merge exact release-context CI kanıtları final teknik kanıttır.

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

- `assets/questions.json`
- `lib/main.dart`
- BoardMap / 67 node
- Firebase / AdMob / release signing
- package name / version

## Kalan Aktif Sıra — V8 BURADAN DEVAM ETSİN

1. Her görev başında canonical release branch, `pubspec.yaml`, son commit ve ilgili açık PR/CI durumunu canlı doğrula.
2. Found/error/completion/B5/swipe kabul kapıları yeni belirti yoksa yeniden açılmaz.
3. PR #167/#163/#162/#161/#158 merge zinciri — **PASS / TAMAMLANDI**.
4. Canonical release HEAD — `189864c92a605e7bb960460300714049c730ea39`.
5. Production `lib/main.dart` navigasyon entegrasyonu ayrı branch/PR olarak yapılır.
6. `REFERENCE_FONT` — **DOĞRULANACAK / DEFERRED**.
7. Play yükleme/yayınlama — **ayrı açık Levent onayı gerektirir**.

**SON DURUM: 8×8 LOCKED / V5 ASSET PASS / FOUND PASS / ERROR PASS / COMPACT COMPLETION PASS / B5 SÜRE PASS / SWIPE ANDROID16 PASS / PR #167+#163+#162+#161+#158 MERGED / CANONICAL RELEASE HEAD `189864c9...` / WORK V2 AKTİF / PLAY YAYINI YOK.**
