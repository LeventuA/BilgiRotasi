# Bilgi Rotası - Güncel Proje Durumu

**Kesim noktası:** 4 Ağustos 2026 gecesi  
**Durum sınıfları:** `DOĞRULANDI`, `RAPORLANDI`, `AÇIK`, `DURDURULDU`

---

## 1. Yayın kaynağı

| Alan | Kesim noktasındaki değer | Durum | Kaynak |
|---|---|---|---|
| Repo | `LeventuA/BilgiRotasi` | DOĞRULANDI | S01, S02, S07 |
| Android paket adı | `com.leventua.bilgirotasi` | DOĞRULANDI | S04 |
| Yayın/release dalı | `release/final-closed-test-aab-1.68.8` | RAPORLANDI | S06, S07, S09 |
| Gerçek paket sürümü | `1.68.13+103` | RAPORLANDI ve birden çok kaynakla uyumlu | S06, S07, S09 |
| `main` dalı | Güncel yayın kaynağı değil | KESİN KARAR | S06, S07, S09 |
| PR #9 | Merge edildi | RAPORLANDI | S07, S09 |
| PR #10 | Merge edildi | RAPORLANDI | S06, S07, S09 |
| PR #7 | Draft ve merge edilmemiş olarak son görüldü | CANLI DOĞRULANACAK | S09 |
| PR #8 | Kapatıldı, merge edilmedi | RAPORLANDI | S07, S09 |

**Kural:** Branch adındaki `1.68.8`, paket sürümü değildir. Sürüm hedef dalın `pubspec.yaml` dosyasından okunmalıdır.

---

## 2. Google Play

- `1.68.13+103` önce Dahili Test'te gerçek cihazda doğrulandı.
- Aynı AAB mevcut Kapalı Test kanalına yayımlandı.
- Son konuşmalarda görülen kapalı test katılımcı sayısı **6** idi; canlı sayı değildir.
- Testçi sayısı ve 14 günlük süreç Play Console'dan yeniden kontrol edilmelidir.
- Uygulama kaydı, paket adı ve ilk AAB yükleme süreci daha önce adım adım tamamlandı.
- Play App Signing SHA değeri production Firebase'e eklenmişti; eski upload/release SHA silinmedi.

**Durum:** Kapalı Test yayını `DOĞRULANDI/RAPORLANDI`; katılım süreci `AÇIK`.

---

## 3. Soru bankası

- Son raporlanan aktif soru sayısı: **8.710**
- Eski 6.710 soruya 2.000 Türkiye odaklı kolay soru eklenmişti.
- Son Sheet konuşmasında hiçbir yeni kayıt `Düzeltildi` yapılmadı.
- Son kontrol kesiminde **41 bekleyen olay / 40 benzersiz soru** bulunduğu hesaplanıyor.
- İlk ayıklamada:
  - 14 benzersiz soru açıkça bozuk,
  - 8 soru zorluk incelemesi adayı,
  - 4 eski kayıt ayrıntılı inceleme bekliyor,
  - 13 soru henüz tek tek değerlendirilmemiş,
  - 1 soru için değişiklik gerekmiyor.

Ayrıntılı liste: `SORU_GERI_BILDIRIM_HAVUZU.md`

---

## 4. Soru geri bildirim taşıma sistemi

Son canlı kontrollerde:

- Eski cihaz kuyruğundaki kayıtlar Sheet'e aktarılabildi.
- `1.68.13+103` sürümünden kuyruk dışı canlı kayıtlar Sheet'e ulaştı.
- Bu nedenle geri bildirim taşıma sistemi çalışıyor kabul edilir.
- Ancak soru düzeltme süreci henüz başlamadı veya tamamlanmadı.
- Sheet kayıtları gerçek soru düzeltmesi merge edilmeden kapatılmamalıdır.

**Durum:** Taşıma `DOĞRULANDI`; içerik temizliği `AÇIK`.

---

