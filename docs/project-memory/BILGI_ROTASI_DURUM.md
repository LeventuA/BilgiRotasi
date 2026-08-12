# Bilgi Rotası - Güncel Proje Durumu

**Kesim noktası:** 12 Ağustos 2026
**Durum sınıfları:** `DOĞRULANDI`, `RAPORLANDI`, `AÇIK`, `DURDURULDU`

---

## 1. Yayın kaynağı

| Alan | Kesim noktasındaki değer | Durum | Kaynak |
|---|---|---|---|
| Kanonik repo | `ZMilaStudio/BilgiRotasi` | DOĞRULANDI | 12 Ağustos 2026 GitHub canlı sorgusu |
| Android paket adı | `com.leventua.bilgirotasi` | DOĞRULANDI | Canlı repo |
| Yayın/release dalı | `release/final-closed-test-aab-1.68.8` (`1a113a6aba98324b668aa5f037fa6b08c7d776c3`) | DOĞRULANDI | 12 Ağustos 2026 GitHub canlı sorgusu |
| Gerçek paket sürümü | `1.68.14+104` | DOĞRULANDI | Release dalındaki `pubspec.yaml`, 12 Ağustos 2026 |
| `main` dalı | Güncel yayın kaynağı değil | KESİN KARAR | Proje kararı |
| PR #13 | Kaynak PR açık/Draft; işlevsel ödüllü reklam düzeltmesi PR #16 ile release'e ulaştı; fiziksel cihaz kabulü bekleniyor | DOĞRULANDI / RAPORLANDI | GitHub canlı durumu |
| PR #14 | Merge edildi (`10 Ağustos 2026`) | DOĞRULANDI | GitHub canlı PR metadata’sı |
| PR #15 | Kaynak PR açık/Draft; değişiklikleri PR #16 üzerinden release'e ulaştı | DOĞRULANDI | GitHub canlı PR metadata’sı |
| PR #19 | Merge edildi (`11 Ağustos 2026`); merge commit `8a99530de7cb370d4db0edff9214ad833a8907cf` | DOĞRULANDI | GitHub canlı PR metadata’sı |
| PR #20 | Merge edildi; release head'i `1a113a6aba98324b668aa5f037fa6b08c7d776c3` oldu | DOĞRULANDI | 12 Ağustos 2026 GitHub canlı PR/release doğrulaması |
| PR #21 | Açık/Draft; son kod değişikliği commit'i `2b247e9c86d00827e4539ac442ff9f242b6931ee`; kod CI #112 PASS; merge onayı bekleniyor | DOĞRULANDI | 12 Ağustos 2026 GitHub canlı PR/Actions doğrulaması |
| Kapalı test entegrasyon adayı | `integration/closed-test-next-release`; PR #16 ile release'e merge edildi (`10 Ağustos 2026`) | DOĞRULANDI | GitHub canlı PR metadata’sı |
| Android geliştirici doğrulaması | Tamamlandı | RAPORLANDI | Levent'in güncel Play doğrulaması |

**Kural:** Branch adındaki `1.68.8`, paket sürümü değildir. Sürüm hedef dalın `pubspec.yaml` dosyasından okunmalıdır.

---

## 2. Google Play

- `1.68.13+103` önce Dahili Test'te gerçek cihazda doğrulandı.
- Aynı AAB mevcut Kapalı Test kanalına yayımlandı.
- Son doğrulanan Play kapalı test durumu **12 geçerli testçi / 4 kesintisiz gün**dür.
- 8 Ağustos 2026'da Play Console'a bağlı tarayıcı bulunmadığı için sayaç UI'dan yeniden okunamadı; bir sonraki canlı kontrolde tarih/sayaç yeniden okunmalıdır.
- Android geliştirici doğrulaması tamamlandı.
- Play App Signing SHA değeri production Firebase'e eklenmişti; eski upload/release SHA silinmedi.
- `1.68.14+104` için yeni RC2 henüz release gate'i geçmediği için Play'e yeni AAB yüklenmemelidir.

**Durum:** Kapalı Test yayını `DOĞRULANDI/RAPORLANDI`; katılım süreci `AÇIK`.

---

## 3. Soru bankası

