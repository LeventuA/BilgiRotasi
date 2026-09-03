# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 3 Eylül 2026 — Kelime Avı V8 devir noktası. Başlangıç Limanı canonical 8×8 gameplay + production navigasyon release entegrasyonu tamamlandı. İkinci paket **Gökyüzü Adaları**, görsel yön **C — Neşeli & Parlak**, 10 bölüm rota sırası ve **modüler asset mimarisi** LOCKED. V1 planı **48 atomik asset / 5 sprite sheet**; Sheet A–E konsept seti ve **1080×1920 statik rota mock V1** üretildi. Bu görseller henüz atomik production asset veya raw Android acceptance değildir. Flutter/APK entegrasyonu başlamadı; sıradaki gerçek kapı Levent’in rota mock görsel kabulüdür. Canonical release HEAD `3557a7e4f2f2917d61ba61866c6d4c8561994667`; Play yükleme/yayınlama yapılmadı. WORK V2 aktif.

> Teknik doğrulukta tek kanonik kaynak canlı `ZMilaStudio/BilgiRotasi` deposu ve ilgili canlı servislerdir. Bu dosya canlı branch/PR/CI/pubspec doğrulamasının yerine geçmez. Ayrıntılı eski üretim günlükları Git geçmişinde ve `docs/project-memory/archive/` altında korunur.

## Kalıcı Çalışma Kuralı

- Her görev başında canlı hedef branch, `pubspec.yaml`, son commit, PR ve CI yeniden doğrulanır.
- `main` güncel/yayın kaynağı varsayılmaz.
- Sıra: branch → test → commit → push → PR → inceleme → merge.
- Kritik merge/release yalnız Levent’in açık onayıyla yapılır.
- Build PASS tek başına kanıt değildir; diff, test, workflow, log, Git geçmişi ve gerçek runtime kanıtı birlikte değerlendirilir.
- Görsel kabul yalnız gerçek/raw Android runtime üzerinden verilir; ImageGen/mockup/QA selector acceptance kanıtı değildir.
- `assets/questions.json` kontrolsüz değiştirilmez; ilgisiz değişiklikler silinmez.
- Codex yalnız mevcut araçlarla yapılamayan zorunlu yerel kod/test işi olduğunda kullanılır; gereksiz Codex kredisi harcanmaz.

## Canlı Release Hattı

- Repo: `ZMilaStudio/BilgiRotasi`.
- Canonical release branch: `release/final-closed-test-aab-1.68.8`.
- Canonical release HEAD: **`3557a7e4f2f2917d61ba61866c6d4c8561994667`**.
- Aktif ürün sürümü: **1.68.19+109**.
- Paket: `com.leventua.bilgirotasi`.
- PR #158 canonical gameplay paketini release’e taşıdı; merge commit `189864c92a605e7bb960460300714049c730ea39`.
- PR #169 production ana navigasyon entegrasyonunu release’e taşıdı; merge commit `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
- PR #168 canonical checkpoint belgelerini release’e taşıdı; docs-only merge commit `3557a7e4f2f2917d61ba61866c6d4c8561994667`.
- Play Console’a yükleme veya yayınlama yapılmadı.

## Başlangıç Limanı — Bağlayıcı Mimari

- İlk rota/paket: **Başlangıç Limanı**.
- Rota hedefi: 10 bölüm / 30 yıldız.
- Issue #109 `Photo 1.jpg` rota ekranı için bağlayıcı görsel kaynaktır.
- Production rota tabanı: MASTER ART raster + şeffaf hitbox + minimum lokal runtime-state override.
- Level 7 tamamlanınca bonus 8 ve normal 9 birlikte açılır; bonus 8, 9 için gate değildir; 10, node 9 tamamlanmadan locked/no-callback.
- BoardMap / 67 node sözleşmesi kontrolsüz değiştirilmez.
- Bu MASTER ART istisnası sonraki Kelime Avı rotalarına otomatik genellenmez.

## Gökyüzü Adaları — Paket 2 LOCKED Kararlar

