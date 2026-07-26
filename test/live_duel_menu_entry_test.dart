import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Canlı Düello Oyna menüsü bağlantısı', () {
    test('kart metinleri kullanıcıya modu açıkça anlatır', () {
      expect(PlayCenterEntryCatalog.liveDuelTitle, 'Canlı Düello');
      expect(
        PlayCenterEntryCatalog.liveDuelDescription,
        contains('gerçek bir rakiple'),
      );
      expect(
        PlayCenterEntryCatalog.liveDuelDescription,
        contains('10, 20 veya 30'),
      );
    });

    test('kart doğru Canlı Düello ekranını açar', () {
      expect(
        PlayCenterEntryCatalog.buildLiveDuelScreen(),
        isA<LiveDuelScreen>(),
      );
    });
  });
}
