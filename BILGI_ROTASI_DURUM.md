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
