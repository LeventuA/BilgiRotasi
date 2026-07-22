#!/usr/bin/env python3
from pathlib import Path
from collections import Counter
import json
import re
import shutil
import subprocess

MAIN = Path("lib/main.dart")
QUALITY_PART = Path("lib/question_quality.dart")
DIFFICULTY_PART = Path("lib/difficulty_balance.dart")
QUESTIONS = Path("assets/questions.json")
PUBSPEC = Path("pubspec.yaml")
REPORT = Path("reports/question_quality_report.txt")


def fail(message: str) -> None:
    raise SystemExit(f"\n❌ {message}\n")


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        fail(
            f"{label} güvenli biçimde bulunamadı "
            f"(eşleşme sayısı: {count}).\n"
            "Repo başka bir güncelleme aldıysa bu çıktıyı ChatGPT'ye gönder."
        )
    return text.replace(old, new, 1)


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
    text = re.sub(r"[^a-z0-9]+", " ", text)
    return re.sub(r"\s+", " ", text).strip()


def quality_reasons(item: dict) -> list[str]:
    question = str(item.get("question", "")).strip()
    options = item.get("options")
    answer_index = item.get("answerIndex")

    if not isinstance(options, list) or len(options) != 4:
        return ["Geçersiz seçenek yapısı"]

    reasons: list[str] = []
    normalized_question = normalize(question)
    word_count = len(normalized_question.split())
    option_lengths = [len(str(option).strip()) for option in options]

    if (
        len(question) > 190
        or word_count > 32
        or max(option_lengths, default=0) > 90
        or sum(option_lengths) > 300
    ):
        reasons.append("Aşırı uzun soru veya seçenek")

    ordering_patterns = (
        "eskiden yeniye",
        "yeniden eskiye",
        "kronolojik",
        "dogru siralama",
        "hangi siralama",
        "sirasiyla diz",
        "siraya koy",
        "siralanmistir",
    )
    if any(pattern in normalized_question for pattern in ordering_patterns):
        reasons.append("Sıralama/kronoloji sorusu")

    matching_patterns = (
        "eslestirmesi hangisidir",
        "dogru eslestirme",
        "hangi eslestirme",
        "eslestirilmistir",
        "eslestiriniz",
        "eslestirilen",
    )
    if any(pattern in normalized_question for pattern in matching_patterns):
        reasons.append("Eşleştirme sorusu")

    vague_patterns = (
        "ile iliskilendirilen",
        "ile iliskilidir",
        "en cok iliskilendirilen",
        "dogru kisi taraf veya gelisme",
        "dogru tur ya da sanat bicimi",
        "dogru tarih veya donem",
        "dogru yer eslestirmesi",
        "dogru yayin yili eslestirmesi",
        "karakteri hangi filmde yer alir",
        "karakteri hangi filmde gorulur",
    )
    if any(pattern in normalized_question for pattern in vague_patterns):
        reasons.append("Belirsiz/yapay soru kalıbı")

    if (
        question.count(",") >= 3
        and (
            "arasindan hangisi" in normalized_question
            or "hangisi ile" in normalized_question
            or "hangisi asagidakilerden" in normalized_question
        )
    ):
        reasons.append("Birleşik ve çok parçalı soru")

    if isinstance(answer_index, int) and 0 <= answer_index < len(options):
        answer = normalize(options[answer_index])
        if len(answer) >= 3:
            answer_pattern = rf"(?:^| ){re.escape(answer)}(?: |$)"
            if re.search(answer_pattern, normalized_question):
                reasons.append("Doğru cevap soru kökünde geçiyor")

    return list(dict.fromkeys(reasons))


for path in (MAIN, DIFFICULTY_PART, QUESTIONS, PUBSPEC):
    if not path.exists():
        fail(
            f"Gerekli dosya bulunamadı: {path}\n"
            "Kurulum dosyasını BilgiRotasi deposunun ana klasöründe çalıştır."
        )

branch = subprocess.run(
    ["git", "branch", "--show-current"],
    check=True,
    capture_output=True,
    text=True,
).stdout.strip()

if branch != "main":
    fail(f"Bu paket main dalında çalıştırılmalı. Mevcut dal: {branch or 'bilinmiyor'}")

