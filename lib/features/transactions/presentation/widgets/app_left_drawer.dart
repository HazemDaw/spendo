import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

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
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            DrawerHeader(
              margin: EdgeInsets.zero,
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.drawerUserName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.drawerUserEmail,
                    style: const TextStyle(
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
                              title: Text(_periodLabel(period, l10n)),
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
                    title: Text(l10n.drawerAllAccounts),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showPlaceholderDialog(
                      context,
                      message: l10n.featureComingSoonMessage,
                      okLabel: l10n.commonOk,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.pie_chart,
                      color: AppColors.primary,
                    ),
                    title: Text(l10n.drawerBudget),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showPlaceholderDialog(
                      context,
                      message: l10n.featureComingSoonMessage,
                      okLabel: l10n.commonOk,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (BuildContext context, AuthState state) {
                final bool isAuthenticated = state is AuthAuthenticated;
                return ListTile(
                  leading: Icon(
                    isAuthenticated ? Icons.cloud_done : Icons.cloud_off,
                    color: isAuthenticated
                        ? AppColors.income
                        : AppColors.textSecondary,
                  ),
                  title: Text(l10n.syncTitle),
                  subtitle: Text(
                    isAuthenticated
                        ? l10n.syncSyncedSubtitle
                        : l10n.syncLocalOnlySubtitle,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static String _periodLabel(
    TransactionPeriod period,
    AppLocalizations l10n,
  ) {
    return switch (period) {
      TransactionPeriod.day => l10n.periodToday,
      TransactionPeriod.week => l10n.periodWeek,
      TransactionPeriod.month => l10n.periodMonth,
    };
  }

  Future<void> _showPlaceholderDialog(
    BuildContext context, {
    required String message,
    required String okLabel,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(okLabel),
            ),
          ],
        );
      },
    );
  }
}
