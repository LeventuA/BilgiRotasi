#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import os
import re
import shutil
import subprocess
import tempfile
from pathlib import Path


BASE_VERSION = "1.48.2+66"
NEW_VERSION = "1.48.3+67"
NEW_VERSION_NAME = "1.48.3"
NEW_BUILD_NUMBER = 67

SHORT_MODE = Path("lib/short_challenge_mode.dart")
MAIN_NAV = Path("lib/main_navigation.dart")
BUILD_INFO = Path("lib/app_build_info.dart")
PUBSPEC = Path("pubspec.yaml")
SYSTEM_TEST = Path("test/system_smoke_test.dart")
CHALLENGE_TEST = Path("test/short_challenge_mode_test.dart")
RC_TEST = Path("test/rc1_quality_gate_test.dart")
QUALITY = Path("tools/rc1_quality_gate.py")
WORKFLOW = Path(".github/workflows/android-apk.yml")
CHECKLIST = Path("reports/RC1_MANUAL_TEST_CHECKLIST.md")
QUESTIONS = Path("assets/questions.json")

TEXT_TARGETS = [
    SHORT_MODE,
    MAIN_NAV,
    BUILD_INFO,
    PUBSPEC,
    SYSTEM_TEST,
    RC_TEST,
    QUALITY,
    WORKFLOW,
    CHECKLIST,
]
INTENDED_TARGETS = [*TEXT_TARGETS, CHALLENGE_TEST]

INSTALLER_NAMES = {
    "BilgiRotasi_Meydan_Okuma_10_20_30_Kurulum.py",
    "BilgiRotasi_Meydan_Okuma_10_20_30_Kurulum_V2.py",
}


class InstallError(RuntimeError):
    pass


def run(
    args: list[str],
    *,
    cwd: Path,
    check: bool = True,
    capture: bool = True,
    env: dict[str, str] | None = None,
) -> subprocess.CompletedProcess[str]:
    print("$ " + " ".join(args))
    completed = subprocess.run(
        args,
        cwd=cwd,
        check=False,
        text=True,
        capture_output=capture,
        env=env,
    )
    if check and completed.returncode != 0:
        detail = (completed.stderr or completed.stdout or "").strip()
        raise InstallError(
            f"Komut başarısız: {' '.join(args)}\n{detail}"
        )
    return completed


def locate_repo() -> Path:
    candidates = [Path.cwd(), Path("/workspaces/BilgiRotasi")]
    for candidate in candidates:
        if not candidate.exists():
            continue
        result = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            cwd=candidate,
            check=False,
            text=True,
            capture_output=True,
        )
        if result.returncode == 0:
            return Path(result.stdout.strip())

    raise InstallError(
        "BilgiRotasi Git deposu bulunamadı. "
        "Dosyayı /workspaces/BilgiRotasi içinde çalıştır."
    )


def sha256(path: Path) -> str | None:
    if not path.exists():
        return None

    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def replace_once(
    text: str,
    old: str,
    new: str,
    *,
    label: str,
) -> str:
    count = text.count(old)
    if count != 1:
        raise InstallError(
            f"{label} için beklenen bölüm bulunamadı. "
            f"Eşleşme sayısı: {count}"
        )
    return text.replace(old, new, 1)


def regex_once(
    text: str,
    pattern: str,
    replacement: str,
    *,
    label: str,
    flags: int = 0,
) -> str:
    updated, count = re.subn(
        pattern,
        lambda _match: replacement,
        text,
        count=1,
        flags=flags,
    )
    if count != 1:
        raise InstallError(
            f"{label} için beklenen bölüm bulunamadı. "
            f"Eşleşme sayısı: {count}"
        )
    return updated


def backup_targets(
    repo: Path,
    backup: Path,
) -> dict[Path, bool]:
    existed: dict[Path, bool] = {}
    for relative in INTENDED_TARGETS:
        source = repo / relative
        existed[relative] = source.exists()
        if source.exists():
            destination = backup / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, destination)
    return existed


def restore_targets(
    repo: Path,
    backup: Path,
    existed: dict[Path, bool],
) -> None:
    for relative in INTENDED_TARGETS:
        destination = repo / relative
        if existed.get(relative, False):
            source = backup / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, destination)
        elif destination.exists():
            destination.unlink()


