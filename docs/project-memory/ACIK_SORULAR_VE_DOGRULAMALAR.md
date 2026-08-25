# Bilgi Rotası - Açık Sorular ve Canlı Doğrulamalar

> 25 Ağustos 2026 aktif kesimidir. Bu tarihten önceki dosyanın tam ve değişmemiş kopyası `docs/project-memory/archive/ACIK_SORULAR_VE_DOGRULAMALAR_PRE_20260825.md` altında korunur.

## Issue #109 / Draft PR #147 — GÖRSEL + MİMARİ KABUL KAPANDI / MERGE KARARI AÇIK

- Issue #109 `Photo 1.jpg` Başlangıç Limanı için tek bağlayıcı MASTER ART'tır.
- Önceki `8b1731c...` ve PR #146 / run `32740827443` görselleri Levent tarafından reddedildi; görsel kaynak değildir.
- Güncel production commit `0ebd1212d7e66f809705c9c3d2711dd63141f4d7` gerçek `WordHuntReferenceRouteScreen` içinde MASTER ART raster taban + şeffaf hitbox mimarisini kullanır.
- Node 9 progression commit'i `e34832bde06f8318833f8a4373d0aa43ba71141a`: 7 tamamlanınca 8 + 9 açılır; 9 callback aktif; final 10 node 9 tamamlanana kadar kilitli/callback yok.
- Production Android 16 run/job `32778145314` / `97593889745`: SUCCESS; artifact `9539030303`, digest `sha256:a38a1cae778a32f232b266571c249ae3ca710ab7598119fb666af574e9e503f3`.
- Pixel-proof run/job `32778145292` / `97593889800`: SUCCESS; artifact `9539028131`, digest `sha256:9794a1d5a3a1b94d5c030a879ae08f82dec9fa29abdabf5ad2742672a41d4b81`.
- Production ve pixel-proof screenshot'ları byte düzeyinde aynı: SHA-256 `7fc42a56c15501785da02854f62e31041b1ead77869146f1a1cd64096e13bfcb`.
- Levent gerçek production Android 16 görünümünü **GÖRSEL PASS** olarak kabul etti.
- Levent `MASTER ART raster + şeffaf hitbox` production mimarisini **MİMARİ PASS** olarak açıkça kabul etti.

**KAPANAN DOĞRULAMA:** Kullanıcı görsel/mimari kabulü artık `DOĞRULANACAK` değildir.

**AÇIK KALAN:**
1. PR #147 için ayrıca açık Ready/merge onayı verilecek mi? Mimari kabul merge onayı değildir.
2. Mimari-onay docs commit'i sonrası PR #147 exact HEAD ve CI/check durumu yeniden doğrulanacak.
3. Production ana uygulama navigasyonu (`lib/main.dart`) entegrasyonu için ayrı kapsam ve açık onay verilecek mi?

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

İki güncel Play cihazı ve iki ayrı hesapla:
- otomatik eşleştirme,
- 10/20/30 soru,
- aynı soru/sıra,
- skor/ilerleme,
- maç sonucu,
- BR/lig tek sefer işleme,
- leaderboard,
- kopma/ayrılma davranışı
uçtan uca doğrulanacak.

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
