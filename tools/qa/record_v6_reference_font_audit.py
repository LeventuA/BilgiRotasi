from pathlib import Path
import re
import subprocess

PRODUCT_BRANCH = 'fix/kelime-avi-v6-error-state-red-clean-20260901'
PRODUCT_BASE_SHA = '4ddeff9e1f76167037756c430f6b61d6c0dd284c'
DOCS_BRANCH = 'docs/kelime-avi-v6-reference-font-audit-20260901'


def read(path: str) -> str:
    return Path(path).read_text(encoding='utf-8')


def write(path: str, text: str) -> None:
    Path(path).write_text(text, encoding='utf-8')


# Live repository facts for the audit.
screens = read('lib/word_hunt/word_hunt_screens.dart')
pubspec = read('pubspec.yaml')
tracked = subprocess.check_output(['git', 'ls-files'], text=True).splitlines()
font_files = [
    p for p in tracked
    if p.lower().endswith(('.ttf', '.otf', '.woff', '.woff2'))
    or '/fonts/' in f'/{p.lower()}/'
    or p.lower().startswith('fonts/')
]

assert "fontFamily: 'serif'" in screens, 'Current gameplay no longer uses the expected generic serif marker.'
assert re.search(r'^\s*fonts\s*:', pubspec, flags=re.MULTILINE) is None, 'pubspec now contains a custom fonts declaration; re-audit required.'
assert not font_files, f'Bundled font files now exist; re-audit required: {font_files}'
assert re.search(r'^version:\s*1\.68\.19\+109\s*$', pubspec, flags=re.MULTILINE), 'Unexpected pubspec version.'

# BILGI_ROTASI_DURUM.md
p = 'docs/project-memory/BILGI_ROTASI_DURUM.md'
t = read(p)
marker = '## 1 Eylül 2026 — V6 reference font kaynak denetimi / EXACT KİMLİK DOĞRULANACAK'
assert marker not in t
header = '> 1 Eylül 2026 aktif kesimidir. PR #147 merge öncesi ayrıntılı durum dosyasının değişmemiş kopyası `docs/project-memory/archive/BILGI_ROTASI_DURUM_PRE_PR147_MERGE_20260825.md` altında korunur. Teknik gerçek her zaman canlı GitHub ve ilgili canlı servislerdir.\n\n'
assert t.count(header) == 1
section = '''## 1 Eylül 2026 — V6 reference font kaynak denetimi / EXACT KİMLİK DOĞRULANACAK

- Font denetimi, accepted V6 child chain'in güncel checkpoint'i `4ddeff9e1f76167037756c430f6b61d6c0dd284c` üzerinde yapıldı.
- `lib/word_hunt/word_hunt_screens.dart` gameplay metinlerinde özel bir font adı yerine generic `fontFamily: 'serif'` kullanıyor.
- `pubspec.yaml` içinde Flutter `fonts:` tanımı yok; sürüm `1.68.19+109` değişmedi.
- Canlı branch'in tracked tree'sinde `.ttf`, `.otf`, `.woff`, `.woff2` veya `fonts/` altında bundled font dosyası yok.
- `KAYNAK_DEFTERI.md`, `TEKNIK_GENEL_BAKIS.md`, README ve Issue #109 kaynak zinciri exact font ailesi/dosyası/provenance bilgisi vermiyor; Issue #109 yorum listesi de boş.
- Raster referanstan yalnız görsel benzerliğe bakarak font adı tahmin edilmeyecek. Exact family/file/source ve lisans/provenance doğrulanmadan font ürüne eklenmeyecek.
- Bu denetim **ürün kodunu değiştirmez**; bu nedenle yeni Android render kanıtı üretilmedi. Mevcut accepted raw Android initial/found/error görsel PASS'leri korunur.
- `REFERENCE_FONT = DOĞRULANACAK`: kaynak denetimi tamam, exact kimlik/source hâlâ bulunmadı.

**Durum:** REFERENCE FONT SOURCE AUDIT PASS / EXACT FONT IDENTITY OPEN / PRODUCT CODE UNCHANGED / READY-MERGE YOK.

---

'''
write(p, t.replace(header, header + section, 1))

