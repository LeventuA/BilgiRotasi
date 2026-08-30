# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 29 Ağustos 2026 — Kelime Avı Başlangıç Limanı **8×8** ürün hattı final teknik gate'i PASS. Temiz ürün commit `052ea7da775db0b58a5ce0c6731a04f251879008`; final run `33251736068` SUCCESS; Dart analyze PASS, focused Word Hunt 37/37, full Flutter 442/442, Android 16 B1/B5/B8/B10 64/64 hücre, B5 soft-time + ANKARA + ters BAŞKENT gesture PASS, crash taraması temiz. Draft PR #158 açıldı ve mergeable=true. Kalan kapı kullanıcı gerçek görünüm/oynanış kabulü + B5/B10 insan süre dengesi. Ready/merge yok.

> Teknik doğrulukta tek kanonik kaynak canlı `ZMilaStudio/BilgiRotasi` deposu ve ilgili canlı servislerdir. Bu dosya canlı branch/PR/CI/pubspec doğrulamasının yerine geçmez. Eski ayrıntılı checkpointler Git geçmişi ve `docs/project-memory/archive/` altında korunur.

## Kalıcı çalışma kuralı

- Yeni sohbet başında önce bu dosya okunur.
- Ardından `BILGI_ROTASI_DURUM.md`, ilgili `KARARLAR.md`, `GOREV_HAVUZU.md` ve gerektiğinde `ACIK_SORULAR_VE_DOGRULAMALAR.md` okunur.
- Her görev öncesi canlı hedef branch, `pubspec.yaml`, son commit, PR ve CI yeniden doğrulanır.
- `main` güncel yayın kaynağı varsayılmaz.
- Doğrudan main/release'e yazılmaz; branch → test → commit → push → PR → inceleme → merge sırası korunur.
- Kritik merge yalnız Levent'in açık onayıyla yapılır.
- Build PASS tek başına çalışma kanıtı değildir; log + workflow + diff + Git geçmişi + gerçek runtime kanıtı birlikte incelenir.
- `assets/questions.json` kontrolsüz değiştirilmez.
- İlgisiz değişiklikler silinmez; `git reset --hard` rutin çözüm değildir.
- Doğrulanmayan bilgi `DOĞRULANACAK` yazılır.

## Canlı release hattı

- Repo: `ZMilaStudio/BilgiRotasi`
- Kanonik release branch: `release/final-closed-test-aab-1.68.8`
- Release HEAD: `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`
- Sürüm: `1.68.19+109`
- Paket: `com.leventua.bilgirotasi`
- PR #155 Bölüm 1 production gameplay release'e merge edildi; release HEAD aynı merge commitidir.

## Başlangıç Limanı bağlayıcı görsel/mimari

`MASTER ART RASTER → TRANSPARENT INTERACTION HITBOXES → MINIMUM LOCAL STATE OVERRIDES`

- Issue #109 `Photo 1.jpg` tek bağlayıcı görsel kaynak.
- Repo MASTER ART: `assets/word_hunt/baslangic_limani_master_art_visual_proof.jpg`.
- MASTER ART / route geometry mevcut 8×8 starter-content dönüşümünde değiştirilmez.
- Route progression: 7 tamamlanınca 8+9 açılır; bonus 8 gate değildir; 10, node 9 tamamlanmadan locked/no-callback.

## AKTİF ÜRÜN KARARI — Başlangıç Limanı 8×8

29 Ağustos 2026 kullanıcı kararı:
- Tüm 10 bölüm **8 satır × 8 sütun**.
- Önceki 6×10 starter-content geometrisi superseded; geçmiş teknik kanıt olarak korunur.
- 10 bölüm / 30 yıldız / 80 toplam target+bonus kelime eğrisi değişmez.

Kelime yoğunluğu:
- B1 5+1 = 6
- B2 5+1 = 6
- B3 6+1 = 7
- B4 6+1 = 7
- B5 7+1 = 8
- B6 7+1 = 8
- B7 8+1 = 9
- B8 7+2 = 9
- B9 9+1 = 10
- B10 9+1 = 10

İçerik sözleşmesi:
- Her target/bonus en az 3 harf.
- Her target/bonus 8 düz yönde **exactly one physical occurrence**.
- Intended ve opposite gesture aynı canonical kelimeye dönmeli.
- B5/B10 yatay+dikey+çapraz yön ailelerini birlikte taşır.
- B8 bonusları `HIZ` + `SKOR`.
- B9 `ROKET` bonus; `AY` yok.
- B10 `YOL` hedef, `HAZİNE` bonus; `ROTA` yok.
- B5 süre/yıldız eşikleri 60 / 50 / 35 saniye.
- B10 süre/yıldız eşikleri 120 / 100 / 75 saniye.