NEW_SERVICE = r"""class ShortChallengeCodeService {
  ShortChallengeCodeService._();

  static const int questionCount = 10;
  static const int targetScore = 7;
  static const List<int> questionCountOptions = <int>[10, 20, 30];

  static String generate([Random? random]) {
    return generateForCount(questionCount, random);
  }

  static String generateForCount(
    int count, [
    Random? random,
  ]) {
    if (!questionCountOptions.contains(count)) {
      throw const FormatException(
        'Meydan okuma soru sayısı 10, 20 veya 30 olmalı.',
      );
    }

    final source = random ?? Random.secure();
    final marker = count ~/ 10;
    final suffix = source.nextInt(1000).toString().padLeft(3, '0');
    return 'BR$marker$suffix';
  }

  static String normalize(String raw) {
    var cleaned = raw
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]'), '');

    if (RegExp(r'^\d{4}$').hasMatch(cleaned)) {
      cleaned = 'BR$cleaned';
    }

    if (!RegExp(r'^BR\d{4}$').hasMatch(cleaned)) {
      throw const FormatException(
        'Kod BR1905 gibi BR ve dört rakamdan oluşmalı.',
      );
    }

    return cleaned;
  }

  static bool isValid(String raw) {
    try {
      normalize(raw);
      return true;
    } on FormatException {
      return false;
    }
  }

  static int questionCountForCode(String rawCode) {
    final code = normalize(rawCode);
    final marker = int.parse(code.substring(2, 3));

    return switch (marker) {
      2 => 20,
      3 => 30,
      _ => 10,
    };
  }

  static int targetScoreForCount(int count) {
    return switch (count) {
      10 => 7,
      20 => 14,
      30 => 21,
      _ => throw const FormatException(
          'Meydan okuma soru sayısı desteklenmiyor.',
        ),
    };
  }

  static int targetScoreForCode(String rawCode) {
    return targetScoreForCount(
      questionCountForCode(rawCode),
    );
  }

  static int stableHash(String value) {
    var hash = 0x811C9DC5;

    for (final byte in utf8.encode(value)) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }

    return hash;
  }

  static List<QuizQuestion> selectQuestions(
    QuestionBank questionBank,
    String rawCode,
  ) {
    final code = normalize(rawCode);
    final count = questionCountForCode(code);
    final questions = questionBank.questionsByCategory.values
        .expand((items) => items)
        .toList(growable: false);

    final ranked = List<QuizQuestion>.from(questions)
      ..sort((a, b) {
        final aHash = stableHash('$code|${a.id}');
        final bHash = stableHash('$code|${b.id}');
        final hashOrder = aHash.compareTo(bHash);

        if (hashOrder != 0) return hashOrder;
        return a.id.compareTo(b.id);
      });

    return ranked.take(count).toList(growable: false);
  }

  static ChallengeConfig buildConfig({
    required QuestionBank questionBank,
    required String rawCode,
    required String challengerName,
  }) {
    final code = normalize(rawCode);
    final count = questionCountForCode(code);
    final questions = selectQuestions(questionBank, code);

    if (questions.length < count) {
      throw const FormatException(
        'Meydan okuma için yeterli soru bulunamadı.',
      );
    }

    final cleanName = challengerName.trim();

    return ChallengeConfig(
      challengerName: cleanName.isEmpty ? 'Bir oyuncu' : cleanName,
      targetScore: targetScoreForCount(count),
      categoryIndex: -1,
      difficulty: 'Karışık',
      questionIds: questions
          .map((question) => question.id)
          .toList(growable: false),
      shortCode: code,
    );
  }
}"""


