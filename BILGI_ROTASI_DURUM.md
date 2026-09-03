# Bilgi Rotası – Proje Durumu

**Son güncelleme:** 3 Eylül 2026 — Gökyüzü Adaları için Sheet A–E konsept üretimleri tamamlandı ve modüler asset yaklaşımını birleştiren **1080×1920 statik rota mock V1** üretildi. Bu görseller üretim/görsel yön kanıtıdır; henüz atomik production asset paketi veya raw Android kabulü değildir. Flutter/APK entegrasyonuna geçilmedi; sıradaki gerçek kapı Levent’in rota mock görsel kabulüdür. Canonical release HEAD `3557a7e4f2f2917d61ba61866c6d4c8561994667`; Play yükleme/yayınlama yapılmadı.

## Canlı Sürüm / Release Hattı

- Repo: `ZMilaStudio/BilgiRotasi`.
- Repo içi aktif ürün sürümü: **1.68.19+109**.
- Paket: `com.leventua.bilgirotasi`.
- Canonical release branch: `release/final-closed-test-aab-1.68.8`.
- Canonical release HEAD: **`3557a7e4f2f2917d61ba61866c6d4c8561994667`**.
- PR #169: **CLOSED / MERGED**; merge commit `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
- PR #168: **CLOSED / MERGED**; docs-only merge commit `3557a7e4f2f2917d61ba61866c6d4c8561994667`.
- `main` güncel/yayın kaynağı olarak varsayılmaz.
- Play Console’a yükleme/yayınlama yapılmadı.

## Kelime Avı — Canonical Ürün Durumu

Canonical gameplay sözleşmesi **8×8 / 64 hücre — LOCKED**.

- İlk paket: **Başlangıç Limanı**.
- 10 bölüm / 30 yıldız.
- Target+bonus eğrisi: B1 5+1, B2 5+1, B3 6+1, B4 6+1, B5 7+1, B6 7+1, B7 8+1, B8 7+2, B9 9+1, B10 9+1; toplam **80**.
- Her target/bonus 8 düz yönde exactly-one fiziksel occurrence taşır; ters gesture aynı canonical kelimeye çözülür.
- B8 bonusları `HIZ` + `SKOR`; B9 bonus `ROKET`; B10 hedef `YOL`, bonus `HAZİNE`.
- B5 60 sn, B10 120 sn soft challenge; hard-fail değildir.
- Nearest-word/autocomplete yoktur.

## Gökyüzü Adaları — Paket 2 LOCKED Ürün Yönü

- Paket adı: **Gökyüzü Adaları — LOCKED**.
- Görsel yön: **C — Neşeli & Parlak — LOCKED**.
- Teknik görsel mimari: **modüler asset yaklaşımı — LOCKED**.
- Atmosfer: neşeli, renkli, pozitif, çocuk dostu, hafif ve canlı.
- Palet: açık gök mavisi/camgöbeği/turkuaz + yeşil yüzen adalar + sarı/turuncu sıcak vurgu + destekleyici pembe/mercan + parlak beyaz bulutlar.

### Kilitli 10 bölüm rotası

1. Rüzgâr Kapısı
2. Bulut Bahçesi
3. Kuş Geçidi
4. Gökkuşağı Köprüsü
5. Fırtına Kulesi
6. Hava Gemisi Limanı
7. Ay İskelesi
8. Gizli Ada — bonus
9. Yıldız Gözlemevi
10. Güneş Sarayı

- Node 8 bonus node'dur.
- Node 7 sonrası bonus 8 ve normal 9 birlikte açılır; 8, 9 için gate değildir.
- Node 10, node 9 tamamlanmadan locked kalır.

### Modüler asset üretim sözleşmesi

