import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CalculatorKeypad extends StatelessWidget {
  const CalculatorKeypad({
    super.key,
    required this.onKeyTap,
  });

  final ValueChanged<String> onKeyTap;

  static const List<String> _keys = <String>[
    '1',
    '2',
    '3',
    '+',
    '4',
    '5',
    '6',
    '-',
    '7',
    '8',
    '9',
    '×',
    '.',
    '0',
    '=',
    '÷',
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _keys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        mainAxisExtent: 64,
      ),
      itemBuilder: (BuildContext context, int index) {
        final String key = _keys[index];
        final bool isOperator = <String>{'+', '-', '×', '÷'}.contains(key);

        return FilledButton(
          onPressed: () => onKeyTap(key),
          style: FilledButton.styleFrom(
            backgroundColor:
                isOperator ? AppColors.primaryLight : AppColors.surface,
            foregroundColor:
                isOperator ? AppColors.primary : AppColors.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(key),
        );
      },
    );
  }
}
