# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 24 Ağustos 2026, 03:16 (Europe/Istanbul)

> Bu dosya yeni bir sohbeti hızlı ve güvenli biçimde başlatmak için yaşayan devir özetidir. Teknik doğrulukta tek kanonik kaynak canlı `ZMilaStudio/BilgiRotasi` GitHub deposu ve ilgili canlı servislerdir. Bu özet canlı repo doğrulamasının yerine geçmez.

## 1. Kalıcı çalışma kuralı

- Her Bilgi Rotası / Kelime Avı çalışmasında önce canlı repo, hedef branch, `pubspec.yaml`, son commit ve açık PR durumu doğrulanır.
- `main` güncel varsayılmaz.
- Doğrudan `main` veya release dalına yazılmaz; ayrı branch kullanılır.
- Sıra: test → commit → push → PR → inceleme → merge.
- Kritik merge için Levent'in açık onayı gerekir.
- Teknik PASS görsel PASS değildir.
- `assets/questions.json`, BoardMap/67 node/3B, production `lib/main.dart`, Firebase/AdMob/Android/release config kontrolsüz değiştirilmez.
- Bu dosya yalnız gerekli farklarla güncellenir; kritik geçmiş ve kararlar korunur.

## 2. Canlı Kelime Avı teknik durumu

- Repo: `ZMilaStudio/BilgiRotasi`
- Kanonik release branch: `release/final-closed-test-aab-1.68.8`
- Kelime Avı güncel çalışma sürümü: `1.68.19+109`
- Paket: `com.leventua.bilgirotasi`
- `main` HEAD: `f42ba228bd7c38b0a00448a19f43d762058e4319` — `ci: add weekly Dependabot updates (#113)`.
- `main/pubspec.yaml` sürümü eski hatta `1.68.6+96`; Kelime Avı için çalışma kaynağı değildir.

### PR #110 — Başlangıç Limanı mevcut teknik çekirdeği

- PR: `#110` — `feat(kelime-avi): pixel-match approved Baslangic Limani reference`
- Branch: `fix/kelime-avi-approved-reference-pixel-match-20260823`
- Güncel HEAD: `bc8a03bfefd401570e0c51cc4aab4206ea45d363`
- Durum: **OPEN / DRAFT / MERGE YOK**
- Sürüm: `1.68.19+109`
- Korunacak kazanımlar: Flutter + Dart, 1080×1920 canonical coordinate-space, tek scene transform, 1–10 deterministik koordinatlar, route control point'leri, progression/unlock, interaction ve regresyon testleri.
- Eski 77/77 focused ve Android 16 kanıtı `5523caf...` product head'ine aittir; güncel `bc8a03bf...` HEAD için kör biçimde yeniden kullanılamaz.

### PR #131 — bağlayıcı görsel üretim standardı

- PR: `#131` — `docs: add Kelime Avı visual production standard`
- Branch: `docs/visual-game-production-standard`
- HEAD: `1b74bf6ff5c3df2a5aaf50822e889441da56b4e4`
- Durum: **OPEN / DRAFT / MERGE YOK**
- Dosya: `görsel oyun üretimstandartı.md`
- Kullanıcı talimatıyla Kelime Avı için bağlayıcı standarttır; PR'ın kendisi Levent açık merge onayı vermeden merge edilmez.

### PR #132 — Başlangıç Limanı asset-first pilotu

- PR: `#132` — `feat(kelime-avi): start Baslangic Limani asset-first production pilot`
- Base: PR #110 branch'i `fix/kelime-avi-approved-reference-pixel-match-20260823`
- Base exact SHA: `bc8a03bfefd401570e0c51cc4aab4206ea45d363`
- Branch: `feat/kelime-avi-baslangic-limani-asset-first-20260824`
- Son asset commit'i: `470118940fdcfe6ece6dd4799436832cfd856fe9` — `assets(kelime-avi): add Baslangic Limani challenge medallion`.
- Durum: **OPEN / DRAFT / MERGE YOK / AKTİF ÇALIŞMA**
- İlk asset sözleşmesi: `docs/kelime-avi/BASLANGIC_LIMANI_PRODUCTION_ASSET_CONTRACT.md`.
- Asset seçim kodu: `lib/word_hunt/word_hunt_production_assets.dart`.
- Asset mapping testi: `test/word_hunt_production_assets_test.dart`.
- MASTER ART bu sohbet içinde yeniden sağlandı ve tek bağlayıcı görsel referans olarak kilitlendi.
- Repo içine gerçek binary production asset olarak eklenenler:
  - `assets/word_hunt/baslangic_limani/node_normal.webp`
  - `assets/word_hunt/baslangic_limani/node_locked.webp`
  - `assets/word_hunt/baslangic_limani/node_challenge.webp`
- Branch içinden push-triggered tek kullanımlık apply workflow denenmiş ancak connector/API commit'i workflow'u tetiklemedi. Test edilmemiş kod zorla commit edilmedi; geçici workflow ve helper dosyaları branch'ten temizlendi.
- Asset-backed `WordHuntRouteStop` entegrasyonu hâlâ **DOĞRULANACAK / UYGULANACAK**. Mevcut product render yolunun procedural premium-art kısmı henüz kaldırılmış sayılmaz.
- Güncel exact HEAD için focused test/CI sonucu bu asset ekleme adımı sonrasında henüz yok; **DOĞRULANACAK**.

## 3. Kelime Avı bağlayıcı görsel üretim standardı

**Ana kural:**

