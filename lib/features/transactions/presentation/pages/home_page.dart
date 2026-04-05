import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/transaction.dart';
import '../widgets/balance_bar.dart';
import '../widgets/category_icon_orbit.dart';
import '../widgets/donut_chart_widget.dart';
import '../widgets/home_action_buttons.dart';
import '../widgets/period_filter_chips.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    final List<DonutCategorySlice> slices = _buildSlices();

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              PeriodFilterChips(
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
              const SizedBox(height: 24),
              CategoryIconOrbit(
                categories: MockData.categories,
                centerChild: DonutChartWidget(
                  slices: slices,
                  income: income,
                  expense: expense,
                  onSliceTap: (String categoryKey) {
                    context.pushNamed(
                      'transactionList',
                      pathParameters: <String, String>{
                        'categoryKey': categoryKey
                      },
                    );
                  },
                ),
                onCategoryTap: (category) {
                  context.pushNamed(
                    'addTransaction',
                    queryParameters: <String, String>{
                      'type': 'expense',
                      'categoryKey': category.key,
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              BalanceBar(
                label: l10n.balanceLabel,
                balance: income - expense,
              ),
              const SizedBox(height: 20),
              HomeActionButtons(
                expenseLabel: l10n.actionExpense,
                incomeLabel: l10n.actionIncome,
                onExpensePressed: () {
                  context.pushNamed(
                    'addTransaction',
                    queryParameters: const <String, String>{'type': 'expense'},
                  );
                },
                onIncomePressed: () {
                  context.pushNamed(
                    'addTransaction',
                    queryParameters: const <String, String>{'type': 'income'},
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DonutCategorySlice> _buildSlices() {
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
