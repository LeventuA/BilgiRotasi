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
  });
}
