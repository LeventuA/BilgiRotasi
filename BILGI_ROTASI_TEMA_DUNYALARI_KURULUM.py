#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Bilgi Rotası — Gerçek Tahta Temaları + Ses Atmosferini Kaldırma

Beklenen taban:
  main @ 7d55704a9f58e0964e486f626d9a77172a021ead
  version: 1.43.1+56

Yapılanlar:
- Klasik/Sakin/Enerjik "ses atmosferi" sistemi tamamen kaldırılır.
- Sesler yeniden normal hız ve gerçek kullanıcı ses ayarıyla çalınır.
- Altı tahta temasına birbirinden farklı, kodla çizilen görsel dünya eklenir:
  Klasik, Antik Mısır, Uzay İstasyonu, Bilgelik Ormanı,
  Derin Okyanus, Gelecek Şehri.
- Oyun ekranının arka planı, üst çubuğu ve tahta kartı seçili temaya bağlanır.
- Merkez simgesi temaya göre değişir.
- Testler güncellenir.
- Sürüm 1.44.0+57 yapılır.
- assets/questions.json dosyasına dokunulmaz.
"""

from __future__ import annotations

import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

EXPECTED_HEAD = "7d55704a9f58e0964e486f626d9a77172a021ead"
OLD_VERSION = "1.43.1+56"
NEW_VERSION = "1.44.0+57"
COMMIT_MESSAGE = "Tahta temalarini gercek dunyalara donustur"

ROOT = Path.cwd()
MAIN = ROOT / "lib" / "main.dart"
COLLECTION = ROOT / "lib" / "visual_collection.dart"
THEME_ART = ROOT / "lib" / "board_theme_art.dart"
TEST = ROOT / "test" / "system_smoke_test.dart"
PUBSPEC = ROOT / "pubspec.yaml"
QUESTIONS = ROOT / "assets" / "questions.json"

TARGETS = [MAIN, COLLECTION, TEST, PUBSPEC]
STAGE_PATHS = [
    "lib/main.dart",
    "lib/visual_collection.dart",
    "lib/board_theme_art.dart",
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
        fail(f"{label}: beklenen parça {count} kez bulundu; işlem güvenle durduruldu.")
    return text.replace(old, new, 1)


def remove_between(
    text: str,
    start_marker: str,
    end_marker: str,
    label: str,
    keep_end: bool = True,
) -> str:
    start = text.find(start_marker)
    if start < 0:
        fail(f"{label}: başlangıç işareti bulunamadı.")
    end = text.find(end_marker, start + len(start_marker))
    if end < 0:
        fail(f"{label}: bitiş işareti bulunamadı.")
    return text[:start] + (text[end:] if keep_end else text[end + len(end_marker):])


def regex_once(text: str, pattern: str, replacement: str, label: str) -> str:
    result, count = re.subn(pattern, replacement, text, count=1, flags=re.S)
    if count != 1:
        fail(f"{label}: beklenen düzen {count} kez eşleşti; işlem güvenle durduruldu.")
    return result


def ensure_repo() -> None:
    if not (ROOT / ".git").exists():
        fail("Bu dosyayı GitHub Codespaces içinde BilgiRotasi depo kökünde çalıştır.")
    for path in TARGETS:
        if not path.exists():
            fail(f"Gerekli dosya bulunamadı: {path.relative_to(ROOT)}")

    branch = output("git", "branch", "--show-current")
    if branch != "main":
        fail(f"Aktif dal main olmalı. Şu an: {branch or '(belirsiz)'}")

    head = output("git", "rev-parse", "HEAD")
    if head != EXPECTED_HEAD:
        fail(
            "Depo beklenen commit'te değil.\n"
            f"Beklenen: {EXPECTED_HEAD}\n"
            f"Mevcut:   {head}\n"
            "Önce git switch main && git pull çalıştır. Commit yine farklıysa "
            "güncel koda göre yeni kurulum hazırlanmalı."
        )

    version_match = re.search(
        r"(?m)^version:\s*([^\s]+)\s*$",
        PUBSPEC.read_text(encoding="utf-8"),
    )
    current_version = version_match.group(1) if version_match else None
    if current_version != OLD_VERSION:
        fail(
            f"Beklenen sürüm {OLD_VERSION}, mevcut sürüm {current_version!r}. "
            "Yanlış tabana kurulum yapılmadı."
        )

    if output("git", "status", "--porcelain", "--", "assets/questions.json"):
        fail(
            "assets/questions.json dosyasında yerel değişiklik var. "
            "Soru çalışmasıyla özellik kurulumu karışmasın diye işlem durduruldu."
        )

    for relative in [
        "lib/main.dart",
        "lib/visual_collection.dart",
        "lib/board_theme_art.dart",
        "test/system_smoke_test.dart",
        "pubspec.yaml",
    ]:
        if output("git", "status", "--porcelain", "--", relative):
            fail(
                f"{relative} dosyasında yerel değişiklik var. "
                "Üzerine yazmamak için işlem durduruldu."
            )


BOARD_THEME_ART = r"""part of 'main.dart';

