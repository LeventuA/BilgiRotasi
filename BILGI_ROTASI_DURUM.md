# Bilgi Rotası – Proje Durumu

**Son güncelleme:** 3 Eylül 2026 — Levent’in ayrı ve açık onayıyla PR #158 canonical release branch’e merge edildi. Kelime Avı Başlangıç Limanı 8×8 gameplay paketi artık canonical release hattındadır. Play yükleme/yayınlama yapılmadı.

## Canlı Sürüm / Release Hattı

- Repo içi aktif ürün sürümü: **1.68.19+109**.
- Paket: `com.leventua.bilgirotasi`.
- Canonical release branch: `release/final-closed-test-aab-1.68.8`.
- Canonical release HEAD: **`189864c92a605e7bb960460300714049c730ea39`**.
- PR #158: **CLOSED / MERGED**.
- PR #158 merge commit: **`189864c92a605e7bb960460300714049c730ea39`**.
- Merge method: `merge`.
- Merge edilen HEAD: `49e24dfc57b251cd2dc8d96d1a88f3b257276b51`.
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
- `pubspec.yaml` yalnız `assets/word_hunt/v5_reference_assets/` kaydını ekler.

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
- Exact tested compact blob `6ce2830a7df8eb696a9df589c91c544df7712969`.
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

## Final Release-context Kanıtı — PASS

Exact test edilmiş ürün HEAD: `2ae95df70b452f735a8db9c5bd0d88827a2ec40a`.

### Kelime Avı Android16 visual proof
- Run `33745646184`: **SUCCESS**.
- Job `100617364648`: **SUCCESS**.
- Focused static/test, proof APK/asset, Android16 install/open/screenshot/activity/logcat/process scan ve MASTER ART comparison PASS.
- Artifact `9887953917`.
- Digest `sha256:0f2fbcfc4022e4e8422912139349412969916496f96d4d29d80bdec8865176c5`.

### Release APK / AdMob
- Run `33745646210`: **SUCCESS**.
- Job `100617365147`: **SUCCESS**.
- Analyze + full test suite, release signing setup, release APK, manifest/AdMob/signature gates ve Android16 cold-start PASS.
- Artifact `9889920696`.
- Digest `sha256:447b82994aa25002e6f520f2de2b4ba598adcf769d80cb7aa7a767faf2f95c00`.

Test edilmiş ürün HEAD `2ae95df7...` ile merge edilen HEAD `49e24dfc...` arasındaki 5 commit yalnız dört canonical checkpoint belgesini değiştirdi; ürün kodu değişmedi.

Merge commit `189864c9...` için otomatik workflow tetiklenmedi (`0` run); bu nedenle merge öncesi exact release-context kanıtları final teknik kanıttır.

## Merge Zinciri — TAMAMLANDI

- PR #167 — MERGED → `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.
- PR #163 — MERGED → `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`.
- PR #162 — MERGED → `929bb13177e03a0962464e21f6c174d4b3439349`.
- PR #161 — MERGED → `4aa490e7c2d5e7547dc95f9463dbbb9adeb85e5a`.
- PR #158 — MERGED → `189864c92a605e7bb960460300714049c730ea39`.
- PR #166 tarihsel geliştirme/QA hattıdır; merge edilmeyecek.

## Korunan Alanlar

- `assets/questions.json`
- `lib/main.dart`
- canonical 8×8 / 64 hücre sözleşmesi
- BoardMap / 67 node
- Firebase / AdMob / release signing
- package name / version

## Kalan Gerçek Kapılar

1. PR #158 → canonical release merge — **PASS / TAMAMLANDI**.
2. Production `lib/main.dart` ana navigasyon entegrasyonu — **AÇIK / ayrı scope-branch-PR**.
3. `REFERENCE_FONT` exact kaynak — **DOĞRULANACAK / DEFERRED**.
4. Play yükleme/yayınlama — **AÇIK / ayrıca Levent’in açık onayı gerekli**.

**Durum:** 8×8 LOCKED / V5 ASSET PASS / FOUND PASS / ERROR PASS / COMPACT COMPLETION PASS / B5 SÜRE PASS / SWIPE ANDROID16 PASS / PR #167+#163+#162+#161+#158 MERGED / CANONICAL RELEASE HEAD `189864c9...` / PLAY YAYINI YOK.
