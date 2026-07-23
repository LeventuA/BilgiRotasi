#!/usr/bin/env python3
from pathlib import Path
import json
import re
import shutil
import subprocess

MAIN = Path("lib/main.dart")
QUALITY = Path("lib/question_quality.dart")
QUESTIONS = Path("assets/questions.json")
PUBSPEC = Path("pubspec.yaml")
REPORT = Path("reports/repetitive_question_families_v2.txt")

TOPIC_TEMPERATURE = "temperature_conversion"
TOPIC_MUSIC = "music_note_duration"
TOPIC_ADMIN = "administrative_division_country"
FILTER_LETTER = "letter_counting"
FILTER_TEMP_DIFF = "temperature_difference"


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
    text = re.sub(r"[^a-z0-9°]+", " ", text)
    return re.sub(r"\s+", " ", text).strip()


def detect_rare_topic(item: dict) -> str | None:
    question = str(item.get("question", ""))
    category = item.get("categoryIndex")
    raw = question.lower()
    normalized = normalize(question)

    scale_count = 0
    if "celsius" in normalized or "°c" in raw:
        scale_count += 1
    if "fahrenheit" in normalized or "°f" in raw:
        scale_count += 1
    if "kelvin" in normalized:
        scale_count += 1

    if (
        category == 4
        and scale_count >= 2
        and any(
            phrase in normalized
            for phrase in (
                "kac derece",
                "kac derecedir",
                "olceginde",
                "donusumu",
                "donusturuldugunde",
            )
        )
    ):
        return TOPIC_TEMPERATURE

    number_count = len(
        re.findall(r"(?<![a-z])\d+(?:[.,]\d+)?", normalized)
    )
    music_words = (
        "nota" in normalized
        and any(
            word in normalized
            for word in (
                "vurus",
                "dortluk",
                "sekizlik",
                "onaltilik",
                "otuzikilik",
                "noktali",
                "olcu",
            )
        )
    )
    music_calc = any(
        phrase in normalized
        for phrase in (
            "toplam kac",
            "toplamda kac",
            "kac dortluk",
            "kac vurus",
            "vurus surer",
            "vurus eder",
            "zaman birimi kac",
            "kac tam olcu",
        )
    )
    if category == 1 and number_count >= 2 and music_words and music_calc:
        return TOPIC_MUSIC

    admin = (
        (
            "adli idari bolum" in normalized
            and any(
                phrase in normalized
                for phrase in (
                    "hangi ulkeye baglidir",
                    "hangi ulkeye aittir",
                    "hangi ulkenin",
                )
            )
        )
        or "hangi ulkenin alt ulusal bolum" in normalized
        or "alt ulusal bolumlerinden biri" in normalized
        or (
            "idari bolum" in normalized
            and "hangi ulkeye" in normalized
        )
    )
    if category == 0 and admin:
        return TOPIC_ADMIN

    return None


def detect_filtered_type(item: dict) -> str | None:
    question = str(item.get("question", ""))
    category = item.get("categoryIndex")
    normalized = normalize(question)

    asks_letters = any(
        phrase in normalized
        for phrase in (
            "kac harf vardir",
            "kac harften olusur",
            "harf sayisi kactir",
            "kac karakter vardir",
        )
    )
    letter_context = any(
        phrase in normalized
        for phrase in (
            "eser adinda",
            "eser basliginda",
            "adinda bosluk",
            "basliginda bosluk",
            "noktalama isaretleri sayilmadan",
            "bosluklar sayilmadan",
            "yalnizca harfler",
            "kelimesinde kac harf",
        )
    )
    if category == 3 and asks_letters and letter_context:
        return FILTER_LETTER

    number_count = len(
        re.findall(r"(?<![a-z])\d+(?:[.,]\d+)?", normalized)
    )
    temp_difference = (
        category == 0
        and "sicaklik" in normalized
        and number_count >= 2
        and any(
            phrase in normalized
            for phrase in (
                "kac derece artmis",
                "kac derece azalmis",
                "kac derece yukselmis",
                "kac derece dusmus",
                "derece artmis olur",
                "derece azalmis olur",
            )
        )
    )
    if temp_difference:
        return FILTER_TEMP_DIFF

    return None


