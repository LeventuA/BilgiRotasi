# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 5 Eylül 2026 — Kelime Avı V9: Gökyüzü Adaları için canonical 8×8 içerik PR #171, doğrulanmış 48 WebP asset PR #172 ve ayrı Flutter rota entegrasyon PR #173 DRAFT olarak hazır. Asset checks ve entegrasyon testleri PASS; exact `3abe69ac...` entegrasyonu + exact `4ec33de...` içerik kombinasyonu Android API 36 raw screenshot/log kanıtıyla teknik runtime PASS aldı ve bağımsız evidence validator run `33929151047` SUCCESS oldu. Raw ekran 1080×1920; uygulama resumed/focused; runtime marker, 10 rota node'u ve crash/ANR/render-failure yokluğu doğrulandı. Levent gerçek cihaz/nihai görsel kabulü açık; hiçbir PR Ready/merge edilmedi, Play işlemi yok. Canonical release `3557a7e4...`, sürüm `1.68.19+109`; WORK V2 aktif.

> Teknik doğrulukta tek kanonik kaynak canlı `ZMilaStudio/BilgiRotasi` deposu ve ilgili canlı servislerdir. Bu dosya canlı branch/PR/CI/pubspec doğrulamasının yerine geçmez. Ayrıntılı eski üretim günlükları Git geçmişinde ve `docs/project-memory/archive/` altında korunur.

## Kalıcı Çalışma Kuralı

- Her görev başında canlı hedef branch, `pubspec.yaml`, son commit, PR ve CI yeniden doğrulanır.
- `main` güncel/yayın kaynağı varsayılmaz.
- Sıra: branch → test → commit → push → PR → inceleme → merge.
- Kritik merge/release yalnız Levent’in açık onayıyla yapılır.
- Build PASS tek başına kanıt değildir; diff, test, workflow, log, Git geçmişi ve gerçek runtime kanıtı birlikte değerlendirilir.
- Görsel kabul yalnız gerçek/raw Android runtime üzerinden verilir; ImageGen/mockup/QA selector acceptance kanıtı değildir. Statik mock onayı yalnız tasarım yönü kabulüdür.
- `assets/questions.json` kontrolsüz değiştirilmez; ilgisiz değişiklikler silinmez.
- Codex yalnız mevcut araçlarla yapılamayan zorunlu yerel kod/test işi olduğunda kullanılır; gereksiz Codex kredisi harcanmaz.
- Kelime Avı için WORK V2 geçerlidir: mikro adım + rapor + bekleme döngüsü yerine mümkün olan en büyük mantıklı üretim bloğu tek çalışma döngüsünde tamamlanır.

## Canlı Release Hattı

- Repo: `ZMilaStudio/BilgiRotasi`.
- Canonical release branch: `release/final-closed-test-aab-1.68.8`.
- Canonical release HEAD: **`3557a7e4f2f2917d61ba61866c6d4c8561994667`**.
- Aktif ürün sürümü: **1.68.19+109**.
- Paket: `com.leventua.bilgirotasi`.
- PR #158 canonical gameplay paketini release’e taşıdı; merge commit `189864c92a605e7bb960460300714049c730ea39`.
- PR #169 production ana navigasyon entegrasyonunu release’e taşıdı; merge commit `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
- PR #168 canonical checkpoint belgelerini release’e taşıdı; docs-only merge commit `3557a7e4f2f2917d61ba61866c6d4c8561994667`.
- Play Console’a bu çalışma için yeni yükleme veya yayınlama yapılmadı.

## Başlangıç Limanı — RELEASE PASS / KORUNACAK

- İlk rota/paket: **Başlangıç Limanı**.
- Rota hedefi: 10 bölüm / 30 yıldız.
- Issue #109 `Photo 1.jpg` rota ekranı için bağlayıcı görsel kaynaktır.
- Production rota tabanı: MASTER ART raster + şeffaf hitbox + minimum lokal runtime-state override.
- Level 7 tamamlanınca bonus 8 ve normal 9 birlikte açılır; bonus 8, 9 için gate değildir; 10, node 9 tamamlanmadan locked/no-callback.
- BoardMap / 67 node sözleşmesi kontrolsüz değiştirilmez.
- Bu MASTER ART istisnası sonraki Kelime Avı rotalarına otomatik genellenmez.
- Production Oyna menüsüne `Kelime Avı` kartı release üzerinde entegredir.
- PR #169 full-suite/release APK/Android16 run `33754851284`: SUCCESS.
- Kelime Avı Android16 görsel run `33754851205`: SUCCESS; 126/126 PASS; artifact `9893332600`.

