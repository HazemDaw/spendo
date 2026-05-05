import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/category_localizer.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../budget/domain/entities/budget.dart';
import '../../../budget/domain/repositories/budget_repository.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';

class InsightsCubit extends Cubit<InsightsState> {
  InsightsCubit({
    required TransactionRepository transactionRepository,
    required BudgetRepository budgetRepository,
  })  : _transactionRepository = transactionRepository,
        _budgetRepository = budgetRepository,
        super(const InsightsInitial());

  final TransactionRepository _transactionRepository;
  final BudgetRepository _budgetRepository;

  Future<void> load({
    required TransactionPeriod period,
    required DateTime referenceDate,
    required AppLocalizations l10n,
    required String locale,
    required String currencySymbol,
    DateTime? intervalStart,
    DateTime? intervalEnd,
  }) async {
    emit(const InsightsLoading());

    final TransactionDateRange currentRange = AppDateUtils.getPeriodRange(
      period,
      referenceDate: referenceDate,
      intervalStart: intervalStart,
      intervalEnd: intervalEnd,
    );
    final TransactionDateRange previousRange = _previousRange(
      period: period,
      referenceDate: referenceDate,
      currentRange: currentRange,
    );

    final _Result<List<Transaction>> currentResult =
        await _transactionsForRange(currentRange);
    final _Result<List<Transaction>> previousResult =
        await _transactionsForRange(previousRange);
    final _Result<List<Budget>> budgetsResult = await _budgetsForMonth(
      referenceDate.month,
      referenceDate.year,
    );

    final Failure? failure =
        currentResult.failure ?? previousResult.failure ?? budgetsResult.failure;
    if (failure != null) {
      emit(InsightsError(failure.message));
      return;
    }

    final List<Transaction> currentTransactions =
        currentResult.value ?? const <Transaction>[];
    if (currentTransactions.isEmpty) {
      emit(const InsightsLoaded(insights: <InsightCardData>[]));
      return;
    }

    final List<Transaction> previousTransactions =
        previousResult.value ?? const <Transaction>[];
    final List<Budget> budgets = budgetsResult.value ?? const <Budget>[];
    emit(
      InsightsLoaded(
        insights: <InsightCardData>[
          _largestExpenseCategoryInsight(
            currentTransactions,
            l10n,
            currencySymbol,
          ),
          _spendingTrendInsight(
            currentTransactions,
            previousTransactions,
            l10n,
            currencySymbol,
          ),
          _mostExpensiveDayInsight(currentTransactions, l10n, locale),
          _budgetStatusInsight(
            currentTransactions,
            budgets,
            l10n,
            currencySymbol,
          ),
        ],
      ),
    );
  }

  Future<_Result<List<Transaction>>> _transactionsForRange(
    TransactionDateRange range,
  ) async {
    final result = await _transactionRepository.getTransactionsByPeriod(
      range.start,
      range.end,
    );
    return result.fold(
      (Failure failure) => _Result<List<Transaction>>(failure: failure),
      (List<Transaction> transactions) =>
          _Result<List<Transaction>>(value: transactions),
    );
  }

  Future<_Result<List<Budget>>> _budgetsForMonth(int month, int year) async {
    final result = await _budgetRepository.getBudgets(month, year);
    return result.fold(
      (Failure failure) => _Result<List<Budget>>(failure: failure),
      (List<Budget> budgets) => _Result<List<Budget>>(value: budgets),
    );
  }

