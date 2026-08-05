# Bilgi Rotası - 3B Tahta Çalışmasının Son Durumu

**Kaynak güveni:** S07 düzenlenmiş ayrıntılı kayıt; repo başlamadan önce yeniden doğrulanmalıdır.

---

## Kesin topoloji

```text
30 dış kategori
30 iç kategori
6 rozet
1 merkez
= 67 nokta
```

- Dış halkada 6 rozet vardır.
- Her komşu rozet arasında tam 5 kategori karesi vardır.
- Merkezden her rozete giden 6 kolun her birinde tam 5 kategori karesi vardır.
- Rozet ve merkez kategori karesi sayılmaz.
- Node kimlikleri, bağlantılar ve mevcut oynanış değişmeyecektir.

---

## Denemeler

### `experiment/perspective-board-v1`

- Eski 2.5D/perspektif deneme.
- Kullanıcı tarafından çok kötü bulundu.
- Merge edilmemeli ve yeni taban yapılmamalı.

### `experiment/original-board-3d-v1`

- `71ee8a1` commit'inde mevcut 2B sahne Matrix4 ile eğildi.
- 218 test geçti; fakat görsel sonuç gerçek 3B değildi.
- Tahta ezilmiş/sıkışmış göründü.
- Branch yerel ve uzak repodan silindi.
- Release'e merge edilmedi.

### `experiment/true-3d-board-renderer-v2`

- Temiz release tabanından açıldı.
- Kesim noktasında gerçek renderer commit'i yoktu.
- Çalışma görsel onay aşamasında durduruldu.

---

## Görsel kararlar

- Kamera tepeden değil, önden-yandan ve alçak perspektifte olacak.
- Ön taraf büyük, arka taraf küçük olacak.
- Tahta fiziksel, kalın ve katmanlı görünecek.
- Kareler ayrı 3B parçalar gibi işlenecek.
- Rozetler kareleri ezmeyecek; ayrı yuvaları olacak.
- Piyonlar dik duracak.
- UI kutuları tahta üzerine binmeyecek.
- 2-6 piyon, küçük ve büyük telefonlarda ayrıca test edilecek.
- Monopoly Go kopyalanmayacak; yalnız güçlü 3B sunum kalitesi referans alınacak.

---

## Kabul edilen referanslar

- Çalışan oyunun mevcut tahta ekranı
- GitHub'daki BoardMap / 67 node düzeni
- `galaktik_bilgi_rotası_oyun_tekerleği.png` geometri referansı
- `63397.png` alçak açılı stil referansı
- Oyunun mevcut 6 kategori adı ve canlı `BoardMap` rozet eşlemesi

## Reddedilenler

- Tek Matrix4 ile düz tahtayı eğen APK
- Dağılan deterministik Python/PIL önizlemesi
- Rozetler eklenirken 5'li yol gruplarını bozan AI görselleri
- Son üretilen tahta görseli

---

## Kapatılan rozet konsepti kararı

Hazırlanan 8 alternatif rozet konsepti kullanıcı kararıyla tamamen iptal edildi.
Tahtada yalnız oyunun mevcut 6 kategorisi kullanılacaktır:

1. Coğrafya
2. Eğlence
3. Tarih
4. Sanat & Edebiyat
5. Bilim & Doğa
6. Spor

8 konseptten 6 rozet seçme veya eşleme konusu kapatılmıştır; yeni bir seçim
beklenmemektedir.

---

## Yeniden başlatma sırası

1. BoardMap'ten 67 node'u veri olarak çıkar.
2. Düz ve numaralı debug önizleme oluştur.
3. Her dış aralığı ve iç kolu 1-5 olarak işaretle.
4. Geometri için kullanıcı onayı al.
5. Deterministik perspektif projeksiyonu uygula.
6. Çakışma/kayıp testlerini otomatikleştir.
7. Ayrı 3B tile/rozet/merkez katmanlarını ekle.
8. Statik görsel onayı al.
9. Flutter önizlemesi yap.
10. En son ayrı APK üret.

**Güncel karar:** Düzeltilmiş AŞAMA 1 kullanıcı tarafından onaylandı. AŞAMA 2
sonunda kullanıcı Kamera B'yi kanonik kamera olarak seçti. AŞAMA 3 yapısal 3B
önizlemesi Kamera B ile hazırdır; statik görsel açıkça onaylanmadan final stil,
doku, logo, piyon, Flutter veya APK çalışmasına geçilmeyecek.

---

## AŞAMA 1 sonucu - deterministik numaralı geometri (2026-08-05)

- Kaynak dal/commit: `release/final-closed-test-aab-1.68.8` /
  `548e8d3046469688a8dcb050552956cf786e525c`
- Çalışma dalı: `experiment/deterministic-board-geometry-v1`
- Canlı `lib/main.dart::BoardMap` kimlikleri, kategori sırası ve karşılıklı rota
  bağlantıları değiştirilmeden veri olarak çıkarıldı.
