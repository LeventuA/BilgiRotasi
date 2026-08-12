# Bilgi Rotası - Görev Havuzu

## P0 - Kapalı Test ve soru kalitesi

### BR-P0-001 - Kapalı Test canlı durumunu doğrula

**Durum:** İZLENİYOR

- Son doğrulanan: 12 geçerli testçi
- Son doğrulanan: 4 kesintisiz gün
- Testten ayrılanlar
- Son aktif AAB
- Play Console'un güncel üretim erişimi koşulları

**Bitti ölçütü:** Ekran kanıtı ve tarih `BILGI_ROTASI_DURUM.md` dosyasına yazılır.

---

### BR-P0-002 - 14 açıkça bozuk soruyu düzelt

**Durum:** AÇIK

Liste: `SORU_GERI_BILDIRIM_HAVUZU.md`

**Bitti ölçütü:**

- Gerçek JSON kayıtları incelendi.
- Şıklar ve cevap indeksleri düzeltildi.
- QA/test geçti.
- Ayrı PR merge edildi.
- Yeni AAB Kapalı Test'e yüklendi.
- Sheet satırları bundan sonra kapatıldı.

---

### BR-P0-003 - Kalan 26 benzersiz geri bildirimi değerlendir

**Durum:** AÇIK

- 8 zorluk adayı
- 4 eski açık kayıt
- 13 değerlendirilmemiş soru
- 1 değişiklik gerektirmeyen kayıt

---

### BR-P0-004 - Ödüllü reklam hak sistemi

**Durum:** UYGULANDI / CI PASS / RELEASE'E ENTEGRE / fiziksel cihaz kabulü bekliyor

Kaynak Draft PR #13 açık ve merge edilmemiştir. İşlevsel değişiklik PR #16 entegrasyonu üzerinden release dalına ulaşmıştır.

İstenen:

- tamamlanan oyun başına 1 hak
- aynı oyun için tekrar yok
- yeni tamamlanan oyunla yeniden hak
- günlük/oturumluk toplam kota yok
- +10 XP

---

### BR-P0-005 - Final kapalı-test entegrasyon adayını doğrula

**Durum:** PR #16 İLE RELEASE'E MERGE EDİLDİ

- Dal: `integration/closed-test-next-release`
- Kaynak PR #13 ve PR #15 açık/Draft kalır; PR #14 merge edilmiştir.
- Oyun-başına ödül hakkı ve başarılı ödüllü reklam telemetrisi birlikte korunur.
- Merge tek başına yeni RC2/AAB/Play yayını değildir.

---

### BR-P0-006 - Android 16 AdMob PR kapısını kanıta dayalı yap

**Durum:** UYGULANDI / CI PASS / PR #19 İLE RELEASE'E MERGE EDİLDİ

- Dal/PR: `fix/rc2-recurring-system-anr-retry`, PR #19.
- Run #102 kök nedeni emulator Android paket servisinde `Broken pipe (32)`; uygulama kurulmadan oluşan altyapı hatası.
- Kritik ADB komutları sınırlı retry kullanır; yalnız açık altyapı kanıtı temiz ikinci emülatörü açar.
- Uygulama crash/ANR/FATAL/process-death ve kanıtsız kapı hataları FAIL kalır.
- GitHub run #103 (`31519334862`), job `93872230451`: PASS; artifact `9113075092`.
- PR #19 merge commit'i: `8a99530de7cb370d4db0edff9214ad833a8907cf`.

---

### BR-P0-007 - RC2 runner pre-script ADB hatasını kaldır

**Durum:** TAMAMLANDI / PR #20 RELEASE'E MERGE EDİLDİ

