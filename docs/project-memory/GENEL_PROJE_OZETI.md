# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 26 Ağustos 2026 (Europe/Istanbul) — PR #150 + PR #149 merge sonrası final PR #132 doğrulama aşaması

> Bu dosya yeni bir sohbeti hızlı ve güvenli biçimde başlatmak için yaşayan devir özetidir. Teknik doğrulukta tek kanonik kaynak canlı `ZMilaStudio/BilgiRotasi` GitHub deposu ve ilgili canlı servislerdir. `main` güncel kabul edilmez.

## 1. Kalıcı çalışma kuralı

- Her görevden önce canlı hedef branch, `pubspec.yaml`, son commit, PR ve ilgili CI doğrulanır.
- Doğrudan `main` veya release dalına yazılmaz; ayrı branch/PR kullanılır.
- Sıra: test → commit → push → PR → inceleme → merge.
- Kritik merge için Levent'in açık onayı gerekir.
- Teknik/build PASS tek başına çalışma veya görsel kabul kanıtı değildir.
- `assets/questions.json`, BoardMap/67 node/3B, Firebase/AdMob/release config kontrolsüz değiştirilmez.
- Uzun tarihsel durum kayıtları Git geçmişi ve `docs/project-memory/archive/` altında korunur.

## 2. Canlı Kelime Avı durumu — 26 Ağustos 2026

- Repo: `ZMilaStudio/BilgiRotasi`
- Kanonik release branch: `release/final-closed-test-aab-1.68.8`
- Kelime Avı çalışma sürümü: `1.68.19+109`
- Paket: `com.leventua.bilgirotasi`
- PR #132 head branch: `feat/kelime-avi-baslangic-limani-asset-first-20260824`
- PR #132 base: `fix/kelime-avi-approved-reference-pixel-match-20260823` / `bc8a03bfefd401570e0c51cc4aab4206ea45d363`
- PR #132: **OPEN / DRAFT / MERGED=false**; üst hedefe merge edilmedi.
- PR #147 production MASTER ART entegrasyonu PR #132 branch'ine merge edildi: `d118aa98c5551cb3b4418f61047f6a730406d963`.
- PR #150 dynamic progression düzeltmesi PR #132 branch'ine merge edildi: `d64fcd4ea63f173c6653ff33926b12a6c99ef37d`.
- PR #149 proje hafızası PR #147 checkpoint'i PR #132 branch'ine merge edildi: `adb4557a9a95dd624166b6b08a9e0ab27b1e4f80`.
- Bu merge'lerden sonraki docs checkpoint commit'leri ürün kodunu değiştirmez; exact canlı HEAD yeni görev öncesi GitHub'dan yeniden okunur.

## 3. Başlangıç Limanı bağlayıcı production mimarisi

- Tek bağlayıcı görsel kaynak Issue #109 `Photo 1.jpg` MASTER ART'tır.
- MASTER ART repo asset'i: `assets/word_hunt/baslangic_limani_master_art_visual_proof.jpg`.
- Kaynak: `720×1280`; SHA-256 `fb4597bb4d37b30cefeec2ba913c591fe9471529f80966830afd5b801a86fca3`.
- Android/canonical proof alanı: `1080×1920`; uniform scale `1.5`; crop/stretch yok.
- PR #146 ve önceki ChatGPT-generated 5/10/book görselleri **REJECTED BY LEVENT — NOT A VISUAL SOURCE**.
- Levent'in açıkça kabul ettiği production mimarisi: **MASTER ART raster görünür taban + şeffaf hitbox + yalnız gerçek state farkında minimum lokal override**.
- Production `WordHuntReferenceRouteScreen` MASTER ART raster sahneyi kullanır.
- Level 1–10, geri, bilgi, pusula ve kitap gerçek Flutter callback/progression akışına şeffaf hitbox'larla bağlıdır.
- MASTER ART üzerindeki rota/node/plaque/crown/kontrol sanatı ikinci kez komple Flutter katmanı olarak çizilmez.
- Bu mimari yalnız Başlangıç Limanı için bağlayıcıdır; diğer rotalara otomatik genellenmez.

