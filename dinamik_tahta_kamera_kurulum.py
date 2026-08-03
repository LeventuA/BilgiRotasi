#!/usr/bin/env python3
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

BRANCH = "experiment/dynamic-board-camera"
BASE_BRANCH = "release/final-closed-test-aab-1.68.8"


def run(*args: str, check: bool = True) -> subprocess.CompletedProcess[str]:
    print("+", " ".join(args), flush=True)
    return subprocess.run(args, text=True, check=check)


def replace_once(text: str, old: str, new: str, label: str) -> str:
    if new in text:
        print(f"✓ {label} zaten uygulanmış")
        return text

    count = text.count(old)
    if count != 1:
        raise RuntimeError(
            f"{label} için beklenen metin {count} kez bulundu; işlem durduruldu."
        )

    print(f"✓ {label} uygulanıyor")
    return text.replace(old, new, 1)


def ensure_branch() -> None:
    result = subprocess.run(
        ["git", "branch", "--show-current"],
        text=True,
        capture_output=True,
        check=True,
    )
    current = result.stdout.strip()
    if current != BRANCH:
        raise RuntimeError(
            f"Bu betik yalnız {BRANCH} dalında çalışır. Şu anki dal: {current or 'belirsiz'}"
        )


def patch_main(path: Path) -> None:
    text = path.read_text(encoding="utf-8")

    text = replace_once(
        text,
        "part 'board_target_presentation.dart';",
        "part 'board_target_presentation.dart';\npart 'dynamic_board_camera.dart';",
        "dynamic camera part bağlantısı",
    )

    old_board = """                    child: GameBoard(
                      players: widget.players,
                      currentPlayerIndex: _currentPlayerIndex,
                      moveOptions: _moveOptions,
                      onMoveSelected: _selectMoveFromBoard,
                      activeMove: _activeMove,
                      routeOpacity: _routeOpacity,
                      landingNodeId: _landingNodeId,
                      landingPulse: _landingPulse,
                    ),"""
    new_board = """                    child: DynamicBoardCameraViewport(
                      players: widget.players,
                      currentPlayerIndex: _currentPlayerIndex,
                      enabled:
                          AppPreferencesService.current.dynamicBoardCamera,
                      moveOptions: _moveOptions,
                      onMoveSelected: _selectMoveFromBoard,
                      activeMove: _activeMove,
                      routeOpacity: _routeOpacity,
                      landingNodeId: _landingNodeId,
                      landingPulse: _landingPulse,
                    ),"""
    text = replace_once(
        text,
        old_board,
        new_board,
        "oyun tahtasını dinamik kamera ile sarma",
    )

    old_order = """              ...List.generate(players.length, (index) {"""
    new_order = """              ...<int>[
                for (var index = 0; index < players.length; index++)
                  if (index != safeCurrentPlayerIndex) index,
                if (players.isNotEmpty) safeCurrentPlayerIndex,
              ].map((index) {"""
    text = replace_once(
        text,
        old_order,
        new_order,
        "aktif piyonu en üst katmanda çizme",
    )

    old_cluster = """                if (player.position == BoardMap.centerId) {
                  final divisor = players.isEmpty ? 1 : players.length;
                  final angle = -pi / 2 + index * (2 * pi / divisor.toDouble());
                  point =
                      boardCenter +
                      Offset(cos(angle), sin(angle)) * base * 0.084;
                } else if (sameCellIndexes.length > 1) {
                  final radialAngle = atan2(
                    point.dy - boardCenter.dy,
                    point.dx - boardCenter.dx,
                  );
                  final tangent = Offset(-sin(radialAngle), cos(radialAngle));
                  final centeredSlot =
                      stackSlot - (sameCellIndexes.length - 1) / 2;
                  point += tangent * centeredSlot * base * 0.052;
                }

                final pawnWidth = active ? base * 0.082 : base * 0.072;
                final pawnHeight = active ? base * 0.112 : base * 0.098;"""
    new_cluster = """                if (sameCellIndexes.length > 1) {
                  point += DynamicPawnClusterLayout.offsetFor(
                    point: point,
                    boardCenter: boardCenter,
                    playerIndexInCell: stackSlot,
                    playerCountInCell: sameCellIndexes.length,
                    active: active,
                    base: base,
                    isCenter: player.position == BoardMap.centerId,
                  );
                }

                final crowded = sameCellIndexes.length >= 4;
                final pawnWidth =
                    active ? base * 0.086 : base * (crowded ? 0.058 : 0.069);
                final pawnHeight =
                    active ? base * 0.118 : base * (crowded ? 0.082 : 0.095);"""
    text = replace_once(
        text,
        old_cluster,
        new_cluster,
        "2-6 piyon için kalabalık kare yerleşimi",
    )

    path.write_text(text, encoding="utf-8")