def patch_short_mode(text: str) -> str:
    text = regex_once(
        text,
        r"class ShortChallengeCodeService \{.*?\n\}\n\n"
        r"class ShortChallengeModeScreen",
        NEW_SERVICE + "\n\nclass ShortChallengeModeScreen",
        label="meydan okuma kod servisi",
        flags=re.DOTALL,
    )

    text = replace_once(
        text,
        """  late String _generatedCode;
  final TextEditingController _joinController =
      TextEditingController();
""",
        """  late String _generatedCode;
  int _selectedQuestionCount =
      ShortChallengeCodeService.questionCount;
  final TextEditingController _joinController =
      TextEditingController();
""",
        label="seçili soru sayısı durumu",
    )

    text = replace_once(
        text,
        """  @override
  void initState() {
    super.initState();
    _generatedCode = ShortChallengeCodeService.generate();
  }
""",
        """  @override
  void initState() {
    super.initState();
    _generatedCode =
        ShortChallengeCodeService.generateForCount(
      _selectedQuestionCount,
    );
  }
""",
        label="başlangıç kısa kodu",
    )

    text = replace_once(
        text,
        """              const Text(
                'Aynı kısa kod, aynı APK sürümünde iki telefonda da '
                'aynı 10 soruyu aynı sırayla açar. Hedef skor 7 doğrudur.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFD8CCEA),
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
""",
        """              const Text(
                'Soru sayısı ve hedef kısa kodun içinde saklanır. '
                'Karşı telefonda yalnızca kodu girmek yeterlidir. '
                'Seçenekler: 10/7, 20/14 ve 30/21.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFD8CCEA),
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
""",
        label="meydan okuma açıklaması",
    )

    text = replace_once(
        text,
        """          Text(
            'Meydan okuyan: $_playerName',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 15),
          Container(
""",
        """          Text(
            'Meydan okuyan: $_playerName',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Soru sayısı ve hedef',
            style: TextStyle(
              color: Color(0xFF334155),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final count
                  in ShortChallengeCodeService.questionCountOptions)
                ChoiceChip(
                  label: Text(
                    '$count soru • Hedef '
                    '${ShortChallengeCodeService.targetScoreForCount(count)}',
                  ),
                  selected: _selectedQuestionCount == count,
                  onSelected: (_) => _selectQuestionCount(count),
                  selectedColor: const Color(0xFFD8B4FE),
                  side: BorderSide(
                    color: _selectedQuestionCount == count
                        ? const Color(0xFF7C3AED)
                        : const Color(0xFFCBD5E1),
                  ),
                  labelStyle: TextStyle(
                    color: _selectedQuestionCount == count
                        ? const Color(0xFF4C1D95)
                        : const Color(0xFF475569),
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
""",
        label="10 20 30 soru seçici",
    )

    text = replace_once(
        text,
        """          const SizedBox(height: 11),
          Row(
""",
        """          const SizedBox(height: 8),
          Text(
            '$_selectedQuestionCount karışık soru • Hedef '
            '${ShortChallengeCodeService.targetScoreForCount(_selectedQuestionCount)} '
            'doğru',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 11),
          Row(
""",
        label="seçilen meydan okuma özeti",
    )

    text = replace_once(
        text,
        """  void _newCode() {
    setState(() {
      _generatedCode = ShortChallengeCodeService.generate();
      _error = null;
    });
    GameHaptics.selectionClick();
  }
""",
        """  void _selectQuestionCount(int value) {
    if (_selectedQuestionCount == value) return;

    setState(() {
      _selectedQuestionCount = value;
      _generatedCode =
          ShortChallengeCodeService.generateForCount(value);
      _error = null;
    });
    GameHaptics.selectionClick();
  }

  void _newCode() {
    setState(() {
      _generatedCode =
          ShortChallengeCodeService.generateForCount(
        _selectedQuestionCount,
      );
      _error = null;
    });
    GameHaptics.selectionClick();
  }
""",
        label="soru sayısı seçim işlemi",
    )

    text = replace_once(
        text,
        """        'Kod: $_generatedCode',
        '10 karışık soru • Hedef 7 doğru',
""",
        """        'Kod: $_generatedCode',
        '$_selectedQuestionCount karışık soru • Hedef '
            '${ShortChallengeCodeService.targetScoreForCount(_selectedQuestionCount)} '
            'doğru',
""",
        label="dinamik paylaşım metni",
    )

    start_pattern = (
        r"  void _start\(\n"
        r"    String rawCode, \{\n"
        r"    required String challengerName,\n"
        r"  \}\) \{.*?\n"
        r"  \}\n\}"
    )
    new_start = r"""  void _start(
    String rawCode, {
    required String challengerName,
  }) {
    try {
      final code = ShortChallengeCodeService.normalize(rawCode);
      final questionCount =
          ShortChallengeCodeService.questionCountForCode(code);
      final targetScore =
          ShortChallengeCodeService.targetScoreForCount(
        questionCount,
      );
      final questions = ShortChallengeCodeService.selectQuestions(
        widget.questionBank,
        code,
      );

      if (questions.length < questionCount) {
        throw const FormatException(
          'Bu sürümde meydan okuma için yeterli soru yok.',
        );
      }

      final challenge = ChallengeConfig(
        challengerName: challengerName,
        targetScore: targetScore,
        categoryIndex: -1,
        difficulty: 'Karışık',
        questionIds: questions
            .map((question) => question.id)
            .toList(growable: false),
        shortCode: code,
      );

      setState(() => _error = null);
      GameHaptics.mediumImpact();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChallengeGameScreen(
            questionBank: widget.questionBank,
            challenge: challenge,
            questions: questions,
          ),
        ),
      );
    } on FormatException catch (error) {
      setState(() {
        _error = error.message.toString();
      });
    } catch (_) {
      setState(() {
        _error = 'Kod açılamadı. BR1905 biçimini kontrol et.';
      });
    }
  }
}"""
    text = regex_once(
        text,
        start_pattern,
        new_start,
        label="dinamik meydan okuma başlatma",
        flags=re.DOTALL,
    )

    return text


