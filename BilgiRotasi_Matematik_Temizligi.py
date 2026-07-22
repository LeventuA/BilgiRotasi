#!/usr/bin/env python3
from pathlib import Path
from collections import Counter
import json
import re
import shutil
import subprocess

MAIN = Path("lib/main.dart")
QUALITY = Path("lib/question_quality.dart")
QUESTIONS = Path("assets/questions.json")
PUBSPEC = Path("pubspec.yaml")
REPORT = Path("reports/category_math_questions.txt")

DART_MARKER = "Kategori dışı matematik problemi"


def fail(message: str) -> None:
    raise SystemExit(f"\n❌ {message}\n")


def run(command: list[str], **kwargs):
    return subprocess.run(command, check=True, **kwargs)


def normalize(value: object) -> str:
    text = str(value or "").lower()
    text = text.translate(
        str.maketrans(
            {
                "ç": "c",
                "ğ": "g",
                "ı": "i",
                "ö": "o",
                "ş": "s",
                "ü": "u",
                "â": "a",
                "î": "i",
                "û": "u",
            }
        )
    )
    text = re.sub(r"[^a-z0-9:+%.,×x*/÷−-]+", " ", text)
    return re.sub(r"\s+", " ", text).strip()


def looks_like_disguised_math(item: dict) -> tuple[bool, list[str]]:
    question = str(item.get("question", "")).strip()
    options = item.get("options", [])
    if not isinstance(options, list):
        options = []

    normalized = normalize(question)
    number_count = len(
        re.findall(r"(?<![a-z])\d+(?:[.,]\d+)?", normalized)
    )

    numeric_option_pattern = re.compile(
        r"^\s*[-+]?\d+(?:[.,]\d+)?"
        r"(?:\s*:\s*\d+(?:[.,]\d+)?)?"
        r"(?:\s*(?:mb|gb|tb|kb|km|m|cm|mm|kg|g|lt|l|"
        r"saat|dakika|saniye|puan|adet|tane|yuzde|%))?\s*$",
        re.IGNORECASE,
    )
    numeric_option_count = sum(
        bool(numeric_option_pattern.fullmatch(str(option).strip()))
        for option in options
    )

    strong_phrases = (
        "toplam kac",
        "toplam ne kadar",
        "toplami nedir",
        "toplam yolu",
        "toplam mesafe",
        "toplam sure",
        "toplam maliyet",
        "toplam puan",
        "ne kadar yer kaplar",
        "kac mb",
        "kac gb",
        "kac kilometre",
        "kac km",
        "kac metre",
        "kac cm",
        "kac dakika",
        "kac saat",
        "kac tam",
        "kac kat",
        "kac adet",
        "kac tane",
        "kac doldurur",
        "sadelestirilmis en boy orani",
        "en boy orani",
        "orani nedir",
        "oran nedir",
        "alani nedir",
        "alan nedir",
        "cevresi nedir",
        "cevre nedir",
        "ortalamasi nedir",
        "yuzdesi nedir",
        "yuzde kac",
        "farki nedir",
        "carpimi nedir",
        "bolumu nedir",
        "her bolumu",
        "her biri",
        "birim fiyati",
        "saatte",
        "saat boyunca",
        "dakikada",
        "dakika boyunca",
        "saniyede",
        "indirimli fiyat",
        "yuzde artis",
        "yuzde azalis",
    )
    matched_phrases = [
        phrase for phrase in strong_phrases if phrase in normalized
    ]

    has_arithmetic_symbol = bool(
        re.search(r"\d\s*(?:x|×|\*|/|÷|\+|−|-)\s*\d", normalized)
    )
    asks_quantity = any(
        phrase in normalized
        for phrase in ("kac", "ne kadar", "nedir", "bulunur", "hesaplanir")
    )
    words = set(normalized.split())
    has_measurement_pair = (
        number_count >= 2
        and any(
            unit in words
            for unit in (
                "mb", "gb", "km", "metre", "cm", "saat",
                "dakika", "saniye", "kg", "gram", "litre",
            )
        )
    )

    reasons: list[str] = []
    if matched_phrases:
        reasons.append("aritmetik/ölçü kalıbı: " + ", ".join(matched_phrases[:3]))
    if has_arithmetic_symbol:
        reasons.append("işlem işareti")
    if numeric_option_count >= 3:
        reasons.append("sayısal seçenekler")
    if has_measurement_pair:
        reasons.append("birden fazla sayı ve ölçü birimi")

    is_math = (
        number_count >= 2
        and (
            bool(matched_phrases)
            or has_arithmetic_symbol
            or (numeric_option_count >= 3 and asks_quantity)
            or (has_measurement_pair and numeric_option_count >= 3)
        )
    ) or (
        number_count >= 1
        and bool(matched_phrases)
        and numeric_option_count >= 3
    )

    return is_math, reasons