## Canonical Gameplay Sözleşmesi — LOCKED

- Grid: **8×8 / 64 hücre — LOCKED**.
- Önceki 6×10 yalnız tarihsel checkpointtir; ürüne geri dönmez.
- Target+bonus eğrisi: B1 5+1, B2 5+1, B3 6+1, B4 6+1, B5 7+1, B6 7+1, B7 8+1, B8 7+2, B9 9+1, B10 9+1; toplam **80**.
- Her target/bonus 8 düz yönde exactly-one fiziksel occurrence taşır; ters gesture aynı canonical kelimeye çözülür.
- B5 60 sn ve B10 120 sn soft challenge; hard-fail değildir.
- Engine/path/scoring/timer/progression sözleşmesi görsel tema uğruna değiştirilmez.
- Swipe false-positive toleransı: kelime olamayacak kısa gesture cezasız iptal; yalnız son hücre çıkarılınca exact çözüm oluşuyorsa tek trailing hücre kırpılır; ilk aktif pointer gesture boyunca kilitlenir; iki hücre taşma ve gerçek yanlış seçim hata kalır.

## V5 / V6 Ürün Kabulü — PASS / YENİDEN AÇILMAZ

- Found-state exact commit `4dddf00178ef9f14b8edb3fc706114be72f477a4`; Android16 run `33486609120`: SUCCESS; raw Android kullanıcı PASS.
- Error-state: fill `0xB35A1F2B`, border `0xFFFF6B57`, transient 280 ms; Android16 `33524578623`: SUCCESS; raw Android kullanıcı PASS.
- Completion/result: targetlar tamam bonus eksikse otomatik popup yok; tüm target+bonus tamamlanınca popup otomatik açılır.
- Static/productize `33629855060`: SUCCESS, Word Hunt 139/139 PASS.
- Android16 `33655562508`: SUCCESS; raw Android B5/B10 kullanıcı PASS.
- B5 tuning sonrası insan testi **32 sn** → süre PASS; Android16 tuning `33670657723`: SUCCESS.
- Swipe ürün commit `749c678b885d6cefec428c603c55a83a4190152c`; fast `33724552713`: SUCCESS; Android16 `33724549202`: SUCCESS.
- Yeni belirti yoksa bu kabul kapıları yeniden açılmaz.

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

### Rota mock V2 — STATİK GÖRSEL PASS

- İlk mock'taki `Mağaza / Başarılar / Oyna / Sıralama / Rozetler` genel alt menüsü rota ekranına ait olmadığı için **REJECTED / superseded**.
- V2 Başlangıç Limanı rota kabuğuyla hizalıdır: alt genel menü yok; sol üst geri, sağ üst bilgi, alt köşelerde yalnız rota içi kontroller.
- 10 bölüm ayrı UI kullanmaz. Ortak node/plaque/star/progression dili korunur; bölüm farkı landmark, ada ve lokal atmosferle verilir.
- Levent 3 Eylül 2026'da düzeltilmiş rota mock V2'yi **onayladı**.
- Bu kabul yalnız **statik tasarım yönü PASS**'idir; raw Android runtime acceptance değildir.

## Gökyüzü Adaları — Runtime Asset Checkpointi

### Production yönünün rafinesi

- İlk 48-asset taslağındaki ayrı `ada tabanı + landmark overlay` zorlaması, üretilen sanatın doğal kompozisyonunu bozduğu için runtime core sözleşmesinde rafine edildi.
- Kullanıcıya görünen V2 tasarım yönü değiştirilmedi.
- Runtime core: **41 asset** = 14 atmosfer/yol + 10 `scene_level_01..10` bölüm sahne composite + 17 node/progression UI/dekor.
- Opsiyonel kütüphane: **7 island variant**.
- Toplam logical runtime asset: **48 WebP**.
- Dinamik bölüm numarası, yıldız sayısı, kilit/progression metni core node assetlerine bake edilmez.
- Büyük gradient/renk alanları Flutter tarafından çizilebilir; illüstratif parçalar modüler raster asset olur.

### Production/Runtime QA