- Paket adı: **Gökyüzü Adaları — LOCKED**.
- Görsel yön: **Konsept C — Neşeli & Parlak — LOCKED**.
- Teknik görsel mimari: **modüler asset yaklaşımı — LOCKED**.
- Atmosfer: neşeli, renkli, pozitif, eğlenceli, çocuk dostu, hafif ve canlı.
- Palet: açık gök mavisi/camgöbeği/turkuaz; yeşil yüzen adalar; sarı-turuncu sıcak vurgu; destekleyici pembe/mercan; parlak beyaz bulutlar.
- Konsept C yalnız sanat yönü referansıdır; final production veya raw Android acceptance kanıtı değildir.

### Kilitli rota

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

- 7 sonrası bonus 8 ve normal 9 birlikte açılır; bonus 8, 9 için gate değildir.
- 10, node 9 tamamlanmadan locked kalır.

### Modüler asset sözleşmesi

- Flatten edilmiş tam rota MASTER ART kullanılmaz.
- Büyük gradient/renk alanları Flutter tarafından çizilebilir; illüstratif dünya parçaları modüler raster asset olur.
- Dinamik numara/yıldız/lock/progression/metin asset içine bake edilmez.
- Referans tuval: **1080×1920 dikey**.
- V1 set: **48 atomik asset** = 8 atmosfer + 7 ada + 6 yol + 10 landmark + 9 node/progression UI + 8 dekor.
- Üretim birimi: **5 sprite sheet**; 48 ayrı görsel üretim döngüsü yapılmaz.
- Ayrıntılı sözleşme: `docs/project-memory/GOKYUZU_ADALARI_ASSET_PLANI.md`.
- Flutter/production entegrasyonundan önce 48 asset ile 1080×1920 statik rota mock'ı hazırlanır ve Levent görsel kabulü verir.

### Görsel üretim checkpointi — V1

- Sheet A–E konsept seti üretildi: atmosfer/yollar, yüzen adalar, landmark 1–5, landmark 6–10, node UI/dekor.
- Sheet seti tek görsel dil ve kompozisyon yönü için **üretim referansıdır**, final atomik production asset değildir.
- Atomik ayırma, gerçek şeffaf arka plan/kenar QA, exact export ölçüsü ve dosya bazlı optimizasyon henüz yapılmadı.
- Sheet setini bir araya getiren **1080×1920 statik Gökyüzü Adaları rota mock V1** üretildi.
- Mock 1–10 bölüm akışını, bonus 8 ayrımını, Güneş Sarayı final odağını ve node/progression görsel yönünü gösterir.
- Mock **ImageGen/statik görsel acceptance adayıdır; raw Android runtime PASS değildir**.
- Flutter/production rota entegrasyonuna geçmeden önce Levent’in bu mock için açık görsel kabulü gerekir.

## Canonical Gameplay Sözleşmesi

- Grid: **8×8 / 64 hücre — LOCKED**.
- Önceki 6×10 yalnız tarihsel checkpointtir; ürüne geri dönmez.
- Target+bonus eğrisi: B1 5+1, B2 5+1, B3 6+1, B4 6+1, B5 7+1, B6 7+1, B7 8+1, B8 7+2, B9 9+1, B10 9+1; toplam **80**.
- Her target/bonus 8 düz yönde exactly-one fiziksel occurrence taşır; ters gesture aynı canonical kelimeye çözülür.
- B8 bonusları `HIZ` + `SKOR`; B9 bonus `ROKET`; B10 hedef `YOL`, bonus `HAZİNE`.
- B5 60 sn ve B10 120 sn soft challenge; hard-fail değildir.
- Engine/path/scoring/timer/progression sözleşmesi görsel tema uğruna değiştirilmez.

## V5 / V6 Ürün Kabulü — PASS

### V5 reference asset
- Production mimarisi: approved raster reference assets + dinamik Flutter text/state + canonical 8×8 engine.
- V5 integration run `33379341765`: **SUCCESS**.

### Found-state
- Exact tested commit `4dddf00178ef9f14b8edb3fc706114be72f477a4`.
- Android16 run `33486609120`: **SUCCESS**; raw Android kullanıcı PASS.

