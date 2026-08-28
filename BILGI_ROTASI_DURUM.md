# Bilgi Rotası – Proje Durumu

**Son güncelleme:** 28 Ağustos 2026

## Canlı Sürüm / Release Hattı

- Kanonik release branch: `release/final-closed-test-aab-1.68.8`
- Release HEAD: `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`
- Sürüm: **1.68.19+109**
- Paket: `com.leventua.bilgirotasi`
- `main` yayın kaynağı olarak varsayılmaz.

## Aktif İş — Kelime Avı Başlangıç Limanı 6×10

- PR: **#156**
- Head branch: `feat/kelime-avi-content-pass-v1-20260828`
- Base: `release/final-closed-test-aab-1.68.8`
- PR son kontrolde: **OPEN / DRAFT / merged=false / mergeable=true**.
- 10 bölümün canonical grid standardı: **10 satır × 6 sütun**.
- Toplam canonical target + bonus: **80 kelime**.
- Eski 6×6 / 3→6 kelimelik plan superseded; geri alınmaz.

## Son Tamamlanan Teknik Checkpoint

Android 16 gerçek 6×10 runtime/gesture QA tamamlandı.

Final QA:
- QA branch: `qa/kelime-avi-6x10-runtime-android16-20260828`
- QA head: `e12b99513ea6235e857f7c855006e6d1abb2080e`
- Commit: `test(qa): verify B5 swipe progress after scroll`
- Workflow run: `33202898863`
- Sonuç: **SUCCESS**
- `QA source gate`: SUCCESS
- B1 runtime: SUCCESS
- B5 runtime: SUCCESS
- B8 runtime: SUCCESS
- B10 runtime: SUCCESS

B5 gerçek Android 16 kanıtı:
- 1080×1920 / 420 dpi.
- 10×6 grid açılıyor.
- +65 saniye sentetik clock offset sonrası oyun hard fail olmadan oynanabilir kalıyor; time limit soft challenge.
- Uzun çapraz `ANKARA` gerçek `adb input swipe` ile bulundu; seçim hücreleri yeşil ve `Bilgi kartı açıldı: Ankara` kanıtı var.
- Ters-dikey `BAŞKENT` ayrı temiz açılışta gerçek `adb input swipe` ile bulundu; seçim hücreleri yeşil ve `BAŞKENT bulundu!` kanıtı var.
- Her iki gesture sonrası viewport üste döndürülünce sayaç `1/7`, hata `0`.
- Uygulama logunda `FATAL EXCEPTION`, uygulama ANR veya `am_crash` kanıtı yok.

## Gameplay Sözleşmesi

Ürün kodu/testleri şunları koruyor:
- rectangular 6×10 render ve dinamik hit-test,
- intended ve reverse straight gestures,
- bonus kelime completion gate değil,
- ana targetlar tamamlanınca elapsed + mistake skoru donar,
- target sonrası bonus araması mümkün,
- target sonrası yanlış bonus denemesi kazanılmış skoru düşürmez,
- sonuç yalnız `Bölümü Tamamla` ile açılır,
- `timeLimitSeconds` hard fail değil soft challenge.

## Sıradaki İş

1. Kullanıcıdan B1/B5/B8/B10 gerçek Android 16 görünümü için **görsel/oynanış kabulü** al.
2. B5 ve B10 challenge sürelerini gerçek insan playtestiyle değerlendir; teknik soft-time PASS zorluk dengesi onayı değildir.
3. Kullanıcı kabulünden önce PR #156 Ready yapma.
4. Merge yalnız Levent'in açık merge onayıyla yapılır.
5. Yeni gerçek cihaz belirtisi çıkmadıkça aynı QA'yı körlemesine tekrar üretme.

## Korunan Alanlar

Açık kapsam olmadan değişmez:
- `lib/main.dart`
- `assets/questions.json`
- BoardMap / 67 node / 3B tahta
- MASTER ART bytes ve kabul edilmiş route art mimarisi
- AdMob / Firebase / Android release-signing config
- package name
- `version: 1.68.19+109`

## Doğrulanacak Proje Dosyaları

28 Ağustos 2026 canlı repo/feature branch kontrolünde aşağıdaki dosyalar bulunamadı:
- `KARARLAR.md`
- `GOREV_HAVUZU.md`
- `ACIK_SORULAR_VE_DOGRULAMALAR.md`

Bu nedenle bunların güncel içerik veya görev durumu **DOĞRULANACAK** olarak kalır; upload/eski sohbet içeriği canlı GitHub kaynağı yerine geçirilmez.

## Kanonik Devir Dosyası

Kelime Avı için ayrıntılı geçmiş, kararlar, QA runları ve sıradaki sıra:
`docs/project-memory/GENEL_PROJE_OZETI.md`
