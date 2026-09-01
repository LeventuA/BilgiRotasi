from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    p = Path(path)
    text = p.read_text()
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{path}: expected one anchor, got {count}")
    p.write_text(text.replace(old, new, 1))


evidence = """## 1 Eylül 2026 — V6 error-state visual PASS / PR #164

- Kullanıcı, ham Android 16 screenrecord'dan çıkarılan bordo/kırmızı hata-state frame'ine açıkça **PASS** verdi.
- Temiz ürün branch'i: `fix/kelime-avi-v6-error-state-red-clean-20260901`.
- Temiz ürün commit: `0d845fc75bbe7b92c3d778ccfbcbde2761fa56de` — `fix(kelime-avi): distinguish error state from found state`.
- Base accepted V6 checkpoint: `889cf391d3db9b34644699237ff8c50d2744e061` / PR #163 head.
- Ürün diff'i yalnız `lib/word_hunt/word_hunt_screens.dart` içinde 2 insertions + 2 deletions: error fill `0xB35A1F2B`, error border `0xFFFF6B57`.
- Found-state altın dili, 8×8 geometri, engine/path/scoring/timer/progression ve içerik değişmedi; error feedback süresi **280 ms / unchanged**.
- Productize run `33524396204`: SUCCESS; `dart analyze lib/word_hunt` PASS ve focused Kelime Avı **138/138 PASS**.
- Raw Android 16 run `33524578623`: SUCCESS; API 36 / 1080×1920 / 420 dpi; `WRONG_WORD_REGISTERED_GATE=PASS`; mistake panel changed pixels `703`; artifact `9807557629`, digest `sha256:bfbcb5603f2ad5bdd21b324115d0999a6c12a7c62b0e4d89bc31e8012186dadc`.
- Draft PR **#164**: OPEN / DRAFT; base `fix/kelime-avi-v6-found-path-connector-product-20260901`; head `fix/kelime-avi-v6-error-state-red-clean-20260901`.
- `ERROR_STATE_VISUAL = PASS / CLOSED`.
- `REFERENCE_FONT = DOĞRULANACAK` kalır. B5/B10 gerçek insan playtesti, Ready kararları, ayrı merge onayı ve production navigation entegrasyonu hâlâ açıktır.

**Durum:** V6 INITIAL + FOUND + ERROR RAW ANDROID USER VISUAL PASS / READY YOK / MERGE YOK.

---

"""

replace_once(
    "docs/project-memory/BILGI_ROTASI_DURUM.md",
    "> 26 Ağustos 2026 aktif kesimidir. PR #147 merge öncesi ayrıntılı durum dosyasının değişmemiş kopyası `docs/project-memory/archive/BILGI_ROTASI_DURUM_PRE_PR147_MERGE_20260825.md` altında korunur. Teknik gerçek her zaman canlı GitHub ve ilgili canlı servislerdir.\n\n",
    "> 1 Eylül 2026 aktif kesimidir. PR #147 merge öncesi ayrıntılı durum dosyasının değişmemiş kopyası `docs/project-memory/archive/BILGI_ROTASI_DURUM_PRE_PR147_MERGE_20260825.md` altında korunur. Teknik gerçek her zaman canlı GitHub ve ilgili canlı servislerdir.\n\n"
    + evidence,
)

decision = """---

## 0B. Kelime Avı V6 error-state görsel kararı

- 1 Eylül 2026 kullanıcı görsel kabulüyle yanlış seçim/hata feedback'i found-state altın dilinden kesin olarak ayrılır.
- Error fill: `0xB35A1F2B` koyu bordo.
- Error border: `0xFFFF6B57` sıcak kırmızı-turuncu.
- Harfler açık/krem kalır; yanlış seçilen hücreler birbirine found-path gibi bağlanmaz.
- Error feedback süresi `280 ms` olarak korunur; mesaj/sayaç/gameplay davranışı değişmez.
- Found-state altın görünümü değişmez.
- Bu karar raw Android 16 run `33524578623` ve kullanıcı **PASS** ile kabul edilmiştir; `ERROR_STATE_VISUAL` kapısı kapanmıştır.
- Exact font seçimi bu karardan bağımsızdır ve `REFERENCE_FONT = DOĞRULANACAK` olarak açık kalır.

---

## 1. Çalışma ve Git düzeni"""
replace_once(
    "docs/project-memory/KARARLAR.md",
    "---\n\n## 1. Çalışma ve Git düzeni",
    decision,
)

