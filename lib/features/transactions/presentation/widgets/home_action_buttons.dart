import 'package:flutter/material.dart';

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
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _CircularActionButton(
          color: const Color(0xFFEF7E8E),
          icon: Icons.remove_rounded,
          onPressed: onExpensePressed,
        ),
        const SizedBox(width: 76),
        _CircularActionButton(
          color: const Color(0xFF6BD98B),
          icon: Icons.add_rounded,
          onPressed: onIncomePressed,
        ),
      ],
    );
  }
}

class _CircularActionButton extends StatelessWidget {
  const _CircularActionButton({
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  final Color color;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 190,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: const CircleBorder(),
          side: BorderSide(color: color, width: 8),
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
        ),
        child: Icon(
          icon,
          color: color,
          size: 84,
        ),
      ),
    );
  }
}
