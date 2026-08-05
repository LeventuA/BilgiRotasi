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
- Premium kategori rozeti konsept seti

## Reddedilenler

- Tek Matrix4 ile düz tahtayı eğen APK
- Dağılan deterministik Python/PIL önizlemesi
- Rozetler eklenirken 5'li yol gruplarını bozan AI görselleri
- Son üretilen tahta görseli

---

## Açık tasarım kararı

8 konsept rozet hazırlanmıştır:

1. Bilim ve Teknoloji
2. Tarih ve Medeniyet
3. Coğrafya ve Dünya
4. Sanat ve Edebiyat
5. Doğa ve Yaşam
6. Spor ve Eğlence
7. Müzik
8. Genel Kültür / Eğitim

Tahtada yalnız 6 rozet noktası vardır. Gerçek oyunun 6 kategori sistemi GitHub'dan doğrulanmalı ve hangi 6 rozetin kullanılacağı Levent tarafından onaylanmalıdır.

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

**Güncel karar:** AŞAMA 1 numaralı geometri üretildi; kullanıcı görsel onayı
alınmadan AŞAMA 2 perspektif/3B, Flutter veya APK çalışmasına geçilmeyecek.

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
- Spor kolu debug yöneliminde alt merkeze sabitlendi; `SPORT INNER 1-5` ve
  `62-66` kimlikleri açıkça görünürdür.
- Sınır, görünürlük, kimlik benzersizliği, bağlantı geçerliliği ve çakışma
  kontrolleri geçti; art arda iki SVG/PNG üretimi birebir aynıdır.
- İnceleme çıktıları:
  - `tools/board_renderer/output/board_debug_numbered.svg`
  - `tools/board_renderer/output/board_debug_numbered_4096.png`
- Bu sonuçta hiçbir oyun/BoardMap, 3B stil, Flutter veya release build değişikliği
  yoktur.