# Görsellerdeki örnekleri doğrula.
rare_samples = [
    {
        "categoryIndex": 4,
        "question": (
            "Celsius ölçeğindeki eksi 125 derece, "
            "Fahrenheit ölçeğinde kaç derecedir?"
        ),
    },
    {
        "categoryIndex": 1,
        "question": (
            "1 adet noktalı sekizlik nota ile 2 adet onaltılık "
            "nota toplamda kaç dörtlük vuruş sürer?"
        ),
    },
    {
        "categoryIndex": 0,
        "question": "Phôngsali adlı idari bölüm hangi ülkeye bağlıdır?",
    },
]
if [detect_rare_topic(item) for item in rare_samples] != [
    TOPIC_TEMPERATURE,
    TOPIC_MUSIC,
    TOPIC_ADMIN,
]:
    fail("Seyreltilecek örnek soru algılama testi başarısız.")

filter_samples = [
    {
        "categoryIndex": 3,
        "question": (
            "“Fallingwater” eser adında boşluklar ve noktalama "
            "işaretleri sayılmadan kaç harf vardır?"
        ),
    },
    {
        "categoryIndex": 0,
        "question": (
            "Bir bölgede sıcaklık 14 °C’den 17 °C’ye yükselirse "
            "sıcaklık kaç derece artmış olur?"
        ),
    },
]
if [detect_filtered_type(item) for item in filter_samples] != [
    FILTER_LETTER,
    FILTER_TEMP_DIFF,
]:
    fail("Oyundan elenecek örnek soru algılama testi başarısız.")


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
    fail(f"Bu paket main dalında çalıştırılmalı. Mevcut dal: {branch}")

run(["git", "pull", "--ff-only", "origin", "main"])

if subprocess.run(["git", "diff", "--quiet"], check=False).returncode != 0:
    fail("Repoda commit edilmemiş değişiklik var.")

main_text = MAIN.read_text(encoding="utf-8")
quality_text = QUALITY.read_text(encoding="utf-8")
pubspec_text = PUBSPEC.read_text(encoding="utf-8")
questions = json.loads(QUESTIONS.read_text(encoding="utf-8"))

if not isinstance(questions, list):
    fail("assets/questions.json bir JSON listesi olmalı.")

rare_by_topic = {
    TOPIC_TEMPERATURE: [],
    TOPIC_MUSIC: [],
    TOPIC_ADMIN: [],
}
filtered_by_type = {
    FILTER_LETTER: [],
    FILTER_TEMP_DIFF: [],
}
changed_ids = []

for item in questions:
    if not isinstance(item, dict):
        continue

    topic = detect_rare_topic(item)
    if topic is not None:
        rare_by_topic[topic].append(
            {
                "id": str(item.get("id", "")),
                "oldDifficulty": str(item.get("difficulty", "Orta")),
                "question": str(item.get("question", "")),
            }
        )
        if item.get("difficulty") != "Zor":
            item["difficulty"] = "Zor"
            changed_ids.append(str(item.get("id", "")))

    filtered = detect_filtered_type(item)
    if filtered is not None:
        filtered_by_type[filtered].append(
            {
                "id": str(item.get("id", "")),
                "difficulty": str(item.get("difficulty", "Orta")),
                "question": str(item.get("question", "")),
            }
        )

missing = [
    key
    for key, items in {**rare_by_topic, **filtered_by_type}.items()
    if not items
]
if missing:
    fail("Beklenen soru kalıpları bulunamadı: " + ", ".join(missing))

family_pattern = re.compile(
    r"  static String questionFamilyKey\(String text\) \{"
    r".*?"
    r"\n  \}\n\n  Set<String> _familyKeysForIds",
    flags=re.DOTALL,
)

