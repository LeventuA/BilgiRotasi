# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 30 Ağustos 2026 — Başlangıç Limanı 8×8 teknik hattı PASS. Seçilen bölüm içi tema (derin lacivert gece limanı + sıcak altın/amber deniz feneri) de Android 16 teknik runtime gate'ini geçti: run `33278797412` SUCCESS; B1 ve B10 build/install/launch, screenshot, UI XML, logcat ve crash/ANR taraması PASS. **Kalan ana kapı kullanıcı görsel kabulüdür.** Gerçek screenshotlarda okunabilirlik iyi, ancak fener/amber atmosferi oldukça hafif; kullanıcı kabul etmeden tema görsel PASS sayılmaz. PR #158 OPEN/DRAFT; theme PR yok; Ready/merge yok.

> Teknik doğrulukta tek kanonik kaynak canlı `ZMilaStudio/BilgiRotasi` deposu ve ilgili canlı servislerdir. Bu dosya canlı branch/PR/CI/pubspec doğrulamasının yerine geçmez. Eski ayrıntılı checkpointler Git geçmişi ve `docs/project-memory/archive/` altında korunur.

## Kalıcı çalışma kuralı

- Her görev başında `BILGI_ROTASI_DURUM.md`, ilgili `KARARLAR.md`, `GOREV_HAVUZU.md` ve canlı GitHub durumu okunur.
- `main` güncel yayın kaynağı varsayılmaz.
- Doğrudan main/release'e yazılmaz; branch → test → commit → push → PR → inceleme → merge sırası korunur.
- Kritik merge yalnız Levent'in açık onayıyla yapılır.
- Build PASS tek başına kanıt değildir; log + diff + workflow + Git geçmişi + runtime birlikte değerlendirilir.
- `assets/questions.json` kontrolsüz değiştirilmez.
- Doğrulanmayan bilgi `DOĞRULANACAK` olarak işaretlenir.

## Canlı release hattı

- Repo: `ZMilaStudio/BilgiRotasi`
- Kanonik release branch: `release/final-closed-test-aab-1.68.8`
- Release HEAD: `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`
- Sürüm: `1.68.19+109`
- Paket: `com.leventua.bilgirotasi`

## MASTER ART / rota sözleşmesi

`MASTER ART RASTER → TRANSPARENT INTERACTION HITBOXES → MINIMUM LOCAL STATE OVERRIDES`

- Issue #109 `Photo 1.jpg` Başlangıç Limanı rota ekranı için tek bağlayıcı görsel kaynak.
- MASTER ART / route geometry mevcut 8×8 ve bölüm içi tema çalışmalarında değiştirilmez.
- BoardMap / 67 node ve 3B tahta kapsamı kapalıdır.

## Başlangıç Limanı 8×8 — AKTİF ÜRÜN STANDARDI

29 Ağustos 2026 kullanıcı kararı:
- Bölüm 1–10: **8 satır × 8 sütun**.
- 6×10 superseded, tarihsel kanıt olarak korunur.
- 10 bölüm / 30 yıldız / toplam 80 target+bonus kelime.
- Her canonical kelime 8 düz yönde exactly-one physical occurrence taşır.
- Intended/opposite gesture aynı canonical kelimeye döner.
- B5/B10 yön çeşitliliği, B8 `HIZ`+`SKOR`, B9 `ROKET`, B10 `YOL`+`HAZİNE` sözleşmeleri korunur.
- B5/B10 süreleri soft challenge: 60 / 120 saniye.

Git/CI:
- Branch `feat/kelime-avi-8x8-content-v1-20260829`.
- Ürün commit `052ea7da775db0b58a5ce0c6731a04f251879008`.
- Final run `33251736068`: SUCCESS.
- Focused Word Hunt 37/37; full Flutter 442/442 PASS.
- Android16 B1/B5/B8/B10 64/64 görünürlük; B5 soft-time; gerçek ANKARA ve ters BAŞKENT swipe; crash/ANR taraması PASS.
- Artifact `9714700778`, digest `sha256:dfbca264c2f67bb3549a0e336b075c9238f1a0638962dc69392ea8715b9a2092`.

PR #158:
- `WIP feat(kelime-avi): Başlangıç Limanı 8x8 production content`
- Base `release/final-closed-test-aab-1.68.8`.
- Head `feat/kelime-avi-8x8-content-v1-20260829`.
- **OPEN / DRAFT / merged=false**.
- Kullanıcı kabulünden önce Ready yok; merge yalnız ayrıca açık onayla.

