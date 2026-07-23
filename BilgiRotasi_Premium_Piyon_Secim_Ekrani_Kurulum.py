#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

MAIN = Path('lib/main.dart')
PUBSPEC = Path('pubspec.yaml')
TEST = Path('test/system_smoke_test.dart')
TARGET = Path('lib/premium_pawn_picker.dart')
COMMIT_MESSAGE = 'Premium piyon secim ekranini ekle'

PART_CONTENT = r"""part of 'main.dart';

class PawnPickerPresentation {
  PawnPickerPresentation._();

  static const List<String> descriptions = <String>[
    'Canlı renkleriyle enerjik bir yol arkadaşı.',
    'Bilgiyi ve kararlılığı temsil eden kristal taş.',
    'Meraklı ve neşeli bir bilgi maskotu.',
    'Klasik masa oyunu havasını sevenlere.',
    'Cesur adımlarıyla rotanın bilge yolcusu.',
    'Şans ile bilgiyi aynı küpte buluşturur.',
    'Her kavşakta yönünü bilen kâşif.',
    'Her sayfasında yeni bir bilgi taşıyan rehber.',
    'Doğru anda parlayan fikirlerin piyonu.',
    'Sabırlı oyuncuların zaman ustası.',
    'Her cevabın peşine düşen meraklı yolcu.',
    'Zafer havasını yanında taşıyan şampiyon.',
    'Uzak yıldızlardan gelen sevimli ve gizemli bilge.',
    'Doğanın gücünü taşıyan küçük orman koruyucusu.',
    'Özgürlüğüne düşkün, kıvrak ve sihirli yolcu.',
    'Karanlık mağaralardan gelen sessiz ve kurnaz yolcu.',
  ];

  static const List<String> labels = <String>[
    'ENERJİ', 'KRİSTAL', 'MERAK', 'KLASİK',
    'BİLGE', 'ŞANS', 'KÂŞİF', 'OKUR',
    'FİKİR', 'SABIR', 'MERAK', 'ŞAMPİYON',
    'KOZMİK', 'DOĞA', 'SİHİR', 'GİZEM',
  ];

  static const List<Color> auraColors = <Color>[
    Color(0xFF64748B), Color(0xFF38BDF8),
    Color(0xFFF472B6), Color(0xFF94A3B8),
    Color(0xFF8B5CF6), Color(0xFF22D3EE),
    Color(0xFFF59E0B), Color(0xFF60A5FA),
    Color(0xFFFACC15), Color(0xFFF97316),
    Color(0xFFA78BFA), Color(0xFFFFD54F),
    Color(0xFF9D7CFF), Color(0xFF45C16D),
    Color(0xFFFFC857), Color(0xFFB6A0FF),
  ];

  static int normalize(int pawnType) {
    return (pawnType % PawnCatalog.all.length + PawnCatalog.all.length) %
        PawnCatalog.all.length;
  }

  static String descriptionFor(int pawnType) =>
      descriptions[normalize(pawnType)];
  static String labelFor(int pawnType) => labels[normalize(pawnType)];
  static Color auraFor(int pawnType) => auraColors[normalize(pawnType)];
  static bool isSpecial(int pawnType) {
    final value = normalize(pawnType);
    return value >= 12 && value <= 15;
  }
}

class PremiumPawnPicker {
  PremiumPawnPicker._();

  static Future<int?> show(
    BuildContext context, {
    required int playerNumber,
    required int initialPawnType,
    required Color playerColor,
  }) {
    return showDialog<int>(
      context: context,
      barrierColor: const Color(0xCC12091A),
      builder: (_) => _PremiumPawnPickerDialog(
        playerNumber: playerNumber,
        initialPawnType: initialPawnType,
        playerColor: playerColor,
      ),
    );
  }
}

class _PremiumPawnPickerDialog extends StatefulWidget {
  const _PremiumPawnPickerDialog({
    required this.playerNumber,
    required this.initialPawnType,
    required this.playerColor,
  });

  final int playerNumber;
  final int initialPawnType;
  final Color playerColor;

  @override
  State<_PremiumPawnPickerDialog> createState() =>
      _PremiumPawnPickerDialogState();
}

class _PremiumPawnPickerDialogState
    extends State<_PremiumPawnPickerDialog> {
  late int selected;
  int previewCounter = 0;
  bool previewBusy = false;

  @override
  void initState() {
    super.initState();
    selected = PawnPickerPresentation.normalize(widget.initialPawnType);
  }

  Future<void> previewSound() async {
    if (previewBusy) return;
    if (!SoundFx.enabled) {
      _message('Sesler kapalı. Ayarlardan sesi açabilirsin.');
      return;
    }
    setState(() => previewBusy = true);
    GameHaptics.selectionClick();
    final played = await SoundFx.pawnStep(
      selected,
      stepIndex: previewCounter++,
    );
    if (!mounted) return;
    setState(() => previewBusy = false);
    if (!played) _message('Piyon sesi oynatılamadı.');
  }

  void _message(String text) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      clipBehavior: Clip.antiAlias,
      backgroundColor: const Color(0xFFF8FAFC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: Color(0x66FFE082), width: 1.5),
      ),
      child: SizedBox(
        width: min(media.size.width - 24, 680.0),
        height: min(media.size.height * 0.92, 780.0),
        child: Column(
          children: [
            _header(),
            _preview(),
            Expanded(child: _grid()),
            _actions(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 13, 10, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A245D), Color(0xFF173B57)],
        ),
      ),
      child: Row(
        children: [
          const Text('♟', style: TextStyle(color: Colors.white, fontSize: 28)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.playerNumber}. oyuncunun piyonu',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'Görünüşünü seç, sesini dinle',
                  style: TextStyle(color: Color(0xFFD8CCEA), fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _preview() {
    final pawn = PawnCatalog.at(selected);
    final aura = PawnPickerPresentation.auraFor(selected);
    final special = PawnPickerPresentation.isSpecial(selected);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.lerp(aura, Colors.white, 0.82)!,
            Colors.white,
            Color.lerp(widget.playerColor, Colors.white, 0.90)!,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: aura.withOpacity(special ? 0.72 : 0.35),
          width: special ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: aura.withOpacity(special ? 0.24 : 0.10),
            blurRadius: special ? 20 : 10,
            spreadRadius: special ? 2 : 0,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 230),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Container(
              key: ValueKey<int>(selected),
              width: 102,
              height: 124,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.white, aura.withOpacity(0.20), Colors.white],
                ),
                boxShadow: [
                  BoxShadow(
                    color: aura.withOpacity(special ? 0.52 : 0.24),
                    blurRadius: special ? 24 : 14,
                    spreadRadius: special ? 3 : 1,
                  ),
                ],
              ),
              child: PawnToken(
                type: selected,
                color: widget.playerColor,
                active: true,
                width: 82,
                height: 104,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 5,
                  children: [
                    Text(
                      pawn.name,
                      style: const TextStyle(
                        color: Color(0xFF25142F),
                        fontSize: 18,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    _badge(PawnPickerPresentation.labelFor(selected), aura),
                    if (special) _badge('ÖZEL', const Color(0xFF7C3AED)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  PawnPickerPresentation.descriptionFor(selected),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF526071),
                    fontSize: 12,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    const Icon(
                      Icons.graphic_eq_rounded,
                      size: 16,
                      color: Color(0xFF6D3F80),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        PawnStepSoundFactory.profileNameForPawn(selected),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6D3F80),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: previewBusy ? null : previewSound,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5B2C70),
                    minimumSize: const Size(0, 39),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  icon: previewBusy
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.volume_up_rounded, size: 18),
                  label: const Text(
                    'Sesini Dinle',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.55)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Color.lerp(color, Colors.black, 0.22),
          fontSize: 8,
          letterSpacing: 0.4,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _grid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 560 ? 4 : 3;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(12, 5, 12, 10),
          itemCount: PawnCatalog.all.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: columns == 4 ? 0.80 : 0.74,
          ),
          itemBuilder: (_, index) => _card(index),
        );
      },
    );
  }

  Widget _card(int index) {
    final pawn = PawnCatalog.all[index];
    final active = selected == index;
    final special = PawnPickerPresentation.isSpecial(index);
    final aura = PawnPickerPresentation.auraFor(index);

    return AnimatedScale(
      scale: active ? 1.035 : 1,
      duration: const Duration(milliseconds: 170),
      curve: Curves.easeOutBack,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            if (selected == index) return;
            setState(() {
              selected = index;
              previewCounter = 0;
            });
            GameHaptics.selectionClick();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 190),
            padding: const EdgeInsets.fromLTRB(5, 6, 5, 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: active
                    ? [Color.lerp(aura, Colors.white, 0.78)!, Colors.white]
                    : special
                        ? [Color.lerp(aura, Colors.white, 0.90)!, Colors.white]
                        : const [Color(0xFFFFFFFF), Color(0xFFF6F8FB)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: active
                    ? aura
                    : special
                        ? aura.withOpacity(0.46)
                        : const Color(0xFFE2E8F0),
                width: active ? 2.6 : special ? 1.4 : 1,
              ),
              boxShadow: [
                if (active || special)
                  BoxShadow(
                    color: aura.withOpacity(active ? 0.30 : 0.13),
                    blurRadius: active ? 14 : 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: PawnToken(
                          type: index,
                          color: widget.playerColor,
                          active: active,
                          width: 55,
                          height: 70,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      pawn.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF25142F),
                        fontSize: 9.5,
                        height: 1.02,
                        fontWeight: active ? FontWeight.w900 : FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: aura.withOpacity(0.11),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        special
                            ? 'ÖZEL • ${PawnPickerPresentation.labelFor(index)}'
                            : PawnPickerPresentation.labelFor(index),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color.lerp(aura, Colors.black, 0.28),
                          fontSize: special ? 6.7 : 7.2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                if (active)
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFF16A34A),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(3),
                        child: Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actions() {
    final pawn = PawnCatalog.at(selected);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          boxShadow: [
            BoxShadow(
              color: Color(0x16000000),
              blurRadius: 12,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Vazgeç',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  GameHaptics.mediumImpact();
                  Navigator.pop(context, selected);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF5B2C70),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
                icon: const Icon(Icons.check_circle_rounded),
                label: Text(
                  '${pawn.name} ile Devam Et',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
"""