- 48 production candidate PNG'den runtime WebP seti hazırlandı.
- Runtime ZIP boyutu: **557.120 bayt**.
- ZIP SHA256: **`d219c6233fa27f5e3e04687ec5fd15dab1f24500584e78d6a7c80036ee68f5ca`**.
- ZIP integrity/test: PASS.
- İçerik: **48/48 WebP**.
- 48/48 dosyada alpha kanalı mevcut.
- 8 px dış kenarda `alpha >= 8` yok; maksimum yalnız düşük alpha fringe (`alpha 4`) görüldü. Doğru QA ifadesi: **8px border alpha<8 PASS**. `tamamen sıfır alpha border` iddiası kullanılmayacak.
- Bu QA dosya/format/alpha/crop güvenlik QA'sıdır; **raw Android runtime görsel PASS değildir**.
- Flutter rota entegrasyonu tamamlandıktan sonra Android16 raw screenshot + crash/ANR/log kanıtı ve Levent'in gerçek görsel kabulü ayrıca gerekir.

## Gökyüzü Adaları — Canonical 8×8 İçerik Paketi / PR #171

- PR #171: **OPEN / DRAFT / mergeable=true**.
- Başlık: `feat(kelime-avi): add Gokyuzu 8x8 content pack`.
- Base: `release/final-closed-test-aab-1.68.8` @ `3557a7e4f2f2917d61ba61866c6d4c8561994667`.
- Exact HEAD: `4ec33de7438fcbd15ed63b1ae2adda127da3be8c`.
- Değişiklik: yalnız 2 dosya; `lib/word_hunt/word_hunt_gokyuzu_content.dart` + `test/word_hunt_gokyuzu_content_test.dart`.
- 10 bölüm / 30 yıldız / toplam **80 target+bonus**.
- Eğri: `5+1, 5+1, 6+1, 6+1, 7+1, 7+1, 8+1, 7+2, 9+1, 9+1`.
- Her kelime exactly-one fiziksel occurrence taşır; forward/reverse gesture aynı canonical kelimeye çözülür.
- B1–B2 yatay/dikey başlangıç; B5 ve B10 yatay+dikey+çapraz yön ailelerini birlikte taşır.
- B5 60 sn; B10 120 sn.
- Gökyüzü içerik özel bonusları: B8 `SIRLAR` + `HAZİNE`, B9 `ROKET`, B10 `ZAFER`.
- `assets/questions.json`, Başlangıç Limanı, gameplay engine/path/scoring/timer/progression, BoardMap/67 node, Firebase/AdMob/signing/Android config ve package/version değişmedi.
- Exact HEAD üzerinde ilgili CI kanıtları SUCCESS olarak doğrulandı.
- Ready/merge yalnız Levent'in ayrı açık onayıyla yapılır.

## Firestorage Binary Transfer Checkpointi — 5 Eylül 2026

- Büyük binary dosyaları GitHub connector üzerinden base64/blob parçalarıyla taşımak uzun, kırılgan ve sohbeti kilitlemeye yatkın çıktı.
- Birden fazla 8k/12k/18k/20k/30k/50k parça denemesi yapıldı; bazı unreferenced bloblar erişilemez oldu veya payload kesilmesi nedeniyle beklenen Git SHA eşleşmedi.
- Bu eski chunk/blob aktarım yolu **ABANDONED / final ürün akışında kullanılmayacak**.
- Eski `.transfer`, `raw8`, `v5`, `tmp/gokyuzu-materialize-*` veya benzeri deneme branch/objeleri **canonical ürün asseti değildir**; final asset PR'a taşınmamalıdır.
- 5 Eylül 2026'da `firestorage.ai` bağlantısı başarıyla kuruldu.
- Google Drive'daki native `gokyuzu_transfer_chunks18_native` Sheet XLSX olarak dışa aktarıldı.
- Firestorage'a başarıyla yüklenen dosya: `gokyuzu_transfer_chunks18_native`.
- Firestorage file id: `01a06e6342ff774994dd33280571724e`.
- Firestorage public id: `G2aJFQx9RHUWoAue`.
- Share URL: `https://firestorage.ai/ja/f/hc_Qp-jw2yHk`.
- Boyut: **1.129.386 bayt**.
- Retention: **72 saat**; Firestorage kayıtlarında expiry `2026-09-07T21:46:34Z`.
- Share URL'yi bilen kişiler erişebilir; yalnız geçici teknik transfer için kullanılacaktır.
- Firestorage'ın bu projedeki yeni tercih edilen rolü: büyük ZIP/XLSX/görsel paketlerini kullanıcıyı manuel taşıma operatörü yapmadan geçici olarak GitHub materialization akışına ulaştırmak.
- Codex bu transfer işi için kullanılmadı ve gerekmiyor.

