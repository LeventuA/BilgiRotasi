# Bilgi Rotası – Proje Durumu

**Son güncelleme:** 29 Ağustos 2026

## Canlı Sürüm / Release Hattı

- Kanonik release branch: `release/final-closed-test-aab-1.68.8`
- Release HEAD: `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`
- Sürüm: **1.68.19+109**
- Paket: `com.leventua.bilgirotasi`
- `main` yayın kaynağı olarak varsayılmaz.

## Aktif İş — Kelime Avı Başlangıç Limanı 8×8

29 Ağustos 2026 kullanıcı kararıyla Başlangıç Limanı bölüm grid standardı **8 satır × 8 sütun** oldu. Önceki 6×10 geometrisi yeni ürün hattı için superseded; geçmiş kanıt olarak korunur.

- Aktif branch: `feat/kelime-avi-8x8-content-v1-20260829`
- Final temiz ürün commit: `052ea7da775db0b58a5ce0c6731a04f251879008`
- Commit adı: `feat(kelime-avi): switch starter levels to 8x8 [skip ci]`
- Draft PR: **#158** — `WIP feat(kelime-avi): Başlangıç Limanı 8x8 production content`
- PR #158: **OPEN / DRAFT / merged=false / mergeable=true**.
- Base: `release/final-closed-test-aab-1.68.8` / `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`.
- Eski PR #156 6×10 hattında OPEN/DRAFT kalır; otomatik kapatma/merge yapılmadı.
- Toplam canonical target+bonus: **80 kelime**.
- Yoğunluk: B1 6, B2 6, B3 7, B4 7, B5 8, B6 8, B7 9, B8 9, B9 10, B10 10.

## 8×8 Final Teknik Gate — PASS

Düzeltilmiş tek final run:

- Workflow gate commit: `4424285066568ddac874cfa35eb3bae1a62b3394`
- Run: `33251736068`
- Job: `99098467708`
- Sonuç: **SUCCESS**

Doğrulama:
- Dart formatter: PASS.
- `dart analyze lib/word_hunt`: **No issues found**.
- Focused Word Hunt suite: **37/37 PASS**.
- Full Flutter suite: **442/442 PASS**.
- `git diff --check`: PASS.
- Korunan scope gate: PASS.
- Isolated Android QA APK build: PASS.
- QA-only entrypoint/helper dosyaları ürün commitine girmedi.

İlk run `33250841637` yalnız formatter kapısında durmuştu; analyze/test/Android16 çalışmamıştı. Bu tarihsel failure ürün hatası değildi ve final PASS yerine kullanılmaz.

## Android 16 Fiziksel Kanıt — PASS

API 36 / 1080×1920 / 420 dpi:

- B1: **64/64** hücre ilk viewportta görünür, sayaç `0/5`.
- B5: **64/64** hücre görünür, sayaç `0/7`.
- B8: **64/64** hücre görünür, sayaç `0/7`.
- B10: **64/64** hücre görünür, sayaç `0/9`.
- B5 sentetik +65 saniye sonrası hard fail yok; 67–76 saniyede oynanabilir.
- Uzun çapraz `ANKARA` gerçek swipe: `1/7`, `Bilgi kartı açıldı: Ankara`.
- Ters-dikey `BAŞKENT` gerçek swipe: `1/7`, `BAŞKENT bulundu!`.
- `FATAL EXCEPTION`, uygulama ANR veya `am_crash` eşleşmesi yok.

Artifact:
- ID `9714700778`
- Digest `sha256:dfbca264c2f67bb3549a0e336b075c9238f1a0638962dc69392ea8715b9a2092`
- QA APK SHA-256 `d07a68b5f9735f574e8e608afbd4c20d4c1f7cc0c775d5d9f8d0010dfd32c07b`
- Payload decoded SHA-256 `7e4955d6f2545039eafb3e476e5537385ee3d3b359b67be0f886b027ea95be54`

Artifact ekran görüntüleri görsel olarak ayrıca incelendi; B1/B5/B8/B10 8×8 gridleri aynı ekranda okunabilir, ANKARA ve BAŞKENT seçimleri doğru hücreleri boyuyor.

## Korunan Alanlar

8×8 dönüşümünde değiştirilmedi:
- `lib/main.dart`
- `pubspec.yaml`
- `assets/questions.json`
- `assets/word_hunt`
- `lib/word_hunt/word_hunt_screens.dart` 8×8 ürün commitinde değiştirilmedi; PR diffindeki değişiklik eski 6×10 gameplay hattından gelir.
- `lib/word_hunt/word_hunt_path.dart`
- `lib/word_hunt/word_hunt_models.dart`
- MASTER ART / route geometry / BoardMap / 67 node
- AdMob / Firebase / Android release-signing
- package name / version

## Kalan Gerçek Kapılar

1. Kullanıcıdan gerçek Android 16 **8×8 görsel/oynanış kabulü**.
2. B5 ve B10 sürelerinin gerçek insan playtest dengesi.
3. Kullanıcı kabulünden önce PR #158 Ready yapılmaz.
4. Merge yalnız Levent'in ayrıca açık merge onayıyla yapılır.
5. `lib/main.dart` production ana navigasyon entegrasyonu ayrı kapsam/onaydır.

## Kanonik Devir Dosyası

Ayrıntılı geçmiş ve sonraki sıra:
`docs/project-memory/GENEL_PROJE_OZETI.md`
