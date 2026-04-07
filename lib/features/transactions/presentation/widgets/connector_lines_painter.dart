import 'package:flutter/material.dart';

class OrbitConnector {
  const OrbitConnector({
    required this.iconCenter,
    required this.color,
    required this.active,
  });

  final Offset iconCenter;
  final Color color;
  final bool active;
}

class ConnectorLinesPainter extends CustomPainter {
  const ConnectorLinesPainter({
    required this.connectors,
    required this.center,
    required this.chartRadius,
  });

  final List<OrbitConnector> connectors;
  final Offset center;
  final double chartRadius;

  @override
  void paint(Canvas canvas, Size size) {
    for (final OrbitConnector connector in connectors) {
      if (!connector.active) {
        continue;
      }

      final Offset delta = connector.iconCenter - center;
      final double distance = delta.distance;
      if (distance == 0) {
        continue;
      }

      final Offset unit = delta / distance;
      final Offset lineStart = center + (unit * chartRadius);
      final Offset lineEnd = connector.iconCenter - (unit * 34);
      final Paint paint = Paint()
        ..color = connector.color.withValues(alpha: 0.42)
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(lineStart, lineEnd, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ConnectorLinesPainter oldDelegate) {
    return oldDelegate.connectors != connectors ||
        oldDelegate.center != center ||
        oldDelegate.chartRadius != chartRadius;
  }
}
