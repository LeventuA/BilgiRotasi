#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

MAIN = Path('lib/main.dart')
PUBSPEC = Path('pubspec.yaml')
TEST = Path('test/system_smoke_test.dart')
TARGET = Path('lib/pawn_visual_effects.dart')
COMMIT_MESSAGE = 'Piyon izleri ve ozel varis efektleri ekle'

DART_CONTENT = r'''part of 'main.dart';

class PawnFxProfile {
  const PawnFxProfile({
    required this.label,
    required this.primary,
    required this.secondary,
    required this.glyph,
  });

  final String label;
  final Color primary;
  final Color secondary;
  final String glyph;
}

class PawnVisualEffects {
  PawnVisualEffects._();

  static const List<PawnFxProfile> profiles = <PawnFxProfile>[
    PawnFxProfile(label: 'Gökkuşağı halkaları', primary: Color(0xFFFF4D9D), secondary: Color(0xFF38BDF8), glyph: '◌'),
    PawnFxProfile(label: 'Kristal parçacıkları', primary: Color(0xFF38BDF8), secondary: Color(0xFFE0F2FE), glyph: '◆'),
    PawnFxProfile(label: 'Zihin kıvılcımları', primary: Color(0xFFF472B6), secondary: Color(0xFFC084FC), glyph: '●'),
    PawnFxProfile(label: 'Klasik oyun izleri', primary: Color(0xFFB45309), secondary: Color(0xFFFDE68A), glyph: '♟'),
    PawnFxProfile(label: 'Bilge nal izleri', primary: Color(0xFF7C3AED), secondary: Color(0xFFD8B4FE), glyph: '∩'),
    PawnFxProfile(label: 'Kristal zar küpleri', primary: Color(0xFF06B6D4), secondary: Color(0xFFA5F3FC), glyph: '□'),
    PawnFxProfile(label: 'Pusula yıldızları', primary: Color(0xFFF59E0B), secondary: Color(0xFFFFF3B0), glyph: '✦'),
    PawnFxProfile(label: 'Uçuşan sayfalar', primary: Color(0xFF3B82F6), secondary: Color(0xFFDBEAFE), glyph: '▱'),
    PawnFxProfile(label: 'Fikir parlamaları', primary: Color(0xFFFACC15), secondary: Color(0xFFFFF7AE), glyph: '✺'),
    PawnFxProfile(label: 'Kum taneleri', primary: Color(0xFFF97316), secondary: Color(0xFFFED7AA), glyph: '⋮'),
    PawnFxProfile(label: 'Merak işaretleri', primary: Color(0xFF8B5CF6), secondary: Color(0xFFEDE9FE), glyph: '?'),
    PawnFxProfile(label: 'Zafer madalyaları', primary: Color(0xFFEAB308), secondary: Color(0xFFFFE082), glyph: '♛'),
    PawnFxProfile(label: 'Kozmik yıldız tozu', primary: Color(0xFF9D7CFF), secondary: Color(0xFF67E8F9), glyph: '★'),
    PawnFxProfile(label: 'Canlı yaprak izleri', primary: Color(0xFF22C55E), secondary: Color(0xFFBBF7D0), glyph: '❧'),
    PawnFxProfile(label: 'Altın sihir kıvılcımları', primary: Color(0xFFFFC857), secondary: Color(0xFFFFF1B8), glyph: '✧'),
    PawnFxProfile(label: 'Taş tozu ve yüzük ışığı', primary: Color(0xFFB6A0FF), secondary: Color(0xFFE7E0FF), glyph: '◉'),
  ];

  static int normalize(int pawnType) {
    return (pawnType % profiles.length + profiles.length) % profiles.length;
  }

  static PawnFxProfile profileFor(int pawnType) {
    return profiles[normalize(pawnType)];
  }

  static bool get minimalAnimations =>
      AppPreferencesService.current.animationMode == 'minimal';
}

class PawnStepTrailPainter extends CustomPainter {
  const PawnStepTrailPainter({
    required this.progress,
    required this.pawnType,
    required this.playerColor,
    required this.pulse,
    required this.minimal,
  });

  final double progress;
  final int pawnType;
  final Color playerColor;
  final int pulse;
  final bool minimal;

  @override
  void paint(Canvas canvas, Size size) {
    final strength = sin(pi * progress).clamp(0.0, 1.0).toDouble();
    if (strength < 0.003) return;

    final profile = PawnVisualEffects.profileFor(pawnType);
    final count = minimal ? 2 : 6;
    final direction = pulse.isEven ? -1.0 : 1.0;
    final origin = Offset(size.width * 0.50, size.height * 0.78);

    for (var index = 0; index < count; index++) {
      final depth = (index + 1) / count;
      final center = origin + Offset(
        direction * size.width * (0.10 + depth * 0.44),
        size.height * (0.03 + depth * 0.12) +
            sin((progress * 5 + index) * pi) * size.height * 0.025,
      );
      final opacity = strength * (1 - depth * 0.68);
      final color = index.isEven
          ? Color.lerp(profile.primary, playerColor, 0.18)!
          : profile.secondary;

      canvas.drawCircle(
        center,
        size.width * 0.060,
        Paint()
          ..color = color.withOpacity(opacity * 0.20)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );

      _paintPawnFxGlyph(
        canvas,
        profile.glyph,
        center,
        size.width * (minimal ? 0.090 : 0.075),
        color.withOpacity(opacity),
        progress * pi + index * 0.42,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PawnStepTrailPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.pawnType != pawnType ||
        oldDelegate.playerColor != playerColor ||
        oldDelegate.pulse != pulse ||
        oldDelegate.minimal != minimal;
  }
}

class PawnLandingSignaturePainter extends CustomPainter {
  const PawnLandingSignaturePainter({
    required this.progress,
    required this.pawnType,
    required this.playerColor,
    required this.minimal,
  });

  final double progress;
  final int pawnType;
  final Color playerColor;
  final bool minimal;

  @override
  void paint(Canvas canvas, Size size) {
    final profile = PawnVisualEffects.profileFor(pawnType);
    final center = Offset(size.width / 2, size.height / 2);
    final fade = (1 - progress).clamp(0.0, 1.0).toDouble();
    final opening = Curves.easeOutCubic.transform(progress);
    final radius = size.width * (0.15 + opening * 0.34);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1.0, size.width * 0.040 * fade)
        ..color = profile.primary.withOpacity(fade * 0.90)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(
      center,
      radius * 0.72,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1.0, size.width * 0.020 * fade)
        ..color = profile.secondary.withOpacity(fade * 0.94),
    );

    final count = minimal ? 4 : 10;
    for (var index = 0; index < count; index++) {
      final angle = -pi / 2 + index * 2 * pi / count + progress * 0.50;
      final point = center + Offset(cos(angle), sin(angle)) * radius;
      final color = index.isEven ? profile.primary : profile.secondary;
      _paintPawnFxGlyph(
        canvas,
        profile.glyph,
        point,
        size.width * (minimal ? 0.090 : 0.075),
        color.withOpacity(fade * (index.isEven ? 0.95 : 0.75)),
        angle + progress * pi,
      );
    }

    final type = PawnVisualEffects.normalize(pawnType);
    if (type >= 12) {
      canvas.drawCircle(
        center,
        size.width * (0.07 + opening * 0.10),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = max(1.0, size.width * 0.028 * fade)
          ..color = Color.lerp(profile.primary, playerColor, 0.20)!
              .withOpacity(fade)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
      _paintPawnFxGlyph(
        canvas,
        profile.glyph,
        center,
        size.width * (minimal ? 0.15 : 0.18),
        Colors.white.withOpacity(fade),
        type == 13 ? -0.40 : progress * pi,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PawnLandingSignaturePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.pawnType != pawnType ||
        oldDelegate.playerColor != playerColor ||
        oldDelegate.minimal != minimal;
  }
}

void _paintPawnFxGlyph(
  Canvas canvas,
  String glyph,
  Offset center,
  double fontSize,
  Color color,
  double rotation,
) {
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.rotate(rotation);

  final painter = TextPainter(
    text: TextSpan(
      text: glyph,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        height: 1,
        fontWeight: FontWeight.w900,
        shadows: <Shadow>[
          Shadow(
            color: color.withOpacity(0.45),
            blurRadius: 5,
          ),
        ],
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  )..layout();

  painter.paint(
    canvas,
    Offset(-painter.width / 2, -painter.height / 2),
  );
  canvas.restore();
}
'''