def patch_preferences(path: Path) -> None:
    text = path.read_text(encoding="utf-8")

    replacements = [
        (
            "    this.hapticsEnabled = true,\n    this.tutorialSeen = false,",
            "    this.hapticsEnabled = true,\n"
            "    this.dynamicBoardCamera = true,\n"
            "    this.tutorialSeen = false,",
            "ayar varsayılanı",
        ),
        (
            "  final bool hapticsEnabled;\n  final bool tutorialSeen;",
            "  final bool hapticsEnabled;\n"
            "  final bool dynamicBoardCamera;\n"
            "  final bool tutorialSeen;",
            "ayar alanı",
        ),
        (
            "    bool? hapticsEnabled,\n    bool? tutorialSeen,",
            "    bool? hapticsEnabled,\n"
            "    bool? dynamicBoardCamera,\n"
            "    bool? tutorialSeen,",
            "copyWith parametresi",
        ),
        (
            "      hapticsEnabled:\n"
            "          hapticsEnabled ?? this.hapticsEnabled,\n"
            "      tutorialSeen: tutorialSeen ?? this.tutorialSeen,",
            "      hapticsEnabled:\n"
            "          hapticsEnabled ?? this.hapticsEnabled,\n"
            "      dynamicBoardCamera:\n"
            "          dynamicBoardCamera ?? this.dynamicBoardCamera,\n"
            "      tutorialSeen: tutorialSeen ?? this.tutorialSeen,",
            "copyWith değeri",
        ),
        (
            "        'hapticsEnabled': hapticsEnabled,\n"
            "        'tutorialSeen': tutorialSeen,",
            "        'hapticsEnabled': hapticsEnabled,\n"
            "        'dynamicBoardCamera': dynamicBoardCamera,\n"
            "        'tutorialSeen': tutorialSeen,",
            "ayar JSON yazımı",
        ),
        (
            "      hapticsEnabled: json['hapticsEnabled'] != false,\n"
            "      tutorialSeen: json['tutorialSeen'] == true,",
            "      hapticsEnabled: json['hapticsEnabled'] != false,\n"
            "      dynamicBoardCamera: json['dynamicBoardCamera'] != false,\n"
            "      tutorialSeen: json['tutorialSeen'] == true,",
            "ayar JSON okuması",
        ),
        (
            "          _title('Animasyon yoğunluğu'),\n"
            "          _animationCard(),\n"
            "          const SizedBox(height: 12),\n"
            "          _title('Oynanış ve yardım'),",
            "          _title('Animasyon yoğunluğu'),\n"
            "          _animationCard(),\n"
            "          _switchCard(\n"
            "            emoji: '🎥',\n"
            "            title: 'Dinamik tahta kamerası',\n"
            "            subtitle:\n"
            "                'Piyon hareketi bittikten sonra tahta aktif '\n"
            "                'oyuncuyu yumuşakça ön tarafa getirir.',\n"
            "            value: _settings.dynamicBoardCamera,\n"
            "            onChanged: (value) => _save(\n"
            "              _settings.copyWith(\n"
            "                dynamicBoardCamera: value,\n"
            "              ),\n"
            "            ),\n"
            "          ),\n"
            "          const SizedBox(height: 12),\n"
            "          _title('Oynanış ve yardım'),",
            "ayar ekranı anahtarı",
        ),
    ]

    for old, new, label in replacements:
        text = replace_once(text, old, new, label)

    path.write_text(text, encoding="utf-8")