- Run #322: `31528674369`; job `93903134897`; artifact `9117187216`.
- Kesin kök neden: `android-emulator-runner`, proje validator'ından önce `disable-animations` settings çağrısında `Broken pipe (32)` aldı.
- Artifact'ta `ANDROID16_*` raporu yoktu; validator hiç başlamadı.
- Dal: `fix/rc2-runner-pre-script-adb-failure`.
- Her iki Android 16 attempt'i `disable-animations: false` kullanır; mandatory uygulama/release gate'leri değiştirilmedi.
- Run #106/#108 emulator servis/KVM sorunlarını ortaya çıkardı; uygulama crash/ANR kanıtı yoktu.
- Son kod değişikliği head'i `18db0393b18fc661cb532a8d4e1b09653bba4259` için run #109 (`31553712368`, job `93981640719`) PASS; artifact `9125437699`.
- Docs head'i için run #110 (`31567372445`) PASS.
- PR #20 merge edildi; release head `1a113a6aba98324b668aa5f037fa6b08c7d776c3` oldu.

**Bitti ölçütü:** PR #20 merge edildi ve fresh RC2 validator'a ulaşabildi. Sonraki RC2'daki ayrı consent-gate problemi BR-P0-008'e taşındı.

---

### BR-P0-008 - RC2 analytics consent popup kapısını doğrula

**Durum:** UYGULANDI / PR #21 KOD CI PASS / MERGE ONAYI BEKLİYOR

- RC2 #323: run `31568589298`, job `94025527635`, artifact `9130712889`, release SHA `1a113a6aba98324b668aa5f037fa6b08c7d776c3`.
- #323'te `APK_INSTALL=PASS`, `APP_LAUNCH=PASS`; Bilgi Rotası crash/ANR/FATAL/process-death kanıtı yok.
- Sonuç `RESULT=FAIL`, `RELEASE_GATE=FAIL`, `REASON=MANDATORY_APP_GATE_INCOMPLETE`.
- Kesin kök neden: `Kullanım Analizine İzin Verilsin mi?` penceresi hâlâ açıkken eski validator tek dokunuştan sonra `ANALYTICS_CONSENT_HANDLED=PASS` yazdı.
- #323 OCR kanıtında `Şimdi Değil` aksiyonu yaklaşık `y=1240`; eski fallback `760 1065` yanlış bölgedeydi.
- Dal: `fix/rc2-analytics-consent-gate`.
- Son kod değişikliği commit'i: `2b247e9c86d00827e4539ac442ff9f242b6931ee` — `fix: verify Android 16 analytics consent dismissal`.
- Validator `Değil` eşleşmesini önceliklendirir, `Şimdi`yi fallback kullanır; koordinat fallback'i `785 1240`.
- Tek ADB tap artık PASS değildir. `ANALYTICS_CONSENT_HANDLED=PASS` yalnız auth ekranında `Google|Misafir` gerçekten görüldükten sonra yazılır.
- Bounded retry ve emulator unhealthy exit `75` korunur; mandatory app/release gate'leri gevşetilmez.
- Yeni regression testi yanlış erken PASS'i, OCR önceliğini, fallback koordinatını ve infra exit `75` korumasını kilitler.
- PR #21 AdMob PR CI #112 (`31573637930`), job `94040784202`: PASS. Analyze+tüm testler, release APK, package/manifest, KVM, Android 16 cold-start attempt 1, classifier, final app gate ve artifact upload PASS; attempt 2 SKIPPED.
- Artifact: `BilgiRotasi-AdMob-1.68.14-104-kanitlari`, ID `9132178688`, digest `sha256:2fea7fcc9b3d3acde16d08a56912a980476245d20b34dbb05baac1229460eb7ef`.
- #112 geniş Guest/Misafir → Oyna RC2 değildir; gerçek consent davranışı fresh RC2 ile ayrıca doğrulanacaktır.
- PR #21 açık/Draft; Levent açık onayı olmadan merge edilmeyecek.
- #323 rerun edilmeyecek.

**Bitti ölçütü:**

- PR #21'in son head CI'ı PASS.
- Levent açık onayıyla PR #21 release'e merge edildi.
- Merge sonrasında release head/sürüm yeniden doğrulandı.
- Eski #323 rerun edilmeden fresh `android-apk.yml` koşusu `confirmation=CLOSED_TEST` ile oluşturuldu.
- Fresh RC2'de analytics consent gerçekten kapanıyor.
- `APK_INSTALL`, `APP_LAUNCH`, `GUEST_LOGIN`, `HOME_OYNA`, `APP_PID`, `APP_LOGCAT`, `APP_GATE`, `RELEASE_GATE` tamamı PASS.
- Bu gate PASS olmadan Play'e AAB yüklenmedi.