## 8×8 Git hattı

- Branch: `feat/kelime-avi-8x8-content-v1-20260829`
- Eski 6×10 ürün kaynağı başlangıç SHA: `0e9408ddda511259f588a338b3fcd8192bf92431`
- Final gate workflow commit: `4424285066568ddac874cfa35eb3bae1a62b3394`
- Temiz ürün commit: `052ea7da775db0b58a5ce0c6731a04f251879008`
- Commit adı: `feat(kelime-avi): switch starter levels to 8x8 [skip ci]`

Ürün commitinde QA-only `word_hunt_8x8_qa_main.dart` ve geçici helper dosyaları yoktur. Gate açık allowlist ile yalnız starter content + ilgili testleri stage etti; geçici workflow/payload dosyaları aynı committe temizlendi.

## Final 8×8 teknik gate — PASS

İlk run:
- `33250841637`: FAILURE.
- Yalnız formatter kapısında durdu; analyze/test/APK/Android16 çalışmadı.
- Ürün logic/layout failure sayılmaz.
- Ayrıca broad stage mantığında QA-only entrypoint scope riski yakalandı.

Düzeltilmiş final run:
- Run `33251736068`
- Job `99098467708`
- Gate HEAD `4424285066568ddac874cfa35eb3bae1a62b3394`
- Sonuç: **SUCCESS**

Kanıt:
- Payload decode SHA-256 `7e4955d6f2545039eafb3e476e5537385ee3d3b359b67be0f886b027ea95be54`.
- Dart formatter PASS.
- `dart analyze lib/word_hunt`: **No issues found**.
- Focused Word Hunt suite: **37/37 PASS**.
- Full Flutter suite: **442/442 PASS**.
- `git diff --check`: PASS.
- Korunan scope gate: PASS.
- Isolated Android16 debug QA APK build: PASS.
- QA APK SHA-256 `d07a68b5f9735f574e8e608afbd4c20d4c1f7cc0c775d5d9f8d0010dfd32c07b`.

## Android 16 8×8 gerçek runtime/gesture — PASS

API 36 / 1080×1920 / 420 dpi:
- B1: 64/64 görünür hücre, `0/5`.
- B5: 64/64 görünür hücre, `0/7`.
- B8: 64/64 görünür hücre, `0/7`.
- B10: 64/64 görünür hücre, `0/9`.
- 8×8 grid artık ilk viewportta komple görünür; 6×10 checkpointteki scroll gereksinimi yeni geometri için yok.
- B5 sentetik +65 saniyede hard fail yok; ekran 67–76 saniyede oynanabilir kaldı.
- Gerçek uzun çapraz ANKARA swipe: `1/7`, seçili hücreler doğru, `Bilgi kartı açıldı: Ankara`.
- Gerçek ters-dikey BAŞKENT swipe: `1/7`, doğru 7 hücre, `BAŞKENT bulundu!`.
- `FATAL EXCEPTION`, app ANR veya `am_crash` eşleşmesi yok.

Artifact:
- ID `9714700778`
- Digest `sha256:dfbca264c2f67bb3549a0e336b075c9238f1a0638962dc69392ea8715b9a2092`
- 21 kanıt dosyası: B1/B5/B8/B10 screenshot+UI XML, ANKARA/BAŞKENT gesture screenshot/XML, LOGCAT, display bilgisi ve hashler.
- Artifact görselleri ayrıca manuel incelendi; grid/etiket taşması veya kırpılma görülmedi.

## PR #158 — AKTİF 8×8 / DRAFT

- URL: `https://github.com/ZMilaStudio/BilgiRotasi/pull/158`
- Başlık: `WIP feat(kelime-avi): Başlangıç Limanı 8x8 production content`
- Base: `release/final-closed-test-aab-1.68.8`
- Head: `feat/kelime-avi-8x8-content-v1-20260829`
- Açılış ürün head: `052ea7da775db0b58a5ce0c6731a04f251879008`
- Son kontrolde: **OPEN / DRAFT / merged=false / mergeable=true**.
- PR yalnız teknik gate sonrası açıldı.
- Kullanıcı görsel/oynanış kabulünden önce Ready yapılmaz.
- Merge yalnız Levent'in ayrıca açık merge onayıyla yapılır.