- Son raporlanan aktif soru sayısı: **8.710**.
- Eski 6.710 soruya 2.000 Türkiye odaklı kolay soru eklenmişti.
- Son Sheet konuşmasında hiçbir yeni kayıt `Düzeltildi` yapılmadı.
- Son kontrol kesiminde **41 bekleyen olay / 40 benzersiz soru** bulunduğu hesaplanıyor.
- İlk ayıklamada 14 benzersiz soru açıkça bozuk, 8 soru zorluk incelemesi adayı, 4 eski kayıt ayrıntılı inceleme bekliyor, 13 soru henüz tek tek değerlendirilmemiş ve 1 soru için değişiklik gerekmiyor.

Ayrıntılı liste: `SORU_GERI_BILDIRIM_HAVUZU.md`

---

## 4. Soru geri bildirim taşıma sistemi

- Eski cihaz kuyruğundaki kayıtlar Sheet'e aktarılabildi.
- `1.68.13+103` sürümünden kuyruk dışı canlı kayıtlar Sheet'e ulaştı.
- Geri bildirim taşıma sistemi çalışıyor kabul edilir.
- Soru düzeltme süreci tamamlanmadı.
- Sheet kayıtları gerçek soru düzeltmesi merge edilmeden kapatılmamalıdır.

**Durum:** Taşıma `DOĞRULANDI`; içerik temizliği `AÇIK`.

---

## 5. 3B oyun tahtası

- Oynanış ve BoardMap değişmeyecek.
- Tahta sözleşmesi 67 noktadır: 30 dış kategori, 30 iç kategori, 6 rozet, 1 merkez.
- Tek Matrix4 ile bütün 2B tahtayı eğme yaklaşımı başarısız bulundu.
- `experiment/original-board-3d-v1` silindi.
- `experiment/true-3d-board-renderer-v2` açıldı; gerçek renderer commit'i doğrulanmadan güncel kabul edilmez.
- Hiçbir 3B çalışma release dalına merge edilmedi.
- Son görsel kabul edilmedi ve çalışma durduruldu.
- 8 kategori rozeti konsepti ile tahtadaki 6 fiziksel rozet noktası arasındaki eşleme çözülmedi.

**Durum:** `DURDURULDU`; çalışan oyuna etkisi yok.

---

## 6. Oyun ve hesap sistemleri

Konuşma ve test kayıtlarında mevcut olduğu görülen ana sistemler:

- 2-6 kişilik yerel tahta oyunu
- Serbest Rota, Soru Maratonu, Günlük Görev
- Hayatta Kalma, 60 Saniye, Takım modu ve diğer hızlı oyun modları
- 10 / 20 / 30 soruluk Meydan Okuma
- Canlı Düello altyapısı ve oyun akışı
- BR ve lig sistemi
- Google giriş / misafir ayrımı
- Bulut kayıt ve hesap silme
- XP, seviye, başarımlar ve Bilgi Rotası Pasaportu
- Piyon koleksiyonu ve güvenli favori piyon seçimi
- Temalar, jokerler, özel kutular
- Erişilebilirlik ve Sistem Sağlığı

**Dikkat:** Yeni teknik çalışma öncesi canlı release dalında ilgili modülün gerçekten bulunduğu ve testlerin geçtiği doğrulanmalıdır.

`codex/simplify-game-modes-pawn-rarity` dalındaki sadeleştirme ayrı feature çalışmasıdır. Aile Modu/Turnuva Modu girişleri ile ayrı piyon nadirlik sistemi kaldırılmış; ana piyon kataloğu ve favori/fallback davranışı korunmuştur. Release'e merge edilmiş sayılmaz.

---

## 7. Reklam ve telemetri

- Aktif soru ve kritik oyun akışlarında reklam bulunmamalı.
- Banner yalnız uygun menü/sonuç ekranlarında kullanılmalı.
- Ödüllü reklam isteğe bağlıdır; ödül `+10 XP`.
- Her tamamlanan oyun bir ödüllü reklam hakkı üretir; aynı oyun sonucu ikinci kez ödül vermez.
- İşlevsel reklam düzeltmesi PR #16 üzerinden release'e ulaştı; fiziksel cihaz kabulü hâlâ açıktır.
- Pseudonymous Firebase Analytics telemetrisi PR #16 üzerinden release'e ulaştı.
- Analytics varsayılan kapalıdır; kullanıcı açıkça izin vermeden `analytics_storage` etkinleştirilmez.
- `Şimdi Değil` aynı sürümde yeniden sormaz; kullanıcı daha sonra Ayarlar'dan izin verebilir.
- Advertising ID toplaması ve Analytics reklam kişiselleştirme sinyalleri kapalıdır.
- Analytics hataları oyun akışını engellemez.

