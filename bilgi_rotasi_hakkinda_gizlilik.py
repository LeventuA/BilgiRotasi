#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess

MAIN = Path('lib/main.dart')
NAV = Path('lib/main_navigation.dart')
PUBSPEC = Path('pubspec.yaml')
SCREEN = Path('about_privacy.dart')

for path in [MAIN, NAV, PUBSPEC, SCREEN]:
    if not path.exists():
        raise SystemExit(f'Gerekli dosya bulunamadı: {path}')

main = MAIN.read_text(encoding='utf-8')
nav = NAV.read_text(encoding='utf-8')

if "part 'about_privacy.dart';" in main:
    raise SystemExit('Hakkında & Gizlilik düzeltmesi zaten uygulanmış.')

if "part 'pawn_visual_effects.dart';" not in main:
    raise SystemExit('Güncel Bilgi Rotası kodu bulunamadı. Önce git pull yap.')

tutorial = """        _HubActionCard(
          emoji: '📘',
          title: 'Eğitimi Yeniden Göster',"""

if tutorial not in nav:
    raise SystemExit('Ayarlar ekranındaki yerleştirme noktası bulunamadı.')

shutil.copy2(MAIN, '/tmp/br_about_main_before.dart')
shutil.copy2(NAV, '/tmp/br_about_nav_before.dart')

shutil.copy2(SCREEN, 'lib/about_privacy.dart')

main = main.replace(
    "part 'pawn_visual_effects.dart';",
    "part 'pawn_visual_effects.dart';\n"
    "part 'about_privacy.dart';",
    1,
)
main = main.replace(
    'Bilgi Rotası • Sürüm 1.41.0',
    'Bilgi Rotası • Sürüm 1.41.1',
    1,
)
MAIN.write_text(main, encoding='utf-8')

card = """        _HubActionCard(
          emoji: 'ℹ️',
          title: 'Hakkında & Gizlilik',
          description:
              'Sürüm bilgisi, çevrimdışı kullanım, '
              'yerel kayıtlar ve gizlilik açıklaması.',
          accent: const Color(0xFF475569),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AboutPrivacyScreen(
                questionBank: questionBank,
              ),
            ),
          ),
        ),
"""

nav = nav.replace(tutorial, card + tutorial, 1)
NAV.write_text(nav, encoding='utf-8')

pub = PUBSPEC.read_text(encoding='utf-8')
pub = re.sub(
    r'^version:\s*.*$',
    'version: 1.41.1+52',
    pub,
    flags=re.MULTILINE,
)
PUBSPEC.write_text(pub, encoding='utf-8')

if shutil.which('dart'):
    subprocess.run([
        'dart', 'format',
        'lib/main.dart',
        'lib/main_navigation.dart',
        'lib/about_privacy.dart',
    ], check=True)

subprocess.run(['git', 'diff', '--check'], check=True)

if shutil.which('flutter'):
    subprocess.run(
        ['flutter', 'analyze', '--no-fatal-infos'],
        check=True,
    )

subprocess.run([
    'git', 'add',
    'lib/main.dart',
    'lib/main_navigation.dart',
    'lib/about_privacy.dart',
    'pubspec.yaml',
], check=True)

changed = subprocess.run(
    ['git', 'diff', '--cached', '--quiet'],
    check=False,
).returncode != 0

if changed:
    subprocess.run([
        'git', 'commit', '-m',
        'Hakkinda ve gizlilik ekranini ekle',
    ], check=True)

subprocess.run(
    ['git', 'push', 'origin', 'main'],
    check=True,
)

print('✅ Ayarlar bölümüne Hakkında & Gizlilik eklendi.')
print('✅ Gizlilik, internet ve yerel veri açıklamaları eklendi.')
print('✅ Sistem Sağlığına geçiş düğmesi eklendi.')
print('✅ Sürüm 1.41.1+52 yapıldı.')
print('✅ Değişiklikler GitHub main dalına gönderildi.')