class BoardThemeArtProfile {
  const BoardThemeArtProfile({
    required this.id,
    required this.centerEmoji,
    required this.tagline,
    required this.appBarColor,
    required this.screenColor,
    required this.cardColor,
    required this.lineColor,
  });

  final String id;
  final String centerEmoji;
  final String tagline;
  final Color appBarColor;
  final Color screenColor;
  final Color cardColor;
  final Color lineColor;
}

class BoardThemeArt {
  BoardThemeArt._();

  static const List<BoardThemeArtProfile> profiles =
      <BoardThemeArtProfile>[
    BoardThemeArtProfile(
      id: 'classic',
      centerEmoji: '🧭',
      tagline: 'Pusula çizgileri ve eski keşif haritası',
      appBarColor: Color(0xFF382047),
      screenColor: Color(0xFFF4F1F7),
      cardColor: Color(0xFFF8F5FA),
      lineColor: Color(0xFFE8C76A),
    ),
    BoardThemeArtProfile(
      id: 'egypt',
      centerEmoji: '☥',
      tagline: 'Hiyeroglif, ankh, piramit ve firavun altını',
      appBarColor: Color(0xFF18344D),
      screenColor: Color(0xFFF0D6A7),
      cardColor: Color(0xFFE6C68B),
      lineColor: Color(0xFFFFD166),
    ),
    BoardThemeArtProfile(
      id: 'space',
      centerEmoji: '🪐',
      tagline: 'Yıldız alanı, yörünge ve istasyon devreleri',
      appBarColor: Color(0xFF07142E),
      screenColor: Color(0xFF040914),
      cardColor: Color(0xFF07152A),
      lineColor: Color(0xFF72D9FF),
    ),
    BoardThemeArtProfile(
      id: 'forest',
      centerEmoji: '🌿',
      tagline: 'Ağaç halkaları, sarmaşık, yaprak ve ateş böceği',
      appBarColor: Color(0xFF173725),
      screenColor: Color(0xFF0D2116),
      cardColor: Color(0xFF183523),
      lineColor: Color(0xFFD9B66F),
    ),
    BoardThemeArtProfile(
      id: 'ocean',
      centerEmoji: '🐚',
      tagline: 'Kabarcık, mercan, dalga ve su ışığı',
      appBarColor: Color(0xFF06374F),
      screenColor: Color(0xFF03283E),
      cardColor: Color(0xFF063B52),
      lineColor: Color(0xFFFFC857),
    ),
    BoardThemeArtProfile(
      id: 'future',
      centerEmoji: '◆',
      tagline: 'Neon şehir, devre ağı ve holografik ızgara',
      appBarColor: Color(0xFF101438),
      screenColor: Color(0xFF060A24),
      cardColor: Color(0xFF0B1232),
      lineColor: Color(0xFF6FFFE9),
    ),
  ];

  static int get profileCount => profiles.length;

  static BoardThemeArtProfile profileFor(String id) {
    return profiles.firstWhere(
      (profile) => profile.id == id,
      orElse: () => profiles.first,
    );
  }

  static String centerEmoji(String id) => profileFor(id).centerEmoji;

  static Color appBarColor(String id) => profileFor(id).appBarColor;

  static Color screenBackground(String id) => profileFor(id).screenColor;

  static Color boardCardColor(String id) => profileFor(id).cardColor;

  static Color borderColor(String id) => profileFor(id).lineColor;

