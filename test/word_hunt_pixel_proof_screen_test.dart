import 'dart:io';

import 'package:bilgi_rotasi/word_hunt/word_hunt_pixel_proof_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('pixel proof source is the untouched Issue 109 Photo 1 JPEG', () {
    final file = File(WordHuntPixelProofAssets.masterArt);
    expect(file.lengthSync(), 156589);
    expect(
      sha256.convert(file.readAsBytesSync()).toString(),
      'fb4597bb4d37b30cefeec2ba913c591fe9471529f80966830afd5b801a86fca3',
    );
    final source = img.decodeJpg(file.readAsBytesSync());
    expect(source, isNotNull);
    expect(source!.width, 720);
    expect(source.height, 1280);
  });

  testWidgets(
    'pixel proof keeps master scene and overrides only node 9 as normal/open',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(540, 960));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(home: WordHuntPixelProofScreen()),
      );
      await tester.pump();

      final images = tester.widgetList<Image>(find.byType(Image)).toList();
      expect(images, hasLength(2));
      final masterArt = tester.widget<Image>(
        find.byKey(const Key('word_hunt_pixel_proof_master_art')),
      );
      expect(
        (masterArt.image as AssetImage).assetName,
        WordHuntPixelProofAssets.masterArt,
      );
      expect(masterArt.fit, BoxFit.fill);
      expect(masterArt.filterQuality, FilterQuality.none);

      final nodeNine = tester.widget<Image>(
        find.byKey(const Key('word_hunt_pixel_proof_node_9_asset')),
      );
      expect(
        (nodeNine.image as AssetImage).assetName,
        WordHuntPixelProofAssets.nodeNineOpen,
      );
      expect(find.text('9'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsNothing);
      expect(find.byIcon(Icons.star_rounded), findsNothing);

      final override = find.byKey(
        const Key('word_hunt_pixel_proof_node_9_override'),
      );
      expect(tester.getSize(override), const Size.square(72));
      expect(
        tester.getCenter(override),
        offsetMoreOrLessEquals(const Offset(127.44, 669.12), epsilon: 0.01),
      );

      final scene = find.byKey(const Key('word_hunt_pixel_proof_source_scene'));
      expect(
        find.descendant(of: scene, matching: find.byType(CustomPaint)),
        findsNothing,
      );
      for (var level = 1; level <= 10; level++) {
        expect(
          find.byKey(Key('word_hunt_pixel_proof_level_$level')),
          findsOneWidget,
        );
      }
      expect(
        find.byKey(const Key('word_hunt_pixel_proof_compass')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('word_hunt_pixel_proof_book')),
        findsOneWidget,
      );
    },
  );

  testWidgets('pixel proof keeps progression callbacks behind invisible art', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(540, 960));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final tapped = <int>[];

    await tester.pumpWidget(
      MaterialApp(home: WordHuntPixelProofScreen(onLevelTap: tapped.add)),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('word_hunt_pixel_proof_level_1')));
    await tester.pump();
    expect(tapped, <int>[1]);

    await tester.tap(find.byKey(const Key('word_hunt_pixel_proof_level_10')));
    await tester.pump();
    expect(tapped, <int>[
      1,
    ], reason: 'Progression kilitli final hitbox callback üretmemeli.');
  });

  testWidgets('pixel proof controls preserve existing callbacks', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(540, 960));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var compassTaps = 0;
    var bookTaps = 0;
    var backTaps = 0;
    var infoTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntPixelProofScreen(
          progress: const WordHuntProgressSnapshot(),
          onCompass: () => compassTaps++,
          onBook: () => bookTaps++,
          onBack: () => backTaps++,
          onInfo: () => infoTaps++,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('word_hunt_pixel_proof_compass')));
    await tester.tap(find.byKey(const Key('word_hunt_pixel_proof_book')));
    await tester.tap(find.byKey(const Key('word_hunt_pixel_proof_back')));
    await tester.tap(find.byKey(const Key('word_hunt_pixel_proof_info')));
    await tester.pump();
    expect(compassTaps, 1);
    expect(bookTaps, 1);
    expect(backTaps, 1);
    expect(infoTaps, 1);
  });
}
