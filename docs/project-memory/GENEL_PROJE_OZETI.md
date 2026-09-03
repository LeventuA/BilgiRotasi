# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 3 Eylül 2026 — Kelime Avı V8 devir noktası. V6 found/error/compact completion kullanıcı PASS; B5 tuning 32 sn ile PASS; swipe false-positive düzeltmesi gerçek Android 16 kanıtıyla PASS. PR #167 ve PR #163 merge edildi. PR #162 final diff/review PASS ve Levent’in “Devam et” onayıyla Ready for Review yapıldı; merge ayrı açık onay bekliyor. Release/main’e merge yapılmadı. WORK V2 aktif.

> Teknik doğrulukta tek kanonik kaynak canlı `ZMilaStudio/BilgiRotasi` deposu ve ilgili canlı servislerdir. Bu dosya canlı branch/PR/CI/pubspec doğrulamasının yerine geçmez. Ayrıntılı eski üretim günlükları Git geçmişinde ve `docs/project-memory/archive/` altında korunur.

## Kalıcı Çalışma Kuralı

- Her görev başında canlı hedef branch, `pubspec.yaml`, son commit, PR ve CI yeniden doğrulanır.
- `main` güncel/yayın kaynağı varsayılmaz.
- Sıra: branch → test → commit → push → PR → inceleme → merge.
- Kritik merge/release yalnız Levent’in açık onayıyla yapılır.
- Build PASS tek başına kanıt değildir; diff, test, workflow, Git geçmişi ve gerçek runtime kanıtı birlikte değerlendirilir.
- Görsel kabul yalnız gerçek/raw Android runtime üzerinden verilir; ImageGen/mockup/QA selector kabul kanıtı değildir.
- `assets/questions.json` kontrolsüz değiştirilmez; ilgisiz değişiklikler silinmez.
- Codex yalnız mevcut araçlarla yapılamayan gerçek yerel kod/test işi zorunlu olduğunda kullanılır; gereksiz Codex kredisi harcanmaz.

## Canlı Release Hattı

- Repo: `ZMilaStudio/BilgiRotasi`
- Canonical release branch: `release/final-closed-test-aab-1.68.8`
- Release HEAD: `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`
- Aktif ürün sürümü: **1.68.19+109**
- Paket: `com.leventua.bilgirotasi`
- Kelime Avı V6 zinciri henüz release/main’e merge edilmedi.

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
- Toplam target+bonus eğrisi: B1 5+1, B2 5+1, B3 6+1, B4 6+1, B5 7+1, B6 7+1, B7 8+1, B8 7+2, B9 9+1, B10 9+1.
- Her target/bonus 8 düz yönde exactly-one fiziksel occurrence taşımalıdır; ters gesture aynı canonical kelimeye çözülür.
- B8 bonusları `HIZ` + `SKOR`; B9 bonus `ROKET`; B10 hedef `YOL`, bonus `HAZİNE`.
- B5 60 sn ve B10 120 sn **soft challenge**; hard-fail değildir.
- Engine/path/scoring/timer/progression genel sözleşmesi görsel tema uğruna değiştirilmez.

## V6 Görsel / Davranış Kabulü

### Found-state — PASS
- Gece limanı, koyu lacivert + bronz/altın premium görsel dil korunur.
- Found hücreler kendi kutu formunu korur; yalnız komşu found hücre boşluğu sıcak altın/turuncu edge-fuse ile birleşir.
- Exact tested commit `4dddf00178ef9f14b8edb3fc706114be72f477a4`.
- Android 16 run `33486609120`: SUCCESS.
- Raw B10 initial + `YOL / 1/9`: kullanıcı PASS.

### Error-state — PASS
- Fill `0xB35A1F2B`, border `0xFFFF6B57`, transient 280 ms.
- Android 16 run `33524578623`: SUCCESS.
- Raw Android kullanıcı PASS.

### Completion/result — PASS
- Targetlar tamam, bonus eksik → otomatik popup yok; bonus aranabilir.
- Tüm target+bonus tamam → popup otomatik açılır.
- Fresh/replay oturumunda tekrar otomatik açılabilir.
- Kabul edilen kompakt panel: `maxWidth: 300`, padding `18/15/18/15`, buton yüksekliği `44`.
- Exact tested compact blob `6ce2830a7df8eb696a9df589c91c544df7712969`.
- Static/productize run `33629855060`: SUCCESS; Word Hunt 139/139 PASS.
- Final Android 16 run `33655562508`: SUCCESS.
- Raw Android B5/B10 compact popup kullanıcı PASS.

## B5 Denge — PASS

- İlk insan testi: B5 **115 sn / 2 hata** → 60 sn soft challenge karşılanmadı.
- B10 insan testi: **109 sn / 4 hata** → 120 sn hedef PASS.
- B5 tuning sonrası insan testi: **32 sn / UI’da 2 false-positive kayıt** → süre PASS.
- İki false-positive bilinçli yanlış seçim değildi; insan niyeti açısından gerçek hata 0.
- B5 tuning Android 16 run `33670657723`: SUCCESS.
- Targetlar `ANKARA`, `ŞEHİR`, `TÜRKİYE`, `BAŞKENT`, `MECLİS`, `KULE`, `KALE`; bonus `ANIT` korunur.
- B5 exact güncel grid:
  - `ANKARAJB`
  - `TÜRKİYEA`
  - `OMOVÜAKŞ`
  - `ÖÇEGÜNUK`
  - `OZZCZILE`
  - `KALELTEN`
  - `OVFĞZİÜT`
  - `ŞEHİRZSÜ`

