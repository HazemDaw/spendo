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
    final Paint paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.4)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    for (final OrbitConnector connector in connectors) {
      canvas.drawLine(connector.start, connector.end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ConnectorLinesPainter oldDelegate) {
    return oldDelegate.connectors != connectors;
  }
}
