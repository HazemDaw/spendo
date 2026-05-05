import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/currency/currency_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../transactions/domain/entities/transaction.dart';
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

          final InsightsLoaded loadedState = state as InsightsLoaded;
          final List<InsightCardData> insights = loadedState.insights;
          final _DailySpendingChartData? chartData =
              _DailySpendingChartData.build(
            transactions: loadedState.currentTransactions,
            range: loadedState.currentRange,
            period: loadedState.period,
            locale: Localizations.localeOf(context).languageCode,
          );
          final int itemCount = insights.length + (chartData == null ? 0 : 1);

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (BuildContext context, int index) {
              if (index < insights.length) {
                return _InsightCard(data: insights[index]);
              }
              return _DailySpendingChartCard(
                data: chartData!,
                title: chartData.usesMonthlyBuckets
                    ? l10n.insightsMonthlySpendingTitle
                    : l10n.insightsDailySpendingTitle,
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: itemCount,
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

class _DailySpendingChartCard extends StatelessWidget {
  const _DailySpendingChartCard({
    required this.data,
    required this.title,
  });

  final _DailySpendingChartData data;
  final String title;

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;
    final String currencySymbol = context.watch<CurrencyCubit>().state;
    final String locale = Localizations.localeOf(context).languageCode;
    final Color backgroundColor =
        isDark ? const Color(0xFF2D2640) : Colors.white;
    final Color textColor = isDark ? Colors.white : AppColors.textPrimary;
    final Color axisColor = isDark ? Colors.white70 : AppColors.textSecondary;
    final Color gridColor =
        Theme.of(context).dividerColor.withValues(alpha: 0.50);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      color: backgroundColor,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.20 : 0.08),
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: Color(0xFF7C3AED), width: 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 300,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double bucketWidth =
                      data.usesMonthlyBuckets ? 44.0 : 32.0;
                  final double chartWidth = math.max(
                    constraints.maxWidth,
                    data.entries.length * bucketWidth,
                  );

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: chartWidth,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: BarChart(
                          _barChartData(
                            data: data,
                            isDark: isDark,
                            currencySymbol: currencySymbol,
                            locale: locale,
                            axisColor: axisColor,
                            gridColor: gridColor,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartData _barChartData({
    required _DailySpendingChartData data,
    required bool isDark,
    required String currencySymbol,
    required String locale,
    required Color axisColor,
    required Color gridColor,
  }) {
    return BarChartData(
      minY: 0,
      maxY: data.maxY,
      alignment: BarChartAlignment.spaceAround,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipRoundedRadius: 6,
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          tooltipMargin: 8,
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipColor: (_) =>
              isDark ? const Color(0xFF111827) : AppColors.textPrimary,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            final int index = group.x;
            if (index < 0 || index >= data.entries.length) {
              return null;
            }
            final String amount = CurrencyFormatter.format(
              data.entries[index].amount,
              symbol: currencySymbol,
            );
            return BarTooltipItem(
              amount,
              const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            );
          },
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: data.yInterval,
        getDrawingHorizontalLine: (double value) {
          if (value <= 0 || value >= data.maxY) {
            return const FlLine(
              color: Colors.transparent,
              strokeWidth: 0,
            );
          }
          return FlLine(
            color: gridColor,
            strokeWidth: 1,
          );
        },
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 64,
            interval: data.yInterval,
            getTitlesWidget: (double value, TitleMeta meta) {
              if (value < 0 || value > data.maxY) {
                return const SizedBox.shrink();
              }
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 6,
                fitInside: SideTitleFitInsideData.fromTitleMeta(
                  meta,
                  distanceFromEdge: 8,
                ),
                child: Text(
                  _formatAxisAmount(value, currencySymbol, locale),
                  style: TextStyle(
                    color: axisColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: 1,
            getTitlesWidget: (double value, TitleMeta meta) {
              final int index = value.round();
              if ((value - index).abs() > 0.01 ||
                  index < 0 ||
                  index >= data.entries.length) {
                return const SizedBox.shrink();
              }
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 7,
                child: Text(
                  data.entries[index].label,
                  style: TextStyle(
                    color: axisColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      barGroups: List<BarChartGroupData>.generate(
        data.entries.length,
        (int index) {
          final bool isHighest = index == data.highestIndex;
          return BarChartGroupData(
            x: index,
            barRods: <BarChartRodData>[
              BarChartRodData(
                toY: data.entries[index].amount,
                gradient: _barGradient(
                  isHighest
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF7C3AED),
                ),
                width: data.usesMonthlyBuckets ? 22 : 16,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  LinearGradient _barGradient(Color color) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[
        color,
        color.withValues(alpha: 0.40),
      ],
    );
  }
}

class _DailySpendingChartData {
  const _DailySpendingChartData({
    required this.entries,
    required this.highestIndex,
    required this.maxY,
    required this.yInterval,
    required this.usesMonthlyBuckets,
  });

  final List<_DailySpendingChartEntry> entries;
  final int highestIndex;
  final double maxY;
  final double yInterval;
  final bool usesMonthlyBuckets;

  static _DailySpendingChartData? build({
    required List<Transaction> transactions,
    required TransactionDateRange? range,
    required TransactionPeriod? period,
    required String locale,
  }) {
    if (range == null || period == null) {
      return null;
    }

    final List<Transaction> expenseTransactions = transactions
        .where(
          (Transaction transaction) =>
              transaction.type == TransactionType.expense,
        )
        .toList(growable: false);
    if (expenseTransactions.isEmpty) {
      return null;
    }

    final DateTime rangeStart = _dateOnly(range.start);
    final DateTime rangeEnd = _dateOnly(range.end);
    final DateTime start = rangeStart.isAfter(rangeEnd) ? rangeEnd : rangeStart;
    final DateTime end = rangeStart.isAfter(rangeEnd) ? rangeStart : rangeEnd;
    final bool usesMonthlyBuckets = _usesMonthlyBuckets(
      period: period,
      start: start,
      end: end,
    );
    final String intlLocale = locale == 'ru' ? 'ru_RU' : 'en_US';
    final List<_DailySpendingChartEntry> entries = usesMonthlyBuckets
        ? _monthlyEntries(
            transactions: expenseTransactions,
            start: start,
            end: end,
            period: period,
            intlLocale: intlLocale,
          )
        : _dailyEntries(
            transactions: expenseTransactions,
            start: start,
            end: end,
          );

    if (entries.isEmpty) {
      return null;
    }

    int highestIndex = 0;
    double maxAmount = entries.first.amount;
    for (int index = 1; index < entries.length; index += 1) {
      if (entries[index].amount > maxAmount) {
        highestIndex = index;
        maxAmount = entries[index].amount;
      }
    }

    if (maxAmount <= 0) {
      return null;
    }

    final double maxY = maxAmount * 1.25;
    final double yInterval = _niceInterval(maxY);
    return _DailySpendingChartData(
      entries: entries,
      highestIndex: highestIndex,
      maxY: maxY,
      yInterval: yInterval,
      usesMonthlyBuckets: usesMonthlyBuckets,
    );
  }

  static bool _usesMonthlyBuckets({
    required TransactionPeriod period,
    required DateTime start,
    required DateTime end,
  }) {
    return switch (period) {
      TransactionPeriod.day ||
      TransactionPeriod.week ||
      TransactionPeriod.month =>
        false,
      TransactionPeriod.year || TransactionPeriod.all => true,
      TransactionPeriod.interval => end.difference(start).inDays + 1 > 31,
    };
  }

  static List<_DailySpendingChartEntry> _dailyEntries({
    required List<Transaction> transactions,
    required DateTime start,
    required DateTime end,
  }) {
    final Map<DateTime, double> totals = <DateTime, double>{};
    for (DateTime date = start;
        !date.isAfter(end);
        date = date.add(const Duration(days: 1))) {
      totals[date] = 0;
    }

    for (final Transaction transaction in transactions) {
      final DateTime date = _dateOnly(transaction.date);
      if (!totals.containsKey(date)) {
        continue;
      }
      totals[date] = totals[date]! + transaction.amount;
    }

    return totals.entries
        .map(
          (MapEntry<DateTime, double> entry) => _DailySpendingChartEntry(
            label: entry.key.day.toString(),
            amount: entry.value,
          ),
        )
        .toList(growable: false);
  }

  static List<_DailySpendingChartEntry> _monthlyEntries({
    required List<Transaction> transactions,
    required DateTime start,
    required DateTime end,
    required TransactionPeriod period,
    required String intlLocale,
  }) {
    final DateFormat monthFormatter = DateFormat.MMM(intlLocale);
    final bool aggregateByMonthOfYear = period == TransactionPeriod.all;
    final List<DateTime> buckets = <DateTime>[];

    if (aggregateByMonthOfYear || period == TransactionPeriod.year) {
      final int year = period == TransactionPeriod.year ? start.year : 2024;
      for (int month = 1; month <= 12; month += 1) {
        buckets.add(DateTime(year, month));
      }
    } else {
      final DateTime endMonth = DateTime(end.year, end.month);
      for (DateTime month = DateTime(start.year, start.month);
          !month.isAfter(endMonth);
          month = DateTime(month.year, month.month + 1)) {
        buckets.add(month);
      }
    }

    final Map<DateTime, double> totals = <DateTime, double>{
      for (final DateTime bucket in buckets) bucket: 0,
    };

    for (final Transaction transaction in transactions) {
      final DateTime key = aggregateByMonthOfYear
          ? DateTime(2024, transaction.date.month)
          : DateTime(transaction.date.year, transaction.date.month);
      if (!totals.containsKey(key)) {
        continue;
      }
      totals[key] = totals[key]! + transaction.amount;
    }

    return buckets
        .map(
          (DateTime bucket) => _DailySpendingChartEntry(
            label: monthFormatter.format(bucket),
            amount: totals[bucket] ?? 0,
          ),
        )
        .toList(growable: false);
  }

  static double _niceInterval(double maxAmount) {
    if (maxAmount <= 0) {
      return 1;
    }

    final double roughInterval = maxAmount / 3;
    final double magnitude = math
        .pow(
          10,
          (math.log(roughInterval) / math.ln10).floor(),
        )
        .toDouble();
    final double residual = roughInterval / magnitude;
    final double niceMultiplier = residual <= 1
        ? 1
        : residual <= 2
            ? 2
            : residual <= 5
                ? 5
                : 10;
    return niceMultiplier * magnitude;
  }
}

class _DailySpendingChartEntry {
  const _DailySpendingChartEntry({
    required this.label,
    required this.amount,
  });

  final String label;
  final double amount;
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

String _formatAxisAmount(double value, String symbol, String locale) {
  final String intlLocale = locale == 'ru' ? 'ru_RU' : 'en_US';
  final bool hasFraction = (value - value.roundToDouble()).abs() > 0.01;
  return NumberFormat.compactCurrency(
    locale: intlLocale,
    symbol: symbol,
    decimalDigits: hasFraction ? 1 : 0,
  ).format(value);
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