Eski PR #156 6×10 tarihsel hatta OPEN/DRAFT kalır; otomatik kapatılmaz.

## Başlangıç Limanı bölüm içi tema — TEKNİK RUNTIME PASS

Kullanıcı beş özgün aday arasından **1. görseli** seçti.

Bağlayıcı görsel yön:
- derin lacivert gece limanı,
- sıcak altın/amber deniz feneri ışığı,
- Bölüm 1–10 aynı ana kimlik,
- yalnız bölüm içi gameplay; MASTER ART rota ekranı değişmez.

Clean theme hattı:
- Branch `feat/kelime-avi-baslangic-limani-theme-clean-v1-20260829`.
- Doğrulanmış tema ürün SHA `a91236c9f734e9495e67de46ab6e078d429d681e`.
- `lib/word_hunt/baslangic_limani_theme_screen.dart` mevcut `WordHuntLevelProductionScreen`'i sarar.
- Overlay `IgnorePointer`; gesture hit-testing korunur.
- `word_hunt_gameplay_flow.dart` varsayılan level açılışını temalı wrapper'a yönlendirir.
- `word_hunt_screens.dart`, path/models, 8×8 içerik, `lib/main.dart`, MASTER ART, Firebase/AdMob/signing/version değişmedi.
- Tema widget + production-flow testleri vardır.

Tarihsel altyapı runları:
- `33260968009`: formatter'da erken failure.
- `33274405539`: `/usr/bin/sh` + `pipefail` failure.
- `33277364738`: multi-line runner scriptinin satır satır `sh -c` yürütülmesi nedeniyle failure.
Bu runlar ürün runtime failure değildir.

### Final V4 tema runtime kanıtı

- Trigger SHA `4671a3989155b801c9da6b7d0ec7a7e1a545d465`.
- Run `33278797412` — **SUCCESS**.
- Job `99170289209`.
- Formatter 4 dosya / 0 changed.
- `dart analyze lib/word_hunt`: No issues.
- Tema testleri 2/2 PASS.
- QA entrypoint analyze PASS.
- B1/B10 debug APK build/install/launch PASS.
- Android16 API36 / 1080×1920 / 420 dpi PASS.
- B1: `Bölüm 1`, `0/5`, `0 hata`, 64/64 hücre.
- B10: `Bölüm 10`, `0/9`, `0 hata`, 64/64 hücre.
- B1/B10 screenshot + UI XML + logcat üretildi.
- Crash/ANR/FATAL/am_crash eşleşmesi yok.
- Artifact `9722440135`.
- Digest `sha256:bf91d7591b4348b3268983f9938a9042631729b8ad7a126c27e6ba35504f3a70`.
- B1 APK SHA-256 `6ea5295ccb1cd27021d75ca7a7e781b867ca88697c57f80b0fbfac3f2174cad2`.
- B10 APK SHA-256 `d3979a967d6213f54680fb4ca3eb8300da7757730f07bde6df9ca515a7428005`.

V4 temporary workflow `[skip ci]` ile silindi; temizlik commit `7c9aa6c6e0468c381e9d22cac700f8a399c5e6f0`.

### Görsel kabul durumu

Teknik okunabilirlik PASS: grid ve metinlerde görünür kırpılma/overflow yok. Ancak gerçek B1/B10 screenshotlarında deniz-feneri/amber atmosferi **çok hafif**; görünüm ağırlıklı olarak temiz koyu lacivert oyun UI'sı. Bu nedenle görsel tema kabulü yalnız Levent'in kararıyla kapanır.

## Korunan alanlar

Açık kapsam olmadan değiştirilmez:
- `lib/main.dart`
- `pubspec.yaml`
- `assets/questions.json`
- `assets/word_hunt` / MASTER ART
- `word_hunt_screens.dart`, `word_hunt_path.dart`, `word_hunt_models.dart`
- BoardMap / 67 node / 3B tahta
- AdMob / Firebase / Android release-signing
- package/version

## Sonraki sıra

1. Gerçek Android16 B1/B10 tema screenshotlarını Levent değerlendirir.
2. Kabul edilirse theme Draft PR açılır; kabul edilmezse yalnız tema atmosferi/ışık yoğunluğu ayarlanır, grid/oyun mantığına dokunulmaz.
3. B5/B10 gerçek insan süre dengesi playtesti yapılır.
4. PR #158 için Ready kararı ayrıca alınır.
5. Merge yalnız Levent'in açık onayıyla yapılır.
6. `lib/main.dart` production ana navigasyon entegrasyonu ayrı branch/PR kapsamıdır.