## PR #156 — TARİHSEL 6×10 / DRAFT

- Eski 6×10 branch: `feat/kelime-avi-content-pass-v1-20260828`
- Head `0e9408ddda511259f588a338b3fcd8192bf92431`.
- OPEN/DRAFT kalır; otomatik kapatılmadı.
- 8×8 kararı nedeniyle yeni ürün merge kaynağı PR #158'dir.

## Tarihsel 6×10 teknik checkpoint

28 Ağustos 6×10 ürün hattı teknik olarak PASS idi ve geçmiş kanıt olarak korunur:
- gameplay/UI commit `8d431826585eb6c52248e85bb3ac2e80fc89bb9f`
- Word Hunt suite 136/136 PASS
- final Android16 QA run `33202898863` SUCCESS
- B5 uzun çapraz ANKARA + ters-dikey BAŞKENT PASS
- soft-time PASS

Bu kanıt 8×8 runtime kabulü yerine kullanılmadı; 8×8 ayrı final gate ile yeniden doğrulandı.

## Korunan alanlar

8×8 ürün dönüşümü açık kapsam olmadan değiştirmez:
- `lib/main.dart`
- `pubspec.yaml`
- `assets/questions.json`
- `assets/word_hunt` / MASTER ART
- `word_hunt_path.dart`
- `word_hunt_models.dart`
- BoardMap / 67 node / 3B tahta
- AdMob / Firebase / Android release-signing config
- package name / version

`word_hunt_screens.dart` PR #158 diffinde görünür, ancak bu değişiklik yeni 8×8 ürün commitinden değil, branch'in devraldığı önceki gameplay/bonus/soft-time hattından gelir; final 8×8 product commit bu dosyaya dokunmadı.

## Kalan aktif sıra — YENİ SOHBET BURADAN DEVAM ETSİN

1. Her görev başında release, 8×8 branch HEAD, `pubspec.yaml` ve PR #158 canlı durumunu yeniden doğrula.
2. Teknik 8×8 gate tamamlandı; yeni belirti yoksa körlemesine yeni QA run üretme.
3. Kullanıcıya gerçek Android16 B1/B5/B8/B10 ve B5 ANKARA/BAŞKENT kanıtlarını göstererek **görsel/oynanış kabulü** al.
4. B5 60s ve B10 120s challenge sürelerini gerçek insan playtestinde değerlendir; teknik soft-time PASS ile zorluk dengesi aynı şey değildir.
5. Kullanıcı kabulünden önce PR #158 Ready yapma.
6. Merge ancak Levent'in açık merge onayıyla yapılır.
7. Eski PR #156 otomatik kapatılmaz; kapatma kararı ayrı alınır.
8. Production `lib/main.dart` ana navigasyon entegrasyonu ayrı kapsam/branch/PR işidir.

Diğer Bilgi Rotası açık işleri `GOREV_HAVUZU.md` ve `ACIK_SORULAR_VE_DOGRULAMALAR.md` içinde korunur.

## 30 Ağustos 2026 — Kelime Avı V5 gameplay görsel teması

- Aktif ürün hattı `feat/kelime-avi-8x8-content-v1-20260829` / Draft PR #158 üzerinde ilerler.
- Başlangıç Limanı gameplay ekranının bağlayıcı görsel dili, kullanıcının 30 Ağustos 2026 gece limanı referansıdır: koyu lacivert deniz/liman, sıcak altın ışık, bronz-altın plakalar ve premium macera hissi.
- Görsel referanstaki 6×10 geometri alınmadı; canonical ürün geometrisi ve içerik sözleşmesi **8×8 / 64 hücre** olarak korundu.
- Mevcut production gameplay widget'ı sunum katmanında güncellendi; engine, gesture, timer, hata, bonus, scoring, result ve progression davranışları değiştirilmedi.
- Temiz `assets/word_hunt/baslangic_limani_bg.jpg` sahne/çevre arka planı kullanıldı; referans screenshot production UI'a gömülmedi ve yeni dependency eklenmedi.
- B1/B5/B8/B10 için 64/64 hücrenin dar 411×731 mantıksal viewport içinde kalması widget testiyle kilitlendi.
- Gerçek Android 16 ekran görüntüsü bu checkpointte mevcut değildir; yerel Android SDK/emülatör yoktur ve kullanıcı yeni manuel Actions dispatch'ini yasaklamıştır. Görsel kabul bu nedenle **DOĞRULANACAK** durumundadır.