for path in (MAIN, QUALITY, QUESTIONS, PUBSPEC):
    if not path.exists():
        fail(
            f"Gerekli dosya bulunamadı: {path}\n"
            "Kurulum dosyasını BilgiRotasi deposunun ana klasöründe çalıştır."
        )

branch = run(
    ["git", "branch", "--show-current"],
    capture_output=True,
    text=True,
).stdout.strip()
if branch != "main":
    fail(f"Bu paket main dalında çalıştırılmalı. Mevcut dal: {branch or 'bilinmiyor'}")

run(["git", "pull", "--ff-only", "origin", "main"])

if subprocess.run(["git", "diff", "--quiet"], check=False).returncode != 0:
    fail(
        "Repoda commit edilmemiş değişiklik var.\n"
        "Önce mevcut çalışmayı commit et veya temizle."
    )

main_text = MAIN.read_text(encoding="utf-8")
quality_text = QUALITY.read_text(encoding="utf-8")
pubspec_text = PUBSPEC.read_text(encoding="utf-8")

if DART_MARKER in quality_text:
    fail("Matematik sorusu temizliği bu repoda zaten kurulu görünüyor.")

if "class QuestionQualityGuard" not in quality_text:
    fail("Soru Kalite Filtresi bulunamadı.")

helper_marker = "  static List<String> reasons(QuizQuestion question) {"
if quality_text.count(helper_marker) != 1:
    fail("QuestionQualityGuard içine matematik denetimi eklenemedi.")

