import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

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
    required this.income,
    required this.expense,
    required this.onSliceTap,
  });

  final List<DonutCategorySlice> slices;
  final double income;
  final double expense;
  final ValueChanged<String> onSliceTap;

  bool get _isEmpty => slices.isEmpty;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 62,
            startDegreeOffset: -90,
            pieTouchData: PieTouchData(
              enabled: !_isEmpty,
              touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
                if (event is! FlTapUpEvent || response?.touchedSection == null) {
                  return;
                }

                final int index =
                    response!.touchedSection!.touchedSectionIndex;
                onSliceTap(slices[index].categoryKey);
              },
            ),
            sections: _isEmpty ? _emptySections() : _dataSections(),
          ),
        ),
        IgnorePointer(
          child: _isEmpty
              ? Text(
                  CurrencyFormatter.format(0),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      CurrencyFormatter.format(income),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.income,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.format(expense),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.expense,
                          ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _emptySections() {
    return <PieChartSectionData>[
      PieChartSectionData(
        value: 1,
        color: AppColors.emptyDonut,
        radius: 38,
        showTitle: false,
      ),
    ];
  }

  List<PieChartSectionData> _dataSections() {
    return slices
        .map(
          (DonutCategorySlice slice) => PieChartSectionData(
            value: slice.value,
            color: slice.color,
            radius: 38,
            showTitle: false,
          ),
        )
        .toList();
  }
}
