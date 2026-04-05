import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart';

class PeriodFilterChips extends StatelessWidget {
  const PeriodFilterChips({
    super.key,
    required this.selectedPeriod,
    required this.labels,
    required this.onSelected,
  });

  final TransactionPeriod selectedPeriod;
  final Map<TransactionPeriod, String> labels;
  final ValueChanged<TransactionPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: TransactionPeriod.values
          .map(
            (TransactionPeriod period) => FilterChip(
              label: Text(labels[period]!),
              selected: period == selectedPeriod,
              onSelected: (_) => onSelected(period),
            ),
          )
          .toList(),
    );
  }
}
