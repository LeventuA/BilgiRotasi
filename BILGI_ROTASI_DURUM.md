# Bilgi Rotası – Proje Durumu

**Son güncelleme:** 3 Eylül 2026 — PR #162 Levent’in açık onayıyla PR #161 parent branch’ine merge edildi; release/main değişmedi

## Canlı Sürüm / Release Hattı

- Repo içi aktif ürün sürümü: **1.68.19+109**.
- Paket: `com.leventua.bilgirotasi`.
- Canonical release branch: `release/final-closed-test-aab-1.68.8`.
- Canonical release HEAD: `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`.
- `main` güncel/yayın kaynağı olarak varsayılmaz.
- Kelime Avı V6 zinciri henüz release/main’e merge edilmedi.

## Kelime Avı — Güncel Ürün Hattı

Canonical gameplay sözleşmesi **8×8 / 64 hücre — LOCKED**.

- Güncel parent branch: `feat/kelime-avi-v5-reference-assets-integration-20260831`.
- Güncel parent PR: **#161 — OPEN / DRAFT / merged=false / mergeable=true**.
- PR #162: **CLOSED / MERGED**; merge commit `929bb13177e03a0962464e21f6c174d4b3439349`.
- PR #163: **CLOSED / MERGED**; merge commit `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`.
- PR #167: **CLOSED / MERGED**; merge commit `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.
- PR #166 tarihsel geliştirme/QA hattıdır; merge edilmeyecek.
- B5 + swipe ürün commit’i: `749c678b885d6cefec428c603c55a83a4190152c`.
- Compact completion ürün commit’i: `9a6fede2c4aed4fdbaa6c9ba427fa84e0ce418da`.

## Kullanıcı Kabulü / Teknik Kapılar

### Found-state — PASS
- Raw Android kullanıcı kabulü: **PASS**.
- Exact tested commit: `4dddf00178ef9f14b8edb3fc706114be72f477a4`.
- Android 16 run `33486609120`: **SUCCESS**.

### Error-state — PASS
- Raw Android kullanıcı kabulü: **PASS**.
- Fill `0xB35A1F2B`, border `0xFFFF6B57`, transient `280 ms`.
- Android 16 run `33524578623`: **SUCCESS**.

### Compact completion/result — PASS
- Targetlar tamam, bonus eksik → otomatik popup yok; bonus aranabilir.
- Tüm target+bonus tamam → otomatik popup.
- Fresh/replay oturumu → popup yeniden otomatik açılabilir.
- Raw Android kompakt B5/B10 popup kullanıcı kabulü: **PASS**.
- Exact tested compact screen blob: `6ce2830a7df8eb696a9df589c91c544df7712969`.
- Static/productize run `33629855060`: **SUCCESS**, Word Hunt **139/139 PASS**.
- Final clean Android 16 run `33655562508`: **SUCCESS**.

### B5 denge — PASS
- İlk insan ölçümü: **115 sn / 2 hata** → 60 sn soft challenge karşılanmadı.
- Tuning sonrası insan ölçümü: **32 sn / UI’da 2 false-positive kayıt** → süre **PASS**.
- İki kayıt bilinçli yanlış seçim değildi; insan niyeti açısından gerçek hata **0**.
- Android 16 tuning run `33670657723`: **SUCCESS**.

### Swipe false-positive toleransı — PASS
- Kelime olamayacak kadar kısa gesture cezasız iptal edilir.
- Yalnız exact target/bonus/already-found oluşturan **tek trailing hücre** kırpılır.
- Gesture boyunca tek aktif pointer kilitlenir.
- İki hücre taşma ve gerçek anlamlı yanlış seçim hata kalır.
- Nearest-word/autocomplete uygulanmaz.
- Fast checks run `33724552713`: **SUCCESS**.
- Android 16 gerçek `ANKARA + 1 trailing hücre` run `33724549202`: **SUCCESS**; `0/7 → 1/7`, hata `0 → 0`.

## PR #162 Merge — PASS

- Final diff/review: **PASS**.
- Açık review/review thread yoktu.
- Ready sonrası HEAD hareketi yalnız `BILGI_ROTASI_DURUM.md`, `GOREV_HAVUZU.md` ve `docs/project-memory/GENEL_PROJE_OZETI.md` checkpoint commitlerinden oluştu; ürün kodu değişmedi.
- Levent ayrı ve açık merge onayı verdi.
- Merge method: `merge`.
- Merge commit: `929bb13177e03a0962464e21f6c174d4b3439349`.
- Merge hedefi PR #161 parent branch’idir; release/main değildir.

## Korunan Alanlar

- `assets/questions.json`
- `lib/main.dart`
- canonical 8×8 / 64 hücre sözleşmesi
- locked V5 reference assets
- BoardMap / 67 node
- Firebase / AdMob / release signing
- package name / version

## Ölçeklenebilir Üretim/Test Kararı

- Üretim birimi **10 bölümlük rota/paket**tir; bölüm başına branch/Action/APK yapılmaz.
- Her bölüm otomatik grid/kelime/yol/timer/render sözleşme testinden geçer.
- İnsan denge örneklemesi varsayılan **B1 + B5 + B10**.
- Tek Android 16 paket kapısı paket tamamlanınca; engine/ortak UI değişiminde ve release entegrasyonu öncesinde çalışır.

## Reference Font

- Runtime `fontFamily: 'serif'` kullanır.
- Repo içinde exact custom font kaynağı yoktur.
- `REFERENCE_FONT = DOĞRULANACAK / DEFERRED`; spekülatif font değişikliği yapılmaz.

## Kalan Gerçek Kapılar

1. PR #161 final diff/review canlı kontrolü. **AÇIK**.
2. PR #161 Ready kararı. **AÇIK / Levent onayı gerekli**.
3. PR #161 merge kararı Ready’den sonra ayrıca açık onay gerektirir.
4. Parent PR #158 zincir kararı ayrıca ele alınır.
5. Production `lib/main.dart` ana navigasyon entegrasyonu ayrı scope/branch/PR işidir.
6. Release entegrasyonu ve Play yayını ayrıca açık karar gerektirir.

**Durum:** 8×8 LOCKED / FOUND PASS / ERROR PASS / COMPACT COMPLETION PASS / B5 SÜRE PASS / SWIPE ANDROID 16 PASS / PR #167 MERGED / PR #163 MERGED / PR #162 MERGED / PR #161 DRAFT-OPEN / RELEASE-MERGE YOK.
