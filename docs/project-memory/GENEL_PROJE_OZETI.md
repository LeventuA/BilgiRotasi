# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 26 Ağustos 2026 — Kelime Avı Başlangıç Limanı release entegrasyonu

> Teknik doğrulukta tek kanonik kaynak canlı `ZMilaStudio/BilgiRotasi` deposu ve ilgili canlı servislerdir. Bu dosya canlı branch/PR/CI/pubspec doğrulamasının yerine geçmez.

## Kalıcı çalışma kuralı

- Yeni sohbet başında önce bu dosya, ardından `BILGI_ROTASI_DURUM.md`, `KARARLAR.md`, `GOREV_HAVUZU.md` ve gerekiyorsa `ACIK_SORULAR_VE_DOGRULAMALAR.md` okunur.
- Her görev öncesi canlı hedef branch, `pubspec.yaml`, son commit, ilgili PR ve CI doğrulanır.
- Doğrudan `main` veya release dalına yazılmaz; ayrı branch/PR kullanılır.
- Sıra: test → commit → push → PR → inceleme → merge.
- Kritik merge için Levent'in açık onayı gerekir.
- Build/teknik PASS tek başına çalışma veya görsel kabul kanıtı değildir.
- Bu dosya her proje yanıtından sonra yalnız gerekli farklarla güncel tutulur; önemli geçmiş silinmez.
- Eski tam kayıtlar `docs/project-memory/archive/` ve Git geçmişinde korunur.

## Canlı yayın hattı

- Repo: `ZMilaStudio/BilgiRotasi`
- Kanonik release branch: `release/final-closed-test-aab-1.68.8`
- Release entegrasyonuna başlanırken canlı release HEAD: `8977d7ecdc88b50aedc9933739a1e17ac5b39833`
- Sürüm: `1.68.19+109`
- Paket: `com.leventua.bilgirotasi`
- `main` güncel yayın kaynağı olarak varsayılmaz.
- Release'teki artifact-retention politikaları, GitHub Releases üretim hattı ve proje-hafızası çalışma kuralı korunacaktır.

## Kelime Avı — ürün yönü

- Kelime Avı Bilgi Rotası içinde Flutter ile geliştirilecektir; Godot runtime/entegrasyon bağımlılığı değildir.
- İlk rota/paket: **Başlangıç Limanı**.
- Hedef paket: 10 bölüm / 30 yıldız; rota → bölüm → kelime avı → sonuç/yıldız → rotaya dönüş döngüsü tamamlanacaktır.
- Production `lib/main.dart` ana navigasyon bağlantısı henüz ayrı geliştirme kapsamıdır; bu release entegrasyonu onu eklemez.

## Başlangıç Limanı — bağlayıcı görsel ve mimari

- Tek bağlayıcı görsel kaynak Issue #109 `Photo 1.jpg` MASTER ART'tır.
- Repo asset'i: `assets/word_hunt/baslangic_limani_master_art_visual_proof.jpg`.
- Kaynak 720×1280; SHA-256 `fb4597bb4d37b30cefeec2ba913c591fe9471529f80966830afd5b801a86fca3`.
- Canonical Android/proof alanı 1080×1920; uniform scale 1.5; crop/stretch yok.
- PR #146 / `c42a9ff...` ve önceki ChatGPT-generated hedef asset'ler **REJECTED BY LEVENT — NOT A VISUAL SOURCE**.
- Levent tarafından kabul edilen production mimarisi: **MASTER ART RASTER → TRANSPARENT INTERACTION HITBOXES → MINIMUM LOCAL STATE OVERRIDES**.
- Görünür rota/node/plaque/crown/control sanatı ikinci kez komple Flutter katmanı olarak çizilmez.
- Bu karar yalnız Başlangıç Limanı için daha önceki layered-only şartı supersede eder; diğer tema/rotalara otomatik genellenmez.

## Dynamic progression sözleşmesi

- MASTER ART içindeki demo state gerçek progression gerçeğini bozamaz.
- Gerçek `X / 30`, level 1–10 gerçek 0–3 yıldız durumu ve locked/open görünümü lokal runtime override ile senkron tutulur.
- Level 7 tamamlanınca bonus 8 ve normal 9 birlikte açılır.
- Bonus 8, node 9 için zorunlu geçiş kapısı değildir.
- Node 9 gerçek callback üretir.
- Node 10, node 9 tamamlanmadan locked ve callback üretmeyen durumda kalır.
- Görünür state ile interaction state aynı gerçeği göstermelidir.

## Tamamlanan PR zinciri

- PR #147 → PR #132 branch'ine merge edildi: MASTER ART production route + node 9 progression.
- PR #150 → PR #132 branch'ine merge edildi: dynamic `X/30`, yıldız ve locked/open state.
- PR #149/#151/#152 → hafıza, exact-tree Android gate ve final cleanup tamamlandı.
- PR #132 → PR #110 head branch'ine merge edildi: `60991051a255608bc631b1341001748aa1a754b8`.
- PR #110 → PR #107 head branch'ine merge edildi: `33a08e589f00928306f759fc4f20738991323896`.
- PR #107 → foundation/#96 head branch'ine merge edildi: `ef34a1858d1a16da829a77c125d4953f7336b06d`.
- Eski PR #96 branch'i güncel release'ten ayrıştığı için release'e doğrudan zorla merge edilmeyecek; güncel release tabanından temiz entegrasyon hazırlanacaktır.

## Son kabul edilmiş Android 16 kanıtı

- Final cleanup test HEAD: `706f3b3cf628783a44b0bcf2c07374013005e4d6`.
- Production run `32977835805`: SUCCESS; artifact `9610537615`.
- Pixel-proof run `32977835819`: SUCCESS; artifact `9610520454`.
- Test edilen tree ile PR #152 sonrası ve PR #132 merge sonrası ürün tree'si eşit: `9a7bf8fd8b9aea96fdb3c86eb365d30e74cbe312`.
- Final ekran görsel olarak kabul edildi: gerçek progression görünümü korunuyor; eski demo sayaç/yıldız kalıntısı yok.

## Korunan alanlar

Bu entegrasyonda kontrolsüz değiştirilmez:
- production `lib/main.dart`
- `assets/questions.json`
- BoardMap / 67 node / 3B tahta
- AdMob / Firebase / Android release config
- paket/sürüm sözleşmesi
- release'te sonradan eklenen retention ve GitHub Releases workflow değişiklikleri

## Sıradaki aktif işler

1. Güncel release `8977d7ec...` tabanından temiz Kelime Avı release-integration branch/PR oluştur.
2. Release-only 5 committeki CI/retention/GitHub Releases/hafıza değişikliklerini koru.
3. Entegrasyon exact HEAD üzerinde full/focused test + analyze + release PR validation çalıştır.
4. Aynı exact tree üzerinde Android 16 production route + pixel-proof kanıtı üret ve ekranı kontrol et.
5. Tüm kapılar PASS ise kullanıcı tarafından verilmiş zinciri bitirme onayı kapsamında release'e kontrollü merge et; Play yükleme/yayınlama yapma.
6. Release entegrasyonu tamamlandıktan sonra güncel release'ten yeni `feat/kelime-avi-gameplay-v1` benzeri branch açarak Bölüm 1 gerçek oynanış döngüsüne devam et.
