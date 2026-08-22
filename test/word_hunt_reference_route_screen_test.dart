import 'package:bilgi_rotasi/word_hunt/word_hunt_reference_route_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpReferenceRoute(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(411, 891));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: WordHuntReferenceRouteScreen(),
      ),
    );
    await tester.pump();
  }

  Offset centerOf(WidgetTester tester, int level) {
    return tester.getCenter(
      find.byKey(Key('word_hunt_reference_level_$level')),
    );
  }

  Rect rectOf(WidgetTester tester, int level) {
    return tester.getRect(
      find.byKey(Key('word_hunt_reference_level_$level')),
    );
  }

  testWidgets('reference route follows the approved composition hierarchy', (
    tester,
  ) async {
    await pumpReferenceRoute(tester);

    for (var level = 1; level <= 10; level++) {
      expect(
        find.byKey(Key('word_hunt_reference_level_$level')),
        findsOneWidget,
      );
    }

    final one = centerOf(tester, 1);
    final two = centerOf(tester, 2);
    final three = centerOf(tester, 3);
    final four = centerOf(tester, 4);
    final five = centerOf(tester, 5);
    final six = centerOf(tester, 6);
    final seven = centerOf(tester, 7);
    final eight = centerOf(tester, 8);
    final nine = centerOf(tester, 9);
    final ten = centerOf(tester, 10);

    expect(one.dy, lessThan(five.dy));
    expect(two.dy, lessThan(five.dy));
    expect(three.dy, lessThan(five.dy));
    expect(four.dy, lessThan(five.dy));

    expect(five.dx, lessThan(411 * 0.48));
    expect(six.dx, lessThan(seven.dx));
    expect(seven.dx - nine.dx, greaterThan(85));
    expect(eight.dx, greaterThan(five.dx));
    expect(nine.dx, lessThan(seven.dx));
    expect(ten.dy, greaterThan(nine.dy));
    expect((ten.dx - 411 / 2).abs(), lessThan(65));
  });

  testWidgets('upper stops keep enough breathing room for node and stars', (
    tester,
  ) async {
    await pumpReferenceRoute(tester);

    final three = rectOf(tester, 3);
    final four = rectOf(tester, 4);

    expect(
      three.overlaps(four),
      isFalse,
      reason: '3 ve 4 durak kutuları veya yıldız alanları üst üste binmemeli.',
    );
    expect(
      four.top - three.bottom,
      greaterThanOrEqualTo(8),
      reason: '1-4 üst bölgesi referanstaki gibi ferah kalmalı.',
    );
  });

  testWidgets('special labels stay to the right of stops 5, 8 and 10', (
    tester,
  ) async {
    await pumpReferenceRoute(tester);

    for (final entry in <(int, String)>[
      (5, 'MEYDAN OKUMA'),
      (8, 'BONUS DURAK'),
      (10, 'ROTA FİNALİ'),
    ]) {
      final orb = tester.getCenter(
        find.byKey(Key('word_hunt_route_stop_orb_${entry.$1}')),
      );
      final label = tester.getCenter(find.text(entry.$2));
      expect(
        label.dx,
        greaterThan(orb.dx),
        reason: '${entry.$1} özel etiketi referanstaki gibi sağda kalmalı.',
      );
    }
  });

  testWidgets('reference route omits rejected scenic labels and keeps bottom controls', (
    tester,
  ) async {
    await pumpReferenceRoute(tester);

    expect(find.text('Fener'), findsNothing);
    expect(find.text('Liman'), findsNothing);
    expect(find.text('Hazine'), findsNothing);

    final compass = find.byKey(const Key('word_hunt_reference_compass'));
    final book = find.byKey(const Key('word_hunt_reference_book'));
    expect(compass, findsOneWidget);
    expect(book, findsOneWidget);
    expect(tester.getCenter(compass).dx, lessThan(tester.getCenter(book).dx));
  });

  testWidgets('reference screen remains an isolated prototype with all route levels visible', (
    tester,
  ) async {
    await pumpReferenceRoute(tester);

    expect(find.text('KELİME AVI'), findsOneWidget);
    expect(find.text('BAŞLANGIÇ LİMANI'), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_reference_route_area')), findsOneWidget);
  });
}
