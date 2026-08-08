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

**Durum:** UYGULANDI / CI PASS / fiziksel cihaz kabulü bekliyor

Kaynak: Draft PR #13, head `ddad3e2fb6b6b8512281e053822cb3fc7a79f64a`.
PR merge edilmediği için release dalında henüz bulunmaz.

İstenen:

- tamamlanan oyun başına 1 hak
- aynı oyun için tekrar yok
- yeni tamamlanan oyunla yeniden hak
- günlük/oturumluk toplam kota yok
- +10 XP

---

## P1 - Teknik doğrulama

### BR-P1-001 - GitHub canlı envanteri

**8 Ağustos 2026 doğrulaması:**

- Kanonik repo: `ZMilaStudio/BilgiRotasi`
- Release head: `548e8d3046469688a8dcb050552956cf786e525c`
- Release sürümü: `1.68.13+103`
- PR #13: açık / Draft / merge edilmedi; ödüllü reklam işi UYGULANDI / CI PASS /
  fiziksel cihaz kabulü bekliyor
- PR #14: açık / Draft / merge edilmedi
- PR #15: açık / Draft / merge edilmedi; head
  `5e7dfe47200375458a6c4f6c40a83e3dab1f0489`
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

Türkiye dışı uygun test bölgesi/debug yöntemiyle onay formunu doğrula.

### BR-P1-005 - Oyun modları ve piyon sistemini sadeleştir — UYGULANDI / DRAFT PR BEKLİYOR

- Diğer Oyun Modları üst alanı ve kartları kompaktlaştırıldı.
- Sabit mod sayısı yerine `Farklı mücadele modları` başlığı kullanıldı.
- Aile Modu ve Turnuva Modu kartları/navigasyon girişleri kaldırıldı.
- Piyon kataloğu korunarak ayrı nadirlik modeli, ekranı, etiketleri ve
  nadirlik temelli görsel vurgu kaldırıldı.
- Favori piyon kaydı ile geçersiz eski indeks fallback'i korunur.
- Hedefli sadeleştirme testleri ve sistem smoke testleri PASS'tir.

### BR-P1-006 - Pseudonymous kapalı test kullanım telemetrisi — UYGULANDI / DRAFT PR BEKLİYOR

- `firebase_analytics` merkezi, hata yalıtımlı bir servis arkasına eklendi.
- Uygulama süreç başlangıcı, ekran, oyun seçimi/başlangıç/tamamlanma/yarıda bırakma,
  joker, ödüllü reklam ve Canlı Düello yaşam döngüsü olayları bağlandı.
- Parametre sözleşmesi hesap kimliği içermeyen oyun boyutlarıyla sınırlandı; kullanıcı kimliği ve
  serbest parametre haritası kabul edilmez.
- Firebase SDK'nın izin sonrasında pseudonymous app-instance ID ürettiği açıkça
  belgelenir; telemetri tam anonim olarak adlandırılmaz.
- Analytics varsayılan kapalıdır; açık kullanıcı tercihi cihazda saklanır,
  geri alınabilir ve izin yokken oyun eksiksiz çalışır.
- `app_process_started` yalnız uygulama süreç başlangıcını belirtir; GA oturum
  metriği olarak kullanılmaz ve oturum sayımı otomatik `session_start` ile yapılır.
- Tercih `unknown` ise sürüm başına bir kez zorlamayan izin istemi gösterilir;
  `Şimdi Değil` sonrasında kullanıcı Ayarlar'dan istediği zaman açabilir.
- Android Advertising ID toplaması ve Analytics reklam kişiselleştirme
  sinyalleri kapatıldı; reklam amaçlı consent değerleri reddedilir.
- Soru ekranındaki her dokunuş veya her cevap için olay üretilmez.
- Unit/widget sözleşme testleri Analytics hatalarının oyuna taşmadığını,
  izinli parametreleri ve adlandırılmış ekran ölçümünü doğrular.
- AAB üretimi/yayını bu görevin kapsamında değildir.

---

## P2 - Görsel ve pazarlama

### BR-P2-001 - 3B tahta için 6 rozet eşlemesini çöz

Çalışmaya yeniden başlamadan önce gerçek 6 kategori ve 8 konsept arasındaki seçim netleşmeli.

### BR-P2-002 - Numaralı geometri önizlemesi

67 node'u görsel debug katmanında doğrula. Onay alınmadan süsleme veya APK yok.

### BR-P2-003 - Profesyonel tanıtım videosu

Eski setleri yeniden kullanma. Gerçek kurgu, efekt, ses ve güçlü açılış üret.

### BR-P2-004 - Mağaza varlık denetimi

Telefon, tablet, Chromebook, PC ve XR için:
`hazır / yüklendi / reddedildi / yeniden yapılacak`

durumunu canlı Play Console ile kaydet.

---

## P3 - Yayın sonrası

- Dünya Turnuvası
- Gelişmiş lig sezonları
- Klan
- Raid
- Günün Sorusu
- Dünya Haritası
- Arkadaşımla Oyna oda kodu