family_replacement = r'''  static String questionFamilyKey(String text) {
    final lower = text.toLowerCase();
    final normalized = lower
        .replaceAll('ç', 'c')
        .replaceAll('ğ', 'g')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ş', 's')
        .replaceAll('ü', 'u')
        .replaceAll('â', 'a')
        .replaceAll('î', 'i')
        .replaceAll('û', 'u')
        .replaceAll(RegExp(r'[^a-z0-9°]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    var temperatureScaleCount = 0;
    if (normalized.contains('celsius') || lower.contains('°c')) {
      temperatureScaleCount++;
    }
    if (normalized.contains('fahrenheit') || lower.contains('°f')) {
      temperatureScaleCount++;
    }
    if (normalized.contains('kelvin')) {
      temperatureScaleCount++;
    }

    if (temperatureScaleCount >= 2 &&
        const <String>[
          'kac derece',
          'kac derecedir',
          'olceginde',
          'donusumu',
          'donusturuldugunde',
        ].any(normalized.contains)) {
      return 'topic:temperature_conversion';
    }

    final numberCount = RegExp(
      r'(?<![a-z])\d+(?:[.,]\d+)?',
    ).allMatches(normalized).length;
    final musicWords = normalized.contains('nota') &&
        const <String>[
          'vurus',
          'dortluk',
          'sekizlik',
          'onaltilik',
          'otuzikilik',
          'noktali',
          'olcu',
        ].any(normalized.contains);
    final musicCalculation = const <String>[
      'toplam kac',
      'toplamda kac',
      'kac dortluk',
      'kac vurus',
      'vurus surer',
      'vurus eder',
      'zaman birimi kac',
      'kac tam olcu',
    ].any(normalized.contains);

    if (numberCount >= 2 &&
        musicWords &&
        musicCalculation) {
      return 'topic:music_note_duration';
    }

    final administrativeTemplate =
        (normalized.contains('adli idari bolum') &&
                const <String>[
                  'hangi ulkeye baglidir',
                  'hangi ulkeye aittir',
                  'hangi ulkenin',
                ].any(normalized.contains)) ||
            normalized.contains(
              'hangi ulkenin alt ulusal bolum',
            ) ||
            normalized.contains(
              'alt ulusal bolumlerinden biri',
            ) ||
            (normalized.contains('idari bolum') &&
                normalized.contains('hangi ulkeye'));

    if (administrativeTemplate) {
      return 'topic:administrative_division_country';
    }

    return normalized
        .replaceAll(RegExp(r'\d+(?:[.,/]\d+)*'), '#')
        .trim();
  }

  Set<String> _familyKeysForIds'''

main_text, count = family_pattern.subn(
    lambda _match: family_replacement,
    main_text,
    count=1,
)
if count != 1:
    fail("QuestionBank.questionFamilyKey güncellenemedi.")

uniform_marker = "final candidateFamilies = <String, List<QuizQuestion>>{};"
if uniform_marker not in main_text:
    selection_pattern = re.compile(
        r"    final question =\s*"
        r"candidates\[random\.nextInt\(candidates\.length\)\];"
        r"\n\n    usedQuestionIds\.add\(question\.id\);"
    )
    selection_replacement = r'''    final candidateFamilies =
        <String, List<QuizQuestion>>{};

    for (final candidate in candidates) {
      final familyKey =
          _familyKeyById[candidate.id] ??
              questionFamilyKey(candidate.text);
      candidateFamilies
          .putIfAbsent(
            familyKey,
            () => <QuizQuestion>[],
          )
          .add(candidate);
    }

    final families = candidateFamilies.values.toList();
    final selectedFamily =
        families[random.nextInt(families.length)];
    final question =
        selectedFamily[random.nextInt(selectedFamily.length)];

    usedQuestionIds.add(question.id);'''

    main_text, count = selection_pattern.subn(
        selection_replacement,
        main_text,
        count=1,
    )
    if count != 1:
        fail("Normal soru seçiminde aile dengesi kurulamadı.")

numeric_old = (
    "r'saat|dakika|saniye|puan|adet|tane|yuzde|%))?\\s*$'"
)
numeric_new = (
    "r'saat|dakika|saniye|puan|adet|tane|yuzde|derece|"
    "°c|°f|%))?\\s*$'"
)
if numeric_old in quality_text:
    quality_text = quality_text.replace(numeric_old, numeric_new, 1)
