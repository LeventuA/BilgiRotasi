import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WordHuntLevelDefinition level({
    required int index,
    WordHuntLevelType type = WordHuntLevelType.normal,
  }) {
    return WordHuntLevelDefinition(
      id: 'baslangic_$index',
      routeId: 'baslangic_limani',
      index: index,
      type: type,
      grid: const <String>[
        'KAPI',
        'ARMA',
        'PUSU',
        'ISIK',
      ],
      targetWords: const <String>['KAPI'],
      bonusWords: const <String>['ISIK'],
      starRules: const WordHuntStarRules(
        twoStarMaxMistakes: 2,
        threeStarMaxMistakes: 0,
      ),
      infoCardIds: const <String>['kart_kapi'],
    );
  }

  test('gecerli rota sozlesmesi hatasiz kabul edilir', () {
    final levels = List<WordHuntLevelDefinition>.generate(10, (index) {
      final number = index + 1;
      return level(
        index: number,
        type:
            number == 10
                ? WordHuntLevelType.routeFinal
                : number == 8
                ? WordHuntLevelType.bonus
                : number == 5
                ? WordHuntLevelType.challenge
                : WordHuntLevelType.normal,
      );
    });

    final route = WordHuntRouteDefinition(
      id: 'baslangic_limani',
      title: 'Başlangıç Limanı',
      theme: 'liman',
      unlockStarsRequired: 18,
      levels: levels,
      routeRewardId: 'rozet_kelime_yolcusu',
    );

    expect(route.maximumStars, 30);
    expect(WordHuntDefinitionValidator.validateRoute(route), isEmpty);
  });

  test('dikdortgen olmayan grid reddedilir', () {
    final invalid = WordHuntLevelDefinition(
      id: 'bozuk_grid',
      routeId: 'baslangic_limani',
      index: 1,
      type: WordHuntLevelType.normal,
      grid: const <String>['KAPI', 'EV'],
      targetWords: const <String>['KAPI'],
      starRules: const WordHuntStarRules(),
    );

    expect(
      WordHuntDefinitionValidator.validateLevel(invalid),
      contains('grid dikdörtgen olmalı: satır 2'),
    );
  });

  test('hedef ve bonus kelime cakismasi reddedilir', () {
    final invalid = WordHuntLevelDefinition(
      id: 'cakisma',
      routeId: 'baslangic_limani',
      index: 1,
      type: WordHuntLevelType.normal,
      grid: const <String>['KAPI', 'ARMA', 'PUSU', 'ISIK'],
      targetWords: const <String>['KAPI'],
      bonusWords: const <String>['KAPI'],
      starRules: const WordHuntStarRules(),
    );

    expect(
      WordHuntDefinitionValidator.validateLevel(invalid),
      contains('hedef ve bonus kelime çakışamaz: KAPI'),
    );
  });

  test('rota finali son durak olmak zorundadir', () {
    final route = WordHuntRouteDefinition(
      id: 'baslangic_limani',
      title: 'Başlangıç Limanı',
      theme: 'liman',
      unlockStarsRequired: 3,
      levels: <WordHuntLevelDefinition>[level(index: 1)],
      routeRewardId: 'rozet_kelime_yolcusu',
    );

    expect(
      WordHuntDefinitionValidator.validateRoute(route),
      contains('rotanın son bölümü rota finali olmalı'),
    );
  });

  test('3 yildiz hedefi 2 yildizdan daha gevsek olamaz', () {
    final invalid = WordHuntLevelDefinition(
      id: 'gevsek_yildiz',
      routeId: 'baslangic_limani',
      index: 1,
      type: WordHuntLevelType.routeFinal,
      grid: const <String>['KAPI', 'ARMA', 'PUSU', 'ISIK'],
      targetWords: const <String>['KAPI'],
      starRules: const WordHuntStarRules(
        twoStarMaxMistakes: 1,
        threeStarMaxMistakes: 2,
      ),
    );

    expect(
      WordHuntDefinitionValidator.validateLevel(invalid),
      contains('3 yıldız hata hedefi 2 yıldızdan daha gevşek olamaz'),
    );
  });

  test('rota kimligi ve indeks sirasi korunur', () {
    final wrongRouteLevel = WordHuntLevelDefinition(
      id: 'yanlis',
      routeId: 'baska_rota',
      index: 2,
      type: WordHuntLevelType.routeFinal,
      grid: const <String>['KAPI', 'ARMA', 'PUSU', 'ISIK'],
      targetWords: const <String>['KAPI'],
      starRules: const WordHuntStarRules(),
    );

    final route = WordHuntRouteDefinition(
      id: 'baslangic_limani',
      title: 'Başlangıç Limanı',
      theme: 'liman',
      unlockStarsRequired: 1,
      levels: <WordHuntLevelDefinition>[wrongRouteLevel],
      routeRewardId: 'rozet_kelime_yolcusu',
    );

    final errors = WordHuntDefinitionValidator.validateRoute(route);
    expect(errors, contains('bölüm rota kimliği eşleşmiyor: yanlis'));
    expect(errors, contains('bölüm indeksleri 1..N sıralı olmalı: yanlis'));
  });
}
