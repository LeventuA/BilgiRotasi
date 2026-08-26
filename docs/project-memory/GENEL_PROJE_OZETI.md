# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 25 Ağustos 2026 (Europe/Istanbul) — PR #147 merge sonrası

> Bu dosya yeni bir sohbeti hızlı ve güvenli biçimde başlatmak için yaşayan devir özetidir. Teknik doğrulukta tek kanonik kaynak canlı `ZMilaStudio/BilgiRotasi` GitHub deposu ve ilgili canlı servislerdir. `main` güncel kabul edilmez.

## 1. Kalıcı çalışma kuralı

- Her görevden önce canlı hedef branch, `pubspec.yaml`, son commit, PR ve ilgili CI doğrulanır.
- Doğrudan `main` veya release dalına yazılmaz; ayrı branch kullanılır.
- Sıra: test → commit → push → PR → inceleme → merge.
- Kritik merge için Levent'in açık onayı gerekir.
- Teknik/build PASS tek başına çalışma veya görsel kabul kanıtı değildir.
- `assets/questions.json`, BoardMap/67 node/3B, Firebase/AdMob/release config kontrolsüz değiştirilmez.
- Uzun tarihsel durum kayıtları Git geçmişi ve `docs/project-memory/archive/` altında korunur.

## 2. Canlı Kelime Avı durumu — 25 Ağustos 2026

- Repo: `ZMilaStudio/BilgiRotasi`
- Kanonik release branch: `release/final-closed-test-aab-1.68.8`
- Kelime Avı çalışma sürümü: `1.68.19+109`
- Paket: `com.leventua.bilgirotasi`
- Başlangıç Limanı asset-first branch: `feat/kelime-avi-baslangic-limani-asset-first-20260824`
- Bu branch'in canlı HEAD'i: `d118aa98c5551cb3b4418f61047f6a730406d963`
- Merge commit mesajı: `fix(kelime-avi): match Baslangic Limani binding master art (#147)`
- PR #147, Levent'in açık `Merge et` onayı sonrası expected-head `4f1e2f60962236990556610f87313dda0b341e8b` ile **squash merge edildi**.
- PR #147: `CLOSED / MERGED`; merge SHA `d118aa98c5551cb3b4418f61047f6a730406d963`.
- PR #147 doğrudan release/main'e değil PR #132'nin branch'ine merge edildi.
- PR #132 (`feat(kelime-avi): start Baslangic Limani asset-first production pilot`) hâlâ **OPEN / DRAFT / MERGEABLE**, base PR #110 branch'i `fix/kelime-avi-approved-reference-pixel-match-20260823`, base SHA `bc8a03bfefd401570e0c51cc4aab4206ea45d363`, head SHA `d118aa98c5551cb3b4418f61047f6a730406d963`.
- PR #132 için ayrı final inceleme ve ayrı açık merge onayı gerekir.

## 3. Başlangıç Limanı bağlayıcı production mimarisi

- Tek bağlayıcı görsel kaynak Issue #109 `Photo 1.jpg` MASTER ART'tır.
- PR #146 / run `32740827443` ve önceki ChatGPT-generated 5/10/book görselleri **REJECTED BY LEVENT — NOT A VISUAL SOURCE**.
- Levent'in açıkça kabul ettiği production mimarisi: **MASTER ART raster görünür taban + şeffaf hitbox + yalnız gerçek state farkında minimum bölgesel override**.
- Production `WordHuntReferenceRouteScreen` MASTER ART raster sahneyi kullanır.
- Level 1–10, geri, bilgi, pusula ve kitap gerçek Flutter callback/progression akışına şeffaf hitbox'larla bağlıdır.
- MASTER ART üzerindeki rota/node/plaque/yıldız/crown/kontrol sanatı ikinci kez görünür Flutter katmanı olarak çizilmez.
- Bu mimari yalnız Başlangıç Limanı için bağlayıcıdır; diğer rotalara otomatik genellenmez.

## 4. Progression sözleşmesi

- 7 tamamlandığında bonus 8 ve normal/open 9 birlikte açılır.
- Bonus 8, node 9 için zorunlu geçiş kapısı değildir.
- Node 9 gerçek `onLevelTap(9)` callback'i üretir ve teal/cyan normal node olarak görünür.
- Final 10, node 9 tamamlanmadan kilitli ve etkileşimsiz kalır.

## 5. Kabul ve test kanıtı

PR #147 final pre-merge exact HEAD `4f1e2f60962236990556610f87313dda0b341e8b` üzerinde:

- Production Android 16 workflow run `32781169538`: **SUCCESS**; artifact `9540046796`; artifact ZIP digest `sha256:e567f5e1b2681aa4fbab6ed4977c12f1aa78973fbf06dacf88ff4621680165bf`.
- Pixel-proof Android 16 workflow run `32781169568`: **SUCCESS**; artifact `9540079789`; artifact ZIP digest `sha256:c6619bc468b6c90edcfb69e2b19798b762ec031cdc54e2515f2602f46b385b16`.
- Focused Kelime Avı suite: **110/110 PASS**.
- `dart analyze lib/word_hunt`: **No issues found**.
- `git diff --check`: PASS.
- Runtime kapıları: `PRODUCTION_ROUTE_RENDER=PASS`, `NODE_9_UNLOCKED_AND_CALLBACK=PASS`, `NODE_10_LOCKED_NO_CALLBACK=PASS`, `APP_PROCESS_FAILURE_SCAN=PASS`.
- Uygulamaya ait crash/ANR/FATAL/process-death: 0.
- MASTER ART kaynak hash'i: `fb4597bb4d37b30cefeec2ba913c591fe9471529f80966830afd5b801a86fca3`.
- Merge commit `d118aa98...` aynı onaylı tree'yi (`d78905a980c2e9928e2bc9de51eb2d825a81d293`) PR #132 branch'ine taşıdı. Merge anında bu yeni SHA üzerinde ayrıca check-run oluşmamıştı; pre-merge exact-head kanıtı merge edilen tree'ye aittir.

## 6. Görsel ve mimari kabul

- **VISUAL USER ACCEPTANCE: PASS**
- **ARCHITECTURE ACCEPTANCE: PASS**
- **PRODUCTION ANDROID 16: PASS**
- **PR #147 MERGE: PASS / COMPLETED**

## 7. Korunan alanlar

PR #147 / merge ile değiştirilmemiş ve ayrı onay gerektiren alanlar:

- production `lib/main.dart`
- `assets/questions.json`
- BoardMap / 67 node / 3B tahta
- AdMob / Firebase / Android release config
- release / Play yayın hattı

## 8. Sıradaki aktif işler

1. **PR #132 final entegrasyon kapısı:** canlı HEAD `d118aa98...`; PR body tarihsel olarak bayat olabilir, teknik gerçek canlı diff/HEAD'dir. Ayrı review ve Levent merge onayı olmadan merge edilmez.
2. **Production ana navigasyon entegrasyonu:** Başlangıç Limanı route ekranının gerçek uygulama girişine bağlanması (`lib/main.dart`) ayrı branch/PR ve ayrı açık kapsam/onay gerektirir.
3. PR #110 ve PR #131 gibi üst/yan hatların canlı durumları yeni teknik görev öncesi yeniden doğrulanır; eski sohbet durumları kaynak sayılmaz.
4. Başlangıç Limanı mimarisi diğer tema/paketlere kör biçimde kopyalanmaz.