### Firestorage sonrası sıradaki exact teknik işlem

1. Firestorage'daki `gokyuzu_transfer_chunks18_native` XLSX'i GitHub tarafında tek-seferlik materialization akışına indir.
2. XLSX `chunks` tablosundaki base64 içeriklerini indeks sırasıyla birleştir.
3. Base64 decode ile runtime ZIP'i yeniden kur.
4. ZIP byte boyutu **557.120** ve SHA256 **`d219c6233fa27f5e3e04687ec5fd15dab1f24500584e78d6a7c80036ee68f5ca`** değilse işlem FAIL; asset commit oluşturma.
5. ZIP PASS ise tam **48 WebP** bulunduğunu doğrula ve `assets/word_hunt/gokyuzu_adalari/` altına çıkar.
6. Transfer XLSX/ZIP/workflow/chunk dosyalarını final ürün tree'sinde bırakma.
7. Canonical release `3557a7e4...` tabanından tek temiz ürün commit'i oluştur: **`feat(kelime-avi): add gokyuzu runtime assets`**.
8. Exact diff yalnız 48 runtime WebP + gerekli asset QA/manifest kayıtları olmalı; ürün kodu/pubspec/Flutter entegrasyonu bu committe olmamalı.
9. Asset PR **DRAFT** aç; Ready/merge yapma.
10. Asset PR QA PASS sonrası ayrı Flutter rota entegrasyon branch/PR'ına geç.

## PR / Branch Durumu — Devir Noktası

- PR #170: **OPEN / DRAFT / mergeable=true** — docs/checkpoint PR. Head: `docs/kelime-avi-v8-final-checkpoint-20260903`.
- PR #171: **OPEN / DRAFT / mergeable=true** — Gökyüzü 8×8 içerik PR'ı. Head: `feat/kelime-avi-gokyuzu-content-20260903` @ `4ec33de...`.
- Final temiz Gökyüzü asset PR **henüz oluşturulmadı**.
- `feat/kelime-avi-gokyuzu-assets-v2-20260903` ve `tmp/gokyuzu-materialize-20260905` üzerindeki transfer denemeleri final ürün geçmişi olarak kabul edilmez.
- Canonical release hiçbir transfer denemesiyle değiştirilmedi.
- Play yükleme/yayınlama yapılmadı.

## Release Merge Zinciri — TAMAMLANDI

- PR #167 — MERGED → `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.
- PR #163 — MERGED → `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`.
- PR #162 — MERGED → `929bb13177e03a0962464e21f6c174d4b3439349`.
- PR #161 — MERGED → `4aa490e7c2d5e7547dc95f9463dbbb9adeb85e5a`.
- PR #158 — MERGED → `189864c92a605e7bb960460300714049c730ea39`.
- PR #169 — MERGED → `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
- PR #168 — DOCS-ONLY MERGED → `3557a7e4f2f2917d61ba61866c6d4c8561994667`.
- PR #166 tarihsel geliştirme/QA hattıdır; merge edilmeyecektir.

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
- package name / version değiştirilmez.
- Gökyüzü statik mock onayı raw Android PASS sayılmaz.
- Asset transfer kolaylığı uğruna gameplay veya görsel sözleşme değiştirilmez.

## Kalan Aktif Sıra — YENİ SOHBET BURADAN DEVAM ETSİN

1. Her görev başında canonical release branch, `pubspec.yaml`, son commit ve açık PR/CI durumunu canlı doğrula.
2. Başlangıç Limanı release/görsel/gameplay kabul kapılarını yeni belirti yoksa yeniden açma.
3. Gökyüzü tema + C görsel yön + 10 bölüm rota + modüler mimari + rota mock V2 statik PASS kararlarını yeniden tartışma.
4. Firestorage paylaşımındaki `gokyuzu_transfer_chunks18_native` XLSX'i kullanarak runtime ZIP'i GitHub materialization akışında yeniden kur.
5. ZIP için zorunlu gate: **557.120 bayt + SHA256 `d219c6233fa27f5e3e04687ec5fd15dab1f24500584e78d6a7c80036ee68f5ca` + 48 WebP**.
6. PASS sonrası transfer kalıntısı olmadan canonical `3557a7e4...` tabanından tek temiz `feat(kelime-avi): add gokyuzu runtime assets` commit'i oluştur.
7. Exact asset diff/QA yap ve DRAFT asset PR aç. Ready/merge YAPMA.
8. Asset PR QA PASS sonrası ayrı Flutter rota entegrasyonu başlat; 41 core asset zorunlu, 7 island variant opsiyonel kütüphanedir.
9. PR #171 içerik paketi DRAFT kalır; Ready/merge ayrı Levent onayı gerektirir.
10. Flutter entegrasyonu sonrasında static/widget testleri + Android16 raw screenshot/crash/ANR/log kanıtı al.
11. Levent raw Android görsel kabulü olmadan Gökyüzü Adaları runtime görsel PASS verme.
12. `REFERENCE_FONT` — DOĞRULANACAK / DEFERRED.
13. Play yükleme/yayınlama — yalnız ayrı açık Levent onayıyla.

