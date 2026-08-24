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

  testWidgets('pixel proof renders one raster scene and transparent hitboxes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(540, 960));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: WordHuntPixelProofScreen()),
    );
    await tester.pump();

    final images = tester.widgetList<Image>(find.byType(Image)).toList();
    expect(images, hasLength(1));
    expect(
      (images.single.image as AssetImage).assetName,
      WordHuntPixelProofAssets.masterArt,
    );
    expect(images.single.fit, BoxFit.fill);
    expect(images.single.filterQuality, FilterQuality.none);

    expect(find.byType(Text), findsNothing);
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
    expect(find.byKey(const Key('word_hunt_pixel_proof_book')), findsOneWidget);
  });

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

    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntPixelProofScreen(
          progress: const WordHuntProgressSnapshot(),
          onCompass: () => compassTaps++,
          onBook: () => bookTaps++,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('word_hunt_pixel_proof_compass')));
    await tester.tap(find.byKey(const Key('word_hunt_pixel_proof_book')));
    await tester.pump();
    expect(compassTaps, 1);
    expect(bookTaps, 1);
  });
}
