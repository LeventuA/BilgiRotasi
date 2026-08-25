# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 25 Ağustos 2026 (Europe/Istanbul)

> Bu dosya yeni bir sohbeti hızlı ve güvenli biçimde başlatmak için yaşayan devir özetidir. Teknik doğrulukta tek kanonik kaynak canlı `ZMilaStudio/BilgiRotasi` GitHub deposu ve ilgili canlı servislerdir. Bu özet canlı repo doğrulamasının yerine geçmez.

## 1. Kalıcı çalışma kuralı

- Her Bilgi Rotası / Kelime Avı çalışmasında önce canlı repo, hedef branch, `pubspec.yaml`, son commit ve açık PR durumu doğrulanır.
- `main` güncel varsayılmaz.
- Doğrudan `main` veya release dalına yazılmaz; ayrı branch kullanılır.
- Sıra: test → commit → push → PR → inceleme → merge.
- Kritik merge için Levent'in açık onayı gerekir.
- Teknik PASS görsel PASS değildir.
- `assets/questions.json`, BoardMap/67 node/3B, production `lib/main.dart`, Firebase/AdMob/Android/release config kontrolsüz değiştirilmez.
- Bu dosya yalnız gerekli farklarla güncellenir; kritik geçmiş ve kararlar korunur.

## 2. Canlı Kelime Avı teknik durumu

- Repo: `ZMilaStudio/BilgiRotasi`
- Kanonik release branch: `release/final-closed-test-aab-1.68.8`
- Kelime Avı güncel çalışma sürümü: `1.68.19+109`
- Paket: `com.leventua.bilgirotasi`
- `main` HEAD: `f42ba228bd7c38b0a00448a19f43d762058e4319` — `ci: add weekly Dependabot updates (#113)`.
- `main/pubspec.yaml` sürümü eski hatta `1.68.6+96`; Kelime Avı için çalışma kaynağı değildir.

### 25 Ağustos — MASTER ART production kabul checkpoint'i

- Aktif branch: `fix/kelime-avi-baslangic-limani-master-art-codex-20260824`.
- Draft PR: `#147` — `fix(kelime-avi): match Baslangic Limani binding master art`.
- PR base: `feat/kelime-avi-baslangic-limani-asset-first-20260824` / exact base SHA `1968c4bccd22468bec50f2188414a3e5f6f3fa4b`.
- Güncel doğrulanmış production commit / PR HEAD: `0ebd1212d7e66f809705c9c3d2711dd63141f4d7` — `fix(kelime-avi): use approved master art in production route`.
- Node 9 progression commit'i `e34832bde06f8318833f8a4373d0aa43ba71141a` korunur: 7 tamamlandığında 8 + normal/open 9 açılır; 9 gerçek callback üretir; final 10 node 9 tamamlanmadan kilitli/etkileşimsiz kalır.
- Issue #109 `Photo 1.jpg` tek bağlayıcı MASTER ART'tır. PR #146 / run `32740827443` ve ona ait ChatGPT-generated asset denemeleri **REJECTED BY LEVENT — NOT A VISUAL SOURCE**.
- Production `WordHuntReferenceRouteScreen`, Levent'in açık onayıyla MASTER ART raster sahneyi görünür taban olarak kullanır. Level 1–10, geri, bilgi, pusula ve kitap davranışları şeffaf hitbox'larla gerçek gameplay/progression callback'lerine bağlanır.
- MASTER ART'taki rota/node/plaque/panel/crown/alt kontroller ikinci kez görünür Flutter katmanı olarak çizilmez. Yalnız state gerçekten MASTER ART'tan farklı olduğunda minimum override kullanılır; node 9 open override mevcut örnektir.
- Bu mimari **Levent tarafından açıkça kabul edildi**: `MASTER ART raster + şeffaf hitbox` Başlangıç Limanı production standardıdır. Bu kabul PR #147 için merge onayı değildir.
- Focused Kelime Avı suite: **110/110 PASS**. `dart analyze lib/word_hunt`: **No issues found**. `git diff --check`: PASS.
- Production Android 16 run/job `32778145314` / `97593889745`: **SUCCESS**. Artifact ID `9539030303`, digest `sha256:a38a1cae778a32f232b266571c249ae3ca710ab7598119fb666af574e9e503f3`, APK SHA-256 `99c945aefeabfa58b15f3b17d4f17b04ad709f4bc233f5239894bc4222ec9429`.
- Pixel-proof Android 16 run/job `32778145292` / `97593889800`: **SUCCESS**. Artifact ID `9539028131`, digest `sha256:9794a1d5a3a1b94d5c030a879ae08f82dec9fa29abdabf5ad2742672a41d4b81`.
- Production ve pixel-proof Android screenshot'ları byte düzeyinde aynı: SHA-256 `7fc42a56c15501785da02854f62e31041b1ead77869146f1a1cd64096e13bfcb`.
- Runtime kapıları: `PRODUCTION_ROUTE_RENDER=PASS`, `NODE_9_UNLOCKED_AND_CALLBACK=PASS`, `NODE_10_LOCKED_NO_CALLBACK=PASS`, `APP_PROCESS_FAILURE_SCAN=PASS`; app-specific crash/ANR/FATAL/process-death = 0.
- PR #147 canlı durumda **OPEN / DRAFT / MERGEABLE / CLEAN / MERGE YOK**. Ready/merge için ayrıca açık Levent onayı gerekir.

