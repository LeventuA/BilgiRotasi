#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

MAIN = Path('lib/main.dart')
PUBSPEC = Path('pubspec.yaml')
ABOUT = Path('lib/about_privacy.dart')
TEST = Path('test/system_smoke_test.dart')
TARGET = Path('lib/board_target_presentation.dart')
COMMIT_MESSAGE = 'Rota hedeflerinde ozel kutu simgelerini duzelt'

TARGET_CONTENT = """part of 'main.dart';

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
"""


def run(command):
    print('$ ' + ' '.join(command))
    return subprocess.run(command, check=True)


for path in [MAIN, PUBSPEC, ABOUT, TEST]:
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
        'Bu düzeltme yalnızca main dalına kurulabilir.\n'
        f'Şu anki dal: {branch or "(belirsiz)"}\n'
        'Önce: git switch main'
    )

question_status = subprocess.run(
    ['git', 'status', '--porcelain', '--', 'assets/questions.json'],
    text=True,
    capture_output=True,
    check=True,
).stdout.strip()
if question_status:
    raise SystemExit(
        'assets/questions.json dosyasında yerel değişiklik var.\n'
        'Soru çalışmasını tamamladıktan sonra bu düzeltmeyi çalıştır.'
    )

protected_targets = [
    'lib/main.dart',
    'pubspec.yaml',
    'lib/about_privacy.dart',
    'test/system_smoke_test.dart',
    'lib/board_target_presentation.dart',
]
target_status = subprocess.run(
    ['git', 'status', '--porcelain', '--', *protected_targets],
    text=True,
    capture_output=True,
    check=True,
).stdout.strip()
if target_status:
    raise SystemExit(
        'Düzeltmenin değiştireceği dosyalarda yerel değişiklik var:\n'
        f'{target_status}\n\n'
        'Bu dosyalardaki çalışmayı commit et veya yedekle. '
        'Diğer yerel dosyalara dokunulmayacak.'
    )

main = MAIN.read_text(encoding='utf-8')
pubspec = PUBSPEC.read_text(encoding='utf-8')
about = ABOUT.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')

version_match = re.search(
    r'^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$',
    pubspec,
    flags=re.MULTILINE,
)
if version_match is None:
    raise SystemExit('pubspec.yaml sürüm satırı okunamadı.')

version = tuple(map(int, version_match.groups()))
if version != (1, 43, 0, 55):
    raise SystemExit(
        'Bu düzeltme 1.43.0+55 sürümü için hazırlandı.\n'
        f'Depodaki sürüm: {version[0]}.{version[1]}.{version[2]}+{version[3]}\n'
        'Önce git pull çalıştır. Sürüm yine farklıysa güncel düzeltme gerekir.'
    )

if TARGET.exists() or 'BoardTargetPresentation' in main:
    raise SystemExit('Bu düzeltme zaten kurulmuş görünüyor.')

for marker in [
    "part 'short_challenge_mode.dart';",
    'class GameBoard',
    'class RouteTargetPulse',
    'final category = destination.categoryIndex < 0',
    "emoji: category?.emoji ?? '🧭'",
    'Bilgi Rotası • Sürüm 1.43.0',
]:
    if marker not in main:
        raise SystemExit(f'Gerekli kod yapısı bulunamadı: {marker}')

backup_dir = Path(tempfile.mkdtemp(prefix='bilgi_rotasi_target_icon_fix_'))
committed = False

