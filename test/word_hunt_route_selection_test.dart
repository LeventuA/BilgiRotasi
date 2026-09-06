import 'dart:io';

import 'package:bilgi_rotasi/word_hunt/word_hunt_gokyuzu_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/word_hunt/word_hunt_production_entry_screen.dart',
  ).readAsStringSync();

  test('production giriş iki rotalı selector sözleşmesini taşır', () {
    expect(source, contains("Key('word_hunt_route_selector')"));
    expect(source, contains("Key('word_hunt_route_card_starter')"));
    expect(source, contains("Key('word_hunt_route_card_gokyuzu')"));
    expect(source, contains('WordHuntStarterContent.baslangicLimani'));
    expect(source, contains('WordHuntGokyuzuContent.gokyuzuAdalari'));
    expect(source, contains("'Rotanı seç'"));
  });

  test('Gökyüzü kapısı 18 Başlangıç Limanı yıldızına bağlıdır', () {
    expect(WordHuntGokyuzuContent.gokyuzuAdalari.unlockStarsRequired, 18);

    const progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        'baslangic-1': 3,
        'baslangic-2': 3,
        'baslangic-3': 3,
        'baslangic-4': 3,
        'baslangic-5': 3,
        'baslangic-6': 3,
      },
    );
    final starterStars = WordHuntRouteProgressEngine.totalStars(
      WordHuntStarterContent.baslangicLimani,
      progress,
    );

    expect(starterStars, 18);
    expect(
      starterStars >= WordHuntGokyuzuContent.gokyuzuAdalari.unlockStarsRequired,
      isTrue,
    );
  });

  test('17 yıldızda Gökyüzü kapısı kapalı kalır', () {
    const progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        'baslangic-1': 3,
        'baslangic-2': 3,
        'baslangic-3': 3,
        'baslangic-4': 3,
        'baslangic-5': 3,
        'baslangic-6': 2,
      },
    );
    final starterStars = WordHuntRouteProgressEngine.totalStars(
      WordHuntStarterContent.baslangicLimani,
      progress,
    );

    expect(starterStars, 17);
    expect(
      starterStars >= WordHuntGokyuzuContent.gokyuzuAdalari.unlockStarsRequired,
      isFalse,
    );
  });

  test('QA belirli rotayı selector olmadan doğrudan açabilir', () {
    expect(source, contains('this.routeSelectionEnabled = true'));
    expect(source, contains('final bool routeSelectionEnabled;'));
    expect(source, contains('widget.routeSelectionEnabled &&'));
    expect(
      source,
      contains("Key('word_hunt_production_entry_gokyuzu_route')"),
    );
  });
}
