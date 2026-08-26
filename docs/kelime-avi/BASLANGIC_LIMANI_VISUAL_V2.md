# Başlangıç Limanı — Görsel V2 Sözleşmesi

**Durum:** Görsel onay turu / production entegrasyonu yok

Bu belge, kullanıcı tarafından onaylanan referans görselin görsel hedefini gerçek Flutter uygulamasına aktarırken kullanılacak sanat ve UI sözleşmesini tanımlar.

## 1. Hedef his

- Premium mobil oyun progression haritası.
- Gece, ay ışığı, derin lacivert/teal deniz.
- Kayalık/tropikal küçük adalar, sıcak sarı ev/liman ışıkları.
- Sağ üst bölgede belirgin deniz feneri.
- Sol/orta bölgede en az bir yelkenli/gemi silueti.
- Deniz üzerinde kıvrılan, okunaklı ama manzarayı kapatmayan ışıklı rota.
- Sahne “düz UI kartı” gibi değil, keşfedilen gerçek bir liman dünyası gibi hissettirmeli.

## 2. Arka plan asset sözleşmesi

Arka plan **UI içermeyen** tek bir illüstrasyon olmalıdır.

### Zorunlu

- Dikey oran: yaklaşık `9:19.5`.
- Hedef üretim: en az `1080×2340`; tercih `1440×3120` veya daha yüksek.
- Metin yok.
- Bölüm numarası, yıldız, kilit, buton, rota etiketi yok.
- Telefon çerçevesi / cihaz mockup yok.
- İnsan yüzü / marka / logo yok.
- Rota düğümlerinin oturacağı orta deniz koridoru yeterince açık bırakılmalı.
- Görselin kenarlarında ada/ev/fener/gemi detayları bulunmalı; merkez tamamen kalabalıklaştırılmamalı.

### Kompozisyon güvenli alanları

- Üst %10: ay/gökyüzü + uzakta kıyı; UI başlığını boğmayacak kadar sakin.
- %10–45: 1–5 durakları için açık deniz koridoru; sağda fener.
- %45–78: 6–8 durakları için kıvrımlı deniz geçidi; iki yanda sıcak liman ışıkları.
- %78–100: 9–10/final alanı; hazine/liman hissi güçlü ama merkezde node okunabilir.

## 3. UI katmanı

UI Flutter tarafından çizilir; background asset içine gömülmez.

- Üst sol: geri.
- Üst merkez: `KELİME AVI`.
- Üst sağ: bilgi.
- Başlık paneli: `BAŞLANGIÇ LİMANI`.
- Yıldız toplamı ve `Kapı: 18`.
- 1–4 / 6–7: turkuaz normal durak.
- 5: turuncu/altın `MEYDAN OKUMA`.
- 8: mor `BONUS DURAK`.
- 9: kilitli normal durak.
- 10: altın `ROTA FİNALİ`.
- Alt sol: pusula.
- Alt sağ: bilgi kitabı.

## 4. Rota ve progression sözleşmesi

- Mevcut 10 bölüm sırası değişmez.
- 5 = challenge, 8 = bonus, 10 = route final.
- Unlock/progress engine görsel uğruna sahte durum üretmez.
- Görsel proof progress yalnız demo amaçlıdır; production progression mantığını değiştirmez.

## 5. Korunan alanlar

- `assets/questions.json` değişmez.
- `lib/main.dart` ve mevcut ana navigasyon değişmez.
- Mevcut Bilgi Oyunu oynanışı değişmez.
- BoardMap / 67 node / 3B tahta değişmez.
- Bu faz yalnız izole Kelime Avı rota görselidir.

## 6. Kabul ölçütü

Bu görsel faz ancak aşağıdakilerin tamamı sağlanınca kullanıcı onayına sunulur:

1. V2 ekran narrow-surface widget testinde overflow üretmez.
2. `flutter analyze` ilgili V2 diff için hata üretmez.
3. İzole V2 APK derlenir.
4. Android 16 gerçek cihaz/emülatör screenshot kanıtı alınır.
5. Screenshot referanstaki görsel hiyerarşiye belirgin biçimde yaklaşır.
6. Kullanıcı açıkça görsel onay verir.
7. Onaydan önce production ana navigasyon entegrasyonu yapılmaz.
