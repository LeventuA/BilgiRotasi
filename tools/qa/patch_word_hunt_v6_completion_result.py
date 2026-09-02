from pathlib import Path

SCREEN = Path('lib/word_hunt/word_hunt_screens.dart')
TEST = Path('test/word_hunt_level_production_test.dart')


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{label}: expected exactly one match, got {count}')
    return text.replace(old, new, 1)


text = SCREEN.read_text(encoding='utf-8')
text = replace_once(
    text,
    """  bool get _allTargetsFound =>\n      _foundTargets.length >= widget.level.targetWords.length;\n\n  bool get _hasMeaningfulAttempt =>\n""",
    """  bool get _allTargetsFound =>\n      _foundTargets.length >= widget.level.targetWords.length;\n\n  bool get _allBonusFound =>\n      _foundBonus.length >= widget.level.bonusWords.length;\n\n  bool get _allWordsFound => _allTargetsFound && _allBonusFound;\n\n  bool get _hasMeaningfulAttempt =>\n""",
    'all words getters',
)

text = replace_once(
    text,
    """        case WordHuntSelectionKind.invalidPath:\n          _status = result.error ?? 'Bu yol geçerli değil.';\n      }\n    });\n  }\n\n  String? _unlockInfoCardFor(String word) {\n""",
    """        case WordHuntSelectionKind.invalidPath:\n          _status = result.error ?? 'Bu yol geçerli değil.';\n      }\n    });\n    _scheduleAutoCompletionIfAllWordsFound();\n  }\n\n  void _scheduleAutoCompletionIfAllWordsFound() {\n    if (!_allWordsFound || _completionDialogOpen || _resultDelivered) return;\n    WidgetsBinding.instance.addPostFrameCallback((_) {\n      if (!mounted ||\n          !_allWordsFound ||\n          _completionDialogOpen ||\n          _resultDelivered) {\n        return;\n      }\n      unawaited(_finishLevel());\n    });\n  }\n\n  String? _unlockInfoCardFor(String word) {\n""",
    'auto completion scheduler',
)

finish_start = text.index('  Future<void> _finishLevel() async {')
dialog_start = text.index('    final leave = await showDialog<bool>(', finish_start)
dialog_end_marker = '\n\n    if (!mounted) return;'
dialog_end = text.index(dialog_end_marker, dialog_start)
old_dialog = text[dialog_start:dialog_end]
new_dialog = """    final leave = await showDialog<bool>(\n      context: context,\n      barrierDismissible: false,\n      barrierColor: const Color(0xD9000812),\n      builder: (dialogContext) => _HarborCompletionDialog(\n        stars: score.stars,\n        elapsedSeconds: elapsed,\n        mistakes: _scoredMistakes,\n        bonusWords: _foundBonus.toList(growable: false),\n        onReturn: () => Navigator.of(dialogContext).pop(true),\n      ),\n    );"""
text = text[:dialog_start] + new_dialog + text[dialog_end:]

