import 'dart:ui' as ui;

import 'package:flutter/services.dart';
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
      expect(WordHuntProductionAssets.requiredPilotAssets, hasLength(15));
      expect(
        WordHuntProductionAssets.requiredPilotAssets.toSet(),
        hasLength(15),
      );
      expect(
        WordHuntProductionAssets.scene,
        WordHuntProductionAssets.background,
      );
      expect(WordHuntProductionAssets.scene, isNot(contains('scene.webp')));
      expect(
        WordHuntProductionAssets.challengeIcon,
        endsWith('challenge_icon.png'),
      );
      expect(WordHuntProductionAssets.bonusIcon, endsWith('bonus_icon.png'));
      expect(WordHuntProductionAssets.finalIcon, endsWith('final_icon.png'));
    });

    for (final path in WordHuntProductionAssets.requiredPilotAssets) {
      testWidgets('Flutter codec decode eder: $path', (tester) async {
        await tester.runAsync(() async {
          final data = await rootBundle.load(path);
          final bytes = data.buffer.asUint8List(
            data.offsetInBytes,
            data.lengthInBytes,
          );
          final codec = await ui.instantiateImageCodec(bytes);
          final frame = await codec.getNextFrame();
          expect(frame.image.width, greaterThan(0), reason: path);
          expect(frame.image.height, greaterThan(0), reason: path);
          frame.image.dispose();
          codec.dispose();
        });
      });
    }
  });
}
