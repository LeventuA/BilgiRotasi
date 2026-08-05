# Bilgi Rotası - Kaynak Defteri

Bu paket hazırlanırken biçimsel **devir özeti** bölümleri karar kaynağı olarak kullanılmadı. Her kaynak aşağıdaki güven seviyesiyle işlendi.

| Kod | Kaynak | Tür | Kullanım | Not |
|---|---|---|---|---|
| S01 | Proje Durumu ve Plan (23-25 Temmuz 2026) | ChatGPT dışa aktarımından doğrudan konuşma zinciri | Birincil | İlk devir okuma mesajı ve sohbet sonundaki devir özeti karar kaynağı olarak kullanılmadı. |
| S02 | Branch · Proje Durumu ve Plan (25-28 Temmuz 2026) | ChatGPT dışa aktarımından doğrudan branch konuşma zinciri | Birincil | Ana sohbetle ortak kısım tekilleştirildi; yalnız branch sonrası farklı mesajlar esas alındı. |
| S03 | Bilgi_Rotasi_Oyun_Gelistirme_Konusmasi.pdf (2-9 birincil; 10-21 devir özeti olarak dışlandı) | Kullanıcı/asistan konuşma dökümü | Birincil |  |
| S04 | Bilgi_Rotasi_Konusma_Arsivi_2026-08-04.pdf (33-38 doğrudan son mesaj dökümü; 2-32 devir özeti olarak dışlandı) | Arşiv PDF | Birincil yalnız belirtilen sayfalar |  |
| S05 | Bilgi_Rotasi_Google_Play_ve_Tanitim_Sohbeti.pdf (2-10) | Düzenlenmiş konuşma arşivi | Orta güven | PDF bazı mesajların atlandığını açıkça belirtiyor. Varlık üretimi kaydedildi; onay/yükleme kanıtı yoksa tamamlandı sayılmadı. |
| S06 | Sohbet_Dokumu1_2026-08-04.pdf (2-7) | Kullanıcıya görünen mesajların doğrudan dökümü | Birincil | İlk mesajdaki eski devir metni dışlandı; canlı Sheet kontrol mesajları esas alındı. |
| S07 | Bilgi_Rotasi_3B_Tahta_Konusma_Kaydi_2026-08-04.pdf (1-22) | Düzenlenmiş ayrıntılı konuşma kaydı | İkincil/konuya özel | Ham birebir döküm değil. Yalnız 3B tahta çalışmasının son durumunu kaydetmek için kullanıldı; canlı repo kanıtı yerine geçmez. |
| S08 | Bilgi_Rotasi_Eklentiler_Sohbet_Dokumu.pdf (2-11) | Doğrudan konuşma dökümü | Birincil |  |
| S09 | B_Sohbet_Dokumu_2026-08-04-1.pdf (2-18) | Sürüm ve durum konuşması | Destekleyici | İçinde birden çok tarihsel durum özeti bulunuyor. Yalnız en son bölüm ve başka kaynaklarla uyuşan bilgiler kullanıldı. |
| S10 | Bilgi_Rotasi_Sohbet_Kaydi_2026-08-04.pdf (3-36) | Seçilmiş mesajlar ve teknik kayıt | Destekleyici | Eksik mesajlar bulunduğu için güncel proje durumunun tek kaynağı yapılmadı. |
| X01 | Bilgi_Rotasi_Sohbet_Kaydi.pdf () | Yapılandırılmış devir kaydı | Analizden dışlandı | Kullanıcının talebi gereği devir özeti proje gerçeği olarak kullanılmadı. |

## Çözümleme kuralları

- Aynı mesaj branch ve ana sohbette tekrar ediyorsa bir kez sayıldı.
- Levent'in daha yeni ve açık kararı eski önerinin önüne geçti.
- “Hazır”, “tamamlandı” veya “çalışıyor” ifadesi test/merge/yayın kanıtı yoksa `RAPORLANDI` olarak yazıldı.
- Bir PDF “skipped messages” veya “seçilmiş mesajlar” diyorsa eksiksiz ham kayıt kabul edilmedi.
- Sürüm numaraları kronolojik olarak güncellendi; eski sürümler güncel duruma taşınmadı.
- 3B tahta kaydı ham sohbet olmadığı için yalnız konuya özel son durum kaydı olarak kullanıldı.
