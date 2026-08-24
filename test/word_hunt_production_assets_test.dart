import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
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

    test('5, 10 ve kitap yalnız bağlayıcı MASTER ART extraction kaynağıdır', () {
      final manifest =
          jsonDecode(
                File(
                  'reports/master_art_extraction_manifest.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      expect(manifest['source'], 'Issue #109 Photo 1.jpg');
      expect(
        manifest['source_sha256'],
        'faf8a4a2598e7e63fc857e694483a923fd3d3994e242b9f1b83554693ed52160',
      );
      expect(manifest['method'], 'direct-source-pixels-crop-mask-alpha');

      final assets = manifest['assets'] as Map<String, dynamic>;
      for (final entry in <(String, String)>[
        ('node_challenge.webp', WordHuntProductionAssets.nodeChallenge),
        ('node_final.webp', WordHuntProductionAssets.nodeFinal),
        ('book_button.webp', WordHuntProductionAssets.bookButton),
      ]) {
        final metadata = assets[entry.$1] as Map<String, dynamic>;
        final bytes = File(entry.$2).readAsBytesSync();
        expect(sha256.convert(bytes).toString(), metadata['sha256']);
        expect(metadata['source_pixel_identity'], true);
        expect(metadata['generated_art'], false);
      }
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