## 5. 3B oyun tahtası

- Oynanış ve BoardMap değişmeyecek.
- Tahta sözleşmesi 67 noktadır:
  - 30 dış kategori,
  - 30 iç kategori,
  - 6 rozet,
  - 1 merkez.
- Tek Matrix4 ile bütün 2B tahtayı eğme yaklaşımı başarısız bulundu.
- `experiment/original-board-3d-v1` silindi.
- `experiment/true-3d-board-renderer-v2` açıldı; konuşma kesiminde gerçek renderer commit'i yoktu.
- Hiçbir 3B çalışma release dalına merge edilmedi.
- Son görsel kabul edilmedi ve çalışma durduruldu.
- 8 adet kategori rozeti konsepti üretildi; tahtadaki 6 fiziksel rozet noktasına eşleme çözülmedi.

**Durum:** `DURDURULDU`; çalışan oyuna etkisi yok.

---

## 6. Oyun ve hesap sistemleri

Konuşma ve test kayıtlarında mevcut olduğu görülen ana sistemler:

- 2-6 kişilik yerel tahta oyunu
- Serbest Rota
- Soru Maratonu
- Günlük Görev
- Hayatta Kalma
- 60 Saniye
- Aile, Takım ve Turnuva modları
- 10 / 20 / 30 soruluk Meydan Okuma
- Canlı Düello altyapısı ve oyun akışı
- BR ve lig sistemi
- Google giriş / misafir ayrımı
- Bulut kayıt
- Hesap silme
- XP, seviye, başarımlar
- Bilgi Rotası Pasaportu
- Piyon koleksiyonu ve nadirlik
- Temalar, jokerler, özel kutular
- Erişilebilirlik ve Sistem Sağlığı

**Dikkat:** Yeni teknik çalışma öncesi canlı release dalında ilgili modülün gerçekten bulunduğu ve testlerin geçtiği doğrulanmalıdır.

---

## 7. Reklam

Kesim noktasındaki proje kararına göre:

- Aktif soru ve kritik oyun akışlarında reklam bulunmamalı.
- Banner yalnız uygun menü/sonuç ekranlarında kullanılmalı.
- Ödüllü reklam isteğe bağlı olmalı.
- Ödül: `+10 XP`
- Günlük toplam kota kaldırılmalı.
- Her tamamlanan oyun bir adet ödüllü reklam hakkı üretmeli.
- Aynı oyun sonucu ikinci kez ödül vermemeli.

**Durum:** Son kota değişikliği `AÇIK`; uygulanıp uygulanmadığı canlı koddan doğrulanmalı.

---

## 8. Mağaza ve tanıtım

Hazırlanan varlıklar arasında:

- 8 telefon görseli
- Tablet görsel seti planı/çalışması
- 600 x 400 PC logosu
- 6 PC ekran görüntüsü
- 6 Android XR görseli
- Instagram kare görsel seti

bulunuyor.

Tanıtım videolarının 15/30/60 saniyelik birçok seti üretildi; Levent tarafından yetersiz bulundu. Onaylı final tanıtım videosu yoktur.

Ayrıntı: `MAGAZA_VE_TANITIM_VARLIKLARI.md`

---

## 9. Şu anda ilk yapılacak işler

1. Play Console'dan canlı kapalı test sayısını ve süreyi doğrula.
2. Sheet'teki soru geri bildirimlerini soru bankasının gerçek kayıtlarıyla incele.
3. Açıkça bozuk sorular için release dalından ayrı düzeltme branch'i aç.
4. Soru düzeltmelerini test et, PR aç, incele ve merge et.
5. Yeni AAB'yi mevcut Kapalı Test kanalına güncelleme olarak yükle.
6. Ödüllü reklamın oyun başına hak kararını canlı kodda doğrula ve gerekiyorsa uygula.
7. 3B tahta çalışmasına, geometri ve 6-rozet eşlemesi çözülmeden dönme.
