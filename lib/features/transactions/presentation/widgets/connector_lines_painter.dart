import 'package:flutter/material.dart';

class OrbitConnector {
  const OrbitConnector({
    required this.start,
    required this.end,
    required this.color,
    required this.chartCenter,
    required this.routeRadius,
  });

  final Offset start;
  final Offset end;
  final Color color;
  final Offset chartCenter;
  final double routeRadius;
}

class ConnectorLinesPainter extends CustomPainter {
  const ConnectorLinesPainter({
    required this.connectors,
  });

  final List<OrbitConnector> connectors;

  @override
  void paint(Canvas canvas, Size size) {
    for (final OrbitConnector connector in connectors) {
      final Paint paint = Paint()
        ..color = connector.color.withValues(alpha: 0.6)
        ..strokeWidth = 0.8
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(connector.start, connector.end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ConnectorLinesPainter oldDelegate) {
    return oldDelegate.connectors != connectors;
  }
}