  InsightCardData _largestExpenseCategoryInsight(
    List<Transaction> transactions,
    AppLocalizations l10n,
    String currencySymbol,
  ) {
    final Map<String, double> categoryTotals = <String, double>{};
    for (final Transaction transaction in transactions) {
      if (transaction.type != TransactionType.expense ||
          transaction.categoryKey == null) {
        continue;
      }
      categoryTotals.update(
        transaction.categoryKey!,
        (double total) => total + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    if (categoryTotals.isEmpty) {
      return InsightCardData(
        icon: Icons.pie_chart_outline_rounded,
        iconColor: AppColors.primary,
        title: l10n.insightLargestCategoryTitle,
        description: l10n.insightNoExpensesThisPeriod,
      );
    }

    final MapEntry<String, double> largest = categoryTotals.entries.reduce(
      (MapEntry<String, double> a, MapEntry<String, double> b) =>
          a.value >= b.value ? a : b,
    );
    return InsightCardData(
      icon: Icons.pie_chart_outline_rounded,
      iconColor: AppColors.primary,
      title: l10n.insightLargestCategoryTitle,
      description: l10n.insightLargestCategoryDescription(
        _categoryLabel(largest.key, l10n),
        CurrencyFormatter.format(largest.value, symbol: currencySymbol),
      ),
    );
  }

  InsightCardData _spendingTrendInsight(
    List<Transaction> currentTransactions,
    List<Transaction> previousTransactions,
    AppLocalizations l10n,
    String currencySymbol,
  ) {
    final double currentExpense = _expenseTotal(currentTransactions);
    final double previousExpense = _expenseTotal(previousTransactions);
    IconData icon = Icons.trending_flat_rounded;
    String description = l10n.insightSpentSame;

    if (previousExpense == 0 && currentExpense > 0) {
      icon = Icons.trending_up_rounded;
      description = l10n.insightNoPreviousExpenses(
        CurrencyFormatter.format(currentExpense, symbol: currencySymbol),
      );
    } else if (previousExpense > 0) {
      final int percent =
          (((currentExpense - previousExpense).abs() / previousExpense) * 100)
              .round();
      if (currentExpense > previousExpense) {
        icon = Icons.trending_up_rounded;
        description = l10n.insightSpentMore(percent);
      } else if (currentExpense < previousExpense) {
        icon = Icons.trending_down_rounded;
        description = l10n.insightSpentLess(percent);
      }
    }

    return InsightCardData(
      icon: icon,
      iconColor: AppColors.primary,
      title: l10n.insightSpendingTrendTitle,
      description: description,
    );
  }

  InsightCardData _mostExpensiveDayInsight(
    List<Transaction> transactions,
    AppLocalizations l10n,
    String locale,
  ) {
    final Map<int, double> weekdayTotals = <int, double>{};
    for (final Transaction transaction in transactions) {
      if (transaction.type != TransactionType.expense) {
        continue;
      }
      weekdayTotals.update(
        transaction.date.weekday,
        (double total) => total + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    if (weekdayTotals.isEmpty) {
      return InsightCardData(
        icon: Icons.calendar_today_outlined,
        iconColor: AppColors.primary,
        title: l10n.insightExpensiveDayTitle,
        description: l10n.insightNoExpenseDay,
      );
    }

    final MapEntry<int, double> mostExpensiveDay = weekdayTotals.entries.reduce(
      (MapEntry<int, double> a, MapEntry<int, double> b) =>
          a.value >= b.value ? a : b,
    );
    final String intlLocale = locale == 'ru' ? 'ru_RU' : 'en_US';
    final String dayName = DateFormat.EEEE(intlLocale).format(
      DateTime(2024, 1, mostExpensiveDay.key),
    );

    return InsightCardData(
      icon: Icons.calendar_today_outlined,
      iconColor: AppColors.primary,
      title: l10n.insightExpensiveDayTitle,
      description: l10n.insightMostExpensiveDay(dayName),
    );
  }

  InsightCardData _budgetStatusInsight(
    List<Transaction> transactions,
    List<Budget> budgets,
    AppLocalizations l10n,
    String currencySymbol,
  ) {
    Budget? totalBudget;
    for (final Budget budget in budgets) {
      if (budget.isTotalBudget) {
        totalBudget = budget;
        break;
      }
    }

    if (totalBudget == null || totalBudget.limitAmount <= 0) {
      return InsightCardData(
        icon: Icons.savings_outlined,
        iconColor: AppColors.primary,
        title: l10n.insightBudgetStatusTitle,
        description: l10n.insightBudgetNotSet,
      );
    }

    final double totalExpense = _expenseTotal(transactions);
    if (totalExpense > totalBudget.limitAmount) {
      return InsightCardData(
        icon: Icons.warning_amber_rounded,
        iconColor: const Color(0xFFEF4444),
        title: l10n.insightBudgetStatusTitle,
        description: l10n.insightBudgetExceeded(
          CurrencyFormatter.format(
            totalExpense - totalBudget.limitAmount,
            symbol: currencySymbol,
          ),
        ),
      );
    }

    return InsightCardData(
      icon: Icons.check_circle_outline_rounded,
      iconColor: const Color(0xFF10B981),
      title: l10n.insightBudgetStatusTitle,
      description: l10n.insightBudgetOnTrack(
        ((totalExpense / totalBudget.limitAmount) * 100).round(),
      ),
    );
  }

  double _expenseTotal(List<Transaction> transactions) {
    return transactions.fold<double>(
      0,
      (double total, Transaction transaction) =>
          transaction.type == TransactionType.expense
              ? total + transaction.amount
              : total,
    );
  }

  String _categoryLabel(String categoryKey, AppLocalizations l10n) {
    final category = MockData.categoryByKey(categoryKey);
    if (category == null) {
      return categoryKey;
    }
    return CategoryLocalizer.label(l10n, category);
  }

  TransactionDateRange _previousRange({
    required TransactionPeriod period,
    required DateTime referenceDate,
    required TransactionDateRange currentRange,
  }) {
    return switch (period) {
      TransactionPeriod.day => AppDateUtils.getPeriodRange(
          period,
          referenceDate: referenceDate.subtract(const Duration(days: 1)),
        ),
      TransactionPeriod.week => AppDateUtils.getPeriodRange(
          period,
          referenceDate: referenceDate.subtract(const Duration(days: 7)),
        ),
      TransactionPeriod.month => AppDateUtils.getPeriodRange(
          period,
          referenceDate: DateTime(referenceDate.year, referenceDate.month - 1),
        ),
      TransactionPeriod.year => AppDateUtils.getPeriodRange(
          period,
          referenceDate: DateTime(referenceDate.year - 1),
        ),
      TransactionPeriod.all => TransactionDateRange(
          start: DateTime(1900),
          end: DateTime(1999, 12, 31, 23, 59, 59),
        ),
      TransactionPeriod.interval => _previousIntervalRange(currentRange),
    };
  }

  TransactionDateRange _previousIntervalRange(TransactionDateRange current) {
    final Duration duration = current.end.difference(current.start);
    final DateTime previousEnd = current.start.subtract(
      const Duration(seconds: 1),
    );
    return TransactionDateRange(
      start: previousEnd.subtract(duration),
      end: previousEnd,
    );
  }
}

class InsightCardData extends Equatable {
  const InsightCardData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  @override
  List<Object?> get props => <Object?>[
        icon,
        iconColor,
        title,
        description,
      ];
}

abstract class InsightsState extends Equatable {
  const InsightsState();

  @override
  List<Object?> get props => <Object?>[];
}

class InsightsInitial extends InsightsState {
  const InsightsInitial();
}

class InsightsLoading extends InsightsState {
  const InsightsLoading();
}

class InsightsLoaded extends InsightsState {
  const InsightsLoaded({
    required this.insights,
  });

  final List<InsightCardData> insights;

  bool get isEmpty => insights.isEmpty;

  @override
  List<Object?> get props => <Object?>[insights];
}

class InsightsError extends InsightsState {
  const InsightsError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

class _Result<T> {
  const _Result({
    this.value,
    this.failure,
  });

  final T? value;
  final Failure? failure;
}
