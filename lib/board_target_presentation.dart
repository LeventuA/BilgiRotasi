part of 'main.dart';

class BoardTargetPresentation {
  BoardTargetPresentation._();

  static Color colorFor(BoardNode node) {
    final effect = node.specialEffect;
    if (effect != null) return effect.color;

    if (node.categoryIndex >= 0 &&
        node.categoryIndex < GameCategory.values.length) {
      return GameCategory.values[node.categoryIndex].color;
    }

    return const Color(0xFF155E75);
  }

  static String emojiFor(BoardNode node) {
    final effect = node.specialEffect;
    if (effect != null) return effect.emoji;

    if (node.categoryIndex >= 0 &&
        node.categoryIndex < GameCategory.values.length) {
      return GameCategory.values[node.categoryIndex].emoji;
    }

    return '🧭';
  }

  static String semanticsLabelFor(MoveOption option) {
    final node = BoardMap.node(option.destination);
    final effect = node.specialEffect;

    if (effect != null) {
      return '${effect.title} özel alanına git';
    }

    return BoardMap.routeTitle(option);
  }
}