def patch_main_navigation(text: str) -> str:
    return replace_once(
        text,
        """              'BR1905 gibi otomatik kısa kod üret; başka telefonda '
              'aynı 10 soruda 7 doğru hedefiyle yarış.',
""",
        """              'BR1905 gibi otomatik kısa kod üret; başka telefonda '
              '10, 20 veya 30 soruluk hedeflerde yarış.',
""",
        label="Oyna merkezi meydan okuma açıklaması",
    )


def patch_system_test(text: str) -> str:
    old = """    test('Kısa meydan okuma kodu kararlı ve okunabilirdir', () {
      expect(
        ShortChallengeCodeService.normalize('br-1905'),
        'BR1905',
      );
      expect(
        ShortChallengeCodeService.normalize('1905'),
        'BR1905',
      );
      expect(
        ShortChallengeCodeService.isValid('BR1905'),
        isTrue,
      );
      expect(
        ShortChallengeCodeService.isValid('BR19'),
        isFalse,
      );
      expect(
        ShortChallengeCodeService.stableHash('BR1905'),
        ShortChallengeCodeService.stableHash('BR1905'),
      );
      expect(ShortChallengeCodeService.questionCount, 10);
      expect(ShortChallengeCodeService.targetScore, 7);
    });
"""
    new = """    test('Kısa meydan okuma kodu 10 20 30 soruyu taşır', () {
      expect(
        ShortChallengeCodeService.normalize('br-1905'),
        'BR1905',
      );
      expect(
        ShortChallengeCodeService.normalize('2905'),
        'BR2905',
      );
      expect(
        ShortChallengeCodeService.isValid('BR3905'),
        isTrue,
      );
      expect(
        ShortChallengeCodeService.isValid('BR19'),
        isFalse,
      );
      expect(
        ShortChallengeCodeService.stableHash('BR1905'),
        ShortChallengeCodeService.stableHash('BR1905'),
      );
      expect(
        ShortChallengeCodeService.questionCountOptions,
        <int>[10, 20, 30],
      );
      expect(
        ShortChallengeCodeService.questionCountForCode('BR1905'),
        10,
      );
      expect(
        ShortChallengeCodeService.questionCountForCode('BR2905'),
        20,
      );
      expect(
        ShortChallengeCodeService.questionCountForCode('BR3905'),
        30,
      );
      expect(
        ShortChallengeCodeService.targetScoreForCode('BR1905'),
        7,
      );
      expect(
        ShortChallengeCodeService.targetScoreForCode('BR2905'),
        14,
      );
      expect(
        ShortChallengeCodeService.targetScoreForCode('BR3905'),
        21,
      );
      expect(ShortChallengeCodeService.questionCount, 10);
      expect(ShortChallengeCodeService.targetScore, 7);
    });
"""
    return replace_once(
        text,
        old,
        new,
        label="meydan okuma sistem testi",
    )


