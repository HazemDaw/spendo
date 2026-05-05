import 'dart:math' as math;

import 'package:flutter/foundation.dart';
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

class DonutChartWidget extends StatefulWidget {
  const DonutChartWidget({
    super.key,
    required this.slices,
    required this.incomeText,
    required this.expenseText,
    required this.startAngleDegrees,
    required this.outerRadius,
    required this.innerRadius,
    required this.onSliceTap,
    this.exceededBudgetCategoryKeys = const <String>{},
  });

  final List<DonutCategorySlice> slices;
  final String incomeText;
  final String expenseText;
  final double startAngleDegrees;
  final double outerRadius;
  final double innerRadius;
  final ValueChanged<String> onSliceTap;
  final Set<String> exceededBudgetCategoryKeys;

  @override
  State<DonutChartWidget> createState() => _DonutChartWidgetState();
}

class _DonutChartWidgetState extends State<DonutChartWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseOpacity;

  bool get _isEmpty => widget.slices.isEmpty;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseOpacity = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: _isEmpty
          ? null
          : (TapUpDetails details) {
              final String? categoryKey = _hitTest(details.localPosition);
              if (categoryKey != null) {
                widget.onSliceTap(categoryKey);
              }
            },
      child: SizedBox.square(
        dimension: widget.outerRadius * 2,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            AnimatedBuilder(
              animation: _pulseOpacity,
              builder: (BuildContext context, Widget? child) {
                return CustomPaint(
                  size: Size.square(widget.outerRadius * 2),
                  painter: _DonutChartPainter(
                    slices: widget.slices,
                    startAngleDegrees: widget.startAngleDegrees,
                    outerRadius: widget.outerRadius,
                    innerRadius: widget.innerRadius,
                    exceededBudgetCategoryKeys:
                        widget.exceededBudgetCategoryKeys,
                    pulseOpacity: _pulseOpacity.value,
                  ),
                );
              },
            ),
            IgnorePointer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    widget.incomeText,
                    style: const TextStyle(
                      color: Color(0xFF89A14F),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.expenseText,
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
    final Offset center = Offset(widget.outerRadius, widget.outerRadius);
    final Offset delta = localPosition - center;
    final double radius = delta.distance;
    if (radius < widget.innerRadius || radius > widget.outerRadius) {
      return null;
    }

    final double tapAngle = _normalizeAngle(math.atan2(delta.dy, delta.dx));
    final double total = widget.slices.fold<double>(
      0,
      (double sum, DonutCategorySlice slice) => sum + slice.value,
    );
    double current = _normalizeAngle(widget.startAngleDegrees * math.pi / 180);

    for (final DonutCategorySlice slice in widget.slices) {
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
    required this.exceededBudgetCategoryKeys,
    required this.pulseOpacity,
  });

  final List<DonutCategorySlice> slices;
  final double startAngleDegrees;
  final double outerRadius;
  final double innerRadius;
  final Set<String> exceededBudgetCategoryKeys;
  final double pulseOpacity;

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
      final double opacity = exceededBudgetCategoryKeys.contains(
        slice.categoryKey,
      )
          ? pulseOpacity
          : 1.0;
      final Paint paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt
        ..color = slice.color.withValues(alpha: opacity);
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
        oldDelegate.innerRadius != innerRadius ||
        !setEquals(
          oldDelegate.exceededBudgetCategoryKeys,
          exceededBudgetCategoryKeys,
        ) ||
        oldDelegate.pulseOpacity != pulseOpacity;
  }
}