p = Path("docs/project-memory/GOREV_HAVUZU.md")
text = p.read_text()
old_line = "- [ ] `ERROR_STATE_VISUAL` için referans/karar doğrulaması."
if text.count(old_line) != 1:
    raise SystemExit("GOREV_HAVUZU error-state checkbox anchor mismatch")
text = text.replace(
    old_line,
    "- [x] `ERROR_STATE_VISUAL` raw Android 16 + kullanıcı PASS ile kapatıldı; PR #164 / commit `0d845fc75bbe7b92c3d778ccfbcbde2761fa56de`.",
    1,
)
anchor = "- Clean product commit: `217beb83c31976436a6f26ec43ae4e35a0c7f05c` exact aynı blob’u taşır.\n"
if text.count(anchor) != 1:
    raise SystemExit("GOREV_HAVUZU accepted-chain anchor mismatch")
text = text.replace(
    anchor,
    anchor
    + "- Error-state product commit: `0d845fc75bbe7b92c3d778ccfbcbde2761fa56de`; yalnız 2 renk satırı değişti.\n"
    + "- Error-state productize run `33524396204`: analyze PASS + focused 138/138 PASS.\n"
    + "- Raw Android 16 error-state run `33524578623`: SUCCESS; wrong-word gate PASS; artifact `9807557629`; kullanıcı görsel **PASS**.\n"
    + "- Draft PR #164 OPEN/DRAFT; Ready/merge yok.\n",
    1,
)
p.write_text(text)

replace_once(
    "docs/project-memory/GENEL_PROJE_OZETI.md",
    "**Son güncelleme:** 1 Eylül 2026 — Kelime Avı V6 edge-fuse raw Android görsel kabulü PASS. Exact tested commit `4dddf00178ef9f14b8edb3fc706114be72f477a4`, exact blob `f43deaad5328f6263f9479de1738cc1f4ac465e0`, Android 16 run `33486609120` SUCCESS, artifact `9792346079`. Raw B10 initial ve `YOL / 1/9` edge-fuse found-state Levent tarafından PASS edildi. Temiz ürün commit `217beb83c31976436a6f26ec43ae4e35a0c7f05c` aynı blob’u taşır. Draft PR #163 OPEN/DRAFT; Ready/merge yok.",
    "**Son güncelleme:** 1 Eylül 2026 — Kelime Avı V6 `ERROR_STATE_VISUAL` raw Android 16 + kullanıcı kabulü **PASS / CLOSED**. Temiz ürün commit `0d845fc75bbe7b92c3d778ccfbcbde2761fa56de`; error fill `0xB35A1F2B`, border `0xFFFF6B57`, 280 ms unchanged. Productize run `33524396204` SUCCESS (analyze + 138/138), raw Android run `33524578623` SUCCESS, artifact `9807557629`. Draft PR #164 OPEN/DRAFT; Ready/merge yok. Sıradaki açık görsel doğrulama `REFERENCE_FONT`.",
)

p = Path("docs/project-memory/GENEL_PROJE_OZETI.md")
text = p.read_text()
anchor = "## Kalan aktif sıra — YENİ SOHBET BURADAN DEVAM ETSİN\n"
section = """## 1 Eylül 2026 — V6 error-state kabul checkpoint'i

- Accepted parent visual checkpoint: PR #163 head `889cf391d3db9b34644699237ff8c50d2744e061`.
- Error-state branch: `fix/kelime-avi-v6-error-state-red-clean-20260901`.
- Commit: `0d845fc75bbe7b92c3d778ccfbcbde2761fa56de` (`fix(kelime-avi): distinguish error state from found state`).
- Diff: yalnız 2 renk satırı; 8×8/gameplay/found-state/locked assetler değişmedi.
- Productize run `33524396204`: SUCCESS; analyze PASS; focused 138/138 PASS.
- Android 16 run `33524578623`: SUCCESS; wrong-word runtime gate PASS; 280 ms unchanged; artifact `9807557629`.
- Kullanıcı raw error-state frame/video için **PASS** verdi.
- Draft PR #164 OPEN/DRAFT; merge yapılmadı.
- `ERROR_STATE_VISUAL = PASS`; `REFERENCE_FONT = DOĞRULANACAK`.

"""
if text.count(anchor) != 1:
    raise SystemExit("GENEL_PROJE_OZETI remaining-order anchor mismatch")
