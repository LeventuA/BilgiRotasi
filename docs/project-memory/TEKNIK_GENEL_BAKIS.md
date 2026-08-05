# Bilgi Rotası - Teknik Genel Bakış

---

## Teknoloji

- Flutter / Dart
- Android
- Firebase Authentication
- Cloud Firestore
- Google Sign-In
- Firebase Functions
- Google Mobile Ads / UMP
- SharedPreferences
- audioplayers
- share_plus
- url_launcher
- GitHub / GitHub Actions / Codespaces / Codex
- Python tabanlı kontrollü kurucu ve QA betikleri

---

## Kritik proje kimliği

```text
Repo: LeventuA/BilgiRotasi
Paket: com.leventua.bilgirotasi
Release dalı (son rapor): release/final-closed-test-aab-1.68.8
Sürüm (son rapor): 1.68.13+103
```

Bu değerler yeni teknik işten önce canlı depodan yeniden okunmalıdır.

---

## Önemli modül aileleri

### Ana oyun

- `lib/main.dart`
- tahta/BoardMap yapısı
- oyun modları
- piyon, zar, joker ve özel kutu modülleri
- kayıt ve ilerleme sistemleri

### Canlı Düello

Konuşmalarda kullanılan dosyalar arasında:

- `lib/live_duel_league.dart`
- `lib/live_duel_matchmaking.dart`
- `lib/live_duel_screen.dart`
- `lib/live_duel_questions.dart`
- `lib/live_duel_progress.dart`

bulunuyordu.

Branch konuşmasında doğrulanan tarihsel aşamalar:

- BR ve lig altyapısı
- 10/20/30 soru seçimi
- otomatik eşleştirme
- rakip arama ve iptal
- rakip bulundu / 3-2-1
- ortak soru kimlikleri
- cevap ve ilerleme altyapısı

Daha sonraki kaynaklarda modun mevcut oyuna dahil olduğu raporlanmıştır; canlı release kodu tekrar kontrol edilmelidir.

---

## Tahta sözleşmesi

- Merkez: node 0
- Toplam: 67 node
- BoardMap, rota, hedef, piyon ve dokunma alanları aynı koordinat sistemini kullanmalıdır.
- 3B renderer bu veriyi tüketmeli; ayrı bir oyun topolojisi üretmemelidir.

---

## Özel kutular ve joker geçmişi

Kaldırılan:

- Zar Tekrar jokeri
- İleri 2
- Geri 2

Korunan/yeni:

- Tekrar Zar At
- Rastgele Joker Kazan
- Kategori Seç
- Çifte Şans
- 50:50
- Soru Değiştir
- İkinci Şans
- Kategori Değiştir

Tarihsel dağılım ve sınıflar canlı release kodunda doğrulanmalıdır.

---

## Test ilkeleri

1. Fiziksel cihaz akışı
2. Entegrasyon/widget testi
3. Birim testi
4. Statik analiz
5. Build

“Build yeşil” tek başına “özellik çalışıyor” demek değildir.

3B ilk APK denemesinde 218 testin geçmesi, görsel yaklaşımın iyi olduğunu kanıtlamadı. Bu, otomatik test ile kullanıcı deneyimi testinin ayrı kanıtlar olduğunu gösterir.

---

## Kurucu/ZIP kullanımı

Kullanıcı çoğunlukla telefondan ve Codespaces üzerinden çalışır.

Kurucu paket:

- hedef dalı ve sürümü doğrulamalı,
- yalnız ilgili dosyaları değiştirmeli,
- soru dosyasını korumalı,
- geçici payload klasörlerini analiz kapsamına sokmamalı,
- format ve testleri çalıştırmalı,
- açık commit adı göstermeli,
- hata durumunda güvenli durmalıdır.

---

## Gizli bilgiler

Repo ve proje hafızasına eklenmemeli:

- testçi e-posta listeleri
- şifreler
- servis hesabı anahtarları
- özel API anahtarları
- kullanıcı kişisel verileri
- test hesabı parolaları
