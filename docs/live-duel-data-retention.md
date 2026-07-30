# Canlı Düello veri saklama ve temizleme

`cleanupLiveDuelData` saatlik scheduled function olarak hazırlanmıştır:

- Eşleştirme kuyruğu: belge süresi dolunca, en geç sonraki saatlik çalışmada.
- Yarım kalan maç: son güncellemeden 24 saat sonra `expired`.
- Presence: 24 saat sonra silinir.
- Progress/cevap ilerlemesi: 30 gün sonra silinir.
- Sonuç iddiası/idempotency kaydı: 90 gün sonra silinir; BR ve toplam
  istatistikler sunucu profilinde kalır.
- Tamamlanmış maçtaki kullanıcı adı ve özel UID bağlantıları: 90 gün sonra
  anonimleştirilir. UID anahtarlı skor/kazanan alanları publicPlayerId
  karşılıklarına dönüştürülür; skor ve rekabet bütünlüğü korunur.
- Oyuncu raporları: inceleme/güvenlik amacıyla en fazla 365 gün; sonra silinir.
- Rate-limit belgeleri: `expiresAt` alanıyla oluşturulur; Firestore TTL politikası
  Console'da ayrıca etkinleştirilmelidir.

Bu süreler kodda hazırdır ancak scheduled function production'a deploy edilene
ve TTL politikası Console'da açılana kadar otomatik çalıştığı iddia edilmez.