def run(command, *, check=True):
    print('$ ' + ' '.join(command))
    return subprocess.run(command, check=check)


def method_span(source, signature):
    start = source.find(signature)
    if start < 0:
        raise RuntimeError(f'Metot bulunamadı: {signature}')
    brace_start = source.find('{', start)
    if brace_start < 0:
        raise RuntimeError(f'Metot başlangıcı bulunamadı: {signature}')
    depth = 0
    for index in range(brace_start, len(source)):
        if source[index] == '{':
            depth += 1
        elif source[index] == '}':
            depth -= 1
            if depth == 0:
                return start, index + 1
    raise RuntimeError(f'Metot sonu bulunamadı: {signature}')


for path in [MAIN, PUBSPEC, TEST, Path('lib/pawn_step_sounds.dart')]:
    if not path.exists():
        raise SystemExit(
            f'Gerekli dosya bulunamadı: {path}\n'
            'Kurulumu BilgiRotasi deposunun ana klasöründe çalıştır.'
        )

branch = subprocess.check_output(
    ['git', 'branch', '--show-current'], text=True
).strip()
if branch != 'main':
    raise SystemExit(
        'Bu özellik yalnızca main dalına kurulabilir.\n'
        f'Şu anki dal: {branch or "(belirsiz)"}\n'
        'Önce: git switch main'
    )

