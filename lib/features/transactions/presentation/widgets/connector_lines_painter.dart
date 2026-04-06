import 'dart:math' as math;

import 'package:flutter/material.dart';

class ConnectorLinesPainter extends CustomPainter {
  const ConnectorLinesPainter({
    required this.angles,
    required this.hasSpending,
    required this.center,
    required this.chartOuterRadius,
    required this.iconOrbitRadius,
  });

  final List<double> angles;
  final List<bool> hasSpending;
  final Offset center;
  final double chartOuterRadius;
  final double iconOrbitRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.4)
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    for (int index = 0; index < angles.length; index++) {
      if (!hasSpending[index]) {
        continue;
      }

      final Offset lineStart = Offset(
        center.dx + (iconOrbitRadius * math.cos(angles[index])),
        center.dy + (iconOrbitRadius * math.sin(angles[index])),
      );
      final Offset lineEnd = Offset(
        center.dx + (chartOuterRadius * math.cos(angles[index])),
        center.dy + (chartOuterRadius * math.sin(angles[index])),
      );

      canvas.drawLine(lineStart, lineEnd, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ConnectorLinesPainter oldDelegate) {
    return oldDelegate.angles != angles ||
        oldDelegate.hasSpending != hasSpending ||
        oldDelegate.center != center ||
        oldDelegate.chartOuterRadius != chartOuterRadius ||
        oldDelegate.iconOrbitRadius != iconOrbitRadius;
  }
}