elif "derece|°c|°f|%" not in quality_text:
    fail("Sayısal seçenek birimleri güncellenemedi.")

phrase_anchor = "      'yuzde azalis',"
extra_phrases = r'''      'yuzde azalis',
      'kac derece artmis',
      'kac derece azalmis',
      'kac derece yukselmis',
      'kac derece dusmus',
      'derece artmis olur',
      'derece azalmis olur','''
if "kac derece artmis" not in quality_text:
    if quality_text.count(phrase_anchor) != 1:
        fail("Matematik kalıpları listesi güncellenemedi.")
    quality_text = quality_text.replace(
        phrase_anchor,
        extra_phrases,
        1,
    )

if "static bool _looksLikeLetterCounting(" not in quality_text:
    reasons_marker = "  static List<String> reasons(QuizQuestion question) {"
    if quality_text.count(reasons_marker) != 1:
        fail("Harf sayma denetimi eklenemedi.")

    helper = r'''  static bool _looksLikeLetterCounting(
    QuizQuestion question,
    String normalizedQuestion,
  ) {
    final asksLetters = const <String>[
      'kac harf vardir',
      'kac harften olusur',
      'harf sayisi kactir',
      'kac karakter vardir',
    ].any(normalizedQuestion.contains);

    final titleOrWordContext = const <String>[
      'eser adinda',
      'eser basliginda',
      'adinda bosluk',
      'basliginda bosluk',
      'noktalama isaretleri sayilmadan',
      'bosluklar sayilmadan',
      'yalnizca harfler',
      'kelimesinde kac harf',
    ].any(normalizedQuestion.contains);

    return asksLetters && titleOrWordContext;
  }

'''
    quality_text = quality_text.replace(
        reasons_marker,
        helper + reasons_marker,
        1,
    )

if "Kategori dışı harf sayma sorusu" not in quality_text:
    return_marker = "    return reasons.toSet().toList(growable: false);"
    if quality_text.count(return_marker) != 1:
        fail("Kalite filtresi sonuç alanı güncellenemedi.")

    letter_call = r'''    if (_looksLikeLetterCounting(
      question,
      normalizedQuestion,
    )) {
      reasons.add('Kategori dışı harf sayma sorusu');
    }

'''
    quality_text = quality_text.replace(
        return_marker,
        letter_call + return_marker,
        1,
    )

labels = {
    TOPIC_TEMPERATURE: "Bilim & Doğa – sıcaklık dönüşümleri",
    TOPIC_MUSIC: "Eğlence – nota/vuruş hesaplamaları",
    TOPIC_ADMIN: "Coğrafya – idari bölüm/ülke soruları",
    FILTER_LETTER: "Sanat & Edebiyat – eser adında harf sayma",
    FILTER_TEMP_DIFF: "Coğrafya – sıcaklık farkı çıkarma",
}

REPORT.parent.mkdir(parents=True, exist_ok=True)
lines = [
    "BİLGİ ROTASI – BEŞ SORU TÜRÜ TEK PAKET",
    "=" * 88,
    "",
    "SEYRELTİLEN VE ZOR YAPILANLAR",
    "-" * 88,
]
for key in (TOPIC_TEMPERATURE, TOPIC_MUSIC, TOPIC_ADMIN):
    lines.append(f"{labels[key]}: {len(rare_by_topic[key])} soru")
    for item in rare_by_topic[key]:
        lines.append(
            f"{item['id']}\t{item['oldDifficulty']} → Zor\t"
            f"{item['question']}"
        )
    lines.append("")

lines.extend(
    [
        "OYUNDAN TAMAMEN ELENENLER",
        "-" * 88,
    ]
)
for key in (FILTER_LETTER, FILTER_TEMP_DIFF):
    lines.append(f"{labels[key]}: {len(filtered_by_type[key])} soru")
    for item in filtered_by_type[key]:
        lines.append(
            f"{item['id']}\t{item['difficulty']}\t"
            f"{item['question']}"
        )
    lines.append("")

REPORT.write_text("\n".join(lines) + "\n", encoding="utf-8")

