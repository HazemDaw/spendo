import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
            BlocBuilder<AuthBloc, AuthState>(
              builder: (BuildContext context, AuthState state) {
                if (state is AuthAuthenticated) {
                  final String emailPrefix = state.email.split('@').first;

                  return DrawerHeader(
                    margin: EdgeInsets.zero,
                    decoration: const BoxDecoration(color: AppColors.primary),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primaryLight,
                          child: Text(
                            state.email[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          state.displayName?.isNotEmpty == true
                              ? state.displayName!
                              : emailPrefix,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          state.email,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return DrawerHeader(
                  margin: EdgeInsets.zero,
                  decoration: const BoxDecoration(color: AppColors.primary),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.push('/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Войдите для синхронизации'),
                      ),
                    ],
                  ),
                );
              },
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
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/budget');
                    },
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