- Başlangıç Limanı'nın flatten edilmiş MASTER ART rota yaklaşımı bu pakete kopyalanmaz.
- Büyük renk/gradient alanları Flutter ile üretilebilir; illüstratif dünya parçaları bağımsız modüler raster asset olur.
- Dinamik bölüm numarası, yıldız, kilit/progression state'i ve değişken metin asset içine bake edilmez.
- Referans tasarım tuvali: **1080×1920 dikey**.
- V1 zorunlu set: **48 atomik asset**:
  - 8 atmosfer,
  - 7 yüzen ada,
  - 6 rota bağlantısı,
  - 10 bölüm landmarkı,
  - 9 node/progression UI,
  - 8 dekor.
- WORK V2 üretim birimi: **5 sprite sheet**; 48 ayrı görsel çağrısı yapılmaz.
- Ayrıntılı plan: `docs/project-memory/GOKYUZU_ADALARI_ASSET_PLANI.md`.
- Flutter/production entegrasyonundan önce 48 asset ile 1080×1920 statik rota mock'ı hazırlanır ve Levent görsel kabulü verir.

### Görsel üretim checkpointi — V1

- Sheet A–E konsept üretimleri current çalışma oturumunda tamamlandı.
- Sheet seti atmosfer/yollar, yüzen adalar, landmark 1–5, landmark 6–10 ve node UI/dekor yönlerini aynı görsel dil altında toplar.
- Bu sheet görselleri **atomik production asset değildir**; ayrıştırma/şeffaf kenar QA/ölçek standardizasyonu henüz yapılmadı.
- Sheet setinden türetilen **1080×1920 statik rota mock V1** üretildi.
- Mock, 10 bölüm rotasını, bonus 8 ayrımını, final 10 odağını ve modüler node/progression yönünü birlikte gösterir.
- Mock **ImageGen/görsel tasarım kanıtıdır; raw Android acceptance değildir**.
- Flutter/production entegrasyonuna geçmeden önce Levent’in bu rota mock’ını görsel olarak kabul etmesi zorunludur.

## V5 / V6 Kabul ve Teknik Kanıtları

### V5 reference asset — PASS
- Onaylı raster reference asset paketi production’da kullanılır.
- Integration run `33379341765`: **SUCCESS**.

### Found-state — PASS
- Raw Android kullanıcı kabulü: **PASS**.
- Exact tested commit `4dddf00178ef9f14b8edb3fc706114be72f477a4`.
- Android16 run `33486609120`: **SUCCESS**.

### Error-state — PASS
- Raw Android kullanıcı kabulü: **PASS**.
- Fill `0xB35A1F2B`, border `0xFFFF6B57`, transient `280 ms`.
- Android16 run `33524578623`: **SUCCESS**.

### Compact completion/result — PASS
- Targetlar tamam, bonus eksik → otomatik popup yok; bonus aranabilir.
- Tüm target+bonus tamam → popup otomatik; fresh/replay’de tekrar açılabilir.
- Static/productize `33629855060`: SUCCESS; Word Hunt **139/139 PASS**.
- Android16 `33655562508`: SUCCESS; raw Android B5/B10 kullanıcı PASS.

### B5 denge — PASS
- İlk insan ölçümü: 115 sn / 2 hata → 60 sn hedef karşılanmadı.
- Tuning sonrası insan ölçümü: **32 sn**; süre PASS.
- Android16 tuning run `33670657723`: SUCCESS.

### Swipe false-positive — PASS
- Kelime olamayacak kadar kısa gesture cezasız iptal edilir.
- Yalnız exact target/bonus/already-found oluşturan tek trailing hücre kırpılır.
- İlk aktif pointer gesture boyunca kilitlenir.
- İki hücre taşma ve anlamlı gerçek yanlış seçim hata kalır; autocomplete yoktur.
- Ürün commit `749c678b885d6cefec428c603c55a83a4190152c`.
- Fast `33724552713`: SUCCESS.
- Android16 `33724549202`: SUCCESS; gerçek `ANKARA + 1 trailing hücre` → `0/7 → 1/7`, hata `0 → 0`.

