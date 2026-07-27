# Bilgi Rotası – Proje Durumu

## Son Sürüm

**1.62.0+83**

## Son Tamamlanan İş

Canlı Düello puan yazımı Firestore tarafından doğrulanır hale getirildi.

- İstemci seçilen şık numarasını ilerleme belgesine gönderiyor.
- Doğru/yanlış artışı özel `live_duel_question_keys` koleksiyonundaki
  cevap anahtarına göre Firestore güvenlik kuralları tarafından doğrulanıyor.
- Oyuncular özel cevap anahtarı koleksiyonunu okuyamıyor veya değiştiremiyor.
- Cevaplar doğru sırada ve yalnızca birer kez gönderilebiliyor.
- Doğru ve yanlış sayaçlarının elle şişirilmesi engellendi.
- Bitmiş maçlara yeni cevap yazılması engellendi.
- 6.710 cevap anahtarını yükleyen araç eklendi.
- Lig ve Sıralama ile 3 dakikalık geri dönüş süresi korunuyor.

## Sıradaki İş

- Cloud Shell'den 6.710 özel cevap anahtarını yükleme
- Yeni 1.62.0+83 APK'yı iki telefona kurma
- Güncel Firestore kurallarını dağıtma
- 10 soruluk normal maçla güvenli puan yazımını doğrulama

## Dağıtım Sırası

1. Cevap anahtarlarını Firestore'a yükle
2. Yeni APK'yı iki telefona kur
3. Firestore kurallarını dağıt
4. Yeni maç başlat

## Bilinen Durumlar

- Toplam soru sayısı: **6710**
- Bu katman sahte doğru/yanlış yazımını engeller.
- Cevaplar uygulama paketinde de bulunduğundan ileri düzey modifiye
  istemci saldırılarına karşı tam gizlilik sağlamaz.


## Çevrimdışı Açılış Düzeltmesi

- Uygulama bulut başlatmasını beklemeden ilk kareyi açar.
- Mevcut Google hesabı yerel kayıtla anında açılır.
- Bulut eşitlemesi arka planda denenir.
- Sunucu okuması 6 saniyede zaman aşımına uğrar.
- İnternet yokken native açılış logosunda kalma engellendi.


## Oyuncu Kullanıcı Adı Sistemi

- Google ile giriş yapan herkes benzersiz kullanıcı adı belirler.
- Kullanıcı adları 3–16 karakter ve küçük harftir.
- Canlı Düello, lig sıralaması ve maç geçmişinde yalnızca
  kullanıcı adı görünür.
- Google adı ve e-posta yalnızca hesap sahibine gösterilir.
- Kullanıcı adı 30 günde bir değiştirilebilir.
- Hesap silindiğinde kullanıcı adı yeniden boşa çıkar.
- Mevcut oyuncular yeni sürümde bir kez kullanıcı adı seçer.


## Canlı Düello Kullanıcı Adı ve BR Düzeltmesi

- Yerel kullanıcı adı ile Firestore kullanıcı adı bağı doğrulanır.
- Eksik sunucu kullanıcı adı kaydı aynı adla otomatik onarılır.
- Kullanıcı adı genel oyun yedeğinden ayrılmıştır.
- Eşit rakipte +18 / -7 BR uygulanır.
- Güçlü rakipte +22 / -5 BR uygulanır.
- Zayıf rakipte +14 / -8 BR uygulanır.
- İlk 5 maçta +20 / -4 BR uygulanır.
- Eski -8'den ağır mağlubiyetlerin farkı bir kez iade edilir.
