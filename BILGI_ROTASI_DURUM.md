# Bilgi Rotası – Proje Durumu

**Son güncelleme:** 3 Eylül 2026 — PR #161 Levent’in açık onayıyla merge edildi; PR #158 release-parent temizliği ve exact release-context CI PASS. PR #158 hâlâ DRAFT; Ready ve release merge ayrı açık kararlardır.

## Canlı Sürüm / Release Hattı

- Repo içi aktif ürün sürümü: **1.68.19+109**.
- Paket: `com.leventua.bilgirotasi`.
- Canonical release branch: `release/final-closed-test-aab-1.68.8`.
- Canonical release HEAD: `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`.
- `main` güncel/yayın kaynağı olarak varsayılmaz.
- Kelime Avı değişiklikleri henüz release/main’e merge edilmedi.

## Kelime Avı — Güncel Ürün Hattı

Canonical gameplay sözleşmesi **8×8 / 64 hücre — LOCKED**.

- Güncel release-parent branch: `feat/kelime-avi-8x8-content-v1-20260829`.
- Güncel PR: **#158 — OPEN / DRAFT / merged=false / mergeable=true**.
- Exact release-context test edilmiş ürün HEAD: `2ae95df70b452f735a8db9c5bd0d88827a2ec40a`.
- PR #161: **CLOSED / MERGED**; merge commit `4aa490e7c2d5e7547dc95f9463dbbb9adeb85e5a`.
- PR #162: **CLOSED / MERGED**; merge commit `929bb13177e03a0962464e21f6c174d4b3439349`.
- PR #163: **CLOSED / MERGED**; merge commit `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`.
- PR #167: **CLOSED / MERGED**; merge commit `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.
- PR #166 tarihsel geliştirme/QA hattıdır; merge edilmeyecek.

## Canonical Gameplay / İçerik

- 10 bölüm / 30 yıldız.
- Her bölüm 8×8 / 64 hücre.
- Target+bonus eğrisi: B1 5+1, B2 5+1, B3 6+1, B4 6+1, B5 7+1, B6 7+1, B7 8+1, B8 7+2, B9 9+1, B10 9+1; toplam **80**.
- Her target/bonus 8 düz yönde exactly-one fiziksel occurrence taşır; ters gesture aynı canonical kelimeye çözülür.
- B8 bonusları `HIZ` + `SKOR`; B9 bonus `ROKET`; B10 hedef `YOL`, bonus `HAZİNE`.
- B5 60 sn, B10 120 sn soft challenge; hard-fail değildir.
- Nearest-word/autocomplete yoktur.

## Kullanıcı Kabulü / Teknik Kapılar

### Found-state — PASS
- Raw Android kullanıcı kabulü: **PASS**.
- Exact tested commit `4dddf00178ef9f14b8edb3fc706114be72f477a4`.
- Android 16 run `33486609120`: **SUCCESS**.

### Error-state — PASS
- Raw Android kullanıcı kabulü: **PASS**.
- Fill `0xB35A1F2B`, border `0xFFFF6B57`, transient `280 ms`.
- Android 16 run `33524578623`: **SUCCESS**.

### Compact completion/result — PASS
- Targetlar tamam, bonus eksik → otomatik popup yok; bonus aranabilir.
- Tüm target+bonus tamam → popup otomatik; fresh/replay’de tekrar açılabilir.
- Exact tested compact blob `6ce2830a7df8eb696a9df589c91c544df7712969`.
- Static/productize `33629855060`: SUCCESS; Word Hunt **139/139 PASS**.
- Android 16 `33655562508`: SUCCESS; raw Android B5/B10 kullanıcı PASS.

### B5 denge — PASS
- İlk insan ölçümü: 115 sn / 2 hata → 60 sn hedef karşılanmadı.
- Tuning sonrası insan ölçümü: **32 sn**; süre PASS.
- Android 16 tuning run `33670657723`: SUCCESS.

### Swipe false-positive — PASS
- Kelime olamayacak kadar kısa gesture cezasız iptal edilir.
- Yalnız exact target/bonus/already-found oluşturan tek trailing hücre kırpılır.
- İlk aktif pointer gesture boyunca kilitlenir.
- İki hücre taşma ve anlamlı gerçek yanlış seçim hata kalır; autocomplete yoktur.
- Ürün commit `749c678b885d6cefec428c603c55a83a4190152c`.
- Fast `33724552713`: SUCCESS.
- Android 16 `33724549202`: SUCCESS; gerçek `ANKARA + 1 trailing hücre` → `0/7 → 1/7`, hata `0 → 0`.

## PR #161 Merge — PASS

