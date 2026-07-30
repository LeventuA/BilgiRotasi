import 'dart:convert';
import 'dart:io';

import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Bilgi Rotası production kalite kapısı', () {
    late List<Map<String, dynamic>> questions;

    setUpAll(() {
      final file = File('assets/questions.json');
      expect(
        file.existsSync(),
        isTrue,
        reason: 'assets/questions.json bulunamadı.',
      );

      final decoded = jsonDecode(file.readAsStringSync());
      expect(decoded, isA<List<dynamic>>());

      questions = (decoded as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(growable: false);
    });

    test('production sürüm bilgisi tek merkezden gelir', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final versionMatch = RegExp(
        r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)\s*$',
        multiLine: true,
      ).firstMatch(pubspec);

      expect(
        versionMatch,
        isNotNull,
        reason: 'pubspec.yaml sürüm bilgisi okunamadı.',
      );

      final versionName = versionMatch!.group(1)!;
      final buildNumber = int.parse(versionMatch.group(2)!);
      final version = '$versionName+$buildNumber';

      expect(AppBuildInfo.versionName, versionName);
      expect(AppBuildInfo.buildNumber, buildNumber);
      expect(AppBuildInfo.channel, 'Production');
      expect(AppBuildInfo.version, version);
      expect(AppBuildInfo.fullLabel, 'Sürüm $version • Production');
    });

    test('Soru bankası kritik şema kontrollerini geçer', () {
      expect(
        questions.length,
        greaterThanOrEqualTo(5000),
        reason: 'RC1 soru bankası 5000 sorunun altına düştü.',
      );

      final ids = <String>{};
      final categoryCounts = List<int>.filled(GameCategory.values.length, 0);

      for (var index = 0; index < questions.length; index++) {
        final item = questions[index];
        final label = 'Soru ${index + 1}';

        final id = item['id']?.toString().trim() ?? '';
        final text = item['question']?.toString().trim() ?? '';
        final explanation = item['explanation']?.toString().trim() ?? '';
        final options = item['options'];
        final category = (item['categoryIndex'] as num?)?.toInt();
        final answer = (item['answerIndex'] as num?)?.toInt();
        final difficulty = item['difficulty']?.toString().trim() ?? '';

        expect(id, isNotEmpty, reason: '$label: id boş.');
        expect(ids.add(id), isTrue, reason: '$label: yinelenen id: $id');
        expect(text, isNotEmpty, reason: '$label ($id): soru metni boş.');
        expect(explanation, isNotEmpty, reason: '$label ($id): açıklama boş.');
        expect(category, isNotNull, reason: '$label ($id): kategori yok.');
        expect(
          category!,
          inInclusiveRange(0, GameCategory.values.length - 1),
          reason: '$label ($id): kategori geçersiz.',
        );
        categoryCounts[category]++;

        expect(
          options,
          isA<List<dynamic>>(),
          reason: '$label ($id): seçenekler liste değil.',
        );
        final optionList = (options as List<dynamic>)
            .map((value) => value.toString().trim())
            .toList(growable: false);
        expect(optionList.length, 4, reason: '$label ($id): dört seçenek yok.');
        expect(
          optionList.every((value) => value.isNotEmpty),
          isTrue,
          reason: '$label ($id): boş seçenek var.',
        );

        expect(answer, isNotNull, reason: '$label ($id): cevap indeksi yok.');
        expect(
          answer!,
          inInclusiveRange(0, 3),
          reason: '$label ($id): cevap indeksi geçersiz.',
        );
        expect(
          <String>{'Kolay', 'Orta', 'Zor'},
          contains(difficulty),
          reason: '$label ($id): zorluk geçersiz.',
        );
      }

      for (var index = 0; index < categoryCounts.length; index++) {
        expect(
          categoryCounts[index],
          greaterThanOrEqualTo(500),
          reason:
              '${GameCategory.values[index].label} '
              'kategorisi 500 sorunun altında.',
        );
      }
    });

    test('XP eğrisi ve rütbe eşikleri kararlıdır', () {
      expect(xpRanks, isNotEmpty);

      for (var index = 1; index < xpRanks.length; index++) {
        expect(xpRanks[index].level, greaterThan(xpRanks[index - 1].level));
      }

      for (var level = 1; level < 100; level++) {
        expect(
          XpProgressService.requiredForLevel(level + 1),
          greaterThan(XpProgressService.requiredForLevel(level)),
        );
      }

      final firstRequirement = XpProgressService.requiredForLevel(1);
      expect(XpProgressService.snapshot(0).level, 1);
      expect(XpProgressService.snapshot(firstRequirement - 1).level, 1);
      expect(XpProgressService.snapshot(firstRequirement).level, 2);

      for (final rank in xpRanks) {
        expect(XpProgressService.rankFor(rank.level).title, rank.title);
      }
    });

    test('Başarım tanımları benzersiz ve geçerlidir', () {
      expect(careerAchievements.length, greaterThanOrEqualTo(10));

      final titles = careerAchievements
          .map((item) => item.title.trim())
          .toList(growable: false);

      expect(titles.every((title) => title.isNotEmpty), isTrue);
      expect(titles.toSet().length, titles.length);

      final empty = CareerStats();
      expect(
        careerAchievements.where((item) => item.isUnlocked(empty)),
        isEmpty,
      );
    });

    test('Tahta grafiğinde ulaşılamayan düğüm yoktur', () {
      final lastId =
          BoardMap.spokeStart +
          GameCategory.values.length * BoardMap.spokeLength -
          1;
      final allIds = <int>{for (var id = 0; id <= lastId; id++) id};

      final visited = <int>{BoardMap.centerId};
      final queue = <int>[BoardMap.centerId];

      while (queue.isNotEmpty) {
        final current = queue.removeAt(0);
        for (final neighbor in BoardMap.neighbors(current)) {
          if (allIds.contains(neighbor) && visited.add(neighbor)) {
            queue.add(neighbor);
          }
        }
      }

      expect(
        visited,
        containsAll(allIds),
        reason: 'Tahtada ulaşılamayan düğüm var.',
      );

      for (final id in allIds) {
        for (final neighbor in BoardMap.neighbors(id)) {
          expect(
            BoardMap.neighbors(neighbor),
            contains(id),
            reason: '$id ile $neighbor komşuluğu tek yönlü.',
          );
        }
      }
    });

    test('Tema ve piyon katalogları tutarlıdır', () {
      expect(boardThemes.length, 6);
      expect(
        boardThemes.map((theme) => theme.id).toSet().length,
        boardThemes.length,
      );

      for (var index = 1; index < boardThemes.length; index++) {
        expect(
          boardThemes[index].unlockLevel,
          greaterThan(boardThemes[index - 1].unlockLevel),
        );
      }

      expect(PawnCatalog.all.length, 17);
      expect(
        PawnCatalog.all.map((pawn) => pawn.name).toSet().length,
        PawnCatalog.all.length,
      );
      expect(PawnVisualEffects.profiles.length, PawnCatalog.all.length);
      expect(PawnStepSoundFactory.profileCount, PawnCatalog.all.length);
    });

    test('Kullanıcı arayüzünde kaldırılan metinler yoktur', () {
      final files = <String>[
        'lib/main_navigation.dart',
        'lib/visual_collection.dart',
        'lib/about_privacy.dart',
        'lib/social_features.dart',
      ];

      final source = files
          .map((path) => File(path).readAsStringSync())
          .join('\n');

      expect(source, isNot(contains('Ses Atmosferi')));
      expect(source, isNot(contains('ses atmosferini seç')));
      expect(source, isNot(contains('Sistem Sağlığını Aç')));
      expect(source, isNot(contains('Meydan Okuma artık Oyna bölümünde')));
    });
  });
}