match = re.search(
    r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$",
    pubspec_text,
    flags=re.MULTILINE,
)
if not match:
    fail("pubspec.yaml sürüm satırı okunamadı.")

major, minor, patch, build = map(int, match.groups())
new_version = f"{major}.{minor + 1}.0+{build + 1}"
display_version = f"{major}.{minor + 1}.0"

pubspec_text = re.sub(
    r"^version:\s*.*$",
    f"version: {new_version}",
    pubspec_text,
    count=1,
    flags=re.MULTILINE,
)

main_text, count = re.subn(
    r"Bilgi Rotası • Sürüm \d+\.\d+(?:\.\d+)?",
    f"Bilgi Rotası • Sürüm {display_version}",
    main_text,
    count=1,
)
if count != 1:
    fail("Ana menü sürüm yazısı güncellenemedi.")

backup = Path("/tmp/bilgi_rotasi_bes_tur_yedek")
backup.mkdir(parents=True, exist_ok=True)
for source in (MAIN, QUALITY, QUESTIONS, PUBSPEC):
    shutil.copy2(source, backup / source.name)

try:
    MAIN.write_text(main_text, encoding="utf-8")
    QUALITY.write_text(quality_text, encoding="utf-8")
    QUESTIONS.write_text(
        json.dumps(questions, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    PUBSPEC.write_text(pubspec_text, encoding="utf-8")

    verified = json.loads(QUESTIONS.read_text(encoding="utf-8"))
    by_id = {
        str(item.get("id", "")): item
        for item in verified
        if isinstance(item, dict)
    }
    for items in rare_by_topic.values():
        for item in items:
            if by_id.get(item["id"], {}).get("difficulty") != "Zor":
                fail(f"{item['id']} Zor olarak doğrulanamadı.")

    if shutil.which("dart"):
        run(["dart", "format", "lib/main.dart", "lib/question_quality.dart"])

    run(["git", "diff", "--check"])

    if shutil.which("flutter"):
        run(["flutter", "analyze", "--no-fatal-infos"])
        if Path("test").exists():
            run(["flutter", "test"])

except Exception:
    shutil.copy2(backup / MAIN.name, MAIN)
    shutil.copy2(backup / QUALITY.name, QUALITY)
    shutil.copy2(backup / QUESTIONS.name, QUESTIONS)
    shutil.copy2(backup / PUBSPEC.name, PUBSPEC)
    print("\n❌ Hata oluştu; dosyalar eski hâline döndürüldü.\n")
    raise

run(
    [
        "git",
        "add",
        "lib/main.dart",
        "lib/question_quality.dart",
        "assets/questions.json",
        "reports/repetitive_question_families_v2.txt",
        "pubspec.yaml",
    ]
)

if subprocess.run(
    ["git", "diff", "--cached", "--quiet"],
    check=False,
).returncode == 0:
    fail("Commit edilecek değişiklik bulunamadı.")

run(["git", "commit", "-m", "Bes tekrar eden soru turunu duzenle"])
run(["git", "push", "origin", "main"])

print("")
print("✅ Beş soru türü tek pakette düzenlendi.")
print(
    "✅ Sıcaklık dönüşümü: "
    f"{len(rare_by_topic[TOPIC_TEMPERATURE])}"
)
print(
    "✅ Nota/vuruş hesabı: "
    f"{len(rare_by_topic[TOPIC_MUSIC])}"
)
print(
    "✅ İdari bölüm/ülke: "
    f"{len(rare_by_topic[TOPIC_ADMIN])}"
)
print(
    "✅ Harf sayma tamamen elendi: "
    f"{len(filtered_by_type[FILTER_LETTER])}"
)
print(
    "✅ Sıcaklık farkı matematiği tamamen elendi: "
    f"{len(filtered_by_type[FILTER_TEMP_DIFF])}"
)
print("✅ Büyük soru aileleri artık seçim şansını şişirmeyecek.")
print(f"✅ Yeni sürüm: {new_version}")
print("✅ Değişiklikler GitHub'a gönderildi.")
print(f"📄 Rapor: {REPORT}")