if subprocess.run(["git", "diff", "--quiet"], check=False).returncode != 0:
    fail(
        "Repoda commit edilmemiş değişiklik var.\n"
        "Önce mevcut çalışmayı commit et veya temizle, sonra paketi yeniden çalıştır."
    )

main = MAIN.read_text(encoding="utf-8")
pubspec = PUBSPEC.read_text(encoding="utf-8")

if "part 'difficulty_balance.dart';" not in main:
    fail("Zorluk Dengesi kurulumu bulunamadı. Önce 1.30 güncellemesi tamamlanmalı.")

if "part 'question_quality.dart';" in main or QUALITY_PART.exists():
    fail("Soru Kalite Filtresi bu repoda zaten kurulu görünüyor.")

quality_part_content = r'''part of 'main.dart';

class QuestionQualityGuard {
  QuestionQualityGuard._();

  static const int maxQuestionCharacters = 190;
  static const int maxQuestionWords = 32;
  static const int maxOptionCharacters = 90;
  static const int maxTotalOptionCharacters = 300;

  static int lastScannedCount = 0;
  static int lastExcludedCount = 0;
  static Map<String, int> lastReasonCounts = <String, int>{};

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('ç', 'c')
        .replaceAll('ğ', 'g')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ş', 's')
        .replaceAll('ü', 'u')
        .replaceAll('â', 'a')
        .replaceAll('î', 'i')
        .replaceAll('û', 'u')
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static List<String> reasons(QuizQuestion question) {
    final reasons = <String>[];
    final normalizedQuestion = _normalize(question.text);
    final wordCount = normalizedQuestion.isEmpty
        ? 0
        : normalizedQuestion.split(' ').length;
    final optionLengths = question.options
        .map((option) => option.trim().length)
        .toList(growable: false);

    if (question.text.trim().length > maxQuestionCharacters ||
        wordCount > maxQuestionWords ||
        optionLengths.any(
          (length) => length > maxOptionCharacters,
        ) ||
        optionLengths.fold<int>(
              0,
              (sum, length) => sum + length,
            ) >
            maxTotalOptionCharacters) {
      reasons.add('Aşırı uzun soru veya seçenek');
    }

    const orderingPatterns = <String>[
      'eskiden yeniye',
      'yeniden eskiye',
      'kronolojik',
      'dogru siralama',
      'hangi siralama',
      'sirasiyla diz',
      'siraya koy',
      'siralanmistir',
    ];

    if (orderingPatterns.any(normalizedQuestion.contains)) {
      reasons.add('Sıralama/kronoloji sorusu');
    }

    const matchingPatterns = <String>[
      'eslestirmesi hangisidir',
      'dogru eslestirme',
      'hangi eslestirme',
      'eslestirilmistir',
      'eslestiriniz',
      'eslestirilen',
    ];

    if (matchingPatterns.any(normalizedQuestion.contains)) {
      reasons.add('Eşleştirme sorusu');
    }

    const vaguePatterns = <String>[
      'ile iliskilendirilen',
      'ile iliskilidir',
      'en cok iliskilendirilen',
      'dogru kisi taraf veya gelisme',
      'dogru tur ya da sanat bicimi',
      'dogru tarih veya donem',
      'dogru yer eslestirmesi',
      'dogru yayin yili eslestirmesi',
      'karakteri hangi filmde yer alir',
      'karakteri hangi filmde gorulur',
    ];

    if (vaguePatterns.any(normalizedQuestion.contains)) {
      reasons.add('Belirsiz/yapay soru kalıbı');
    }

    final commaCount = ','.allMatches(question.text).length;
    if (commaCount >= 3 &&
        (normalizedQuestion.contains('arasindan hangisi') ||
            normalizedQuestion.contains('hangisi ile') ||
            normalizedQuestion.contains(
              'hangisi asagidakilerden',
            ))) {
      reasons.add('Birleşik ve çok parçalı soru');
    }

    if (question.answerIndex >= 0 &&
        question.answerIndex < question.options.length) {
      final answer = _normalize(
        question.options[question.answerIndex],
      );

      if (answer.length >= 3) {
        final answerPattern = RegExp(
          '(?:^| )${RegExp.escape(answer)}(?: |\$)',
        );

        if (answerPattern.hasMatch(normalizedQuestion)) {
          reasons.add('Doğru cevap soru kökünde geçiyor');
        }
      }
    }

    return reasons.toSet().toList(growable: false);
  }

  static bool isPlayable(QuizQuestion question) {
    return reasons(question).isEmpty;
  }

  static void updateLastScan(
    List<QuizQuestion> allQuestions,
  ) {
    lastScannedCount = allQuestions.length;
    final counts = <String, int>{};
    var excluded = 0;

    for (final question in allQuestions) {
      final issues = reasons(question);
      if (issues.isEmpty) continue;

      excluded++;
      for (final issue in issues) {
        counts[issue] = (counts[issue] ?? 0) + 1;
      }
    }

    lastExcludedCount = excluded;
    lastReasonCounts = Map<String, int>.unmodifiable(counts);
  }

  static String get summary {
    final playable = max(
      0,
      lastScannedCount - lastExcludedCount,
    );

    return '$playable uygun • $lastExcludedCount elendi';
  }
}
'''
QUALITY_PART.write_text(quality_part_content, encoding="utf-8")

