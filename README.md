# Bilgi Rotası - Proje Hafızası V2

**Hazırlanma tarihi:** 5 Ağustos 2026  
**Kaynak kesim noktası:** 4 Ağustos 2026 gecesi  
**Temel ilke:** Bu paket devir özetlerinden kopyalanmadı. Doğrudan konuşma akışları, Levent'in açık kararları, kullanıcı testleri, ekran kayıtları ve son konuşmalardaki gerçek gelişmeler esas alındı.

## Önceki paket neden geçersiz?

İlk paket 3 Ağustos 2026 saat 10:50'de alınan dışa aktarıma dayanıyordu. Sonraki gün konuşulan:

- `1.68.13+103` sürümü,
- PR #9 ve PR #10,
- Kapalı Test yayını,
- canlı Sheet geri bildirimleri,
- yeni 3B tahta denemeleri,
- kategori rozeti çalışmaları

pakette yoktu. V2 baştan hazırlanmıştır; V1 üzerine yama yapılmamıştır.

## Bu paketteki doğruluk sırası

1. Canlı GitHub / Play Console / Firebase / Sheet
2. `BILGI_ROTASI_DURUM.md`
3. `KARARLAR.md`
4. `GOREV_HAVUZU.md`
5. Konuya özel dosyalar
6. Eski sohbetler

## Dosyalar

| Dosya | Amaç |
|---|---|
| `BILGI_ROTASI_DURUM.md` | Kesim noktasındaki gerçek proje durumu |
| `KARARLAR.md` | Kesinleşen, reddedilen ve ertelenen kararlar |
| `GOREV_HAVUZU.md` | Önceliklendirilmiş açık işler |
| `SORU_GERI_BILDIRIM_HAVUZU.md` | Sheet'teki soru olaylarının ayıklanmış listesi |
| `3B_TAHTA_DURUMU.md` | Tahta denemeleri, topoloji ve durdurulan işler |
| `MAGAZA_VE_TANITIM_VARLIKLARI.md` | Üretilen, onaylanan ve reddedilen görseller/videolar |
| `TEKNIK_GENEL_BAKIS.md` | Teknoloji, branch, test ve çalışma düzeni |
| `ACIK_SORULAR_VE_DOGRULAMALAR.md` | Canlı kaynaktan kontrol edilmesi gerekenler |
| `KAYNAK_DEFTERI.md` | Hangi bilginin hangi konuşmadan geldiği |
| `CHATGPT_PROJE_TALIMATI.txt` | ChatGPT Projesi talimatlarına yapıştırılacak metin |
| `GUNCELLEME_SABLONU.md` | Her çalışma sonunda doldurulacak kısa kayıt |
| `V1_DUZELTME_NOTU.md` | Eski paketteki başlıca yanlışlar |
| `MANIFEST.json` | Dosya ve kaynak bütünlük kaydı |

## Kullanım

Yeni bir Bilgi Rotası sohbeti açıldığında önce:

1. `BILGI_ROTASI_DURUM.md`
2. `KARARLAR.md`
3. `GOREV_HAVUZU.md`
4. Yapılacak işle ilgili konu dosyası

okunmalıdır.

Sohbet geçmişi yalnız ayrıntı gerektiğinde açılmalıdır. Eski sohbet içindeki kod, canlı repo görülmeden kullanılmamalıdır.
