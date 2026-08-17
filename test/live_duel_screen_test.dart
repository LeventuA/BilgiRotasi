import 'dart:io';

import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Canlı düello ekran metinleri', () {
    test('soru sayısı etiketi doğru oluşturulur', () {
      expect(LiveDuelScreenText.questionCountLabel(10), '10 Soru');

      expect(LiveDuelScreenText.questionCountLabel(30), '30 Soru');
    });

    test('kuyruk metni soru sayısını içerir', () {
      expect(
        LiveDuelScreenText.queueStatus(20),
        '20 soruluk düello için rakip aranıyor...',
      );
    });

    test('lig özeti BR puanını içerir', () {
      const profile = LiveDuelProfile(rating: 1450, matchesPlayed: 8);

      final summary = LiveDuelScreenText.leagueSummary(profile);

      expect(summary, contains('Altın'));
      expect(summary, contains('1450 BR'));
    });

    test('tamamlanmış stale maç yeniden açılmaz', () {
      const stale = LiveDuelResumeMatch(matchId: 'match-1', questionCount: 20);
      const same = LiveDuelResumeMatch(matchId: 'match-1', questionCount: 20);
      const other = LiveDuelResumeMatch(matchId: 'match-2', questionCount: 20);

      expect(liveDuelResumeStillCurrent(stale: stale, fresh: same), isTrue);
      expect(liveDuelResumeStillCurrent(stale: stale, fresh: null), isFalse);
      expect(liveDuelResumeStillCurrent(stale: stale, fresh: other), isFalse);
    });

    test('resume sunucuda yeniden doğrulanmadan ekran açılmaz', () {
      final source = File('lib/live_duel_screen.dart').readAsStringSync();
      final resumeStart = source.indexOf('Future<void> _resumeDuel()');
      final revalidation = source.indexOf(
        'LiveDuelConnectionService.findResumableMatch()',
        resumeStart,
      );
      final navigation = source.indexOf(
        'Navigator.of(context).push<void>',
        resumeStart,
      );

      expect(resumeStart, greaterThanOrEqualTo(0));
      expect(revalidation, greaterThan(resumeStart));
      expect(navigation, greaterThan(revalidation));
      expect(
        source.substring(resumeStart, navigation),
        contains('liveDuelResumeStillCurrent'),
      );
    });
  });
}
