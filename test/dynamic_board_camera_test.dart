import 'dart:math';

import 'package:bilgi_rotasi/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DynamicBoardCameraMath', () {
    test('merkezde tahta dönmez', () {
      expect(
        DynamicBoardCameraMath.angleForNode(BoardMap.centerId),
        closeTo(0, 0.000001),
      );
    });

    test('sağdaki dış halka aktif oyuncuyu alt tarafa çevirir', () {
      final rightNode = BoardMap.outerId(9);
      expect(
        DynamicBoardCameraMath.angleForNode(rightNode),
        closeTo(pi / 2, 0.000001),
      );
    });

    test('kamera en kısa dönüş yönünü seçer', () {
      final adjusted = DynamicBoardCameraMath.nearestEquivalentAngle(
        current: pi - 0.08,
        target: -pi + 0.08,
      );

      expect((adjusted - (pi - 0.08)).abs(), lessThan(0.20));
    });

    test('kapalı kamera kimlik matrisi üretir', () {
      final matrix = DynamicBoardCameraMath.transformFor(
        size: const Size(400, 400),
        angle: pi / 2,
        enabled: false,
      );

      expect(matrix, Matrix4.identity());
    });
  });

  group('DynamicPawnClusterLayout', () {
    test('altı piyon merkezde farklı noktalara yerleşir', () {
      final offsets = <Offset>{
        for (var index = 0; index < 6; index++)
          DynamicPawnClusterLayout.offsetFor(
            point: const Offset(200, 200),
            boardCenter: const Offset(200, 200),
            playerIndexInCell: index,
            playerCountInCell: 6,
            active: index == 3,
            base: 400,
            isCenter: true,
          ),
      };

      expect(offsets.length, 6);
    });

    test('aktif piyon kalabalık karede dışarı taşınır', () {
      const point = Offset(320, 200);
      const center = Offset(200, 200);

      final passive = DynamicPawnClusterLayout.offsetFor(
        point: point,
        boardCenter: center,
        playerIndexInCell: 2,
        playerCountInCell: 6,
        active: false,
        base: 400,
        isCenter: false,
      );
      final active = DynamicPawnClusterLayout.offsetFor(
        point: point,
        boardCenter: center,
        playerIndexInCell: 2,
        playerCountInCell: 6,
        active: true,
        base: 400,
        isCenter: false,
      );

      expect(active.dx, greaterThan(passive.dx));
    });
  });
}
