import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/category_localizer.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../categories/domain/entities/category.dart';
import '../../domain/entities/transaction.dart';
import '../widgets/balance_bar.dart';
import '../widgets/category_icon_button.dart';
import '../widgets/connector_lines_painter.dart';
import '../widgets/donut_chart_widget.dart';
import '../widgets/home_action_buttons.dart';
import '../widgets/period_filter_chips.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double _orbitBoxSize = 360;
  static const double _chartInset = 80;
  static const double _chartOuterRadius = 100;
  static const double _iconOrbitRadius = 158;
  static const double _iconTapTarget = 40;
  static const double _iconVerticalOffset = 12;

  TransactionPeriod _selectedPeriod = TransactionPeriod.day;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<Transaction> filteredTransactions = MockData.sampleTransactions
        .where(
          (Transaction transaction) =>
              AppDateUtils.matchesPeriod(transaction.date, _selectedPeriod),
        )
        .toList();

    final double income = filteredTransactions
        .where((Transaction transaction) =>
            transaction.type == TransactionType.income)
        .fold(0,
            (double sum, Transaction transaction) => sum + transaction.amount);
    final double expense = filteredTransactions
        .where((Transaction transaction) =>
            transaction.type == TransactionType.expense)
        .fold(0,
            (double sum, Transaction transaction) => sum + transaction.amount);
    final Map<String, double> expenseTotals = _buildExpenseTotals();
    final List<DonutCategorySlice> slices = _buildSlices();
    final double totalExpense = expenseTotals.values.fold(
      0,
      (double sum, double value) => sum + value,
    );
    final List<double> angles = List<double>.generate(
      MockData.categories.length,
      (int index) => ((2 * math.pi) / MockData.categories.length) * index -
          (math.pi / 2),
    );
    final List<bool> hasSpending = MockData.categories
        .map((Category category) => (expenseTotals[category.key] ?? 0) > 0)
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu_rounded),
            );
          },
        ),
        title: Text(l10n.appTitle),
        actions: <Widget>[
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                icon: const Icon(Icons.tune_rounded),
              );
            },
          ),
        ],
      ),
      drawer: const _PhaseDrawer(icon: Icons.person_outline),
      endDrawer: const _PhaseDrawer(icon: Icons.settings_outlined),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: PeriodFilterChips(
                          selectedPeriod: _selectedPeriod,
                          labels: <TransactionPeriod, String>{
                            TransactionPeriod.day: l10n.periodToday,
                            TransactionPeriod.week: l10n.periodWeek,
                            TransactionPeriod.month: l10n.periodMonth,
                          },
                          onSelected: (TransactionPeriod period) {
                            setState(() {
                              _selectedPeriod = period;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: SizedBox(
                          width: _orbitBoxSize,
                          height: _orbitBoxSize,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              Positioned.fill(
                                left: _chartInset,
                                right: _chartInset,
                                top: _chartInset,
                                bottom: _chartInset,
                                child: DonutChartWidget(
                                  slices: slices,
                                  income: income,
                                  expense: expense,
                                  onSliceTap: (String categoryKey) {
                                    context.pushNamed(
                                      'transactionList',
                                      pathParameters: <String, String>{
                                        'categoryKey': categoryKey,
                                      },
                                    );
                                  },
                                ),
                              ),
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: ConnectorLinesPainter(
                                    angles: angles,
                                    hasSpending: hasSpending,
                                    center: const Offset(180, 180),
                                    chartOuterRadius: _chartOuterRadius,
                                    iconOrbitRadius: _iconOrbitRadius,
                                  ),
                                ),
                              ),
                              for (int index = 0;
                                  index < MockData.categories.length;
                                  index++)
                                _buildCategoryIcon(
                                  context: context,
                                  category: MockData.categories[index],
                                  angle: angles[index],
                                  amount:
                                      expenseTotals[MockData.categories[index].key] ??
                                          0,
                                  totalExpense: totalExpense,
                                  onPressed: () {
                                    context.pushNamed(
                                      'addTransaction',
                                      queryParameters: <String, String>{
                                        'type': 'expense',
                                        'categoryKey':
                                            MockData.categories[index].key,
                                      },
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      BalanceBar(
                        label: l10n.balanceLabel,
                        balance: income - expense,
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: HomeActionButtons(
                          expenseLabel: l10n.actionExpense,
                          incomeLabel: l10n.actionIncome,
                          onExpensePressed: () {
                            context.pushNamed(
                              'addTransaction',
                              queryParameters: const <String, String>{
                                'type': 'expense',
                              },
                            );
                          },
                          onIncomePressed: () {
                            context.pushNamed(
                              'addTransaction',
                              queryParameters: const <String, String>{
                                'type': 'income',
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Positioned _buildCategoryIcon({
    required BuildContext context,
    required Category category,
    required double angle,
    required double amount,
    required double totalExpense,
    required VoidCallback onPressed,
  }) {
    final double iconCenterX = 180 + (_iconOrbitRadius * math.cos(angle));
    final double iconCenterY = 180 + (_iconOrbitRadius * math.sin(angle));
    final bool hasSpending = amount > 0;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String label = hasSpending && totalExpense > 0
        ? '${((amount / totalExpense) * 100).round()}%'
        : CategoryLocalizer.label(l10n, category);

    return Positioned(
      left: iconCenterX - (_iconTapTarget / 2),
      top: iconCenterY - (_iconTapTarget / 2) - _iconVerticalOffset,
      child: CategoryIconButton(
        category: category,
        onPressed: onPressed,
        showContainer: false,
        width: _iconTapTarget,
        containerSize: _iconTapTarget,
        iconSize: 26,
        iconOpacity: hasSpending ? 1 : 0.35,
        label: label,
        labelMaxLines: 1,
        labelOverflow: TextOverflow.visible,
        labelSoftWrap: false,
        labelOffset: 4,
        labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
      ),
    );
  }

  Map<String, double> _buildExpenseTotals() {
    final Iterable<Transaction> expenseTransactions =
        MockData.sampleTransactions.where(
      (Transaction transaction) =>
          transaction.type == TransactionType.expense &&
          AppDateUtils.matchesPeriod(transaction.date, _selectedPeriod),
    );

    final Map<String, double> totals = <String, double>{};
    for (final Transaction transaction in expenseTransactions) {
      final String? categoryKey = transaction.categoryKey;
      if (categoryKey == null) {
        continue;
      }

      totals.update(
        categoryKey,
        (double value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    return totals;
  }

  List<DonutCategorySlice> _buildSlices() {
    final Map<String, double> totals = _buildExpenseTotals();

    return MockData.categories
        .where((category) => totals.containsKey(category.key))
        .map(
          (category) => DonutCategorySlice(
            categoryKey: category.key,
            value: totals[category.key]!,
            color: category.color,
          ),
        )
        .toList();
  }
}

class _PhaseDrawer extends StatelessWidget {
  const _PhaseDrawer({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(height: 16),
              Text(
                l10n.drawerStub,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
