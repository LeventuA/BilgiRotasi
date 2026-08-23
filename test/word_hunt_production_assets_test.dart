import 'package:flutter_test/flutter_test.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_production_assets.dart';

void main() {
  group('WordHuntProductionAssets', () {
    test('açık node tipleri doğru production asset ile eşleşir', () {
      expect(
        WordHuntProductionAssets.nodeFor(
          type: WordHuntLevelType.normal,
          unlocked: true,
        ),
        WordHuntProductionAssets.nodeNormal,
      );
      expect(
        WordHuntProductionAssets.nodeFor(
          type: WordHuntLevelType.challenge,
          unlocked: true,
        ),
        WordHuntProductionAssets.nodeChallenge,
      );
      expect(
        WordHuntProductionAssets.nodeFor(
          type: WordHuntLevelType.bonus,
          unlocked: true,
        ),
        WordHuntProductionAssets.nodeBonus,
      );
      expect(
        WordHuntProductionAssets.nodeFor(
          type: WordHuntLevelType.routeFinal,
          unlocked: true,
        ),
        WordHuntProductionAssets.nodeFinal,
      );
    });

    test('kilitli normal/challenge/bonus ortak locked asset kullanır', () {
      for (final type in <WordHuntLevelType>[
        WordHuntLevelType.normal,
        WordHuntLevelType.challenge,
        WordHuntLevelType.bonus,
      ]) {
        expect(
          WordHuntProductionAssets.nodeFor(type: type, unlocked: false),
          WordHuntProductionAssets.nodeLocked,
        );
      }
    });

    test('kilitli final altın hedef asset görünümünü korur', () {
      expect(
        WordHuntProductionAssets.nodeFor(
          type: WordHuntLevelType.routeFinal,
          unlocked: false,
        ),
        WordHuntProductionAssets.nodeFinal,
      );
    });

    test('özel node plaque eşleşmeleri tek kaynaktan gelir', () {
      expect(
        WordHuntProductionAssets.plaqueFor(WordHuntLevelType.normal),
        isNull,
      );
      expect(
        WordHuntProductionAssets.plaqueFor(WordHuntLevelType.challenge),
        WordHuntProductionAssets.challengePlaque,
      );
      expect(
        WordHuntProductionAssets.plaqueFor(WordHuntLevelType.bonus),
        WordHuntProductionAssets.bonusPlaque,
      );
      expect(
        WordHuntProductionAssets.plaqueFor(WordHuntLevelType.routeFinal),
        WordHuntProductionAssets.finalPlaque,
      );
    });

    test('pilot required asset listesi eksiksiz ve tekrarsızdır', () {
      expect(WordHuntProductionAssets.requiredPilotAssets, hasLength(12));
      expect(
        WordHuntProductionAssets.requiredPilotAssets.toSet(),
        hasLength(12),
      );
      expect(
        WordHuntProductionAssets.requiredPilotAssets,
        everyElement(startsWith('assets/word_hunt/baslangic_limani/')),
      );
    });
  });
}
