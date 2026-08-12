# Bilgi Rotası - Açık Sorular ve Canlı Doğrulamalar

**Kesim noktası:** 12 Ağustos 2026

## Canlı durum

- Kanonik repo: `ZMilaStudio/BilgiRotasi` — GitHub'da doğrulandı.
- Release dalı: `release/final-closed-test-aab-1.68.8`, head
  `8a99530de7cb370d4db0edff9214ad833a8907cf`, sürüm `1.68.14+104`.
- Kaynak PR #13 ve PR #15 açık/Draft ve merge edilmemiştir; PR #14 merge
  edilmiştir. PR #13/#15 değişiklikleri PR #16 entegrasyonu üzerinden release'e
  ulaşmıştır.
- PR #19 release'e merge edilmiştir. Sonraki RC2 #322, project validator başlamadan
  önce third-party action'ın `disable-animations` settings çağrısında kırılmıştır.
- PR #20 açık/Draft ve merge edilmemiştir. Final doğrulanan head
  `18db0393b18fc661cb532a8d4e1b09653bba4259` üzerindeki AdMob PR doğrulaması
  run #109 (`31553712368`), job `93981640719` PASS'tir. KVM hazırlama ve
  `disable animations: false` logdan doğrulanmış; project validator deneme 1'de
  çalışıp tüm AdMob app/release gate'lerini geçmiştir. Final artifact ID
  `9125437699`.
- Android geliştirici doğrulaması tamamlandı.
- Son doğrulanan Play kapalı test değeri: **12 geçerli testçi / 4 kesintisiz gün**.
- 8 Ağustos kontrolünde bağlı Play Console tarayıcısı bulunmadığı için bu sayaç
  UI'dan yeniden okunamadı; sonraki erişimde tarihli ekran kanıtı alınmalıdır.

## Analytics consent doğrulaması

1. Yeni kurulumda Analytics ayarı varsayılan kapalı mı ve native koleksiyon
   manifest seviyesinde kapalı mı?
2. Kullanıcı açıkça izin vermeden `analytics_storage` etkinleşmiyor, Firebase
   app-instance ID üretilmiyor ve olay gönderilmiyor mu?
3. Kullanıcı tercihi cihazda güvenli şekilde saklanıp yeniden açılışta doğru
   yükleniyor mu?
4. İzin geri alındığında Analytics koleksiyonu kapanıyor, consent değerleri
   güncelleniyor ve yerel Analytics verisi sıfırlanıyor mu?
5. Reklam depolaması, reklam kullanıcı verisi ve reklam kişiselleştirmesi her
   durumda `denied` kalıyor mu?
6. Analytics kapalıyken bütün çevrimdışı ve çevrimiçi oyun akışları eksiksiz
   çalışıyor mu?

## Play Data Safety ve gizlilik politikası görevleri

Play Console'da bu PR kapsamında değişiklik yapılmayacaktır. Yayın öncesinde:

1. Play Data Safety formunda Firebase Analytics nedeniyle toplanan/verilen veri
   türleri güncel SDK davranışı ve Firebase belgeleriyle tek tek doğrulanmalı.
2. En az uygulama etkileşimleri, diğer kullanıcı tarafından oluşturulmayan
   kullanım olayları, yaklaşık tanımlayıcı/app-instance ID, tanılama ve cihaz
   bilgisi kategorilerinin gerçekten toplanıp toplanmadığı denetlenmeli; formda
   yalnız kanıtlanan veri türleri işaretlenmeli.
3. Veri toplamanın isteğe bağlı olduğu, Analytics consent kapalıyken olay ve
   identifier depolanmadığı ve reklam amaçlı consent değerlerinin reddedildiği
   doğru biçimde beyan edilmeli.
4. Gizlilik politikası Firebase Analytics kullanımını, pseudonymous
   app-instance ID'yi, olay parametrelerini, kullanım amacını, saklama/silme
   yaklaşımını ve kullanıcının Ayarlar'dan izni geri alma yolunu açıklamalı.
5. UMP reklam consent'i ile Analytics consent'inin ayrı mekanizmalar olduğu
   açıkça doğrulanmalı; biri diğerinin yerine geçmiş gibi beyan edilmemeli.
6. Politika URL'si ve Play Data Safety yanıtları gerçek production build ve
   Firebase Console ayarlarıyla karşılaştırılmadan yayın onayı verilmemeli.

## Diğer açık doğrulamalar

1. Play kapalı test sayacı ve 14 günlük koşul bir sonraki Play Console erişiminde
   tarihli ekran kanıtıyla yeniden okunmalı.
2. Sheet'te yeni soru olayı ve bekleyen soru düzeltmeleri yeniden incelenmeli.
3. Production Firebase Functions, Firestore Rules ve index deploy envanteri
   canlı projeden doğrulanmalı.
4. UMP onay akışı uygun EEA test bölgesinde doğrulanmalı.
5. Canlı Düello iki güncel kapalı test cihazında uçtan uca test edilmeli.
6. Telefon, tablet, Chromebook, PC ve XR mağaza varlıklarının Play Console
   yükleme durumu canlı ekrandan doğrulanmalı.
7. Levent onayıyla PR #20 release'e merge edilirse release head yeniden
   doğrulanmalı; eski RC2 #322 rerun edilmeden yeni `android-apk.yml`
   workflow_dispatch koşusu `confirmation=CLOSED_TEST` ile oluşturulmalı. Bu
   dokümantasyon görevi merge, RC2 veya Play yüklemesi yapmaz.
8. Yeni RC2'de `disable animations: false`, KVM erişimi ve project validator
   başlangıcı logdan doğrulanmalı; attempt 1 açık infrastructure quartet üretirse
   temiz attempt 2'nin gerçekten başladığı ayrıca kanıtlanmalı. Daha geniş
   Misafir → Oyna AAB-derived kapısı PASS olmadan Play yüklemesi yapılmamalı.
