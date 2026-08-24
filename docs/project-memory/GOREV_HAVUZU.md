# Bilgi Rotası - Görev Havuzu

> 25 Ağustos 2026 aktif kesimidir. Bu tarihten önceki görev havuzunun tam ve değişmemiş kopyası `docs/project-memory/archive/GOREV_HAVUZU_PRE_20260825.md` altında korunur. Teknik gerçek her zaman canlı GitHub ve ilgili canlı servislerdir.

## 0R - 25 Ağustos 2026 / Başlangıç Limanı production MASTER ART mimari kabulü

- **Durum:** UYGULANDI / VISUAL USER ACCEPTANCE PASS / ARCHITECTURE ACCEPTANCE PASS / PRODUCTION ANDROID 16 PASS / PR #147 AÇIK + DRAFT / MERGE YOK.
- Branch: `fix/kelime-avi-baslangic-limani-master-art-codex-20260824`
- PR: `#147`
- Base exact: `1968c4bccd22468bec50f2188414a3e5f6f3fa4b`
- Production commit: `0ebd1212d7e66f809705c9c3d2711dd63141f4d7` — `fix(kelime-avi): use approved master art in production route`
- Node 9 progression commit: `e34832bde06f8318833f8a4373d0aa43ba71141a`
- Sürüm: `1.68.19+109`

**Bitti ölçütü:**
- [x] Issue #109 `Photo 1.jpg` tek bağlayıcı MASTER ART olarak korunuyor.
- [x] Production `WordHuntReferenceRouteScreen` görünür tabanda MASTER ART raster sahneyi kullanıyor.
- [x] Level 1–10, geri, bilgi, pusula ve kitap gerçek davranışları şeffaf hitbox'larla callback/progression sistemine bağlı.
- [x] MASTER ART'taki görünür rota/node/plaque/panel/crown/kontrol sanatı ikinci kez çizilmiyor.
- [x] State farkı yalnız minimum override ile uygulanıyor; node 9 normal/open override bunun bağlayıcı örneği.
- [x] 7 tamamlanınca 8 + 9 açılıyor; 9 gerçek callback üretiyor; final 10, 9 tamamlanmadan locked ve callback üretmiyor.
- [x] Focused Kelime Avı suite `110/110 PASS`.
- [x] `dart analyze lib/word_hunt`: `No issues found`.
- [x] `git diff --check`: PASS.
- [x] Production Android 16 run/job `32778145314` / `97593889745`: SUCCESS; artifact `9539030303`, digest `sha256:a38a1cae778a32f232b266571c249ae3ca710ab7598119fb666af574e9e503f3`.
- [x] Pixel-proof Android 16 run/job `32778145292` / `97593889800`: SUCCESS; artifact `9539028131`, digest `sha256:9794a1d5a3a1b94d5c030a879ae08f82dec9fa29abdabf5ad2742672a41d4b81`.
- [x] Production ve pixel-proof screenshot byte düzeyinde aynı: SHA-256 `7fc42a56c15501785da02854f62e31041b1ead77869146f1a1cd64096e13bfcb`.
- [x] Runtime: `PRODUCTION_ROUTE_RENDER=PASS`, `NODE_9_UNLOCKED_AND_CALLBACK=PASS`, `NODE_10_LOCKED_NO_CALLBACK=PASS`, `APP_PROCESS_FAILURE_SCAN=PASS`; app crash/ANR/FATAL/process-death = 0.
- [x] Levent gerçek Android 16 production görselini açıkça kabul etti.
- [x] Levent `MASTER ART raster + şeffaf hitbox` production mimarisini açıkça kabul etti.
- [ ] PR #147 için ayrı açık Ready/merge onayı gerekir. Bu mimari kabul merge onayı değildir.

---

## 0S - PR #147 final merge kapısı

**Durum:** AÇIK / KULLANICI MERGE KARARI BEKLİYOR.

**Bitti ölçütü:**
- [ ] Mimari-onay proje-hafızası commit'i sonrası PR #147 exact HEAD canlı GitHub'dan yeniden kilitlenir.
- [ ] Docs-head üzerinde tetiklenen CI/check sonuçları varsa tamamı incelenir; product commit `0ebd121...` kanıtı ile karıştırılmaz.
- [ ] PR `OPEN / DRAFT / MERGEABLE / CLEAN` durumunda ve base exact beklenen hatta olmalıdır.
- [ ] Levent ayrıca açıkça `Ready/merge et` onayı verir.
- [ ] Merge ancak expected-head SHA ile kontrollü uygulanır.
- [ ] Merge sonrası hedef dal HEAD'i ve diff yeniden doğrulanır.

---

## 0T - Kelime Avı production ana navigasyon entegrasyonu

**Durum:** AÇIK / AYRI KAPSAM + AYRI ONAY GEREKİYOR.

`lib/main.dart` bu çalışma sırasında değiştirilmedi. Başlangıç Limanı production rota ekranının ana uygulama navigasyonunda hangi girişten açılacağı ayrı görevdir.

**Bitti ölçütü:**
- [ ] Levent açık kapsam/onay verir.
- [ ] Canlı hedef branch/release tekrar kilitlenir.
- [ ] Minimum navigation diff ayrı branch/PR üzerinde yapılır.
- [ ] Mevcut giriş, reklam, Firebase, BoardMap/67 node ve diğer oyun modları bozulmaz.
- [ ] Analyze/test/Android gerçek cihaz veya Android 16 kabulü PASS.
- [ ] Ayrı açık merge onayı olmadan merge yapılmaz.

---

## Korunan açık işler

Aşağıdaki işler bu Kelime Avı görsel kabulüyle kapanmış sayılmaz; ayrıntılı tarihsel kayıtları arşiv dosyasında korunur:

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
