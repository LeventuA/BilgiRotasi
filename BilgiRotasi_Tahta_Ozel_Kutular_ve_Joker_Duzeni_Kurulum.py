#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

MAIN = Path('lib/main.dart')
GAMEPLAY = Path('lib/gameplay_boost.dart')
PUBSPEC = Path('pubspec.yaml')
TEST = Path('test/system_smoke_test.dart')
ABOUT = Path('lib/about_privacy.dart')
QUESTION_FILE = Path('assets/questions.json')

EXPECTED_VERSION = (1, 42, 0, 54)
NEW_VERSION = '1.43.0+55'
NEW_VISIBLE_VERSION = '1.43.0'
COMMIT_MESSAGE = 'Zar tekrar jokerini kaldir ve ozel kutulari yenile'

TARGET_PATHS = [MAIN, GAMEPLAY, PUBSPEC, TEST, ABOUT]


def run(command: list[str]) -> None:
    print('$ ' + ' '.join(command))
    subprocess.run(command, check=True)


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise RuntimeError(
            f'{label} için beklenen kod bloğu {count} kez bulundu; 1 kez bulunmalıydı.'
        )
    return text.replace(old, new, 1)


def regex_replace_once(
    text: str,
    pattern: str,
    replacement: str,
    label: str,
) -> str:
    updated, count = re.subn(
        pattern,
        lambda _match: replacement,
        text,
        count=1,
        flags=re.DOTALL,
    )
    if count != 1:
        raise RuntimeError(
            f'{label} için beklenen kod bloğu bulunamadı veya birden fazla eşleşti.'
        )
    return updated


for path in TARGET_PATHS:
    if not path.exists():
        raise SystemExit(
            f'Gerekli dosya bulunamadı: {path}\n'
            'Kurulumu BilgiRotasi deposunun ana klasöründe çalıştır.'
        )

branch = subprocess.check_output(
    ['git', 'branch', '--show-current'],
    text=True,
).strip()

if branch != 'main':
    raise SystemExit(
        'Bu özellik yalnızca main dalına kurulabilir.\n'
        f'Şu anki dal: {branch or "(belirsiz)"}\n'
        'Önce: git switch main'
    )

question_status = subprocess.run(
    ['git', 'status', '--porcelain', '--', str(QUESTION_FILE)],
    text=True,
    capture_output=True,
    check=True,
).stdout.strip()

if question_status:
    raise SystemExit(
        'assets/questions.json dosyasında yerel değişiklik var.\n'
        'Soru çalışmasını tamamlayıp main dalını güncelledikten sonra bu paketi çalıştır.'
    )

changed_targets = subprocess.run(
    ['git', 'status', '--porcelain', '--', *[str(path) for path in TARGET_PATHS]],
    text=True,
    capture_output=True,
    check=True,
).stdout.strip()

if changed_targets:
    raise SystemExit(
        'Bu paketin değiştireceği oyun dosyalarında yerel değişiklik var:\n'
        f'{changed_targets}\n'
        'Bu değişiklikleri önce tamamla veya commit et. Diğer dosyalardaki yerel '
        'değişikliklere paket dokunmaz.'
    )

main = MAIN.read_text(encoding='utf-8')
gameplay = GAMEPLAY.read_text(encoding='utf-8')
pubspec = PUBSPEC.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')
about = ABOUT.read_text(encoding='utf-8')

version_match = re.search(
    r'^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$',
    pubspec,
    flags=re.MULTILINE,
)
if version_match is None:
    raise SystemExit('pubspec.yaml sürüm satırı okunamadı.')

version = tuple(map(int, version_match.groups()))
if version != EXPECTED_VERSION:
    raise SystemExit(
        'Bu paket 1.42.0+54 sürümü için hazırlandı.\n'
        f'Depodaki sürüm: {version[0]}.{version[1]}.{version[2]}+{version[3]}\n'
        'Önce git pull çalıştır. Sürüm yine farklıysa güncel paket hazırlanması gerekir.'
    )

