# Bilgi Rotası Kapalı Test Yayın Hazırlığı

Bu repoda izlenen dosya güncel release sürümü, commit, AAB adı veya soru sayısı için statik kaynak değildir.

Yetkili `Closed test release doğrulaması` akışında `tools/rc1_quality_gate.py`, kalite kapısını çalıştırdıktan sonra `tools/release_readiness_report.py` aracılığıyla bu dosyayı çalışma anındaki gerçek değerlerle yeniden üretir. Üretilen kopya artifact içine `reports/RELEASE_READINESS.md` olarak alınır.

Dinamik kaynaklar:

- sürüm: `pubspec.yaml`
- soru sayısı ve soru dosyası SHA-256: `assets/questions.json`
- kaynak commit/ref: GitHub Actions `GITHUB_SHA` / `GITHUB_REF_NAME`
- AAB adı: workflow `AAB_FILE` değeri; yoksa sürümden deterministik türetme
- workflow run adresi: GitHub Actions çalışma ortamı

Bu dosya Play Console canlı kanalını, Firebase canlı deploy durumunu veya fiziksel cihaz kabulünü tek başına doğrulamaz.

## Fiziksel Google Play Internal Testing kontrol listesi

> Ayarlar ve öğretici: ZORUNLU. CI/emülatör kabulü fiziksel Play kurulumundaki bu kontrolün yerine geçmez.

- Google hesabıyla giriş ve uygulamayı yeniden açınca oturumun korunması.
- Misafir → Google geçişinde kayıtların doğru hesaba bağlanması ve hesaplar arası veri sızmaması.
- Eğitimin otomatik açılmaması; Ayarlar'dan açılıp “Anladım” ile kapanması.
- İki ayrı fiziksel cihaz/hesapla Canlı Düello eşleşme, maç bitişi, sonuç kaydı ve leaderboard güncellemesi.
- Leaderboard belgesi yokken sıra gösterilmemesi; belge oluştuktan sonra tutarlı sıra.
- Kapalı-test sürümünde yalnız Google demo reklam kreatifleri.