### Error-state
- Fill `0xB35A1F2B`, border `0xFFFF6B57`, transient 280 ms.
- Android16 run `33524578623`: **SUCCESS**; raw Android kullanıcı PASS.

### Completion/result
- Targetlar tamam, bonus eksik → otomatik popup yok; bonus aranabilir.
- Tüm target+bonus tamam → popup otomatik açılır; fresh/replay’de tekrar açılabilir.
- Static/productize `33629855060`: SUCCESS, Word Hunt 139/139 PASS.
- Android16 `33655562508`: SUCCESS; raw Android B5/B10 kullanıcı PASS.

### B5 denge
- İlk insan testi: 115 sn / 2 hata → 60 sn hedef karşılanmadı.
- B10 insan testi: 109 sn / 4 hata → 120 sn hedef PASS.
- B5 tuning sonrası: **32 sn** → süre PASS.
- Android16 tuning run `33670657723`: SUCCESS.
- B5 targetları `ANKARA`, `ŞEHİR`, `TÜRKİYE`, `BAŞKENT`, `MECLİS`, `KULE`, `KALE`; bonus `ANIT`.

### Swipe false-positive toleransı
- Kelime olamayacak kadar kısa gesture cezasız iptal edilir.
- Yalnız son hücre çıkarıldığında exact target/bonus/already-found oluşuyorsa tek trailing hücre kırpılır.
- İlk aktif pointer gesture boyunca kilitlenir; ek temas seçime karışmaz.
- İki hücre taşma ve anlamlı gerçek yanlış seçim hata kalır; autocomplete yoktur.
- Ürün commit `749c678b885d6cefec428c603c55a83a4190152c`.
- Fast `33724552713`: SUCCESS.
- Android16 `33724549202`: SUCCESS; gerçek `ANKARA + 1 trailing hücre` → `1/7`, hata `0`.

## Release Merge Zinciri — TAMAMLANDI

- PR #167 — **MERGED** → `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.
- PR #163 — **MERGED** → `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`.
- PR #162 — **MERGED** → `929bb13177e03a0962464e21f6c174d4b3439349`.
- PR #161 — **MERGED** → `4aa490e7c2d5e7547dc95f9463dbbb9adeb85e5a`.
- PR #158 — **MERGED** → `189864c92a605e7bb960460300714049c730ea39`.
- PR #169 — **MERGED** → `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
- PR #168 — **DOCS-ONLY MERGED** → `3557a7e4f2f2917d61ba61866c6d4c8561994667`.
- PR #166 tarihsel geliştirme/QA hattıdır; merge edilmeyecektir.

## PR #158 Exact Release-context Kanıtı — PASS

- Exact test edilmiş ürün HEAD: `2ae95df70b452f735a8db9c5bd0d88827a2ec40a`.
- Kelime Avı Android16 visual proof run `33745646184`: **SUCCESS**, artifact `9887953917`.
- Release APK / AdMob run `33745646210`: **SUCCESS**, artifact `9889920696`.
- Merge commit `189864c9...` için otomatik workflow tetiklenmedi (`0` run); pre-merge exact release-context CI kanıtları final teknik kanıttır.

## Production Ana Navigasyon Entegrasyonu — PR #169 MERGED

