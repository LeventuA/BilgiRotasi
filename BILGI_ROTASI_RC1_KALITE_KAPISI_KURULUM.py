#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import annotations

import re
import shutil
import subprocess
import sys
from pathlib import Path

OLD_VERSION = "1.45.0+59"
NEW_VERSION = "1.46.0+60"
COMMIT_MESSAGE = "RC1 kalite kapisini ve tam test paketini ekle"

ROOT = Path.cwd()

MAIN = ROOT / "lib/main.dart"
ABOUT = ROOT / "lib/about_privacy.dart"
BUILD_INFO = ROOT / "lib/app_build_info.dart"
TEST = ROOT / "test/rc1_quality_gate_test.dart"
QUALITY_TOOL = ROOT / "tools/rc1_quality_gate.py"
CHECKLIST = ROOT / "reports/RC1_MANUAL_TEST_CHECKLIST.md"
AUTO_REPORT = ROOT / "reports/RC1_AUTOMATED_REPORT.md"
WORKFLOW = ROOT / ".github/workflows/android-apk.yml"
PUBSPEC = ROOT / "pubspec.yaml"
QUESTIONS = ROOT / "assets/questions.json"

EXISTING_TARGETS = [MAIN, ABOUT, WORKFLOW, PUBSPEC]
NEW_TARGETS = [BUILD_INFO, TEST, QUALITY_TOOL, CHECKLIST]
ALL_TARGETS = EXISTING_TARGETS + NEW_TARGETS + [AUTO_REPORT]

STAGE_PATHS = [
    "lib/main.dart",
    "lib/about_privacy.dart",
    "lib/app_build_info.dart",
    "test/rc1_quality_gate_test.dart",
    "tools/rc1_quality_gate.py",
    "reports/RC1_MANUAL_TEST_CHECKLIST.md",
    "reports/RC1_AUTOMATED_REPORT.md",
    ".github/workflows/android-apk.yml",
    "pubspec.yaml",
]