protected = [
    'lib/main.dart',
    'lib/premium_pawn_picker.dart',
    'lib/pawn_step_sounds.dart',
    'pubspec.yaml',
    'pubspec.lock',
    'test/system_smoke_test.dart',
    'assets/questions.json',
]
local_changes = subprocess.run(
    ['git', 'status', '--porcelain', '--', *protected],
    text=True,
    capture_output=True,
    check=True,
).stdout.strip()
if local_changes:
    raise SystemExit(
        'Korunan proje dosyalarında yerel değişiklik var:\n'
        f'{local_changes}\n\n'
        'Önce mevcut çalışmayı commit et. Kurulum yerel değişiklikleri silmez.'
    )

print('🔄 main dalı güncelleniyor...')
run(['git', 'pull', '--ff-only', 'origin', 'main'])

main = MAIN.read_text(encoding='utf-8')
pubspec = PUBSPEC.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')
sound_source = Path('lib/pawn_step_sounds.dart').read_text(encoding='utf-8')

version_match = re.search(
    r'^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$',
    pubspec,
    flags=re.MULTILINE,
)
if version_match is None:
    raise SystemExit('pubspec.yaml sürüm satırı okunamadı.')
version = tuple(map(int, version_match.groups()))
if version != (1, 39, 0, 49):
    raise SystemExit(
        'Bu paket 1.39.0+49 sürümü için hazırlandı.\n'
        f'Depodaki sürüm: {version[0]}.{version[1]}.{version[2]}+{version[3]}\n'
        'Sürüm farklıysa güncel kurulum paketi gerekir.'
    )