**SON DURUM: 8×8 LOCKED / BAŞLANGIÇ LİMANI RELEASE PASS / GÖKYÜZÜ ADALARI TEMA+KONSEPT+ROTA+MODÜLER MİMARİ LOCKED / ROTA MOCK V2 STATİK GÖRSEL PASS / GÖKYÜZÜ 10 BÖLÜM-80 KELİME İÇERİK PR #171 DRAFT / 48 RUNTIME WEBP QA HAZIR / FIRESTORAGE TRANSFER HATTI ÇALIŞIYOR / FİNAL TEMİZ ASSET COMMIT+PR HENÜZ YOK / FLUTTER-APK ENTEGRASYONU YOK / CANONICAL RELEASE `3557a7e4...` / WORK V2 AKTİF / PLAY YAYINI YOK.**

## Kelime Avı V9 — Gökyüzü Adaları Asset Intake Checkpoint — 5 Eylül 2026

- Canonical release: `release/final-closed-test-aab-1.68.8` @ `3557a7e4f2f2917d61ba61866c6d4c8561994667`; sürüm `1.68.19+109`.
- Başlangıç Limanı release/gameplay/görsel/navigasyon PASS; yeni belirti yok, yeniden açılmadı.
- İçerik PR #171: OPEN / DRAFT; exact HEAD `4ec33de7438fcbd15ed63b1ae2adda127da3be8c`; Ready/merge yapılmadı.
- Firestorage file id `01a06e6342ff774994dd33280571724e`: 42 chunk index `0..41`, 42/42 expected Git blob SHA ve strict base64 decode PASS.
- Rebuilt ZIP: 557120 bayt PASS; SHA256 `d219c6233fa27f5e3e04687ec5fd15dab1f24500584e78d6a7c80036ee68f5ca` PASS; ZIP integrity PASS.
- Runtime asset QA: 48/48 WebP PASS; 41 core + 7 optional island variant PASS; 48/48 decode/alpha PASS. Bu raw Android görsel PASS değildir.
- Materialization run `33923955868`, job `101188228034`: SUCCESS.
- Asset branch `feat/kelime-avi-gokyuzu-runtime-assets`; tek temiz commit `8508e6bfe03d0772cf2bd371d9d3ea4b4177b7fb` (`feat(kelime-avi): add gokyuzu runtime assets`); parent exact canonical `3557a7e4f2f2917d61ba61866c6d4c8561994667`.
- Exact compare: ahead_by=1, behind_by=0, total_commits=1; yalnız `assets/word_hunt/gokyuzu_adalari/*.webp`; 48 changed file. Final ürün tree'sinde transfer XLSX/ZIP/workflow/chunk kalıntısı yok.
- Asset PR #172: OPEN / DRAFT; base `3557a7e4...`, head `8508e6bf...`, 1 commit / 48 file; Ready/merge yapılmadı.
- Bu checkpoint sırasında #172 otomatik kontrolleri sürüyor; ASSET_PR_PASS henüz verilmedi.
- Flutter rota entegrasyonu #172 gerçek PASS sonrası ayrı branch/PR olarak BEKLİYOR.
- Android 16 raw screenshot + crash/ANR/log ve Levent gerçek cihaz görsel kabulü BEKLİYOR.
- `assets/questions.json`, BoardMap/67 node, Firebase, AdMob, signing, package/version ve Play release'e dokunulmadı. Play yalnız Levent'in ayrı açık onayıyla.

## Kelime Avı V9 — Gökyüzü Rota Entegrasyonu + Android16 Teknik Kanıtı — 5 Eylül 2026