def run(command):
    print('$ ' + ' '.join(command))
    return subprocess.run(command, check=True)


for path in [MAIN, PUBSPEC, TEST]:
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
    ['git', 'status', '--porcelain', '--', 'assets/questions.json'],
    text=True,
    capture_output=True,
    check=True,
).stdout.strip()

if question_status:
    raise SystemExit(
        'assets/questions.json dosyasında yerel değişiklik var.\n'
        'Soru çalışmasını tamamlayıp main dalını güncelledikten sonra '
        'bu özellik paketini çalıştır.'
    )

main = MAIN.read_text(encoding='utf-8')
pubspec = PUBSPEC.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')

version_match = re.search(
    r'^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$',
    pubspec,
    flags=re.MULTILINE,
)
if version_match is None:
    raise SystemExit('pubspec.yaml sürüm satırı okunamadı.')

version = tuple(map(int, version_match.groups()))
if version != (1, 40, 0, 50):
    raise SystemExit(
        'Bu paket 1.40.0+50 sürümü için hazırlandı.\n'
        f'Depodaki sürüm: {version[0]}.{version[1]}.{version[2]}+{version[3]}\n'
        'Önce git pull çalıştır. Sürüm yine farklıysa güncel kurulum '
        'paketi hazırlanması gerekir.'
    )

