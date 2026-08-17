import 'dart:io';

import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Canlı düello otomatik eşleştirme', () {
    test('soru seçenekleri 10, 20 ve 30 olur', () {
      expect(LiveDuelMatchmakingPolicy.questionCountOptions, <int>[10, 20, 30]);

      expect(LiveDuelMatchmakingPolicy.supportsQuestionCount(15), isFalse);
    });

    test('BR puanı doğru aralığa ayrılır', () {
      expect(LiveDuelMatchmakingPolicy.ratingBucket(0), 0);
      expect(LiveDuelMatchmakingPolicy.ratingBucket(999), 4);
      expect(LiveDuelMatchmakingPolicy.ratingBucket(1000), 5);
      expect(LiveDuelMatchmakingPolicy.ratingBucket(1399), 6);
      expect(LiveDuelMatchmakingPolicy.ratingBucket(1400), 7);
    });

    test('önce oyuncunun kendi BR aralığı aranır', () {
      expect(LiveDuelMatchmakingPolicy.searchBuckets(1000), <int>[5, 4, 6]);

      expect(LiveDuelMatchmakingPolicy.searchBuckets(50), <int>[0, 1]);
    });

    test('kuyruk süresi üç dakikadır', () {
      expect(
        LiveDuelMatchmakingPolicy.queueLifetime,
        const Duration(minutes: 3),
      );
    });

    test('arama ekranı kurulmadan eşleşme başlatılmaz ve matched kayıt kurtarılır', () {
      final source = File('lib/live_duel_matchmaking.dart').readAsStringSync();
      final enterQueue = RegExp(
        r'static Future<void> enterQueue[\s\S]*?^  }',
        multiLine: true,
      ).firstMatch(source)?.group(0);

      expect(enterQueue, isNotNull);
      expect(enterQueue, isNot(contains('await tryMatch()')));
      expect(source, contains('GetOptions(source: Source.server)'));
      expect(source, contains('if (ownQueue.matched) return ownQueue.matchId;'));
    });
  });
}
