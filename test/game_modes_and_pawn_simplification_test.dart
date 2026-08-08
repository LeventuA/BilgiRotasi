import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('oyun modları sadeleştirme sözleşmesi', () {
    final quickModes = File('lib/quick_modes.dart').readAsStringSync();
    final navigation = File('lib/main_navigation.dart').readAsStringSync();

    test('başlık sayıdan bağımsız ve içerik kompakt kalır', () {
      expect(quickModes, contains('Farklı mücadele modları'));
      expect(quickModes, isNot(contains('Yedi farklı mücadele')));
      expect(quickModes, isNot(contains('7 Oyun Modu')));
      expect(
        quickModes,
        contains('EdgeInsets.symmetric(horizontal: 16, vertical: 14)'),
      );
      expect(
        quickModes,
        contains('EdgeInsets.symmetric(horizontal: 15, vertical: 13)'),
      );
    });

    test('Aile ve Turnuva kartları ile navigasyonları kaldırılmıştır', () {
      expect(quickModes, isNot(contains("title: 'Aile Modu'")));
      expect(quickModes, isNot(contains('FamilyModeSetupScreen(')));
      expect(quickModes, isNot(contains("title: 'Turnuva Modu'")));
      expect(quickModes, isNot(contains('TournamentSetupScreen(')));
      expect(navigation, isNot(contains('Aile, Takım')));
      expect(navigation, isNot(contains('Turnuva ve Karışık')));
    });
  });

  group('piyon nadirliği kaldırma sözleşmesi', () {
    final career = File('lib/career_collection_update.dart').readAsStringSync();
    final navigation = File('lib/main_navigation.dart').readAsStringSync();
    final picker = File('lib/premium_pawn_picker.dart').readAsStringSync();
    final collection = File('lib/visual_collection.dart').readAsStringSync();
    final main = File('lib/main.dart').readAsStringSync();

    test('nadirlik modeli, ekranı ve kariyer girişi yoktur', () {
      expect(career, isNot(contains('PawnRarity')));
      expect(navigation, isNot(contains('Piyon Nadirlikleri')));
      expect(navigation, isNot(contains('PawnRarityScreen')));
      expect(picker, isNot(contains('isSpecial')));
      expect(picker, isNot(contains("_badge('ÖZEL'")));
    });

    test('piyon kataloğu ve eski indeksler için güvenli fallback korunur', () {
      expect(main, contains('class PawnCatalog'));
      expect(main, contains('static PawnDefinition at(int index)'));
      expect(main, contains('(index % all.length + all.length) % all.length'));
      expect(collection, contains("'favoritePawn': favoritePawn"));
      expect(collection, contains('.clamp(0, PawnCatalog.all.length - 1)'));
    });
  });
}
