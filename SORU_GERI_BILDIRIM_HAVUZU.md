# Bilgi Rotası - Soru Geri Bildirim Havuzu

**Kaynak:** 4 Ağustos 2026 canlı Sheet kontrol konuşması (S06)  
**Kesim noktası:** Son görülen kayıtlar `1.68.13+103` sürümünden canlı gelen `q60857` ve `q56838` olaylarıdır.  
**Önemli:** Bu konuşmada hiçbir kayıt `Düzeltildi` yapılmadı.

## Özet

| Sınıf | Benzersiz soru |
|---|---:|
| Açıkça bozuk | 14 |
| Zorluk incelemesi | 8 |
| Eski, ayrıntısı yeniden incelenecek | 4 |
| Henüz tek tek değerlendirilmemiş | 13 |
| Değişiklik gerekmiyor | 1 |
| **Toplam** | **40** |

Toplam olay sayısı 41'dir; `q60813` iki ayrı olay olarak gelmiştir.

---

## A. İlk düzeltme paketine kesin alınacak bozuk sorular

| ID | Sorun |
|---|---|
| `q61081` | Şıklarda “halka” ve “Ömer Erdoğan”; 2009/2018 birlikte. Tek doğru cevap yapısı bozuk. |
| `q60513` | Alakasız şıklar ve “yaban koyunudir” yazım hatası. |
| `q60872` | Kişi sorusunda “yağlı güreş” ve “Paralimpik Oyunları” gibi alakasız şıklar. |
| `q60813` | Doğru cevap Sırbistan; diğer şıklar “sarı ve siyah, 2010, 6”. İki ayrı kullanıcı olayı. |
| `q60766` | Takım sorusunun şıkları tarih ve kişi değerleriyle doldurulmuş. |
| `q60668` | Metin-Ali-Feyyaz sorusunun diğer şıkları alakasız. |
| `q59729` | “Daha Mutlu Olamam” şarkısında doğru cevap yanlış bildirildi; gerçek kayıt doğrulanmalı. |
| `q60481` | Bildirim zorluk olsa da seçenekler bariz sorunlu. |
| `q60525` | Bildirim zorluk olsa da seçenekler bariz sorunlu. |
| `q59537` | Bildirim zorluk olsa da seçenekler bariz sorunlu. |
| `q60705` | Bildirim zorluk olsa da seçenekler bariz sorunlu. |
| `q60836` | Fenerbahçe kadın voleybol sorusunda 2010 dışındaki şıklar alakasız. |
| `q60899` | Buse Tosun Çavuşoğlu sorusunda spor/yer şıkları alakasız. |
| `q60857` | Doğru cevap “smaçör”; diğer şıklar kulüp, yıl ve kişi. Gerçek sorun cevap değil seçenekler. |

---

## B. Zorluk seviyesi inceleme adayları

| ID | Sistem / kullanıcı | İlk değerlendirme |
|---|---|---|
| `q54456` | Kolay / Zor | Vasco da Gama-Hindistan. Muhtemelen Orta; Zor abartılı olabilir. |
| `q56292` | Kolay / Zor | Joshua Cohen / *The Netanyahus*. Büyük olasılıkla Zor. |
| `q59101` | Kolay / Zor | Muazzez İlmiye Çığ. En az Orta. |
| `q57392` | Kolay / Zor | *Only Murders in the Building*; ifade de gevşek. Orta/Zor incelenmeli. |
| `q60223` | Kolay / Zor | *Balık İzlerinin Sesi* - Buket Uzuner. Kolay değil. |
| `q54542` | Kolay / Zor | Nirvana sorusu. Tek oyla hemen değiştirilmemeli. |
| `q58001` | Orta / Zor | Sakkaroz formülü. Zor yapılması mantıklı aday. |
| `q56838` | Kolay / Zor | Banu Mushtaq ve 2025 ödül sezonu. Kolay değil. |

---

## C. Eski açık kayıtlar - yeniden kaynaktan incelenecek

- `q5895`
- `q56205`
- `q55642`
- `q53840`

Bu PDF'de soru içerikleri bulunmadığı için karar verilmemelidir.

---

## D. Henüz tek tek değerlendirilmemiş eski kuyruk kayıtları

- `q58048`
- `q3637`
- `q57669`
- `q57878`
- `q54698`
- `q60547`
- `q53762`
- `q56483`
- `q57606`
- `q60324`
- `q59480`
- `q54864`
- `q54578`

---

## E. Değişiklik gerekmiyor

| ID | Neden |
|---|---|
| `q54089` | “Suyun kimyasal formülü nedir?” Sistem ve kullanıcı zorluğu Kolay. |

---

## Güvenli düzeltme akışı

1. Güncel release dalından ayrı branch aç.
2. Her ID'yi gerçek `assets/questions.json` kaydıyla karşılaştır.
3. Soru, dört seçenek, doğru indeks, açıklama, kategori ve zorluğu birlikte düzelt.
4. ID'yi değiştirme.
5. Format/şema/duplicate QA çalıştır.
6. Testleri çalıştır.
7. PR aç ve değişiklik tablosunu ekle.
8. Merge ve yeni AAB doğrulandıktan sonra Sheet durumunu güncelle.
