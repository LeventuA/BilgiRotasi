# Bilgi Rotası - Kesinleşen Kararlar

---

## 1. Çalışma ve Git düzeni

- `main` otomatik olarak güncel kabul edilmeyecek.
- Güncel hedef dal ve `pubspec.yaml` sürümü işe başlamadan önce okunacak.
- Doğrudan ana/release dala rastgele kod yazılmayacak.
- Yeni iş ayrı branch üzerinde yapılacak.
- Sıra: **test -> commit -> push -> PR -> inceleme -> merge**
- Levent açık onay vermeden kritik merge yapılmayacak.
- Build alınması, uygulamanın çalıştığının tek başına kanıtı değildir.
- Tam hata logu, workflow, değişen dosyalar ve Git geçmişi birlikte incelenecek.
- Aynı hataya V2, V3, V4 adıyla kör yama yapılmayacak.
- `assets/questions.json` kontrolsüz değiştirilmeyecek.
- Kullanıcının ilgisiz yerel dosyaları silinmeyecek.
- `git reset --hard` rutin çözüm olarak verilmeyecek.
- Telefonda uygulanabilir, tek parça komutlar tercih edilecek.
- Büyük manuel kod yapıştırmaları yerine kontrollü ZIP/kurucu kullanılabilir.
- Her GitHub yüklemesinde commit adı açıkça söylenecek.

---

## 2. Ürün ve yayın

- Uygulama adı: **Bilgi Rotası**
- Yayıncı: **ZMila Studio**
- Paket adı değiştirilmeyecek: `com.leventua.bilgirotasi`
- Yeni özellik uğruna çalışan kapalı test sürümü bozulmayacak.
- Mağaza metni gerçek soru sayısına göre yazılacak.
- Halka açık görsellerde kişisel ad, e-posta ve test hesabı gösterilmeyecek.

---

## 3. Oyun özellikleri

### Kesin mevcut/korunacak kararlar

- Yerel oyun 2-6 oyuncuyu destekler.
- Meydan Okuma modu zaten vardır.
- Canlı Düello 10, 20 veya 30 soru seçeneği sunar.
- Ana Canlı Düello otomatik eşleştirme kullanır.
- Ana düello akışında 6 haneli oda kodu kullanılmaz.
- Oda kodu ileride ayrı bir “Arkadaşımla Oyna” modu olabilir.
- Yakın BR oyuncular eşleştirilir.
- İki oyuncuya aynı sorular aynı sırayla verilir.
- Maç sonucu BR ve lig sistemine işlenir.

### Yayın sonrasına bırakılanlar

- Dünya Turnuvası
- Gelişmiş lig sezonları
- Raid etkinliği
- Günün Sorusu
- Klan sistemi
- Dünya haritası/alan fethetme fikri

### İstenmeyen veya kaldırılanlar

- Günlük giriş ödülü yok.
- Sandık sistemi yok.
- Zar Tekrar jokeri kaldırıldı.
- İleri 2 / Geri 2 kutuları kaldırıldı.
- Bunların yerine Tekrar Zar At ve Rastgele Joker Kazan kutuları kullanıldı.

---

## 4. Kariyer ve koleksiyon

- Piyon nadirlik sistemi korunacak.
- Bilgi Rotası Pasaportu korunacak.
- Seviye yükseldikçe XP ihtiyacı belirgin artacak.
- Birkaç soruyla çok sayıda seviye atlama olmayacak.
- Hesap, XP, piyon, ayar ve istatistik kayıtları güncellemelerde korunacak.

---

## 5. Reklam

- Aktif soru ekranında reklam gösterilmeyecek.
- Kritik canlı maç ve oyun akışı reklamla kesilmeyecek.
- Banner yalnız uygun ekranlarda kullanılacak.
- Ödüllü reklam kullanıcı isteğiyle açılacak.
- Sonuç kartı metni: “Bize destek olmak ister misiniz?”
- Ödül: +10 XP.
- Günlük/oturumluk toplam kota olmayacak.
- Her tamamlanan oyun bir kez ödül hakkı üretir.
- Aynı tamamlanmış oyun ikinci ödülü vermez.

---

## 6. Soru kalitesi

- Soru sayısı kaliteyi geçersiz kılmaz.
- Cevap soru metninde verilmez.
- Dört seçenek bulunur.
- Yanlış seçenekler aynı bağlamda ve makul olur.
- Açıklama kısa ve öğretici olur.
- Robotik, tekrar eden şablonlar temizlenir.
- Güncel olmayan, belirsiz veya tek doğru cevabı olmayan sorular düzeltilir.
- Sheet satırı yalnız gerçek soru düzeltmesi merge edilip doğrulandıktan sonra kapatılır.

---

## 7. 3B tahta