completion_widget = r'''
class _HarborCompletionDialog extends StatelessWidget {
  const _HarborCompletionDialog({
    required this.stars,
    required this.elapsedSeconds,
    required this.mistakes,
    required this.bonusWords,
    required this.onReturn,
  });

  final int stars;
  final int elapsedSeconds;
  final int mistakes;
  final List<String> bonusWords;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const Key('word_hunt_production_result_dialog'),
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),
        child: Container(
          key: const Key('word_hunt_production_result_panel'),
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Color(0xFF0B2137), Color(0xFF061525)],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFD29A43), width: 1.4),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0xCC000000),
                blurRadius: 28,
                offset: Offset(0, 14),
              ),
              BoxShadow(color: Color(0x33FFCA62), blurRadius: 18),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 54,
                height: 4,
                decoration: BoxDecoration(
                  color: _harborGold,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(color: Color(0x66FFCA62), blurRadius: 8),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Icon(Icons.anchor_rounded, color: _harborGold, size: 34),
              const SizedBox(height: 8),
              const Text(
                'Bölüm Tamamlandı',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _harborCream,
                  fontFamily: 'serif',
                  fontSize: 25,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .2,
                  shadows: <Shadow>[
                    Shadow(color: Color(0xE0000000), blurRadius: 7),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Başlangıç Limanı',
                style: TextStyle(
                  color: Color(0xFFD9A64F),
                  fontFamily: 'serif',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .4,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(
                  3,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      index < stars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      key: Key('word_hunt_production_result_star_${index + 1}'),
                      size: 40,
                      color: index < stars
                          ? const Color(0xFFFFCF5C)
                          : const Color(0xFF6D6A62),
                      shadows: index < stars
                          ? const <Shadow>[
                              Shadow(color: Color(0x66FFB52A), blurRadius: 10),
                            ]
                          : const <Shadow>[],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(height: 1, color: const Color(0x557C5A2A)),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _HarborResultMetric(
                      icon: Icons.timer_outlined,
                      value: '$elapsedSeconds saniye',
                      valueKey: const Key('word_hunt_production_result_elapsed'),
                      label: 'Süre',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _HarborResultMetric(
                      icon: Icons.close_rounded,
                      value: '$mistakes hata',
                      valueKey: const Key('word_hunt_production_result_mistakes'),
                      label: 'Hata',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _HarborResultMetric(
                      icon: Icons.auto_awesome_rounded,
                      value: '${bonusWords.length}',
                      label: 'Bonus',
                    ),
                  ),
                ],
              ),
              if (bonusWords.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0x99261307),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF8F642A)),
                  ),
                  child: Text(
                    '✦ Bonus: ${bonusWords.join(' • ')}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFFFD47B),
                      fontFamily: 'serif',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  key: const Key('word_hunt_production_return_route'),
                  onPressed: onReturn,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF8A5A16),
                    foregroundColor: _harborCream,
                    side: const BorderSide(color: _harborGold, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  icon: const Icon(Icons.route_rounded, size: 20),
                  label: const Text('Rotaya Dön'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HarborResultMetric extends StatelessWidget {
  const _HarborResultMetric({
    required this.icon,
    required this.value,
    required this.label,
    this.valueKey,
  });

  final IconData icon;
  final String value;
  final String label;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xB3091827),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x557C5A2A)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: const Color(0xFFD9A64F), size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            key: valueKey,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _harborCream,
              fontFamily: 'serif',
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9AA8B8),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

'''
text = replace_once(
    text,
    'class _HarborGameplayHeader extends StatelessWidget {\n',
    completion_widget + 'class _HarborGameplayHeader extends StatelessWidget {\n',
    'completion dialog widget',
)
SCREEN.write_text(text, encoding='utf-8')

test = TEST.read_text(encoding='utf-8')
test = replace_once(
    test,
    """      expect(\n        find.byKey(const Key('word_hunt_production_result_dialog')),\n        findsNothing,\n      );\n\n      await tester.ensureVisible(\n        find.byKey(const Key('word_hunt_production_finish')),\n      );\n      await tester.tap(find.byKey(const Key('word_hunt_production_finish')));\n      await tester.pumpAndSettle();\n      expect(\n        find.byKey(const Key('word_hunt_production_result_dialog')),\n        findsOneWidget,\n      );\n""",
    """      await tester.pumpAndSettle();\n      expect(\n        find.byKey(const Key('word_hunt_production_result_dialog')),\n        findsOneWidget,\n      );\n      expect(find.byType(AlertDialog), findsNothing);\n      expect(\n        find.byKey(const Key('word_hunt_production_result_panel')),\n        findsOneWidget,\n      );\n""",
    'auto dialog expectation',
)

replay_test = r'''
  testWidgets('tüm kelimeler tamamlanınca sonuç dialogu yeni oturumda yeniden açılır', (
    tester,
  ) async {
    for (var attempt = 1; attempt <= 2; attempt++) {
      await pumpLevel(tester);
      await completeLevelOneTargets(tester);
      expect(
        find.byKey(const Key('word_hunt_production_result_dialog')),
        findsNothing,
        reason: 'attempt $attempt ana hedeflerden sonra bonus için açık kalmalı',
      );
      await dragCells(
        tester,
        startRow: 4,
        startColumn: 2,
        endRow: 4,
        endColumn: 5,
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('word_hunt_production_result_dialog')),
        findsOneWidget,
        reason: 'attempt $attempt tüm kelimelerde otomatik açılmalı',
      );
      expect(
        find.byKey(const Key('word_hunt_production_result_panel')),
        findsOneWidget,
      );
    }
  });

'''
test = replace_once(
    test,
    "  testWidgets('timeLimit production oynanışı hard fail ile kapatmaz', (\n",
    replay_test + "  testWidgets('timeLimit production oynanışı hard fail ile kapatmaz', (\n",
    'replay regression test',
)
TEST.write_text(test, encoding='utf-8')
