# Bilgi Rotası - Açık Sorular ve Canlı Doğrulamalar

> 25 Ağustos 2026 aktif kesimidir. Bu tarihten önceki dosyanın tam ve değişmemiş kopyası `docs/project-memory/archive/ACIK_SORULAR_VE_DOGRULAMALAR_PRE_20260825.md` altında korunur.

## Issue #109 / PR #147 — KAPANDI

- Issue #109 `Photo 1.jpg` Başlangıç Limanı için tek bağlayıcı MASTER ART'tır.
- Levent gerçek production Android 16 görünümünü **GÖRSEL PASS** olarak kabul etti.
- Levent `MASTER ART raster + şeffaf hitbox` production mimarisini **MİMARİ PASS** olarak kabul etti.
- PR #147 final pre-merge head `4f1e2f60962236990556610f87313dda0b341e8b` üzerinde production Android 16 run `32781169538` ve pixel-proof run `32781169568` SUCCESS oldu.
- Levent ayrıca açıkça `Merge et` onayı verdi.
- PR #147 expected-head ile squash merge edildi; merge SHA `d118aa98c5551cb3b4418f61047f6a730406d963`.
- PR #147 canlı durum: `CLOSED / MERGED`.
- Hedef branch `feat/kelime-avi-baslangic-limani-asset-first-20260824` canlı HEAD: `d118aa98c5551cb3b4418f61047f6a730406d963`.

**KAPANAN DOĞRULAMALAR:** görsel kabul, mimari kabul, node 9 progression, Android 16 production kanıtı ve PR #147 merge kararı artık açık değildir.

---

## PR #132 Başlangıç Limanı asset-first pilot — AÇIK

- PR #132 canlı durum: `OPEN / DRAFT / MERGEABLE / MERGED=false`.
- Base: `fix/kelime-avi-approved-reference-pixel-match-20260823` / `bc8a03bfefd401570e0c51cc4aab4206ea45d363`.
- Head: `feat/kelime-avi-baslangic-limani-asset-first-20260824` / `d118aa98c5551cb3b4418f61047f6a730406d963`.
- PR body eski ara asset durumunu taşıyabilir; güncel teknik gerçek canlı diff/HEAD'dir.

**DOĞRULANACAK:**
1. PR #132 net diff ve Git geçmişi final `d118aa98...` HEAD'inde temiz mi?
2. PR #132 için fresh exact-head CI gerekli mi, yoksa merge edilen PR #147 tree kanıtı yeterli mi?
3. Levent PR #132 için ayrıca merge onayı verecek mi?

---

## Kelime Avı production ana navigasyon entegrasyonu — AÇIK

- `lib/main.dart` PR #147 ile değiştirilmedi.
- Başlangıç Limanı production route ekranının gerçek uygulama girişine bağlanması ayrı kapsamdır.

**DOĞRULANACAK:** Levent bu entegrasyon için ayrı açık kapsam/onay verecek mi?

---

## 1.68.19+109 release / Play / rewarded canlı kabul — AÇIK

- Aynı `gameId` ikinci +10 XP vermez — fiziksel canlı kabul.
- Yarım/başarısız rewarded reklamda XP yok; hak korunur ve yeniden denenebilir — fiziksel canlı kabul.
- Farklı tamamlanan oyunlarda günlük/oturumluk toplam kota yok — fiziksel canlı kabul.
- Production +109 AAB package/version/signing/AdMob/Firebase profil doğrulaması.
- Play Console +109 upload/install/rollout/public listing doğrulaması.
- Play App Signing / Upload sertifika SHA rollerinin canlı Console + Firebase fingerprint eşlemesi.

---

## Canlı Düello fiziksel kabulü — AÇIK

İki güncel Play cihazı ve iki ayrı hesapla otomatik eşleştirme, 10/20/30 soru, aynı soru/sıra, skor/ilerleme, maç sonucu, BR/lig tek sefer işleme, leaderboard ve kopma/ayrılma davranışı uçtan uca doğrulanacak.

---

## Soru geri bildirimleri — AÇIK

- Sheet'teki bekleyen olaylar canlı kaynaktan yeniden okunacak.
- Her soru için metin, dört seçenek, doğru indeks, açıklama, kategori ve zorluk birlikte kontrol edilecek.
- `assets/questions.json` kontrolsüz değiştirilmeyecek.
- Sheet satırı gerçek soru düzeltmesi merge edilmeden kapatılmayacak.

---

## 3B tahta — DURDURULDU / KARAR BEKLİYOR

- Oynanış, BoardMap ve 67 node düzenine dokunulmayacak.
- Önce numaralı deterministik geometri.
- 8 konsept rozet / 6 fiziksel rozet eşlemesi çözülmeden ilerlenmeyecek.
- Kullanıcı görsel onayı olmadan stil/Flutter/APK aşamasına geçilmeyecek.

---

## Mağaza ve tanıtım — AÇIK

Telefon, tablet, Chromebook, PC ve XR varlıklarının Play Console durumu canlı ekrandan `hazır / yüklendi / reddedildi / yeniden yapılacak` biçiminde doğrulanacak.