### PR #110 — Başlangıç Limanı mevcut teknik çekirdeği

- PR: `#110` — `feat(kelime-avi): pixel-match approved Baslangic Limani reference`
- Branch: `fix/kelime-avi-approved-reference-pixel-match-20260823`
- Güncel HEAD: `bc8a03bfefd401570e0c51cc4aab4206ea45d363`
- Durum: **OPEN / DRAFT / MERGE YOK**
- Sürüm: `1.68.19+109`
- Korunacak kazanımlar: Flutter + Dart, 1080×1920 canonical coordinate-space, tek scene transform, 1–10 deterministik koordinatlar, route control point'leri, progression/unlock, interaction ve regresyon testleri.
- Eski 77/77 focused ve Android 16 kanıtı `5523caf...` product head'ine aittir; güncel `bc8a03bf...` HEAD için kör biçimde yeniden kullanılamaz.

### PR #131 — bağlayıcı görsel üretim standardı

- PR: `#131` — `docs: add Kelime Avı visual production standard`
- Branch: `docs/visual-game-production-standard`
- HEAD: `1b74bf6ff5c3df2a5aaf50822e889441da56b4e4`
- Durum: **OPEN / DRAFT / MERGE YOK**
- Dosya: `görsel oyun üretimstandartı.md`
- Genel asset-first standardı korunur; ancak Başlangıç Limanı özelinde Levent'in 25 Ağustos 2026 tarihli açık kararıyla MASTER ART raster + şeffaf hitbox production mimarisi bağlayıcı istisna/nihai çözümdür.

### PR #132 — Başlangıç Limanı asset-first pilotu

- PR: `#132` — `feat(kelime-avi): start Baslangic Limani asset-first production pilot`
- Base: PR #110 branch'i `fix/kelime-avi-approved-reference-pixel-match-20260823`
- Base exact SHA: `bc8a03bfefd401570e0c51cc4aab4206ea45d363`
- Branch: `feat/kelime-avi-baslangic-limani-asset-first-20260824`
- Bu hat PR #147'nin base'i olarak tarihsel/teknik temel görevi görür; güncel görsel çözüm PR #147 üzerindedir.

## 3. Kelime Avı bağlayıcı görsel üretim standardı

**Genel ana kural:**

`REFERENCE → PRODUCTION-READY VISUAL SOURCE → THIN INTERACTION CODE`

- Onaylı referans görsel MASTER ART / bağlayıcı kalite hedefidir.
- Referans `CustomPainter`, Dart Canvas veya benzeri procedural çizimlerle yaklaşık olarak yeniden üretilmez.
- Motor resmi yapmayacak; resmi oynatacak.
- Placeholder veya düşük kaliteli geçici çizimler final kabul edilmez.

### Başlangıç Limanı için kabul edilen production mimarisi

- Görünür sahnenin ana kaynağı Issue #109 MASTER ART rasterıdır.
- 1080×1920 canonical sahne MASTER ART'ın 720×1280 kaynağını uniform 1.5× ölçekler; crop/zoom/stretch yoktur.
- Level 1–10, geri, bilgi, pusula ve kitap etkileşimleri görünmez hitbox'larla gerçek Flutter callback/progression sistemine bağlanır.
- MASTER ART üzerindeki görünür sanat ikinci kez üstüne çizilmez.
- State farkları yalnız minimum bölgesel override ile çözülür; node 9 normal/open override mevcut bağlayıcı örnektir.
- Bu yaklaşım Başlangıç Limanı için Levent tarafından 25 Ağustos 2026'da açıkça kabul edilmiştir; diğer rotalara otomatik genellenmez.