for marker in [
    "part 'pawn_step_sounds.dart';",
    "part 'premium_pawn_picker.dart';",
    'class JumpingPawn extends StatefulWidget',
    'class LandingBurst extends StatefulWidget',
]:
    if marker not in main:
        raise SystemExit(f'Gerekli kod bulunamadı: {marker}')

if not Path('lib/pawn_step_sounds.dart').exists():
    raise SystemExit('Piyona özel ses paketi bulunamadı.')

if (
    "part 'pawn_visual_effects.dart';" in main
    or 'PawnStepTrailPainter' in main
    or TARGET.exists()
):
    raise SystemExit('Piyon izleri ve varış efektleri zaten kurulmuş görünüyor.')

backup_dir = Path(tempfile.mkdtemp(prefix='bilgi_rotasi_pawn_effects_'))
committed = False

try:
    shutil.copy2(MAIN, backup_dir / 'main.dart')
    shutil.copy2(PUBSPEC, backup_dir / 'pubspec.yaml')
    shutil.copy2(TEST, backup_dir / 'system_smoke_test.dart')

    TARGET.write_text(DART_CONTENT, encoding='utf-8')

    part_anchor = "part 'premium_pawn_picker.dart';"
    main = main.replace(
        part_anchor,
        part_anchor + "\npart 'pawn_visual_effects.dart';",
        1,
    )

    jump_anchor = '''          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                bottom: widget.height * 0.015,
'''
    jump_replacement = '''          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: PawnStepTrailPainter(
                      progress: t,
                      pawnType: widget.type,
                      playerColor: widget.color,
                      pulse: widget.movePulse,
                      minimal: PawnVisualEffects.minimalAnimations,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: widget.height * 0.015,
'''
    if jump_anchor not in main:
        raise RuntimeError('Piyon zıplama katmanı bulunamadı.')
    main = main.replace(jump_anchor, jump_replacement, 1)

    landing_constructor = '''class LandingBurst extends StatefulWidget {
  const LandingBurst({
    required this.color,
    required this.size,
    super.key,
  });

  final Color color;
  final double size;
'''
    landing_constructor_new = '''class LandingBurst extends StatefulWidget {
  const LandingBurst({
    required this.color,
    required this.size,
    required this.pawnType,
    required this.playerColor,
    super.key,
  });

  final Color color;
  final double size;
  final int pawnType;
  final Color playerColor;
'''
    if landing_constructor not in main:
        raise RuntimeError('Varış efekti yapıcısı bulunamadı.')
    main = main.replace(landing_constructor, landing_constructor_new, 1)

    landing_paint = '''        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: LandingBurstPainter(
                progress: _controller.value,
                color: widget.color,
              ),
            );
          },
        ),
'''
    landing_paint_new = '''        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: LandingBurstPainter(
                    progress: _controller.value,
                    color: widget.color,
                  ),
                ),
                CustomPaint(
                  painter: PawnLandingSignaturePainter(
                    progress: _controller.value,
                    pawnType: widget.pawnType,
                    playerColor: widget.playerColor,
                    minimal: PawnVisualEffects.minimalAnimations,
                  ),
                ),
              ],
            );
          },
        ),
'''
    if landing_paint not in main:
        raise RuntimeError('Varış efekti çizim bloğu bulunamadı.')
    main = main.replace(landing_paint, landing_paint_new, 1)

    landing_size_anchor = '''          final landingSize = base * 0.17;

          return Stack(
'''
    landing_size_new = '''          final landingSize = base * 0.17;
          final safeCurrentPlayerIndex = players.isEmpty
              ? 0
              : currentPlayerIndex.clamp(0, players.length - 1).toInt();
          final landingPawnType = players.isEmpty
              ? 0
              : players[safeCurrentPlayerIndex].pawnType;
          final landingPlayerColor = players.isEmpty
              ? const Color(0xFF67E8F9)
              : players[safeCurrentPlayerIndex].color;

          return Stack(
'''
    if landing_size_anchor not in main:
        raise RuntimeError('Tahta varış boyutu bloğu bulunamadı.')
    main = main.replace(landing_size_anchor, landing_size_new, 1)

    landing_call = '''                  child: LandingBurst(
                    key: ValueKey<int>(landingPulse),
                    color: landingColor,
                    size: landingSize,
                  ),
'''
    landing_call_new = '''                  child: LandingBurst(
                    key: ValueKey<int>(landingPulse),
                    color: landingColor,
                    size: landingSize,
                    pawnType: landingPawnType,
                    playerColor: landingPlayerColor,
                  ),
'''
    if landing_call not in main:
        raise RuntimeError('Tahta varış efekti çağrısı bulunamadı.')
    main = main.replace(landing_call, landing_call_new, 1)

    main, version_text_count = re.subn(
        r'Bilgi Rotası • Sürüm 1\.40\.0',
        'Bilgi Rotası • Sürüm 1.41.0',
        main,
        count=1,
    )
    if version_text_count != 1:
        raise RuntimeError('Ana menü sürüm yazısı güncellenemedi.')

    pubspec = re.sub(
        r'^version:\s*.*$',
        'version: 1.41.0+51',
        pubspec,
        count=1,
        flags=re.MULTILINE,
    )

    test_insert = '''
    test('On altı piyonun görsel efekt profili bulunur', () {
      expect(PawnVisualEffects.profiles.length, 16);
      expect(PawnVisualEffects.profiles.length, PawnCatalog.all.length);

      final labels = PawnVisualEffects.profiles
          .map((profile) => profile.label)
          .toSet();
      expect(labels.length, 16);
      expect(PawnVisualEffects.profileFor(12).label, 'Kozmik yıldız tozu');
      expect(PawnVisualEffects.profileFor(13).label, 'Canlı yaprak izleri');
      expect(
        PawnVisualEffects.profileFor(14).label,
        'Altın sihir kıvılcımları',
      );
      expect(
        PawnVisualEffects.profileFor(15).label,
        'Taş tozu ve yüzük ışığı',
      );
      expect(PawnVisualEffects.normalize(-1), 15);
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
            "part 'pawn_visual_effects.dart';",
            'PawnStepTrailPainter(',
            'PawnLandingSignaturePainter(',
            'pawnType: landingPawnType',
            'Bilgi Rotası • Sürüm 1.41.0',
        ],
        TARGET: [
            'class PawnVisualEffects',
            'class PawnStepTrailPainter',
            'class PawnLandingSignaturePainter',
            'Kozmik yıldız tozu',
            'Taş tozu ve yüzük ışığı',
        ],
        PUBSPEC: ['version: 1.41.0+51'],
        TEST: ['On altı piyonun görsel efekt profili bulunur'],
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
            'lib/pawn_visual_effects.dart',
            'test/system_smoke_test.dart',
        ])

    run(['git', 'diff', '--check'])

    changed_paths = subprocess.check_output(
        ['git', 'diff', '--name-only'],
        text=True,
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
        print(
            'ℹ️ Flutter bu ortamda bulunamadı; analiz ve test '
            "GitHub Actions'ta çalışacak."
        )

    files_to_stage = [
        'lib/main.dart',
        'lib/pawn_visual_effects.dart',
        'test/system_smoke_test.dart',
        'pubspec.yaml',
    ]
    if Path('pubspec.lock').exists():
        files_to_stage.append('pubspec.lock')

    run(['git', 'add', *files_to_stage])

    changed = subprocess.run(
        ['git', 'diff', '--cached', '--quiet'],
        check=False,
    ).returncode != 0
    if not changed:
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
            'lib/pawn_visual_effects.dart',
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
        print('Dosyalar önceki hâline otomatik döndürüldü.')
    raise SystemExit(1)
finally:
    shutil.rmtree(backup_dir, ignore_errors=True)

print('')
print('✅ On altı piyonun her birine özgün hareket izi eklendi.')
print('✅ Her piyon için özel varış imzası hazırlandı.')
print('✅ Düşük animasyon ayarında parçacık sayısı azaltılıyor.')
print('✅ Son dört piyon özel yıldız, yaprak, sihir ve yüzük efektleri aldı.')
print('✅ questions.json dosyasına dokunulmadı.')
print('✅ Yeni sürüm: 1.41.0+51')
print('✅ Değişiklikler GitHub main dalına gönderildi.')