## Canonical Release-context Kanıtı — PASS

- Exact test edilmiş ürün HEAD: `2ae95df70b452f735a8db9c5bd0d88827a2ec40a`.
- Kelime Avı Android16 visual proof run `33745646184`: **SUCCESS**; artifact `9887953917`.
- Release APK / AdMob run `33745646210`: **SUCCESS**; artifact `9889920696`.
- PR #158 merge commitinde otomatik workflow tetiklenmedi (`0` run); merge öncesi exact release-context kanıtları final teknik kanıttır.

## Merge Zinciri — TAMAMLANDI

- PR #167 — MERGED → `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.
- PR #163 — MERGED → `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`.
- PR #162 — MERGED → `929bb13177e03a0962464e21f6c174d4b3439349`.
- PR #161 — MERGED → `4aa490e7c2d5e7547dc95f9463dbbb9adeb85e5a`.
- PR #158 — MERGED → `189864c92a605e7bb960460300714049c730ea39`.
- PR #169 — MERGED → `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
- PR #168 — DOCS-ONLY MERGED → `3557a7e4f2f2917d61ba61866c6d4c8561994667`.
- PR #166 tarihsel geliştirme/QA hattıdır; merge edilmeyecek.

## Production Ana Navigasyon Entegrasyonu — PR #169 MERGED

- Exact merged HEAD: `ffa1454ba8fb47da21ca6caa50b0a5495e0149c1`.
- Merge commit: `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
- Final ürün farkı 4 dosya / 259 ekleme / 0 silme.
- `assets/questions.json`, BoardMap/67 node, canonical 8×8 içerik, Firebase rules/model, AdMob/signing/Android config ve package/version değişmedi.
- Oyna menüsü → `WordHuntProductionEntryScreen` → Başlangıç Limanı production rota → canonical gameplay akışı release içindedir.
- Full-suite/release APK/Android16 run `33754851284`: **SUCCESS**.
- Kelime Avı Android16 visual/MASTER ART run `33754851205`: **SUCCESS**; 126/126 PASS; artifact `9893332600`.

## Korunan Alanlar

- `assets/questions.json` kontrolsüz değiştirilmez.
- Canonical 8×8 / 64 hücre sözleşmesi değiştirilmez.
- BoardMap / 67 node değiştirilmez.
- Firebase / AdMob / release signing kapsam dışıdır.
- package name / version değişmedi.

## Kalan Gerçek Kapılar

1. Gökyüzü Adaları **rota mock V1 Levent görsel kabulü** — **AÇIK / SIRADAKİ GERÇEK KAPI**.
2. Sheet'leri gerçek 48 atomik production asset'e ayırma + şeffaf kenar/ölçek/toplu QA — **BEKLİYOR / mock kabulü sonrası**.
3. Flutter rota entegrasyonu — **BEKLİYOR / kullanıcı görsel kabulü olmadan başlanmaz**.
4. Gökyüzü Adaları 80 target+bonus ve 8×8 grid paketi — **BEKLİYOR**.
5. `REFERENCE_FONT` exact kaynak — **DOĞRULANACAK / DEFERRED**.
6. Play yükleme/yayınlama — **AÇIK / ayrıca Levent’in açık onayı gerekli**.

**Durum:** 8×8 LOCKED / BAŞLANGIÇ LİMANI RELEASE PASS / GÖKYÜZÜ ADALARI TEMA+KONSEPT+ROTA+MODÜLER MİMARİ LOCKED / SHEET A–E KONSEPT SETİ ÜRETİLDİ / 1080×1920 ROTA MOCK V1 ÜRETİLDİ / KULLANICI GÖRSEL KABULÜ BEKLENİYOR / FLUTTER-APK ENTEGRASYONU YOK / CANONICAL RELEASE HEAD `3557a7e4...` / PLAY YAYINI YOK.
