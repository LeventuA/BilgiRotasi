# Bilgi Rotası — RC2 Telefon Test Listesi

Sürüm: **1.47.1+63 • RC2**

> Bir kritik madde başarısızsa RC2 onaylanmaz. Hata düzeltilir,
> yeni APK alınır ve ilgili bölüm yeniden test edilir.

## 1. Güncelleme ve açılış

- [ ] APK mevcut imzalı uygulamanın üzerine kuruldu.
- [ ] XP, tema, piyon ve kayıtlı oyun korundu.
- [ ] Hakkında ekranında `Sürüm 1.47.1+63 • RC2` göründü.
- [ ] Uygulama çevrimdışıyken misafir olarak açılabildi.

## 2. İlk hesap seçimi

- [ ] İlk açılışta Google ile giriş ve Misafir seçenekleri göründü.
- [ ] Misafir seçilince ana ekran açıldı.
- [ ] Misafirde ana sayfadaki Günlük Görev kartı görünmedi.
- [ ] Misafirde Bölümler alanındaki Günlük kartı görünmedi.
- [ ] Misafirde Kariyer içindeki günlük istatistik kartı görünmedi.
- [ ] Misafir diğer oyun modlarına erişebildi.

## 3. Google girişi

- [ ] Google hesap seçme ekranı açıldı.
- [ ] Giriş sonrası kullanıcı adı/e-posta göründü.
- [ ] Günlük Görev giriş sonrası görünür oldu.
- [ ] İlk girişte telefondaki mevcut ilerleme kaybolmadı.
- [ ] `Şimdi eşitle` işlemi başarıyla tamamlandı.

## 4. Bulut geri yükleme

- [ ] Uygulama kapatılıp açıldığında Google oturumu korundu.
- [ ] XP, başarımlar, temalar ve kayıtlı oyun korundu.
- [ ] Firestore `users/{uid}` belgesi oluştu.
- [ ] Aynı hesapla temiz kurulumda bulut verisi geri geldi.

## 5. Hesap ayrımı

- [ ] Hesaptan çıkınca Google verisi yerine misafir kaydı geri geldi.
- [ ] Misafir ve Google ilerlemeleri birbirine karışmadı.
- [ ] Tekrar Google girişi yapılınca hesap kaydı geri geldi.
- [ ] Başka kullanıcının Firestore belgesine erişim reddedildi.

## 6. Mevcut oyun özellikleri

- [ ] Standart oyun, kayıt ve devam çalıştı.
- [ ] Serbest Rota ve Soru Maratonu çalıştı.
- [ ] Günlük Görev Google hesabında çalıştı.
- [ ] Tema, piyon, ses ve erişilebilirlik ayarları çalıştı.
- [ ] Uygulama arka plana alınıp dönünce çalışmaya devam etti.

## RC2 sonucu

- Test edilen telefon:
- Android sürümü:
- Test tarihi:
- Test eden:
- Sonuç: [ ] ONAYLANDI  [ ] REDDEDİLDİ
- Bulunan hatalar:

## 7. Bulut veri deposu hotfix testi

- [ ] Hesap ekranında `Şimdi eşitle` sonrası yüklenen kayıt sayısı sıfırdan büyük göründü.
- [ ] Uygulama kaldırılıp tekrar kuruldu.
- [ ] Aynı Google hesabıyla giriş yapıldı.
- [ ] XP, tema, piyon ve kayıtlı oyun geri geldi.
- [ ] Boş telefon kaydı dolu bulut kaydının üzerine yazılmadı.