CHALLENGE_TEST_CONTENT = """import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Seçilebilir kısa meydan okuma', () {
    late QuestionBank questionBank;

    setUpAll(() {
      final grouped = <int, List<QuizQuestion>>{};

      for (var index = 0; index < 72; index++) {
        final category = index % 6;
        grouped.putIfAbsent(category, () => <QuizQuestion>[]).add(
              QuizQuestion(
                id: 'challenge_test_${index.toString().padLeft(3, '0')}',
                categoryIndex: category,
                text: 'Test sorusu $index',
                options: const <String>['A', 'B', 'C', 'D'],
                answerIndex: index % 4,
                difficulty: 'Orta',
                explanation: 'Test açıklaması.',
              ),
            );
      }

      questionBank = QuestionBank(grouped);
    });

    test('kod seçilen soru sayısını ve hedefi taşır', () {
      final cases = <String, (int, int)>{
        'BR1905': (10, 7),
        'BR2905': (20, 14),
        'BR3905': (30, 21),
      };

      for (final entry in cases.entries) {
        expect(
          ShortChallengeCodeService.questionCountForCode(entry.key),
          entry.value.$1,
        );
        expect(
          ShortChallengeCodeService.targetScoreForCode(entry.key),
          entry.value.$2,
        );
      }
    });

    test('üretilen kısa kod soru sayısını korur', () {
      for (final count
          in ShortChallengeCodeService.questionCountOptions) {
        final code =
            ShortChallengeCodeService.generateForCount(count);

        expect(
          ShortChallengeCodeService.questionCountForCode(code),
          count,
        );
      }
    });

    test('aynı kod aynı soruları aynı sırayla seçer', () {
      for (final code in <String>['BR1905', 'BR2905', 'BR3905']) {
        final first = ShortChallengeCodeService.selectQuestions(
          questionBank,
          code,
        );
        final second = ShortChallengeCodeService.selectQuestions(
          questionBank,
          code,
        );
        final count =
            ShortChallengeCodeService.questionCountForCode(code);

        expect(first.length, count);
        expect(
          first.map((item) => item.id).toList(),
          second.map((item) => item.id).toList(),
        );
        expect(
          first.map((item) => item.id).toSet().length,
          count,
        );
      }
    });

    test('meydan okuma yapılandırması dinamik hedef üretir', () {
      for (final code in <String>['BR1905', 'BR2905', 'BR3905']) {
        final config = ShortChallengeCodeService.buildConfig(
          questionBank: questionBank,
          rawCode: code,
          challengerName: 'Test Oyuncusu',
        );
        final count =
            ShortChallengeCodeService.questionCountForCode(code);

        expect(config.code, code);
        expect(config.questionIds.length, count);
        expect(
          config.targetScore,
          ShortChallengeCodeService.targetScoreForCount(count),
        );
      }
    });
  });
}
"""


