from pathlib import Path

path = Path('lib/word_hunt/word_hunt_screens.dart')
text = path.read_text(encoding='utf-8')

connector_key = 'word_hunt_production_found_path_connector'
if text.count(connector_key) != 1:
    raise SystemExit(f'Expected one connector key, found {text.count(connector_key)}')
if 'word_hunt_production_found_path_seam' in text:
    raise SystemExit('Seam already present')

search_start = text.index(connector_key)
grid_start = text.index('GridView.builder(', search_start)
paren_start = text.index('(', grid_start)

depth = 0
quote = None
escaped = False
close_index = None
for i in range(paren_start, len(text)):
    ch = text[i]
    if quote is not None:
        if escaped:
            escaped = False
            continue
        if ch == '\\':
            escaped = True
            continue
        if ch == quote:
            quote = None
        continue
    if ch in ("'", '"'):
        quote = ch
        continue
    if ch == '(':
        depth += 1
    elif ch == ')':
        depth -= 1
        if depth == 0:
            close_index = i
            break

if close_index is None:
    raise SystemExit('Could not find GridView.builder closing parenthesis')

comma_index = close_index + 1
while comma_index < len(text) and text[comma_index].isspace():
    comma_index += 1
if comma_index >= len(text) or text[comma_index] != ',':
    raise SystemExit('GridView.builder is not followed by a comma')

overlay = r'''
                        IgnorePointer(
                          child: CustomPaint(
                            key: const Key(
                              'word_hunt_production_found_path_seam',
                            ),
                            painter: _HarborFoundPathSeamPainter(
                              paths: _foundPaths.values
                                  .map(
                                    (path) =>
                                        List<WordHuntCell>.unmodifiable(path),
                                  )
                                  .toList(growable: false),
                              cellExtent: cellExtent,
                              spacing: _harborGridSpacing,
                            ),
                          ),
                        ),'''

insert_pos = comma_index + 1
text = text[:insert_pos] + '\n' + overlay + text[insert_pos:]

marker = 'class _HarborGridCell extends StatelessWidget {'
if text.count(marker) != 1:
    raise SystemExit(f'Expected one HarborGridCell marker, found {text.count(marker)}')

painter = r'''
class _HarborFoundPathSeamPainter extends CustomPainter {
  const _HarborFoundPathSeamPainter({
    required this.paths,
    required this.cellExtent,
    required this.spacing,
  });

  final List<List<WordHuntCell>> paths;
  final double cellExtent;
  final double spacing;

  Offset _centerFor(WordHuntCell cell) {
    final stride = cellExtent + spacing;
    return Offset(
      cell.column * stride + cellExtent / 2,
      cell.row * stride + cellExtent / 2,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (paths.isEmpty) return;

    final haloPaint = Paint()
      ..color = const Color(0xB8FF9D22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(7, cellExtent * .36)
      ..strokeCap = StrokeCap.round;
    final fillPaint = Paint()
      ..color = const Color(0xF0B96712)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(5, cellExtent * .24)
      ..strokeCap = StrokeCap.round;
    final highlightPaint = Paint()
      ..color = const Color(0xA8FFD36A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2, cellExtent * .08)
      ..strokeCap = StrokeCap.round;

    for (final path in paths) {
      if (path.length < 2) continue;
      for (var index = 0; index < path.length - 1; index++) {
        final startCenter = _centerFor(path[index]);
        final endCenter = _centerFor(path[index + 1]);
        final delta = endCenter - startCenter;
        final distance = delta.distance;
        if (distance <= 0) continue;

        final direction = delta / distance;
        final midpoint = Offset(
          (startCenter.dx + endCenter.dx) / 2,
          (startCenter.dy + endCenter.dy) / 2,
        );
        final halfLength = spacing / 2 + cellExtent * .11;
        final start = midpoint - direction * halfLength;
        final end = midpoint + direction * halfLength;

        canvas.drawLine(start, end, haloPaint);
        canvas.drawLine(start, end, fillPaint);
        canvas.drawLine(start, end, highlightPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HarborFoundPathSeamPainter oldDelegate) {
    return oldDelegate.paths != paths ||
        oldDelegate.cellExtent != cellExtent ||
        oldDelegate.spacing != spacing;
  }
}

'''

text = text.replace(marker, painter + marker, 1)
path.write_text(text, encoding='utf-8')
