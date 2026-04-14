import 'package:flutter/material.dart';

class BalanceBar extends StatelessWidget {
  const BalanceBar({
    super.key,
    required this.balanceText,
    this.onTap,
    this.onMenuTap,
  });

  final String balanceText;
  final VoidCallback? onTap;
  final VoidCallback? onMenuTap;

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
        _BalanceHandle(onTap: onMenuTap),
      ],
    );
  }
}

class _BalanceHandle extends StatelessWidget {
  const _BalanceHandle({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: const SizedBox(
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
        color: const Color.fromARGB(255, 175, 60, 221),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
