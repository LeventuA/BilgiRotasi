# Bilgi Rotası — Production Başvurusu Sonrası Kalan Teknik İşler

**Tarih:** 18 Ağustos 2026

Production başvurusu kullanıcı tarafından zaten yapılmıştır. Bu belge başvuru adımını tekrar görev olarak yazmaz; yalnız uygulamanın production'a güvenli taşınması için kalan teknik/ürün doğrulamalarını sıralar.

## P0 — yayın öncesi kabul

1. `1.68.17+107` release adayının current-head CI + tam log + artifact + Android 16 gate + exact diff kabulü.
2. Play Kapalı Test'te +107 yayımlandıktan sonra iki cihazlı Canlı Düello fiziksel kabulü:
   - normal maç
   - BR/maç sayısı anında güncel
   - stale `Yarım Kalan Düello` yok
   - normal maç sonunda SupportRewardCard
   - aynı maç ikinci ödül yok
   - forfeit'te reklam hakkı yok.
3. +107 üzerinde first-run UX fiziksel kabulü:
   - otomatik Analytics popup yok
   - bildirim CTA bir kez
   - `Şimdi Değil` sistem izni açmıyor
   - `Bildirimleri Aç` sistem iznini açıyor
   - izin reddinde oyun normal.

## P0 — rewarded production güvenliği

1. `serverRewardXp` ↔ kanonik/yerel XP sahipliği ve idempotent reconciliation tamamlanmalı.
2. Production optimistic local +10 kaldırılmadan gerçek SSV cutover yapılmamalı.
3. PR #53 tek başına yeterli değildir; caller-scoped read-only claim state güncel release'e göre yeniden değerlendirilmelidir.
4. Functions değişikliği ayrı branch/test/PR/merge/onay/deploy hattından geçmelidir.
5. `server_config/rewarded.ssvEnabled` veya production AdMob SSV callback etkinleştirmesi ayrı açık karar ve post-deploy doğrulama gerektirir.

## P1 — reklam kapsam bütünlüğü

SupportRewardCard eksikliği denetiminde aktif modlar için öncelik:
- Marathon
- Daily Challenge
- Survival
- 60 Seconds
- Category Duel
- Short Challenge
- Team
- Mixed Madness.

Her mod stabil gameId ve oyun-başına tek hak sözleşmesine alınmalı. Aktif soru/maç sırasında reklam gösterilmemeli.

## P1 — final gerçek AdMob profili

Production gerçek reklam profiline geçmeden önce birlikte doğrulanmalı:
- gerçek App ID / ad unit ID'ler
- rewarded unit ve SSV callback ayarı
- UMP/privacy consent davranışı
- `app-ads.txt` yayını ve AdMob doğrulaması
- test/closed-test profillerinin Google test reklamında kalması
- kendi gerçek reklamlara test tıklaması yapılmaması
- release signing/env ayrımı.

## P1 — regresyon ve canlı servis kontrolü

- Google giriş/oturum korunması
- Misafir → Google veri izolasyonu
- FCM opt-in + closed-test mesaj teslim regresyonu
- Firestore Rules / indexes / Functions canlı sürümleri yalnız gerektiği kadar doğrulama
- App Check / Play Integrity release davranışı
- crash/ANR/process-death taraması
- full Flutter/Functions/Rules/Android release gates.

## P1 — içerik kalitesi

Videodan kesin ID'leri çıkarılan üç soru ayrı kontrollü görevdir:
- `q56250` Prophet Song
- `q56526` Trust
- `q55862` Felemenkçe

Ayrıca açık Sheet/soru geri bildirimleri gerçek soru düzeltmesi merge edilmeden kapatılmamalıdır.

## P2 — repo/proje hafızası

- #56, #58 ve overnight checkpoint'leri +107 fiziksel kabul sonrası tek güncel proje-hafızası kapanışında konsolide et.
- #13 exact diff incelemesi sonrası superseded ise kapat.
- #53 yeni reconciliation branch'i oluşturulunca eski taslak kapatılabilir.
- #7 release→main PR yalnız production/main entegrasyonu bilinçli olarak gündeme geldiğinde güncellenir/merge edilir.

## Bu gece yapılmayan production işlemleri

- Play'e AAB yükleme/yayın yok.
- Firebase production deploy yok.
- Production SSV cutover yok.
- Gerçek production AdMob açılışı yok.
- Production topic bildirimi gönderimi yok.