## Swipe False-positive Toleransı — PASS

- Kelime olamayacak kadar kısa gesture cezasız iptal edilir.
- Yalnız son hücre çıkarıldığında exact target/bonus/already-found oluşuyorsa tek trailing hücre kırpılır.
- İlk aktif pointer gesture boyunca kilitlenir; ek temas seçime karışmaz.
- İki hücre taşma ve anlamlı gerçek yanlış seçim hata kalır.
- Nearest-word/autocomplete uygulanmaz.
- Ürün commit `749c678b885d6cefec428c603c55a83a4190152c`.
- Fast checks run `33724552713`: SUCCESS.
- Android 16 gerçek `ANKARA + 1 trailing hücre` run `33724549202`: SUCCESS; `0/7 → 1/7`, hata `0 → 0`.
- Job `100550528945`; artifact `9881526593`; APK SHA-256 `73618f5af356374104475d457fe15f263cdd370b009f81f7691c5f7d333dbd58`.

## PR Zinciri — Güncel

- PR #167 — **CLOSED / MERGED**.
  - Merge commit: `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.
  - B5 tuning + swipe toleransı PR #163 ürün hattına taşındı.
- PR #163 — **CLOSED / MERGED**.
  - Levent Ready ve ardından ayrı merge onayı verdi.
  - Merge commit: `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`.
  - Merge hedefi release/main değil PR #162’nin V6 branch’idir.
- PR #162 — **OPEN / READY / mergeable=true / merged=false**.
  - Güncel V6 branch: `fix/kelime-avi-v6-visual-found-state-20260901`.
  - Ready checkpoint ürün HEAD: `bf3768b0b3104ebf8c8103340d9664c1e0385ce8`.
  - Final diff/review PASS: 16 beklenen dosya; `lib/main.dart`, `assets/questions.json`, locked V5 assets, BoardMap/67 node ve release config diff dışında; açık review/thread yok.
  - Levent’in 3 Eylül 2026 “Devam et” onayıyla Ready for Review yapıldı.
  - Ready sonrası yalnız checkpoint doküman commitleri eklenmektedir; ürün kodu değişmemiştir.
- PR #161 — **OPEN / DRAFT**; parent V5 zincir kararı ayrıca ele alınacaktır.
- PR #166 tarihsel geliştirme/QA hattıdır; merge edilmeyecektir.

## Ölçeklenebilir Üretim/Test — KALICI KARAR

- Temel üretim birimi **10 bölümlük rota/paket**tir.
- Bölüm başına ayrı branch/Android Action/APK/insan testi yapılmaz.
- Her bölüm otomatik 8×8, kelime sayısı, exactly-one occurrence, yön, reverse gesture, timer/yıldız ve render kapılarından geçer.
- İnsan denge örneklemesi varsayılan **B1 + B5 + B10**; otomatik outlier varsa yalnız ilgili ek bölüm oynanır.
- Android 16 tam runtime paket tamamlanınca, engine/ortak UI değişiminde ve release entegrasyonu öncesinde çalışır.
- Tek paket QA APK’sı B1–B10 seçici taşır.

## WORK V2 — AKTİF

- Mikro değişiklik → tam test → rapor → bekleme döngüsü kullanılmaz.
- İlişkili işler mümkün olan en büyük mantıklı üretim bloğunda tamamlanır.
- Çözülebilen fixture/test/uygulama hataları kullanıcıyı test operatörü yapmadan giderilir ve yeniden doğrulanır.
- Kullanıcı yalnız ürün yönü, gerçek görsel/fiziksel kabul ve Ready/merge/release kararlarında devreye girer.

## Reference Font

- Runtime `fontFamily: 'serif'` kullanır.
- Repo içinde exact custom font kaynağı yoktur.
- `REFERENCE_FONT = DOĞRULANACAK / DEFERRED`.
- Spekülatif font değişikliği yapılmaz.

## Korunan Alanlar

V6 zincirinde değiştirilmedi:
- `assets/questions.json`
- `lib/main.dart`
- locked V5 reference assets
- BoardMap / 67 node
- Firebase / AdMob / release signing
- package name / version

## Kalan Aktif Sıra — V8 BURADAN DEVAM ETSİN

1. Her görev başında release branch, PR #162 HEAD, `pubspec.yaml`, PR/review/CI durumunu canlı doğrula.
2. Found, error ve compact completion acceptance kapıları PASS; yeni belirti yoksa yeniden açma.
3. B5 tuning ve swipe toleransı PASS; yeni ürün değişikliği yoksa yeniden Android Action çalıştırma.
4. PR #162 final diff/review + Ready — **PASS / TAMAMLANDI**.
5. PR #162 merge için ayrıca Levent’in açık onayını al.
6. Sonra PR #161 zincir kararını ayrıca ele al.
7. Production `lib/main.dart` navigasyon entegrasyonunu ayrı branch/PR olarak yap.
8. Release entegrasyonu ve Play yayını ayrı açık karardır.

**SON DURUM: 8×8 LOCKED / FOUND PASS / ERROR PASS / COMPACT COMPLETION PASS / B5 SÜRE PASS / SWIPE ANDROID 16 PASS / PR #167 MERGED / PR #163 MERGED / PR #162 READY-OPEN / WORK V2 AKTİF / MERGE YOK / RELEASE-MERGE YOK.**