def write_new_files(root: Path) -> None:
    dynamic_path = root / "lib" / "dynamic_board_camera.dart"
    test_path = root / "test" / "dynamic_board_camera_test.dart"

    dynamic_path.write_text("part of 'main.dart';\n\nclass DynamicBoardCameraViewport extends StatefulWidget {\n  const DynamicBoardCameraViewport({\n    required this.players,\n    required this.currentPlayerIndex,\n    required this.enabled,\n    this.moveOptions = const <MoveOption>[],\n    this.onMoveSelected,\n    this.activeMove,\n    this.routeOpacity = 0,\n    this.landingNodeId,\n    this.landingPulse = 0,\n    super.key,\n  });\n\n  final List<PlayerData> players;\n  final int currentPlayerIndex;\n  final bool enabled;\n  final List<MoveOption> moveOptions;\n  final ValueChanged<MoveOption>? onMoveSelected;\n  final MoveOption? activeMove;\n  final double routeOpacity;\n  final int? landingNodeId;\n  final int landingPulse;\n\n  @override\n  State<DynamicBoardCameraViewport> createState() =>\n      _DynamicBoardCameraViewportState();\n}\n\nclass _DynamicBoardCameraViewportState\n    extends State<DynamicBoardCameraViewport> {\n  Timer? _settleTimer;\n  int _observedPlayerIndex = -1;\n  int _observedNodeId = BoardMap.centerId;\n  double _cameraAngle = 0;\n\n  int get _safePlayerIndex {\n    if (widget.players.isEmpty) return 0;\n    return widget.currentPlayerIndex\n        .clamp(0, widget.players.length - 1)\n        .toInt();\n  }\n\n  int get _activeNodeId {\n    if (widget.players.isEmpty) return BoardMap.centerId;\n    return widget.players[_safePlayerIndex].position;\n  }\n\n  @override\n  void initState() {\n    super.initState();\n    _observedPlayerIndex = _safePlayerIndex;\n    _observedNodeId = _activeNodeId;\n    _cameraAngle = DynamicBoardCameraMath.angleForNode(_observedNodeId);\n  }\n\n  @override\n  void didUpdateWidget(covariant DynamicBoardCameraViewport oldWidget) {\n    super.didUpdateWidget(oldWidget);\n\n    final playerIndex = _safePlayerIndex;\n    final nodeId = _activeNodeId;\n    final playerChanged = playerIndex != _observedPlayerIndex;\n    final nodeChanged = nodeId != _observedNodeId;\n    final enabledChanged = oldWidget.enabled != widget.enabled;\n\n    if (!playerChanged && !nodeChanged && !enabledChanged) return;\n\n    _observedPlayerIndex = playerIndex;\n    _observedNodeId = nodeId;\n\n    if (!widget.enabled) {\n      _settleTimer?.cancel();\n      setState(() => _cameraAngle = 0);\n      return;\n    }\n\n    _scheduleFocus(playerChanged: playerChanged);\n  }\n\n  void _scheduleFocus({required bool playerChanged}) {\n    _settleTimer?.cancel();\n    _settleTimer = Timer(\n      Duration(milliseconds: playerChanged ? 260 : 480),\n      () {\n        if (!mounted || !widget.enabled) return;\n\n        final target = DynamicBoardCameraMath.angleForNode(_activeNodeId);\n        setState(() {\n          _cameraAngle = DynamicBoardCameraMath.nearestEquivalentAngle(\n            current: _cameraAngle,\n            target: target,\n          );\n        });\n      },\n    );\n  }\n\n  @override\n  void dispose() {\n    _settleTimer?.cancel();\n    super.dispose();\n  }\n\n  @override\n  Widget build(BuildContext context) {\n    final animationMode = AppPreferencesService.current.animationMode;\n    final cameraEnabled = widget.enabled && animationMode != 'minimal';\n    final duration =\n        animationMode == 'reduced'\n            ? const Duration(milliseconds: 360)\n            : const Duration(milliseconds: 650);\n\n    return LayoutBuilder(\n      builder: (context, constraints) {\n        final size = Size(constraints.maxWidth, constraints.maxHeight);\n        final matrix = DynamicBoardCameraMath.transformFor(\n          size: size,\n          angle: cameraEnabled ? _cameraAngle : 0,\n          enabled: cameraEnabled,\n        );\n\n        return AnimatedContainer(\n          duration: duration,\n          curve: Curves.easeInOutCubic,\n          transform: matrix,\n          transformAlignment: Alignment.center,\n          child: GameBoard(\n            players: widget.players,\n            currentPlayerIndex: widget.currentPlayerIndex,\n            moveOptions: widget.moveOptions,\n            onMoveSelected: widget.onMoveSelected,\n            activeMove: widget.activeMove,\n            routeOpacity: widget.routeOpacity,\n            landingNodeId: widget.landingNodeId,\n            landingPulse: widget.landingPulse,\n          ),\n        );\n      },\n    );\n  }\n}\n\nclass DynamicBoardCameraMath {\n  DynamicBoardCameraMath._();\n\n  static double angleForNode(int nodeId) {\n    final node = BoardMap.node(nodeId);\n    if (node.kind == BoardNodeKind.center) return 0;\n\n    final nodeAngle =\n        node.kind == BoardNodeKind.outer\n            ? -pi / 2 + node.ring! * (2 * pi / BoardMap.outerCount)\n            : BoardMap.armAngle(node.arm!);\n\n    return pi / 2 - nodeAngle;\n  }\n\n  static double nearestEquivalentAngle({\n    required double current,\n    required double target,\n  }) {\n    var adjusted = target;\n    while (adjusted - current > pi) {\n      adjusted -= 2 * pi;\n    }\n    while (adjusted - current < -pi) {\n      adjusted += 2 * pi;\n    }\n    return adjusted;\n  }\n\n  static Matrix4 transformFor({\n    required Size size,\n    required double angle,\n    required bool enabled,\n  }) {\n    if (!enabled || size.isEmpty) return Matrix4.identity();\n\n    final base = min(size.width, size.height);\n    return Matrix4.identity()\n      ..setEntry(3, 2, 0.00115)\n      ..translate(0.0, -base * 0.105)\n      ..rotateX(0.16)\n      ..rotateZ(angle)\n      ..scale(1.055, 1.055);\n  }\n}\n\nclass DynamicPawnClusterLayout {\n  DynamicPawnClusterLayout._();\n\n  static Offset offsetFor({\n    required Offset point,\n    required Offset boardCenter,\n    required int playerIndexInCell,\n    required int playerCountInCell,\n    required bool active,\n    required double base,\n    required bool isCenter,\n  }) {\n    if (playerCountInCell <= 1) return Offset.zero;\n\n    if (isCenter) {\n      final angle =\n          -pi / 2 +\n          playerIndexInCell * (2 * pi / playerCountInCell.toDouble());\n      final radius = base * (playerCountInCell >= 5 ? 0.102 : 0.086);\n      final activeLift = active ? base * 0.012 : 0.0;\n      return Offset(cos(angle), sin(angle)) * (radius + activeLift);\n    }\n\n    final radialAngle = atan2(\n      point.dy - boardCenter.dy,\n      point.dx - boardCenter.dx,\n    );\n    final radial = Offset(cos(radialAngle), sin(radialAngle));\n    final tangent = Offset(-sin(radialAngle), cos(radialAngle));\n\n    if (playerCountInCell <= 3) {\n      final centeredSlot =\n          playerIndexInCell - (playerCountInCell - 1) / 2;\n      return tangent * centeredSlot * base * 0.050 +\n          radial * (active ? base * 0.018 : 0.0);\n    }\n\n    final span = min(pi * 0.82, 0.27 * (playerCountInCell - 1));\n    final step = span / (playerCountInCell - 1);\n    final localAngle = -span / 2 + playerIndexInCell * step;\n    final tangentOffset = sin(localAngle) * base * 0.118;\n    final radialOffset = (1 - cos(localAngle)) * base * 0.055;\n\n    return tangent * tangentOffset +\n        radial * (radialOffset + (active ? base * 0.024 : 0.0));\n  }\n}\n", encoding="utf-8")
    test_path.write_text("import 'dart:math';\n\nimport 'package:bilgi_rotasi/main.dart';\nimport 'package:flutter/material.dart';\nimport 'package:flutter_test/flutter_test.dart';\n\nvoid main() {\n  group('DynamicBoardCameraMath', () {\n    test('merkezde tahta dönmez', () {\n      expect(\n        DynamicBoardCameraMath.angleForNode(BoardMap.centerId),\n        closeTo(0, 0.000001),\n      );\n    });\n\n    test('sağdaki dış halka aktif oyuncuyu alt tarafa çevirir', () {\n      final rightNode = BoardMap.outerId(9);\n      expect(\n        DynamicBoardCameraMath.angleForNode(rightNode),\n        closeTo(pi / 2, 0.000001),\n      );\n    });\n\n    test('kamera en kısa dönüş yönünü seçer', () {\n      final adjusted = DynamicBoardCameraMath.nearestEquivalentAngle(\n        current: pi - 0.08,\n        target: -pi + 0.08,\n      );\n\n      expect((adjusted - (pi - 0.08)).abs(), lessThan(0.20));\n    });\n\n    test('kapalı kamera kimlik matrisi üretir', () {\n      final matrix = DynamicBoardCameraMath.transformFor(\n        size: const Size(400, 400),\n        angle: pi / 2,\n        enabled: false,\n      );\n\n      expect(matrix, Matrix4.identity());\n    });\n  });\n\n  group('DynamicPawnClusterLayout', () {\n    test('altı piyon merkezde farklı noktalara yerleşir', () {\n      final offsets = <Offset>{\n        for (var index = 0; index < 6; index++)\n          DynamicPawnClusterLayout.offsetFor(\n            point: const Offset(200, 200),\n            boardCenter: const Offset(200, 200),\n            playerIndexInCell: index,\n            playerCountInCell: 6,\n            active: index == 3,\n            base: 400,\n            isCenter: true,\n          ),\n      };\n\n      expect(offsets.length, 6);\n    });\n\n    test('aktif piyon kalabalık karede dışarı taşınır', () {\n      const point = Offset(320, 200);\n      const center = Offset(200, 200);\n\n      final passive = DynamicPawnClusterLayout.offsetFor(\n        point: point,\n        boardCenter: center,\n        playerIndexInCell: 2,\n        playerCountInCell: 6,\n        active: false,\n        base: 400,\n        isCenter: false,\n      );\n      final active = DynamicPawnClusterLayout.offsetFor(\n        point: point,\n        boardCenter: center,\n        playerIndexInCell: 2,\n        playerCountInCell: 6,\n        active: true,\n        base: 400,\n        isCenter: false,\n      );\n\n      expect(active.dx, greaterThan(passive.dx));\n    });\n  });\n}\n", encoding="utf-8")
    print("✓ Dinamik kamera ve test dosyaları yazıldı")


