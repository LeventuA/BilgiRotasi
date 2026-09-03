import 'package:bilgi_rotasi/main.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_production_entry_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Kelime Avı Oyna menüsü bağlantısı', () {
    test('kart metinleri production modu açıkça anlatır', () {
      expect(PlayCenterEntryCatalog.wordHuntTitle, 'Kelime Avı');
      expect(
        PlayCenterEntryCatalog.wordHuntDescription,
        contains('Başlangıç Limanı'),
      );
      expect(PlayCenterEntryCatalog.wordHuntDescription, contains('10 bölüm'));
    });

    test('kart production Kelime Avı giriş ekranını açar', () {
      final screen = PlayCenterEntryCatalog.buildWordHuntScreen(
        ownerUid: 'test-user',
      );

      expect(screen, isA<WordHuntProductionEntryScreen>());
      expect((screen as WordHuntProductionEntryScreen).ownerUid, 'test-user');
    });
  });
}
