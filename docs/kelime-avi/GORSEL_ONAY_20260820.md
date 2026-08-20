# Bilgi Rotası — Ana Ekran + Kelime Avı Görsel Onayı

**Tarih:** 20 Ağustos 2026
**Onay türü:** Kullanıcı görsel onayı
**Kapsam:** Yeni ana ekran, Kelime Avı rota ekranı, Kelime Avı bölüm ekranı

## Onaylanan referans görsel

ChatGPT içinde 20 Ağustos 2026'da üretilen üç ekranlı neon konsept kullanıcı tarafından açıkça onaylandı.

- Boyut: `1672 × 941`
- Yerel çalışma dosyası: `neon_bilgi_rotası_oyun_arayüzü.png`
- SHA-256: `03f261daa15c73391a5a2e576179deabde834bd21cc791e0d786bb05a7f24cd5`

Bu dosya şu anda repo asset'i değildir; hash yalnız onaylanan görsel referansını sabitlemek için kaydedilir. Final uygulamada ekranlar tek bir raster mockup olarak kullanılmayacak; Flutter bileşenleri ve gerektiğinde ayrı kontrollü görsel asset'lerle yeniden üretilecektir.

## 1. Onaylanan yeni ana ekran

- Koyu lacivert / gece mavisi ana zemin.
- Altın pusula / rota grafik dili.
- Üstte avatar, kullanıcı adı, seviye, XP ilerlemesi.
- Sağ üstte bildirim ve Ayarlar ikonları.
- Kompakt `BİLGİ ROTASI` marka alanı ve `Zarı at, bilginle yolu aç.` sloganı.
- İki eşdeğer ana oyun kartı:
  - `Bilgi Oyunu`: turkuaz/camgöbeği, zar vurgusu, `Oyna`.
  - `Kelime Avı`: mor/indigo, harf/arama vurgusu, `Başla`.
- `Günlük Görevler` iki ana oyunun altında daha düşük görsel öncelikle kalır.
- `Yeni modlar yolda!` alanı küçük destek alanıdır.
- Büyük bağımsız Kariyer, Sosyal veya Ayarlar kartı kullanılmaz.

## 2. Onaylanan Kelime Avı rota ekranı

`Başlangıç Limanı` finalde düz/dikey bölüm kartı listesi gibi görünmeyecek.

Onaylanan yön:

- Gerçek bir liman/ada rota haritası hissi.
- Deniz, iskele, deniz feneri, küçük rota landmark'ları ve macera atmosferi.
- Kıvrılan, parlayan rota çizgisi.
- Deterministik 10 numaralı durak.
- Tamamlanan duraklarda yıldızlar.
- Kilitli gelecek duraklarda açık kilit durumu.
- `5`: turuncu/altın `Meydan Okuma`.
- `8`: mor `Bonus Durak`.
- `10`: altın `Rota Finali`.
- Üst başlıkta `Başlangıç Limanı`, toplam yıldız ve sonraki kapı eşiği.

Bu ekran mevcut `WordHuntRoutePrototypeScreen` içindeki dikey kart listesinin final görsel yönü değildir.

## 3. Onaylanan Kelime Avı bölüm ekranı

Onaylanan yön klasik hedef-kelime listesini tek başına göstermek yerine **bilgi ipucunu oyunun merkezine** taşır.

Örnek görsel sözleşme:

- Başlık: `Bölüm 3`.
- Üst metrikler: bulunan, hata, süre.
- İpucu kartı: `Türkiye'nin başkenti`.
- Cevap, oyuncuya doğrudan hedef kelime olarak verilmez; harf/boşluk ipucu gösterilebilir.
- 6×6 harf grid'i.
- Parmağı sürükleyerek seçim.
- Örnek seçim: `ANKARA`.
- Doğru seçim sonrası: `Harika! ANKARA bulundu.`.
- Ardından kısa `Ankara` bilgi kartı açılır/görünür.
- Alt eylem: `Bölümü Tamamla`.
- Seçili yol mor; tamamlanmış/bulunmuş yol turkuaz görsel geri bildirim kullanabilir.

Bu yön, `Kayıp Kelime + Bilgi Kartı` yaklaşımını Kelime Avı'nın ayırt edici özelliği yapar. Veri modeli gelecekte `Bilgi Zinciri` ve `Canlanan Harita` genişlemelerine açık kalır.

## Görsel sistem

- Ana zemin: koyu lacivert / gece mavisi.
- Marka / rota / final: altın.
- Bilgi Oyunu: turkuaz.
- Kelime Avı: mor / indigo.
- Tamamlanmış kelime/başarı geri bildirimi: turkuaz.
- Meydan Okuma: sıcak turuncu / altın.
- Büyük radius, güçlü kontrast, oyun hissi veren glow; fakat okunabilirlik glow uğruna feda edilmez.
- Final uygulama ekranında telefon çerçevesi/mockup çizilmez; onay görselindeki telefonlar yalnız sunum çerçevesidir.

## Uygulama sırası

1. **Başlangıç Limanı rota haritası**: mevcut dikey listeyi, aynı 10-node/progression sözleşmesini koruyarak izole harita görünümüne dönüştür.
2. **Kelime Avı bölüm ekranı**: ipucu-merkezli `Kayıp Kelime` sunumunu mevcut path/scoring çekirdeğine kontrollü bağla.
3. **Ana ekran**: onaylı oyun-merkezi görsel diline son polish'i uygula.
4. Her ekran için izole widget/test + Android ekran görüntüsü doğrulaması yap.
5. Bu üç ekran yeniden kullanıcıya gösterilip uygulama içi görünüm onaylanmadan mevcut ana navigasyona bağlama.

## Gerçek Android 16 görsel kanıt hattı

- Üretim `lib/main.dart` değiştirilmeden ayrı `lib/word_hunt/word_hunt_visual_proof_main.dart` giriş noktası kullanılacaktır.
- `.github/workflows/word-hunt-visual-proof.yml` yalnız Kelime Avı görsel doğrulaması için Android 16 emulator üzerinde izole debug APK üretir.
- Görsel kanıt akışı `WordHuntRouteMapPrototypeScreen` ekranını gerçek Flutter/Android renderer ile açar ve üst/alt PNG screenshot, activity state, logcat, exact HEAD SHA ve APK SHA-256 dosyalarını artifact olarak kaydeder.
- Bu visual-proof APK release adayı değildir; production package/navigasyon davranışını değiştirmez ve mevcut release kabul kapılarının yerine geçmez.

## Güvenlik ve kapsam sınırı

Bu görsel onay:

- `assets/questions.json` için değişiklik yetkisi değildir.
- Mevcut Bilgi Oyunu oynanışı, BoardMap/67 node veya 3B tahta için değişiklik yetkisi değildir.
- Firebase/AdMob/Play config değişikliği değildir.
- PR #74'ü Draft'tan çıkarma veya merge etme yetkisi değildir.
- Ana navigasyona hemen entegrasyon yetkisi değildir.

Görsel onay yalnız izole Kelime Avı / home hub ekranlarının bu onaylı tasarım yönünde Flutter uygulamasına geçirilmesi kapısını açar.