def create_or_show_pr() -> None:
    view = subprocess.run(
        ["gh", "pr", "view", BRANCH, "--json", "url"],
        text=True,
        capture_output=True,
    )
    if view.returncode == 0:
        print("Draft PR zaten mevcut:")
        print(view.stdout.strip())
        return

    body = """## Amaç

Bilgi Rotası tahta oyununda deneysel dinamik kamera prototipi.

- Piyon hareket ederken kamera sabit kalır.
- Hareket bittikten sonra aktif piyon ön tarafa alınır.
- Tur değişince kamera yeni aktif oyuncuya döner.
- 2-6 oyuncuda aynı karedeki piyonlar yay biçiminde gruplanır.
- Aktif piyon en üstte ve daha büyük çizilir.
- Ayarlardan Dinamik tahta kamerası kapatılabilir.
- Minimal animasyon modunda kamera otomatik olarak sabit kalır.

## Güvenlik sınırı

Bu PR deneyseldir. `main` dalına veya kapalı test sürümüne doğrudan alınmamalıdır.
Backend, Firebase, AdMob, soru bankası ve sürüm numarası değiştirilmez.

## Test

- Dinamik kamera matematik testleri
- 6 piyon küme yerleşimi testleri
- Flutter analyze
- Tam Flutter test paketi
"""

    run(
        "gh",
        "pr",
        "create",
        "--draft",
        "--base",
        BASE_BRANCH,
        "--head",
        BRANCH,
        "--title",
        "experiment: dinamik tahta kamerası prototipi",
        "--body",
        body,
    )


