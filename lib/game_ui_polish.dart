part of 'main.dart';

class GameUiMetrics {
  GameUiMetrics._();

  static const double wideBreakpoint = 760;
  static const double maximumBoardSize = 720;

  static bool isCompact(double width) => width < wideBreakpoint;

  static double boardSize(double availableWidth) {
    if (availableWidth <= 0) return 0;
    return min(availableWidth, maximumBoardSize);
  }

  static String actionLabel({
    required bool busy,
    required bool hasAllBadges,
  }) {
    if (busy) return 'Bekle…';
    return hasAllBadges ? 'Final Sorusuna Geç' : 'Zarı At';
  }

  static IconData actionIcon({
    required bool busy,
    required bool hasAllBadges,
  }) {
    if (busy) return Icons.hourglass_top_rounded;
    return hasAllBadges
        ? Icons.emoji_events_rounded
        : Icons.casino_rounded;
  }
}

class GameMobileActionBar extends StatelessWidget {
  const GameMobileActionBar({
    required this.player,
    required this.busy,
    required this.hasWinner,
    required this.onPressed,
    super.key,
  });

  final PlayerData player;
  final bool busy;
  final bool hasWinner;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = !busy && !hasWinner;
    final label = GameUiMetrics.actionLabel(
      busy: busy,
      hasAllBadges: player.hasAllBadges,
    );
    final icon = GameUiMetrics.actionIcon(
      busy: busy,
      hasAllBadges: player.hasAllBadges,
    );

    return SafeArea(
      top: false,
      child: Material(
        color: Colors.white,
        elevation: 18,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: player.color.withValues(alpha: 0.24),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: player.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: player.color.withValues(alpha: 0.32),
                  ),
                ),
                child: PawnToken(
                  type: player.pawnType,
                  color: player.color,
                  active: true,
                  width: 31,
                  height: 38,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${player.badges.length}/6 rozet • '
                      '${player.correctAnswers} doğru',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: enabled ? onPressed : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: player.hasAllBadges
                        ? const Color(0xFFB45309)
                        : const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      icon,
                      key: ValueKey<IconData>(icon),
                    ),
                  ),
                  label: Text(
                    label,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameTurnHeader extends StatelessWidget {
  const GameTurnHeader({
    required this.player,
    required this.lastDice,
    super.key,
  });

  final PlayerData player;
  final int? lastDice;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            player.color.withValues(alpha: 0.16),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: player.color.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: [
          PawnToken(
            type: player.pawnType,
            color: player.color,
            active: true,
            width: 55,
            height: 68,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SIRA',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  player.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${player.badges.length}/6 rozet • '
                  '${player.correctAnswers + player.wrongAnswers} cevap',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          DiceFace(value: lastDice),
        ],
      ),
    );
  }
}

class GameBadgeStrip extends StatelessWidget {
  const GameBadgeStrip({
    required this.player,
    super.key,
  });

  final PlayerData player;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var index = 0; index < GameCategory.values.length; index++)
          _badge(index),
      ],
    );
  }

  Widget _badge(int index) {
    final category = GameCategory.values[index];
    final earned = player.badges.contains(index);

    return Tooltip(
      message: category.label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 39,
        height: 39,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: earned ? category.color : const Color(0xFFF1F5F9),
          shape: BoxShape.circle,
          border: Border.all(
            color: earned ? Colors.white : const Color(0xFFCBD5E1),
            width: 2,
          ),
          boxShadow: earned
              ? [
                  BoxShadow(
                    blurRadius: 8,
                    spreadRadius: 1,
                    color: category.color.withValues(alpha: 0.36),
                  ),
                ]
              : null,
        ),
        child: Text(
          earned ? '✓' : category.emoji,
          style: TextStyle(
            fontWeight: earned ? FontWeight.w900 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class GameStatusBanner extends StatelessWidget {
  const GameStatusBanner({
    required this.status,
    required this.busy,
    required this.waitingForRoute,
    required this.playerColor,
    super.key,
  });

  final String status;
  final bool busy;
  final bool waitingForRoute;
  final Color playerColor;

  @override
  Widget build(BuildContext context) {
    final lower = status.toLowerCase();

    final IconData icon;
    final Color accent;

    if (waitingForRoute) {
      icon = Icons.alt_route_rounded;
      accent = const Color(0xFF2563EB);
    } else if (busy) {
      icon = Icons.hourglass_top_rounded;
      accent = const Color(0xFF7C3AED);
    } else if (lower.contains('doğru')) {
      icon = Icons.check_circle_rounded;
      accent = const Color(0xFF16A34A);
    } else if (lower.contains('yanlış')) {
      icon = Icons.cancel_rounded;
      accent = const Color(0xFFDC2626);
    } else if (lower.contains('rozet')) {
      icon = Icons.workspace_premium_rounded;
      accent = const Color(0xFFB45309);
    } else {
      icon = Icons.explore_rounded;
      accent = playerColor;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accent.withValues(alpha: 0.28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                icon,
                key: ValueKey<IconData>(icon),
                color: accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Text(
                  status,
                  key: ValueKey<String>(status),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameProgressSummary extends StatelessWidget {
  const GameProgressSummary({
    required this.player,
    required this.difficultyText,
    required this.usedQuestionCount,
    required this.totalQuestionCount,
    super.key,
  });

  final PlayerData player;
  final String difficultyText;
  final int usedQuestionCount;
  final int totalQuestionCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _stat(
                emoji: '✅',
                value: '${player.correctAnswers}',
                label: 'Doğru',
                color: const Color(0xFF16A34A),
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _stat(
                emoji: '❌',
                value: '${player.wrongAnswers}',
                label: 'Yanlış',
                color: const Color(0xFFDC2626),
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _stat(
                emoji: '🧩',
                value: '$usedQuestionCount',
                label: 'Farklı soru',
                color: const Color(0xFF2563EB),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFF155E75).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF155E75).withValues(alpha: 0.22),
            ),
          ),
          child: Text(
            '🧠 $difficultyText • '
            '$usedQuestionCount/$totalQuestionCount soru',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _stat({
    required String emoji,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        children: [
          Text(emoji),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