APP_BUILD_INFO = "part of 'main.dart';\n\nclass AppBuildInfo {\n  AppBuildInfo._();\n\n  static const String versionName = '1.46.0';\n  static const int buildNumber = 60;\n  static const String channel = 'RC1';\n\n  static const String version = '$versionName+$buildNumber';\n  static const String fullLabel = 'Sürüm $version • $channel';\n  static const String compactLabel =\n      'Bilgi Rotası • $versionName • $channel';\n}\n"
RC1_DART_TEST = "import 'dart:convert';\nimport 'dart:io';\n\nimport 'package:bilgi_rotasi/main.dart';\nimport 'package:flutter_test/flutter_test.dart';\n\nvoid main() {\n  TestWidgetsFlutterBinding.ensureInitialized();\n\n  group('Bilgi Rotası RC1 kalite kapısı', () {\n    late List<Map<String, dynamic>> questions;\n\n    setUpAll(() {\n      final file = File('assets/questions.json');\n      expect(\n        file.existsSync(),\n        isTrue,\n        reason: 'assets/questions.json bulunamadı.',\n      );\n\n      final decoded = jsonDecode(file.readAsStringSync());\n      expect(decoded, isA<List<dynamic>>());\n\n      questions = (decoded as List<dynamic>)\n          .map(\n            (item) => Map<String, dynamic>.from(\n              item as Map,\n            ),\n          )\n          .toList(growable: false);\n    });\n\n    test('RC1 sürüm bilgisi tek merkezden gelir', () {\n      expect(AppBuildInfo.versionName, '1.46.0');\n      expect(AppBuildInfo.buildNumber, 60);\n      expect(AppBuildInfo.channel, 'RC1');\n      expect(AppBuildInfo.version, '1.46.0+60');\n      expect(\n        AppBuildInfo.fullLabel,\n        'Sürüm 1.46.0+60 • RC1',\n      );\n    });\n\n    test('Soru bankası kritik şema kontrollerini geçer', () {\n      expect(\n        questions.length,\n        greaterThanOrEqualTo(5000),\n        reason: 'RC1 soru bankası 5000 sorunun altına düştü.',\n      );\n\n      final ids = <String>{};\n      final categoryCounts = List<int>.filled(\n        GameCategory.values.length,\n        0,\n      );\n\n      for (var index = 0; index < questions.length; index++) {\n        final item = questions[index];\n        final label = 'Soru ${index + 1}';\n\n        final id = item['id']?.toString().trim() ?? '';\n        final text =\n            item['question']?.toString().trim() ?? '';\n        final explanation =\n            item['explanation']?.toString().trim() ?? '';\n        final options = item['options'];\n        final category =\n            (item['categoryIndex'] as num?)?.toInt();\n        final answer =\n            (item['answerIndex'] as num?)?.toInt();\n        final difficulty =\n            item['difficulty']?.toString().trim() ?? '';\n\n        expect(id, isNotEmpty, reason: '$label: id boş.');\n        expect(\n          ids.add(id),\n          isTrue,\n          reason: '$label: yinelenen id: $id',\n        );\n        expect(\n          text,\n          isNotEmpty,\n          reason: '$label ($id): soru metni boş.',\n        );\n        expect(\n          explanation,\n          isNotEmpty,\n          reason: '$label ($id): açıklama boş.',\n        );\n        expect(\n          category,\n          isNotNull,\n          reason: '$label ($id): kategori yok.',\n        );\n        expect(\n          category!,\n          inInclusiveRange(\n            0,\n            GameCategory.values.length - 1,\n          ),\n          reason: '$label ($id): kategori geçersiz.',\n        );\n        categoryCounts[category]++;\n\n        expect(\n          options,\n          isA<List<dynamic>>(),\n          reason: '$label ($id): seçenekler liste değil.',\n        );\n        final optionList = (options as List<dynamic>)\n            .map((value) => value.toString().trim())\n            .toList(growable: false);\n        expect(\n          optionList.length,\n          4,\n          reason: '$label ($id): dört seçenek yok.',\n        );\n        expect(\n          optionList.every((value) => value.isNotEmpty),\n          isTrue,\n          reason: '$label ($id): boş seçenek var.',\n        );\n\n        expect(\n          answer,\n          isNotNull,\n          reason: '$label ($id): cevap indeksi yok.',\n        );\n        expect(\n          answer!,\n          inInclusiveRange(0, 3),\n          reason: '$label ($id): cevap indeksi geçersiz.',\n        );\n        expect(\n          <String>{'Kolay', 'Orta', 'Zor'},\n          contains(difficulty),\n          reason: '$label ($id): zorluk geçersiz.',\n        );\n      }\n\n      for (var index = 0;\n          index < categoryCounts.length;\n          index++) {\n        expect(\n          categoryCounts[index],\n          greaterThanOrEqualTo(500),\n          reason:\n              '${GameCategory.values[index].label} '\n              'kategorisi 500 sorunun altında.',\n        );\n      }\n    });\n\n    test('XP eğrisi ve rütbe eşikleri kararlıdır', () {\n      expect(xpRanks, isNotEmpty);\n\n      for (var index = 1; index < xpRanks.length; index++) {\n        expect(\n          xpRanks[index].level,\n          greaterThan(xpRanks[index - 1].level),\n        );\n      }\n\n      for (var level = 1; level < 100; level++) {\n        expect(\n          XpProgressService.requiredForLevel(level + 1),\n          greaterThan(\n            XpProgressService.requiredForLevel(level),\n          ),\n        );\n      }\n\n      final firstRequirement =\n          XpProgressService.requiredForLevel(1);\n      expect(XpProgressService.snapshot(0).level, 1);\n      expect(\n        XpProgressService.snapshot(\n          firstRequirement - 1,\n        ).level,\n        1,\n      );\n      expect(\n        XpProgressService.snapshot(firstRequirement).level,\n        2,\n      );\n\n      for (final rank in xpRanks) {\n        expect(\n          XpProgressService.rankFor(rank.level).title,\n          rank.title,\n        );\n      }\n    });\n\n    test('Başarım tanımları benzersiz ve geçerlidir', () {\n      expect(careerAchievements.length, greaterThanOrEqualTo(10));\n\n      final titles = careerAchievements\n          .map((item) => item.title.trim())\n          .toList(growable: false);\n\n      expect(titles.every((title) => title.isNotEmpty), isTrue);\n      expect(titles.toSet().length, titles.length);\n\n      final empty = CareerStats();\n      expect(\n        careerAchievements\n            .where((item) => item.isUnlocked(empty)),\n        isEmpty,\n      );\n    });\n\n    test('Tahta grafiğinde ulaşılamayan düğüm yoktur', () {\n      final lastId = BoardMap.spokeStart +\n          GameCategory.values.length *\n              BoardMap.spokeLength -\n          1;\n      final allIds = <int>{\n        for (var id = 0; id <= lastId; id++) id,\n      };\n\n      final visited = <int>{BoardMap.centerId};\n      final queue = <int>[BoardMap.centerId];\n\n      while (queue.isNotEmpty) {\n        final current = queue.removeAt(0);\n        for (final neighbor in BoardMap.neighbors(current)) {\n          if (allIds.contains(neighbor) &&\n              visited.add(neighbor)) {\n            queue.add(neighbor);\n          }\n        }\n      }\n\n      expect(\n        visited,\n        containsAll(allIds),\n        reason: 'Tahtada ulaşılamayan düğüm var.',\n      );\n\n      for (final id in allIds) {\n        for (final neighbor in BoardMap.neighbors(id)) {\n          expect(\n            BoardMap.neighbors(neighbor),\n            contains(id),\n            reason:\n                '$id ile $neighbor komşuluğu tek yönlü.',\n          );\n        }\n      }\n    });\n\n    test('Tema ve piyon katalogları tutarlıdır', () {\n      expect(boardThemes.length, 6);\n      expect(\n        boardThemes.map((theme) => theme.id).toSet().length,\n        boardThemes.length,\n      );\n\n      for (var index = 1;\n          index < boardThemes.length;\n          index++) {\n        expect(\n          boardThemes[index].unlockLevel,\n          greaterThan(\n            boardThemes[index - 1].unlockLevel,\n          ),\n        );\n      }\n\n      expect(PawnCatalog.all.length, 16);\n      expect(\n        PawnCatalog.all\n            .map((pawn) => pawn.name)\n            .toSet()\n            .length,\n        PawnCatalog.all.length,\n      );\n      expect(\n        PawnVisualEffects.profiles.length,\n        PawnCatalog.all.length,\n      );\n      expect(\n        PawnStepSoundFactory.profileCount,\n        PawnCatalog.all.length,\n      );\n    });\n\n    test('Kullanıcı arayüzünde kaldırılan metinler yoktur', () {\n      final files = <String>[\n        'lib/main_navigation.dart',\n        'lib/visual_collection.dart',\n        'lib/about_privacy.dart',\n        'lib/social_features.dart',\n      ];\n\n      final source = files\n          .map((path) => File(path).readAsStringSync())\n          .join('\\n');\n\n      expect(source, isNot(contains('Ses Atmosferi')));\n      expect(\n        source,\n        isNot(contains('ses atmosferini seç')),\n      );\n      expect(\n        source,\n        isNot(contains('Sistem Sağlığını Aç')),\n      );\n      expect(\n        source,\n        isNot(\n          contains('Meydan Okuma artık Oyna bölümünde'),\n        ),\n      );\n    });\n  });\n}\n"
QUALITY_GATE_TOOL = '#!/usr/bin/env python3\n# -*- coding: utf-8 -*-\n\n# Bilgi Rotası RC1 hızlı kalite kapısı.\n\nfrom __future__ import annotations\n\nimport argparse\nimport hashlib\nimport json\nimport re\nimport sys\nfrom collections import Counter\nfrom pathlib import Path\n\nROOT = Path(__file__).resolve().parents[1]\nEXPECTED_VERSION = "1.46.0+60"\nMIN_TOTAL_QUESTIONS = 5000\nMIN_QUESTIONS_PER_CATEGORY = 500\nCATEGORY_COUNT = 6\n\nREQUIRED_FILES = [\n    "lib/main.dart",\n    "lib/app_build_info.dart",\n    "assets/questions.json",\n    "assets/branding/app_icon.png",\n    "assets/branding/app_icon_foreground.png",\n    "assets/branding/splash_logo.png",\n    "assets/sounds/dice_roll.mp3",\n    "assets/sounds/landing.mp3",\n    "assets/sounds/correct.mp3",\n    "assets/sounds/wrong.mp3",\n    "assets/sounds/badge.mp3",\n    "assets/sounds/win.mp3",\n]\n\nUSER_FACING_FILES = [\n    "lib/main_navigation.dart",\n    "lib/visual_collection.dart",\n    "lib/about_privacy.dart",\n    "lib/social_features.dart",\n]\n\nFORBIDDEN_TEXTS = [\n    "Ses Atmosferi",\n    "ses atmosferini seç",\n    "Sistem Sağlığını Aç",\n    "Meydan Okuma artık Oyna bölümünde",\n]\n\n\ndef parse_args() -> argparse.Namespace:\n    parser = argparse.ArgumentParser()\n    parser.add_argument(\n        "--report",\n        default="reports/RC1_AUTOMATED_REPORT.md",\n    )\n    return parser.parse_args()\n\n\ndef normalize(value: str) -> str:\n    return re.sub(r"\\s+", " ", value.strip().casefold())\n\n\ndef main() -> int:\n    args = parse_args()\n    errors: list[str] = []\n    warnings: list[str] = []\n\n    for relative in REQUIRED_FILES:\n        path = ROOT / relative\n        if not path.is_file():\n            errors.append(f"Eksik dosya: {relative}")\n        elif path.stat().st_size <= 0:\n            errors.append(f"Boş dosya: {relative}")\n\n    pubspec_path = ROOT / "pubspec.yaml"\n    version = "?"\n    if not pubspec_path.is_file():\n        errors.append("pubspec.yaml bulunamadı.")\n    else:\n        pubspec = pubspec_path.read_text(encoding="utf-8")\n        match = re.search(\n            r"(?m)^version:\\s*([^\\s]+)\\s*$",\n            pubspec,\n        )\n        version = match.group(1) if match else "?"\n        if version != EXPECTED_VERSION:\n            errors.append(\n                f"Sürüm uyuşmuyor: {version} "\n                f"(beklenen {EXPECTED_VERSION})"\n            )\n\n    questions_path = ROOT / "assets/questions.json"\n    questions: list[dict] = []\n    category_counts = Counter()\n    duplicate_text_count = 0\n    question_sha = "?"\n\n    if questions_path.is_file():\n        question_sha = hashlib.sha256(\n            questions_path.read_bytes()\n        ).hexdigest()\n\n        try:\n            raw = json.loads(\n                questions_path.read_text(encoding="utf-8")\n            )\n        except Exception as exc:\n            errors.append(f"Soru JSON okunamadı: {exc}")\n            raw = []\n\n        if not isinstance(raw, list):\n            errors.append("Soru bankasının kökü liste değil.")\n        else:\n            questions = raw\n\n    if len(questions) < MIN_TOTAL_QUESTIONS:\n        errors.append(\n            f"Toplam soru sayısı {len(questions)}; "\n            f"en az {MIN_TOTAL_QUESTIONS} olmalı."\n        )\n\n    seen_ids: set[str] = set()\n    seen_texts: set[str] = set()\n\n    for index, item in enumerate(questions, start=1):\n        label = f"Soru {index}"\n\n        if not isinstance(item, dict):\n            errors.append(f"{label}: nesne değil.")\n            continue\n\n        question_id = str(item.get("id", "")).strip()\n        question = str(item.get("question", "")).strip()\n        explanation = str(\n            item.get("explanation", "")\n        ).strip()\n        options = item.get("options")\n        category = item.get("categoryIndex")\n        answer = item.get("answerIndex")\n        difficulty = str(\n            item.get("difficulty", "")\n        ).strip()\n\n        if not question_id:\n            errors.append(f"{label}: id boş.")\n        elif question_id in seen_ids:\n            errors.append(\n                f"{label}: yinelenen id {question_id}."\n            )\n        else:\n            seen_ids.add(question_id)\n\n        if not question:\n            errors.append(\n                f"{label} ({question_id}): metin boş."\n            )\n        else:\n            normalized = normalize(question)\n            if normalized in seen_texts:\n                duplicate_text_count += 1\n            else:\n                seen_texts.add(normalized)\n\n        if not explanation:\n            errors.append(\n                f"{label} ({question_id}): açıklama boş."\n            )\n\n        if not isinstance(category, int) or not (\n            0 <= category < CATEGORY_COUNT\n        ):\n            errors.append(\n                f"{label} ({question_id}): kategori geçersiz."\n            )\n        else:\n            category_counts[category] += 1\n\n        if not isinstance(options, list) or len(options) != 4:\n            errors.append(\n                f"{label} ({question_id}): dört seçenek yok."\n            )\n        elif any(not str(option).strip() for option in options):\n            errors.append(\n                f"{label} ({question_id}): boş seçenek var."\n            )\n\n        if not isinstance(answer, int) or not 0 <= answer <= 3:\n            errors.append(\n                f"{label} ({question_id}): "\n                "cevap indeksi geçersiz."\n            )\n\n        if difficulty not in {"Kolay", "Orta", "Zor"}:\n            errors.append(\n                f"{label} ({question_id}): zorluk geçersiz."\n            )\n\n    for category in range(CATEGORY_COUNT):\n        count = category_counts[category]\n        if count < MIN_QUESTIONS_PER_CATEGORY:\n            errors.append(\n                f"Kategori {category}: {count} soru; "\n                f"en az {MIN_QUESTIONS_PER_CATEGORY} olmalı."\n            )\n\n    if duplicate_text_count:\n        warnings.append(\n            "Normalize edilmiş yinelenen soru metni: "\n            f"{duplicate_text_count}"\n        )\n\n    for relative in USER_FACING_FILES:\n        path = ROOT / relative\n        if not path.is_file():\n            continue\n        source = path.read_text(encoding="utf-8")\n        for forbidden in FORBIDDEN_TEXTS:\n            if forbidden in source:\n                errors.append(\n                    f"{relative}: kaldırılmış metin bulundu: "\n                    f"{forbidden!r}"\n                )\n\n    report_path = ROOT / args.report\n    report_path.parent.mkdir(parents=True, exist_ok=True)\n\n    status = "BAŞARILI" if not errors else "BAŞARISIZ"\n    report_lines = [\n        "# Bilgi Rotası RC1 Otomatik Kalite Raporu",\n        "",\n        f"- Durum: **{status}**",\n        f"- Sürüm: `{version}`",\n        f"- Toplam soru: **{len(questions)}**",\n        f"- Soru dosyası SHA-256: `{question_sha}`",\n        "",\n        "## Kategori dağılımı",\n        "",\n    ]\n\n    for category in range(CATEGORY_COUNT):\n        report_lines.append(\n            f"- Kategori {category}: "\n            f"**{category_counts[category]}**"\n        )\n\n    report_lines.extend(\n        [\n            "",\n            "## Uyarılar",\n            "",\n            *(\n                [f"- {warning}" for warning in warnings]\n                if warnings\n                else ["- Uyarı yok."]\n            ),\n            "",\n            "## Hatalar",\n            "",\n            *(\n                [f"- {error}" for error in errors]\n                if errors\n                else ["- Kritik hata yok."]\n            ),\n            "",\n        ]\n    )\n\n    report_path.write_text(\n        "\\n".join(report_lines),\n        encoding="utf-8",\n    )\n\n    print("=" * 64)\n    print(f"Bilgi Rotası RC1 kalite kapısı: {status}")\n    print(f"Sürüm: {version}")\n    print(f"Toplam soru: {len(questions)}")\n    print(\n        "Kategori dağılımı: "\n        + ", ".join(\n            f"{index}={category_counts[index]}"\n            for index in range(CATEGORY_COUNT)\n        )\n    )\n    if warnings:\n        print("Uyarılar:")\n        for warning in warnings:\n            print(f"  - {warning}")\n    if errors:\n        print("Hatalar:")\n        for error in errors[:40]:\n            print(f"  - {error}")\n        if len(errors) > 40:\n            print(f"  ... ve {len(errors) - 40} hata daha")\n    print(f"Rapor: {report_path.relative_to(ROOT)}")\n    print("=" * 64)\n\n    return 1 if errors else 0\n\n\nif __name__ == "__main__":\n    sys.exit(main())\n'
MANUAL_CHECKLIST = '# Bilgi Rotası — RC1 Telefon Test Listesi\n\nSürüm: **1.46.0+60 • RC1**\n\n> Bir madde başarısızsa RC1 onaylanmaz. Hata düzeltilir,\n> yeni APK alınır ve ilgili bölüm yeniden test edilir.\n\n## 1. Kurulum ve açılış\n\n- [ ] APK mevcut uygulamanın üzerine sorunsuz kuruldu.\n- [ ] Uygulama ilk açılışta kapanmadı veya siyah ekranda kalmadı.\n- [ ] Ana sayfada soru sayısı ve altı kategori doğru göründü.\n- [ ] Hakkında ekranında `Sürüm 1.46.0+60 • RC1` göründü.\n- [ ] Uygulama internet kapalıyken açıldı.\n\n## 2. Standart tahta oyunu\n\n- [ ] 2 oyunculu yeni oyun başlatıldı.\n- [ ] Zar, piyon hareketi, rota seçimi ve soru ekranı çalıştı.\n- [ ] Doğru ve yanlış cevap akışları çalıştı.\n- [ ] Altı kategoriden rozet alınabildi.\n- [ ] Tekrar Zar At kutusu soru açmadan sırayı korudu.\n- [ ] Rastgele Joker kutusu bir jokere `+1` ekledi.\n- [ ] Çifte Şans ve Kategori Seç alanları çalıştı.\n- [ ] Oyun kaydedildi, uygulama kapatılıp açıldı ve sürdü.\n- [ ] Final sorusu ve kazanan ekranı çalıştı.\n\n## 3. Diğer oyun modları\n\n- [ ] Serbest Rota başlatıldı ve tamamlanabildi.\n- [ ] Soru Maratonu başlatıldı ve sonuç ekranı açıldı.\n- [ ] Günlük Görev oynandı ve aynı gün ikinci resmî skor yazılmadı.\n- [ ] Kısa kodlu Meydan Okuma oluşturuldu.\n- [ ] Oluşturulan kısa kod giriş ekranında kabul edildi.\n\n## 4. Kariyer ve kayıtlar\n\n- [ ] Doğru cevap sonrası XP arttı.\n- [ ] Yanlış cevap XP düşürmedi ve seriyi sıfırladı.\n- [ ] Seviye ve rütbe bilgileri doğru güncellendi.\n- [ ] Başarımlar uygun koşulda açıldı.\n- [ ] Aile Rekorları sonuçlardan sonra güncellendi.\n- [ ] Kariyer paylaşım ekranı açıldı.\n\n## 5. Tema, piyon ve ses\n\n- [ ] Klasik ve Antik Mısır temaları oyunda düzgün göründü.\n- [ ] Kilitli Uzay, Orman, Okyanus ve Gelecek temaları önizlendi.\n- [ ] Kilitli tema önizlemede seçili temayı değiştirmedi.\n- [ ] Açık tema `Bu Temayı Kullan` ile seçildi.\n- [ ] Favori piyon seçimi kaydedildi.\n- [ ] Zar, hareket, doğru, yanlış, rozet ve kazanma sesleri çaldı.\n- [ ] Ses kapatıldığında oyun sesleri sustu.\n\n## 6. Ayarlar ve erişilebilirlik\n\n- [ ] Yazı boyutu seçenekleri ekranı bozmadı.\n- [ ] Çocuk modu çalıştı.\n- [ ] Kategori destek modu çalıştı.\n- [ ] Titreşim anahtarı çalıştı.\n- [ ] Animasyon yoğunluğu seçenekleri çalıştı.\n- [ ] `Ses Atmosferi` hiçbir kullanıcı ekranında görünmedi.\n- [ ] Sistem Sağlığı normal kullanıcı menüsünde görünmedi.\n- [ ] Sosyal ekranın eski açıklama kutusu yoktu.\n\n## 7. Dayanıklılık\n\n- [ ] Uygulama arka plana alınıp dönünce çalışmaya devam etti.\n- [ ] Peş peşe en az 30 soru oynandı ve kilitlenme olmadı.\n- [ ] Uygulama yeniden açıldığında ayarlar korundu.\n- [ ] Telefon yeniden başladıktan sonra ilerleme korundu.\n\n## RC1 sonucu\n\n- Test edilen telefon:\n- Android sürümü:\n- Test tarihi:\n- Test eden:\n- Sonuç: [ ] ONAYLANDI  [ ] REDDEDİLDİ\n- Bulunan hatalar:\n'
WORKFLOW_YAML = 'name: RC1 kalite kapısı ve APK\n\non:\n  push:\n    branches:\n      - main\n  workflow_dispatch:\n\npermissions:\n  contents: read\n\njobs:\n  quality-and-build:\n    name: Kalite + APK\n    runs-on: ubuntu-latest\n\n    steps:\n      - name: Depoyu indir\n        uses: actions/checkout@v4\n\n      - name: Flutter kur\n        uses: subosito/flutter-action@v2\n        with:\n          flutter-version: "3.44.7"\n          channel: stable\n          cache: true\n\n      - name: Bağımlılıkları kur\n        run: flutter pub get\n\n      - name: RC1 soru ve asset kalite kapısı\n        run: |\n          python3 tools/rc1_quality_gate.py \\\n            --report reports/RC1_AUTOMATED_REPORT.md\n\n      - name: Yeni RC1 dosyalarının biçimini kontrol et\n        run: |\n          dart format --output=none --set-exit-if-changed \\\n            lib/app_build_info.dart \\\n            test/rc1_quality_gate_test.dart\n\n      - name: Flutter statik analiz\n        run: flutter analyze --no-fatal-warnings --no-fatal-infos\n\n      - name: Flutter testleri\n        run: flutter test\n\n      - name: Temiz Android projesi oluştur\n        shell: bash\n        run: |\n          set -euxo pipefail\n\n          rm -rf .flutter_build\n\n          flutter create \\\n            --platforms=android \\\n            --org com.levent \\\n            --project-name bilgi_rotasi \\\n            .flutter_build\n\n          rm -rf .flutter_build/lib\n          cp -R lib .flutter_build/lib\n\n          rm -rf .flutter_build/assets\n          cp -R assets .flutter_build/assets\n\n          cp pubspec.yaml .flutter_build/pubspec.yaml\n\n          if [ -f pubspec.lock ]; then\n            cp pubspec.lock .flutter_build/pubspec.lock\n          fi\n\n          if [ -f analysis_options.yaml ]; then\n            cp analysis_options.yaml \\\n              .flutter_build/analysis_options.yaml\n          fi\n\n          test -f .flutter_build/lib/main.dart\n          test -f .flutter_build/lib/app_build_info.dart\n          test -f .flutter_build/assets/questions.json\n          test -f .flutter_build/assets/sounds/correct.mp3\n\n      - name: Android simge ve açılış ekranını hazırla\n        working-directory: .flutter_build\n        run: |\n          flutter pub get\n          dart run flutter_launcher_icons\n          dart run flutter_native_splash:create\n\n          sed -i \\\n            \'s/android:label="bilgi_rotasi"/android:label="Bilgi Rotası"/\' \\\n            android/app/src/main/AndroidManifest.xml\n\n      - name: Release APK oluştur\n        working-directory: .flutter_build\n        run: flutter build apk --release\n\n      - name: APK parmak izini oluştur\n        shell: bash\n        run: |\n          set -euxo pipefail\n\n          APK=".flutter_build/build/app/outputs/flutter-apk/app-release.apk"\n          test -f "$APK"\n\n          sha256sum "$APK" | tee reports/RC1_APK_SHA256.txt\n\n          {\n            echo "# Bilgi Rotası RC1 Yapı Bilgisi"\n            echo\n            echo "- Commit: ${GITHUB_SHA}"\n            echo "- Sürüm: 1.46.0+60"\n            echo "- Kanal: RC1"\n            echo "- Workflow: ${GITHUB_RUN_ID}"\n          } > reports/RC1_BUILD_INFO.md\n\n      - name: RC1 APK ve raporları yükle\n        uses: actions/upload-artifact@v4\n        with:\n          name: BilgiRotasi-RC1-1.46.0-60\n          path: |\n            .flutter_build/build/app/outputs/flutter-apk/app-release.apk\n            reports/RC1_AUTOMATED_REPORT.md\n            reports/RC1_APK_SHA256.txt\n            reports/RC1_BUILD_INFO.md\n            reports/RC1_MANUAL_TEST_CHECKLIST.md\n          if-no-files-found: error\n          retention-days: 30\n'