def patch_versions(
    contents: dict[Path, str],
) -> dict[Path, str]:
    contents[PUBSPEC] = replace_once(
        contents[PUBSPEC],
        "version: 1.48.2+66",
        "version: 1.48.3+67",
        label="pubspec sürümü",
    )

    build = contents[BUILD_INFO]
    build = replace_once(
        build,
        "  static const String versionName = '1.48.2';",
        "  static const String versionName = '1.48.3';",
        label="uygulama sürüm adı",
    )
    build = replace_once(
        build,
        "  static const int buildNumber = 66;",
        "  static const int buildNumber = 67;",
        label="uygulama yapı numarası",
    )
    contents[BUILD_INFO] = build

    rc = contents[RC_TEST]
    rc = replace_once(
        rc,
        "expect(AppBuildInfo.versionName, '1.48.2');",
        "expect(AppBuildInfo.versionName, '1.48.3');",
        label="RC2 sürüm testi",
    )
    rc = replace_once(
        rc,
        "expect(AppBuildInfo.buildNumber, 66);",
        "expect(AppBuildInfo.buildNumber, 67);",
        label="RC2 yapı numarası testi",
    )
    rc = replace_once(
        rc,
        "expect(AppBuildInfo.version, '1.48.2+66');",
        "expect(AppBuildInfo.version, '1.48.3+67');",
        label="RC2 tam sürüm testi",
    )
    rc = replace_once(
        rc,
        "'Sürüm 1.48.2+66 • RC2'",
        "'Sürüm 1.48.3+67 • RC2'",
        label="RC2 sürüm etiketi testi",
    )
    contents[RC_TEST] = rc

    contents[QUALITY] = replace_once(
        contents[QUALITY],
        'EXPECTED_VERSION = "1.48.2+66"',
        'EXPECTED_VERSION = "1.48.3+67"',
        label="kalite kapısı sürümü",
    )

    workflow = contents[WORKFLOW]
    if workflow.count("1.48.2+66") < 1:
        raise InstallError(
            "Workflow içinde 1.48.2+66 sürümü bulunamadı."
        )
    if workflow.count("1.48.2-66") < 1:
        raise InstallError(
            "Workflow paket adlarında 1.48.2-66 bulunamadı."
        )
    workflow = workflow.replace("1.48.2+66", "1.48.3+67")
    workflow = workflow.replace("1.48.2-66", "1.48.3-67")

    workflow = replace_once(
        workflow,
        """            lib/app_build_info.dart \\
            lib/account_cloud.dart \\
""",
        """            lib/app_build_info.dart \\
            lib/short_challenge_mode.dart \\
            lib/main_navigation.dart \\
            lib/account_cloud.dart \\
""",
        label="workflow değişen Dart dosyaları",
    )
    workflow = replace_once(
        workflow,
        """            test/rc1_quality_gate_test.dart \\
            test/account_cloud_policy_test.dart \\
""",
        """            test/rc1_quality_gate_test.dart \\
            test/system_smoke_test.dart \\
            test/short_challenge_mode_test.dart \\
            test/account_cloud_policy_test.dart \\
""",
        label="workflow meydan okuma testleri",
    )
    contents[WORKFLOW] = workflow

    checklist = contents[CHECKLIST]
    checklist = checklist.replace(
        "1.48.2+66",
        "1.48.3+67",
    )
    checklist += """
## 8. Seçilebilir Meydan Okuma testi

- [ ] Yeni meydan okuma ekranında 10, 20 ve 30 soru seçenekleri göründü.
- [ ] 10 soru seçilince hedef 7 doğru olarak gösterildi.
- [ ] 20 soru seçilince hedef 14 doğru olarak gösterildi.
- [ ] 30 soru seçilince hedef 21 doğru olarak gösterildi.
- [ ] Soru sayısı değişince yeni kısa kod otomatik üretildi.
- [ ] Paylaşım metninde seçilen soru sayısı ve hedef doğru göründü.
- [ ] İkinci telefonda yalnızca kod girilince soru sayısı otomatik çözüldü.
- [ ] Aynı kod iki telefonda aynı soruları aynı sırayla açtı.
"""
    contents[CHECKLIST] = checklist

    return contents


def validate_patched(
    contents: dict[Path, str],
) -> None:
    markers: dict[Path, list[str]] = {
        SHORT_MODE: [
            "questionCountOptions = <int>[10, 20, 30]",
            "generateForCount",
            "questionCountForCode",
            "targetScoreForCount",
            "10/7, 20/14 ve 30/21",
            "ChoiceChip",
            "_selectQuestionCount",
        ],
        MAIN_NAV: [
            "10, 20 veya 30 soruluk hedeflerde yarış",
        ],
        BUILD_INFO: [
            "versionName = '1.48.3'",
            "buildNumber = 67",
        ],
        PUBSPEC: ["version: 1.48.3+67"],
        SYSTEM_TEST: [
            "Kısa meydan okuma kodu 10 20 30 soruyu taşır",
            "targetScoreForCode('BR3905')",
        ],
        RC_TEST: [
            "AppBuildInfo.versionName, '1.48.3'",
            "AppBuildInfo.buildNumber, 67",
        ],
        QUALITY: ['EXPECTED_VERSION = "1.48.3+67"'],
        WORKFLOW: [
            "BilgiRotasi-1.48.3-67-signed.apk",
            "BilgiRotasi-1.48.3-67-signed.aab",
            "BilgiRotasi-Signed-RC2-1.48.3-67",
            "test/short_challenge_mode_test.dart",
        ],
        CHECKLIST: [
            "1.48.3+67 • RC2",
            "Seçilebilir Meydan Okuma testi",
        ],
    }

    for file_path, expected in markers.items():
        for marker in expected:
            if marker not in contents[file_path]:
                raise InstallError(
                    f"Kurulum doğrulaması başarısız: "
                    f"{file_path} / {marker}"
                )

    for marker in [
        "kod seçilen soru sayısını ve hedefi taşır",
        "aynı kod aynı soruları aynı sırayla seçer",
        "meydan okuma yapılandırması dinamik hedef üretir",
    ]:
        if marker not in CHALLENGE_TEST_CONTENT:
            raise InstallError(
                "Meydan okuma test dosyası doğrulanamadı: "
                + marker
            )