p.write_text(text.replace(anchor, section + anchor, 1))

p = Path("docs/project-memory/ACIK_SORULAR_VE_DOGRULAMALAR.md")
text = p.read_text()
old_heading = "## Kelime Avı Başlangıç Limanı 8×8 — TEKNİK PASS / CURRENT ANDROID GÖRSEL FAIL / KULLANICI KABULÜ AÇIK"
if text.count(old_heading) != 1:
    raise SystemExit("ACIK_SORULAR heading anchor mismatch")
text = text.replace(
    old_heading,
    "## Kelime Avı Başlangıç Limanı 8×8 — V6 RAW ANDROID INITIAL + FOUND + ERROR USER PASS / KALAN DOĞRULAMALAR AÇIK",
    1,
)
old_accept = "- [ ] **GERÇEK ANDROID GÖRSEL KABUL:** mevcut runtime kullanıcı tarafından FAIL edildi."
if text.count(old_accept) != 1:
    raise SystemExit("ACIK_SORULAR visual acceptance anchor mismatch")
text = text.replace(
    old_accept,
    "- [x] **GERÇEK ANDROID GÖRSEL KABUL:** V6 raw initial + edge-fuse found-state + bordo/kırmızı error-state kullanıcı tarafından PASS edildi.",
    1,
)
old_limit = "**ÖNEMLİ RUN SINIRI:** run `33388386388` genel sonucu FAILURE'dır; screenshot ve real-gesture visual-change PASS sonrasında exact log-string `grep` assertion'ı exit 1 vermiştir. Bu run workflow SUCCESS diye yazılmayacak. Ayrıca runtime davranışı teknik olarak çalışsa bile görsel kullanıcı kabulü ayrı kapıdır ve şu an FAIL'dir."
if text.count(old_limit) != 1:
    raise SystemExit("ACIK_SORULAR historical limit anchor mismatch")
text = text.replace(
    old_limit,
    "**TARİHSEL RUN SINIRI:** run `33388386388` genel sonucu FAILURE'dır ve workflow SUCCESS diye yazılmaz. Bu eski V5 runtime FAIL kaydı, daha sonraki V6 raw Android kullanıcı kabulleriyle görsel durum açısından supersede edilmiştir; tarihsel kanıt olarak korunur.",
    1,
)
start = text.index("**DOĞRULANACAK — KALANLAR:**")
end = text.index("\n\n### Tarihsel 30–31 Ağustos V5 tema kanıtları", start)
remaining = """**DOĞRULANACAK — KALANLAR:**
1. `REFERENCE_FONT`: exact font kaynağı/kararı bağımsız doğrulanmadı.
2. B5 60 saniye ve B10 120 saniye challenge süreleri gerçek insan playtestinde dengeli mi?
3. PR #161 / #162 / #163 / #164 ne zaman Ready yapılacak? Görsel PASS merge veya Ready izni değildir.
4. Merge için Levent ayrıca açık onay verecek mi?
5. Production `lib/main.dart` ana navigasyon entegrasyonu için ayrı kapsam/onay verilecek mi?
6. Eski PR #156 ne zaman/kim tarafından kapatılacak? Otomatik kapatılmayacak.

**KAPANDI — `ERROR_STATE_VISUAL`:** error fill `0xB35A1F2B`, border `0xFFFF6B57`, 280 ms unchanged; product commit `0d845fc75bbe7b92c3d778ccfbcbde2761fa56de`; run `33524578623` SUCCESS; artifact `9807557629`; kullanıcı raw Android görsel **PASS**."""
p.write_text(text[:start] + remaining + text[end:])