- Bilgi Rotası production **Oyna** menüsüne `Kelime Avı` kartı eklendi.
- Exact merged HEAD: `ffa1454ba8fb47da21ca6caa50b0a5495e0149c1`.
- Merge commit: `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
- Final ürün farkı 4 dosya / +259 / -0.
- Full-suite/release APK/Android16 run `33754851284`: **SUCCESS**.
- Kelime Avı Android16 görsel run `33754851205`: **SUCCESS**; 126/126 PASS; artifact `9893332600`.
- `assets/questions.json`, BoardMap/67 node, Firebase/AdMob/signing/Android config ve package/version değişmedi.

## Docs-only Checkpoint PR #168 — MERGED

- PR #168: **CLOSED / MERGED**.
- Merge commit: `3557a7e4f2f2917d61ba61866c6d4c8561994667`.
- Kapsam yalnız canonical checkpoint belgeleriydi; ürün kodu değişmedi.

## Ölçeklenebilir Üretim/Test — KALICI KARAR

- Temel üretim birimi 10 bölümlük rota/pakettir.
- Bölüm başına ayrı branch/Android Action/APK/insan testi yapılmaz.
- Her bölüm otomatik 8×8, kelime sayısı, exactly-one occurrence, yön, reverse gesture, timer/yıldız ve render kapılarından geçer.
- İnsan denge örneklemesi varsayılan B1 + B5 + B10; otomatik outlier varsa yalnız ilgili ek bölüm oynanır.
- Android16 tam runtime paket tamamlanınca, engine/ortak UI değişiminde ve release entegrasyonu öncesinde çalışır.

## WORK V2 — AKTİF

- Mikro değişiklik → tam test → rapor → bekleme döngüsü kullanılmaz.
- İlişkili işler mümkün olan en büyük mantıklı üretim bloğunda tamamlanır.
- Çözülebilen hata/fixture/test sorunları kullanıcıyı test operatörü yapmadan giderilir ve yeniden doğrulanır.
- Kullanıcı ürün yönü, gerçek görsel/fiziksel kabul ve Ready/merge/release kararlarında devreye girer.

## Reference Font

- Runtime `fontFamily: 'serif'` kullanır.
- Repo içinde exact custom font kaynağı yoktur.
- `REFERENCE_FONT = DOĞRULANACAK / DEFERRED`; spekülatif font değişikliği yapılmaz.

## Korunan Alanlar

- `assets/questions.json` kontrolsüz değiştirilmez.
- BoardMap / 67 node değiştirilmez.
- Canonical 8×8 / 64 hücre sözleşmesi korunur.
- Firebase / AdMob / release signing değişiklikleri ayrı scope gerektirir.
- package name / version değişmedi.

## Kalan Aktif Sıra — V8 BURADAN DEVAM ETSİN

1. Her görev başında canonical release branch, `pubspec.yaml`, son commit ve ilgili açık PR/CI durumunu canlı doğrula.
2. Found/error/completion/B5/swipe kabul kapıları yeni belirti yoksa yeniden açılmaz.
3. PR #167/#163/#162/#161/#158/#169/#168 merge zinciri — **PASS / TAMAMLANDI**.
4. Canonical release HEAD — `3557a7e4f2f2917d61ba61866c6d4c8561994667`.
5. Gökyüzü Adaları tema + C görsel yön + 10 bölüm rota + modüler asset mimarisi — **LOCKED**.
6. V1 asset planı — **48 atomik asset / 5 sprite sheet / HAZIR**.
7. Sheet A–E konsept seti — **ÜRETİLDİ / production atomik export değil**.
8. 1080×1920 statik rota mock V1 — **ÜRETİLDİ / LEVENT GÖRSEL KABULÜ BEKLENİYOR**.
9. Görsel kabul sonrası gerçek 48 atomik asset export + şeffaflık/kenar/ölçek toplu QA yapılacak.
10. Sonra Flutter rota entegrasyon branch'i açılabilir; kullanıcı kabulünden önce Flutter'a geçilmez.
11. Gökyüzü Adaları 80 target+bonus içerik ve 8×8 grid paketi toplu üretilecek.
12. `REFERENCE_FONT` — **DOĞRULANACAK / DEFERRED**.
13. Play yükleme/yayınlama — **ayrı açık Levent onayı gerektirir**.

**SON DURUM: 8×8 LOCKED / BAŞLANGIÇ LİMANI RELEASE PASS / GÖKYÜZÜ ADALARI TEMA+KONSEPT+ROTA+MODÜLER MİMARİ LOCKED / SHEET A–E KONSEPT SETİ ÜRETİLDİ / ROTA MOCK V1 ÜRETİLDİ / KULLANICI GÖRSEL KABULÜ BEKLENİYOR / FLUTTER-APK ENTEGRASYONU YOK / CANONICAL RELEASE HEAD `3557a7e4...` / WORK V2 AKTİF / PLAY YAYINI YOK.**
