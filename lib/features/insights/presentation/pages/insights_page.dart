import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/currency/currency_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/insights_cubit.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({
    super.key,
    required this.period,
    required this.referenceDate,
    this.intervalStart,
    this.intervalEnd,
  });

  final TransactionPeriod period;
  final DateTime referenceDate;
  final DateTime? intervalStart;
  final DateTime? intervalEnd;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String locale = Localizations.localeOf(context).languageCode;
    final String currencySymbol = context.read<CurrencyCubit>().state;

    return BlocProvider<InsightsCubit>(
      create: (_) => sl<InsightsCubit>()
        ..load(
          period: period,
          referenceDate: referenceDate,
          intervalStart: intervalStart,
          intervalEnd: intervalEnd,
          l10n: l10n,
          locale: locale,
          currencySymbol: currencySymbol,
        ),
      child: _InsightsView(l10n: l10n),
    );
  }
}

class _InsightsView extends StatelessWidget {
  const _InsightsView({
    required this.l10n,
  });

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(l10n.insightsTitle)),
      body: BlocBuilder<InsightsCubit, InsightsState>(
        builder: (BuildContext context, InsightsState state) {
          if (state is InsightsLoading || state is InsightsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is InsightsError) {
            return _MessageState(
              icon: Icons.error_outline_rounded,
              title: l10n.insightsErrorTitle,
              message: state.message,
            );
          }

          if (state is InsightsLoaded && state.isEmpty) {
            return _MessageState(
              icon: Icons.lightbulb_outline_rounded,
              title: l10n.insightsEmptyTitle,
              message: l10n.insightsEmptyMessage,
            );
          }

          final List<InsightCardData> insights =
              state is InsightsLoaded ? state.insights : const <InsightCardData>[];
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (BuildContext context, int index) {
              return _InsightCard(data: insights[index]);
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: insights.length,
          );
        },
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.data,
  });

  final InsightCardData data;

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;
    final Color backgroundColor =
        isDark ? const Color(0xFF2D2640) : Colors.white;
    final Color textColor = isDark ? Colors.white : AppColors.textPrimary;
    final Color descriptionColor =
        isDark ? Colors.white70 : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(color: Color(0xFF7C3AED), width: 4),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(data.icon, color: data.iconColor, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  data.title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.description,
                  style: TextStyle(
                    color: descriptionColor,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              color: AppColors.primary,
              size: 48,
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : AppColors.textSecondary,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
