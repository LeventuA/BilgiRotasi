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
- Aile Modu ve Turnuva Modu, Diğer Oyun Modları ekranı ile bu ekrandaki
  navigasyon girişlerinden kaldırıldı.

---

## 4. Kariyer ve koleksiyon

- Piyon kataloğu, seçim ve kullanıcıdaki favori piyon verisi korunacak; piyon
  nadirlik katmanı, nadirlik etiketleri ve nadirliğe bağlı farklılaştırma
  kullanılmayacak.
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
- 8 kategori rozeti ile 6 fiziksel rozet noktası eşleştirilmeden çalışma ilerlemeyecek.

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

---

## 10. Analytics ve anonim telemetri

- Kapalı test davranışı Firebase Analytics ile yalnız anonim olaylar üzerinden
  ölçülecek.
- İzin verilen oyun boyutları oyun modu, kategori, gerekiyorsa zorluk grubu,
  süre, sonuç ve uygulama sürümüyle sınırlıdır.
- Ad, e-posta, Firebase/Google kullanıcı kimliği, açık kullanıcı adı, reklam
  kimliği veya başka kişisel veri Analytics'e gönderilmeyecek.
- Android Advertising ID toplaması ve Analytics reklam kişiselleştirme
  sinyalleri kapalı tutulacak; Analytics consent yalnız ölçüm depolamasına izin
  verirken reklam depolaması, reklam kullanıcı verisi ve kişiselleştirmeyi
  reddedecek.
- Analytics katmanı genel amaçlı key/value veya kullanıcı kimliği API'si
  sunmayacak; yeni olaylar merkezi servisten geçecek.
- Aktif soru ekranındaki dokunuşlar ve tek tek cevaplar olaylaştırılmayacak.
- Telemetri ağ/SDK hataları oyunu durdurmayacak ve kullanıcıya hata olarak
  yansıtılmayacak.
- Firebase test/development/production çalışma ayrımı korunacak.