  static void paintSurface(
    Canvas canvas,
    Size size,
    Rect boardRect,
    double base,
    BoardThemeDefinition theme,
    double pulse,
  ) {
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        boardRect,
        Radius.circular(base * 0.042),
      ),
    );

    switch (theme.id) {
      case 'egypt':
        _paintEgypt(canvas, boardRect, base, pulse);
        break;
      case 'space':
        _paintSpace(canvas, boardRect, base, pulse);
        break;
      case 'forest':
        _paintForest(canvas, boardRect, base, pulse);
        break;
      case 'ocean':
        _paintOcean(canvas, boardRect, base, pulse);
        break;
      case 'future':
        _paintFuture(canvas, boardRect, base, pulse);
        break;
      case 'classic':
      default:
        _paintClassic(canvas, boardRect, base, pulse);
        break;
    }

    canvas.restore();
  }

  static void _paintClassic(
    Canvas canvas,
    Rect rect,
    double base,
    double pulse,
  ) {
    final center = rect.center;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(0.7, base * 0.0015)
      ..color = const Color(0x44F8E6A5);

    for (var index = 0; index < 12; index++) {
      final angle = index * pi / 6;
      canvas.drawLine(
        center + Offset(cos(angle), sin(angle)) * base * 0.15,
        center + Offset(cos(angle), sin(angle)) * base * 0.46,
        line,
      );
    }

    for (final radius in <double>[0.18, 0.29, 0.39]) {
      canvas.drawCircle(center, base * radius, line);
    }

    final mapPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(0.7, base * 0.0013)
      ..color = const Color(0x332EE6D6);

    for (var index = 0; index < 7; index++) {
      final y = rect.top + base * (0.13 + index * 0.105);
      final path = Path()
        ..moveTo(rect.left + base * 0.07, y)
        ..cubicTo(
          rect.left + base * 0.23,
          y - base * 0.045,
          rect.right - base * 0.25,
          y + base * 0.045,
          rect.right - base * 0.07,
          y,
        );
      canvas.drawPath(path, mapPaint);
    }

    _paintSparkles(
      canvas,
      rect,
      base,
      const Color(0x99FFE082),
      18,
      pulse,
    );
  }

  static void _paintEgypt(
    Canvas canvas,
    Rect rect,
    double base,
    double pulse,
  ) {
    canvas.drawRect(
      rect,
      Paint()..color = const Color(0x18FFD166),
    );

    final engraving = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(0.8, base * 0.0017)
      ..color = const Color(0x558A5415);

    for (var row = 0; row < 4; row++) {
      final y = rect.top + base * (0.11 + row * 0.22);
      for (var column = 0; column < 11; column++) {
        final x = rect.left + base * (0.065 + column * 0.083);
        final size = base * 0.018;
        switch ((row + column) % 4) {
          case 0:
            canvas.drawCircle(Offset(x, y), size * 0.42, engraving);
            canvas.drawLine(
              Offset(x, y + size * 0.4),
              Offset(x, y + size * 1.25),
              engraving,
            );
            canvas.drawLine(
              Offset(x - size * 0.52, y + size * 0.72),
              Offset(x + size * 0.52, y + size * 0.72),
              engraving,
            );
            break;
          case 1:
            final pyramid = Path()
              ..moveTo(x - size, y + size * 0.8)
              ..lineTo(x, y - size * 0.75)
              ..lineTo(x + size, y + size * 0.8)
              ..close();
            canvas.drawPath(pyramid, engraving);
            break;
          case 2:
            canvas.drawOval(
              Rect.fromCenter(
                center: Offset(x, y),
                width: size * 1.8,
                height: size,
              ),
              engraving,
            );
            canvas.drawCircle(
              Offset(x, y),
              size * 0.22,
              engraving,
            );
            break;
          default:
            canvas.drawRect(
              Rect.fromCenter(
                center: Offset(x, y),
                width: size * 1.15,
                height: size * 1.15,
              ),
              engraving,
            );
            canvas.drawLine(
              Offset(x - size * 0.55, y),
              Offset(x + size * 0.55, y),
              engraving,
            );
        }
      }
    }

    final pyramidPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(1.0, base * 0.0023)
      ..color = const Color(0x66FFD166);

    for (final anchor in <Offset>[
      Offset(rect.left + base * 0.13, rect.bottom - base * 0.11),
      Offset(rect.right - base * 0.13, rect.bottom - base * 0.11),
    ]) {
      final path = Path()
        ..moveTo(anchor.dx - base * 0.09, anchor.dy)
        ..lineTo(anchor.dx, anchor.dy - base * 0.14)
        ..lineTo(anchor.dx + base * 0.09, anchor.dy)
        ..close();
      canvas.drawPath(path, pyramidPaint);
      canvas.drawLine(
        Offset(anchor.dx, anchor.dy - base * 0.14),
        Offset(anchor.dx, anchor.dy),
        pyramidPaint,
      );
    }

    _drawSymbol(
      canvas,
      '☥',
      Offset(rect.left + base * 0.10, rect.top + base * 0.10),
      base * 0.055,
      const Color(0x55FFD166),
    );
    _drawSymbol(
      canvas,
      '☥',
      Offset(rect.right - base * 0.10, rect.top + base * 0.10),
      base * 0.055,
      const Color(0x55FFD166),
    );
  }

  static void _paintSpace(
    Canvas canvas,
    Rect rect,
    double base,
    double pulse,
  ) {
    for (var index = 0; index < 72; index++) {
      final x = rect.left +
          ((index * 47 + index * index * 13) % 997) / 997 * rect.width;
      final y = rect.top +
          ((index * 83 + index * index * 7) % 991) / 991 * rect.height;
      final radius = base * (index % 7 == 0 ? 0.0030 : 0.0015);
      final alpha = index % 5 == 0 ? 0.82 : 0.48;
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..color = Color.lerp(
            const Color(0xFFFFFFFF),
            const Color(0xFF8BE9FD),
            index.isEven ? 0.2 : 0.8,
          )!
              .withOpacity(alpha),
      );
    }

    final orbit = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(0.8, base * 0.0017)
      ..color = const Color(0x556D28D9);

    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);
    canvas.rotate(-0.35);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: base * 0.78,
        height: base * 0.31,
      ),
      orbit,
    );
    canvas.rotate(0.78);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: base * 0.72,
        height: base * 0.25,
      ),
      orbit..color = const Color(0x555DEBFF),
    );
    canvas.restore();

    final circuit = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(0.8, base * 0.0017)
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x6644D8FF);

    for (var index = 0; index < 5; index++) {
      final inset = base * (0.055 + index * 0.025);
      final path = Path()
        ..moveTo(rect.left + inset, rect.top + base * 0.08)
        ..lineTo(rect.left + inset, rect.top + base * 0.18)
        ..lineTo(rect.left + base * (0.18 + index * 0.02), rect.top + base * 0.18);
      canvas.drawPath(path, circuit);
      canvas.drawCircle(
        Offset(rect.left + base * (0.18 + index * 0.02), rect.top + base * 0.18),
        base * 0.004,
        Paint()..color = const Color(0xAA7DE3FF),
      );
    }
  }

  static void _paintForest(
    Canvas canvas,
    Rect rect,
    double base,
    double pulse,
  ) {
    final center = rect.center;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(0.8, base * 0.0018)
      ..color = const Color(0x443F7D58);

    for (var index = 0; index < 9; index++) {
      canvas.drawCircle(
        center.translate(
          sin(index * 0.9) * base * 0.008,
          cos(index * 1.2) * base * 0.008,
        ),
        base * (0.12 + index * 0.041),
        ring,
      );
    }

    final vine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(1.1, base * 0.0032)
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x8856A66F);

    final topVine = Path()
      ..moveTo(rect.left + base * 0.04, rect.top + base * 0.08)
      ..cubicTo(
        rect.left + base * 0.24,
        rect.top + base * 0.01,
        rect.right - base * 0.24,
        rect.top + base * 0.15,
        rect.right - base * 0.04,
        rect.top + base * 0.07,
      );
    canvas.drawPath(topVine, vine);

    final bottomVine = Path()
      ..moveTo(rect.left + base * 0.05, rect.bottom - base * 0.08)
      ..cubicTo(
        rect.left + base * 0.28,
        rect.bottom - base * 0.16,
        rect.right - base * 0.23,
        rect.bottom - base * 0.01,
        rect.right - base * 0.05,
        rect.bottom - base * 0.09,
      );
    canvas.drawPath(bottomVine, vine);

    for (var index = 0; index < 18; index++) {
      final angle = index * 2 * pi / 18;
      final point = center +
          Offset(cos(angle), sin(angle)) * base * (0.38 + (index % 3) * 0.018);
      canvas.save();
      canvas.translate(point.dx, point.dy);
      canvas.rotate(angle + pi / 2);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: base * 0.027,
          height: base * 0.012,
        ),
        Paint()..color = const Color(0x775EC47B),
      );
      canvas.restore();
    }

    _paintSparkles(
      canvas,
      rect,
      base,
      const Color(0xAAFFE082),
      14,
      pulse,
    );
  }

  static void _paintOcean(
    Canvas canvas,
    Rect rect,
    double base,
    double pulse,
  ) {
    for (var index = 0; index < 42; index++) {
      final x = rect.left +
          ((index * 67 + index * index * 3) % 983) / 983 * rect.width;
      final y = rect.top +
          ((index * 41 + index * index * 11) % 977) / 977 * rect.height;
      final radius = base * (0.003 + (index % 5) * 0.0018);
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = max(0.7, base * 0.0012)
          ..color = const Color(0x668BE9FD),
      );
      if (index % 4 == 0) {
        canvas.drawCircle(
          Offset(x - radius * 0.35, y - radius * 0.35),
          radius * 0.18,
          Paint()..color = const Color(0x99FFFFFF),
        );
      }
    }

    final wave = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(0.8, base * 0.0015)
      ..color = const Color(0x447DE3FF);

    for (var row = 0; row < 8; row++) {
      final y = rect.top + base * (0.08 + row * 0.115);
      final path = Path()..moveTo(rect.left, y);
      for (var segment = 0; segment < 8; segment++) {
        final x1 = rect.left + rect.width * (segment + 0.5) / 8;
        final x2 = rect.left + rect.width * (segment + 1) / 8;
        path.quadraticBezierTo(
          x1,
          y + (segment.isEven ? -1 : 1) * base * 0.018,
          x2,
          y,
        );
      }
      canvas.drawPath(path, wave);
    }

    _paintCoral(
      canvas,
      Offset(rect.left + base * 0.08, rect.bottom - base * 0.04),
      base,
      false,
    );
    _paintCoral(
      canvas,
      Offset(rect.right - base * 0.08, rect.bottom - base * 0.04),
      base,
      true,
    );
  }

  static void _paintFuture(
    Canvas canvas,
    Rect rect,
    double base,
    double pulse,
  ) {
    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(0.8, base * 0.0013)
      ..color = const Color(0x445DEBFF);

    final horizon = rect.top + rect.height * 0.56;
    for (var index = -8; index <= 8; index++) {
      canvas.drawLine(
        Offset(rect.center.dx + index * base * 0.025, horizon),
        Offset(rect.center.dx + index * base * 0.09, rect.bottom),
        grid,
      );
    }
    for (var row = 0; row < 9; row++) {
      final t = row / 9;
      final y = horizon +
          pow(t, 1.65).toDouble() * (rect.bottom - horizon);
      canvas.drawLine(
        Offset(rect.left, y),
        Offset(rect.right, y),
        grid,
      );
    }

    final skyline = Paint()..color = const Color(0x553A0D6E);
    for (var index = 0; index < 22; index++) {
      final width = base * (0.018 + (index % 4) * 0.006);
      final height = base * (0.05 + (index * 17 % 9) * 0.012);
      final x = rect.left + index * rect.width / 22;
      canvas.drawRect(
        Rect.fromLTWH(
          x,
          horizon - height,
          width,
          height,
        ),
        skyline,
      );
      if (index % 3 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(
            x + width * 0.35,
            horizon - height - base * 0.018,
            width * 0.3,
            base * 0.018,
          ),
          skyline,
        );
      }
    }

    final circuit = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(0.9, base * 0.0018)
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x665FFFE9);

    for (var index = 0; index < 8; index++) {
      final y = rect.top + base * (0.07 + index * 0.055);
      final path = Path()
        ..moveTo(rect.left + base * 0.04, y)
        ..lineTo(rect.left + base * (0.13 + index * 0.015), y)
        ..lineTo(
          rect.left + base * (0.16 + index * 0.015),
          y + base * 0.025,
        )
        ..lineTo(rect.left + base * 0.26, y + base * 0.025);
      canvas.drawPath(path, circuit);
      canvas.drawCircle(
        Offset(rect.left + base * 0.26, y + base * 0.025),
        base * 0.004,
        Paint()..color = const Color(0xAAFF2E88),
      );
    }

    _paintSparkles(
      canvas,
      rect,
      base,
      const Color(0xAAFF2E88),
      16,
      pulse,
    );
  }

  static void _paintSparkles(
    Canvas canvas,
    Rect rect,
    double base,
    Color color,
    int count,
    double pulse,
  ) {
    for (var index = 0; index < count; index++) {
      final x = rect.left +
          ((index * 73 + index * index * 5) % 971) / 971 * rect.width;
      final y = rect.top +
          ((index * 37 + index * index * 17) % 967) / 967 * rect.height;
      final radius =
          base * (0.0018 + (index % 3) * 0.0012) * (0.85 + pulse * 0.25);
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = color,
      );
    }
  }

  static void _paintCoral(
    Canvas canvas,
    Offset origin,
    double base,
    bool mirror,
  ) {
    final coral = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(1.0, base * 0.0034)
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x886DD5D5);

    final direction = mirror ? -1.0 : 1.0;
    for (var branch = 0; branch < 5; branch++) {
      final start = origin + Offset(direction * branch * base * 0.006, 0);
      final end = start +
          Offset(
            direction * base * (0.025 + branch * 0.009),
            -base * (0.055 + branch * 0.012),
          );
      canvas.drawLine(start, end, coral);
      canvas.drawLine(
        end,
        end + Offset(direction * base * 0.022, -base * 0.022),
        coral,
      );
      canvas.drawLine(
        end,
        end + Offset(-direction * base * 0.016, -base * 0.026),
        coral,
      );
    }
  }

  static void _drawSymbol(
    Canvas canvas,
    String symbol,
    Offset center,
    double fontSize,
    Color color,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: symbol,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(
      canvas,
      Offset(
        center.dx - painter.width / 2,
        center.dy - painter.height / 2,
      ),
    );
  }
}
"""


def patch_collection(text: str) -> str:
    text = remove_between(
        text,
        "class SoundAtmosphere {",
        "class VisualCollectionSettings {",
        "Ses atmosferi model ve listesi",
    )

    for old, label in [
        ("    this.soundId = 'classic',\n", "Ayar kurucusundaki soundId"),
        ("  final String soundId;\n", "Ayar alanındaki soundId"),
        ("    String? soundId,\n", "copyWith soundId parametresi"),
        ("      soundId: soundId ?? this.soundId,\n", "copyWith soundId ataması"),
        ("        'soundId': soundId,\n", "JSON soundId alanı"),
        ("      soundId: json['soundId']?.toString() ?? 'classic',\n", "JSON soundId okuması"),
    ]:
        text = replace_once(text, old, "", label)

    text = regex_once(
        text,
        r"\n\s*if \(!isSoundUnlocked\(current\.soundId\)\) \{\s*"
        r"current = current\.copyWith\(soundId: 'classic'\);\s*\}\s*",
        "\n",
        "Başlangıçtaki ses kilidi kontrolü",
    )

    text = remove_between(
        text,
        "  static SoundAtmosphere get sound {",
        "  static bool isThemeUnlocked(String id) {",
        "VisualCollectionService sound getter",
    )
    text = remove_between(
        text,
        "  static bool isSoundUnlocked(String id) {",
        "  static Future<void> selectTheme(String id) async {",
        "Ses kilidi metodu",
    )
    text = remove_between(
        text,
        "  static Future<void> selectSound(String id) async {",
        "  static Future<void> selectFavoritePawn(int index) async {",
        "Ses seçme metodu",
    )

    text = replace_once(
        text,
        "'Yeni seviyelerde tema ve ses atmosferleri açılır.'",
        "'Yeni seviyelerde yepyeni tahta dünyaları açılır.'",
        "Koleksiyon üst açıklaması",
    )

    sound_section_start = (
        "              const SizedBox(height: 18),\n"
        "              const Text(\n"
        "                'Ses atmosferi',"
    )
    switch_marker = "              SwitchListTile("
    start = text.find(sound_section_start)
    if start < 0:
        fail("Koleksiyon ekranındaki Ses atmosferi bölümü bulunamadı.")
    end = text.find(switch_marker, start)
    if end < 0:
        fail("Ses atmosferi bölümünden sonraki Canlı tahta anahtarı bulunamadı.")
    text = text[:start] + "              const SizedBox(height: 14),\n" + text[end:]

    text = remove_between(
        text,
        "  Widget _soundCard(SoundAtmosphere sound) {",
        "  void _lockedMessage(String message) {",
        "Ses atmosferi kartı",
    )

    return text


def patch_main(text: str) -> str:
    text = replace_once(
        text,
        "part 'visual_collection.dart';\n",
        "part 'visual_collection.dart';\npart 'board_theme_art.dart';\n",
        "Yeni tema sanatı part bağlantısı",
    )

    text = regex_once(
        text,
        r"\n\s*final atmosphere =\s*VisualCollectionService\.sound;\s*"
        r"\n\s*await player\.setPlaybackRate\(\s*"
        r"\(\s*atmosphere\.playbackRate \*\s*playbackRateMultiplier\s*\)"
        r"\.clamp\(0\.5, 2\.0\)\.toDouble\(\),\s*\);",
        "\n\n      await player.setPlaybackRate(\n"
        "        playbackRateMultiplier.clamp(0.5, 2.0).toDouble(),\n"
        "      );",
        "Ses oynatma hızı çarpanı",
    )

    text = regex_once(
        text,
        r"volume: \(\s*volume \*\s*atmosphere\.volumeMultiplier \*\s*"
        r"AppPreferencesService\.soundMultiplier\s*\)"
        r"\.clamp\(0\.0, 1\.0\)\.toDouble\(\),",
        "volume: (\n"
        "          volume * AppPreferencesService.soundMultiplier\n"
        "        ).clamp(0.0, 1.0).toDouble(),",
        "Ses seviyesi atmosfer çarpanı",
    )

    scaffold_old = (
        "      child: Scaffold(\n"
        "        appBar: AppBar(\n"
        "        title: const Text('Bilgi Rotası'),"
    )
    scaffold_new = (
        "      child: Scaffold(\n"
        "        backgroundColor: BoardThemeArt.screenBackground(\n"
        "          VisualCollectionService.theme.id,\n"
        "        ),\n"
        "        appBar: AppBar(\n"
        "          backgroundColor: BoardThemeArt.appBarColor(\n"
        "            VisualCollectionService.theme.id,\n"
        "          ),\n"
        "          foregroundColor: Colors.white,\n"
        "          surfaceTintColor: Colors.transparent,\n"
        "          title: const Text('Bilgi Rotası'),"
    )
    text = replace_once(
        text,
        scaffold_old,
        scaffold_new,
        "Oyun ekranı tema arka planı",
    )

    card_old = (
        "  Widget _buildBoardCard() {\n"
        "    return Card(\n"
        "      clipBehavior: Clip.none,"
    )
    card_new = (
        "  Widget _buildBoardCard() {\n"
        "    final themeId = VisualCollectionService.theme.id;\n"
        "\n"
        "    return Card(\n"
        "      color: BoardThemeArt.boardCardColor(themeId),\n"
        "      surfaceTintColor: Colors.transparent,\n"
        "      shape: RoundedRectangleBorder(\n"
        "        borderRadius: BorderRadius.circular(24),\n"
        "        side: BorderSide(\n"
        "          color: BoardThemeArt.borderColor(themeId).withOpacity(0.72),\n"
        "          width: 1.6,\n"
        "        ),\n"
        "      ),\n"
        "      clipBehavior: Clip.none,"
    )
    text = replace_once(
        text,
        card_old,
        card_new,
        "Tahta kartı tema çerçevesi",
    )

    background_anchor = (
        "    canvas.drawRRect(\n"
        "      boardShape,\n"
        "      Paint()\n"
        "        ..shader = LinearGradient(\n"
        "          begin: Alignment.topLeft,\n"
        "          end: Alignment.bottomRight,\n"
        "          colors: _theme.backgroundColors,\n"
        "        ).createShader(boardRect),\n"
        "    );\n"
    )
    background_new = background_anchor + (
        "\n"
        "    BoardThemeArt.paintSurface(\n"
        "      canvas,\n"
        "      size,\n"
        "      boardRect,\n"
        "      base,\n"
        "      _theme,\n"
        "      pulse,\n"
        "    );\n"
    )
    text = replace_once(
        text,
        background_anchor,
        background_new,
        "Tahta yüzey sanatı",
    )

    center_start = text.find("  void _drawCenterHex(Canvas canvas, Offset center, double base) {")
    if center_start < 0:
        fail("Merkez altıgen metodu bulunamadı.")
    center_end = text.find("  void _drawText(", center_start)
    if center_end < 0:
        fail("Merkez altıgen metodunun sonu bulunamadı.")
    center_block = text[center_start:center_end]
    center_block = replace_once(
        center_block,
        "      '🧭',",
        "      BoardThemeArt.centerEmoji(_theme.id),",
        "Temaya göre merkez simgesi",
    )
    text = text[:center_start] + center_block + text[center_end:]

    return text


def patch_test(text: str) -> str:
    test_block = r"""
    test('Altı tahta teması ayrı sanat profiline sahiptir', () {
      expect(boardThemes.length, 6);
      expect(BoardThemeArt.profileCount, boardThemes.length);

      final themeIds = boardThemes.map((theme) => theme.id).toSet();
      final artIds = BoardThemeArt.profiles
          .map((profile) => profile.id)
          .toSet();

      expect(artIds, themeIds);
      expect(
        BoardThemeArt.profiles
            .map((profile) => profile.centerEmoji)
            .toSet()
            .length,
        boardThemes.length,
      );

      for (final theme in boardThemes) {
        final profile = BoardThemeArt.profileFor(theme.id);
        expect(profile.tagline.trim(), isNotEmpty);
        expect(BoardThemeArt.centerEmoji(theme.id).trim(), isNotEmpty);
      }
    });