## 4. Dynamic progression sözleşmesi

MASTER ART içindeki demo state gerçek progression gerçeğini bozamaz. PR #150 sonrası görünür runtime state lokalde dinamik tutulur:

- gerçek toplam yıldız `X / 30`,
- level 1–10 gerçek `0–3` yıldız state'i,
- gerçek locked/open state,
- node 9 open state'i.

Progression davranışı:

- 7 tamamlandığında bonus 8 ve normal/open 9 birlikte açılır.
- Bonus 8, node 9 için zorunlu geçiş kapısı değildir.
- Node 9 gerçek `onLevelTap(9)` callback'i üretir.
- Final 10, node 9 tamamlanmadan kilitli ve etkileşimsiz kalır.
- Görünür lock/yıldız state'i interaction state ile aynı gerçeği göstermelidir.

İlk dynamic-star denemesi ikinci yıldız satırı oluşturduğu için FAIL kabul edildi. MASTER ART'ın 1–10 gerçek star-slot pikselleri ölçülerek generic çap hesabı kaldırıldı; bonus 8, normal 9 ve büyük final 10 kendi ölçülmüş yuvalarını kullanır.

## 5. Son doğrulanmış Android 16 kanıtı

PR #150 kod HEAD `aebb384912d379fc87908e4e79b31aecdaba427b` üzerinde:

- Production Android 16 run `32969604847`: **SUCCESS**.
- Artifact `9607328059`.
- Artifact digest `sha256:a1c01a5acb1c515b584e6cf1d24dea63ece57eaa9417f279f4b52f17e41ef776`.
- Focused progression/route test adımı: PASS.
- Android 16 production runtime: PASS.
- Node 9 unlocked + callback: PASS.
- Node 10 locked + callback yok: PASS.
- App process failure taraması: PASS.
- MASTER ART comparison üretimi: PASS.
- Artifact screenshot incelemesinde `21 / 30`, 1–7 dolu, 8–9 açık/0 yıldız ve 10 locked/0 yıldız proof state ile tutarlı; eski demo yıldız kalıntıları görünmüyor.

Bu kanıt PR #150'ye aittir. PR #132 final merge kapısı için bütün merge/docs commit'lerini içeren **yeni exact HEAD** üzerinde fresh proof ayrıca alınacaktır.

## 6. Kabul durumu

- **MASTER ART VISUAL USER ACCEPTANCE: PASS**
- **MASTER ART RASTER + TRANSPARENT HITBOX ARCHITECTURE ACCEPTANCE: PASS**
- **PR #147 MERGE: COMPLETED**
- **PR #150 DYNAMIC PROGRESSION: MERGED INTO PR #132 BRANCH**
- **PR #149 MEMORY CHECKPOINT: MERGED INTO PR #132 BRANCH**
- **PR #132 FINAL MERGE: NOT YET APPROVED / NOT MERGED**

## 7. Korunan alanlar

Bu Kelime Avı pilot çalışmasında kontrolsüz değiştirilmez:

- production `lib/main.dart`
- `assets/questions.json`
- BoardMap / 67 node / 3B tahta
- AdMob / Firebase / Android release config
- release / Play yayın hattı

## 8. Sıradaki aktif işler

1. **PR #132 final exact-head doğrulaması:** focused test + analyze + `git diff --check` + Android 16 production proof + crash/ANR/FATAL/process-death taraması.
2. **Final production screenshot/artifact incelemesi:** dynamic progression sonrası gerçek ekran tekrar kontrol edilecek.
3. **PR #132 merge kararı:** bütün kapılar PASS ise Levent'ten ayrıca açık merge onayı alınacak; onaysız Ready/merge yok.
4. **Production ana navigasyon entegrasyonu:** `lib/main.dart` üzerinden gerçek uygulama girişine bağlanması ayrı kapsam/branch/PR/onay gerektirir.
5. PR #110 / PR #131 ve release hatları yeni görev öncesi canlı GitHub'dan yeniden doğrulanır.
