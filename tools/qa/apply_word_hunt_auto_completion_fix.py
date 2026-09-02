from pathlib import Path
import re

screen_path = Path('lib/word_hunt/word_hunt_screens.dart')
text = screen_path.read_text()

result_anchor = """    final result = WordHuntPathEngine.evaluate(
      level: widget.level,
      path: selectedPath,
      foundTargetWords: _foundTargets,
      foundBonusWords: _foundBonus,
    );

    setState(() {
"""
if text.count(result_anchor) != 1:
    raise SystemExit(f'result anchor count={text.count(result_anchor)}')
text = text.replace(
    result_anchor,
    result_anchor.replace(
        '\n\n    setState(() {',
        '\n\n    var shouldAutoFinish = false;\n    setState(() {',
    ),
    1,
)

freeze_anchor = """            _completionMistakes = _mistakes;
            _timer?.cancel();
          }
"""
if text.count(freeze_anchor) != 1:
    raise SystemExit(f'freeze anchor count={text.count(freeze_anchor)}')
text = text.replace(
    freeze_anchor,
    """            _completionMistakes = _mistakes;
            _timer?.cancel();
            shouldAutoFinish = true;
          }
""",
    1,
)

end_anchor = """    });
  }

  String? _unlockInfoCardFor(String word) {
"""
if text.count(end_anchor) != 1:
    raise SystemExit(f'pointer-up end anchor count={text.count(end_anchor)}')
text = text.replace(
    end_anchor,
    """    });
    if (shouldAutoFinish) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_finishLevel());
      });
    }
  }

  String? _unlockInfoCardFor(String word) {
""",
    1,
)
screen_path.write_text(text)

test_path = Path('test/word_hunt_level_production_test.dart')
tests = test_path.read_text()
pattern = re.compile(
    r"  testWidgets\(\n    'targetlar bitince süre ve hata donar, grid bonus için açık kalır',.*?\n  \);\n\n  testWidgets\('timeLimit",
    re.S,
)
replacement = """  testWidgets(
    'targetlar bitince sonuç otomatik açılır ve süre hata donar',
    (tester) async {
      var now = DateTime(2026, 8, 29, 12);
      await pumpLevel(tester, now: () => now);

      await dragCells(
        tester,
        startRow: 0,
        startColumn: 0,
        endRow: 0,
        endColumn: 1,
      );
      expect(find.text('1 hata'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));

      now = now.add(const Duration(seconds: 10));
      await dragCells(
        tester,
        startRow: 4,
        startColumn: 2,
        endRow: 4,
        endColumn: 5,
      );
      expect(
        find.byKey(const Key('word_hunt_production_bonus_ELMA_found')),
        findsOneWidget,
      );

      await completeLevelOneTargets(tester);
      await tester.pumpAndSettle();

      expect(find.text('5/5'), findsOneWidget);
      expect(
        find.byKey(const Key('word_hunt_production_result_dialog')),
        findsOneWidget,
      );
      expect(find.text('10 saniye'), findsOneWidget);
      expect(find.text('1 hata'), findsWidgets);
      expect(find.text('Bonus: ELMA'), findsOneWidget);

      final frozen =
          tester
              .widget<Text>(
                find.byKey(const Key('word_hunt_production_elapsed_text')),
              )
              .data;
      expect(frozen, '10s');

      now = now.add(const Duration(seconds: 20));
      await tester.pump(const Duration(seconds: 2));
      expect(
        tester
            .widget<Text>(
              find.byKey(const Key('word_hunt_production_elapsed_text')),
            )
            .data,
        frozen,
      );
      expect(
        find.byKey(const Key('word_hunt_production_result_dialog')),
        findsOneWidget,
      );
      expect(
        tester
            .widget<Icon>(
              find.byKey(const Key('word_hunt_production_result_star_2')),
            )
            .icon,
        Icons.star_rounded,
      );
      expect(
        tester
            .widget<Icon>(
              find.byKey(const Key('word_hunt_production_result_star_3')),
            )
            .icon,
        Icons.star_outline_rounded,
      );
    },
  );

  testWidgets('timeLimit"""
tests, count = pattern.subn(replacement, tests, count=1)
if count != 1:
    raise SystemExit(f'legacy test replacement count={count}')
test_path.write_text(tests)
