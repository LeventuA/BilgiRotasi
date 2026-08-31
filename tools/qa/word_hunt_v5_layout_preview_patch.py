from pathlib import Path

path = Path('lib/word_hunt/word_hunt_screens.dart')
text = path.read_text(encoding='utf-8')

old = "const _harborGridSpacing = 1.5;\n"
new = (
    "const _harborGridSpacing = 1.5;\n"
    "const _harborInstructionDefault =\n"
    "    'İlk harfe dokun, parmağını kelimenin üzerinde sürükle.';\n"
)
assert text.count(old) == 1
text = text.replace(old, new, 1)

old = "  String _status = 'İlk harfe dokun, parmağını kelimenin üzerinde sürükle.';\n"
assert text.count(old) == 1
text = text.replace(old, "  String _status = _harborInstructionDefault;\n", 1)

old = "  int get _scoredMistakes => _completionMistakes ?? _mistakes;\n\n  DateTime _now()"
new = """  int get _scoredMistakes => _completionMistakes ?? _mistakes;

  String get _displayedInstructionStatus {
    final status = _status;
    final successFeedback =
        status.endsWith(' bulundu!') ||
        status.startsWith('Bilgi kartı açıldı:') ||
        status.startsWith('Bonus kelime:') ||
        status.endsWith(' zaten bulundu.');
    return successFeedback ? _harborInstructionDefault : status;
  }

  DateTime _now()"""
assert text.count(old) == 1
text = text.replace(old, new, 1)

old = "                        _HarborInstructionPlate(status: _status),"
new = """                        _HarborInstructionPlate(
                          status: _displayedInstructionStatus,
                        ),"""
assert text.count(old) == 1
text = text.replace(old, new, 1)

word_start = text.index('class _HarborWordPlate')
grid_start = text.index('class _HarborGridCell', word_start)
word = text[word_start:grid_start]
old = """      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(asset),
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
        ),
      ),"""
new = """      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(asset),
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
          colorFilter:
              found
                  ? const ColorFilter.mode(
                    Color(0xFFC06B16),
                    BlendMode.color,
                  )
                  : null,
        ),
      ),"""
assert word.count(old) == 1
word = word.replace(old, new, 1)
text = text[:word_start] + word + text[grid_start:]

grid_start = text.index('class _HarborGridCell')
instruction_start = text.index('class _HarborInstructionPlate', grid_start)
grid = text[grid_start:instruction_start]
old = "    return Stack(\n"
new = """    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(math.max(6, extent * .14)),
        boxShadow:
            active
                ? const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x55FF9D22),
                    blurRadius: 3,
                    spreadRadius: .2,
                  ),
                ]
                : const <BoxShadow>[],
      ),
      child: Stack(
"""
assert grid.count(old) == 1
grid = grid.replace(old, new, 1)
old_end = "      ],\n    );\n  }\n}\n\n"
new_end = """        ],
      ),
    );
  }
}

"""
assert grid.endswith(old_end)
grid = grid[:-len(old_end)] + new_end
text = text[:grid_start] + grid + text[instruction_start:]

path.write_text(text, encoding='utf-8')
print('V6_LAYOUT_PREVIEW_PATCH_APPLIED')