def run(*args: str, check: bool = True, capture: bool = False):
    kwargs = {"cwd": ROOT, "text": True, "check": check}
    if capture:
        kwargs["stdout"] = subprocess.PIPE
        kwargs["stderr"] = subprocess.PIPE
    return subprocess.run(args, **kwargs)


def output(*args: str) -> str:
    return run(*args, capture=True).stdout.strip()


def fail(message: str) -> None:
    raise RuntimeError(message)


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        fail(
            f"{label}: beklenen parça {count} kez bulundu. "
            "İşlem güvenle durduruldu."
        )
    return text.replace(old, new, 1)


def ensure_repo() -> None:
    if not (ROOT / ".git").exists():
        fail(
            "Bu dosyayı Codespaces içinde BilgiRotasi "
            "deposunun ana klasöründe çalıştır."
        )

    if output("git", "branch", "--show-current") != "main":
        fail("Aktif dal main olmalı.")

    for path in EXISTING_TARGETS + [QUESTIONS]:
        if not path.exists():
            fail(f"Gerekli dosya yok: {path.relative_to(ROOT)}")

    pubspec = PUBSPEC.read_text(encoding="utf-8")
    match = re.search(r"(?m)^version:\s*([^\s]+)\s*$", pubspec)
    current = match.group(1) if match else None
    if current != OLD_VERSION:
        fail(
            f"Beklenen sürüm {OLD_VERSION}; mevcut sürüm {current!r}."
        )

    for relative in [
        "lib/main.dart",
        "lib/about_privacy.dart",
        ".github/workflows/android-apk.yml",
        "pubspec.yaml",
    ]:
        if output("git", "status", "--porcelain", "--", relative):
            fail(
                f"{relative} dosyasında yerel değişiklik var. "
                "Üzerine yazılmadı."
            )

    for path in NEW_TARGETS:
        if path.exists():
            fail(
                f"{path.relative_to(ROOT)} zaten var. "
                "Kurulum ikinci kez çalıştırılmadı."
            )

    if output(
        "git",
        "status",
        "--porcelain",
        "--",
        "assets/questions.json",
    ):
        fail(
            "assets/questions.json yerelde değiştirilmiş. "
            "RC1 kurulumu soru çalışmasıyla karıştırılmadı."
        )


