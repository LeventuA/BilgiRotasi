# Kelime Avı — Release → Gameplay Geçiş Checkpoint'i

**Tarih:** 27 Ağustos 2026

> Bu dosya Kelime Avı için mevcut bağlayıcı durumdur. `BILGI_ROTASI_DURUM.md`, `GOREV_HAVUZU.md` veya `ACIK_SORULAR_VE_DOGRULAMALAR.md` içinde PR #132/#96 zincirini hâlâ açık gösteren satırlar tarihsel kayıttır ve bu checkpoint tarafından supersede edilir.

## Canlı release gerçeği

- Repo: `ZMilaStudio/BilgiRotasi`
- Kanonik release branch: `release/final-closed-test-aab-1.68.8`
- Release HEAD: `0350e0ae9cbe9ec3eda275a983c9cbc17483baf3`
- Release tree: `a082ce673a682dc81adfdfc7c5975b80ccc2165a`
- Sürüm: `1.68.19+109`
- Paket: `com.leventua.bilgirotasi`

## Tamamlanan PR zinciri

- PR #147 → MASTER ART production route kabul/entegrasyonu.
- PR #150 → dynamic `X/30`, yıldız ve locked/open runtime state.
- PR #132 → merged.
- PR #110 → merged.
- PR #107 → merged.
- Eski PR #96 güncel release ile diverged olduğu için **SUPERSEDED / CLOSED / UNMERGED**.
- Temiz current-release entegrasyonu PR #153 üzerinden yapıldı.
- PR #153 → `release/final-closed-test-aab-1.68.8` üzerine merged.
- PR #153 merge commit: `0350e0ae9cbe9ec3eda275a983c9cbc17483baf3`.
- Geçici QA PR #154 **CLOSED / DO NOT MERGE**.

## Final release-context kanıtı

Exact integration HEAD `38b12ba58f60558c22eff75997a7d22e95d291a2` üzerinde:

- Kelime Avı Android 16 görsel/focused run `33000456233`: SUCCESS.
- Artifact `9618632032`; digest `sha256:a22ad1612755ac6be979bb52c9cd680d4103d657e7ca35124864d4e681724516`.
- Focused Kelime Avı suite: PASS.
- MASTER ART packaged/source equality: PASS.
- Android 16 screenshot visual QA: PASS.
- Runtime görünüm: `21/30`, 8–9 açık/0 yıldız, 10 locked.
- AdMob/release validation run `33000456242`: SUCCESS.
- Analyze + tüm testler: PASS.
- Release APK + package/manifest: PASS.
- Android 16 cold-start: PASS.
- App/release gate: PASS.

## Bağlayıcı Başlangıç Limanı mimarisi

`MASTER ART RASTER → TRANSPARENT INTERACTION HITBOXES → MINIMUM LOCAL STATE OVERRIDES`

- Issue #109 `Photo 1.jpg` tek bağlayıcı görsel kaynaktır.
- Repo MASTER ART: `assets/word_hunt/baslangic_limani_master_art_visual_proof.jpg`.
- PR #146 / `c42a9ff...` ve ChatGPT-generated eski hedef asset'ler görsel kaynak değildir.
- Gerçek `X/30`, level 1–10 yıldız ve locked/open state runtime progression ile senkrondur.
- Level 7 tamamlanınca 8 + 9 açılır.
- Bonus 8 node 9 için zorunlu değildir.
- Node 9 callback üretir.
- Node 10 node 9 tamamlanana kadar locked/no-callback kalır.

## Yeni aktif geliştirme hattı

- Branch: `feat/kelime-avi-gameplay-v1-20260826`
- Branch başlangıç SHA: `0350e0ae9cbe9ec3eda275a983c9cbc17483baf3`
- İlk hedef: **Başlangıç Limanı Bölüm 1 gerçek production oynanış döngüsü**.
- `lib/main.dart` ana uygulama navigasyonu bu ilk gameplay adımında değiştirilmeyecek.

### Bölüm 1 canonical içerik

Grid 6×6:

- `KALEMS`
- `MASALI`
- `ELMALI`
- `BİLGİN`
- `OYUNCU`
- `ROTASI`

Hedefler:
- `KALEM`
- `MASA`

Bonus:
- `ELMA`

Yıldız kuralı:
- 1 yıldız: bölüm tamamlandı.
- 2 yıldız: en fazla 2 hata.
- 3 yıldız: 0 hata.

## İlk gameplay hedefi

`Başlangıç Limanı production route → Node 1 → Bölüm 1 production game → sonuç/yıldız → rotaya dönüş → progress kaydı → Bölüm 2 unlock`

Bu döngü önce Word Hunt modülü içinde production-safe ve otomatik test edilebilir olacaktır.

## Korunan alanlar

İlk gameplay PR'ında açık onay olmadan değişmez:

- `lib/main.dart`
- `assets/questions.json`
- BoardMap / 67 node / 3B tahta
- AdMob/Firebase/Android release/signing config
- package name
- `version: 1.68.19+109`
- Başlangıç Limanı MASTER ART production rota mimarisi

## Bundan sonraki sıra

1. Bölüm 1 içerik/grid QA ve kesin seçim koordinatları.
2. Bölüm 1 production UI sözleşmesi.
3. Tam oynanış/edge-case sözleşmesi.
4. Codex kabul testleri/checklist.
5. Codex implementation.
6. Diff/test review + Android 16 production proof.