## 4. Korunacak teknik çekirdek

- `WordHuntProgressSnapshot`
- `WordHuntRouteProgressEngine`
- `WordHuntProgressCodec`
- `WordHuntStarterContent.baslangicLimani`
- canonical 1080×1920 koordinat sözleşmesi
- gerçek progression değerleri
- node 9: 7 sonrası open/callback aktif
- final 10: node 9 tamamlanmadan locked/callback yok
- davranışsal ve regresyon testleri
- `assets/questions.json`, BoardMap/67 node/3B, AdMob/Firebase/Android/release config

## 5. Başlangıç Limanı ürün sözleşmesi

- İlk rota: **Başlangıç Limanı**.
- 10 bölüm, 30 yıldız, 6 Bilgi Kartı.
- 1–4 üst bölgede ferah rota.
- 5 `MEYDAN OKUMA`: merkez-sol, plaque sağında.
- 6 sol geçiş.
- 7 merkez/merkez-sağ.
- 8 `BONUS DURAK`: sağ bölge, plaque sağında.
- 9 normal/open durak solda; bonus 8 zorunlu geçiş kapısı değildir ve 7 tamamlandığında 8 ile birlikte açılır.
- 10 `ROTA FİNALİ`: alt-orta, plaque sağında; node 9 tamamlanana kadar oynanamaz.
- Pusula sol altta, kitap sağ altta.
- Arka plan/görsel sahne: onaylı premium gece limanı MASTER ART.
- Görsel state gerçek progression gerçeğini bozmaz.
- Production `lib/main.dart` ana navigasyon entegrasyonu ayrı açık onay gerektirir.

## 6. Görsel kabul kapısı

Başlangıç Limanı production görünümü için:

1. MASTER ART bağlayıcı referanstır.
2. Android 16 gerçek production route screenshot'ı referansla yan yana incelenmiştir.
3. Production ve pixel-proof screenshot'ları byte düzeyinde aynıdır.
4. Gameplay/progression node 9 ve final 10 runtime kapıları PASS'tir.
5. Teknik testler ve CI PASS'tir.
6. **Levent görseli ve MASTER ART raster + şeffaf hitbox mimarisini açıkça kabul etmiştir.**

**Görsel kabul PASS. Merge onayı hâlâ ayrı açık karardır.**

## 7. Korunan alanlar

Kelime Avı çalışmasında açık onay olmadan dokunulmaz:

- `assets/questions.json`
- production `lib/main.dart`
- BoardMap / 67 node / 3B tahta
- Android / AdMob / Firebase / release config
- release / Play yayın hattı

Progression'da yalnız açıkça onaylanan node 9 sözleşmesi değişmiştir.

## 8. Tarihsel notlar

- PR #96 Kelime Avı foundation hattıdır; açık/Draft kalmıştır.
- PR #98 teknik olarak PASS olsa da resmi referansa uymadığı için görsel olarak reddedilmiştir.
- PR #146 ve ChatGPT-generated 5/10/book denemeleri Levent tarafından açıkça reddedilmiştir; görsel kaynak değildir.
- PR #110 canonical transform ve test kazanımlarıyla ileri teknik temel oluşturdu.
- Direct-extraction/layered yaklaşımın teknik PASS olması görsel kabul sayılmadı; nihai çözüm pixel-proof ile aynı görünümü gerçek production route'a taşıyan `0ebd121...` commit'idir.

## 9. Sıradaki aktif iş

1. PR #147'nin bu mimari-onay proje-hafızası commit'i sonrası canlı HEAD ve CI durumunu yeniden doğrula.
2. PR #147 Draft kalsın; Levent ayrıca açıkça merge/Ready onayı vermeden durumunu değiştirme.
3. Merge kararı verilirse base SHA + exact head + final CI yeniden kilitlenerek kontrollü merge uygulanır.
4. Merge sonrasında hedef production/release entegrasyon yolu ayrıca doğrulanır; `lib/main.dart` ana navigasyon entegrasyonu ayrı açık onay olmadan yapılmaz.
5. Başlangıç Limanı onaylı mimarisi diğer tema/paketlere kör biçimde kopyalanmaz; her rota için referans ve state sözleşmesi ayrı doğrulanır.
