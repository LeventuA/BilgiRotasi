# Kelime Avı — PROJECT_RULES

Bu dosya Bilgi Rotası içindeki **Kelime Avı** çalışmalarında her yeni görev ve sohbet başlamadan önce okunacak çalışma sözleşmesidir.

## 1. Kaynak ve doğrulama sırası

1. Önce bu `PROJECT_RULES.md` dosyasını oku.
2. `BILGI_ROTASI_DURUM.md` dosyasını oku; ancak içindeki sürüm bilgisini tek başına güncel kabul etme.
3. Varsa ilgili karar/görev belgelerini kontrol et. Repo içinde bulunmuyorsa **DOĞRULANACAK** olarak işaretle; uydurma.
4. Canlı hedef branch'i ve `pubspec.yaml` sürümünü GitHub'dan doğrula.
5. `main` dalını otomatik olarak güncel kaynak kabul etme.
6. Eski sohbetlerdeki kodu veya eski ekran görüntülerini canlı koddan daha güncel kabul etme.

## 2. Git çalışma kuralı

- Doğrudan `main`, release veya canlı hedef dala yazma.
- Her görev için ayrı branch kullan.
- Sıra: **inceleme → branch → değişiklik → test → commit → push → PR → inceleme → kullanıcı onayı → merge**.
- Levent açıkça onaylamadan kritik merge yapma.
- Build başarısını tek başına çalışma kanıtı sayma.
- Tam log, diff, workflow, test sonucu ve Git geçmişini birlikte değerlendir.
- İlgisiz yerel değişiklikleri silme.
- `git reset --hard` rutin çözüm değildir.
- Commit adını açıkça yaz.
- Gizli bilgi, parola, anahtar veya testçi e-postası repoya eklenmez.

## 3. Kelime Avı kapsam kilidi

Kelime Avı, Bilgi Rotası içindeki ayrı bir oyun/mod akışıdır. Mevcut Bilgi Rotası oynanışını veya başka modları gereksiz yere değiştirme.

Özellikle:

- `assets/questions.json` dosyasına Kelime Avı görsel/UI işi bahanesiyle dokunma.
- Ana Bilgi Rotası `BoardMap`, 67 node düzeni ve 3B tahta çalışması Kelime Avı görevinin parçası değildir.
- Kelime Avı işi için `main.dart` veya genel uygulama altyapısında gereksiz değişiklik yapma.
- Başka sistemleri refactor ederek görevi büyütme.

## 4. Görsel çalışma kuralı — en önemli bölüm

Kelime Avı görsellerinde **referans görsel onayı koddan önce gelir**.

- Levent'in onayladığı mevcut referans korunur; her denemede sıfırdan başka bir tasarım üretme.
- Kullanıcı yalnızca belirli bir bölgenin düzeltilmesini istediyse yalnızca o bölgeyi değiştir.
- Onaylı kompozisyonu, perspektifi, ana nesnelerin konumunu ve genel sanat dilini keyfi biçimde değiştirme.
- “Daha güzel olur” gerekçesiyle onaysız yeni öğe, farklı sahne, farklı kamera açısı veya farklı UI ekleme.
- Görsel üretim sonucunu otomatik olarak doğru kabul etme; referansla tek tek karşılaştır.
- Bir sonuç referansı bozuyorsa onu ilerletme. Açıkça **RED** olarak işaretle ve önceki onaylı noktaya dön.
- Görsel onay alınmadan Flutter entegrasyonu, APK veya sonraki büyük aşamaya geçme.

## 5. Başlangıç Limanı kilidi

Aktif çalışma alanı **Başlangıç Limanı** ise önce o sahneyi bitir. Başlangıç Limanı tamamlanmadan sırf ilerlemek için başka rota/sahneye atlama.

Mevcut teknik referansta Başlangıç Limanı için kullanılan HD arka plan yolu:

`assets/images/word_hunt/limani/limani_bg_v2_hd.jpg`

ve ilgili widget:

`lib/word_hunt/presentation/widgets/word_hunt_liman_background.dart`

Bu yollar canlı branch'te yeniden doğrulanmadan değiştirilmez.

## 6. Onay kapıları

Her büyük görsel iş aşağıdaki kapılardan geçer:

1. **Referans doğrulama:** Hangi görselin korunacağı net.
2. **Tek değişiklik tanımı:** Bu turda tam olarak ne değişecek net.
3. **Statik görsel:** Sadece istenen değişiklik uygulanmış önizleme.
4. **Levent onayı:** Açık onay yoksa ilerleme yok.
5. **Entegrasyon:** Onaylanan asset aynı kompozisyonla oyuna yerleştirilir.
6. **Gerçek ekran doğrulaması:** Küçük/büyük ekran, kırpılma, bulanıklık, gri/boş alan, taşma kontrol edilir.
7. **Test/PR:** Teknik kanıtlar tamamlanır.

Bir kapı başarısızsa sonraki kapıya geçilmez.

## 7. Mevcut Kelime Avı teknik durumu için bilinen referans

21 Ağustos 2026 tarihli durum raporunda:

- Çalışma branch'i: `feat/kelime-avi-clean-release-integration-20260821`
- PR: `#96 (Draft)`
- Başlangıç Limanı V2 HD görseli entegre edilmişti.
- Word Hunt testleri: **59 PASS** olarak raporlanmıştı.
- Android 16 emülatör açılış testi: **PASS** olarak raporlanmıştı.
- `assets/questions.json`, BoardMap/67 node ve 3B tahta değiştirilmemişti.

Bunlar **tarihsel referanstır**. Yeni görev başında canlı GitHub durumu tekrar doğrulanmalıdır.

## 8. İletişim ve görev boyutu

- Tek seferde çok büyük, kontrolsüz iş yapma.
- Özellikle görsel işlerde küçük ve doğrulanabilir adımlarla ilerle.
- Aynı hatayı tekrar tekrar üretmek yerine ikinci başarısız denemeden sonra yöntemi değiştir.
- Kullanıcı telefondaysa mümkün olduğunca tek parça, uygulanabilir komut ver.
- Bir bilgi kesin değilse **DOĞRULANACAK** yaz; tahmin etme.

## 9. Bitti ölçütü

Bir Kelime Avı görevi ancak şu koşullar birlikte sağlanınca **BİTTİ** sayılır:

- İstenen sonuç görsel/işlev olarak kullanıcı tarafından onaylandı.
- İlgisiz sistemlere dokunulmadığı doğrulandı.
- Gerekli analiz/testler geçti.
- Gerçek ekran veya çalışma kanıtı görüldü; yalnızca build sonucu kullanılmadı.
- Diff incelendi.
- Commit ve branch açıkça kaydedildi.
- PR açıldı ve incelemeye hazır hale geldi.
- Kritik merge için Levent'in açık onayı alındı.
- Proje durum/görev belgeleri gerekiyorsa güncellendi; repoda bulunmayan belgeler için durum **DOĞRULANACAK** olarak bırakıldı.

## 10. Değişmez kısa kural

> **Önce canlı kaynağı doğrula. Referansı kilitle. Tek şeyi değiştir. Görsel onay almadan kod/APK aşamasına geçme. Bilgi Rotası'nın çalışan sistemlerini Kelime Avı işi uğruna bozma.**