required_main_markers = [
    "part 'premium_dice.dart';",
    "part 'short_challenge_mode.dart';",
    'bool _diceRolling = false;',
    'case SpecialCellEffect.forwardTwo:',
    'case SpecialCellEffect.backTwo:',
    'GameplayBoostDialogs.offerReroll(',
]
for marker in required_main_markers:
    if marker not in main:
        raise SystemExit(f'Gerekli ana oyun kodu bulunamadı: {marker}')

required_gameplay_markers = [
    'enum JokerKind {',
    'JokerKind.reroll',
    'wallet.reroll',
    'static Future<bool> offerReroll(',
]
for marker in required_gameplay_markers:
    if marker not in gameplay:
        raise SystemExit(f'Gerekli joker kodu bulunamadı: {marker}')

backup_dir = Path(tempfile.mkdtemp(prefix='bilgi_rotasi_board_specials_'))
committed = False

try:
    for path in TARGET_PATHS:
        shutil.copy2(path, backup_dir / path.name)

    # ------------------------------------------------------------------
    # Zar Tekrar jokerini tamamen kaldır.
    # ------------------------------------------------------------------
    gameplay = replace_once(
        gameplay,
        """            subtitle:\n                '50:50, soru değiştir, ikinci şans, '\n                'kategori değiştir ve zar tekrar.',\n""",
        """            subtitle:\n                '50:50, soru değiştir, ikinci şans ve '\n                'kategori değiştir.',\n""",
        'Joker ayar açıklaması',
    )

    gameplay = replace_once(
        gameplay,
        """              'Jokerler her yeni oyun veya maratonda '\n              'yenilenir. Her oyuncu her jokerden bir adetle '\n              'başlar. Yanlış cevap XP düşürmez; yalnızca '\n              'doğru cevap serisini sıfırlar.',\n""",
        """              'Jokerler her yeni oyun veya maratonda '\n              'yenilenir. Her oyuncu dört jokerin her birinden '\n              'bir adetle başlar. Tahtadaki hediye kutusu '\n              'rastgele bir jokere +1 ekler. Yanlış cevap '\n              'XP düşürmez; yalnızca doğru cevap serisini '\n              'sıfırlar.',\n""",
        'Joker bilgi kutusu',
    )

    joker_wallet_block = r"""enum JokerKind {
  fiftyFifty,
  changeQuestion,
  secondChance,
  categoryChange,
}

extension JokerKindX on JokerKind {
  String get title => switch (this) {
        JokerKind.fiftyFifty => '50:50',
        JokerKind.changeQuestion => 'Soru Değiştir',
        JokerKind.secondChance => 'İkinci Şans',
        JokerKind.categoryChange => 'Kategori Değiştir',
      };

  String get emoji => switch (this) {
        JokerKind.fiftyFifty => '✂️',
        JokerKind.changeQuestion => '🔄',
        JokerKind.secondChance => '🍀',
        JokerKind.categoryChange => '🎨',
      };
}

class JokerWallet {
  JokerWallet({
    this.fiftyFifty = 1,
    this.changeQuestion = 1,
    this.secondChance = 1,
    this.categoryChange = 1,
  });

  int fiftyFifty;
  int changeQuestion;
  int secondChance;
  int categoryChange;

  factory JokerWallet.starter() => JokerWallet();

  int count(JokerKind kind) {
    return switch (kind) {
      JokerKind.fiftyFifty => fiftyFifty,
      JokerKind.changeQuestion => changeQuestion,
      JokerKind.secondChance => secondChance,
      JokerKind.categoryChange => categoryChange,
    };
  }

  bool consume(JokerKind kind) {
    if (count(kind) <= 0) return false;

    switch (kind) {
      case JokerKind.fiftyFifty:
        fiftyFifty--;
        break;
      case JokerKind.changeQuestion:
        changeQuestion--;
        break;
      case JokerKind.secondChance:
        secondChance--;
        break;
      case JokerKind.categoryChange:
        categoryChange--;
        break;
    }

    return true;
  }

  void grant(JokerKind kind, {int amount = 1}) {
    final safeAmount = max(0, amount);
    if (safeAmount == 0) return;

    switch (kind) {
      case JokerKind.fiftyFifty:
        fiftyFifty += safeAmount;
        break;
      case JokerKind.changeQuestion:
        changeQuestion += safeAmount;
        break;
      case JokerKind.secondChance:
        secondChance += safeAmount;
        break;
      case JokerKind.categoryChange:
        categoryChange += safeAmount;
        break;
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'fiftyFifty': fiftyFifty,
        'changeQuestion': changeQuestion,
        'secondChance': secondChance,
        'categoryChange': categoryChange,
      };

  factory JokerWallet.fromJson(dynamic raw) {
    if (raw is! Map) return JokerWallet.starter();

    final json = Map<String, dynamic>.from(raw);

    int read(String key) {
      return max(
        0,
        (json[key] as num?)?.toInt() ?? 1,
      );
    }

    return JokerWallet(
      fiftyFifty: read('fiftyFifty'),
      changeQuestion: read('changeQuestion'),
      secondChance: read('secondChance'),
      categoryChange: read('categoryChange'),
    );
  }
}

class JokerWalletMiniBar"""

    gameplay = regex_replace_once(
        gameplay,
        r'enum JokerKind \{.*?\n\}\n\nclass JokerWalletMiniBar',
        joker_wallet_block,
        'Joker türleri ve cüzdanı',
    )

    gameplay = replace_once(
        gameplay,
        """    final values = <(String, int)>[\n      ('✂️', wallet.fiftyFifty),\n      ('🔄', wallet.changeQuestion),\n      ('🍀', wallet.secondChance),\n      ('🎨', wallet.categoryChange),\n      ('🎲', wallet.reroll),\n    ];\n""",
        """    final values = <(String, int)>[\n      ('✂️', wallet.fiftyFifty),\n      ('🔄', wallet.changeQuestion),\n      ('🍀', wallet.secondChance),\n      ('🎨', wallet.categoryChange),\n    ];\n""",
        'Joker mini çubuğu',
    )

    gameplay = regex_replace_once(
        gameplay,
        r'\n  static Future<bool> offerReroll\(.*?\n  \}\n\}\n\nclass GameplayBoostQuestionPicker',
        '\n}\n\nclass GameplayBoostQuestionPicker',
        'Zar Tekrar teklif penceresi',
    )

    # ------------------------------------------------------------------
    # Ana oyundan zar tekrar teklifini çıkar.
    # ------------------------------------------------------------------
    main = replace_once(
        main,
        '  bool _diceRolling = false;\n  bool _isBusy = false;',
        '  bool _diceRolling = false;\n  bool _bonusRollPending = false;\n  bool _isBusy = false;',
        'Tekrar zar durumu',
    )

    reroll_flow = """    var diceResult = _random.nextInt(6) + 1;\n\n    setState(() {\n      _lastDice = diceResult;\n      _diceRolling = false;\n    });\n\n    final useReroll =\n        await GameplayBoostDialogs.offerReroll(\n      context,\n      currentRoll: diceResult,\n      wallet: _currentPlayer.jokers,\n    );\n\n    if (!mounted) return;\n\n    if (useReroll &&\n        _currentPlayer.jokers.consume(\n          JokerKind.reroll,\n        )) {\n      setState(() {\n        _lastDice = null;\n        _diceRolling = true;\n      });\n      unawaited(SoundFx.dice());\n      GameHaptics.mediumImpact();\n      await Future<void>.delayed(\n        const Duration(milliseconds: 450),\n      );\n      diceResult = _random.nextInt(6) + 1;\n    }\n\n    setState(() {\n"""
    main = replace_once(
        main,
        reroll_flow,
        """    final diceResult = _random.nextInt(6) + 1;\n\n    setState(() {\n""",
        'Ana oyundaki Zar Tekrar akışı',
    )

    special_call_old = """    if (specialEffect != null) {\n      selectedCategory = await _resolveSpecialEffect(\n        specialEffect,\n        selected,\n      );\n\n      if (!mounted) return;\n\n      target = BoardMap.node(_currentPlayer.position);\n      await _saveGame();\n    }\n"""
    special_call_new = """    if (specialEffect != null) {\n      selectedCategory = await _resolveSpecialEffect(\n        specialEffect,\n      );\n\n      if (!mounted) return;\n\n      target = BoardMap.node(_currentPlayer.position);\n      await _saveGame();\n\n      if (_bonusRollPending) {\n        setState(() {\n          _bonusRollPending = false;\n          _isBusy = false;\n          _lastDice = null;\n          _diceRolling = false;\n          _status =\n              '${_currentPlayer.name}, tekrar zar atma hakkı sende! 🎲';\n        });\n        return;\n      }\n    }\n"""
    main = replace_once(
        main,
        special_call_old,
        special_call_new,
        'Özel kutu çözüm çağrısı',
    )

    resolver_block = r"""  Future<int?> _resolveSpecialEffect(
    SpecialCellEffect effect,
  ) async {
    if (effect == SpecialCellEffect.randomJoker) {
      final kind = JokerKind.values[
        _random.nextInt(JokerKind.values.length)
      ];
      _currentPlayer.jokers.grant(kind);

      setState(() {
        _status =
            '${_currentPlayer.name}, ${kind.emoji} ${kind.title} jokeri kazandı!';
      });

      unawaited(SoundFx.badge());
      GameHaptics.heavyImpact();
      await _showJokerRewardDialog(kind);
      return null;
    }

    await _showSpecialEffectDialog(effect);

    if (!mounted) return null;

    unawaited(SoundFx.badge());
    GameHaptics.heavyImpact();

    switch (effect) {
      case SpecialCellEffect.rollAgain:
        setState(() {
          _bonusRollPending = true;
          _status =
              '${_currentPlayer.name} tekrar zar atma hakkı kazandı! 🎲';
        });
        return null;

      case SpecialCellEffect.randomJoker:
        return null;

      case SpecialCellEffect.chooseCategory:
        return _chooseQuestionCategory();

      case SpecialCellEffect.doubleChance:
        setState(() {
          _currentPlayer.doubleChance = true;
          _status =
              '${_currentPlayer.name} Çifte Şans hakkı kazandı! 🍀';
        });
        return null;
    }
  }

  Future<void> _showJokerRewardDialog(
    JokerKind kind,
  ) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Text(
            kind.emoji,
            style: const TextStyle(fontSize: 52),
          ),
          title: const Text('Joker Kazandın!'),
          content: Text(
            '${kind.title} jokerine +1 eklendi.\n\n'
            'Yeni toplam: ${_currentPlayer.jokers.count(kind)}',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Harika'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSpecialEffectDialog("""

    main = regex_replace_once(
        main,
        r'  Future<int\?> _resolveSpecialEffect\(.*?\n  Future<void> _showSpecialEffectDialog\(',
        resolver_block,
        'Özel kutu çözüm sistemi',
    )

    # ------------------------------------------------------------------
    # Özel kutu türleri ve tahtadaki konumları.
    # ------------------------------------------------------------------
    special_enum_block = r"""enum SpecialCellEffect {
  rollAgain,
  randomJoker,
  chooseCategory,
  doubleChance,
}

extension SpecialCellEffectX on SpecialCellEffect {
  String get title {
    switch (this) {
      case SpecialCellEffect.rollAgain:
        return 'Tekrar Zar At';
      case SpecialCellEffect.randomJoker:
        return 'Joker Kazan';
      case SpecialCellEffect.chooseCategory:
        return 'Kategori Seç';
      case SpecialCellEffect.doubleChance:
        return 'Çifte Şans';
    }
  }

  String get emoji {
    switch (this) {
      case SpecialCellEffect.rollAgain:
        return '🎲';
      case SpecialCellEffect.randomJoker:
        return '🎁';
      case SpecialCellEffect.chooseCategory:
        return '🎯';
      case SpecialCellEffect.doubleChance:
        return '🍀';
    }
  }

  String get description {
    switch (this) {
      case SpecialCellEffect.rollAgain:
        return 'Bu kutuda soru açılmaz. Aynı oyuncu zarı yeniden atar.';
      case SpecialCellEffect.randomJoker:
        return 'Dört aktif jokerden biri rastgele seçilir ve +1 eklenir.';
      case SpecialCellEffect.chooseCategory:
        return 'Bu turda sorulacak kategoriyi sen seçersin.';
      case SpecialCellEffect.doubleChance:
        return 'Bir sonraki yanlış cevabında sıra sende kalır. '
            'Hak kullanılana kadar korunur.';
    }
  }

  Color get color {
    switch (this) {
      case SpecialCellEffect.rollAgain:
        return const Color(0xFF06B6D4);
      case SpecialCellEffect.randomJoker:
        return const Color(0xFFF59E0B);
      case SpecialCellEffect.chooseCategory:
        return const Color(0xFF8B5CF6);
      case SpecialCellEffect.doubleChance:
        return const Color(0xFF22C55E);
    }
  }
}

enum BoardNodeKind"""

    main = regex_replace_once(
        main,
        r'enum SpecialCellEffect \{.*?\n\}\n\nenum BoardNodeKind',
        special_enum_block,
        'Özel kutu türleri',
    )

    main = replace_once(
        main,
        """  static const Map<int, SpecialCellEffect> specialCells = {\n    4: SpecialCellEffect.forwardTwo,\n    22: SpecialCellEffect.forwardTwo,\n    9: SpecialCellEffect.backTwo,\n    27: SpecialCellEffect.backTwo,\n    14: SpecialCellEffect.chooseCategory,\n    32: SpecialCellEffect.chooseCategory,\n    18: SpecialCellEffect.doubleChance,\n    36: SpecialCellEffect.doubleChance,\n  };\n""",
        """  static const Map<int, SpecialCellEffect> specialCells = {\n    4: SpecialCellEffect.rollAgain,\n    22: SpecialCellEffect.rollAgain,\n    9: SpecialCellEffect.randomJoker,\n    27: SpecialCellEffect.randomJoker,\n    14: SpecialCellEffect.chooseCategory,\n    32: SpecialCellEffect.chooseCategory,\n    18: SpecialCellEffect.doubleChance,\n    36: SpecialCellEffect.doubleChance,\n  };\n""",
        'Tahta özel kutu konumları',
    )

    # ------------------------------------------------------------------
    # Sürüm ve testler.
    # ------------------------------------------------------------------
    main = replace_once(
        main,
        'Bilgi Rotası • Sürüm 1.42.0',
        f'Bilgi Rotası • Sürüm {NEW_VISIBLE_VERSION}',
        'Ana ekran sürüm yazısı',
    )

    about = replace_once(
        about,
        'Sürüm 1.42.0+54',
        f'Sürüm {NEW_VERSION}',
        'Hakkında ekranı sürümü',
    )

    pubspec, version_count = re.subn(
        r'^version:\s*.*$',
        f'version: {NEW_VERSION}',
        pubspec,
        count=1,
        flags=re.MULTILINE,
    )
    if version_count != 1:
        raise RuntimeError('pubspec.yaml sürümü güncellenemedi.')

    test_insert = r"""

    test('Zar jokeri kaldırılır ve özel kutular yenilenir', () {
      expect(JokerKind.values.length, 4);

      final wallet = JokerWallet(
        fiftyFifty: 0,
        changeQuestion: 0,
        secondChance: 0,
        categoryChange: 0,
      );
      wallet.grant(JokerKind.changeQuestion);
      expect(wallet.changeQuestion, 1);
      expect(wallet.toJson().containsKey('reroll'), isFalse);

      expect(
        BoardMap.specialCells.values
            .where((effect) => effect == SpecialCellEffect.rollAgain)
            .length,
        2,
      );
      expect(
        BoardMap.specialCells.values
            .where((effect) => effect == SpecialCellEffect.randomJoker)
            .length,
        2,
      );
      expect(BoardMap.specialCells[4], SpecialCellEffect.rollAgain);
      expect(BoardMap.specialCells[22], SpecialCellEffect.rollAgain);
      expect(BoardMap.specialCells[9], SpecialCellEffect.randomJoker);
      expect(BoardMap.specialCells[27], SpecialCellEffect.randomJoker);
      expect((22 - 4).abs(), BoardMap.outerCount ~/ 2);
      expect((27 - 9).abs(), BoardMap.outerCount ~/ 2);
    });
"""

    if 'Zar jokeri kaldırılır ve özel kutular yenilenir' in test:
        raise RuntimeError('Yeni özel kutu testi zaten eklenmiş görünüyor.')

    group_end = test.rfind('  });\n}')
    if group_end < 0:
        raise RuntimeError('Test dosyasının ekleme noktası bulunamadı.')
    test = test[:group_end] + test_insert + test[group_end:]

    MAIN.write_text(main, encoding='utf-8')
    GAMEPLAY.write_text(gameplay, encoding='utf-8')
    PUBSPEC.write_text(pubspec, encoding='utf-8')
    TEST.write_text(test, encoding='utf-8')
    ABOUT.write_text(about, encoding='utf-8')

    # Güvenlik ve içerik doğrulamaları.
    combined = main + '\n' + gameplay
    forbidden = [
        'SpecialCellEffect.forwardTwo',
        'SpecialCellEffect.backTwo',
        'JokerKind.reroll',
        'wallet.reroll',
        'offerReroll(',
    ]
    for marker in forbidden:
        if marker in combined:
            raise RuntimeError(f'Kaldırılması gereken kod hâlâ mevcut: {marker}')

    required_after = {
        MAIN: [
            'SpecialCellEffect.rollAgain',
            'SpecialCellEffect.randomJoker',
            '_bonusRollPending',
            '_showJokerRewardDialog',
            'Bilgi Rotası • Sürüm 1.43.0',
        ],
        GAMEPLAY: [
            'void grant(JokerKind kind',
            "JokerKind.fiftyFifty => '50:50'",
            "('🎨', wallet.categoryChange)",
        ],
        PUBSPEC: ['version: 1.43.0+55'],
        ABOUT: ['Sürüm 1.43.0+55'],
        TEST: ['Zar jokeri kaldırılır ve özel kutular yenilenir'],
    }

    for path, markers in required_after.items():
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
            str(MAIN),
            str(GAMEPLAY),
            str(TEST),
            str(ABOUT),
        ])

    run([
        'git',
        'diff',
        '--check',
        '--',
        *[str(path) for path in TARGET_PATHS],
    ])

    changed_files = subprocess.check_output(
        ['git', 'diff', '--name-only'],
        text=True,
    ).splitlines()
    if str(QUESTION_FILE) in changed_files:
        raise RuntimeError(
            'Güvenlik kontrolü: assets/questions.json değişmiş görünüyor.'
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
            'ℹ️ Flutter bu ortamda bulunamadı; analiz ve test GitHub Actions’ta çalışacak.'
        )

    run(['git', 'add', *[str(path) for path in TARGET_PATHS]])

    has_changes = subprocess.run(
        ['git', 'diff', '--cached', '--quiet'],
        check=False,
    ).returncode != 0
    if not has_changes:
        raise RuntimeError('Commit edilecek değişiklik bulunamadı.')

    run(['git', 'commit', '-m', COMMIT_MESSAGE])
    committed = True
    run(['git', 'push', 'origin', 'main'])