def main() -> int:
    repo = locate_repo()

    branch = run(
        ["git", "branch", "--show-current"],
        cwd=repo,
    ).stdout.strip()
    if branch != "main":
        raise InstallError(
            f"Kurulum main dalında çalışmalıdır. "
            f"Mevcut dal: {branch or '(yok)'}"
        )

    required = [*TEXT_TARGETS, QUESTIONS]
    missing = [
        str(relative)
        for relative in required
        if not (repo / relative).is_file()
    ]
    if missing:
        raise InstallError(
            "Gerekli proje dosyaları bulunamadı:\n"
            + "\n".join(missing)
        )

    protected_status = run(
        [
            "git",
            "status",
            "--porcelain",
            "--",
            *[str(path) for path in [*INTENDED_TARGETS, QUESTIONS]],
        ],
        cwd=repo,
    ).stdout.strip()
    if protected_status:
        raise InstallError(
            "Kurulumun değiştireceği dosyalarda yerel değişiklik var:\n"
            + protected_status
            + "\nÖnce bu değişiklikleri commit et."
        )

    run(["git", "fetch", "origin", "main"], cwd=repo)
    divergence = run(
        [
            "git",
            "rev-list",
            "--left-right",
            "--count",
            "HEAD...origin/main",
        ],
        cwd=repo,
    ).stdout.strip().split()

    if len(divergence) != 2:
        raise InstallError("Git dal durumu okunamadı.")

    ahead, behind = map(int, divergence)
    if ahead > 0:
        raise InstallError(
            "GitHub'a gönderilmemiş yerel commit var. "
            "Önce git push origin main çalıştır."
        )
    if behind > 0:
        run(
            ["git", "pull", "--ff-only", "origin", "main"],
            cwd=repo,
            capture=False,
        )

    unrelated = run(
        ["git", "status", "--porcelain"],
        cwd=repo,
    ).stdout.splitlines()
    visible_unrelated = [
        line
        for line in unrelated
        if not any(name in line for name in INSTALLER_NAMES)
    ]
    if visible_unrelated:
        print("ℹ️ İlgisiz yerel değişiklikler korunacak:")
        for line in visible_unrelated:
            print("   " + line)

    question_hash_before = sha256(repo / QUESTIONS)
    contents = {
        path: (repo / path).read_text(encoding="utf-8")
        for path in TEXT_TARGETS
    }

    version_match = re.search(
        r"(?m)^version:\s*([^\s]+)\s*$",
        contents[PUBSPEC],
    )
    current_version = version_match.group(1) if version_match else "?"
    if current_version != BASE_VERSION:
        raise InstallError(
            f"Bu paket {BASE_VERSION} sürümü için hazırlandı. "
            f"Depodaki sürüm: {current_version}"
        )

    if "questionCountOptions = <int>[10, 20, 30]" in contents[SHORT_MODE]:
        raise InstallError(
            "10/20/30 soruluk meydan okuma sistemi zaten kurulu."
        )

    if (repo / CHALLENGE_TEST).exists():
        raise InstallError(
            f"{CHALLENGE_TEST} zaten var; beklenmeyen bir durum oluştu."
        )

    # Tüm eşleşmeleri dosyalara yazmadan önce hazırla ve doğrula.
    contents[SHORT_MODE] = patch_short_mode(contents[SHORT_MODE])
    contents[MAIN_NAV] = patch_main_navigation(contents[MAIN_NAV])
    contents[SYSTEM_TEST] = patch_system_test(contents[SYSTEM_TEST])
    contents = patch_versions(contents)
    validate_patched(contents)

    backup = Path(
        tempfile.mkdtemp(prefix="bilgi_rotasi_meydan_okuma_")
    )
    existed = backup_targets(repo, backup)
    committed = False

    try:
        for relative, text in contents.items():
            destination = repo / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_text(
                text,
                encoding="utf-8",
                newline="\n",
            )

        (repo / CHALLENGE_TEST).write_text(
            CHALLENGE_TEST_CONTENT,
            encoding="utf-8",
            newline="\n",
        )

        if sha256(repo / QUESTIONS) != question_hash_before:
            raise InstallError(
                "Güvenlik kontrolü: assets/questions.json değişti."
            )

        dart_files = [
            str(SHORT_MODE),
            str(MAIN_NAV),
            str(BUILD_INFO),
            str(SYSTEM_TEST),
            str(CHALLENGE_TEST),
            str(RC_TEST),
        ]
        if shutil.which("dart"):
            run(
                ["dart", "format", *dart_files],
                cwd=repo,
                capture=False,
            )

        run(
            [
                "git",
                "diff",
                "--check",
                "--",
                *[str(path) for path in INTENDED_TARGETS],
            ],
            cwd=repo,
        )

        report = repo / ".git" / "RC2_CHALLENGE_QUALITY_REPORT.md"
        try:
            run(
                [
                    "python3",
                    str(QUALITY),
                    "--report",
                    ".git/RC2_CHALLENGE_QUALITY_REPORT.md",
                ],
                cwd=repo,
                capture=False,
            )
        finally:
            report.unlink(missing_ok=True)

        if shutil.which("flutter"):
            run(
                [
                    "flutter",
                    "analyze",
                    "--no-fatal-warnings",
                    "--no-fatal-infos",
                ],
                cwd=repo,
                capture=False,
            )
            run(
                ["flutter", "test"],
                cwd=repo,
                capture=False,
            )
        else:
            print(
                "ℹ️ Flutter bu ortamda bulunamadı; "
                "analiz ve test GitHub Actions'ta çalışacak."
            )

        if sha256(repo / QUESTIONS) != question_hash_before:
            raise InstallError(
                "Testlerden sonra soru dosyası değişmiş görünüyor."
            )

        run(
            [
                "git",
                "add",
                "--",
                *[str(path) for path in INTENDED_TARGETS],
            ],
            cwd=repo,
        )

        staged = sorted(
            line.strip()
            for line in run(
                ["git", "diff", "--cached", "--name-only"],
                cwd=repo,
            ).stdout.splitlines()
            if line.strip()
        )
        expected = sorted(str(path) for path in INTENDED_TARGETS)

        if staged != expected:
            raise InstallError(
                "Commit dosyaları beklenenle eşleşmedi.\n"
                f"Beklenen: {expected}\n"
                f"Bulunan: {staged}"
            )

        if str(QUESTIONS) in staged:
            raise InstallError(
                "Soru dosyası yanlışlıkla stage alanına girdi."
            )

        run(
            [
                "git",
                "commit",
                "-m",
                "Meydan okumaya 10 20 30 soru secenegi ekle",
            ],
            cwd=repo,
            capture=False,
        )
        committed = True

        push_env = os.environ.copy()
        push_env.pop("GH_TOKEN", None)
        push_env.pop("GITHUB_TOKEN", None)

        run(
            ["git", "push", "origin", "main"],
            cwd=repo,
            capture=False,
            env=push_env,
        )

        print()
        print("✅ MEYDAN OKUMA GÜNCELLEMESİ TAMAMLANDI")
        print("✅ 10 soru seçeneği: hedef 7 doğru.")
        print("✅ 20 soru seçeneği: hedef 14 doğru.")
        print("✅ 30 soru seçeneği: hedef 21 doğru.")
        print("✅ Soru sayısı ve hedef kısa kodun içine işlendi.")
        print("✅ Karşı telefonda yalnızca kodu girmek yeterli.")
        print("✅ Aynı kod aynı soruları aynı sırayla açıyor.")
        print("✅ assets/questions.json dosyasına dokunulmadı.")
        print("✅ Yeni sürüm: 1.48.3+67 • RC2")
        print("✅ Değişiklikler GitHub main dalına gönderildi.")
        return 0

    except Exception:
        if not committed:
            restore_targets(repo, backup, existed)
            run(
                [
                    "git",
                    "restore",
                    "--staged",
                    "--",
                    *[str(path) for path in INTENDED_TARGETS],
                ],
                cwd=repo,
                check=False,
            )
        raise
    finally:
        shutil.rmtree(backup, ignore_errors=True)


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except InstallError as error:
        print()
        print("❌ KURULUM DURDU")
        print(str(error))
        raise SystemExit(1)
    except Exception as error:
        print()
        print("❌ KURULUM BAŞARISIZ")
        print(f"{type(error).__name__}: {error}")
        print(
            "Commit oluştuysa yalnızca şu komutu çalıştır: "
            "env -u GH_TOKEN -u GITHUB_TOKEN git push origin main"
        )
        raise SystemExit(1)