**Durum:** Reklam/telemetri kodu release'te; fiziksel reklam kabulü ve yayın öncesi Data Safety/consent doğrulamaları `AÇIK`.

---

## 7A. Kapalı test yayın adayı entegrasyonu

- `integration/closed-test-next-release` PR #16 ile release'e merge edildi.
- Kaynak PR #13 ve PR #15 açık/Draft kalır; PR #14 merge edilmiştir.
- Bu merge tek başına yeni RC2, AAB üretimi veya Play Console yayını kanıtı değildir.

---

## 7B. Android 16 AdMob PR doğrulama altyapısı

- PR #19 ile kritik ADB komutlarında sınırlı retry ve açık emulator altyapı sınıflandırması release'e taşındı.
- Bilgi Rotası crash/ANR/FATAL/process-death ve kanıtsız uygulama kapısı hataları retry edilmez ve FAIL kalır.
- PR #19 doğrulama run #103 (`31519334862`, job `93872230451`) PASS; artifact `9113075092`.

---

## 7C. RC2 #322 runner pre-script ADB hatası ve PR #20

- RC2 #322: run `31528674369`, job `93903134897`, artifact `9117187216`.
- Kesin kök neden: `android-emulator-runner`, proje validator'ı başlamadan önce `disable-animations` settings çağrısında `Broken pipe (32)` aldı.
- Artifact'ta `ANDROID16_*` raporu yoktu; validator hiç başlamadı. Bu uygulama crash/ANR kanıtı değildir.
- PR #20 her iki Android 16 attempt'inde `disable-animations: false` kullanacak ve KVM erişimini emulator öncesi fail-fast hazırlayacak biçimde düzeltildi.
- Ara run #106/#108 emulator servis/KVM sorunlarını ortaya çıkardı; uygulama crash/ANR kanıtı yoktu.
- Son kod değişikliği head'i `18db0393b18fc661cb532a8d4e1b09653bba4259` için AdMob PR run #109 (`31553712368`, job `93981640719`) PASS; artifact `9125437699`.
- Son docs head'i için run #110 (`31567372445`) PASS oldu.
- PR #20 Levent onayı sonrasında merge edildi; release head `1a113a6aba98324b668aa5f037fa6b08c7d776c3` oldu.

**Durum:** `TAMAMLANDI / MERGE EDİLDİ`. Sonraki doğrulama yeni RC2 ile yapıldı.

---

## 7D. RC2 #323 analytics consent kapısı hatası

- Yeni RC2 run #323: `31568589298`, job `94025527635`, release SHA `1a113a6aba98324b668aa5f037fa6b08c7d776c3`, artifact `9130712889`.
- `APK_INSTALL=PASS` ve `APP_LAUNCH=PASS` oluştu; uygulama PID/MainActivity sağlıklı kaldı ve Bilgi Rotası crash/ANR/FATAL/process-death kanıtı bulunmadı.
- Artifact sonucu `RESULT=FAIL`, `RELEASE_GATE=FAIL`, `REASON=MANDATORY_APP_GATE_INCOMPLETE` idi.
- Kesin neden: ilk açılıştaki `Kullanım Analizine İzin Verilsin mi?` penceresi ekranda kalmasına rağmen eski validator tek ADB dokunuşundan sonra `ANALYTICS_CONSENT_HANDLED=PASS` yazdı.
- #323 OCR kanıtında `Şimdi Değil` aksiyonu yaklaşık `y=1240` bölgesindeydi; eski fallback `760 1065` yanlış yükseklikteydi. Eski `Simdi|Şimdi|Degil|Değil` araması da ilk `Şimdi` eşleşmesini seçebiliyordu.
- Bu nedenle #323 **uygulama çökmesi değil, validator gate doğrulama hatasıdır**. #323 rerun edilmeyecek.

### PR #21 düzeltmesi