- PR #161 final review + Ready daha önce PASS idi.
- Levent 3 Eylül 2026’da ayrıca açık merge onayı verdi.
- Merge method: `merge`.
- Merge commit: `4aa490e7c2d5e7547dc95f9463dbbb9adeb85e5a`.
- Hedef yalnız PR #158 branch’idir; release/main değildir.

## PR #158 Release-parent Temizliği — PASS

- PR #161 merge sonrası PR #158 release’e girecek final parent olarak yeniden incelendi.
- Obsolete release QA helper cleanup commit: `2ae95df70b452f735a8db9c5bd0d88827a2ec40a` — `chore(kelime-avi): remove obsolete release QA helpers`.
- Release diff’inden kaldırılanlar: eski V5 gameplay QA workflow/entrypoint/script/test/helper/reference dosyaları ve artık runtime’da kullanılmayan `assets/word_hunt/baslangic_limani_gameplay_bg.jpg`.
- Eski background superseded durumdadır; runtime onaylı V5 reference background kullanır.
- Cleanup yalnız QA/superseded dosyaları kaldırdı; ürün kodu değiştirilmedi.
- PR #158 final diff: **37 dosya**.
- `lib/main.dart`, `assets/questions.json`, BoardMap/67 node, Firebase/AdMob/signing ve package/version diff dışında.
- `pubspec.yaml` yalnız `assets/word_hunt/v5_reference_assets/` kaydını ekler; sürüm **1.68.19+109** değişmedi.
- Açık PR review/review thread yok.

## PR #158 Exact Release-context CI — PASS

### Kelime Avı Android 16 visual proof
- Exact HEAD: `2ae95df70b452f735a8db9c5bd0d88827a2ec40a`.
- Run `33745646184`: **SUCCESS**.
- Job `100617364648`: **SUCCESS**.
- Focused static/test, proof APK/asset doğrulaması, Android 16 install/open/screenshot/activity/logcat/process scan ve MASTER ART comparison PASS.
- Artifact `9887953917` — `kelime-avi-android16-visual-proof`.
- Digest `sha256:0f2fbcfc4022e4e8422912139349412969916496f96d4d29d80bdec8865176c5`.

### Release APK / AdMob PR doğrulaması
- Exact HEAD: `2ae95df70b452f735a8db9c5bd0d88827a2ec40a`.
- Run `33745646210`: **SUCCESS**.
- Job `100617365147`: **SUCCESS**.
- Analyze + full test suite, release signing setup, release APK, manifest/AdMob/signature gates ve Android 16 cold-start PASS; ikinci Android denemesine ihtiyaç olmadı.
- Artifact `9889920696` — `BilgiRotasi-AdMob-1.68.19-109-kanitlari`.
- Digest `sha256:447b82994aa25002e6f520f2de2b4ba598adcf769d80cb7aa7a767faf2f95c00`.

## Korunan Alanlar

- `assets/questions.json`
- `lib/main.dart`
- canonical 8×8 / 64 hücre sözleşmesi
- BoardMap / 67 node
- Firebase / AdMob / release signing
- package name / version

## Ölçeklenebilir Üretim/Test Kararı

- Üretim birimi 10 bölümlük rota/pakettir; bölüm başına branch/Action/APK yapılmaz.
- Her bölüm otomatik grid/kelime/yol/timer/render sözleşme testinden geçer.
- İnsan denge örneklemesi varsayılan B1 + B5 + B10.
- Tek Android 16 paket kapısı paket tamamlanınca, ortak engine/UI değişiminde ve release entegrasyonu öncesinde çalışır.

## Reference Font

- Runtime `fontFamily: 'serif'` kullanır.
- Exact custom font kaynağı repoda yoktur.
- `REFERENCE_FONT = DOĞRULANACAK / DEFERRED`; spekülatif değişiklik yapılmaz.

## Kalan Gerçek Kapılar

1. PR #161 merge — **PASS / TAMAMLANDI**.
2. PR #158 cleanup + final diff/review + exact release-context CI — **PASS / TAMAMLANDI**.
3. PR #158 Ready for Review — **AÇIK / ayrıca Levent’in açık onayı gerekli**.
4. PR #158 → canonical release merge — Ready sonrasında ayrıca Levent’in açık merge onayı gerekli.
5. Production `lib/main.dart` ana navigasyon entegrasyonu ayrı scope/branch/PR işidir.
6. Play yükleme/yayınlama ayrıca açık karar gerektirir.

**Durum:** 8×8 LOCKED / V5 ASSET PASS / FOUND PASS / ERROR PASS / COMPACT COMPLETION PASS / B5 SÜRE PASS / SWIPE ANDROID16 PASS / PR #167+#163+#162+#161 MERGED / PR #158 RELEASE-CONTEXT CI PASS / PR #158 DRAFT-OPEN / READY YOK / RELEASE-MERGE YOK.