dart_helper = r'''  static bool _looksLikeCategoryDisguisedMath(
    QuizQuestion question,
    String normalizedQuestion,
  ) {
    final numberCount = RegExp(
      r'\d+(?:[.,]\d+)?',
    ).allMatches(normalizedQuestion).length;

    final numericOptionPattern = RegExp(
      r'^\s*[-+]?\d+(?:[.,]\d+)?'
      r'(?:\s*:\s*\d+(?:[.,]\d+)?)?'
      r'(?:\s*(?:mb|gb|tb|kb|km|m|cm|mm|kg|g|lt|l|'
      r'saat|dakika|saniye|puan|adet|tane|yuzde|%))?\s*$',
      caseSensitive: false,
    );

    final numericOptionCount = question.options
        .where(
          (option) => numericOptionPattern.hasMatch(
            option.trim().toLowerCase(),
          ),
        )
        .length;

    const strongPhrases = <String>[
      'toplam kac',
      'toplam ne kadar',
      'toplami nedir',
      'toplam yolu',
      'toplam mesafe',
      'toplam sure',
      'toplam maliyet',
      'toplam puan',
      'ne kadar yer kaplar',
      'kac mb',
      'kac gb',
      'kac kilometre',
      'kac km',
      'kac metre',
      'kac cm',
      'kac dakika',
      'kac saat',
      'kac tam',
      'kac kat',
      'kac adet',
      'kac tane',
      'kac doldurur',
      'sadelestirilmis en boy orani',
      'en boy orani',
      'orani nedir',
      'oran nedir',
      'alani nedir',
      'alan nedir',
      'cevresi nedir',
      'cevre nedir',
      'ortalamasi nedir',
      'yuzdesi nedir',
      'yuzde kac',
      'farki nedir',
      'carpimi nedir',
      'bolumu nedir',
      'her bolumu',
      'her biri',
      'birim fiyati',
      'saatte',
      'saat boyunca',
      'dakikada',
      'dakika boyunca',
      'saniyede',
      'indirimli fiyat',
      'yuzde artis',
      'yuzde azalis',
    ];

    final hasStrongPhrase = strongPhrases.any(
      normalizedQuestion.contains,
    );
    final hasArithmeticSymbol = RegExp(
      r'\d\s*(?:x|×|\*|/|÷|\+|−|-)\s*\d',
    ).hasMatch(question.text);
    final asksQuantity = const <String>[
      'kac',
      'ne kadar',
      'nedir',
      'bulunur',
      'hesaplanir',
    ].any(normalizedQuestion.contains);

    final words = normalizedQuestion.split(' ').toSet();
    final hasMeasurementPair = numberCount >= 2 &&
        const <String>[
          'mb',
          'gb',
          'km',
          'metre',
          'cm',
          'saat',
          'dakika',
          'saniye',
          'kg',
          'gram',
          'litre',
        ].any(words.contains);

    return (numberCount >= 2 &&
            (hasStrongPhrase ||
                hasArithmeticSymbol ||
                (numericOptionCount >= 3 && asksQuantity) ||
                (hasMeasurementPair &&
                    numericOptionCount >= 3))) ||
        (numberCount >= 1 &&
            hasStrongPhrase &&
            numericOptionCount >= 3);
  }

'''

quality_text = quality_text.replace(helper_marker, dart_helper + helper_marker, 1)

return_marker = "    return reasons.toSet().toList(growable: false);"
if quality_text.count(return_marker) != 1:
    fail("QuestionQualityGuard sonuç bölümü bulunamadı.")

quality_text = quality_text.replace(
    return_marker,
    f'''    if (_looksLikeCategoryDisguisedMath(
      question,
      normalizedQuestion,
    )) {{
      reasons.add('{DART_MARKER}');
    }}

{return_marker}''',
    1,
)

try:
    raw_questions = json.loads(QUESTIONS.read_text(encoding="utf-8"))
except Exception as error:
    fail(f"questions.json okunamadı: {error}")

if not isinstance(raw_questions, list):
    fail("assets/questions.json bir JSON listesi olmalı.")

category_names = {
    0: "Coğrafya",
    1: "Eğlence",
    2: "Tarih",
    3: "Sanat & Edebiyat",
    4: "Bilim & Doğa",
    5: "Spor",
}
flagged: list[tuple[str, str, str, str]] = []
category_counts: Counter[str] = Counter()

for item in raw_questions:
    if not isinstance(item, dict):
        continue
    matched, reasons = looks_like_disguised_math(item)
    if not matched:
        continue

    category = category_names.get(
        item.get("categoryIndex"),
        f"Kategori {item.get('categoryIndex')}",
    )
    category_counts[category] += 1
    flagged.append(
        (
            str(item.get("id", "")),
            category,
            "; ".join(reasons),
            str(item.get("question", "")).replace("\n", " ").strip(),
        )
    )

REPORT.parent.mkdir(parents=True, exist_ok=True)
report_lines = [
    "BİLGİ ROTASI – KATEGORİYE GİYDİRİLMİŞ MATEMATİK SORULARI",
    "=" * 86,
    "",
    f"Toplam soru bankası: {len(raw_questions)}",
    f"Matematik problemi olarak elenecek: {len(flagged)}",
    "",
    "KATEGORİLERE GÖRE",
    "-" * 86,
]
for category, count in category_counts.most_common():
    report_lines.append(f"{category}: {count}")

