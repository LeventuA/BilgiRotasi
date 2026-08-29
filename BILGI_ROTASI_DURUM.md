# Bilgi Rotası – Proje Durumu

**Son güncelleme:** 30 Ağustos 2026

## Canlı Sürüm / Release Hattı

- Repo: `ZMilaStudio/BilgiRotasi`
- Kanonik release branch: `release/final-closed-test-aab-1.68.8`
- Release HEAD: `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`
- Sürüm: **1.68.19+109**
- Paket: `com.leventua.bilgirotasi`
- `main` yayın kaynağı olarak varsayılmaz.

## Başlangıç Limanı 8×8 — TEKNİK PASS

29 Ağustos 2026 kullanıcı kararıyla Bölüm 1–10 grid standardı **8×8** oldu. Önceki 6×10 geometrisi superseded; geçmiş kanıt olarak korunur.

- Branch: `feat/kelime-avi-8x8-content-v1-20260829`
- Temiz ürün commit: `052ea7da775db0b58a5ce0c6731a04f251879008`
- Draft PR #158: **OPEN / DRAFT / merged=false**; kullanıcı kabulü olmadan Ready/merge yok.
- Final gate run `33251736068`: **SUCCESS**.
- Focused Word Hunt: **37/37 PASS**; full Flutter: **442/442 PASS**.
- Android 16 / API 36 / 1080×1920 / 420 dpi: B1/B5/B8/B10 **64/64** hücre görünür; B5 soft-time, ANKARA ve ters BAŞKENT gerçek swipe, crash/ANR taraması PASS.
- Artifact `9714700778`, digest `sha256:dfbca264c2f67bb3549a0e336b075c9238f1a0638962dc69392ea8715b9a2092`.

## Başlangıç Limanı Bölüm İçi Tema — TEKNİK RUNTIME PASS / GÖRSEL KULLANICI KABULÜ AÇIK

Bağlayıcı tema kararı: Bölüm 1–10 için **derin lacivert gece limanı + sıcak altın/amber deniz feneri ışığı**. Tema yalnız bölüm içi Kelime Avı ekranındadır; MASTER ART rota ekranı değişmez.

- Clean theme branch: `feat/kelime-avi-baslangic-limani-theme-clean-v1-20260829`.
- Doğrulanmış tema ürün SHA: `a91236c9f734e9495e67de46ab6e078d429d681e`.
- Tema katmanı: `lib/word_hunt/baslangic_limani_theme_screen.dart`.
- Production flow: `lib/word_hunt/word_hunt_gameplay_flow.dart` varsayılan level açılışını temalı wrapper'a yönlendirir.
- `word_hunt_screens.dart`, path/scoring, 8×8 içerik, `lib/main.dart`, MASTER ART, AdMob/Firebase/signing/version değiştirilmedi.
- Açık theme PR yok; Ready/merge yok.

### Final tema Android 16 gate — PASS

V4 trigger commit:
`4671a3989155b801c9da6b7d0ec7a7e1a545d465` — `ci(kelime-avi): trigger lighthouse theme Android16 v4`

- Run: `33278797412`
- Job: `99170289209`
- Sonuç: **SUCCESS**
- Formatter: **4 dosya / 0 changed PASS**.
- `dart analyze lib/word_hunt`: **No issues found**.
- Tema widget + production-flow testleri: **2/2 PASS**.
- QA-only entrypoint analyze: PASS.
- B1 debug APK build/install/launch: PASS.
- B10 debug APK build/install/launch: PASS.
- KVM + API 36 emulator boot: PASS.
- Fiziksel ekran: **1080×1920 / 420 dpi**.
- B1 UI: `Bölüm 1 / Başlangıç Limanı`, `0/5`, `0 hata`, **64/64** harf hücresi.
- B10 UI: `Bölüm 10 / Başlangıç Limanı`, `0/9`, `0 hata`, **64/64** harf hücresi.
- B1/B10 screenshot + UI XML + logcat başarıyla üretildi.
- `FATAL EXCEPTION`, uygulama ANR ve `am_crash` eşleşmesi yok.

Artifact:
- ID `9722440135`
- Digest `sha256:bf91d7591b4348b3268983f9938a9042631729b8ad7a126c27e6ba35504f3a70`
- 15 kanıt dosyası.
- B1 APK SHA-256 `6ea5295ccb1cd27021d75ca7a7e781b867ca88697c57f80b0fbfac3f2174cad2`.
- B10 APK SHA-256 `d3979a967d6213f54680fb4ca3eb8300da7757730f07bde6df9ca515a7428005`.

V4 geçici workflow başarı sonrası branch'ten kaldırıldı:
- Temizlik commit: `7c9aa6c6e0468c381e9d22cac700f8a399c5e6f0`
- `chore(ci): remove lighthouse theme Android16 v4 gate [skip ci]`
- Yeni Actions run tetiklenmemesi ayrıca doğrulanacak.

### Görsel değerlendirme kapısı

Teknik ekran okunabilirliği PASS; grid, sayaç, hedef alanları ve alt durum metni taşmıyor. Ancak mevcut gerçek screenshotlarda deniz-feneri/amber atmosferi **oldukça hafif**; ekran baskın olarak sade koyu lacivert oyun arayüzü şeklinde okunuyor. Bu nedenle tema görseli kullanıcı tarafından kabul edilmeden görsel PASS verilmez.

## Korunan Alanlar

Tema/8×8 çalışmasında açık kapsam olmadan değiştirilmez:
- `lib/main.dart`
- `pubspec.yaml`
- `assets/questions.json`
- `assets/word_hunt` / MASTER ART
- `lib/word_hunt/word_hunt_screens.dart`
- `lib/word_hunt/word_hunt_path.dart`
- `lib/word_hunt/word_hunt_models.dart`
- BoardMap / 67 node / 3B tahta
- AdMob / Firebase / Android release-signing
- package name / version

## Kalan Gerçek Kapılar

1. Levent gerçek B1/B10 tema screenshotlarını görsel olarak kabul eder veya tema atmosferinin güçlendirilmesini ister.
2. Görsel kabulden sonra gerekirse clean theme Draft PR açılır; kullanıcı kabulünden önce Ready yapılmaz.
3. B5/B10 gerçek insan süre dengesi playtesti yapılır.
4. PR #158 için Ready kararı ayrıca verilir.
5. Merge yalnız Levent'in ayrıca açık merge onayıyla yapılır.
6. Production `lib/main.dart` ana navigasyon entegrasyonu ayrı kapsam/branch/PR işidir.

## Kanonik Devir Dosyası

`docs/project-memory/GENEL_PROJE_OZETI.md`