---

## P1 - Teknik doğrulama

### BR-P1-001 - GitHub canlı envanteri

**12 Ağustos 2026 doğrulaması:**

- Kanonik repo: `ZMilaStudio/BilgiRotasi`
- Release head: `1a113a6aba98324b668aa5f037fa6b08c7d776c3`
- Release sürümü: `1.68.14+104`
- PR #20: merge edildi
- PR #21: açık/Draft; son kod değişikliği `2b247e9c86d00827e4539ac442ff9f242b6931ee`; kod CI #112 PASS
- PR #13: açık/Draft; ödüllü reklam işi release'e entegre, fiziksel kabul bekliyor
- PR #15: açık/Draft; değişiklikleri PR #16 üzerinden release'e ulaştı
- Android geliştirici doğrulaması: tamamlandı
- Son Play bilgisi: 12 geçerli testçi / 4 kesintisiz gün; UI yeniden okuması açık

### BR-P1-002 - Firebase production envanteri

- Auth sağlayıcıları
- SHA kayıtları
- Functions
- Firestore rules/indexes
- Dev/prod ayrımı

### BR-P1-003 - Canlı Düello release doğrulaması

- 10/20/30
- otomatik eşleştirme
- aynı sorular
- skor/ilerleme
- maç sonucu
- BR/lig tek sefer işleme
- iki telefon testi
- kopma/ayrılma akışları

### BR-P1-004 - UMP testi

Türkiye dışı uygun test bölgesi/debug yöntemiyle onay formını doğrula.

### BR-P1-005 - Oyun modları ve piyon sistemini sadeleştir — UYGULANDI / DRAFT PR BEKLİYOR

- Diğer Oyun Modları üst alanı ve kartları kompaktlaştırıldı.
- Aile Modu ve Turnuva Modu girişleri kaldırıldı.
- Ayrı piyon nadirlik modeli/girişi kaldırıldı; ana katalog ve favori/fallback davranışı korunur.
- Hedefli testler ve sistem smoke testleri PASS'tir.

### BR-P1-006 - Pseudonymous kapalı test kullanım telemetrisi — RELEASE'E ENTEGRE

- Merkezi ve hata yalıtımlı Firebase Analytics katmanı eklendi.
- Analytics varsayılan kapalı; açık kullanıcı tercihi cihazda saklanır ve geri alınabilir.
- `app_process_started`, ekran ve sınırlı oyun yaşam döngüsü olayları hesap kimliği içermeyen parametrelerle ölçülür.
- Advertising ID ve Analytics reklam kişiselleştirme sinyalleri kapalıdır.
- Play Data Safety/gizlilik ve gerçek production consent doğrulamaları yayın öncesi açık görevdir.

---

## P2 - Görsel ve pazarlama

### BR-P2-001 - 3B tahta için 6 rozet eşlemesini çöz

Çalışmaya yeniden başlamadan önce gerçek 6 kategori ve 8 konsept arasındaki seçim netleşmeli.

### BR-P2-002 - Numaralı geometri önizlemesi

67 node'u görsel debug katmanında doğrula. Onay alınmadan süsleme veya APK yok.

### BR-P2-003 - Profesyonel tanıtım videosu

Eski setleri yeniden kullanma. Gerçek kurgu, efekt, ses ve güçlü açılış üret.

### BR-P2-004 - Mağaza varlık denetimi

Telefon, tablet, Chromebook, PC ve XR için `hazır / yüklendi / reddedildi / yeniden yapılacak` durumunu canlı Play Console ile kaydet.

---

## P3 - Yayın sonrası

- Dünya Turnuvası
- Gelişmiş lig sezonları
- Klan
- Raid
- Günün Sorusu
- Dünya Haritası
- Arkadaşımla Oyna oda kodu
