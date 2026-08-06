# Bilgi Rotası - Görev Havuzu

## P0 - Kapalı Test ve soru kalitesi

### BR-P0-001 - Kapalı Test canlı durumunu doğrula

**Durum:** KISMEN DOĞRULANDI / CANLI SAYAÇ İZLENECEK

6 Ağustos 2026 raporu:

- Aktif sürüm: `1.68.13+103`
- Yayın tarihi: 4 Ağustos 2026, 09:49
- Test listesi: 20 kişi
- Google'ın katılımcı saydığı: 12 kişi
- 14 günlük sürede geçen: 2 gün

Açık kalanlar:

- testten ayrılan kişi olup olmadığı,
- güncel sayaç ve üretim erişimi durumu,
- sonraki kontrol tarihindeki canlı katılımcı sayısı.

**Bitti ölçütü:** Güncel ekran kanıtı ve tarih `BILGI_ROTASI_DURUM.md` dosyasına yazılır.

---

### BR-P0-002 - Açıkça bozuk soruları düzelt

**Durum:** AÇIK / CANLI JSON ERİŞİMİ DOĞRULANACAK

Liste: `SORU_GERI_BILDIRIM_HAVUZU.md` ve 6 Ağustos 2026 canlı Sheet özeti.

6 Ağustos çalışmasında bağlı GitHub aracı büyük ve tek satırlı `assets/questions.json` içeriğini döndürmedi. Hedef kayıtlar canlı JSON'dan okunamadığı için dosyada değişiklik yapılmadı.

**Bitti ölçütü:**

- Gerçek JSON kayıtları eksiksiz incelendi.
- Her soru için metin, dört şık, doğru indeks, açıklama, kategori ve zorluk kontrol edildi.
- QA/test geçti.
- Birleşik güncelleme PR'ına girdi ve Levent onayıyla merge edildi.
- Yeni AAB Kapalı Test'e yüklendi.
- Sheet satırları ancak bundan sonra kapatıldı.

---

### BR-P0-003 - Kalan benzersiz geri bildirimleri değerlendir

**Durum:** AÇIK

- Hatalı soru bildirimleri
- Zorluk adayları
- Eski açık kayıtlar
- Henüz değerlendirilmemiş sorular
- Değişiklik gerektirmeyen kayıtlar

**Kural:** Tek zorluk oyuyla kör değişiklik yapılmaz. Soru içeriği canlı JSON ile eşleştirilmeden karar verilmez.

---

### BR-P0-004 - Ödüllü reklam hak sistemini doğrula/uygula

**Durum:** UYGULANDI — DRAFT PR #13 AÇIK — CI PASS — FİZİKSEL CİHAZ KABULÜ DOĞRULANACAK

İstenen:

- tamamlanan oyun başına 1 hak,
- aynı oyun için tekrar yok,
- yeni tamamlanan oyunla yeniden hak,
- günlük/oturumluk toplam kota yok,
- `+10 XP`.

6 Ağustos 2026'da `update/closed-test-next-release` dalında:

- `SupportRewardLimiter` içindeki günlük üç reklam sınırı kaldırıldı,
- yalnız aynı oyun kimliğinin tekrar kullanılması engellendi,
- boş oyun kimliği reddedildi,
- 200 kayıt sonrası eski oyunları silen budama kaldırıldı,
- hak kayıtları seri kuyruğa alınarak eşzamanlı farklı oyun taleplerinin birbirini ezmesi önlendi,
- reklam başarısızsa veya ödül callback'i gelmezse kalıcı hak yeniden okunup aynı ekranda tekrar deneme açık bırakıldı,
- birim ve regresyon testleri ürün kararına göre güncellendi,
- tahtadaki rastgele joker reklamına dokunulmadı,
- release tabanlı Draft PR #13 açık ve çatışmasız kaldı.

Eklenen test senaryoları:

- aynı oyun yalnız bir kez,
- farklı oyunlara genel kota yok,
- 250 oyun sonrası ilk oyuna yeniden hak yok,
- eşzamanlı aynı taleplerden yalnız biri kazanır,
- eşzamanlı farklı oyun taleplerinin ikisi de kalıcı tutulur,
- boş kimlik reddedilir,
- yeni limiter örneğinde tekrar yok,
- reklam callback başarısızsa ödül yok,
- başarısız reklamdan sonra hak sürüyorsa yeniden deneme var,
- ödül verildiyse kart yeniden açılmaz.

Kod/test commit'i: `f9d5ab900d0644a969d251ee9fd8e814650857af`.

CI kanıtı:

- Workflow run: `31111600703` / `success`
- Job: `92650502426` / `success`
- Flutter analiz: PASS
- Tüm testler: PASS
- İmzalı release APK: PASS
- Paket/sürüm/manifest/sertifika: PASS
- Android 16 emülatör cold-start ve logcat: PASS
- Artifact: `5395999980` (`bilgi-rotasi-release-apk`)
- Artifact SHA-256: `caf6033b51d233a9bce633b8ca19f69ab91ff2160c33b11b0ec7e50dc36eafd9`

**Bitti ölçütünde kalanlar:**

- fiziksel cihazda gerçek reklam/XP davranışı doğrulanır,
- production Firebase açıkken sonuç reklamı ürün davranışı netleştirilir,
- Levent onayıyla merge edilir.

---

## P1 - Teknik doğrulama

### BR-P1-001 - GitHub canlı envanteri

**Durum:** KISMEN TAMAMLANDI / PLAY AAB RUN EŞLEMESİ DOĞRULANACAK

6 Ağustos 2026 doğrulananlar:

- Kanonik repo: `ZMilaStudio/BilgiRotasi`
- Release branch: `release/final-closed-test-aab-1.68.8`
- Release head: `548e8d3046469688a8dcb050552956cf786e525c`
- Sürüm: `1.68.13+103`
- Son işlevsel release commit'i: `34e8df9291ff070f333ea4e6d375b48ed7d01754` (PR #10 merge)
- PR #6: eski hotfix / kapalı / merge edilmemiş / release hattı tarafından superseded
- PR #7: açık / Draft / güncel `1.68.13+103` release başlığı ve envanteri yazıldı
- PR #9: merge commit `25f283d87875c766697e43a7b0b9655ceff752b6`; güncel release içinde
- PR #10: merge commit `34e8df9291ff070f333ea4e6d375b48ed7d01754`; güncel release içinde
- PR #11: belge-only merge commit `548e8d3046469688a8dcb050552956cf786e525c`
- PR #12: deterministik geometri / açık / Draft / Codex'e bırakıldı / değiştirilmedi
- PR #13: birleşik güncelleme / açık / Draft / çatışmasız
- Birleşik güncelleme dalı: `update/closed-test-next-release`
- PR #13 kod/test commit'i: `f9d5ab900d0644a969d251ee9fd8e814650857af`
- PR #13 Actions run/job ve release APK artifact kanıtı doğrulandı.
- PR #10 merge commit'i üzerindeki `1.68.13+103` APK CI kanıtı doğrulandı:
  - run `30864581523`,
  - job `91853543414`,
  - artifact `8879320751`,
  - SHA-256 `3e8015f512b7710c9997aa7cad854f59aeee796cc2e72d9a3c3d5538f7174f69`.
- Release dalında production Firebase + test AdMob profilli, imzalı kapalı-test AAB üreten `workflow_dispatch` hattı doğrulandı.

Açık kalanlar:

- Play Console'a yüklenen `1.68.13+103` AAB'nin özgül workflow_dispatch run ID'si,
- yüklenen AAB'nin artifact ID ve SHA-256 değeri,
- bu AAB kanıtının Play Console sürüm kodu `103` ile birebir eşleştirilmesi.

**Kural:** APK artifact'i Play'e yüklenen AAB kanıtı sayılmaz.

### BR-P1-002 - Firebase production envanteri

**Durum:** AÇIK

- Auth sağlayıcıları
- SHA kayıtları
- Functions
- Firestore rules/indexes
- Dev/prod ayrımı

### BR-P1-003 - Canlı Düello release doğrulaması

**Durum:** AÇIK / CİHAZ GEREKİYOR

- 10/20/30
- otomatik eşleştirme
- aynı sorular
- skor/ilerleme
- maç sonucu
- BR/lig tek sefer işleme
- iki telefon testi
- kopma/ayrılma akışları

### BR-P1-004 - UMP testi

**Durum:** AÇIK / UYGUN TEST ORTAMI GEREKİYOR

Türkiye dışı uygun test bölgesi/debug yöntemiyle onay formunu doğrula.

---

## P2 - Görsel ve pazarlama

### BR-P2-001 - 3B tahta için 6 rozet eşlemesini çöz

**Durum:** AÇIK

Çalışmaya yeniden başlamadan önce gerçek 6 kategori ve 8 konsept arasındaki seçim netleşmeli.

### BR-P2-002 - Numaralı geometri önizlemesi

**Durum:** PR #12 AÇIK / LEVENT GÖRSEL ONAYI BEKLİYOR

67 node'u görsel debug katmanında doğrula. Onay alınmadan süsleme, Flutter veya APK yok.

### BR-P2-003 - Profesyonel tanıtım videosu

**Durum:** AÇIK

Eski setleri yeniden kullanma. Gerçek kurgu, efekt, ses ve güçlü açılış üret.

### BR-P2-004 - Mağaza varlık denetimi

**Durum:** AÇIK / PLAY CONSOLE ERİŞİMİ GEREKİYOR

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