try:
    shutil.copy2(MAIN, backup_dir / 'main.dart')
    shutil.copy2(PUBSPEC, backup_dir / 'pubspec.yaml')
    shutil.copy2(ABOUT, backup_dir / 'about_privacy.dart')
    shutil.copy2(TEST, backup_dir / 'system_smoke_test.dart')

    TARGET.write_text(TARGET_CONTENT, encoding='utf-8')

    part_anchor = "part 'short_challenge_mode.dart';"
    main = main.replace(
        part_anchor,
        part_anchor + "\npart 'board_target_presentation.dart';",
        1,
    )

    old_category = """                final category = destination.categoryIndex < 0
                    ? null
                    : GameCategory.values[destination.categoryIndex];
"""
    new_category = """                final targetColor =
                    BoardTargetPresentation.colorFor(destination);
                final targetEmoji =
                    BoardTargetPresentation.emojiFor(destination);
"""
    if old_category not in main:
        raise RuntimeError('Rota hedefi kategori bloğu bulunamadı.')
    main = main.replace(old_category, new_category, 1)

    old_target = """                    label: BoardMap.routeTitle(option),
                    child: RouteTargetPulse(
                      key: ValueKey<int>(option.destination),
                      color: category?.color ?? const Color(0xFF155E75),
                      emoji: category?.emoji ?? '🧭',
"""
    new_target = """                    label:
                        BoardTargetPresentation.semanticsLabelFor(option),
                    child: RouteTargetPulse(
                      key: ValueKey<int>(option.destination),
                      color: targetColor,
                      emoji: targetEmoji,
"""
    if old_target not in main:
        raise RuntimeError('Rota hedefi çizim bloğu bulunamadı.')
    main = main.replace(old_target, new_target, 1)

    main, count = re.subn(
        r'Bilgi Rotası • Sürüm 1\.43\.0',
        'Bilgi Rotası • Sürüm 1.43.1',
        main,
        count=1,
    )
    if count != 1:
        raise RuntimeError('Ana ekran sürüm yazısı güncellenemedi.')

    pubspec, count = re.subn(
        r'^version:\s*1\.43\.0\+55\s*$',
        'version: 1.43.1+56',
        pubspec,
        count=1,
        flags=re.MULTILINE,
    )
    if count != 1:
        raise RuntimeError('pubspec.yaml sürümü güncellenemedi.')

    about, count = re.subn(
        r'Sürüm 1\.43\.0\+55',
        'Sürüm 1.43.1+56',
        about,
        count=1,
    )
    if count != 1:
        raise RuntimeError('Hakkında ekranı sürümü güncellenemedi.')

    test_insert = r"""
    test('Rota hedefleri özel kutunun simgesini gösterir', () {
      for (final entry in BoardMap.specialCells.entries) {
        final node = BoardMap.node(entry.key);

        expect(
          BoardTargetPresentation.emojiFor(node),
          entry.value.emoji,
        );
        expect(
          BoardTargetPresentation.colorFor(node),
          entry.value.color,
        );
      }

      final normalNode = BoardMap.node(BoardMap.outerId(1));
      expect(normalNode.specialEffect, isNull);
      expect(
        BoardTargetPresentation.emojiFor(normalNode),
        GameCategory.values[normalNode.categoryIndex].emoji,
      );
    });
"""
    group_end = test.rfind('  });\n}')
    if group_end < 0:
        raise RuntimeError('Test dosyası ekleme noktası bulunamadı.')
    test = test[:group_end] + test_insert + test[group_end:]

    MAIN.write_text(main, encoding='utf-8')
    PUBSPEC.write_text(pubspec, encoding='utf-8')
    ABOUT.write_text(about, encoding='utf-8')
    TEST.write_text(test, encoding='utf-8')

    checks = {
        MAIN: [
            "part 'board_target_presentation.dart';",
            'BoardTargetPresentation.colorFor(destination)',
            'BoardTargetPresentation.emojiFor(destination)',
            'BoardTargetPresentation.semanticsLabelFor(option)',
            'Bilgi Rotası • Sürüm 1.43.1',
        ],
        TARGET: [
            'class BoardTargetPresentation',
            'return effect.emoji;',
            'return effect.color;',
        ],
        PUBSPEC: ['version: 1.43.1+56'],
        ABOUT: ['Sürüm 1.43.1+56'],
        TEST: ['Rota hedefleri özel kutunun simgesini gösterir'],
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
            'dart',
            'format',
            'lib/main.dart',
            'lib/board_target_presentation.dart',
            'lib/about_privacy.dart',
            'test/system_smoke_test.dart',
        ])

    run(['git', 'diff', '--check'])

    changed_paths = subprocess.check_output(
        ['git', 'diff', '--name-only'], text=True
    ).splitlines()
    if 'assets/questions.json' in changed_paths:
        raise RuntimeError('Güvenlik kontrolü: questions.json değişmiş görünüyor.')

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
        print('ℹ️ Flutter bulunamadı; analiz ve test GitHub Actions’ta çalışacak.')

    files_to_stage = [
        'lib/main.dart',
        'lib/board_target_presentation.dart',
        'lib/about_privacy.dart',
        'test/system_smoke_test.dart',
        'pubspec.yaml',
    ]
    if Path('pubspec.lock').exists():
        files_to_stage.append('pubspec.lock')

    run(['git', 'add', *files_to_stage])

    staged_paths = subprocess.check_output(
        ['git', 'diff', '--cached', '--name-only'], text=True
    ).splitlines()
    unexpected = [path for path in staged_paths if path not in set(files_to_stage)]
    if unexpected:
        raise RuntimeError(
            'Beklenmeyen dosyalar stage alanına girdi: ' + ', '.join(unexpected)
        )

    if subprocess.run(
        ['git', 'diff', '--cached', '--quiet'], check=False
    ).returncode == 0:
        raise RuntimeError('Commit edilecek değişiklik bulunamadı.')

    run(['git', 'commit', '-m', COMMIT_MESSAGE])
    committed = True
    run(['git', 'push', 'origin', 'main'])

except Exception as error:
    if not committed:
        shutil.copy2(backup_dir / 'main.dart', MAIN)
        shutil.copy2(backup_dir / 'pubspec.yaml', PUBSPEC)
        shutil.copy2(backup_dir / 'about_privacy.dart', ABOUT)
        shutil.copy2(backup_dir / 'system_smoke_test.dart', TEST)
        if TARGET.exists():
            TARGET.unlink()

        reset_paths = [
            'lib/main.dart',
            'lib/board_target_presentation.dart',
            'lib/about_privacy.dart',
            'test/system_smoke_test.dart',
            'pubspec.yaml',
        ]
        if Path('pubspec.lock').exists():
            reset_paths.append('pubspec.lock')
        subprocess.run(['git', 'reset', '--', *reset_paths], check=False)
        if shutil.which('flutter'):
            subprocess.run(['flutter', 'pub', 'get'], check=False)

    print('')
    print('❌ Düzeltme tamamlanamadı.')
    print(str(error))
    if committed:
        print('Commit oluştu fakat push başarısız oldu: git push origin main')
    else:
        print('Hedef dosyalar önceki hâline otomatik döndürüldü.')
    raise SystemExit(1)
finally:
    shutil.rmtree(backup_dir, ignore_errors=True)

print('')
print('✅ Yol seçimindeki hedef balonları artık özel kutu simgesini gösteriyor.')
print('✅ Kategori Seç kutusunda kategori simgesi yerine 🎯 korunuyor.')
print('✅ Tekrar Zar At, Rastgele Joker ve Çifte Şans simgeleri de korunuyor.')
print('✅ Kutuların işlevleri ve soru bankası değiştirilmedi.')
print('✅ Yeni sürüm: 1.43.1+56')
print('✅ Değişiklikler GitHub main dalına gönderildi.')
