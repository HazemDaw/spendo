import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';

class AppLeftDrawer extends StatelessWidget {
  const AppLeftDrawer({
    super.key,
    required this.selectedPeriod,
    required this.currentPeriodLabel,
    required this.onPeriodSelected,
  });

  final TransactionPeriod selectedPeriod;
  final String currentPeriodLabel;
  final ValueChanged<TransactionPeriod> onPeriodSelected;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            const DrawerHeader(
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(color: AppColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Spendo User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'user@spendo.app',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  ListTile(
                    leading: const Icon(
                      Icons.calendar_today,
                      color: AppColors.primary,
                    ),
                    title: Text(currentPeriodLabel),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      children: TransactionPeriod.values
                          .map(
                            (TransactionPeriod period) => ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.only(
                                left: 24,
                                right: 16,
                              ),
                              title: Text(_periodLabel(period)),
                              trailing: period == selectedPeriod
                                  ? const Icon(
                                      Icons.check,
                                      color: AppColors.primary,
                                    )
                                  : null,
                              onTap: () {
                                onPeriodSelected(period);
                                Navigator.of(context).pop();
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.primary,
                    ),
                    title: const Text('Все счета'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showPlaceholderDialog(
                      context,
                      'Функция будет доступна позже',
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.pie_chart,
                      color: AppColors.primary,
                    ),
                    title: const Text('Бюджет'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showPlaceholderDialog(
                      context,
                      'Функция будет доступна позже',
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const ListTile(
              leading: Icon(
                Icons.cloud_off,
                color: AppColors.textSecondary,
              ),
              title: Text('Синхронизация'),
              subtitle: Text('Только локально'),
            ),
          ],
        ),
      ),
    );
  }

  static String _periodLabel(TransactionPeriod period) {
    return switch (period) {
      TransactionPeriod.day => 'Сегодня',
      TransactionPeriod.week => 'Неделя',
      TransactionPeriod.month => 'Месяц',
    };
  }

  Future<void> _showPlaceholderDialog(BuildContext context, String message) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