if TARGET.exists() or "part 'premium_pawn_picker.dart';" in main:
    raise SystemExit('Premium piyon seçim ekranı zaten kurulmuş görünüyor.')

for marker in [
    "part 'pawn_step_sounds.dart';",
    'class PawnCatalog',
    'class PlayerSetupScreen',
    'Future<void> _showPawnPicker(int playerIndex) async {',
    'SoundFx.pawnStep(',
]:
    if marker not in main:
        raise SystemExit(f'Beklenen kod işareti bulunamadı: {marker}')
if 'profileNameForPawn' not in sound_source:
    raise SystemExit('Piyona özel ses paketi güncel değil.')

backup_dir = Path(tempfile.mkdtemp(prefix='bilgi_rotasi_premium_picker_'))
committed = False

try:
    shutil.copy2(MAIN, backup_dir / 'main.dart')
    shutil.copy2(PUBSPEC, backup_dir / 'pubspec.yaml')
    shutil.copy2(TEST, backup_dir / 'system_smoke_test.dart')

    TARGET.write_text(PART_CONTENT, encoding='utf-8')

    main = main.replace(
        "part 'pawn_step_sounds.dart';",
        "part 'pawn_step_sounds.dart';\npart 'premium_pawn_picker.dart';",
        1,
    )

    signature = '  Future<void> _showPawnPicker(int playerIndex) async {'
    start, end = method_span(main, signature)
    replacement = '''  Future<void> _showPawnPicker(int playerIndex) async {
    final selected = await PremiumPawnPicker.show(
      context,
      playerNumber: playerIndex + 1,
      initialPawnType: _selectedPawnTypes[playerIndex],
      playerColor: _playerColors[playerIndex],
    );

    if (selected == null || !mounted) return;

    setState(() {
      _selectedPawnTypes[playerIndex] = selected;
    });
  }'''
    main = main[:start] + replacement + main[end:]

    main, count = re.subn(
        r'Bilgi Rotası • Sürüm 1\.39\.0',
        'Bilgi Rotası • Sürüm 1.40.0',
        main,
        count=1,
    )
    if count != 1:
        raise RuntimeError('Ana menü sürüm yazısı güncellenemedi.')

    pubspec, count = re.subn(
        r'^version:\s*.*$',
        'version: 1.40.0+50',
        pubspec,
        count=1,
        flags=re.MULTILINE,
    )
    if count != 1:
        raise RuntimeError('pubspec.yaml sürümü güncellenemedi.')

    test_insert = r'''
    test('Premium piyon seçici tüm piyonları tanımlar', () {
      expect(
        PawnPickerPresentation.descriptions.length,
        PawnCatalog.all.length,
      );
      expect(
        PawnPickerPresentation.labels.length,
        PawnCatalog.all.length,
      );
      expect(
        PawnPickerPresentation.auraColors.length,
        PawnCatalog.all.length,
      );

      for (var index = 0; index < PawnCatalog.all.length; index++) {
        expect(PawnPickerPresentation.descriptionFor(index).trim(), isNotEmpty);
        expect(PawnPickerPresentation.labelFor(index).trim(), isNotEmpty);
      }

      expect(PawnPickerPresentation.isSpecial(11), isFalse);
      expect(PawnPickerPresentation.isSpecial(12), isTrue);
      expect(PawnPickerPresentation.isSpecial(15), isTrue);
      expect(PawnPickerPresentation.isSpecial(16), isFalse);
    });
'''
    group_end = test.rfind('  });\n}')
    if group_end < 0:
        raise RuntimeError('Test dosyası ekleme noktası bulunamadı.')
    test = test[:group_end] + test_insert + test[group_end:]

    MAIN.write_text(main, encoding='utf-8')
    PUBSPEC.write_text(pubspec, encoding='utf-8')
    TEST.write_text(test, encoding='utf-8')

    checks = {
        MAIN: [
            "part 'premium_pawn_picker.dart';",
            'PremiumPawnPicker.show(',
            'Bilgi Rotası • Sürüm 1.40.0',
        ],
        TARGET: [
            'class PawnPickerPresentation',
            'class PremiumPawnPicker',
            'Sesini Dinle',
            'PawnStepSoundFactory.profileNameForPawn',
            'ÖZEL',
        ],
        PUBSPEC: ['version: 1.40.0+50'],
        TEST: ['Premium piyon seçici tüm piyonları tanımlar'],
    }
    for path, markers in checks.items():
        content = path.read_text(encoding='utf-8')
        for marker in markers:
            if marker not in content:
                raise RuntimeError(
                    f'Kurulum doğrulaması başarısız: {path} / {marker}'
                )

    if shutil.which('dart'):
        run([
            'dart', 'format',
            'lib/main.dart',
            'lib/premium_pawn_picker.dart',
            'test/system_smoke_test.dart',
        ])

    run(['git', 'diff', '--check'])

    changed_paths = subprocess.check_output(
        ['git', 'diff', '--name-only'], text=True
    ).splitlines()
    if 'assets/questions.json' in changed_paths:
        raise RuntimeError(
            'Güvenlik kontrolü: assets/questions.json değişmiş görünüyor.'
        )

    allowed = {
        'lib/main.dart',
        'lib/premium_pawn_picker.dart',
        'pubspec.yaml',
        'pubspec.lock',
        'test/system_smoke_test.dart',
    }
    unexpected = [path for path in changed_paths if path not in allowed]
    if unexpected:
        raise RuntimeError(
            'Beklenmeyen dosya değişiklikleri görüldü:\n'
            + '\n'.join(unexpected)
        )

    if shutil.which('flutter'):
        run(['flutter', 'pub', 'get'])
        run([
            'flutter',
            'analyze',
            '--no-fatal-warnings',
            '--no-fatal-infos',
        ])
        run(['flutter', 'test'])
    else:
        print(
            "ℹ️ Flutter bu ortamda bulunamadı; analiz ve test "
            "GitHub Actions'ta çalışacak."
        )

    files_to_stage = [
        'lib/main.dart',
        'lib/premium_pawn_picker.dart',
        'test/system_smoke_test.dart',
        'pubspec.yaml',
    ]
    if Path('pubspec.lock').exists():
        files_to_stage.append('pubspec.lock')

    run(['git', 'add', *files_to_stage])

    staged = subprocess.check_output(
        ['git', 'diff', '--cached', '--name-only'], text=True
    ).splitlines()
    if 'assets/questions.json' in staged:
        raise RuntimeError('Soru dosyası yanlışlıkla stage alanına girdi.')

    has_changes = subprocess.run(
        ['git', 'diff', '--cached', '--quiet'], check=False
    ).returncode != 0
    if not has_changes:
        raise RuntimeError('Commit edilecek değişiklik bulunamadı.')

    run(['git', 'commit', '-m', COMMIT_MESSAGE])
    committed = True
    run(['git', 'push', 'origin', 'main'])

