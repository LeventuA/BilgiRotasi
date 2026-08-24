# Bilgi Rotası — Genel Proje Özeti

**Amaç:** Bu dosya yeni bir sohbetin Bilgi Rotası bağlamını hızlı ve güvenli biçimde devralması için yaşayan özet kaydıdır.

> Teknik doğrulukta tek kanonik kaynak canlı `ZMilaStudio/BilgiRotasi` deposu ve ilgili canlı servislerdir. Bu dosya canlı branch/PR/pubspec doğrulamasının yerine geçmez.

## Kalıcı çalışma kuralı

- Yeni sohbet başında önce bu dosya okunur; ardından `BILGI_ROTASI_DURUM.md`, `KARARLAR.md`, `GOREV_HAVUZU.md`, canlı hedef branch, `pubspec.yaml`, son commit ve ilgili PR durumu doğrulanır.
- Bu proje kapsamındaki **her yanıtın sonunda** bu dosya yalnız gerekli farklarla güncellenir.
- Yeni kararlar, tamamlanan görevler, branch/commit/PR/test kanıtları ve açık konular eklenir.
- Gereksiz tekrarlar temizlenebilir; önemli teknik, ürün ve görsel kararlar silinmez.
- Dosya her seferinde sıfırdan yazılmaz; önceki kayıtlar korunur ve yalnız gerekli değişiklik uygulanır.
- Yeni sohbeti başlatmaya yetecek güncellikte tutulur.
- Doğrulanmamış bilgi `DOĞRULANACAK` olarak işaretlenir; tahmin yapılmaz.

## Canlı yayın hattı

- Repo: `ZMilaStudio/BilgiRotasi`
- Kanonik release branch: `release/final-closed-test-aab-1.68.8`
- Son doğrulanan release HEAD: `8977d7ecdc88b50aedc9933739a1e17ac5b39833` — PR #106 squash merge.
- Release `pubspec.yaml`: `1.68.19+109`
- Paket: `com.leventua.bilgirotasi`
- `main` yayın kaynağı olarak varsayılmaz.

## Git çalışma sözleşmesi

- Doğrudan main/release'e yazılmaz; ayrı branch açılır.
- Sıra: test → commit → push → PR → inceleme → merge.
- Kritik merge için Levent'in açık onayı gerekir.
- Build başarısı tek başına çalışma kanıtı değildir; log, workflow, diff, test ve Git geçmişi birlikte incelenir.
- `assets/questions.json` kontrolsüz değiştirilmez.
- İlgisiz yerel değişiklikler silinmez; `git reset --hard` rutin çözüm değildir.

## Kelime Avı — ürün yönü

- Kelime Avı mevcut Bilgi Rotası uygulaması içinde **Flutter** ile çalışır.
- Godot Kelime Avı için çalışma zamanı veya entegrasyon bağımlılığı değildir.
- İlk rota: **Başlangıç Limanı**.
- 10 bölüm, 30 yıldız, 6 Bilgi Kartı.
- 8 yönlü parmak seçimi, sıralı açılma, 1–3 yıldız ve rota finali + yıldız eşiği sözleşmesi korunur.
- Ayırt edici mekanik: **Kayıp Kelime + Bilgi Kartı**.
- Production `lib/main.dart` entegrasyonu ayrı branch ve ayrı açık kullanıcı onayı gerektirir.

## Kelime Avı — resmi görsel standart

**Kalıcı karar:** Kullanıcı tarafından onaylanan referans görseller projenin resmi görsel standardını oluşturur.

- Her tema kendi onaylanmış referans görselini temel alır.
- O temaya ait tüm görsel varlıklar sanat stili, görsel kalite seviyesi, renk paleti, ışıklandırma ve genel atmosfer açısından o referansla tutarlı olur.
- Referans, serbest ilham görseli değil; kalite ve kompozisyon sözleşmesidir.
- Başlangıç Limanı için kullanıcının son onayladığı gece limanı referansı resmi tema standardıdır.

## Kelime Avı — modüler görsel üretim sistemi

- AI'dan tam ekran oyun arayüzü üretilmez; tek seferde yalnız tek görsel parça istenir.
- Temel parçalar: arka plan, rota/yol, bölüm düğümleri, yıldızlar/kilitler, Meydan Okuma kartı, Bonus Durak kartı, Rota Finali kartı, üst bilgi paneli, alt menü/yardımcı ikonlar.
- Tek ortak buton/bileşen sistemi kullanılır; tema değişince geometri ve davranış değil, tema rengi/doku/süs/ışık karakteri değişir.
- Örnek: Liman = turkuaz + mor + altın; Orman = yeşil + bronz.
- Arka plan asset'lerinde yazı, bölüm numarası, yıldız, kilit, buton, etiket, logo veya telefon çerçevesi bulunmaz.
- Metinler, rota, düğümler, yıldız/kilit durumları ve etkileşimli UI Flutter overlay olarak çizilir.
- Hedef tek bir mükemmel ekran değil; aynı kaliteyi koruyan yüzlerce tema ve binlerce bölüm üretebilen sistemdir.

## Başlangıç Limanı — son görsel/geometri durumu

### PR #96 — foundation
- Branch: `feat/kelime-avi-clean-release-integration-20260821`
- Head: `070b7306ccd4e3273e81c0ac2a7ad1f489185d95`
- Durum: OPEN / DRAFT / merge yok.
- Onaylı gece limanı background asset'i ve Kelime Avı foundation burada.

