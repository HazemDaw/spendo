import 'dart:math' as math;

import 'package:flutter/material.dart';

class DonutCategorySlice {
  const DonutCategorySlice({
    required this.categoryKey,
    required this.value,
    required this.color,
  });

  final String categoryKey;
  final double value;
  final Color color;
}

class DonutChartWidget extends StatelessWidget {
  const DonutChartWidget({
    super.key,
    required this.slices,
    required this.incomeText,
    required this.expenseText,
    required this.startAngleDegrees,
    required this.outerRadius,
    required this.innerRadius,
    required this.onSliceTap,
  });

  final List<DonutCategorySlice> slices;
  final String incomeText;
  final String expenseText;
  final double startAngleDegrees;
  final double outerRadius;
  final double innerRadius;
  final ValueChanged<String> onSliceTap;

  bool get _isEmpty => slices.isEmpty;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: _isEmpty
          ? null
          : (TapUpDetails details) {
              final String? categoryKey = _hitTest(details.localPosition);
              if (categoryKey != null) {
                onSliceTap(categoryKey);
              }
            },
      child: SizedBox.square(
        dimension: outerRadius * 2,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            CustomPaint(
              size: Size.square(outerRadius * 2),
              painter: _DonutChartPainter(
                slices: slices,
                startAngleDegrees: startAngleDegrees,
                outerRadius: outerRadius,
                innerRadius: innerRadius,
              ),
            ),
            IgnorePointer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    incomeText,
                    style: const TextStyle(
                      color: Color(0xFF89A14F),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    expenseText,
                    style: const TextStyle(
                      color: Color(0xFFB75C63),
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _hitTest(Offset localPosition) {
    final Offset center = Offset(outerRadius, outerRadius);
    final Offset delta = localPosition - center;
    final double radius = delta.distance;
    if (radius < innerRadius || radius > outerRadius) {
      return null;
    }

    final double tapAngle = _normalizeAngle(math.atan2(delta.dy, delta.dx));
    final double total = slices.fold<double>(
      0,
      (double sum, DonutCategorySlice slice) => sum + slice.value,
    );
    double current = _normalizeAngle(startAngleDegrees * math.pi / 180);

    for (final DonutCategorySlice slice in slices) {
      final double sweep = (slice.value / total) * (math.pi * 2);
      final double end = current + sweep;
      if (_containsAngle(tapAngle, current, end)) {
        return slice.categoryKey;
      }
      current = end;
    }

    return null;
  }

  bool _containsAngle(double value, double start, double end) {
    final double normalizedValue = _normalizeAngle(value);
    final double normalizedStart = _normalizeAngle(start);
    final double normalizedEnd = _normalizeAngle(end);

    if (normalizedStart <= normalizedEnd) {
      return normalizedValue >= normalizedStart &&
          normalizedValue <= normalizedEnd;
    }

    return normalizedValue >= normalizedStart || normalizedValue <= normalizedEnd;
  }

  double _normalizeAngle(double angle) {
    const double fullTurn = math.pi * 2;
    final double normalized = angle % fullTurn;
    return normalized < 0 ? normalized + fullTurn : normalized;
  }
}

class _DonutChartPainter extends CustomPainter {
  const _DonutChartPainter({
    required this.slices,
    required this.startAngleDegrees,
    required this.outerRadius,
    required this.innerRadius,
  });

  final List<DonutCategorySlice> slices;
  final double startAngleDegrees;
  final double outerRadius;
  final double innerRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double strokeWidth = outerRadius - innerRadius;
    final double arcRadius = innerRadius + (strokeWidth / 2);
    final Rect rect = Rect.fromCircle(center: center, radius: arcRadius);

    canvas.drawShadow(
      Path()..addOval(Rect.fromCircle(center: center, radius: outerRadius - 6)),
      const Color(0x552E302E),
      10,
      false,
    );

    final Paint outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0x33764340);
    canvas.drawCircle(center, outerRadius - 1, outlinePaint);
    canvas.drawCircle(center, innerRadius + 1, outlinePaint);

    final double total = slices.fold<double>(
      0,
      (double sum, DonutCategorySlice slice) => sum + slice.value,
    );
    double start = startAngleDegrees * math.pi / 180;

    for (final DonutCategorySlice slice in slices) {
      final Paint paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt
        ..color = slice.color;
      final double sweep = (slice.value / total) * (math.pi * 2);
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.slices != slices ||
        oldDelegate.startAngleDegrees != startAngleDegrees ||
        oldDelegate.outerRadius != outerRadius ||
        oldDelegate.innerRadius != innerRadius;
  }
}