- Dal: `fix/rc2-analytics-consent-gate`.
- Son kod değişikliği commit'i: `2b247e9c86d00827e4539ac442ff9f242b6931ee` — `fix: verify Android 16 analytics consent dismissal`.
- Değişiklik yalnız `tools/validate_android16_closed_test.sh` ve yeni `test/android16_analytics_consent_gate_test.dart` dosyalarındadır.
- `Değil` OCR eşleşmesi önceliklidir; `Şimdi` yalnız fallback'tir.
- Koordinat fallback'i #323 kanıtına göre `785 1240` olarak güncellendi.
- Tek ADB tap artık PASS sayılmaz; consent bounded retry ile tekrar yakalanır ve `ANALYTICS_CONSENT_HANDLED=PASS` yalnız `Google|Misafir` auth ekranı gerçekten görüldükten sonra yazılır.
- Emulator unhealthy exit `75` sınıflandırması korunur; mandatory uygulama/release gate'leri gevşetilmedi.
- Regression testi yanlış erken PASS'i, OCR önceliğini, fallback koordinatını ve infra exit `75` korumasını kilitler.
- AdMob PR CI run #112 (`31573637930`), job `94040784202`: **PASS**. Analyze+tüm testler, release APK, package/manifest, KVM hazırlığı, Android 16 cold-start attempt 1, classifier, final app gate ve artifact yükleme adımları PASS; attempt 2 gerekmedi ve SKIPPED kaldı.
- #112 artifact: `BilgiRotasi-AdMob-1.68.14-104-kanitlari`, ID `9132178688`, digest `sha256:2fea7fcc9b3d3acde16d08a56912a980476245d20b34dbb05baac1229460eb7ef`.
- #112 AdMob cold-start CI'dır; gerçek `Kullanım Analizi → Misafir → Oyna` geniş RC2 kapısının yerine geçmez.

**Durum:** PR #21 açık/Draft; kod/CI doğrulaması PASS. Levent açık merge onayı bekleniyor. Merge edilmeden yeni RC2 başlatılmayacak; merge sonrasında eski #323 rerun edilmeden **yeni** RC2 oluşturulacak ve geniş Guest/Misafir → Oyna AAB-derived kapısı PASS olmadan Play'e AAB yüklenmeyecek.

---

## 8. Mağaza ve tanıtım

Hazırlanan varlıklar arasında telefon görselleri, tablet planı, PC logosu/ekran görüntüleri, Android XR görselleri ve Instagram kare seti bulunuyor. Tanıtım videolarının 15/30/60 saniyelik birçok seti üretildi; Levent tarafından yetersiz bulundu. Onaylı final tanıtım videosu yoktur.

Ayrıntı: `MAGAZA_VE_TANITIM_VARLIKLARI.md`

---

## 9. Şu anda ilk yapılacak işler

1. PR #21'in güncel head'i ve son CI sonucu doğrulanmalı; yalnız Levent'in açık onayıyla release'e merge edilmeli.
2. Merge sonrasında release head ve `pubspec.yaml` yeniden doğrulanmalı.
3. Eski RC2 #323 rerun edilmeden yeni `android-apk.yml` RC2 koşusu `confirmation=CLOSED_TEST` ile başlatılmalı.
4. Yeni RC2'de analytics consent penceresinin gerçekten kapanması; ardından `APK_INSTALL`, `APP_LAUNCH`, `GUEST_LOGIN`, `HOME_OYNA`, `APP_PID`, `APP_LOGCAT`, `APP_GATE` ve `RELEASE_GATE` değerlerinin tamamının PASS olması doğrulanmalı.
5. Yeni RC2 PASS olmadan Play Console'a yeni AAB yüklenmemeli.
6. Play kapalı test sayacı bir sonraki erişimde tarihli ekran kanıtıyla yeniden doğrulanmalı.
7. Sheet'teki soru geri bildirimleri gerçek soru kayıtlarıyla incelenmeli; gerçek düzeltme merge edilmeden Sheet satırı kapatılmamalı.
8. PR #13 ödüllü reklam değişikliğinin fiziksel cihaz kabul testi tamamlanmalı.
9. 3B tahta çalışmasına, geometri ve 6-rozet eşlemesi çözülmeden dönülmemeli.
