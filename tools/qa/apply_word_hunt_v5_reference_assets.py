#!/usr/bin/env python3
from pathlib import Path

SOURCE = Path('lib/word_hunt/word_hunt_screens.dart')
TEST = Path('test/word_hunt_level_production_test.dart')
PUBSPEC = Path('pubspec.yaml')
ASSET_TEST = Path('test/word_hunt_v5_reference_assets_test.dart')


def replace_once(value: str, old: str, new: str, label: str) -> str:
    count = value.count(old)
    if count != 1:
        raise RuntimeError(f'{label}: expected 1 occurrence, found {count}')
    return value.replace(old, new, 1)


def replace_section(value: str, start: str, end: str, replacement: str, label: str) -> str:
    if value.count(start) != 1 or value.count(end) != 1:
        raise RuntimeError(f'{label}: class markers are not unique')
    left = value.index(start)
    right = value.index(end, left)
    return value[:left] + replacement.rstrip() + '\n\n' + value[right:]


text = SOURCE.read_text(encoding='utf-8')

text = replace_once(
    text,
    "'assets/word_hunt/baslangic_limani_gameplay_bg.jpg'",
    "'assets/word_hunt/v5_reference_assets/harbor_background_1080x1920.png'",
    'gameplay background asset',
)

overlay = """            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0x18010812),
                    Color(0x30010812),
                    Color(0x52010812),
                  ],
                  stops: <double>[0, .48, 1],
                ),
              ),
            ),
"""
text = replace_once(text, overlay, '', 'remove procedural background tint')

text = replace_once(
    text,
    'icon: Icons.search_rounded,',
    "iconAsset: 'assets/word_hunt/v5_reference_assets/icon_search.png',",
    'progress icon callsite',
)
text = replace_once(
    text,
    'icon: Icons.close_rounded,',
    "iconAsset: 'assets/word_hunt/v5_reference_assets/icon_mistake.png',",
    'mistake icon callsite',
)
text = replace_once(
    text,
    'icon: Icons.timer_outlined,',
    "iconAsset: 'assets/word_hunt/v5_reference_assets/icon_timer.png',",
    'timer icon callsite',
)

header = """class _HarborGameplayHeader extends StatelessWidget {
  const _HarborGameplayHeader({required this.levelIndex, required this.onBack});

  final int levelIndex;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: Row(
        children: [
          IconButton(
            key: const Key('word_hunt_production_back'),
            onPressed: onBack,
            style: IconButton.styleFrom(
              minimumSize: const Size(42, 42),
              padding: EdgeInsets.zero,
            ),
            icon: Image.asset(
              'assets/word_hunt/v5_reference_assets/icon_back.png',
              width: 34,
              height: 34,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bölüm $levelIndex',
                  style: const TextStyle(
                    color: _harborCream,
                    fontFamily: 'serif',
                    fontSize: 30,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .2,
                    shadows: [
                      Shadow(color: Color(0xE0000000), blurRadius: 8),
                      Shadow(color: Color(0x44FFCA62), blurRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Başlangıç Limanı',
                  style: TextStyle(
                    color: Color(0xFF98A9B8),
                    fontFamily: 'serif',
                    fontSize: 13.5,
                    letterSpacing: .25,
                    shadows: [Shadow(color: Color(0xCC000000), blurRadius: 6)],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
"""

metric = """class _HarborMetricPlate extends StatelessWidget {
  const _HarborMetricPlate({
    super.key,
    required this.iconAsset,
    required this.label,
    this.textKey,
  });

  final String iconAsset;
  final String label;
  final Key? textKey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/word_hunt/v5_reference_assets/status_panel_empty.png',
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  iconAsset,
                  width: 18,
                  height: 18,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    key: textKey,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _harborCream,
                      fontFamily: 'serif',
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      shadows: <Shadow>[
                        Shadow(color: Color(0xCC000000), blurRadius: 3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
"""

word_plate = """class _HarborWordPlate extends StatelessWidget {
  const _HarborWordPlate({
    required this.word,
    required this.found,
    this.bonus = false,
  });

  final String word;
  final bool found;
  final bool bonus;

  @override
  Widget build(BuildContext context) {
    final asset =
        bonus
            ? 'assets/word_hunt/v5_reference_assets/bonus_plaque_empty.png'
            : 'assets/word_hunt/v5_reference_assets/word_plaque_empty.png';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      constraints: const BoxConstraints(minHeight: 34),
      padding: EdgeInsets.fromLTRB(bonus ? 30 : 12, 6, 12, 6),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(asset),
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (bonus)
            SizedBox(
              key: Key('word_hunt_production_bonus_icon_$word'),
              width: 0,
              height: 0,
            ),
          Text(
            word,
            style: TextStyle(
              color: found ? const Color(0xFFFFE7AE) : _harborCream,
              fontFamily: 'serif',
              fontSize: 12.5,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: .2,
              shadows: const <Shadow>[
                Shadow(color: Color(0xD0000000), blurRadius: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
"""

