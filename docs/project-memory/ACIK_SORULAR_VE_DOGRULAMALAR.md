# Bilgi Rotası - Açık Sorular ve Canlı Doğrulamalar

> 29 Ağustos 2026 aktif kesimidir. Eski tam kayıtlar Git geçmişi ve `docs/project-memory/archive/` altında korunur.

## Kelime Avı Başlangıç Limanı tema — KOD HAZIR / RUNTIME GÖRSEL DOĞRULAMA AÇIK

Kullanıcı beş özgün aday arasından **1. görseli** seçti: derin lacivert gece limanı + sıcak altın/amber deniz feneri ışığı. Tema Bölüm 1–10 ana görsel kimliğidir; MASTER ART rota ekranını değiştirmez.

Canlı clean theme çalışma:
- Branch: `feat/kelime-avi-baslangic-limani-theme-clean-v1-20260829`
- Taban: doğrulanmış 8×8 docs HEAD `69efcd17606d339233e1d9ca6183d9ac37ed5b5c`.
- Tema wrapper: `lib/word_hunt/baslangic_limani_theme_screen.dart`.
- Production flow: `word_hunt_gameplay_flow.dart` varsayılan açılışı temalı wrapper'a yönlendirildi.
- Doğrulanmış `word_hunt_screens.dart`, 8×8 içerik, path/scoring, `lib/main.dart`, MASTER ART, AdMob/Firebase/signing değişmedi.
- Tema branch'inde Actions run sayısı: **0**.

**DOĞRULANACAK:**
1. Tema dosyaları gerçek `dart format` / analyze'dan geçiyor mu?
2. İki yeni tema/flow widget testi Flutter runner'da PASS mi?
3. Android 16 gerçek screenshot seçilen 1. görselin lacivert + sıcak altın liman hissine yeterince yakın mı?
4. Fener/ışık dekoru sayaç, hedef chipleri, grid ve alt status metninin okunabilirliğini bozuyor mu?
5. Kullanıcı gerçek screenshotı görsel olarak kabul ediyor mu; kabul etmezse hangi renk/ışık yoğunluğu ayarlanacak?
6. Runtime görsel gate sonrası clean theme Draft PR açılacak mı?

---

## Kelime Avı Başlangıç Limanı 8×8 — TEKNİK PASS / KULLANICI KABULÜ AÇIK

29 Ağustos 2026 kullanıcı kararıyla starter-content grid standardı **8×8** oldu; önceki 6×10 geometrisi yeni ürün hattı için superseded edildi.

Canlı çalışma:
- Branch: `feat/kelime-avi-8x8-content-v1-20260829`
- Ürün commit: `052ea7da775db0b58a5ce0c6731a04f251879008`
- Draft PR: **#158** — OPEN / DRAFT / merged=false / mergeable=true.
- Base release: `release/final-closed-test-aab-1.68.8` / `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`.
- Sürüm: `1.68.19+109`.
- Eski PR #156 6×10 hattında OPEN/DRAFT kalır; otomatik kapatılmadı.

Teknik olarak doğrulandı:
- 10 adet 8×8 grid ve 80 toplam target+bonus.
- Her canonical kelime exactly-one physical straight-line occurrence.
- Intended/opposite canonical yol eşleşmeleri.
- B5/B10 yatay+dikey+çapraz yön aileleri.
- B8 `HIZ`+`SKOR`, B9 `ROKET` ve `AY` yok, B10 `YOL`+`HAZİNE` ve `ROTA` yok.
- Dart formatter PASS.
- `dart analyze lib/word_hunt`: No issues.
- Focused Word Hunt suite: **37/37 PASS**.
- Full Flutter suite: **442/442 PASS**.
- `git diff --check` + protected-scope gate PASS.
- QA-only entrypoint/helper dosyaları ürün commitine girmedi.

Final Android 16:
- Run `33251736068`: **SUCCESS**.
- API 36 / 1080×1920 / 420 dpi.
- B1/B5/B8/B10: ilk viewportta **64/64** hücre görünür ve okunabilir.
- B5 +65s soft-time: hard fail yok; 67–76s oynanabilir.
- ANKARA uzun çapraz gerçek swipe: `1/7`, `Bilgi kartı açıldı: Ankara`.
- BAŞKENT ters-dikey gerçek swipe: `1/7`, `BAŞKENT bulundu!`.
- Crash/ANR/FATAL/am_crash taraması temiz.
- Artifact `9714700778`; digest `sha256:dfbca264c2f67bb3549a0e336b075c9238f1a0638962dc69392ea8715b9a2092`.

İlk gate `33250841637` formatter kapısında durmuştu ve analyze/test/Android16 çalışmamıştı; ürün failure değildir. Final run `33251736068` teknik kabul kanıtıdır.

**DOĞRULANACAK — KALANLAR:**
1. Tema uygulanmış gerçek Android 16 8×8 görünümü/oynanışı kullanıcı tarafından kabul ediliyor mu?
2. B5 60 saniye ve B10 120 saniye challenge süreleri gerçek insan playtestinde dengeli mi?
3. Kullanıcı kabulünden sonra PR #158 Ready yapılacak mı?
4. PR #158 merge'i için Levent ayrıca açık merge onayı verecek mi?
5. Eski PR #156 ne zaman/kim tarafından kapatılacak? Otomatik kapatılmayacak.
6. Production `lib/main.dart` ana navigasyon entegrasyonu için ayrı kapsam/onay verilecek mi?

---

## Issue #109 / MASTER ART production — KAPANDI

- Issue #109 `Photo 1.jpg` tek bağlayıcı MASTER ART.
- Görsel ve `MASTER ART raster + şeffaf hitbox` mimari kabulü PASS.
- PR #147 merge SHA `d118aa98c5551cb3b4418f61047f6a730406d963`.

---

## Dynamic progression state — KAPANDI

- Gerçek `X / 30`, yıldız, locked/open state doğrulandı.
- Android 16 run `32969604847`: SUCCESS.
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