main = replace_once(
    main,
    "part 'difficulty_balance.dart';",
    "part 'difficulty_balance.dart';\npart 'question_quality.dart';",
    "Kalite filtresi part bağlantısı",
)

main = replace_once(
    main,
    '''    final questions = decoded
        .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
        .toList();

    final grouped = <int, List<QuizQuestion>>{};''',
    '''    final allQuestions = decoded
        .map(
          (item) =>
              QuizQuestion.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    QuestionQualityGuard.updateLastScan(allQuestions);

    final questions = allQuestions
        .where(QuestionQualityGuard.isPlayable)
        .toList(growable: false);

    debugPrint(
      'Soru kalite taraması: '
      '${QuestionQualityGuard.summary}',
    );

    final grouped = <int, List<QuizQuestion>>{};''',
    "QuestionBank kalite filtresi",
)

screen_start = main.find("class QuestionScreen extends StatefulWidget")
screen_end = main.find("  Widget _buildJokerPanel(", screen_start)
if screen_start < 0 or screen_end < 0:
    fail("QuestionScreen bölümü bulunamadı.")

before_screen = main[:screen_start]
screen = main[screen_start:screen_end]
after_screen = main[screen_end:]

screen = replace_once(
    screen,
    '''        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(18, 8, 18, 20),
            child: Column(''',
    '''        body: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.fromLTRB(18, 8, 18, 20),
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(''',
    "Soru ekranı ana kaydırma alanı",
)

screen = replace_once(
    screen,
    '''                Expanded(
                  child: ListView.separated(
                    itemCount:
                        _question.options.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _buildOption(index, category);
                    },
                  ),
                ),''',
    '''                ListView.separated(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount: _question.options.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _buildOption(index, category);
                  },
                ),''',
    "Soru seçenekleri kaydırma alanı",
)

main = before_screen + screen + after_screen

try:
    raw_questions = json.loads(QUESTIONS.read_text(encoding="utf-8"))
except Exception as error:
    fail(f"questions.json okunamadı: {error}")

if not isinstance(raw_questions, list):
    fail("assets/questions.json bir JSON listesi olmalı.")

flagged: list[tuple[str, str, str]] = []
reason_counts: Counter[str] = Counter()

for item in raw_questions:
    if not isinstance(item, dict):
        continue
    reasons = quality_reasons(item)
    for reason in reasons:
        reason_counts[reason] += 1
    if reasons:
        flagged.append(
            (
                str(item.get("id", "")),
                " | ".join(reasons),
                str(item.get("question", "")).replace("\n", " ").strip(),
            )
        )

REPORT.parent.mkdir(parents=True, exist_ok=True)
report_lines = [
    "BİLGİ ROTASI – SORU KALİTE TARAMASI",
    "=" * 72,
    "",
    f"Toplam soru: {len(raw_questions)}",
    f"Oyundan elenen soru: {len(flagged)}",
    f"Oyunda kalacak soru: {len(raw_questions) - len(flagged)}",
    "",
    "NEDENLERE GÖRE SAYILAR",
    "-" * 72,
]
for reason, count in reason_counts.most_common():
    report_lines.append(f"{reason}: {count}")

