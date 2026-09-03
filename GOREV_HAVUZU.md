# Bilgi Rotası — Görev Havuzu

**Son güncelleme:** 3 Eylül 2026 — Gökyüzü Adaları için 10 bölüm sırası ve **modüler asset yaklaşımı** Levent tarafından onaylandı. V1 görsel üretim sözleşmesi 48 atomik asset / 5 sprite sheet olarak tanımlandı. Henüz Flutter/APK üretimine geçilmedi; sıradaki iş sprite sheet üretimi ve statik rota mock görsel kabulüdür.

> Root dosya güncel Kelime Avı çalışma checkpointini taşır. Eski ayrıntılı görev geçmişi `docs/project-memory/GOREV_HAVUZU.md` ve Git geçmişinde korunur.

## Aktif görev — Gökyüzü Adaları modüler görsel üretimi

**Durum:** 8×8 LOCKED / BAŞLANGIÇ LİMANI RELEASE PASS / GÖKYÜZÜ ADALARI TEMA+KONSEPT+ROTA+MODÜLER MİMARİ LOCKED / 48 ASSET-5 SHEET PLANI HAZIR / FLUTTER-APK ÜRETİMİ BAŞLAMADI / CANONICAL RELEASE HEAD `3557a7e4...` / PLAY YAYINI YOK

**Canonical release:** `release/final-closed-test-aab-1.68.8` @ `3557a7e4f2f2917d61ba61866c6d4c8561994667`

**Sürüm:** `1.68.19+109`

### Tamamlanan kapılar

1. Canonical 8×8 / 64 hücre — **PASS**.
2. 10 bölüm / 30 yıldız / 80 target+bonus contract — **PASS**.
3. V5 approved reference asset integration — **PASS**; run `33379341765`.
4. Found-state raw Android kullanıcı kabulü — **PASS**; run `33486609120`.
5. Error-state raw Android kullanıcı kabulü — **PASS**; run `33524578623`.
6. Compact completion popup — **PASS**; run `33655562508`.
7. B5 60 sn tuning — **PASS**; insan sonucu **32 sn**; Android16 `33670657723`.
8. Swipe false-positive dar tolerans — **PASS**; fast `33724552713`, Android16 `33724549202`.
9. PR #167 Ready + merge — **PASS**; `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.
10. PR #163 final review + Ready + merge — **PASS**; `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`.
11. PR #162 final review + Ready + merge — **PASS**; `929bb13177e03a0962464e21f6c174d4b3439349`.
12. PR #161 final review + Ready + merge — **PASS**; `4aa490e7c2d5e7547dc95f9463dbbb9adeb85e5a`.
13. PR #158 cleanup/final review/exact release-context — **PASS**.
14. PR #158 → canonical release merge — **PASS**; merge commit `189864c92a605e7bb960460300714049c730ea39`.
15. Production ana navigasyon branch’i — **PASS**; `feat/kelime-avi-production-navigation-20260903`.
16. PR #169 final minimum ürün diff’i — **PASS**; yalnız 4 dosya, 259 ekleme / 0 silme; protected scope temiz.
17. PR #169 focused production validation — **PASS**; run `33754274810`, 62 test.
18. PR #169 minimum-diff yeniden doğrulaması — **PASS**; run `33754621892`.
19. PR #169 full-suite + release APK + Android16 cold-start/AdMob — **PASS**; run `33754851284`, job `100646698982`.
20. PR #169 Kelime Avı Android16 görsel/MASTER ART — **PASS**; run `33754851205`, job `100646698474`; 126 test; artifact `9893332600`.
21. PR #169 Ready for Review — **PASS**; exact Ready HEAD `ffa1454ba8fb47da21ca6caa50b0a5495e0149c1`.
22. PR #169 → canonical release merge — **PASS**; merge commit `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
23. PR #169 merge sonrası canonical release HEAD doğrulaması — **PASS**; `0c84aefd...`.
24. PR #168 docs-only final diff — **PASS**; yalnız dört checkpoint belgesi.
25. PR #168 review/comment kontrolü — **PASS**; blocker yok.
26. PR #168 → canonical release merge — **PASS**; Levent’in `Devam et` onayıyla; merge commit `3557a7e4f2f2917d61ba61866c6d4c8561994667`.
27. PR #168 merge sonrası canonical release HEAD doğrulaması — **PASS**; `3557a7e4...`.
28. PR #168 merge commitinde otomatik PR workflow’u — **0 run / DOĞRULANDI**.
29. Paket 2 tema adı — **PASS / LOCKED**: `Gökyüzü Adaları`.
30. Paket 2 görsel yön — **PASS / LOCKED**: `C — Neşeli & Parlak`.
31. Gökyüzü Adaları 10 bölüm adı + rota sırası — **PASS / LOCKED**.
32. Gökyüzü Adaları görsel teknik mimarisi — **PASS / LOCKED**: modüler asset yaklaşımı.
33. V1 asset üretim sözleşmesi — **PASS / HAZIR**: 48 atomik asset / 5 sprite sheet; ayrıntı `docs/project-memory/GOKYUZU_ADALARI_ASSET_PLANI.md`.

### Gökyüzü Adaları — kilitli rota

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

- 7 sonrası bonus 8 ve normal 9 birlikte erişilebilir; 8, 9 için gate değildir.
- 10, node 9 tamamlanmadan locked kalır.

### Gökyüzü Adaları — V1 asset üretimi

- Referans tuval: 1080×1920 dikey.
- 48 atomik asset: 8 atmosfer + 7 ada + 6 yol + 10 landmark + 9 node/progression UI + 8 dekor.
- Üretim 5 sprite sheet halinde yapılır; 48 ayrı görsel döngüsü yapılmaz.
- Dinamik numara, yıldız, lock/progression ve metin asset içine bake edilmez.
- Flutter/production entegrasyonundan önce statik rota mock'ı kullanıcı görsel kabulüne sunulur.

### Açık işler

1. **Sheet A–E görsel üretimi** — **AÇIK / SIRADAKİ ÜRETİM İŞİ**.
2. Üretilen sheet'lerin atomik asset'lere ayrılması + toplu görsel QA — **BEKLİYOR**.
3. 1080×1920 statik Gökyüzü Adaları rota mock'ı — **BEKLİYOR**.
4. Rota mock görsel kullanıcı kabulü — **BEKLİYOR / FLUTTER'DAN ÖNCE**.
5. Gökyüzü Adaları 80 target+bonus içerik iskeleti ve 8×8 grid üretimi — **BEKLİYOR / görsel rota sözleşmesiyle paralel veya sonrasında**.
6. `REFERENCE_FONT` exact kaynak — **DOĞRULANACAK / DEFERRED**.
7. PR #166 tarihsel geliştirme/QA hattıdır — **MERGE YOK**.
8. Play yükleme/yayınlama — **AÇIK / ayrıca Levent’in açık onayı gerekli**.

**Sıradaki çalışma: 5 sprite sheet'i üret, atomik asset'lere ayır, toplu QA yap ve Flutter'a geçmeden önce 1080×1920 rota mock'ını kullanıcı kabulüne getir.**