- Yeni oyun tasarlanmıyor; çalışan tahta görsel olarak yükseltiliyor.
- Oynanış, node kimlikleri ve rota bağlantıları değişmeyecek.
- BoardMap ve 67 noktalı sözleşme korunacak.
- Her iki rozet arasında tam 5 dış kategori karesi olacak.
- Merkez ile her rozet arasında tam 5 iç kategori karesi olacak.
- Kamera tepeden düz değil; ön taraf büyük, arka taraf küçük görünür.
- Bütün 2B sahneyi tek Matrix4 ile eğmek kullanılmayacak.
- Her tile, rozet ve merkez ayrı perspektif/3B parça olarak ele alınacak.
- Piyonlar dik kalacak ve aynı projeksiyona oturacak.
- Görsel onay alınmadan APK üretimine geçilmeyecek.
- Yapay görsel modelinin kare sayımına güvenilmeyecek.
- Son başarısız görseller kullanılmayacak.
- Hazırlanan 8 alternatif rozet konsepti tamamen iptal edilmiştir; 8'den 6'ya
  seçim/eşleme yapılmayacaktır.
- Tahtadaki 6 rozet yalnız mevcut oyun kategorilerini temsil edecektir:
  Coğrafya, Eğlence, Tarih, Sanat & Edebiyat, Bilim & Doğa ve Spor.
- İlk yeniden başlatma adımı, canlı `BoardMap` verisinden üretilen düz ve numaralı
  deterministik geometri olacaktır; bu veri oyun kodunun alternatifi değildir.
- Debug yönelimi canlı `BoardMap.armAngle/position` değerlerini aynen koruyacak;
  tahta Spor yolunu alta getirmek için döndürülmeyecektir. Kuzey node `1`, güney
  node `19`, Spor rozeti kuzeybatıda node `31`dir.
- Aynı kaynak iki kez işlendiğinde SVG ve PNG çıktıları birebir aynı olacaktır.
- 67 kimlik, altı dış `1-5` aralığı, altı iç `1-5` yol, sınırlar, bağlantılar ve
  çakışmasızlık otomatik testlerle geçmeden görsel onaya sunulmayacaktır.
- Numaralı geometri onaylanmadan stil, perspektif/3B, Flutter veya APK aşamasına
  geçilmeyecektir.
- Perspektif önizlemede tamamlanmış 2B tahta veya raster tek parça warp
  edilmeyecek; her node düzlemi ve bağlantı aynı pinhole kamera fonksiyonuyla
  ayrı ayrı projekte edilecektir.
- Kamera A/B/C aynı güney/ön azimutu (`90°`), mesafe (`1.55`) ve dikey FOV'u
  (`42°`) paylaşacak; yalnız yükseliş `58° / 46° / 34°` olarak değişecektir.
- Kullanıcı A/B/C arasından açıkça seçim yapmadan stil, doku, gölge, 3B kalınlık,
  Flutter veya APK aşamasına geçilmeyecektir.
- Kullanıcı kanonik kamera olarak Kamera B'yi seçmiştir: yükseliş `46°`,
  güney/ön azimut `90°`, mesafe `1.55`, dikey FOV `42°` ve yakın/uzak ölçek
  oranı `1.463752079` sabit kalacaktır.
- Yapısal 3B aşamasında her dış/iç taş, rozet ve merkez ayrı üst ve yan yüzlere
  sahip olacaktır; tek bir 2B raster/tahta eğilmeyecektir.
- Sabit dünya birimi kalınlıkları taşıyıcı taban `0.012`, dış taş `0.024`, iç
  taş `0.020`, rozet `0.027` ve merkez `0.028` olarak kabul edilmiştir.
- Merkez-rozet radyal taşıyıcılarının görsel genişliği `5.0` değerinden `6.25`
  değerine çıkarılacaktır. Taşıyıcı merkez çizgisi, uçları, uzunluğu ve yüksekliği
  ile dış halka taşıyıcısının `5.0` genişliği sabit kalacaktır.
- AŞAMA 3 statik görseli açıkça onaylanmadan final stil/doku, logo, ikon, piyon,
  Flutter veya APK aşamasına geçilmeyecektir.

---

## 8. Tasarım ve tanıtım

- Uygulama simgesinde yazı kullanılmayacak.
- Kişisel bilgi mağaza görsellerine girmeyecek.
- Başka bir oyunun görsel kimliği kopyalanmayacak.
- Ham ekran kaydını kırpıp vermek tanıtım videosu sayılmayacak.
- Tanıtım videosu kurgu, ritim, efekt, metin ve ses tasarımı içerecek.
- Hatalı bildirilen soru ekranları tanıtıma konulmayacak.

---

## 9. Proje hafızası

- Proje gerçeği yalnız sohbet hafızasında tutulmayacak.
- Durum, karar ve görev dosyaları her iş sonunda güncellenecek.
- Devir özeti tek başına kaynak sayılmayacak.
- Yeni sohbet, canlı kaynak ve bu proje dosyalarını okuyarak başlayacak.
