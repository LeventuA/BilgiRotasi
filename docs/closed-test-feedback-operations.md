BİLGİ ROTASI – KAPALI TEST GERİ BİLDİRİM GÜNCELLEMESİ
================================================================

Bu paket main dalına yazmaz.

Taban dal:
  release/final-closed-test-aab-1.68.8

Oluşturacağı dal:
  fix/closed-test-feedback-1.68.12

İşlemler:
- 9 sorunun zorluğu güncellenir.
- q57860 sorusunun seçenekleri ABC/NBC/CBS/FOX biçiminde düzeltilir.
- Güncel 1.68.11+101 sürümü 1.68.12+102 olarak artırılır.
- Analiz ve testler çalıştırılır.
- Ayrı branch push edilir; GitHub CLI varsa Draft PR açılır.
- Apps Script için eski sürüm ve mükerrer Olay ID koruması repoya eklenir.
- Backend veya Apps Script otomatik deploy edilmez.

KURULUM

ZIP'i repo ana klasörüne yükleyin ve terminalde:

  git pull
  unzip -o BilgiRotasi_Kapali_Test_GeriBildirim_Guncellemesi_V2.zip
  python3 BilgiRotasi_Kapali_Test_GeriBildirim_Guncellemesi_V2/install_closed_test_feedback_update.py

Apps Script koruması ayrıca mevcut doPost(e) fonksiyonuna entegre edilip
Deploy > Manage deployments > Edit > New version > Deploy ile yayımlanmalıdır.

ÖNEMLİ
- git add . kullanmayın.
- Draft PR incelenmeden release dalına birleştirmeyin.
- Kurulum başarıyla bitmeden aktif Sheet satırlarını Düzeltildi yapmayın.
