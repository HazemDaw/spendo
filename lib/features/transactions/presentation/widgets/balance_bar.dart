import 'package:flutter/material.dart';

class BalanceBar extends StatelessWidget {
  const BalanceBar({
    super.key,
    required this.balanceText,
    this.onTap,
  });

  final String balanceText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const _BalanceHandle(),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 410,
            height: 76,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFE817F),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: const Color(0x88764340),
                width: 2,
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x332D2E2D),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              'Balance  $balanceText',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const _BalanceHandle(),
      ],
    );
  }
}

class _BalanceHandle extends StatelessWidget {
  const _BalanceHandle();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 76,
      child: Column(
        children: <Widget>[
          _HandleLine(width: 74),
          SizedBox(height: 8),
          _HandleLine(width: 58),
          SizedBox(height: 8),
          _HandleLine(width: 74),
        ],
      ),
    );
  }
}

class _HandleLine extends StatelessWidget {
  const _HandleLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 3,
      decoration: BoxDecoration(
        color: const Color(0xFFA7D0C3),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