report_lines.extend(["", "ELENEN SORULAR", "-" * 72])
for question_id, reasons, question in flagged:
    report_lines.append(f"{question_id}\t{reasons}\t{question}")

REPORT.write_text(
    "\n".join(report_lines) + "\n",
    encoding="utf-8",
)

remaining_by_category: Counter[int] = Counter()
for item in raw_questions:
    if isinstance(item, dict) and not quality_reasons(item):
        category = item.get("categoryIndex")
        if isinstance(category, int):
            remaining_by_category[category] += 1

missing_categories = [
    str(index)
    for index in range(6)
    if remaining_by_category[index] < 20
]
if missing_categories:
    fail(
        "Kalite filtresi bazı kategorilerde 20'den az soru bıraktı: "
        + ", ".join(missing_categories)
    )

version_match = re.search(
    r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$",
    pubspec,
    flags=re.MULTILINE,
)
if not version_match:
    fail("pubspec.yaml sürüm satırı okunamadı.")

major, minor, patch, build = map(int, version_match.groups())
new_version = f"{major}.{minor + 1}.0+{build + 1}"
display_version = f"{major}.{minor + 1}.0"

pubspec = re.sub(
    r"^version:\s*.*$",
    f"version: {new_version}",
    pubspec,
    count=1,
    flags=re.MULTILINE,
)

main, display_count = re.subn(
    r"Bilgi Rotası • Sürüm \d+\.\d+(?:\.\d+)?",
    f"Bilgi Rotası • Sürüm {display_version}",
    main,
    count=1,
)
if display_count != 1:
    fail("Ana menü sürüm yazısı güncellenemedi.")

backup_dir = Path("/tmp/bilgi_rotasi_soru_kalite_yedek")
backup_dir.mkdir(parents=True, exist_ok=True)
shutil.copy2(MAIN, backup_dir / "main.dart")
shutil.copy2(PUBSPEC, backup_dir / "pubspec.yaml")

MAIN.write_text(main, encoding="utf-8")
PUBSPEC.write_text(pubspec, encoding="utf-8")

if shutil.which("dart"):
    subprocess.run(
        [
            "dart",
            "format",
            "lib/main.dart",
            "lib/question_quality.dart",
        ],
        check=True,
    )

subprocess.run(["git", "diff", "--check"], check=True)

if shutil.which("flutter"):
    subprocess.run(
        ["flutter", "analyze", "--no-fatal-infos"],
        check=True,
    )
    if Path("test").exists():
        subprocess.run(["flutter", "test"], check=True)

subprocess.run(
    [
        "git",
        "add",
        "lib/main.dart",
        "lib/question_quality.dart",
        "reports/question_quality_report.txt",
        "pubspec.yaml",
    ],
    check=True,
)

has_changes = subprocess.run(
    ["git", "diff", "--cached", "--quiet"],
    check=False,
).returncode != 0
if not has_changes:
    fail("Kurulum sonunda commit edilecek değişiklik bulunamadı.")

subprocess.run(
    [
        "git",
        "commit",
        "-m",
        "Sorulari kalite filtresinden gecir ve ekrani kaydir",
    ],
    check=True,
)
subprocess.run(["git", "push", "origin", "main"], check=True)

print("")
print("✅ Soru Kalite Filtresi kuruldu.")
print("✅ Sıralama ve kronoloji soruları oyundan elendi.")
print("✅ Eşleştirme ve yapay ilişkilendirme soruları oyundan elendi.")
print("✅ Aşırı uzun soru ve seçenekler oyundan elendi.")
print("✅ Cevabı soru kökünde bulunan sorular oyundan elendi.")
print("✅ Birleşik ve çok parçalı sorular oyundan elendi.")
print("✅ Soru ekranının tamamı kaydırılabilir hâle getirildi.")
print("✅ questions.json değiştirilmedi; elenenler rapora yazıldı.")
print(f"✅ Toplam elenen soru: {len(flagged)}")
print(f"✅ Oyunda kalan soru: {len(raw_questions) - len(flagged)}")
print(f"✅ Yeni sürüm: {new_version}")
print("✅ Değişiklikler GitHub'a gönderildi.")
print(f"📄 Rapor: {REPORT}")
print(f"ℹ️ Geçici yedek: {backup_dir}")
