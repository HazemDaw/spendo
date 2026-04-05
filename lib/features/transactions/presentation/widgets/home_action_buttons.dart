import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HomeActionButtons extends StatelessWidget {
  const HomeActionButtons({
    super.key,
    required this.expenseLabel,
    required this.incomeLabel,
    required this.onExpensePressed,
    required this.onIncomePressed,
  });

  final String expenseLabel;
  final String incomeLabel;
  final VoidCallback onExpensePressed;
  final VoidCallback onIncomePressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onExpensePressed,
            icon: const Icon(Icons.remove_circle_outline,
                color: AppColors.expense),
            label: Text(
              expenseLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.expense,
                  ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.expense),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onIncomePressed,
            icon: const Icon(Icons.add_circle_outline, color: AppColors.income),
            label: Text(
              incomeLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.income,
                  ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.income),
            ),
          ),
        ),
      ],
    );
  }
}
