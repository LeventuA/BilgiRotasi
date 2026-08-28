from pathlib import Path


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{label} marker count={count}")
    return text.replace(old, new, 1)


screen_path = Path("lib/word_hunt/word_hunt_screens.dart")
text = screen_path.read_text(encoding="utf-8")
prod_start = text.index("class _WordHuntLevelProductionScreenState")
prod_end = text.index("/// İzole rota ekranı", prod_start)
prod = text[prod_start:prod_end]

prod = replace_once(
    prod,
    """        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(""",
    """        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
            child: Column(""",
    "production scroll",
)

prod = replace_once(
    prod,
    """                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,""",
    """                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,""",
    "production target wrap",
)

grid_start_marker = """                const SizedBox(height: 16),
                AspectRatio(
"""
grid_end_marker = """                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(minHeight: 48),"""
grid_start = prod.index(grid_start_marker)
grid_end = prod.index(grid_end_marker, grid_start)

new_grid = """                const SizedBox(height: 8),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final spacing = constraints.maxHeight < 380 ? 3.0 : 5.0;
                      final columns = widget.level.columnCount;
                      final rows = widget.level.rowCount;
                      final availableWidth = math.max(
                        1.0,
                        constraints.maxWidth - ((columns - 1) * spacing),
                      );
                      final availableHeight = math.max(
                        1.0,
                        constraints.maxHeight - ((rows - 1) * spacing),
                      );
                      final cellSize = math.max(
                        1.0,
                        math.min(
                          availableWidth / columns,
                          availableHeight / rows,
                        ),
                      );
                      final gridWidth =
                          (cellSize * columns) + ((columns - 1) * spacing);
                      final gridHeight =
                          (cellSize * rows) + ((rows - 1) * spacing);
                      final gridSize = Size(gridWidth, gridHeight);
                      final letterSize = math.min(
                        22.0,
                        math.max(16.0, cellSize * 0.56),
                      );
                      final cornerRadius = math.min(
                        12.0,
                        math.max(8.0, cellSize * 0.28),
                      );

                      return Center(
                        child: SizedBox(
                          width: gridWidth,
                          height: gridHeight,
                          child: Listener(
                            key: const Key('word_hunt_production_grid'),
                            behavior: HitTestBehavior.opaque,
                            onPointerDown:
                                (event) => _pointerDown(
                                  event.localPosition,
                                  gridSize,
                                ),
                            onPointerMove:
                                (event) => _pointerMove(
                                  event.localPosition,
                                  gridSize,
                                ),
                            onPointerUp: (_) => _pointerUp(),
                            onPointerCancel: (_) => _pointerCancel(),
                            child: GridView.builder(
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: spacing,
                                    mainAxisSpacing: spacing,
                                    childAspectRatio: 1,
                                  ),
                              itemCount: rows * columns,
                              itemBuilder: (context, index) {
                                final row = index ~/ columns;
                                final column = index % columns;
                                final cell = WordHuntCell(row, column);
                                final rune = widget.level.grid[row].runes
                                    .elementAt(column);
                                final selected = _selectedPath.contains(cell);
                                final found = _isFound(cell);
                                final error = _errorCells.contains(cell);
                                return AnimatedContainer(
                                  key: Key(
                                    'word_hunt_production_cell_${row}_$column',
                                  ),
                                  duration: const Duration(milliseconds: 120),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color:
                                        selected
                                            ? const Color(0xFF8B5CF6)
                                            : error
                                            ? const Color(0xFF9A3412)
                                            : found
                                            ? const Color(0xFF0F766E)
                                            : const Color(0xFF142A4C),
                                    borderRadius: BorderRadius.circular(
                                      cornerRadius,
                                    ),
                                    border: Border.all(
                                      color:
                                          selected
                                              ? const Color(0xFFD8B4FE)
                                              : error
                                              ? const Color(0xFFF97316)
                                              : found
                                              ? const Color(0xFF5EEAD4)
                                              : const Color(0xFF34527A),
                                    ),
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    alignment: Alignment.center,
                                    children: [
                                      Center(
                                        child: Text(
                                          String.fromCharCode(rune),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: letterSize,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                      if (error)
                                        IgnorePointer(
                                          child: SizedBox.expand(
                                            key: Key(
                                              'word_hunt_production_error_cell_${row}_$column',
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
"""
prod = prod[:grid_start] + new_grid + prod[grid_end:]

prod = replace_once(
    prod,
    """                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(12),""",
    """                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),""",
    "production status",
)

prod = replace_once(
    prod,
    """                const SizedBox(height: 12),
                if (_allTargetsFound)""",
    """                const SizedBox(height: 8),
                if (_allTargetsFound)""",
    "production finish gap",
)

screen_path.write_text(text[:prod_start] + prod + text[prod_end:], encoding="utf-8")

test_path = Path("test/word_hunt_level_production_test.dart")
tests = test_path.read_text(encoding="utf-8")
tests = replace_once(
    tests,
    """  Future<void> pumpLevel(
    WidgetTester tester, {
    WordHuntLevelDefinition? level,
    DateTime Function()? now,
  }) async {
    await tester.binding.setSurfaceSize(const Size(720, 1280));""",
    """  Future<void> pumpLevel(
    WidgetTester tester, {
    WordHuntLevelDefinition? level,
    DateTime Function()? now,
    Size surfaceSize = const Size(720, 1280),
  }) async {
    await tester.binding.setSurfaceSize(surfaceSize);""",
    "test helper",
)

insert_marker = "  testWidgets('target reverse wrong ve bonus ayrışır', (tester) async {"
regression = """  testWidgets(
    'Bölüm 10 10x6 grid 411x731 portrait viewport içine kaydırmasız sığar',
    (tester) async {
      final level = WordHuntStarterContent.baslangicLimani.levels.last;
      await pumpLevel(
        tester,
        level: level,
        surfaceSize: const Size(411, 731),
      );

      expect(find.text('0/9'), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsNothing);

      final screenRect = tester.getRect(
        find.byKey(const Key('word_hunt_production_screen')),
      );
      final gridRect = tester.getRect(
        find.byKey(const Key('word_hunt_production_grid')),
      );
      final firstCellSize = tester.getSize(
        find.byKey(const Key('word_hunt_production_cell_0_0')),
      );
      final lastCellRect = tester.getRect(
        find.byKey(const Key('word_hunt_production_cell_9_5')),
      );
      final statusRect = tester.getRect(
        find.byKey(const Key('word_hunt_production_status')),
      );

      expect(firstCellSize.shortestSide, greaterThanOrEqualTo(30));
      expect(lastCellRect.bottom, lessThanOrEqualTo(gridRect.bottom + 0.5));
      expect(gridRect.bottom, lessThanOrEqualTo(statusRect.top + 0.5));
      expect(statusRect.bottom, lessThanOrEqualTo(screenRect.bottom + 0.5));
      expect(tester.takeException(), isNull);
    },
  );

"""
if tests.count(insert_marker) != 1:
    raise SystemExit(f"test insertion marker count={tests.count(insert_marker)}")
tests = tests.replace(insert_marker, regression + insert_marker, 1)
test_path.write_text(tests, encoding="utf-8")
