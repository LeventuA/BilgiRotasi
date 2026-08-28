# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 28 Ağustos 2026 — Kelime Avı Başlangıç Limanı 6×10 redesign onaylandı ve aktif üretime geçti.

> Teknik doğrulukta tek kanonik kaynak canlı `ZMilaStudio/BilgiRotasi` deposu ve ilgili canlı servislerdir. Bu dosya canlı branch/PR/CI/pubspec doğrulamasının yerine geçmez.

## Kalıcı çalışma kuralı

- Yeni sohbet başında önce bu dosya okunur.
- Ardından ilgili Kelime Avı checkpoint dosyaları ve gerekiyorsa `BILGI_ROTASI_DURUM.md`, `KARARLAR.md`, `GOREV_HAVUZU.md`, `ACIK_SORULAR_VE_DOGRULAMALAR.md` okunur.
- Her substantive sohbet mesajından sonra bu dosya güncellenir.
- Her görev öncesi canlı hedef branch, son commit, ilgili PR ve CI yeniden doğrulanır.
- Doğrudan `main` veya release dalına kod yazılmaz; branch/PR kullanılır.
- Kritik merge için Levent'in açık onayı gerekir.
- Build/CI PASS tek başına görsel veya ürün kabulü değildir.

## Canlı release hattı

- Repo: `ZMilaStudio/BilgiRotasi`
- Kanonik release: `release/final-closed-test-aab-1.68.8`
- Release HEAD: `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`
- Sürüm: `1.68.19+109`
- Paket: `com.leventua.bilgirotasi`
- `main` yayın kaynağı olarak varsayılmaz.
- PR #155 production Bölüm 1 gameplay merge edildi; merge commit `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`.

## Başlangıç Limanı bağlayıcı görsel/mimari

`MASTER ART RASTER → TRANSPARENT INTERACTION HITBOXES → MINIMUM LOCAL STATE OVERRIDES`

- Issue #109 `Photo 1.jpg` bağlayıcı görsel kaynak.
- Repo MASTER ART: `assets/word_hunt/baslangic_limani_master_art_visual_proof.jpg`.
- PR #146 / eski ChatGPT-generated hedef asset'ler görsel kaynak değildir.
- Route progression: 7 tamamlanınca 8+9 açılır; bonus 8 gate değildir; 10 node 9 tamamlanmadan locked/no-callback kalır.

## Bölüm 1 production gameplay — TAMAMLANDI

- Product branch eski final head: `4edd4090862bbbdcc8e7422b913fae7d7d758540`.
- Android 16 production QA accepted: run `33113510959`, 126/126 PASS.
- PR #155 merge edildi ve release'e girdi.
- Üretim ekranı gerçek gesture, result modal, exit confirmation, elapsed/mistake/star hesapları taşıyor.

## AKTİF ÜRÜN KARARI — Başlangıç Limanı 6×10 redesign

28 Ağustos 2026 kullanıcı onayıyla eski 6×6 / 3→6 kelimelik plan supersede edildi.

Canonical grid:
- **10 satır × 6 sütun** (`rowCount=10`, `columnCount=6`).

Canonical toplam kelime eğrisi target + bonus dahil:
- B1 = 6 (`5 target + 1 bonus`)
- B2 = 6 (`5 + 1`)
- B3 = 7 (`6 + 1`)
- B4 = 7 (`6 + 1`)
- B5 = 8 (`7 + 1`)
- B6 = 8 (`7 + 1`)
- B7 = 9 (`8 + 1`)
- B8 Bonus Durak = 9 (`7 target + 2 bonus`)
- B9 = 10 (`9 + 1`)
- B10 Final = 10 (`9 + 1`)

Toplam canonical target/bonus: **80 kelime**.

Content kuralları:
- Her target/bonus en az 3 harf.
- Her target/bonus 8 düz yönde **exactly 1 physical occurrence** taşımalı.
- Intended path ve opposite gesture gerçek `WordHuntPathEngine` üzerinden aynı canonical kelimeye dönmeli.
- Zorluk kelime sayısı, kesişim, diagonal/vertical/reverse yönler ve daha uzun kelimelerle artar.
- B9 `AY` geri dönmez; `ROKET` bonus korunur.
- B10 `ROTA` geri dönmez; `YOL` korunur.

## PR #156 — AKTİF / DRAFT / WIP

- URL: `https://github.com/ZMilaStudio/BilgiRotasi/pull/156`
- Base: `release/final-closed-test-aab-1.68.8`
- Base SHA: `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`
- Head branch: `feat/kelime-avi-content-pass-v1-20260828`
- Son 6×10 starter-content commit: `aee37c0b169b0acc72a9036e15d914412b826ae4`
- PR başlığı WIP 6×10 redesign olarak güncellendi.
- **Merge yok.** Eski 6×6 içerik merge edilmeyecek.
- 10 yeni 6×10 grid üretildi; 80 canonical target/bonus bağımsız occurrence taramasında exactly1 olarak doğrulandı.

## Onaylanan gameplay UX — sonraki stacked product dilimi

Ana targetların sonuncusu bulunduğunda:
- yıldız hesabı için elapsed + mistake snapshotı donar,
- grid bonus aramak için açık kalır,
- bonus completion için zorunlu değildir,
- bonus arama aşamasındaki yanlış seçim kazanılmış yıldızı düşürmez,
- sonuç yalnız `Bölümü Tamamla` ile açılır,
- `timeLimitSeconds` hard fail değil **soft challenge** olur.

Önceki ayrı branch `fix/kelime-avi-bonus-after-targets-soft-timer-20260828` denemesinde geçici workflow patch'leri başarısız oldu; ürün kodu doğrulanmadan merge edilmedi. Bu UX yeni 6×10 rectangular UI uyarlamasıyla temiz şekilde yeniden uygulanacak.

## Şu anki teknik engel / gerekli UI uyarlaması

Model ve validator rectangular grid destekliyor; ancak production/prototype oyun ekranlarında kare `AspectRatio(1)` / 6×6 hücre varsayımları bulunuyor. 6×10 için:
- grid yüksekliği 10 satıra göre hesaplanmalı,
- cell hit-testing rowCount/columnCount üzerinden dinamik olmalı,
- gesture/widget testlerindeki `/6` sabitleri kaldırılmalı,
- 6×10 grid Android telefonda hedef/bonus alanıyla birlikte taşmadan kullanılmalı.

## Korunan alanlar

Açık kapsam olmadan değişmez:
- `lib/main.dart`
- `assets/questions.json`
- BoardMap / 67 node / 3B tahta
- MASTER ART bytes ve kabul edilmiş route art mimarisi
- AdMob / Firebase / Android release/signing config
- package name
- `version: 1.68.19+109`

## Sıradaki aktif sıra

1. `word_hunt_starter_content_test.dart` → 6×10, 6→10 density ve 80 exact-occurrence/path sözleşmesi.
2. Prototype gesture testleri → dinamik row/column ölçümü ve yeni canonical yollar.
3. Production/prototype grid UI → rectangular 6×10 layout + hit-testing.
4. Bonus-after-targets + soft-time gameplay UX.
5. Focused Word Hunt tests + analyze + diff-check.
6. Android 16 gerçek production QA; özellikle B1, B5, B8, B10.
7. Kullanıcı görsel/oynanış onayı olmadan PR #156 Ready/merge yapılmaz.

Diğer Bilgi Rotası açık işleri diğer project-memory dosyalarında korunur; bu özet onları silmez.