- Tam dağılım doğrulandı: 1 merkez + 6 rozet + 30 dış kategori + 30 iç kategori
  = 67 düğüm.
- Altı rozet aralığının her birinde tam 5 dış düğüm, merkezden rozete giden altı
  kolun her birinde tam 5 iç düğüm vardır.
- İlk debug yöneliminin tahtayı keyfî döndürdüğü otomatik parite kapısında
  bulundu. Canlı `BoardMap` yönü geri yüklendi: node `1` kuzey, node `19` güney,
  node `31` kuzeybatıdır.
- Ekranın altındaki gerçek iç yol `52-56` ve güneydeki rozet node `19`dur.
  Gerçek Spor rozeti node `31`, Spor iç yolu `62-66` ve kuzeybatıdadır.
- `board_map_parity_report.json/.md` raporlarında 67/67 kimlik, tür, kategori
  indeksi, rozet durumu, bağlantı, sıra ve normalize koordinat eşleşmesi PASS'tir.
- Sınır, görünürlük, kimlik benzersizliği, bağlantı geçerliliği ve çakışma
  kontrolleri geçti; art arda iki SVG/PNG üretimi birebir aynıdır.
- İnceleme çıktıları:
  - `tools/board_renderer/output/board_debug_numbered.svg`
  - `tools/board_renderer/output/board_debug_numbered_4096.png`
- Bu sonuçta hiçbir oyun/BoardMap, 3B stil, Flutter veya release build değişikliği
  yoktur.

---

## AŞAMA 2 sonucu - deterministik perspektif geometri (2026-08-06)

- Tamamlanmış 2B görsel warp edilmedi; merkez, rozet ve kategori taşlarının her
  biri kendi köşeleriyle ayrı düzlem olarak pinhole kameradan geçirildi.
- Node merkezi, poligon köşeleri, etiket merkezi ve bağlantı çizgileri aynı
  projeksiyon fonksiyonunu kullanır.
- Ortak kamera değerleri: güney/ön azimut `90°`, mesafe `1.55`, dikey FOV `42°`.
- Kamera A: yükseliş `58°`, yakın/uzak ölçek oranı `1.335332839`.
- Kamera B: yükseliş `46°`, yakın/uzak ölçek oranı `1.463752079`.
- Kamera C: yükseliş `34°`, yakın/uzak ölçek oranı `1.579455081`.
- Her kamerada 67 node tuval içinde ve pozitif derinliktedir; poligon/etiket
  çakışması yoktur. Altı dış aralık ve altı iç yol ayrı ayrı 5 taş içerir.
- Güney/ön iç yol `52-56` üç kamerada da tamamen görünürdür.
- Çıktılar `tools/board_renderer/output/board_perspective_*` altında, birleşik
  karşılaştırma `board_perspective_camera_comparison.png` dosyasındadır.
- Bu aşamada stil, doku, ışık, gölge, logo, piyon, extrusion/kalınlık, Flutter,
  APK veya AAB eklenmedi.

---

## AŞAMA 3 sonucu - Kamera B yapısal 3B geometri (2026-08-06)

- Kullanıcı kanonik kamera olarak Kamera B'yi seçti: yükseliş `46°`, güney/ön
  azimut `90°`, mesafe `1.55`, dikey FOV `42°`, yakın/uzak ölçek oranı
  `1.463752079`.
- BoardMap merkezleri, kimlikleri, yönleri ve bağlantıları değiştirilmedi.
- 30 dış taş, 30 iç taş, 6 rozet ve merkez ayrı ayrı üst yüzey, yan yüzler ve
  pozitif kalınlık içeren 67 fiziksel parça olarak üretildi.
- Sabit dünya birimi kalınlıkları: taşıyıcı taban `0.012`, dış taş `0.024`, iç
  taş `0.020`, rozet `0.034`, merkez `0.040`.
- Gerçek parça boşlukları korundu; yüzler ortalama kamera derinliğine göre
  uzaktan yakına çizildi ve kimlik etiketleri hiçbir fiziksel yüz tarafından
  kapatılmadı.
- BoardMap paritesi `67/67`; altı dış aralık ve altı iç yol ayrı ayrı
  `5/5/5/5/5/5` PASS'tir. Güney `52-56` ve Spor `62-66` yolları görünürdür.
- Merkez en yakın iç taşı, rozetler komşu dış taşları kapatmaz.
- Ana ve güney yakın plan çıktıları 4096x4096'dır:
  - `tools/board_renderer/output/board_structural_3d_camera_B_4096.png`
  - `tools/board_renderer/output/board_structural_3d_camera_B_closeup_4096.png`
- Bu aşamada final renk/stil, doku, logo, kategori ikonu, piyon, parıltı, ağır
  gölge, Flutter, APK veya AAB eklenmedi.
