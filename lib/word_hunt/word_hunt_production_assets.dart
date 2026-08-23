import 'word_hunt_models.dart';

/// Başlangıç Limanı production-ready layered asset yollarının tek kaynağı.
///
/// Bu sınıf progression veya oyun state'i tutmaz. Yalnız mevcut domain
/// state'inden hangi görsel asset'in seçileceğini belirler.
class WordHuntProductionAssets {
  WordHuntProductionAssets._();

  static const String base = 'assets/word_hunt/baslangic_limani';

  static const String scene = '$base/scene.webp';

  static const String nodeNormal = '$base/node_normal.webp';
  static const String nodeLocked = '$base/node_locked.webp';
  static const String nodeChallenge = '$base/node_challenge.webp';
  static const String nodeBonus = '$base/node_bonus.webp';
  static const String nodeFinal = '$base/node_final.webp';

  static const String challengePlaque = '$base/challenge_plaque.webp';
  static const String bonusPlaque = '$base/bonus_plaque.webp';
  static const String finalPlaque = '$base/final_plaque.webp';
  static const String finalCrown = '$base/final_crown.webp';

  static const String compassButton = '$base/compass_button.webp';
  static const String bookButton = '$base/book_button.webp';

  /// Kilitli final progression bakımından oynanamaz kalsa da MASTER ART'taki
  /// altın hedef görünümünü korur. Interaction kararı bu sınıfın işi değildir.
  static String nodeFor({
    required WordHuntLevelType type,
    required bool unlocked,
  }) {
    if (!unlocked && type != WordHuntLevelType.routeFinal) {
      return nodeLocked;
    }

    return switch (type) {
      WordHuntLevelType.normal => nodeNormal,
      WordHuntLevelType.challenge => nodeChallenge,
      WordHuntLevelType.bonus => nodeBonus,
      WordHuntLevelType.routeFinal => nodeFinal,
    };
  }

  static String? plaqueFor(WordHuntLevelType type) => switch (type) {
    WordHuntLevelType.normal => null,
    WordHuntLevelType.challenge => challengePlaque,
    WordHuntLevelType.bonus => bonusPlaque,
    WordHuntLevelType.routeFinal => finalPlaque,
  };

  static const List<String> requiredPilotAssets = <String>[
    scene,
    nodeNormal,
    nodeLocked,
    nodeChallenge,
    nodeBonus,
    nodeFinal,
    challengePlaque,
    bonusPlaque,
    finalPlaque,
    finalCrown,
    compassButton,
    bookButton,
  ];
}
