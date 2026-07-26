import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Ana sayfa üst kart düzeni', () {
    late String source;
    late String homeBuild;

    setUpAll(() {
      source = File('lib/main.dart').readAsStringSync();

      final homeStart = source.indexOf(
        'class _HomeScreenState extends State<HomeScreen>',
      );
      final buildStart = source.indexOf(
        'Widget build(BuildContext context)',
        homeStart,
      );
      final buildEnd = source.indexOf('Widget _buildHeroHeader()', buildStart);

      expect(homeStart, greaterThanOrEqualTo(0));
      expect(buildStart, greaterThanOrEqualTo(0));
      expect(buildEnd, greaterThan(buildStart));

      homeBuild = source.substring(buildStart, buildEnd);
    });

    test('Oyuna Başla kartı ana sayfada bulunmaz', () {
      expect(homeBuild, isNot(contains('_buildNewGameCard()')));
      expect(source, isNot(contains('Widget _buildNewGameCard()')));
      expect(homeBuild, isNot(contains('Standart Tahta Oyununu Başlat')));
    });

    test('Günlük görev kartı ana sayfada bulunmaz', () {
      expect(homeBuild, isNot(contains('DailyChallengeHomeCard')));
      expect(homeBuild, isNot(contains('AccountCloudService.dailyVisible')));
    });

    test('yalnızca gerçek kayıtlı oyun kartı korunur', () {
      expect(homeBuild, contains('FutureBuilder<SavedGame?>'));
      expect(homeBuild, contains('savedGame == null'));
      expect(homeBuild, contains('return _buildSavedGameCard(savedGame);'));
      expect(homeBuild, contains('return const SizedBox.shrink();'));
    });
  });
}
