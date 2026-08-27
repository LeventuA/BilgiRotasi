# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 27 Ağustos 2026 — Kelime Avı release zinciri kapandı, Bölüm 1 gameplay başladı.

> Teknik doğrulukta tek kanonik kaynak canlı `ZMilaStudio/BilgiRotasi` deposu ve ilgili canlı servislerdir. Bu dosya canlı branch/PR/CI/pubspec doğrulamasının yerine geçmez.

## Kalıcı çalışma kuralı

- Yeni sohbet başında önce bu dosya okunur.
- Kelime Avı çalışmasında hemen ardından `docs/project-memory/checkpoints/KELIME_AVI_RELEASE_TO_GAMEPLAY_20260827.md` okunur.
- Ardından `BILGI_ROTASI_DURUM.md`, `KARARLAR.md`, `GOREV_HAVUZU.md` ve gerekiyorsa `ACIK_SORULAR_VE_DOGRULAMALAR.md` okunur.
- Bu eski aktif dosyalarda PR #132/#96 zincirini hâlâ açık gösteren satırlar tarihsel kayıttır; Kelime Avı için 27 Ağustos checkpoint'i supersede eder.
- Her görev öncesi canlı hedef branch, `pubspec.yaml`, son commit, ilgili PR ve CI yeniden doğrulanır.
- Doğrudan `main` veya release dalına kod yazılmaz; branch/PR kullanılır.
- Kritik merge için Levent'in açık onayı gerekir.
- Build/CI PASS tek başına görsel veya ürün kabulü değildir.
- Önemli geçmiş `docs/project-memory/archive/`, checkpoint'ler ve Git geçmişinde korunur.

## Canlı release hattı

- Repo: `ZMilaStudio/BilgiRotasi`
- Kanonik release: `release/final-closed-test-aab-1.68.8`
- Release HEAD: `0350e0ae9cbe9ec3eda275a983c9cbc17483baf3`
- Release tree: `a082ce673a682dc81adfdfc7c5975b80ccc2165a`
- Sürüm: `1.68.19+109`
- Paket: `com.leventua.bilgirotasi`
- `main` yayın kaynağı olarak varsayılmaz.

## Kelime Avı — release zinciri TAMAMLANDI

- PR #147 → MASTER ART production route.
- PR #150 → dynamic progression görünür state.
- PR #132 → merged.
- PR #110 → merged.
- PR #107 → merged.
- Eski PR #96 → `SUPERSEDED / CLOSED / UNMERGED`.
- Temiz current-release entegrasyonu PR #153 üzerinden yapıldı.
- PR #153 release'e merge edildi: `0350e0ae9cbe9ec3eda275a983c9cbc17483baf3`.
- Geçici QA PR #154 kapatıldı ve merge edilmedi.

Final release-context kanıtları:
- Kelime Avı Android 16 run `33000456233`: SUCCESS.
- Artifact `9618632032`.
- AdMob/release run `33000456242`: SUCCESS.
- Analyze/tüm testler/release APK/package-manifest/Android 16 cold-start/app gate: PASS.
- Android 16 visual QA: PASS.

## Başlangıç Limanı bağlayıcı mimari

`MASTER ART RASTER → TRANSPARENT INTERACTION HITBOXES → MINIMUM LOCAL STATE OVERRIDES`

- Issue #109 `Photo 1.jpg` tek bağlayıcı görsel kaynak.
- Repo MASTER ART: `assets/word_hunt/baslangic_limani_master_art_visual_proof.jpg`.
- PR #146 / `c42a9ff...` ve eski ChatGPT-generated hedef asset'ler görsel kaynak değildir.
- Gerçek `X/30`, level 1–10 yıldız ve locked/open state runtime progression ile senkrondur.
- Level 7 → 8 + 9 açılır; bonus 8 zorunlu kapı değildir.
- Node 9 callback aktiftir.
- Node 10 node 9 bitmeden locked/no-callback kalır.

## Yeni aktif geliştirme — Bölüm 1 production gameplay

- Branch: `feat/kelime-avi-gameplay-v1-20260826`.
- Branch release `0350e0ae...` üzerinden açıldı.
- Aktif checkpoint: `docs/project-memory/checkpoints/KELIME_AVI_RELEASE_TO_GAMEPLAY_20260827.md`.
- İlk hedef:
  `production route → node 1 → Bölüm 1 oyun → sonuç/yıldız → rotaya dönüş → progress → Bölüm 2 unlock`.
- İlk gameplay adımında production `lib/main.dart` değiştirilmez.

Bölüm 1 canonical veri:
- Grid: `KALEMS / MASALI / ELMALI / BİLGİN / OYUNCU / ROTASI`
- Hedef: `KALEM`, `MASA`
- Bonus: `ELMA`
- 3 yıldız: 0 hata
- 2 yıldız: en fazla 2 hata
- 1 yıldız: bölüm tamamlandı

## Korunan alanlar

Kelime Avı gameplay geliştirmesinde açık kapsam olmadan değişmez:
- `lib/main.dart`
- `assets/questions.json`
- BoardMap / 67 node / 3B tahta
- AdMob / Firebase / Android release/signing config
- package name
- `version: 1.68.19+109`
- kabul edilmiş MASTER ART production rota mimarisi

## Sıradaki aktif sıra

1. Bölüm 1 içerik/grid QA ve kesin seçim koordinatlarını çıkar.
2. Bölüm 1 production UI sözleşmesini kilitle.
3. Tam oynanış ve edge-case sözleşmesini kilitle.
4. Codex kabul testleri/checklist'i hazırla.
5. Codex implementation.
6. GitHub diff/test review + Android 16 production proof.

Diğer Bilgi Rotası açık işleri `BILGI_ROTASI_DURUM.md`, `GOREV_HAVUZU.md` ve `ACIK_SORULAR_VE_DOGRULAMALAR.md` içinde korunur; bu özet onları silmez.
