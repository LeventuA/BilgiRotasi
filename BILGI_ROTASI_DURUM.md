# Bilgi Rotası – Proje Durumu

**Son güncelleme:** 30 Ağustos 2026

## Canlı Sürüm / Release Hattı

- Repo: `ZMilaStudio/BilgiRotasi`
- Kanonik release branch: `release/final-closed-test-aab-1.68.8`
- Release HEAD: `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`
- Sürüm: **1.68.19+109**
- Paket: `com.leventua.bilgirotasi`
- `main` yayın kaynağı olarak varsayılmaz.

## Başlangıç Limanı 8×8 — TEKNİK PASS

- Branch: `feat/kelime-avi-8x8-content-v1-20260829`
- Temiz ürün commit: `052ea7da775db0b58a5ce0c6731a04f251879008`
- Final gate run `33251736068`: **SUCCESS**.
- Focused Word Hunt **37/37**, full Flutter **442/442 PASS**.
- Android16 B1/B5/B8/B10 **64/64** görünürlük; B5 soft-time, ANKARA ve ters BAŞKENT swipe, crash/ANR taraması PASS.
- Draft PR #158: **OPEN / DRAFT / merged=false / mergeable=true**.
- Kullanıcı kabulü olmadan Ready/merge yok.

## Başlangıç Limanı Bölüm İçi Tema — TEKNİK PASS / GÖRSEL V4 REDDEDİLDİ

Canlı clean theme branch:
`feat/kelime-avi-baslangic-limani-theme-clean-v1-20260829`

Son doğrulanmış branch HEAD görev başında:
`02951f63445ee064e7856c6b36873052ae2f54df`

V4 teknik runtime kanıtı:
- Run `33278797412`: **SUCCESS**.
- Job `99170289209`.
- B1/B10 debug APK build/install/launch PASS.
- API36 / 1080×1920 / 420 dpi PASS.
- B1/B10 screenshot + UI XML + logcat üretildi.
- Crash/ANR/FATAL/am_crash taraması temiz.
- Artifact `9722440135`, digest `sha256:bf91d7591b4348b3268983f9938a9042631729b8ad7a126c27e6ba35504f3a70`.

### 30 Ağustos bağlayıcı görsel kararı

Kullanıcı V4 ekranlarını seçilen temaya göre **çok uzak** buldu ve görsel olarak reddetti.

Yeni bağlayıcı hedef:
- Kullanıcının 30 Ağustos 2026'da sohbet içinde yeniden gönderdiği **Bölüm 10 / Başlangıç Limanı** gece limanı ekranı.
- Bu görsel “ilham” veya “yaklaşık tema” değildir; **mümkün olan en yüksek sadakatle birebir hedef** kabul edilir.
- ChatGPT/Codex yeni sanat yönü, ekstra çizim, alternatif dekor veya kendi yorumunu eklemez.
- Referansın görsel dili aynen hedeflenir: gece limanı, sağ üst deniz feneri ve amber ışık huzmesi, su yansımaları, sol liman feneri/detayları, koyu lacivert-altın metal sayaç panelleri, aynı dilde kelime chipleri, lacivert-altın harf hücreleri, sıcak amber found/selection glow ve alt çapa/pusula bilgi paneli.
- Gerçek oyun **8×8** kalır; referans görseldeki örnek harf/kelime düzeni canonical oyun verisini değiştirmez.
- Önceki hafif overlay teması nihai görsel yön olarak **superseded** edilmiştir; `a91236c9...` yalnız teknik tarihsel checkpointtir.

## Aktif Sonraki İş

1. Aynı clean theme branch üzerinde referans sadakatli tema yeniden uygulanacak.
2. Oynanış, 8×8 içerik, path/scoring/gesture, MASTER ART rota ekranı, `lib/main.dart`, BoardMap/67 node, AdMob/Firebase/signing/version korunacak.
3. Yeni uygulama formatter/analyze/test → APK → Android16 B1/B10 screenshot/UI/logcat kapısından geçecek.
4. Yeni gerçek screenshot referansla yan yana kontrol edilmeden görsel PASS verilmeyecek.
5. Kullanıcı açık görsel kabulü olmadan theme PR Ready/merge yapılmayacak.
6. PR #158 için Ready ve merge ayrıca açık kullanıcı onayı ister.
7. B5/B10 gerçek insan süre dengesi ayrı açık kapıdır.

## Korunan Alanlar

Açık kapsam olmadan değiştirilmez:
- `lib/main.dart`
- `pubspec.yaml`
- `assets/questions.json`
- MASTER ART / route geometry
- `word_hunt_path.dart`, `word_hunt_models.dart`
- BoardMap / 67 node / 3B tahta
- AdMob / Firebase / Android release-signing
- package/version

## Kanonik Devir Dosyası

`docs/project-memory/GENEL_PROJE_OZETI.md`