# KARARLAR.md
p = 'docs/project-memory/KARARLAR.md'
t = read(p)
marker = '## 0C. Kelime Avı V6 reference font doğrulama kararı'
assert marker not in t
anchor = '---\n\n## 1. Çalışma ve Git düzeni'
assert t.count(anchor) == 1
decision = '''---

## 0C. Kelime Avı V6 reference font doğrulama kararı

- Exact font ailesi raster ekran görüntüsünden tahmin edilerek production'a yazılmaz.
- `REFERENCE_FONT` PASS sayılabilmesi için en az exact font family adı ve güvenilir kaynak/provenance doğrulanmalıdır; custom font dosyası kullanılacaksa lisans/dağıtım uygunluğu da doğrulanır.
- Exact kaynak bulunana kadar accepted gameplay'in mevcut generic `fontFamily: 'serif'` davranışı değiştirilmez.
- Repo içinde custom font deklarasyonu/dosyası olmadığı 1 Eylül 2026 denetiminde doğrulandı; bu, generic serif'i exact referans font olarak kabul etmek anlamına gelmez.
- Font implementation yapılırsa ayrı branch/test/raw Android görsel kabulü gerekir.

---

## 1. Çalışma ve Git düzeni'''
write(p, t.replace(anchor, decision, 1))

# GOREV_HAVUZU.md
p = 'docs/project-memory/GOREV_HAVUZU.md'
t = read(p)
old = '- [ ] Exact `REFERENCE_FONT` kaynağı/kararı doğrulaması.'
assert t.count(old) == 1
new = '''- [x] `REFERENCE_FONT` repo/source audit: current gameplay generic `serif`; pubspec custom font yok; tracked font dosyası yok.
- [ ] Exact `REFERENCE_FONT` family/source/provenance ve gerekiyorsa lisans doğrulaması; kaynak bulunmadan implementation yok.'''
write(p, t.replace(old, new, 1))

# GENEL_PROJE_OZETI.md
p = 'docs/project-memory/GENEL_PROJE_OZETI.md'
t = read(p)
lines = t.splitlines()
assert lines and lines[0].startswith('# Bilgi Rotası')
idx = next(i for i, line in enumerate(lines) if line.startswith('**Son güncelleme:**'))
lines[idx] = ('**Son güncelleme:** 1 Eylül 2026 — Kelime Avı V6 `REFERENCE_FONT` kaynak denetimi tamamlandı. '
              "Accepted gameplay kodu generic `fontFamily: 'serif'` kullanıyor; `pubspec.yaml` custom `fonts:` tanımı içermiyor; tracked tree'de TTF/OTF/WOFF/WOFF2 veya `fonts/` font asset'i yok. "
              'KAYNAK_DEFTERI / TEKNIK_GENEL_BAKIS / README / Issue #109 kaynak zinciri exact font identity vermiyor. '
              '`REFERENCE_FONT = DOĞRULANACAK`; font tahminiyle ürün değişikliği yapılmadı, Android yeniden koşturulmadı. PR #164 OPEN/DRAFT; Ready/merge yok.')
t = '\n'.join(lines) + ('\n' if read(p).endswith('\n') else '')
anchor = '## Kalan aktif sıra — YENİ SOHBET BURADAN DEVAM ETSİN\n'
assert t.count(anchor) == 1
section = '''## 1 Eylül 2026 — V6 reference font audit checkpoint\n\n- Audit base: `4ddeff9e1f76167037756c430f6b61d6c0dd284c`.\n- Current gameplay typography: generic `fontFamily: 'serif'`.\n- `pubspec.yaml`: custom Flutter `fonts:` declaration yok.\n- Tracked tree: `.ttf/.otf/.woff/.woff2` ve `fonts/` font asset'i yok.\n- Project source notes + Issue #109 exact font family/file/provenance tanımlamıyor.\n- Sonuç: exact font identity bulunmadı; görselden font adı tahmin edilmeyecek.\n- Product code unchanged; mevcut raw Android visual PASS'ler korunur.\n- `REFERENCE_FONT = DOĞRULANACAK`; sonraki çözüm için exact family/source/provenance gerekir.\n\n'''
write(p, t.replace(anchor, section + anchor, 1))

# ACIK_SORULAR_VE_DOGRULAMALAR.md
p = 'docs/project-memory/ACIK_SORULAR_VE_DOGRULAMALAR.md'
t = read(p)
old = '1. `REFERENCE_FONT`: exact font kaynağı/kararı bağımsız doğrulanmadı.'
assert t.count(old) == 1
new = ('1. `REFERENCE_FONT`: **KAYNAK DENETİMİ TAMAMLANDI / EXACT KİMLİK DOĞRULANACAK.** '
       "Current gameplay generic `fontFamily: 'serif'`; pubspec custom font deklarasyonu yok; tracked font dosyası yok; proje kaynakları ve Issue #109 exact family/file/provenance vermiyor. "
       'Exact family/source ve gerekiyorsa lisans doğrulanmadan implementation yapılmayacak.')
write(p, t.replace(old, new, 1))

print('REFERENCE_FONT_SOURCE_AUDIT=PASS')
print('CURRENT_GAMEPLAY_FONT=generic serif')
print('PUBSPEC_CUSTOM_FONT=NONE')
print('TRACKED_FONT_FILES=NONE')
print('REFERENCE_FONT_IDENTITY=DOĞRULANACAK')