except Exception as error:
    if not committed:
        shutil.copy2(backup_dir / 'main.dart', MAIN)
        shutil.copy2(backup_dir / 'pubspec.yaml', PUBSPEC)
        shutil.copy2(backup_dir / 'system_smoke_test.dart', TEST)
        if TARGET.exists():
            TARGET.unlink()

        reset_paths = [
            'lib/main.dart',
            'lib/premium_pawn_picker.dart',
            'test/system_smoke_test.dart',
            'pubspec.yaml',
        ]
        if Path('pubspec.lock').exists():
            reset_paths.append('pubspec.lock')
        subprocess.run(['git', 'reset', '--', *reset_paths], check=False)
        if shutil.which('flutter'):
            subprocess.run(['flutter', 'pub', 'get'], check=False)

    print('')
    print('❌ Kurulum tamamlanamadı.')
    print(str(error))
    if committed:
        print(
            'Commit oluşturuldu fakat push başarısız oldu. '
            'Tekrar dene: git push origin main'
        )
    else:
        print('Özellik dosyaları önceki hâline otomatik döndürüldü.')
        print('Soru dosyasına ve soru commitlerine dokunulmadı.')
    raise SystemExit(1)

finally:
    shutil.rmtree(backup_dir, ignore_errors=True)

print('')
print('✅ Premium piyon seçim ekranı eklendi.')
print('✅ 16 piyon büyük kartlar ve seçili piyon önizlemesiyle gösteriliyor.')
print('✅ Her piyonun adı, açıklaması ve ses karakteri görüntüleniyor.')
print('✅ Sesini Dinle düğmesi hareket sesini oyun öncesinde oynatıyor.')
print('✅ Son dört piyon ÖZEL rozeti ve kendine özgü aura kazandı.')
print('✅ Küçük telefon ekranlarında kaydırılabilir ve taşmasız çalışır.')
print('✅ questions.json dosyasına dokunulmadı.')
print('✅ Yeni sürüm: 1.40.0+50')
print('✅ Değişiklikler GitHub main dalına gönderildi.')
