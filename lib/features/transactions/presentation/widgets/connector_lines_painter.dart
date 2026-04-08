import 'dart:math' as math;

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
        ..color = connector.color.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true;

      canvas.drawPath(_buildPath(connector), paint);
    }
  }

  Path _buildPath(OrbitConnector connector) {
    final Offset startVector = connector.start - connector.chartCenter;
    final Offset endVector = connector.end - connector.chartCenter;
    final double startAngle = math.atan2(startVector.dy, startVector.dx);
    final double endAngle = math.atan2(endVector.dy, endVector.dx);
    final Offset escapePoint = _pointOnCircle(
      center: connector.chartCenter,
      radius: connector.routeRadius,
      angle: startAngle,
    );
    final Offset approachPoint = _pointOnCircle(
      center: connector.chartCenter,
      radius: connector.routeRadius,
      angle: endAngle,
    );
    final Path path = Path()..moveTo(connector.start.dx, connector.start.dy);

    final double escapeDistance = (connector.start - escapePoint).distance;
    if (escapeDistance > 0.5) {
      final Offset escapeControl =
          Offset.lerp(connector.start, escapePoint, 0.55)!;
      path.quadraticBezierTo(
        escapeControl.dx,
        escapeControl.dy,
        escapePoint.dx,
        escapePoint.dy,
      );
    } else {
      path.lineTo(escapePoint.dx, escapePoint.dy);
    }

    final double sweepAngle = _normalizedSweep(startAngle, endAngle);
    if (sweepAngle.abs() > 0.001) {
      path.arcTo(
        Rect.fromCircle(
          center: connector.chartCenter,
          radius: connector.routeRadius,
        ),
        startAngle,
        sweepAngle,
        false,
      );
    } else {
      path.lineTo(approachPoint.dx, approachPoint.dy);
    }

    final Offset endControl = Offset.lerp(approachPoint, connector.end, 0.45)!;
    path.quadraticBezierTo(
      endControl.dx,
      endControl.dy,
      connector.end.dx,
      connector.end.dy,
    );

    return path;
  }

  Offset _pointOnCircle({
    required Offset center,
    required double radius,
    required double angle,
  }) {
    return Offset(
      center.dx + (math.cos(angle) * radius),
      center.dy + (math.sin(angle) * radius),
    );
  }

  double _normalizedSweep(double startAngle, double endAngle) {
    const double fullTurn = math.pi * 2;
    double sweep = (endAngle - startAngle) % fullTurn;
    if (sweep > math.pi) {
      sweep -= fullTurn;
    } else if (sweep < -math.pi) {
      sweep += fullTurn;
    }
    return sweep;
  }

  @override
  bool shouldRepaint(covariant ConnectorLinesPainter oldDelegate) {
    return oldDelegate.connectors != connectors;
  }
}