- Canonical release değişmedi: `release/final-closed-test-aab-1.68.8` @ `3557a7e4f2f2917d61ba61866c6d4c8561994667`; sürüm `1.68.19+109`.
- Başlangıç Limanı release/gameplay/görsel/navigasyon PASS durumu korunuyor; yeniden açılmadı.
- İçerik PR #171: **OPEN / DRAFT / mergeable=true**; exact HEAD `4ec33de7438fcbd15ed63b1ae2adda127da3be8c`; Ready/merge yok.
- Asset PR #172: **OPEN / DRAFT / mergeable=true / ASSET_PR_PASS**; exact HEAD `8508e6bfe03d0772cf2bd371d9d3ea4b4177b7fb`; 48 WebP; otomatik kontroller SUCCESS; Ready/merge yok.
- Flutter rota entegrasyonu ayrı ürün branch'inde tamamlandı: `feat/kelime-avi-gokyuzu-route-integration-20260905`.
- Entegrasyon commit'i: `3abe69ac329fba76ecfeb780ecdf3bfc68da578e` — `feat(kelime-avi): integrate gokyuzu route`; parent exact asset HEAD `8508e6bf...`.
- Exact integration diff: ahead 1 / behind 0 / 1 commit; yalnız 6 dosya: Gökyüzü route screen, production entry dar route seçimi, progression bonus-bypass genellemesi, `pubspec.yaml` asset kaydı ve 2 focused test dosyası.
- Pre-commit integration gate run `33925674228`, job `101193533261`: SUCCESS; focused regresyon **39/39 PASS**; yeni analyzer error yok; `assets/questions.json`, `android/`, package/version korunuyor.
- DRAFT entegrasyon PR #173: **OPEN / DRAFT / mergeable=true**; base `feat/kelime-avi-gokyuzu-runtime-assets`, exact head `3abe69ac...`; Ready/merge yok.
- Gökyüzü progression LOCKED davranışı testle korunuyor: node 7 sonrası bonus 8 + normal 9 birlikte açılır; node 10, 9 tamamlanmadan locked kalır; Başlangıç Limanı regresyonu PASS.
- Android16 source capture run `33928436133`, job `101201894979`: exact integration HEAD `3abe69ac...` + exact runner-only content HEAD `4ec33de...`; analyzer **No issues found**; Gökyüzü focused **6/6 PASS**; isolated debug APK build PASS; APK SHA256 `cbcb0daa63a3b96727a9e4af827c2a03ded6242b27a0021b912dcbc166a8efbb`.
- Aynı run Android API 36 emulatoru boot etti, APK'yı kurup açtı ve raw screenshot aldı. Screenshot **1080×1920**; `[GOKYUZU_ANDROID16_RUNTIME_READY]` marker mevcut; `MainActivity` resumed/focused; UI dump başlık + 10 bölüm + Pusula + Bilgi Kitabı taşıyor.
- Source capture step sonucu, kanıt dosyaları üretildikten sonra `android-emulator-runner` çok satırlı `grep \\` ifadesini ayrı `/bin/sh` çağrılarına böldüğü için false-negative `failure` oldu. Bu uygulama/runtime hatası değildir. Source artifact: `9957851560`.
- Raw artifact bağımsız validator run `33929151047`, job `101204015094`: **SUCCESS**. Exact SHA'lar, 1080×1920 PNG, resumed/focused activity, runtime marker, 10 node semantics ve `FATAL EXCEPTION` / package ANR-crash-proc-died / `A RenderFlex overflowed` / `FlutterError` yokluğu tekrar doğrulandı. Validated artifact: `9957897368`.
- Sonuç: `GOKYUZU_ANDROID16_TECHNICAL_RUNTIME` — **PASS / KAPANDI**.
- `GOKYUZU_REAL_DEVICE_VISUAL_ACCEPTANCE` — **AÇIK / LEVENT GERÇEK CİHAZ-NİHAİ GÖRSEL KABULÜ GEREKLİ**. Emulator teknik PASS, insan/fiziksel cihaz kabulünün yerine geçmez.
- #171, #172, #173 DRAFT kalır. Ready/merge/Play işlemi yapılmadı; Play yalnız Levent'in ayrı açık onayıyla.
- `assets/questions.json`, BoardMap/67 node, Firebase, AdMob, signing, package/version ve Play release korunmuştur.
- Bu blokta yeni ürün kararı alınmadı; `KARARLAR.md` değişmedi.
