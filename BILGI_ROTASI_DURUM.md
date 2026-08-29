# Bilgi Rotası – Proje Durumu

**Son güncelleme:** 29 Ağustos 2026

## Canlı Sürüm / Release Hattı

- Kanonik release branch: `release/final-closed-test-aab-1.68.8`
- Release HEAD: `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`
- Sürüm: **1.68.19+109**
- Paket: `com.leventua.bilgirotasi`
- `main` yayın kaynağı olarak varsayılmaz.

## Aktif İş — Kelime Avı Başlangıç Limanı 8×8

29 Ağustos 2026 kullanıcı kararıyla Başlangıç Limanı bölüm grid standardı **8 satır × 8 sütun** olarak değiştirildi. Önceki 6×10 ürün geometrisi artık yeni çalışma için superseded durumdadır; eski 6×10 teknik kanıtı geçmiş checkpoint olarak korunur.

- Yeni çalışma branch'i: `feat/kelime-avi-8x8-content-v1-20260829`
- Başlangıç noktası / eski 6×10 ürün head'i: `0e9408ddda511259f588a338b3fcd8192bf92431`
- 8×8 geçici gate head'i: `7cff26f4a75e1c58beaea2c163f2e89e2c2af154`
- PR #156: **OPEN / DRAFT / merged=false**; hâlâ eski 6×10 branch'i `feat/kelime-avi-content-pass-v1-20260828` üzerindedir ve 8×8 için Ready/merge kaynağı değildir.
- Toplam canonical target + bonus: **80 kelime** korunuyor.
- Kelime yoğunluğu korunuyor: B1 6, B2 6, B3 7, B4 7, B5 8, B6 8, B7 9, B8 9, B9 10, B10 10.

## 8×8 Statik İçerik Sözleşmesi — PASS

Bağımsız statik denetimde:

- 10 bölümün tamamı 8×8.
- Toplam 80 target/bonus korunuyor.
- Her canonical target/bonus 8 düz yönde **exactly one physical occurrence** taşıyor.
- Intended path ve ters fiziksel hatlar aynı canonical kelimeye karşılık geliyor.
- B5 ve B10 yatay + dikey + çapraz yön ailelerinin üçünü de içeriyor.
- B8 bonusları `HIZ` + `SKOR`; `TOP` tek fiziksel hatta.
- B9 `ROKET` bonus korunuyor; `AY` geri dönmüyor.
- B10 `ROTA` geri dönmüyor; `YOL` hedef ve `HAZİNE` bonus korunuyor.
- B5 süre/yıldız eşikleri 60 / 50 / 35 saniye; B10 120 / 100 / 75 saniye olarak korunuyor.
- Yeni ürün/test kapsamındaki hard-coded gesture yolları yeni 8×8 canonical koordinatlarla uyumlu.
- Manuel formatter adayı beş ürün/test dosyasında whitespace + Dart trailing-comma nötr karşılaştırmada kaynakla eşdeğer: **PASS**.

Bu statik PASS, Flutter analyze/test veya Android 16 runtime PASS değildir.

## Tek Yetkili Actions Koşusu — FAILURE / FORMAT GATE

Kullanıcının izin verdiği tek GitHub Actions koşusu kullanıldı:

- Workflow commit: `7cff26f4a75e1c58beaea2c163f2e89e2c2af154`
- Run: `33250841637`
- Job: `99096135627`
- Sonuç: **FAILURE**

Run'ın gerçek nedeni:

- Payload decode/apply: SUCCESS.
- Java 17: SUCCESS.
- Flutter 3.44.6 kurulumu: SUCCESS.
- `dart format --output=none --set-exit-if-changed` üç Dart dosyasında biçim değişikliği istedi ve step bu noktada exit 1 verdi.
- `dart analyze` ÇALIŞMADI.
- Focused Flutter testleri ÇALIŞMADI.
- Full `flutter test` ÇALIŞMADI.
- APK build ÇALIŞMADI.
- Android 16 B1/B5/B8/B10 runtime ve gesture gate ÇALIŞMADI.

Dolayısıyla 8×8 teknik ürün doğrulaması **DOĞRULANACAK** durumdadır; bu run ürün logic/layout failure kanıtı değildir.

## QA Scope Bulgusu

Başarısız run sonrası workflow incelemesinde ek bir güvenlik sorunu tespit edildi: payload içindeki QA-only `lib/word_hunt/word_hunt_8x8_qa_main.dart`, final `git add lib/word_hunt test` adımına ulaşılsaydı yanlışlıkla ürün commitine dahil olabilirdi. Run bu adıma ulaşmadığı için QA dosyası branch ürün kaynağına commit edilmedi.

Yeni gate'te:

- QA entrypoint ve yardımcı araçlar yalnız geçici kalacak.
- Ürün commit scope'u açık allowlist ile sınırlandırılacak.
- QA-only dosya temizlenmeden ürün commitine geçilmeyecek.

## Korunan Alanlar

8×8 çalışma kapsamında değiştirilmez:

- `lib/main.dart`
- `assets/questions.json`
- MASTER ART bytes / route art mimarisi
- BoardMap / 67 node / 3B tahta
- AdMob / Firebase / Android release-signing config
- package name
- `version: 1.68.19+109`

## Sıradaki Teknik Kapı

1. Formatter-uyumlu 8×8 ürün adayını temiz scope ile hazırla.
2. Yeni Actions koşusu **ancak Levent yeniden açık izin verirse** veya yerel Flutter SDK doğrulaması mümkün olursa çalıştır.
3. Zorunlu doğrulamalar: Dart format, `dart analyze lib/word_hunt`, focused Word Hunt testleri, full `flutter test`, `git diff --check`.
4. Android 16: B1/B5/B8/B10 gerçek production screen; ilk viewportta 64/64 8×8 hücre görünürlüğü/okunabilirliği; B5 >60s soft-time; gerçek `ANKARA` ve ters `BAŞKENT` swipe; crash/ANR/am_crash taraması.
5. Bu kanıtlar olmadan yeni 8×8 PR Ready/merge yapılmaz.
6. Merge yalnız Levent'in açık merge onayıyla yapılır.

## Kanonik Devir Dosyası

Ayrıntılı geçmiş ve sonraki sıra:
`docs/project-memory/GENEL_PROJE_OZETI.md`
