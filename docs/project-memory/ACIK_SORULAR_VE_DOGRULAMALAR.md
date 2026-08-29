# Bilgi Rotası - Açık Sorular ve Canlı Doğrulamalar

> 30 Ağustos 2026 aktif kesimidir. Eski tam kayıtlar Git geçmişi ve `docs/project-memory/archive/` altında korunur.

## Kelime Avı Başlangıç Limanı tema — TEKNİK RUNTIME PASS / GÖRSEL KABUL AÇIK

Bağlayıcı kullanıcı seçimi: beş özgün aday içinden **1. görsel** — derin lacivert gece limanı + sıcak altın/amber deniz feneri ışığı. Tema Bölüm 1–10 ana görsel kimliğidir; MASTER ART rota ekranını değiştirmez.

Canlı çalışma:
- Branch: `feat/kelime-avi-baslangic-limani-theme-clean-v1-20260829`.
- Doğrulanmış tema ürün SHA: `a91236c9f734e9495e67de46ab6e078d429d681e`.
- Tema wrapper: `lib/word_hunt/baslangic_limani_theme_screen.dart`.
- Production flow: `word_hunt_gameplay_flow.dart` temalı wrapper'a yönlendirildi.
- `word_hunt_screens.dart`, 8×8 içerik, path/scoring, `lib/main.dart`, MASTER ART, AdMob/Firebase/signing/version değişmedi.
- Açık theme PR yok; Ready/merge yok.

Final Android 16 tema gate:
- Run `33278797412`: **SUCCESS**.
- Job `99170289209`.
- Gate SHA `4671a3989155b801c9da6b7d0ec7a7e1a545d465`.
- Formatter: 4 dosya / 0 changed.
- `dart analyze lib/word_hunt`: No issues.
- Tema widget + production-flow testleri: **2/2 PASS**.
- QA entrypoint analyze: PASS.
- B1/B10 debug APK build + install + launch: PASS.
- API 36 / 1080×1920 / 420 dpi: PASS.
- B1 UI: `Bölüm 1`, `0/5`, `0 hata`, 64/64 hücre.
- B10 UI: `Bölüm 10`, `0/9`, `0 hata`, 64/64 hücre.
- B1/B10 screenshot, UI XML ve logcat üretildi.
- `FATAL EXCEPTION`, uygulama ANR ve `am_crash` eşleşmesi yok.
- Artifact `9722440135`, digest `sha256:bf91d7591b4348b3268983f9938a9042631729b8ad7a126c27e6ba35504f3a70`.
- B1 APK SHA-256 `6ea5295ccb1cd27021d75ca7a7e781b867ca88697c57f80b0fbfac3f2174cad2`.
- B10 APK SHA-256 `d3979a967d6213f54680fb4ca3eb8300da7757730f07bde6df9ca515a7428005`.

Tarihsel altyapı failureları `33260968009`, `33274405539`, `33277364738` final V4 SUCCESS yerine kullanılmaz. V4'te runner'a yalnız `bash /tmp/theme_android16_proof.sh` verilerek shell problemi kapatıldı.

**DOĞRULANACAK — KALANLAR:**
1. Gerçek B1/B10 screenshotları seçilen gece-limanı + sıcak amber deniz-feneri hissine yeterince yakın mı?
2. Mevcut gerçek ekranlarda tema dekorunun oldukça hafif olması kullanıcı açısından kabul ediliyor mu, yoksa liman/fener/amber atmosferi güçlendirilecek mi?
3. Kullanıcı görseli kabul ederse clean theme Draft PR açılacak mı?
4. Tema PR ve PR #158 ne zaman Ready yapılacak? Kullanıcı kabulünden önce yapılmaz.
5. Merge için Levent ayrıca açık onay verecek mi?

---

## Kelime Avı Başlangıç Limanı 8×8 — TEKNİK PASS / KULLANICI KABULÜ AÇIK

- Branch: `feat/kelime-avi-8x8-content-v1-20260829`.
- Ürün commit: `052ea7da775db0b58a5ce0c6731a04f251879008`.
- Draft PR #158: OPEN / DRAFT / merged=false.
- Base release: `release/final-closed-test-aab-1.68.8` / `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`.
- Sürüm: `1.68.19+109`.
- Final run `33251736068`: SUCCESS.
- 10 adet 8×8 grid / 80 target+bonus; static/path/reverse sözleşmesi PASS.
- Focused Word Hunt **37/37**, full Flutter **442/442 PASS**.
- Android16 B1/B5/B8/B10 64/64; soft-time ve gerçek ANKARA/ters BAŞKENT swipe PASS.

**DOĞRULANACAK:**
1. Tema dahil gerçek 8×8 görünüm kullanıcı tarafından kabul ediliyor mu?
2. B5 60 saniye ve B10 120 saniye challenge süreleri gerçek insan playtestinde dengeli mi?
3. Kullanıcı kabulünden sonra PR #158 Ready yapılacak mı?
4. PR #158 merge'i için Levent ayrıca açık merge onayı verecek mi?
5. Eski PR #156 ne zaman/kim tarafından kapatılacak? Otomatik kapatılmayacak.
6. Production `lib/main.dart` ana navigasyon entegrasyonu için ayrı kapsam/onay verilecek mi?

---

## Issue #109 / MASTER ART production — KAPANDI

- Issue #109 `Photo 1.jpg` tek bağlayıcı MASTER ART.
- MASTER ART raster + şeffaf hitbox mimari kabulü PASS.
- PR #147 merge SHA `d118aa98c5551cb3b4418f61047f6a730406d963`.

---

## Dynamic progression state — KAPANDI

- Gerçek `X / 30`, yıldız, locked/open state doğrulandı.
- Android16 run `32969604847`: SUCCESS.
- PR #150 merge SHA `d64fcd4ea63f173c6653ff33926b12a6c99ef37d`.

---

## Kelime Avı production ana navigasyon entegrasyonu — AÇIK / AYRI KAPSAM

- `lib/main.dart` 8×8 starter-content/tema dönüşümünde değiştirilmedi.
- Gerçek uygulama girişine bağlama ayrı branch/PR ve açık onay ister.

---

## 1.68.19+109 release / Play / rewarded canlı kabul — AÇIK

- Aynı `gameId` ikinci +10 XP vermez — fiziksel canlı kabul.
- Yarım/başarısız rewarded reklamda XP yok; hak korunur ve yeniden denenebilir.
- Farklı tamamlanan oyunlarda toplam kota olmaması fiziksel kabul.
- Production +109 package/version/signing/AdMob/Firebase/Play doğrulamaları.

---

## Canlı Düello fiziksel kabulü — AÇIK

İki güncel Play cihazı ve iki ayrı hesapla eşleştirme, soru sırası, skor, sonuç, BR/lig, leaderboard ve kopma davranışı uçtan uca doğrulanacak.

---

## Soru geri bildirimleri — AÇIK

- Her soru metin + 4 seçenek + doğru indeks + açıklama + kategori + zorluk birlikte kontrol edilir.
- `assets/questions.json` kontrolsüz değiştirilmez.
- Gerçek düzeltme merge edilmeden Sheet satırı kapatılmaz.

---

## 3B tahta — DURDURULDU / KARAR BEKLİYOR

- BoardMap / 67 node düzenine dokunulmaz.
- Önce numaralı deterministik geometri.
- 8 konsept rozet / 6 fiziksel rozet eşlemesi çözülmeden ilerlenmez.

---

## Mağaza ve tanıtım — AÇIK

Telefon, tablet, Chromebook, PC ve XR varlıklarının Play Console durumu canlı ekrandan doğrulanacak.
