# Bilgi Rotası - Güncel Proje Durumu

> 25 Ağustos 2026 aktif kesimidir. PR #147 merge öncesi ayrıntılı durum dosyasının değişmemiş kopyası `docs/project-memory/archive/BILGI_ROTASI_DURUM_PRE_PR147_MERGE_20260825.md` altında korunur. Teknik gerçek her zaman canlı GitHub ve ilgili canlı servislerdir.

## 0T. PR #147 Başlangıç Limanı MASTER ART production merge checkpoint — 25 Ağustos 2026

- Levent gerçek Android 16 production görünümünü ve **MASTER ART raster + şeffaf hitbox** mimarisini daha önce açıkça kabul etti.
- Levent 25 Ağustos 2026'da ayrıca açıkça `Merge et` onayı verdi.
- PR #147 Draft'tan Ready'ye alındı; exact head `4f1e2f60962236990556610f87313dda0b341e8b` değişmeden kilitlendi.
- PR #147 `squash` yöntemi ve `expected_head_sha=4f1e2f60962236990556610f87313dda0b341e8b` ile kontrollü merge edildi.
- Merge SHA: `d118aa98c5551cb3b4418f61047f6a730406d963`.
- Merge mesajı: `fix(kelime-avi): match Baslangic Limani binding master art (#147)`.
- Hedef branch `feat/kelime-avi-baslangic-limani-asset-first-20260824` merge sonrası canlı HEAD olarak `d118aa98c5551cb3b4418f61047f6a730406d963` değerine ilerledi.
- GitHub PR #147 canlı metadata: `CLOSED / MERGED`; `merged_at=2026-08-25T12:31:03Z`.
- Merge commit GitHub tarafından doğrulanmış imzalı commit olarak kaydedildi ve parent `1968c4bccd22468bec50f2188414a3e5f6f3fa4b` → tree `d78905a980c2e9928e2bc9de51eb2d825a81d293` biçimindedir.

### Merge edilen ürün sözleşmesi

- Issue #109 `Photo 1.jpg` Başlangıç Limanı için tek bağlayıcı MASTER ART'tır.
- Production `WordHuntReferenceRouteScreen` MASTER ART raster görünür taban + şeffaf hitbox mimarisini kullanır.
- Node 9 normal/open'dır; 7 tamamlanınca 8 + 9 açılır; 9 gerçek callback üretir.
- Final 10, node 9 tamamlanmadan locked ve callback üretmez.
- MASTER ART görünür node/route/plaque/kontrol sanatı ikinci kez Flutter katmanı olarak çizilmez; yalnız gerekli state farkı minimum override alır.

### Merge öncesi exact-head kanıtı

Exact PR head `4f1e2f60962236990556610f87313dda0b341e8b`:

- Production Android 16 run `32781169538`: SUCCESS; artifact `9540046796`; digest `sha256:e567f5e1b2681aa4fbab6ed4977c12f1aa78973fbf06dacf88ff4621680165bf`.
- Pixel-proof Android 16 run `32781169568`: SUCCESS; artifact `9540079789`; digest `sha256:c6619bc468b6c90edcfb69e2b19798b762ec031cdc54e2515f2602f46b385b16`.
- Focused Kelime Avı suite: `110/110 PASS`.
- `dart analyze lib/word_hunt`: `No issues found`.
- `git diff --check`: PASS.
- Runtime: `PRODUCTION_ROUTE_RENDER=PASS`, `NODE_9_UNLOCKED_AND_CALLBACK=PASS`, `NODE_10_LOCKED_NO_CALLBACK=PASS`, `APP_PROCESS_FAILURE_SCAN=PASS`.
- App crash/ANR/FATAL/process-death: 0.

Merge SHA `d118aa98...` aynı onaylı tree'yi taşır. Merge anındaki canlı sorguda bu yeni squash SHA üzerinde ayrıca check-run yoktu; pre-merge exact-head kanıtı merge edilen tree'nin doğrudan kanıtıdır.

**Durum:** PR #147 MERGED / VISUAL PASS / ARCHITECTURE PASS / ANDROID 16 PASS.

---

## 0U. PR #132 Başlangıç Limanı asset-first pilot final entegrasyon kapısı

- PR #132: `feat(kelime-avi): start Baslangic Limani asset-first production pilot`.
- Durum: `OPEN / DRAFT / MERGEABLE / MERGED=false`.
- Base: `fix/kelime-avi-approved-reference-pixel-match-20260823` / `bc8a03bfefd401570e0c51cc4aab4206ea45d363`.
- Head: `feat/kelime-avi-baslangic-limani-asset-first-20260824` / `d118aa98c5551cb3b4418f61047f6a730406d963`.
- PR #132 body eski asset-first ara durumunu içeriyor olabilir; güncel teknik gerçek canlı HEAD/diff ve bu checkpoint'tir.
- PR #132 için Levent'ten ayrı açık merge onayı alınmadan Ready/merge yapılmaz.

**Durum:** AÇIK / AYRI REVIEW + AYRI MERGE ONAYI GEREKİYOR.

---

## 0V. Kelime Avı production ana navigasyon entegrasyonu

- `lib/main.dart` PR #147 kapsamında değiştirilmedi.
- Başlangıç Limanı production route ekranının gerçek uygulama girişine bağlanması ayrı görevdir.
- Release/main, AdMob/Firebase, BoardMap/67 node/3B ve `assets/questions.json` bu entegrasyon uğruna kontrolsüz değiştirilemez.

**Durum:** AÇIK / AYRI BRANCH + TEST + PR + ONAY GEREKİYOR.

---

## Korunan diğer açık alanlar

- Soru geri bildirimleri: gerçek düzeltme merge edilmeden Sheet satırı kapanmaz; metin + 4 seçenek + doğru indeks + açıklama + kategori + zorluk birlikte doğrulanır.
- Rewarded/SSV canlı no-double, başarısız reklamda hak/retry ve farklı oyunlarda toplam kota olmaması fiziksel kabul maddeleri.
- Play/Firebase signing SHA rol eşlemesi ve canlı production/Play kabul maddeleri.
- İki cihaz Canlı Düello uçtan uca fiziksel kabulü.
- 3B tahta: BoardMap/67 node korunur; 8 konsept rozet / 6 fiziksel rozet eşlemesi çözülmeden ilerlenmez.
- Mağaza/tanıtım varlıklarının canlı Play Console durumu.