def patch_main(text: str) -> str:
    text = replace_once(
        text,
        "part 'about_privacy.dart';\n",
        "part 'about_privacy.dart';\n"
        "part 'app_build_info.dart';\n",
        "AppBuildInfo bağlantısı",
    )

    old = """                const Text(
                  'Bilgi Rotası • Sürüm 1.45.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0x99FFFFFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
"""
    new = """                const Text(
                  AppBuildInfo.compactLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0x99FFFFFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
"""
    return replace_once(
        text,
        old,
        new,
        "Ana sayfa sürüm bilgisi",
    )


def patch_about(text: str) -> str:
    old = """                const Text(
                  'Sürüm 1.45.0+59',
                  style: TextStyle(
                    color: Color(0xFFFFE082),
                    fontWeight: FontWeight.w800,
                  ),
                ),
"""
    new = """                const Text(
                  AppBuildInfo.fullLabel,
                  style: TextStyle(
                    color: Color(0xFFFFE082),
                    fontWeight: FontWeight.w800,
                  ),
                ),
"""
    return replace_once(
        text,
        old,
        new,
        "Hakkında sürüm bilgisi",
    )


def main() -> None:
    ensure_repo()

    originals = {
        path: path.read_bytes() if path.exists() else None
        for path in ALL_TARGETS
    }
    committed = False

    try:
        MAIN.write_text(
            patch_main(MAIN.read_text(encoding="utf-8")),
            encoding="utf-8",
        )
        ABOUT.write_text(
            patch_about(ABOUT.read_text(encoding="utf-8")),
            encoding="utf-8",
        )
        BUILD_INFO.write_text(APP_BUILD_INFO, encoding="utf-8")
        TEST.write_text(RC1_DART_TEST, encoding="utf-8")
        QUALITY_TOOL.write_text(
            QUALITY_GATE_TOOL,
            encoding="utf-8",
        )
        QUALITY_TOOL.chmod(0o755)
        CHECKLIST.write_text(
            MANUAL_CHECKLIST,
            encoding="utf-8",
        )
        WORKFLOW.write_text(
            WORKFLOW_YAML,
            encoding="utf-8",
        )

        pubspec = PUBSPEC.read_text(encoding="utf-8")
        PUBSPEC.write_text(
            replace_once(
                pubspec,
                f"version: {OLD_VERSION}",
                f"version: {NEW_VERSION}",
                "Sürüm numarası",
            ),
            encoding="utf-8",
        )

        run(
            sys.executable,
            "tools/rc1_quality_gate.py",
            "--report",
            "reports/RC1_AUTOMATED_REPORT.md",
        )

        dart = shutil.which("dart")
        flutter = shutil.which("flutter")

        if dart:
            run(
                dart,
                "format",
                "lib/main.dart",
                "lib/about_privacy.dart",
                "lib/app_build_info.dart",
                "test/rc1_quality_gate_test.dart",
            )
        else:
            print("UYARI: dart bulunamadı; format atlandı.")

        run("git", "diff", "--check", "--", *STAGE_PATHS)

        if flutter:
            run(flutter, "pub", "get")
            run(
                flutter,
                "analyze",
                "--no-fatal-warnings",
                "--no-fatal-infos",
            )
            run(flutter, "test")
        else:
            print(
                "UYARI: flutter bulunamadı; "
                "kontroller GitHub Actions'ta çalışacak."
            )

        if output(
            "git",
            "status",
            "--porcelain",
            "--",
            "assets/questions.json",
        ):
            fail("Kurulum soru dosyasını değiştirdi.")

        run("git", "add", "--", *STAGE_PATHS)

        staged = output(
            "git",
            "diff",
            "--cached",
            "--name-only",
        ).splitlines()

        allowed = set(STAGE_PATHS)
        unexpected = [p for p in staged if p not in allowed]
        if unexpected:
            fail(
                "RC1 commit'ine beklenmeyen dosyalar girdi:\n- "
                + "\n- ".join(unexpected)
            )
        if not staged:
            fail("RC1 değişikliği oluşmadı.")

        run(
            "git",
            "commit",
            "-m",
            COMMIT_MESSAGE,
            "--",
            *STAGE_PATHS,
        )
        committed = True

        try:
            run("git", "push", "origin", "main")
        except Exception:
            print(
                "\nCommit oluşturuldu fakat push başarısız.\n"
                "Sonra çalıştır: git push origin main\n"
            )
            raise

        print(
            "\n✅ RC1 kalite kapısı kuruldu.\n"
            "✅ Yeni sürüm: 1.46.0+60 • RC1\n"
            "✅ Soru ve asset denetimi geçti.\n"
            "✅ Analyze ve Flutter testleri kalite kapısına bağlandı.\n"
            "✅ Merkezi sürüm bilgisi eklendi.\n"
            "✅ Manuel telefon test listesi eklendi.\n"
            "✅ assets/questions.json içeriğine dokunulmadı.\n"
            "✅ Commit main dalına push edildi.\n\n"
            "Actions yeşil olunca BilgiRotasi-RC1-1.46.0-60 "
            "artifact'ini indir."
        )

    except Exception as error:
        if not committed:
            for path, data in originals.items():
                if data is None:
                    if path.exists():
                        path.unlink()
                else:
                    path.write_bytes(data)

            run(
                "git",
                "reset",
                "--quiet",
                "--",
                *STAGE_PATHS,
                check=False,
            )
            print("\nHedef dosyalar eski hâline döndürüldü.")

        print(f"\n❌ RC1 kurulumu başarısız: {error}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
