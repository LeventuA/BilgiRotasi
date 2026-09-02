from pathlib import Path

path = Path('lib/word_hunt/word_hunt_screens.dart')
text = path.read_text(encoding='utf-8')
start_marker = 'class _HarborCompletionDialog extends StatelessWidget {'
end_marker = 'class _HarborGameplayHeader extends StatelessWidget {'
start = text.index(start_marker)
end = text.index(end_marker, start)
region = text[start:end]


def replace(old: str, new: str, expected: int = 1) -> None:
    global region
    count = region.count(old)
    if count != expected:
        raise SystemExit(f'expected {expected}, found {count}: {old!r}')
    region = region.replace(old, new)

replace('constraints: const BoxConstraints(maxWidth: 350),', 'constraints: const BoxConstraints(maxWidth: 300),')
replace('padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),', 'padding: const EdgeInsets.fromLTRB(18, 15, 18, 15),')
replace('borderRadius: BorderRadius.circular(26),', 'borderRadius: BorderRadius.circular(22),')
replace('blurRadius: 28,', 'blurRadius: 24,')
replace('offset: Offset(0, 14),', 'offset: Offset(0, 11),')
replace('BoxShadow(color: Color(0x33FFCA62), blurRadius: 18),', 'BoxShadow(color: Color(0x33FFCA62), blurRadius: 14),')
replace('width: 54,', 'width: 46,')
replace('height: 4,', 'height: 3,')
replace("const SizedBox(height: 14),\n              const Icon(Icons.anchor_rounded, color: _harborGold, size: 34),", "const SizedBox(height: 10),\n              const Icon(Icons.anchor_rounded, color: _harborGold, size: 28),")
replace("const SizedBox(height: 8),\n              const Text(\n                'Bölüm Tamamlandı',", "const SizedBox(height: 6),\n              const Text(\n                'Bölüm Tamamlandı',")
replace('fontSize: 25,', 'fontSize: 22,')
replace('fontSize: 13,\n                  fontWeight: FontWeight.w700,', 'fontSize: 12,\n                  fontWeight: FontWeight.w700,')
replace('const SizedBox(height: 16),\n              Row(\n                mainAxisAlignment: MainAxisAlignment.center,', 'const SizedBox(height: 12),\n              Row(\n                mainAxisAlignment: MainAxisAlignment.center,')
replace('padding: const EdgeInsets.symmetric(horizontal: 4),', 'padding: const EdgeInsets.symmetric(horizontal: 3),')
replace('size: 40,', 'size: 34,')
replace('const SizedBox(height: 16),\n              Container(height: 1, color: const Color(0x557C5A2A)),\n              const SizedBox(height: 14),', 'const SizedBox(height: 12),\n              Container(height: 1, color: const Color(0x557C5A2A)),\n              const SizedBox(height: 10),')
replace('const SizedBox(width: 8),', 'const SizedBox(width: 6),', expected=2)
replace('const SizedBox(height: 12),\n                Container(\n                  width: double.infinity,\n                  padding: const EdgeInsets.symmetric(\n                    horizontal: 12,\n                    vertical: 9,', 'const SizedBox(height: 9),\n                Container(\n                  width: double.infinity,\n                  padding: const EdgeInsets.symmetric(\n                    horizontal: 10,\n                    vertical: 7,')
replace('borderRadius: BorderRadius.circular(14),', 'borderRadius: BorderRadius.circular(12),', expected=2)
replace('fontSize: 13,\n                      fontWeight: FontWeight.w800,', 'fontSize: 12,\n                      fontWeight: FontWeight.w800,')
replace('const SizedBox(height: 18),\n              SizedBox(\n                width: double.infinity,\n                height: 50,', 'const SizedBox(height: 14),\n              SizedBox(\n                width: double.infinity,\n                height: 44,')
replace('borderRadius: BorderRadius.circular(16),', 'borderRadius: BorderRadius.circular(14),')
replace('fontSize: 16,', 'fontSize: 15,')
replace('icon: const Icon(Icons.route_rounded, size: 20),', 'icon: const Icon(Icons.route_rounded, size: 18),')
replace('padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),', 'padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),')
replace('Icon(icon, color: const Color(0xFFD9A64F), size: 18),', 'Icon(icon, color: const Color(0xFFD9A64F), size: 16),')
replace('const SizedBox(height: 4),', 'const SizedBox(height: 3),')
replace('fontSize: 12,\n              fontWeight: FontWeight.w900,', 'fontSize: 11,\n              fontWeight: FontWeight.w900,')
replace('fontSize: 10,\n              fontWeight: FontWeight.w700,', 'fontSize: 9,\n              fontWeight: FontWeight.w700,')

text = text[:start] + region + text[end:]
path.write_text(text, encoding='utf-8')
