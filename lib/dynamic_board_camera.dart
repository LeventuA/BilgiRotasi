part of 'main.dart';

class DynamicBoardCameraViewport extends StatefulWidget {
  const DynamicBoardCameraViewport({
    required this.players,
    required this.currentPlayerIndex,
    required this.enabled,
    this.moveOptions = const <MoveOption>[],
    this.onMoveSelected,
    this.activeMove,
    this.routeOpacity = 0,
    this.landingNodeId,
    this.landingPulse = 0,
    super.key,
  });

  final List<PlayerData> players;
  final int currentPlayerIndex;
  final bool enabled;
  final List<MoveOption> moveOptions;
  final ValueChanged<MoveOption>? onMoveSelected;
  final MoveOption? activeMove;
  final double routeOpacity;
  final int? landingNodeId;
  final int landingPulse;

  @override
  State<DynamicBoardCameraViewport> createState() =>
      _DynamicBoardCameraViewportState();
}

class _DynamicBoardCameraViewportState
    extends State<DynamicBoardCameraViewport> {
  Timer? _settleTimer;
  int _observedPlayerIndex = -1;
  int _observedNodeId = BoardMap.centerId;
  double _cameraAngle = 0;

  int get _safePlayerIndex {
    if (widget.players.isEmpty) return 0;
    return widget.currentPlayerIndex
        .clamp(0, widget.players.length - 1)
        .toInt();
  }

  int get _activeNodeId {
    if (widget.players.isEmpty) return BoardMap.centerId;
    return widget.players[_safePlayerIndex].position;
  }

  @override
  void initState() {
    super.initState();
    _observedPlayerIndex = _safePlayerIndex;
    _observedNodeId = _activeNodeId;
    _cameraAngle = DynamicBoardCameraMath.angleForNode(_observedNodeId);
  }

  @override
  void didUpdateWidget(covariant DynamicBoardCameraViewport oldWidget) {
    super.didUpdateWidget(oldWidget);

    final playerIndex = _safePlayerIndex;
    final nodeId = _activeNodeId;
    final playerChanged = playerIndex != _observedPlayerIndex;
    final nodeChanged = nodeId != _observedNodeId;
    final enabledChanged = oldWidget.enabled != widget.enabled;

    if (!playerChanged && !nodeChanged && !enabledChanged) return;

    _observedPlayerIndex = playerIndex;
    _observedNodeId = nodeId;

    if (!widget.enabled) {
      _settleTimer?.cancel();
      setState(() => _cameraAngle = 0);
      return;
    }

    _scheduleFocus(playerChanged: playerChanged);
  }

  void _scheduleFocus({required bool playerChanged}) {
    _settleTimer?.cancel();
    _settleTimer = Timer(Duration(milliseconds: playerChanged ? 260 : 480), () {
      if (!mounted || !widget.enabled) return;

      final target = DynamicBoardCameraMath.angleForNode(_activeNodeId);
      setState(() {
        _cameraAngle = DynamicBoardCameraMath.nearestEquivalentAngle(
          current: _cameraAngle,
          target: target,
        );
      });
    });
  }

  @override
  void dispose() {
    _settleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animationMode = AppPreferencesService.current.animationMode;
    final cameraEnabled = widget.enabled && animationMode != 'minimal';
    final duration =
        animationMode == 'reduced'
            ? const Duration(milliseconds: 360)
            : const Duration(milliseconds: 650);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final matrix = DynamicBoardCameraMath.transformFor(
          size: size,
          angle: cameraEnabled ? _cameraAngle : 0,
          enabled: cameraEnabled,
        );

        return AnimatedContainer(
          duration: duration,
          curve: Curves.easeInOutCubic,
          transform: matrix,
          transformAlignment: Alignment.center,
          child: GameBoard(
            players: widget.players,
            currentPlayerIndex: widget.currentPlayerIndex,
            moveOptions: widget.moveOptions,
            onMoveSelected: widget.onMoveSelected,
            activeMove: widget.activeMove,
            routeOpacity: widget.routeOpacity,
            landingNodeId: widget.landingNodeId,
            landingPulse: widget.landingPulse,
          ),
        );
      },
    );
  }
}

class DynamicBoardCameraMath {
  DynamicBoardCameraMath._();

  static double angleForNode(int nodeId) {
    final node = BoardMap.node(nodeId);
    if (node.kind == BoardNodeKind.center) return 0;

    final nodeAngle =
        node.kind == BoardNodeKind.outer
            ? -pi / 2 + node.ring! * (2 * pi / BoardMap.outerCount)
            : BoardMap.armAngle(node.arm!);

    return pi / 2 - nodeAngle;
  }

  static double nearestEquivalentAngle({
    required double current,
    required double target,
  }) {
    var adjusted = target;
    while (adjusted - current > pi) {
      adjusted -= 2 * pi;
    }
    while (adjusted - current < -pi) {
      adjusted += 2 * pi;
    }
    return adjusted;
  }

  static Matrix4 transformFor({
    required Size size,
    required double angle,
    required bool enabled,
  }) {
    if (!enabled || size.isEmpty) return Matrix4.identity();

    final base = min(size.width, size.height);
    return Matrix4.identity()
      ..setEntry(3, 2, 0.00115)
      ..translate(0.0, -base * 0.105)
      ..rotateX(0.16)
      ..rotateZ(angle)
      ..scale(1.055, 1.055);
  }
}

class DynamicPawnClusterLayout {
  DynamicPawnClusterLayout._();

  static Offset offsetFor({
    required Offset point,
    required Offset boardCenter,
    required int playerIndexInCell,
    required int playerCountInCell,
    required bool active,
    required double base,
    required bool isCenter,
  }) {
    if (playerCountInCell <= 1) return Offset.zero;

    if (isCenter) {
      final angle =
          -pi / 2 + playerIndexInCell * (2 * pi / playerCountInCell.toDouble());
      final radius = base * (playerCountInCell >= 5 ? 0.102 : 0.086);
      final activeLift = active ? base * 0.012 : 0.0;
      return Offset(cos(angle), sin(angle)) * (radius + activeLift);
    }

    final radialAngle = atan2(
      point.dy - boardCenter.dy,
      point.dx - boardCenter.dx,
    );
    final radial = Offset(cos(radialAngle), sin(radialAngle));
    final tangent = Offset(-sin(radialAngle), cos(radialAngle));

    if (playerCountInCell <= 3) {
      final centeredSlot = playerIndexInCell - (playerCountInCell - 1) / 2;
      return tangent * centeredSlot * base * 0.050 +
          radial * (active ? base * 0.018 : 0.0);
    }

    final span = min(pi * 0.82, 0.27 * (playerCountInCell - 1));
    final step = span / (playerCountInCell - 1);
    final localAngle = -span / 2 + playerIndexInCell * step;
    final tangentOffset = sin(localAngle) * base * 0.118;
    final radialOffset = (1 - cos(localAngle)) * base * 0.055;

    return tangent * tangentOffset +
        radial * (radialOffset + (active ? base * 0.024 : 0.0));
  }
}
