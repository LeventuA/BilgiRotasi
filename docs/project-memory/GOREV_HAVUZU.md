# Bilgi Rotası - Görev Havuzu

## P0 - Kapalı Test ve soru kalitesi

### BR-P0-001 - Kapalı Test canlı durumunu doğrula

**Durum:** AÇIK

- Katılımcı sayısı
- Gerekli süre/sayaç
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

### BR-P0-004 - Ödüllü reklam hak sistemini doğrula/uygula

**Durum:** AÇIK

İstenen:

- tamamlanan oyun başına 1 hak
- aynı oyun için tekrar yok
- yeni tamamlanan oyunla yeniden hak
- günlük/oturumluk toplam kota yok
- +10 XP

---

## P1 - Teknik doğrulama

### BR-P1-001 - GitHub canlı envanteri

- Release branch head
- PR #7
- PR #9 / #10 merge commitleri
- Açık deney branch'leri
- Son AAB kaynak commit'i
- `pubspec.yaml`
- CI durumu

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

---

## P2 - Görsel ve pazarlama

### BR-P2-001 - 3B tahta için 6 rozet eşlemesini çöz — İPTAL/KAPATILDI

8 alternatif rozet konsepti kullanıcı kararıyla tamamen iptal edildi. Eşleme
yapılmayacak; tahtada yalnız Coğrafya, Eğlence, Tarih, Sanat & Edebiyat,
Bilim & Doğa ve Spor kategorileri kullanılacak.

### BR-P2-002 - Numaralı geometri önizlemesi — TEKNİK ÜRETİM TAMAMLANDI

67 node canlı `BoardMap` bağlantılarıyla görsel debug katmanında doğrulandı.
Deterministik SVG ve 4096x4096 PNG üretildi; altı dış aralık, altı iç yol ve alt
Spor yolu `1-5` işaretleriyle görünür. Sonraki kapı kullanıcı görsel onayıdır;
onay alınmadan süsleme, perspektif/3B, Flutter veya APK yok.

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
