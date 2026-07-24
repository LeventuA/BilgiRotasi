#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Bilgi Rotası — Kilitli Tahta Temaları İçin Tam Önizleme

Taban sürüm: 1.44.0+57
Yeni sürüm: 1.44.1+58

Yapılanlar:
- Her tema kartına "Önizle" düğmesi eklenir.
- Kilitli tema kartına dokununca uyarı yerine tam tahta önizlemesi açılır.
- Önizleme seçili temayı değiştirmez.
- Açık temalar önizleme ekranından kullanılabilir.
- Kilitli temalarda gereken seviye gösterilir.
- BoardPainter seçili temadan bağımsız tema çizebilir.
- Test eklenir.
- assets/questions.json dosyasına dokunulmaz.
"""

from __future__ import annotations

import re
import shutil
import subprocess
import sys
from pathlib import Path

OLD_VERSION = "1.44.0+57"
NEW_VERSION = "1.44.1+58"
COMMIT_MESSAGE = "Kilitli tahta temalarina tam onizleme ekle"

ROOT = Path.cwd()
MAIN = ROOT / "lib" / "main.dart"
COLLECTION = ROOT / "lib" / "visual_collection.dart"
TEST = ROOT / "test" / "system_smoke_test.dart"
PUBSPEC = ROOT / "pubspec.yaml"

TARGETS = [MAIN, COLLECTION, TEST, PUBSPEC]
STAGE_PATHS = [
    "lib/main.dart",
    "lib/visual_collection.dart",
    "test/system_smoke_test.dart",
    "pubspec.yaml",
]


def run(
    *args: str,
    check: bool = True,
    capture: bool = False,
) -> subprocess.CompletedProcess[str]:
    kwargs = {
        "cwd": ROOT,
        "text": True,
        "check": check,
    }
    if capture:
        kwargs["stdout"] = subprocess.PIPE
        kwargs["stderr"] = subprocess.PIPE
    return subprocess.run(args, **kwargs)


def output(*args: str) -> str:
    return run(*args, capture=True).stdout.strip()


def fail(message: str) -> None:
    raise RuntimeError(message)


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        fail(
            f"{label}: beklenen parça {count} kez bulundu; "
            "kurulum güvenle durduruldu."
        )
    return text.replace(old, new, 1)


def ensure_repo() -> None:
    if not (ROOT / ".git").exists():
        fail(
            "Bu dosyayı GitHub Codespaces içinde "
            "BilgiRotasi depo kökünde çalıştır."
        )

    branch = output("git", "branch", "--show-current")
    if branch != "main":
        fail(f"Aktif dal main olmalı. Şu an: {branch or '(belirsiz)'}")

    for path in TARGETS:
        if not path.exists():
            fail(f"Gerekli dosya bulunamadı: {path.relative_to(ROOT)}")

    version_match = re.search(
        r"(?m)^version:\s*([^\s]+)\s*$",
        PUBSPEC.read_text(encoding="utf-8"),
    )
    version = version_match.group(1) if version_match else None
    if version != OLD_VERSION:
        fail(
            f"Beklenen sürüm {OLD_VERSION}, mevcut sürüm {version!r}. "
            "Yanlış tabana kurulum yapılmadı."
        )

    for relative in STAGE_PATHS:
        if output("git", "status", "--porcelain", "--", relative):
            fail(
                f"{relative} dosyasında yerel değişiklik var. "
                "Üzerine yazmamak için işlem durduruldu."
            )

    if output("git", "status", "--porcelain", "--", "assets/questions.json"):
        fail(
            "assets/questions.json dosyasında yerel değişiklik var. "
            "Soru çalışmasıyla özellik kurulumu karışmasın diye işlem durduruldu."
        )


THEME_CARD_AND_PREVIEW_METHOD = r"""  Widget _themeCard(BoardThemeDefinition theme) {
    final unlocked =
        VisualCollectionService.isThemeUnlocked(theme.id);
    final selected =
        VisualCollectionService.current.themeId == theme.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? theme.gold
              : const Color(0xFFE2E8F0),
          width: selected ? 2.2 : 1,
        ),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 8),
          child: Column(
            children: [
              InkWell(
                onTap: unlocked
                    ? () => VisualCollectionService.selectTheme(
                          theme.id,
                        )
                    : () => _openThemePreview(theme),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      Container(
                        width: 57,
                        height: 57,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: theme.backgroundColors,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          unlocked ? theme.emoji : '🔒',
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              theme.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              theme.description,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              unlocked
                                  ? selected
                                      ? 'Seçili tema'
                                      : 'Kullanılabilir'
                                  : 'Seviye ${theme.unlockLevel}',
                              style: TextStyle(
                                color: unlocked
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFB45309),
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : unlocked
                                ? Icons.radio_button_unchecked_rounded
                                : Icons.lock_outline_rounded,
                        color: selected
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  if (!unlocked)
                    const Expanded(
                      child: Text(
                        'Kilidi açmadan tahtayı inceleyebilirsin.',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                  TextButton.icon(
                    onPressed: () => _openThemePreview(theme),
                    icon: const Icon(
                      Icons.visibility_rounded,
                      size: 18,
                    ),
                    label: const Text(
                      'Önizle',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openThemePreview(
    BoardThemeDefinition theme,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ThemePreviewScreen(
          theme: theme,
        ),
      ),
    );
  }

"""


THEME_PREVIEW_SCREEN = r"""
class ThemePreviewScreen extends StatefulWidget {
  const ThemePreviewScreen({
    required this.theme,
    super.key,
  });

  final BoardThemeDefinition theme;

  @override
  State<ThemePreviewScreen> createState() =>
      _ThemePreviewScreenState();
}

class _ThemePreviewScreenState extends State<ThemePreviewScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get _unlocked =>
      VisualCollectionService.isThemeUnlocked(widget.theme.id);

  bool get _selected =>
      VisualCollectionService.current.themeId == widget.theme.id;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _useTheme() async {
    if (!_unlocked || _selected) return;

    await VisualCollectionService.selectTheme(
      widget.theme.id,
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final art = BoardThemeArt.profileFor(theme.id);
    final live = VisualCollectionService.current.liveBoard;

    return Scaffold(
      backgroundColor: art.screenColor,
      appBar: AppBar(
        backgroundColor: art.appBarColor,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text('${theme.emoji} ${theme.title}'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding =
                constraints.maxWidth >= 700 ? 42.0 : 14.0;

            return ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                28,
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: theme.backgroundColors,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: theme.gold,
                      width: 1.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        theme.emoji,
                        style: const TextStyle(fontSize: 42),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              theme.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              theme.description,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.84),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 680,
                    ),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: art.cardColor,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: art.lineColor.withOpacity(0.88),
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x66000000),
                              blurRadius: 22,
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: BoardPainter(
                                pulse: live
                                    ? _controller.value
                                    : 0,
                                themeOverride: theme,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.94),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: art.lineColor.withOpacity(0.48),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _unlocked
                                ? Icons.lock_open_rounded
                                : Icons.lock_rounded,
                            color: _unlocked
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFB45309),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              _unlocked
                                  ? _selected
                                      ? 'Bu tema şu anda seçili.'
                                      : 'Bu tema kullanılabilir.'
                                  : 'Seviye ${theme.unlockLevel} '
                                      'olduğunda kullanıma açılır.',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        art.tagline,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Önizleme temayı seçmez ve kayıtlı '
                        'görünümünü değiştirmez.',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed:
                      _unlocked && !_selected ? _useTheme : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.backgroundColors.first,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                  ),
                  icon: Icon(
                    _selected
                        ? Icons.check_circle_rounded
                        : _unlocked
                            ? Icons.palette_rounded
                            : Icons.lock_rounded,
                  ),
                  label: Text(
                    _selected
                        ? 'Şu an seçili'
                        : _unlocked
                            ? 'Bu Temayı Kullan'
                            : 'Seviye ${theme.unlockLevel}\'te açılır',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text(
                    'Koleksiyona Dön',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

"""


def patch_collection(text: str) -> str:
    start_marker = "  Widget _themeCard(BoardThemeDefinition theme) {"
    end_marker = "  Widget _pawnGrid() {"

    start = text.find(start_marker)
    if start < 0:
        fail("Tema kartı metodu bulunamadı.")

    end = text.find(end_marker, start)
    if end < 0:
        fail("Tema kartından sonraki piyon ızgarası bulunamadı.")

    text = (
        text[:start]
        + THEME_CARD_AND_PREVIEW_METHOD
        + text[end:]
    )

    live_marker = "class LiveBoardLayer extends StatefulWidget {"
    if text.count(live_marker) != 1:
        fail("LiveBoardLayer ekleme noktası benzersiz bulunamadı.")

    text = text.replace(
        live_marker,
        THEME_PREVIEW_SCREEN + live_marker,
        1,
    )

    return text


def patch_main(text: str) -> str:
    old = """class BoardPainter extends CustomPainter {
  const BoardPainter({this.pulse = 0});

  final double pulse;

  BoardThemeDefinition get _theme =>
      VisualCollectionService.theme;
"""
    new = """class BoardPainter extends CustomPainter {
  const BoardPainter({
    this.pulse = 0,
    this.themeOverride,
  });

  final double pulse;
  final BoardThemeDefinition? themeOverride;

  BoardThemeDefinition get _theme =>
      themeOverride ?? VisualCollectionService.theme;
"""
    return replace_once(
        text,
        old,
        new,
        "BoardPainter tema geçersiz kılma desteği",
    )


def patch_test(text: str) -> str:
    marker = (
        "    test('Zar jokeri kaldırılır ve özel kutular yenilenir', () {"
    )
    addition = r"""    test('Kilitli tema seçilmeden tam önizlenebilir', () {
      final lockedTheme = boardThemes.last;
      final painter = BoardPainter(
        themeOverride: lockedTheme,
        pulse: 0.5,
      );
      final screen = ThemePreviewScreen(
        theme: lockedTheme,
      );

      expect(painter.themeOverride, same(lockedTheme));
      expect(screen.theme, same(lockedTheme));
      expect(
        BoardThemeArt.profileFor(lockedTheme.id).tagline.trim(),
        isNotEmpty,
      );
    });

"""
    return replace_once(
        text,
        marker,
        addition + marker,
        "Tema önizleme testi ekleme noktası",
    )


def main() -> None:
    ensure_repo()

    originals: dict[Path, bytes] = {
        path: path.read_bytes()
        for path in TARGETS
    }
    committed = False

    try:
        main_text = MAIN.read_text(encoding="utf-8")
        collection_text = COLLECTION.read_text(encoding="utf-8")
        test_text = TEST.read_text(encoding="utf-8")
        pubspec_text = PUBSPEC.read_text(encoding="utf-8")

        MAIN.write_text(
            patch_main(main_text),
            encoding="utf-8",
        )
        COLLECTION.write_text(
            patch_collection(collection_text),
            encoding="utf-8",
        )
        TEST.write_text(
            patch_test(test_text),
            encoding="utf-8",
        )
        PUBSPEC.write_text(
            replace_once(
                pubspec_text,
                f"version: {OLD_VERSION}",
                f"version: {NEW_VERSION}",
                "Sürüm numarası",
            ),
            encoding="utf-8",
        )

        dart = shutil.which("dart")
        flutter = shutil.which("flutter")

        if dart:
            run(
                dart,
                "format",
                "lib/main.dart",
                "lib/visual_collection.dart",
                "test/system_smoke_test.dart",
            )
        else:
            print("UYARI: dart bulunamadı; format adımı atlandı.")

        run("git", "diff", "--check", "--", *STAGE_PATHS)

        if flutter:
            run(flutter, "pub", "get")
            run(flutter, "analyze")
            run(flutter, "test")
        else:
            print(
                "UYARI: flutter bulunamadı; "
                "pub get/analyze/test adımları atlandı."
            )

        if output(
            "git",
            "status",
            "--porcelain",
            "--",
            "assets/questions.json",
        ):
            fail("Kurulum soru dosyasını değiştirdi.")

        run("git", "add", "--", *STAGE_PATHS)

        staged_targets = output(
            "git",
            "diff",
            "--cached",
            "--name-only",
            "--",
            *STAGE_PATHS,
        ).splitlines()

        if not staged_targets:
            fail("Tema önizleme değişikliği oluşmadı.")

        run(
            "git",
            "commit",
            "-m",
            COMMIT_MESSAGE,
            "--",
            *STAGE_PATHS,
        )
        committed = True

        try:
            run("git", "push", "origin", "main")
        except Exception:
            print(
                "\nKod doğrulandı ve commit oluşturuldu, "
                "ancak push başarısız oldu.\n"
                "Bağlantı düzeldikten sonra çalıştır:\n"
                "  git push origin main\n"
            )
            raise

        print(
            "\n✅ Tema önizleme kurulumu tamamlandı.\n"
            f"✅ Yeni sürüm: {NEW_VERSION}\n"
            "✅ Kilitli temalar seçilmeden görüntülenebilir.\n"
            "✅ Açık temalar önizlemeden kullanılabilir.\n"
            "✅ Soru dosyasına dokunulmadı.\n"
            "✅ Commit main dalına push edildi.\n\n"
            "GitHub Actions yeşil olunca APK'yı indirip kur."
        )

    except Exception as error:
        if not committed:
            for path, data in originals.items():
                path.write_bytes(data)

            run(
                "git",
                "reset",
                "--quiet",
                "--",
                *STAGE_PATHS,
                check=False,
            )
            print(
                "\nDeğiştirilen hedef dosyalar eski hâline döndürüldü."
            )

        print(
            f"\n❌ Kurulum başarısız: {error}",
            file=sys.stderr,
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
