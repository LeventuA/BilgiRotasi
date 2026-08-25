# Bilgi Rotası - Görev Havuzu

> 25 Ağustos 2026 aktif kesimidir. Bu tarihten önceki görev havuzunun tam ve değişmemiş kopyası `docs/project-memory/archive/GOREV_HAVUZU_PRE_20260825.md` altında korunur. Teknik gerçek her zaman canlı GitHub ve ilgili canlı servislerdir.

## 0R - Başlangıç Limanı production MASTER ART mimari kabulü

**Durum:** TAMAMLANDI.

- [x] Issue #109 `Photo 1.jpg` tek bağlayıcı MASTER ART.
- [x] Production `WordHuntReferenceRouteScreen` MASTER ART raster görünür taban kullanıyor.
- [x] Level 1–10, geri, bilgi, pusula ve kitap şeffaf hitbox ile gerçek callback/progression sistemine bağlı.
- [x] Görünür MASTER ART sanatı ikinci kez Flutter katmanı olarak çizilmiyor.
- [x] Node 9 normal/open; 7 sonrası 8 + 9 açılıyor; 9 callback aktif; final 10 node 9 tamamlanana kadar locked/callback yok.
- [x] Focused Kelime Avı `110/110 PASS`.
- [x] `dart analyze lib/word_hunt`: `No issues found`.
- [x] `git diff --check`: PASS.
- [x] Android 16 production/pixel-proof kanıtları PASS.
- [x] Levent görseli ve `MASTER ART raster + şeffaf hitbox` mimarisini açıkça kabul etti.

---

## 0S - PR #147 final merge kapısı

**Durum:** TAMAMLANDI / MERGED.

- [x] Final PR head `4f1e2f60962236990556610f87313dda0b341e8b` canlı GitHub'dan kilitlendi.
- [x] PR merge öncesi `OPEN / DRAFT / MERGEABLE / CLEAN` doğrulandı.
- [x] Docs-head production Android 16 run `32781169538`: SUCCESS.
- [x] Docs-head pixel-proof Android 16 run `32781169568`: SUCCESS.
- [x] Açık review thread yok; submitted review yok.
- [x] Levent ayrıca açıkça `Merge et` onayı verdi.
- [x] PR Ready'ye alındı.
- [x] `expected_head_sha=4f1e2f60962236990556610f87313dda0b341e8b` ile squash merge uygulandı.
- [x] Merge SHA `d118aa98c5551cb3b4418f61047f6a730406d963`.
- [x] Hedef branch `feat/kelime-avi-baslangic-limani-asset-first-20260824` HEAD'i `d118aa98...` olarak yeniden doğrulandı.
- [x] PR #147 canlı metadata `CLOSED / MERGED`.

---

## 0T - PR #132 final entegrasyon kapısı

**Durum:** AÇIK / AYRI REVIEW + AYRI MERGE ONAYI GEREKİYOR.

- PR #132: `feat(kelime-avi): start Baslangic Limani asset-first production pilot`.
- Base: `fix/kelime-avi-approved-reference-pixel-match-20260823` / `bc8a03bfefd401570e0c51cc4aab4206ea45d363`.
- Head: `feat/kelime-avi-baslangic-limani-asset-first-20260824` / `d118aa98c5551cb3b4418f61047f6a730406d963`.
- Canlı durum: `OPEN / DRAFT / MERGEABLE / MERGED=false`.

**Bitti ölçütü:**
- [ ] PR #132 body/diff/Git geçmişi güncel HEAD üzerinden incelenir; bayat ara durum metni teknik gerçek sayılmaz.
- [ ] Merge edilen PR #147 tree'sinin PR #132 net diff'inde istenmeyen kapsam taşımadığı doğrulanır.
- [ ] Gerekli exact-head CI/test kanıtları değerlendirilir; gerekirse fresh kanıt alınır.
- [ ] Levent ayrıca açıkça PR #132 merge onayı verir.
- [ ] Expected-head ile kontrollü merge yapılır.
- [ ] Merge sonrası hedef PR #110 branch HEAD'i doğrulanır.

---

## 0U - Kelime Avı production ana navigasyon entegrasyonu

**Durum:** AÇIK / AYRI KAPSAM + AYRI ONAY GEREKİYOR.

`lib/main.dart` PR #147 kapsamında değiştirilmedi. Başlangıç Limanı production rota ekranının gerçek uygulama navigasyonundan açılması ayrı görevdir.

**Bitti ölçütü:**
- [ ] Levent açık kapsam/onay verir.
- [ ] Canlı hedef branch/release yeniden kilitlenir.
- [ ] Minimum navigation diff ayrı branch/PR üzerinde yapılır.
- [ ] Mevcut giriş, reklam, Firebase, BoardMap/67 node ve diğer oyun modları bozulmaz.
- [ ] Analyze/test/Android gerçek cihaz veya Android 16 kabulü PASS.
- [ ] Ayrı açık merge onayı olmadan merge yapılmaz.

---

## Korunan açık işler

- Soru geri bildirimleri: soru metni + 4 seçenek + doğru indeks + açıklama + kategori + zorluk birlikte doğrulanacak; gerçek düzeltme merge edilmeden Sheet satırı kapatılmayacak.
- Rewarded/SSV fiziksel no-double, başarısız reklamda hak/retry ve farklı oyunlarda toplam kota olmaması canlı kabul maddeleri.
- Play/Firebase signing SHA rol eşlemesi ve canlı production/Play kabul maddeleri.
- İki cihaz Canlı Düello uçtan uca fiziksel kabulü.
- 3B tahta: BoardMap/67 node korunur; 8 konsept rozet / 6 fiziksel rozet eşlemesi çözülmeden ilerlenmez.
- Mağaza/tanıtım varlıklarının canlı Play Console durumu.

## Kaynak koruması

- `assets/questions.json` kontrolsüz değiştirilmez.
- `main` güncel yayın kaynağı varsayılmaz.
- Release/main'e doğrudan yazılmaz.
- Kritik merge için Levent'in açık onayı gerekir.
- Build PASS tek başına çalışma kanıtı değildir.
