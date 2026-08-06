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

**Durum:** UYGULANDI — TEST/CI/PR BEKLİYOR

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
- birim testleri ürün kararına göre güncellendi,
- tahtadaki rastgele joker reklamına dokunulmadı.

**Bitti ölçütü:**

- hedefli testler ve CI geçti,
- diff incelendi,
- Draft PR açıldı,
- fiziksel cihazda reklam/XP davranışı doğrulandı,
- Levent onayıyla merge edildi.

---

## P1 - Teknik doğrulama

### BR-P1-001 - GitHub canlı envanteri

**Durum:** KISMEN TAMAMLANDI

6 Ağustos 2026 doğrulananlar:

- Kanonik repo: `ZMilaStudio/BilgiRotasi`
- Release branch: `release/final-closed-test-aab-1.68.8`
- Release head: `548e8d3046469688a8dcb050552956cf786e525c`
- Sürüm: `1.68.13+103`
- PR #7: açık / Draft / merge edilmemiş
- PR #6: eski hotfix / açık / Draft
- PR #12: deterministik geometri / açık / Draft
- Birleşik güncelleme dalı: `update/closed-test-next-release`

Açık kalanlar:

- son birleşik güncelleme CI durumu,
- son AAB kaynak commit'i ve artifact kanıtı,
- PR #9 / #10 merge commitlerinin ayrıntılı envanteri.

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
