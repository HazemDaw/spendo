import 'package:flutter/material.dart';

class OrbitConnector {
  const OrbitConnector({
    required this.start,
    required this.end,
    required this.color,
  });

  final Offset start;
  final Offset end;
  final Color color;
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
        ..color = connector.color.withValues(alpha: 0.28)
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(connector.start, connector.end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ConnectorLinesPainter oldDelegate) {
    return oldDelegate.connectors != connectors;
  }
}