### PR #98 — referans yerleşim
- Branch: `fix/kelime-avi-reference-layout-20260822`
- Bu özet hazırlanırken doğrulanan head: `54d75cd60217c3867601a23e10ddd1a4fe68f920`
- Son commit: `fix(kelime-avi): separate level 7 from locked stop`
- 7. durak `Offset(0.29, 0.58)` → `Offset(0.36, 0.58)` alınarak 9'dan uzaklaştırıldı.
- Regression beklentisi: `center(7).dx - center(9).dx > 40`.
- Exact-head Android 16 visual-proof run `32571152461`: SUCCESS.
- Exact-head genel AdMob/release regression run `32571152462`: SUCCESS.
- Visual artifact ID `9475441130`; digest `sha256:582bf85e0a19ed2b374332607c77568d3116ba341f76f267d35271aa0e1fadc1`.
- PR #98 Draft; kullanıcı açık onayı olmadan parent PR #96 hattına merge edilmez.

### Başlangıç Limanı yerleşim sözleşmesi
- 1–4 üst bölgede ferah ilerler.
- 5 `MEYDAN OKUMA`: merkez-sol; kart sağında.
- 6 sol geçiş durağı.
- 7 merkez/merkez-sağ; 9'dan belirgin uzak.
- 8 `BONUS DURAK`: sağda; kart sağında.
- 9 kilitli durak solda.
- 10 `ROTA FİNALİ`: alt-orta; kart sağında.
- Pusula sol altta, kitap sağ altta.

## Onaylı Başlangıç Limanı background asset'i

- `assets/word_hunt/baslangic_limani_bg.jpg`
- JPEG `1080x2340`, `81310` byte.
- SHA-256 `ea0034e2b3a7713f36bd36d2757815748e2988e831c91f213ad0c7a2eb050d45`.
- Paketlenmiş asset'in kaynakla byte-for-byte aynı olduğu ve runtime'da `[WORD_HUNT_ASSET_LOADED]` verdiği doğrulanmıştır.

## Korunan alanlar

Kelime Avı görsel çalışmalarında açık onay olmadan değişmez:
- `assets/questions.json`
- production `lib/main.dart`
- mevcut oyun/progression mantığı
- BoardMap / 67 node / 3B tahta
- Android / AdMob / Firebase / release config
- onaylı Başlangıç Limanı background asset'i

## Yaşayan özet kalıcılaştırması — PR #106

- Branch: `docs/general-project-summary-rule-20260822`.
- PR #106: **MERGED**.
- Final PR head: `27081e59d40696f1c0cf83cbec23aef67eea60a3`.
- Squash merge SHA / release HEAD: `8977d7ecdc88b50aedc9933739a1e17ac5b39833`.
- Commit: `docs: make general project summary a permanent workflow rule (#106)`.
- Exact-head AdMob PR doğrulaması run/job `32578442339` / `97044127097`: **SUCCESS**; analyze+tüm testler, release APK, paket/manifest ve Android 16 app/release gate PASS.
- Artifact: `BilgiRotasi-AdMob-1.68.19-109-kanitlari`, ID `9477310958`, digest `sha256:2526375593aaf25f440fc579da6a0ab379d16fdb0af2c6077c48ab5c87c278cc`.
- Merge yalnız `docs/project-memory/CHATGPT_PROJE_TALIMATI.txt`, `docs/project-memory/GENEL_PROJE_OZETI.md`, `docs/project-memory/KARARLAR.md` dosyalarını değiştirdi; runtime, `assets/questions.json`, `lib/main.dart`, BoardMap/3B ve release konfigürasyonu değişmedi.
- `CHATGPT_PROJE_TALIMATI.txt` artık yeni sohbet başında `GENEL_PROJE_OZETI.md` okuma ve her proje yanıtından sonra fark bazlı güncelleme kuralını içerir.
- ChatGPT uygulamasındaki **Proje Talimatları** alanını bu oturumdan doğrudan değiştirecek bir proje-ayar yazma aracı yoktur. Bu nedenle UI alanına aynı kuralın kullanıcı tarafından bir kez eklenmesi `DOĞRULANACAK / MANUEL` kalır.
- Yanlışlıkla açılan boş Draft PR #133 aynı dakika içinde kapatıldı; merge edilmedi ve ürün/release değişikliği oluşturmadı.

## Sıradaki açık kapılar

1. 7 numara düzeltmesi dahil son gerçek Android 16 görünümünün kullanıcı tarafından nihai görsel kabulü.
2. Kabul sonrası PR #98'in yalnız parent Kelime Avı branch'ine alınmasının değerlendirilmesi; release'e doğrudan merge yok.
3. Parent PR #96 yeni exact HEAD üzerinde focused suite + tüm testler + Android 16 + regression yeniden çalıştırılır.
4. PR #96 → release ancak Levent ayrıca açık merge onayı verirse.
5. Production ana navigasyon entegrasyonu ayrı branch ve ayrı onayla yapılır.
6. Başlangıç Limanı kabulünden sonra sonraki temalar modüler asset sistemiyle üretilir; her tema için ayrı kullanıcı-onaylı resmi referans gerekir.
7. ChatGPT Proje Talimatları UI alanına kısa otomatik-özet kuralı bir kez eklenirse yeni sohbetlerde repo kuralını çağırma davranışı daha güvenilir olur.

## Bu özetin bakım kuralı

Her yanıttan sonra:
1. Yeni karar varsa ekle.
2. Tamamlanan işi ve kanıtını güncelle.
3. Açık kalan konuyu not et.
4. Gereksiz tekrarları temizle.
5. Önemli geçmişi silme.
6. Dosyayı sıfırdan yeniden yazma; yalnız gerekli farkı uygula.
