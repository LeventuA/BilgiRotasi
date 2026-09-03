# Bilgi Rotası – Proje Durumu

**Son güncelleme:** 3 Eylül 2026 — PR #162 final diff/review PASS ve Levent’in “Devam et” onayıyla Ready for Review yapıldı; merge ayrı açık onay bekliyor

## Canlı Sürüm / Release Hattı

- Repo içi aktif ürün sürümü: **1.68.19+109**.
- Paket: `com.leventua.bilgirotasi`.
- Canonical release branch: `release/final-closed-test-aab-1.68.8`.
- Canonical release HEAD: `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`.
- `main` güncel/yayın kaynağı olarak varsayılmaz; canlı ürün branch/PR her görevde yeniden doğrulanır.
- Kelime Avı V6 zinciri henüz release/main’e merge edilmedi.

## Kelime Avı V6 — Güncel Ürün Hattı

Canonical gameplay sözleşmesi **8×8 / 64 hücre — LOCKED**.

- Parent V5: PR #161 — **OPEN / DRAFT / merge yok**.
- Güncel V6 branch: `fix/kelime-avi-v6-visual-found-state-20260901`.
- Güncel V6 PR: **#162 — OPEN / READY / merged=false / mergeable=true**.
- PR #162 Ready checkpoint ürün HEAD’i: `bf3768b0b3104ebf8c8103340d9664c1e0385ce8`; Ready sonrası yalnız checkpoint belgeleri güncellenir.
- PR #163: **CLOSED / MERGED**; merge commit `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`.
- PR #167: **CLOSED / MERGED**; merge commit `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.
- B5 + swipe ürün commit’i: `749c678b885d6cefec428c603c55a83a4190152c`.
- Compact completion ürün commit’i: `9a6fede2c4aed4fdbaa6c9ba427fa84e0ce418da`.

## Kullanıcı Kabulü / Teknik Kapılar

### Found-state — PASS
- Raw Android kullanıcı kabulü: **PASS**.
- Exact tested commit: `4dddf00178ef9f14b8edb3fc706114be72f477a4`.
- Android 16 run `33486609120`: **SUCCESS**.
- Kabul edilen biçim: found hücrelerin kendi kutusu korunur; yalnız komşu found hücre aralığı sıcak altın/turuncu edge-fuse ile birleşir.

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
- B5 hedef/bonus listesi, 8×8, 60 sn soft challenge, yıldız eşikleri ve yön aileleri korundu.
- Android 16 tuning run `33670657723`: **SUCCESS**.

### Swipe false-positive toleransı — PASS
- Kelime olamayacak kadar kısa gesture cezasız iptal edilir.
- Yalnız exact target/bonus/already-found oluşturan **tek trailing hücre** kırpılır.
- Gesture boyunca tek aktif pointer kilitlenir.
- İki hücre taşma ve gerçek anlamlı yanlış seçim hata kalır.
- Nearest-word/autocomplete uygulanmaz.
- Fast checks run `33724552713`: **SUCCESS**.
- Android 16 gerçek `ANKARA + 1 trailing hücre` run `33724549202`: **SUCCESS**.
- Gerçek sonuç: `0/7 → 1/7`, hata `0 → 0`.
- Job `100550528945`; artifact `9881526593`; APK SHA-256 `73618f5af356374104475d457fe15f263cdd370b009f81f7691c5f7d333dbd58`.

## PR #162 Final İnceleme — PASS

- 16 beklenen değişen dosya doğrulandı.
- `lib/main.dart`, `assets/questions.json`, locked V5 assets, BoardMap/67 node ve release yapılandırması diff dışında.
- Açık review veya review thread yok.
- Swipe çözümü dar kapsamlıdır; geniş kelime tahmini/autocomplete yoktur.
- PR #163 mergeinden sonra ürün kodu değişmedi; son HEAD’e eklenen değişiklikler checkpoint belgeleridir.
- PR #162 Levent’in “Devam et” onayıyla **READY FOR REVIEW** yapıldı.

## Korunan Alanlar

Bu V6 ürün zincirinde değiştirilmedi:
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

1. PR #162 final diff/review + Ready — **PASS / TAMAMLANDI**.
2. PR #162 merge — **AÇIK / ayrıca Levent’in açık onayı gerekli**.
3. PR #161 zincir kararı ayrıca ele alınır.
4. Production `lib/main.dart` ana navigasyon entegrasyonu ayrı scope/branch/PR işidir.
5. Release entegrasyonu ve Play yayını ayrıca açık karar gerektirir.

**Durum:** V6 FOUND PASS / ERROR PASS / COMPACT COMPLETION PASS / B5 SÜRE PASS / SWIPE ANDROID 16 PASS / PR #167 MERGED / PR #163 MERGED / PR #162 READY-OPEN / MERGE YOK / RELEASE-MERGE YOK.