except Exception as error:
    if not committed:
        for path in TARGET_PATHS:
            backup = backup_dir / path.name
            if backup.exists():
                shutil.copy2(backup, path)

        subprocess.run(
            ['git', 'reset', '--', *[str(path) for path in TARGET_PATHS]],
            check=False,
        )

        if shutil.which('flutter'):
            subprocess.run(['flutter', 'pub', 'get'], check=False)

    print('')
    print('❌ Kurulum tamamlanamadı.')
    print(str(error))

    if committed:
        print(
            'Commit oluşturuldu fakat push başarısız oldu. Tekrar dene: git push origin main'
        )
    else:
        print('Paketin değiştirdiği dosyalar önceki hâline otomatik döndürüldü.')

    raise SystemExit(1)

finally:
    shutil.rmtree(backup_dir, ignore_errors=True)

print('')
print('✅ Zar Tekrar jokeri tamamen kaldırıldı.')
print('✅ İleri 2 ve Geri 2 kutuları kaldırıldı.')
print('✅ Tahtanın karşılıklı uzak iki noktasına Tekrar Zar At kutusu eklendi.')
print('✅ Diğer iki kutu rastgele +1 joker kazandırıyor.')
print('✅ Aktif jokerler: 50:50, Soru Değiştir, İkinci Şans, Kategori Değiştir.')
print('✅ questions.json ve ilgisiz yerel değişiklikler korunuyor.')
print(f'✅ Yeni sürüm: {NEW_VERSION}')
print('✅ Değişiklikler GitHub main dalına gönderildi.')
