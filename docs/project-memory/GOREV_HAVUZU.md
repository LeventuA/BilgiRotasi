# Bilgi Rotası - Görev Havuzu

> 26 Ağustos 2026 aktif kesimidir. Bu tarihten önceki görev havuzunun tam ve değişmemiş kopyası `docs/project-memory/archive/GOREV_HAVUZU_PRE_20260825.md` altında korunur. Teknik gerçek her zaman canlı GitHub ve ilgili canlı servislerdir.

## 0R - Başlangıç Limanı production MASTER ART mimari kabulü

**Durum:** TAMAMLANDI.

- [x] Issue #109 `Photo 1.jpg` tek bağlayıcı MASTER ART.
- [x] Production `WordHuntReferenceRouteScreen` MASTER ART raster görünür taban kullanıyor.
- [x] Level 1–10, geri, bilgi, pusula ve kitap şeffaf hitbox ile gerçek callback/progression sistemine bağlı.
- [x] Görünür MASTER ART sanatı ikinci kez komple Flutter katmanı olarak çizilmiyor.
- [x] Node 9 normal/open; 7 sonrası 8 + 9 açılıyor; 9 callback aktif; final 10 node 9 tamamlanana kadar locked/callback yok.
- [x] Levent görseli ve `MASTER ART raster + şeffaf hitbox` mimarisini açıkça kabul etti.

---

## 0S - PR #147 production merge kapısı

**Durum:** TAMAMLANDI / MERGED.

- [x] Final PR #147 pre-merge HEAD `4f1e2f60962236990556610f87313dda0b341e8b` doğrulandı.
- [x] Android 16 production/pixel-proof kanıtları PASS.
- [x] Levent açık `Merge et` onayı verdi.
- [x] Expected-head ile squash merge yapıldı.
- [x] Merge SHA `d118aa98c5551cb3b4418f61047f6a730406d963`.
- [x] PR #147 `CLOSED / MERGED`.

---

## 0T - Dynamic progression görünür state düzeltmesi / PR #150

**Durum:** TAMAMLANDI / MERGED.

- [x] Raster demo `12 / 30` state'inin runtime progression ile çelişebildiği tespit edildi.
- [x] Gerçek `X / 30` lokal override eklendi.
- [x] Level 1–10 gerçek `0–3` yıldız state'i lokal override edildi.
- [x] Gerçek locked/open state görünür hale getirildi.
- [x] İlk ikinci-yıldız-satırı denemesi görsel FAIL kabul edildi.
- [x] MASTER ART gerçek star-slot pikselleri ölçüldü; generic node-diameter yıldız konumu kaldırıldı.
- [x] Bonus 8, normal 9 ve büyük final 10 kendi ölçülmüş yıldız yuvasını kullanıyor.
- [x] Android 16 production run `32969604847`: SUCCESS.
- [x] Artifact `9607328059`; digest `sha256:a1c01a5acb1c515b584e6cf1d24dea63ece57eaa9417f279f4b52f17e41ef776`.
- [x] Node 9 unlocked/callback PASS.
- [x] Node 10 locked/no-callback PASS.
- [x] App process failure scan PASS.
- [x] Production screenshot'ta eski demo star kalıntıları temizlendi.
- [x] Production asset contract kabul edilen MASTER ART raster + hitbox + lokal state override mimarisine güncellendi.
- [x] PR #150 PR #132 feature branch'ine merge edildi; merge SHA `d64fcd4ea63f173c6653ff33926b12a6c99ef37d`.

---

## 0U - PR #149 proje hafızası checkpoint merge

**Durum:** TAMAMLANDI / MERGED.

- [x] PR #147 sonrası yaşayan proje hafızası checkpoint'i korundu.
- [x] PR #149 PR #132 feature branch'ine merge edildi.
- [x] Merge SHA `adb4557a9a95dd624166b6b08a9e0ab27b1e4f80`.

---

## 0V - PR #132 final entegrasyon kapısı

**Durum:** AÇIK / FINAL EXACT-HEAD DOĞRULAMA + AYRI MERGE ONAYI GEREKİYOR.

- PR #132: `feat(kelime-avi): Baslangic Limani MASTER ART production pilot`.
- Base: `fix/kelime-avi-approved-reference-pixel-match-20260823` / `bc8a03bfefd401570e0c51cc4aab4206ea45d363`.
- Head branch: `feat/kelime-avi-baslangic-limani-asset-first-20260824`.
- PR #147, #150 ve #149 bu branch'e merge edildi.
- Canlı sürüm: `1.68.19+109`.

**Bitti ölçütü:**
- [x] PR #132 body canlı duruma göre güncellendi.
- [x] MASTER ART mimarisi production contract ile hizalandı.
- [x] Dynamic progression görsel state açığı giderildi.
- [x] PR #149 hafıza checkpoint'i feature branch'e merge edildi.
- [ ] Bütün merge/docs commit'lerini içeren yeni exact HEAD üzerinde focused test + analyze + `git diff --check` PASS.
- [ ] Yeni exact HEAD Android 16 production proof SUCCESS.
- [ ] Crash/ANR/FATAL/process-death taraması PASS.
- [ ] Final production screenshot/artifact görsel incelemesi PASS.
- [ ] Levent ayrıca açık PR #132 merge onayı verir.
- [ ] Expected-head ile kontrollü PR #132 merge yapılır.
- [ ] Merge sonrası hedef PR #110 branch HEAD'i doğrulanır.

---

## 0W - Kelime Avı production ana navigasyon entegrasyonu

**Durum:** AÇIK / AYRI KAPSAM + AYRI ONAY GEREKİYOR.

`lib/main.dart` bu pilot merge zincirinde değiştirilmedi. Başlangıç Limanı production rota ekranının gerçek uygulama navigasyonundan açılması ayrı görevdir.

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