def main() -> int:
    root = Path.cwd()
    ensure_branch()

    main_path = root / "lib" / "main.dart"
    preferences_path = root / "lib" / "accessibility_settings.dart"
    if not main_path.exists() or not preferences_path.exists():
        raise RuntimeError(
            "Betik BilgiRotasi depo kökünde çalıştırılmalıdır."
        )

    patch_main(main_path)
    patch_preferences(preferences_path)
    write_new_files(root)

    run(
        "dart",
        "format",
        "lib/main.dart",
        "lib/accessibility_settings.dart",
        "lib/dynamic_board_camera.dart",
        "test/dynamic_board_camera_test.dart",
    )
    run("flutter", "pub", "get")
    run("flutter", "test", "test/dynamic_board_camera_test.dart")
    run(
        "flutter",
        "analyze",
        "--no-fatal-warnings",
        "--no-fatal-infos",
    )
    run("flutter", "test", "--concurrency=1")

    run(
        "git",
        "add",
        "lib/main.dart",
        "lib/accessibility_settings.dart",
        "lib/dynamic_board_camera.dart",
        "test/dynamic_board_camera_test.dart",
    )

    staged = subprocess.run(
        ["git", "diff", "--cached", "--quiet"],
        check=False,
    )
    if staged.returncode == 0:
        print("Değişiklik yok; commit atlanıyor.")
    else:
        run(
            "git",
            "commit",
            "-m",
            "experiment: add dynamic board camera prototype",
        )
        run("git", "push", "origin", f"HEAD:{BRANCH}")

    create_or_show_pr()
    print("\n✅ Dinamik tahta kamerası prototipi hazırlandı.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as error:
        print(f"\n❌ İşlem durdu: {error}", file=sys.stderr)
        raise