`REFERENCE → PRODUCTION-READY LAYERED ASSETS → THIN INTERACTION CODE`

- Onaylı referans görsel MASTER ART / bağlayıcı kalite hedefidir.
- Referans `CustomPainter`, Dart Canvas veya benzeri procedural çizimlerle yaklaşık olarak yeniden üretilmez.
- Motor resmi yapmayacak; resmi oynatacak.
- Premium final-art öğeleri gerçek PNG/WebP transparan production asset olarak hazırlanır.
- Kod yalnız doğru asset'i doğru canonical koordinata yerleştirir, state varyantını seçer, progression/gesture/animasyon/ölçekleme işini yürütür.
- Placeholder veya düşük kaliteli geçici çizimler final kabul edilmez.

### Başlangıç Limanı production asset listesi

Hedef klasör: `assets/word_hunt/baslangic_limani/`

- `scene.webp` veya mevcut onaylı temiz scene/background asset'i
- `node_normal.webp` — **REPOYA EKLENDİ**
- `node_locked.webp` — **REPOYA EKLENDİ**
- `node_challenge.webp` — **REPOYA EKLENDİ**
- `node_bonus.webp`
- `node_final.webp`
- `challenge_plaque.webp`
- `bonus_plaque.webp`
- `final_plaque.webp`
- `final_crown.webp`
- `compass_button.webp`
- `book_button.webp`
- gerekirse route / route-glow state overlay asset'leri

## 4. PR #110'dan korunacak ve değiştirilecek alanlar

### Korunacak

- `WordHuntProgressSnapshot`
- `WordHuntRouteProgressEngine`
- `WordHuntProgressCodec`
- `WordHuntStarterContent.baslangicLimani`
- canonical 1080×1920 koordinat sözleşmesi
- `WordHuntCanonicalSceneTransform`
- 1–10 merkez koordinatları
- route cubic Bézier kontrol noktaları
- gerçek progression değerinin UI'ya yansıması
- kilitli node callback üretmemesi
- davranışsal ve regresyon testleri

### Final çözüm olmaktan çıkarılacak procedural premium-art

- `_FinalCrownPainter`
- `_TreasureChestPainter`
- `_FantasyPlaquePainter`
- premium medalyon / özel ikon / dekor niteliğindeki diğer procedural çizimler

Final Başlangıç Limanı render yolu production asset kullanacaktır.

## 5. Başlangıç Limanı ürün sözleşmesi

- İlk rota: **Başlangıç Limanı**.
- 10 bölüm, 30 yıldız, 6 Bilgi Kartı.
- 1–4 üst bölgede ferah rota.
- 5 `MEYDAN OKUMA`: merkez-sol, plaque sağında.
- 6 sol geçiş.
- 7 merkez/merkez-sağ.
- 8 `BONUS DURAK`: sağ bölge, plaque sağında.
- 9 kilitli durak solda.
- 10 `ROTA FİNALİ`: alt-orta, plaque sağında.
- Pusula sol altta, kitap sağ altta.
- Arka plan: premium gece limanı, ay ışığı, deniz, sıcak köy ışıkları, gemiler/iskeleler ve sağda deniz feneri.
- Görsel state gerçek progression gerçeğini bozmaz.
- Production `lib/main.dart` entegrasyonu ayrı açık onay gerektirir.

## 6. Görsel kabul kapısı

Bir ekran ancak aşağıdaki koşullarla görsel olarak tamamlanmış sayılır:

1. Referansla ilk bakışta aynı görsel aile ve kalite düzeyi.
2. Premium öğeler procedural taklit değil gerçek production asset.
3. Android gerçek cihaz / gerçek Android screenshot referansla yan yana incelenmiş.
4. Gameplay/progression bozulmamış.
5. Teknik testler ve CI PASS.
6. **Levent açık görsel kabul vermiş.**

Teknik PASS tek başına görsel PASS değildir.

## 7. Korunan alanlar

Kelime Avı asset-first pilotunda açık onay olmadan dokunulmaz:

- `assets/questions.json`
- production `lib/main.dart`
- mevcut progression / oyun mantığı
- BoardMap / 67 node / 3B tahta
- Android / AdMob / Firebase / release config
- release / Play yayın hattı

## 8. Tarihsel notlar

- PR #96 Kelime Avı foundation hattıdır; açık/Draft kalmıştır.
- PR #98 teknik olarak PASS olsa da son Android görüntüsü resmi referansa uymadığı için kullanıcı tarafından görsel olarak reddedilmiştir.
- Teknik başarı görsel kabul sayılmaz.
- PR #110 canonical transform ve test kazanımlarıyla ileri teknik temel oluşturdu; procedural premium-art final çözüm olarak yeni standart tarafından geçersiz kılındı.

## 9. Sıradaki aktif iş

1. Kalan MASTER ART production asset'lerini hazırla: bonus/final node, 3 plaque, crown, compass, book.
2. Asset-backed widget entegrasyonunu testli bir commit ile yap; connector kaynaklı push-workflow tetiklenmemesini test kapısını atlamak için kullanma.
3. Procedural premium-art final render yolunu kaldır.
4. Canonical transform, progression, koordinatlar ve interaction testlerini koru.
5. Exact HEAD focused test + tam regresyon + analyze çalıştır.
6. Android 16 / gerçek cihaz screenshot üret ve referansla yan yana incele.
7. Levent görsel kabul vermeden Ready/merge yapma.
8. Başlangıç Limanı onaylanmadan diğer tema/paketlere yayılma.