"""
    marker = "    test('Zar jokeri kaldırılır ve özel kutular yenilenir', () {"
    return replace_once(
        text,
        marker,
        test_block + marker,
        "Tema sanatı testi ekleme noktası",
    )


def update_descriptions(text: str) -> str:
    replacements = {
        "Mor, turkuaz ve altın klasik görünüm.":
            "Pusula çizgileri, keşif haritası ve altın klasik görünüm.",
        "Kum taşı, lapis ve firavun altını.":
            "Hiyeroglifler, ankhlar, piramitler ve firavun altını.",
        "Gece mavisi, neon mor ve yıldız ışığı.":
            "Yıldız alanı, yörüngeler ve neon istasyon devreleri.",
        "Zümrüt yeşili ve sıcak ahşap tonları.":
            "Ağaç halkaları, sarmaşıklar ve sıcak fener ışığı.",
        "Mercan parıltılı derin deniz tahtası.":
            "Kabarcıklar, mercanlar ve su altı ışık huzmeleri.",
        "Neon pembe, elektrik mavisi ve krom.":
            "Neon şehir çizgileri, hologramlar ve krom devreler.",
    }
    for old, new in replacements.items():
        text = replace_once(text, old, new, f"Tema açıklaması: {old}")
    return text


def verify_removed_tokens() -> None:
    forbidden = [
        "SoundAtmosphere",
        "soundAtmospheres",
        "isSoundUnlocked",
        "selectSound",
        "VisualCollectionService.sound",
        "soundId",
    ]
    offenders = []
    for path in (ROOT / "lib").glob("*.dart"):
        content = path.read_text(encoding="utf-8")
        for token in forbidden:
            if token in content:
                offenders.append(f"{path.relative_to(ROOT)} -> {token}")
    if offenders:
        fail(
            "Ses atmosferinden kalan beklenmeyen referanslar var:\n- "
            + "\n- ".join(offenders)
        )


def main() -> None:
    ensure_repo()

    originals: dict[Path, bytes | None] = {}
    for path in [MAIN, COLLECTION, THEME_ART, TEST, PUBSPEC]:
        originals[path] = path.read_bytes() if path.exists() else None

    committed = False
    try:
        main_text = MAIN.read_text(encoding="utf-8")
        collection_text = COLLECTION.read_text(encoding="utf-8")
        test_text = TEST.read_text(encoding="utf-8")
        pubspec_text = PUBSPEC.read_text(encoding="utf-8")

        collection_text = patch_collection(collection_text)
        collection_text = update_descriptions(collection_text)
        main_text = patch_main(main_text)
        test_text = patch_test(test_text)

        pubspec_text = replace_once(
            pubspec_text,
            f"version: {OLD_VERSION}",
            f"version: {NEW_VERSION}",
            "Sürüm numarası",
        )

        MAIN.write_text(main_text, encoding="utf-8")
        COLLECTION.write_text(collection_text, encoding="utf-8")
        THEME_ART.write_text(BOARD_THEME_ART, encoding="utf-8")
        TEST.write_text(test_text, encoding="utf-8")
        PUBSPEC.write_text(pubspec_text, encoding="utf-8")

        verify_removed_tokens()

        dart = shutil.which("dart")
        flutter = shutil.which("flutter")

        if dart:
            run(
                dart,
                "format",
                "lib/main.dart",
                "lib/visual_collection.dart",
                "lib/board_theme_art.dart",
                "test/system_smoke_test.dart",
            )
        else:
            print("UYARI: dart bulunamadı; format adımı atlandı.")

        run("git", "diff", "--check")

        if flutter:
            run(flutter, "pub", "get")
            run(flutter, "analyze")
            run(flutter, "test")
        else:
            print("UYARI: flutter bulunamadı; pub get/analyze/test atlandı.")

        if output("git", "status", "--porcelain", "--", "assets/questions.json"):
            fail("Kurulum soru dosyasını değiştirdi; güvenlik için işlem durduruldu.")

        changed = output("git", "diff", "--name-only")
        allowed = set(STAGE_PATHS)
        unexpected = [
            path for path in changed.splitlines()
            if path and path not in allowed
        ]
        if unexpected:
            fail(
                "Kurulum beklenmeyen dosyaları değiştirdi:\n- "
                + "\n- ".join(unexpected)
            )

        run("git", "add", "--", *STAGE_PATHS)

        staged = output("git", "diff", "--cached", "--name-only").splitlines()
        if not staged:
            fail("Stage edilecek değişiklik oluşmadı.")
        if any(path == "assets/questions.json" for path in staged):
            fail("Soru dosyası yanlışlıkla stage edildi.")

        run("git", "commit", "-m", COMMIT_MESSAGE)
        committed = True

        try:
            run("git", "push", "origin", "main")
        except Exception:
            print(
                "\nKod doğrulandı ve commit oluşturuldu fakat push başarısız oldu.\n"
                "İnternet düzeldikten sonra yalnızca şu komutu çalıştır:\n"
                "  git push origin main\n"
            )
            raise

        print(
            "\n✅ Kurulum tamamlandı.\n"
            f"✅ Yeni sürüm: {NEW_VERSION}\n"
            "✅ Ses atmosferi kaldırıldı.\n"
            "✅ Altı tema gerçek görsel dünyalara dönüştürüldü.\n"
            "✅ assets/questions.json dosyasına dokunulmadı.\n"
            "✅ Commit main dalına push edildi.\n\n"
            "Şimdi GitHub Actions yeşil olana kadar bekle; sonra yeni APK'yı indirip kur."
        )

    except Exception as error:
        if not committed:
            for path, data in originals.items():
                if data is None:
                    if path.exists():
                        path.unlink()
                else:
                    path.write_bytes(data)
            run("git", "reset", "--quiet", "--", *STAGE_PATHS, check=False)
            print("\nDeğiştirilen dosyalar eski hâline döndürüldü.")
        print(f"\n❌ Kurulum başarısız: {error}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
