# Kelime Avı V9 — 6 Eylül 2026 Devir Özeti

Bu belge Kelime Avı / Gökyüzü Adaları üretim hattının 6 Eylül 2026 son durumunu kaydeder. Canlı teknik doğrulukta esas kaynak yine `ZMilaStudio/BilgiRotasi` deposu ve güncel release branch durumudur.

## Canonical release

- Repo: `ZMilaStudio/BilgiRotasi`
- Canonical branch: `release/final-closed-test-aab-1.68.8`
- Canonical HEAD: `4719aa36da31938d492370f12c7ab6a254c767cd`
- Sürüm: `1.68.19+109`
- Paket: `com.leventua.bilgirotasi`
- Play yükleme/yayınlama yapılmadı.

## Başlangıç Limanı

- İlk rota/paket olarak production'da korunur.
- 10 bölüm / 30 yıldız canonical yapı korunur.
- MASTER ART + şeffaf hitbox + minimum runtime state yaklaşımı kabul edilmiştir.
- Canonical 8×8 gameplay, progression, swipe toleransı, found/error state ve B5/B10 denge kabul zinciri bozulmaz.

## Gökyüzü Adaları — tamamlanan ürün zinciri

### Rota / görsel / gameplay

- Gökyüzü Adaları ikinci rota/pakettir.
- Görsel yön: neşeli/parlak gökyüzü teması; rota MASTER ART tabanı kullanır.
- Gameplay'de mevcut gerçek 8×8 UI ölçüleri korunur; yalnız scenic background kullanılır.
- Production scenic set:
  - `gameplay_bg_bright.webp`
  - `gameplay_bg_storm.webp`
  - `gameplay_bg_airship.webp`
  - `gameplay_bg_moon.webp`
- Mapping: 1–4 bright, 5 storm, 6 airship, 7 moon, 8 storm, 9 moon, 10 bright.
- R8 eski `scene_level_*` / island-derived yaklaşımı fiziksel cihazda görsel FAIL aldığı için superseded edilmiştir.
- R9 Android16 teknik kabulü PASS; fiziksel cihaz insan görsel/gameplay kabulü PASS.

### İçerik

- 10 canonical bölüm.
- 30 yıldızlık rota.
- 8×8 grid.
- Toplam 80 target+bonus sözleşmesi.
- Exactly-one fiziksel occurrence ve mevcut engine/progression kuralları korunur.
- İçerik PR #176 kullanıcı onayı sonrası merge edilmiştir.
- PR #176 merge sonrası canonical HEAD: `a2278f59b4c51012a7f79e0ed89d153675f4d78e`.

### Production erişim

- PR #177 normal production Kelime Avı girişine rota seçici ekledi.
- Başlangıç Limanı her zaman açıktır.
- Gökyüzü Adaları, Başlangıç Limanı'nda 18 yıldız toplandığında açılır.
- Her rota kendi 30 yıldız ilerlemesini gösterir.
- Ortak mevcut `WordHuntProgressSnapshot` / persistence şeması korunur; yeni kayıt şeması eklenmedi.
- Bir rotadan geri dönülünce selector'a dönülür.
- QA/test belirli rotayı `routeSelectionEnabled: false` ile doğrudan açabilir.

## PR #177 doğrulaması

Exact ürün HEAD: `1e95bad7648e6e466fbd017183d6197e310c0879`.

İki ana workflow tamamen SUCCESS:

- `AdMob PR doğrulaması` run `34036946323`
  - analyze + tüm testler PASS
  - signing hazırlığı PASS
  - test reklam kimlikli release APK PASS
  - package / merged manifest PASS
  - Android16 cold-start PASS
  - AdMob Android16 gate PASS
  - artifact upload PASS

- `Kelime Avı Android 16 görsel kanıtı` run `34036946364`
  - exact feature HEAD checkout PASS
  - focused Kelime Avı suite PASS
  - izole görsel kanıt APK + asset doğrulama PASS
  - Android16 gerçek Flutter ekranı PASS
  - MASTER ART karşılaştırma kanıtı PASS
  - artifact upload PASS

PR #177 kullanıcı açık onayıyla Ready yapılıp merge edilmiştir.

Merge commit / güncel canonical HEAD:
`4719aa36da31938d492370f12c7ab6a254c767cd`

## Merge zinciri

Gökyüzü Adaları güncel kabul zinciri:

- PR #175 — Gökyüzü rota + onaylı scenic gameplay ürün entegrasyonu — MERGED.
- PR #176 — canonical 10 bölüm / 8×8 içerik entegrasyonu — MERGED.
- PR #177 — production rota selector / 18 yıldız kapısı — MERGED.

Eski/superseded hatlar production'a merge edilmemelidir:

- PR #173 sentetik/modüler eski renderer yaklaşımı — superseded.
- PR #174 eski MASTER ART V2 ara hattı — superseded by #175.
- PR #171 eski içerik hattı — #176 ile replaced/closed.
- PR #172 eski island-derived asset hattı — R8 görsel FAIL sonrası replaced/closed.

## Bağlayıcı progression

Gökyüzü rota içi progression:

- 7 tamamlanınca 8 ve 9 birlikte açılır.
- 8 bonus node'dur; 9 için gate değildir.
- 10 yalnız 9 tamamlanınca açılır.

Rotalar arası progression:

- Başlangıç Limanı açık.
- Gökyüzü Adaları kapısı: 18 Başlangıç Limanı yıldızı.

## Korunan kapsam

Aşağıdaki alanlar bu Gökyüzü zincirinde kontrolsüz değiştirilmedi:

- `assets/questions.json`
- BoardMap / 67 node sözleşmesi
- Firebase
- AdMob production config
- signing
- package id
- sürüm numarası
- Play release/yayın işlemleri

## Görsel üretim süreci — bağlayıcı karar

Yeni theme/gameplay background değişikliklerinde:

1. Önce statik görsel yön/adayı Levent onaylar.
2. Görsel yön PASS olmadan yeni APK/CI görsel turu hazırlanmaz.
3. Teknik PASS ile görsel/human PASS ayrı tutulur.
4. Statik mockup runtime kanıtı sayılmaz.
5. Kullanıcı açıkça istemedikçe onay sonrası tekrar tekrar görsel gönderilmez.

## WORK V2

- Mikro adım + rapor + bekleme döngüsü kullanılmaz.
- Mümkün olan en büyük mantıklı üretim bloğu tek döngüde tamamlanır.
- Kullanıcı yalnız ürün kararı, gerçek görsel tercih, nihai fiziksel kabul, Ready/merge/release gibi kritik kapılarda devreye girer.
- Codex yalnız mevcut araçlarla yapılamayan zorunlu durumda kullanılmalıdır.

## Güncel kapı

Gökyüzü Adaları rota + gameplay + içerik + production erişim entegrasyonu tamamlanmış ve canonical release branch'e merge edilmiştir.

Şu anda sonraki ayrı ürün kapısı release/AAB/Play hazırlığıdır. Play'e yükleme veya yayınlama için ayrıca açık Levent onayı zorunludur.
