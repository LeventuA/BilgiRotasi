# Bilgi Rotası - Açık Sorular ve Canlı Doğrulamalar

**Kesim noktası:** 12 Ağustos 2026

## Canlı durum

- Kanonik repo: `ZMilaStudio/BilgiRotasi` — GitHub'da doğrulandı.
- Release dalı: `release/final-closed-test-aab-1.68.8`, head `1a113a6aba98324b668aa5f037fa6b08c7d776c3`, sürüm `1.68.14+104`.
- Kaynak PR #13 ve PR #15 açık/Draft; PR #14 merge edilmiştir. PR #13/#15 değişiklikleri PR #16 entegrasyonu üzerinden release'e ulaşmıştır.
- PR #19 release'e merge edilmiştir.
- PR #20 release'e merge edilmiştir. Son kod değişikliği head'i `18db0393b18fc661cb532a8d4e1b09653bba4259` için run #109 (`31553712368`, job `93981640719`) PASS; docs head'i için run #110 (`31567372445`) PASS'tir. Merge sonrası release head `1a113a6aba98324b668aa5f037fa6b08c7d776c3` olmuştur.
- Fresh RC2 #323 (`31568589298`, job `94025527635`, artifact `9130712889`) project validator'a ulaştı; uygulama kuruldu/açıldı ancak analytics consent penceresi kapatılmadan eski validator yanlış `ANALYTICS_CONSENT_HANDLED=PASS` verdi. Sonuç `MANDATORY_APP_GATE_INCOMPLETE`; Bilgi Rotası crash/ANR/FATAL/process-death kanıtı yoktur.
- PR #21 açık/Draft. Dal `fix/rc2-analytics-consent-gate`; son kod değişikliği commit'i `2b247e9c86d00827e4539ac442ff9f242b6931ee`.
- PR #21 kod CI run #112 (`31573637930`), job `94040784202`: PASS. Analyze+tüm testler, release APK, package/manifest, KVM, Android 16 cold-start attempt 1, classifier, final app gate ve artifact upload PASS; attempt 2 SKIPPED. Artifact ID `9132178688`, digest `sha256:2fea7fcc9b3d3acde16d08a56912a980476245d20b34dbb05baac1229460eb7ef`.
- #112 AdMob cold-start CI'dır; gerçek analytics consent → Misafir → Oyna geniş RC2 gate'inin yerine geçmez.
- Android geliştirici doğrulaması tamamlandı.
- Son doğrulanan Play kapalı test değeri: **12 geçerli testçi / 4 kesintisiz gün**. Sonraki Play erişiminde tarihli ekran kanıtıyla yeniden okunmalıdır.

## RC2 #323 sonrası açık release doğrulaması

1. PR #21'in docs güncellemesi sonrasındaki **güncel head CI sonucu** PASS olarak doğrulanmalı.
2. Levent açıkça onaylamadan PR #21 merge edilmemeli.
3. Merge onayı verilirse merge öncesi base/release head, PR head, mergeability ve checks yeniden doğrulanmalı.
4. Merge sonrasında release head ve `pubspec.yaml` sürümü yeniden okunmalı.
5. Eski #323 **rerun edilmemeli**; yeni `android-apk.yml` workflow_dispatch koşusu `confirmation=CLOSED_TEST` ile oluşturulmalı.
6. Fresh RC2'de `Kullanım Analizine İzin Verilsin mi?` penceresinin gerçekten kapandığı ve auth ekranında `Google|Misafir` görüldüğü kanıtlanmalı.
7. Fresh RC2 artifact'ında `APK_INSTALL`, `APP_LAUNCH`, `GUEST_LOGIN`, `HOME_OYNA`, `APP_PID`, `APP_LOGCAT`, `APP_GATE`, `RELEASE_GATE` değerlerinin tamamı PASS olmalı.
8. Attempt 1 açık emulator infrastructure quartet'i üretirse yalnız tanımlı bounded retry ile attempt 2'ye gidildiği doğrulanmalı; uygulama hataları infrastructure olarak yeniden sınıflandırılmamalı.
9. Fresh RC2 PASS olmadan Play Console'a yeni AAB yüklenmemeli.

## Analytics consent doğrulaması

1. Yeni kurulumda Analytics ayarı varsayılan kapalı mı ve native koleksiyon manifest seviyesinde kapalı mı?
2. Kullanıcı açıkça izin vermeden `analytics_storage` etkinleşmiyor, Firebase app-instance ID üretilmiyor ve olay gönderilmiyor mu?
3. Kullanıcı tercihi cihazda güvenli şekilde saklanıp yeniden açılışta doğru yükleniyor mu?
4. İzin geri alındığında Analytics koleksiyonu kapanıyor, consent değerleri güncelleniyor ve yerel Analytics verisi sıfırlanıyor mu?
5. Reklam depolaması, reklam kullanıcı verisi ve reklam kişiselleştirmesi her durumda `denied` kalıyor mu?
6. Analytics kapalıyken bütün çevrimdışı ve çevrimiçi oyun akışları eksiksiz çalışıyor mu?

## Play Data Safety ve gizlilik politikası görevleri

Play Console'da PR #21 kapsamında değişiklik yapılmayacaktır. Yayın öncesinde:

1. Play Data Safety formunda Firebase Analytics nedeniyle toplanan/verilen veri türleri güncel SDK davranışı ve Firebase belgeleriyle tek tek doğrulanmalı.
2. Uygulama etkileşimleri, pseudonymous app-instance ID, tanılama ve cihaz bilgisi gibi kategorilerin gerçekten toplanıp toplanmadığı denetlenmeli; yalnız kanıtlanan veri türleri işaretlenmeli.
3. Veri toplamanın isteğe bağlı olduğu, Analytics consent kapalıyken olay ve identifier depolanmadığı ve reklam amaçlı consent değerlerinin reddedildiği doğru biçimde beyan edilmeli.
4. Gizlilik politikası Firebase Analytics kullanımını, pseudonymous app-instance ID'yi, olay parametrelerini, kullanım amacını, saklama/silme yaklaşımını ve Ayarlar'dan izni geri alma yolunu açıklamalı.
5. UMP reklam consent'i ile Analytics consent'inin ayrı mekanizmalar olduğu doğrulanmalı.
6. Politika URL'si ve Play Data Safety yanıtları gerçek production build ve Firebase Console ayarlarıyla karşılaştırılmadan yayın onayı verilmemeli.

## Diğer açık doğrulamalar

1. Play kapalı test sayacı ve 14 günlük koşul bir sonraki Play Console erişiminde tarihli ekran kanıtıyla yeniden okunmalı.
2. Sheet'te yeni soru olayı ve bekleyen soru düzeltmeleri yeniden incelenmeli.
3. Production Firebase Functions, Firestore Rules ve index deploy envanteri canlı projeden doğrulanmalı.
4. UMP onay akışı uygun EEA test bölgesinde doğrulanmalı.
5. Canlı Düello iki güncel kapalı test cihazında uçtan uca test edilmeli.
6. Telefon, tablet, Chromebook, PC ve XR mağaza varlıklarının Play Console yükleme durumu canlı ekrandan doğrulanmalı.
7. PR #13 ödüllü reklam değişikliğinin fiziksel cihaz kabul testi tamamlanmalı.