report_lines.extend(
    [
        "",
        "ELENECEK SORULAR",
        "-" * 86,
        "ID\tKATEGORİ\tTESPİT\tSORU",
    ]
)
for question_id, category, reasons, question in flagged:
    report_lines.append(f"{question_id}\t{category}\t{reasons}\t{question}")

REPORT.write_text("\n".join(report_lines) + "\n", encoding="utf-8")

version_match = re.search(
    r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$",
    pubspec_text,
    flags=re.MULTILINE,
)
if not version_match:
    fail("pubspec.yaml sürüm satırı okunamadı.")

major, minor, patch, build = map(int, version_match.groups())
new_version = f"{major}.{minor + 1}.0+{build + 1}"
display_version = f"{major}.{minor + 1}.0"

pubspec_text = re.sub(
    r"^version:\s*.*$",
    f"version: {new_version}",
    pubspec_text,
    count=1,
    flags=re.MULTILINE,
)

main_text, version_replacements = re.subn(
    r"Bilgi Rotası • Sürüm \d+\.\d+(?:\.\d+)?",
    f"Bilgi Rotası • Sürüm {display_version}",
    main_text,
    count=1,
)
if version_replacements != 1:
    fail("Ana menü sürüm yazısı güncellenemedi.")

backup_dir = Path("/tmp/bilgi_rotasi_matematik_temizligi_yedek")
backup_dir.mkdir(parents=True, exist_ok=True)
shutil.copy2(MAIN, backup_dir / "main.dart")
shutil.copy2(QUALITY, backup_dir / "question_quality.dart")
shutil.copy2(PUBSPEC, backup_dir / "pubspec.yaml")
report_existed = REPORT.exists()
if report_existed:
    shutil.copy2(REPORT, backup_dir / "category_math_questions.txt")

try:
    MAIN.write_text(main_text, encoding="utf-8")
    QUALITY.write_text(quality_text, encoding="utf-8")
    PUBSPEC.write_text(pubspec_text, encoding="utf-8")

    if shutil.which("dart"):
        run(["dart", "format", "lib/main.dart", "lib/question_quality.dart"])

    run(["git", "diff", "--check"])

    if shutil.which("flutter"):
        run(["flutter", "analyze", "--no-fatal-infos"])
        if Path("test").exists():
            run(["flutter", "test"])

except Exception:
    shutil.copy2(backup_dir / "main.dart", MAIN)
    shutil.copy2(backup_dir / "question_quality.dart", QUALITY)
    shutil.copy2(backup_dir / "pubspec.yaml", PUBSPEC)
    if report_existed:
        shutil.copy2(backup_dir / "category_math_questions.txt", REPORT)
    elif REPORT.exists():
        REPORT.unlink()
    print(
        "\n❌ Kontrol sırasında hata oluştu; değiştirilen dosyalar "
        "eski hâline geri getirildi.\n"
    )
    raise

run(
    [
        "git",
        "add",
        "lib/main.dart",
        "lib/question_quality.dart",
        "reports/category_math_questions.txt",
        "pubspec.yaml",
    ]
)

has_changes = (
    subprocess.run(["git", "diff", "--cached", "--quiet"], check=False).returncode != 0
)
if not has_changes:
    fail("Commit edilecek değişiklik bulunamadı.")

run(
    [
        "git",
        "commit",
        "-m",
        "Kategoriye giydirilmis matematik sorularini ele",
    ]
)
run(["git", "push", "origin", "main"])

print("")
print("✅ Matematik sorusu temizliği tamamlandı.")
print("✅ Kategoriye matematik kostümü giydirilmiş problemler elendi.")
print("✅ Dört işlem, oran, hız-zaman, alan-çevre ve dosya boyutu")
print("   problemleri artık oyunda gösterilmeyecek.")
print("✅ questions.json değiştirilmedi.")
print(f"✅ Bu taramada elenen matematik sorusu: {len(flagged)}")
print(f"✅ Yeni sürüm: {new_version}")
print(f"📄 Ayrıntılı rapor: {REPORT}")
print("✅ Değişiklikler GitHub'a gönderildi.")