grid_cell = """class _HarborGridCell extends StatelessWidget {
  const _HarborGridCell({
    super.key,
    required this.row,
    required this.column,
    required this.letter,
    required this.extent,
    required this.selected,
    required this.found,
    required this.error,
  });

  final int row;
  final int column;
  final String letter;
  final double extent;
  final bool selected;
  final bool found;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final active = selected || found;
    final asset =
        active
            ? 'assets/word_hunt/v5_reference_assets/cell_selected_found.png'
            : 'assets/word_hunt/v5_reference_assets/cell_idle.png';

    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        Image.asset(
          asset,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
        ),
        if (error)
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0x338B3B20),
              borderRadius: BorderRadius.circular(math.max(6, extent * .14)),
              border: Border.all(color: const Color(0xFFFFB06A), width: 1.2),
            ),
          ),
        Center(
          child: Text(
            letter,
            style: TextStyle(
              color: _harborCream,
              fontFamily: 'serif',
              fontSize: (extent * .46).clamp(17, 24),
              fontWeight: FontWeight.w900,
              height: 1,
              shadows: const <Shadow>[
                Shadow(color: Color(0xE0000000), blurRadius: 3),
              ],
            ),
          ),
        ),
        if (error)
          IgnorePointer(
            child: SizedBox.expand(
              key: Key('word_hunt_production_error_cell_${row}_$column'),
            ),
          ),
      ],
    );
  }
}
"""

instruction = """class _HarborInstructionPlate extends StatelessWidget {
  const _HarborInstructionPlate({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('word_hunt_production_instruction_plate'),
      height: 50,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/word_hunt/v5_reference_assets/instruction_panel_empty.png',
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 7),
            child: Center(
              child: Text(
                status,
                key: const Key('word_hunt_production_status'),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _harborCream,
                  fontFamily: 'serif',
                  fontSize: 12,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  shadows: <Shadow>[
                    Shadow(color: Color(0xD0000000), blurRadius: 3),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
"""

text = replace_section(text, 'class _HarborGameplayHeader extends StatelessWidget', 'class _HarborMetricPlate extends StatelessWidget', header, 'header')
text = replace_section(text, 'class _HarborMetricPlate extends StatelessWidget', 'class _HarborWordPlate extends StatelessWidget', metric, 'metric plate')
text = replace_section(text, 'class _HarborWordPlate extends StatelessWidget', 'class _HarborGridCell extends StatelessWidget', word_plate, 'word plate')
text = replace_section(text, 'class _HarborGridCell extends StatelessWidget', 'class _HarborInstructionPlate extends StatelessWidget', grid_cell, 'grid cell')
text = replace_section(text, 'class _HarborInstructionPlate extends StatelessWidget', 'class _MetricChip extends StatelessWidget', instruction, 'instruction plate')
SOURCE.write_text(text, encoding='utf-8')

test_text = TEST.read_text(encoding='utf-8')
test_text = replace_once(
    test_text,
    'assets/word_hunt/baslangic_limani_gameplay_bg.jpg',
    'assets/word_hunt/v5_reference_assets/harbor_background_1080x1920.png',
    'production test background expectation',
)
TEST.write_text(test_text, encoding='utf-8')

pubspec = PUBSPEC.read_text(encoding='utf-8')
if 'version: 1.68.19+109' not in pubspec:
    raise RuntimeError('pubspec version changed unexpectedly')
asset_entry = '    - assets/word_hunt/v5_reference_assets/\n'
if asset_entry not in pubspec:
    anchor = '    - assets/word_hunt/baslangic_limani/\n'
    pubspec = replace_once(pubspec, anchor, anchor + asset_entry, 'pubspec asset registration')
PUBSPEC.write_text(pubspec, encoding='utf-8')

ASSET_TEST.write_text("""import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('approved V5 reference assets keep exact SHA-256 contract', () {
    const expected = <String, String>{
      'harbor_background_1080x1920.png': '0482adfa9ce8b2eb3b3637a7ef9976984650368a43f539f999842437a69d4368',
      'cell_idle.png': '052ac36a48cd0bac06bfbd6221e28c77bd32a4b1e9f08ded0e7fabefbf56c529',
      'cell_selected_found.png': '57d620263cae231c4b8983cc8fab7732db7733a78fae9e620abaaec7dc8aac87',
      'status_panel_empty.png': '0f5fd5aac1f94fa644a3f19c4147e2747fd639b0041a12e94df8198201fc95f4',
      'word_plaque_empty.png': '90d15d496a1a22fdee1014ffc2921ef8569863570b3c61141417cf9fb941c04a',
      'bonus_plaque_empty.png': 'e3bfe4b5a958ec945a76cdd0cc48d2ae3e93f4340ccf5b778ad63663787a79bf',
      'instruction_panel_empty.png': '71aa162fc3dd24ef6f84c04792c87eb8800e63ff8b92b933bab13f2b72731c5c',
      'icon_back.png': '4d086841a7fc4cb4bb194ab72fd3f9f34c3d84adc836b965ab15e651ac92b24f',
      'icon_search.png': 'da26169dc521284e58144453ce756053a1b153e7c467d90a860d1cf5c2ec71fe',
      'icon_mistake.png': 'b77fe3628dc98162e1d739d649dffc426ec293f88579716c25e459de2e0d6253',
      'icon_timer.png': 'f276c862e3ecae30853ff8d0f3fe8e08d2878e1357d67a4eb3e13c95affa54ec',
    };

    for (final entry in expected.entries) {
      final file = File('assets/word_hunt/v5_reference_assets/${entry.key}');
      expect(file.existsSync(), isTrue, reason: entry.key);
      expect(sha256.convert(file.readAsBytesSync()).toString(), entry.value, reason: entry.key);
    }
  });
}
""", encoding='utf-8')

print('Deterministic V5 reference asset presentation patch applied.')
