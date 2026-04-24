import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/category_localizer.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';
import '../../../transactions/presentation/bloc/transaction_state.dart';
import '../../domain/entities/budget.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  static const List<String> _orbitCategoryKeys = <String>[
    'entertainment',
    'clothing',
    'communication',
    'housing',
    'transport',
    'food',
    'sport',
    'health',
  ];

  late final DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<BudgetBloc>().add(
            LoadBudgetsEvent(
              month: _currentMonth.month,
              year: _currentMonth.year,
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final TransactionState transactionState = context.watch<TransactionBloc>().state;
    final Map<String, double> categoryTotals =
        transactionState is TransactionLoaded
            ? transactionState.categoryTotals
            : const <String, double>{};
    final double totalSpent =
        transactionState is TransactionLoaded ? transactionState.totalExpense : 0;

    return BlocListener<BudgetBloc, BudgetState>(
      listener: (BuildContext context, BudgetState state) {
        if (state is BudgetError && (ModalRoute.of(context)?.isCurrent ?? false)) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Бюджет • ${_formatMonthYear(_currentMonth)}'),
        ),
        body: BlocBuilder<BudgetBloc, BudgetState>(
          builder: (BuildContext context, BudgetState state) {
            final List<Budget> budgets =
                state is BudgetLoaded ? state.budgets : const <Budget>[];

            if (state is BudgetLoading && budgets.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildTotalBudgetCard(
                    context: context,
                    budgets: budgets,
                    totalSpent: totalSpent,
                  ),
                  const SizedBox(height: 16),
                  ..._orbitCategoryKeys.map(
                    (String categoryKey) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildCategoryBudgetCard(
                        context: context,
                        l10n: l10n,
                        categoryKey: categoryKey,
                        budgets: budgets,
                        spentAmount: categoryTotals[categoryKey] ?? 0,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTotalBudgetCard({
    required BuildContext context,
    required List<Budget> budgets,
    required double totalSpent,
  }) {
    final Budget? totalBudget = _findBudget(budgets, null);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Общий бюджет',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _showBudgetDialog(
                    context,
                    null,
                    budgets,
                  ),
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
            if (totalBudget != null) ...<Widget>[
              const SizedBox(height: 8),
              _buildProgressBar(
                spent: totalSpent,
                limit: totalBudget.limitAmount,
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Потрачено: ${CurrencyFormatter.format(totalSpent)}',
                      style: const TextStyle(color: AppColors.expense),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Лимит: ${CurrencyFormatter.format(totalBudget.limitAmount)}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Остаток: ${_formatSignedAmount(totalBudget.limitAmount - totalSpent)}',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: totalBudget.limitAmount - totalSpent >= 0
                            ? AppColors.income
                            : AppColors.expense,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...<Widget>[
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _showBudgetDialog(
                  context,
                  null,
                  budgets,
                ),
                child: const Text('Установить общий бюджет'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBudgetCard({
    required BuildContext context,
    required AppLocalizations l10n,
    required String categoryKey,
    required List<Budget> budgets,
    required double spentAmount,
  }) {
    final category = MockData.categoryByKey(categoryKey)!;
    final Budget? budget = _findBudget(budgets, categoryKey);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(category.icon, color: category.color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    CategoryLocalizer.label(l10n, category),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(spentAmount),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(budget != null ? Icons.edit : Icons.add),
                  onPressed: () => _showBudgetDialog(
                    context,
                    categoryKey,
                    budgets,
                  ),
                ),
              ],
            ),
            if (budget != null) ...<Widget>[
              const SizedBox(height: 8),
              _buildProgressBar(
                spent: spentAmount,
                limit: budget.limitAmount,
              ),
              const SizedBox(height: 4),
              Row(
                children: <Widget>[
                  Text(
                    '${_usedPercent(spentAmount, budget.limitAmount)}% использовано',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    'Лимит: ${CurrencyFormatter.format(budget.limitAmount)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar({
    required double spent,
    required double limit,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: (spent / limit).clamp(0.0, 1.0),
        color: _progressColor(spent, limit),
        backgroundColor: AppColors.primaryLight,
        minHeight: 8,
      ),
    );
  }

  Color _progressColor(double spent, double limit) {
    if (spent >= limit) {
      return AppColors.expense;
    }
    if (spent >= limit * 0.8) {
      return Colors.orange;
    }
    return AppColors.primary;
  }

  int _usedPercent(double spent, double limit) {
    if (limit <= 0) {
      return 0;
    }
    return ((spent / limit) * 100).round();
  }

  String _formatMonthYear(DateTime date) {
    final String value = DateFormat('LLLL yyyy', 'ru_RU').format(date);
    if (value.isEmpty) {
      return value;
    }
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  String _formatSignedAmount(double amount) {
    final String formatted = CurrencyFormatter.format(amount.abs());
    return amount.isNegative ? '-$formatted' : formatted;
  }

  Budget? _findBudget(List<Budget> budgets, String? categoryKey) {
    for (final Budget budget in budgets) {
      if (budget.categoryKey == categoryKey) {
        return budget;
      }
    }
    return null;
  }

  String _budgetId(String? categoryKey) {
    return 'budget_${_currentMonth.year}_${_currentMonth.month}_${categoryKey ?? 'total'}';
  }

  Future<void> _showBudgetDialog(
    BuildContext context,
    String? categoryKey,
    List<Budget> budgets,
  ) async {
    final category = MockData.categoryByKey(categoryKey);
    final Budget? existingBudget = _findBudget(budgets, categoryKey);
    String amountInput = existingBudget?.limitAmount.toStringAsFixed(0) ?? '';

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            categoryKey == null
                ? 'Общий бюджет'
                : CategoryLocalizer.label(
                    AppLocalizations.of(context)!,
                    category!,
                  ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                key: ValueKey<String>('budget_amount_$categoryKey'),
                onChanged: (String value) => amountInput = value,
                initialValue: amountInput,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Лимит (₽)',
                  prefixIcon: Icon(Icons.currency_ruble),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            if (existingBudget != null)
              TextButton(
                onPressed: () {
                  context.read<BudgetBloc>().add(
                        DeleteBudgetEvent(id: existingBudget.id),
                      );
                  Navigator.of(dialogContext).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.expense,
                ),
                child: const Text('Удалить'),
              ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                final String rawValue = amountInput.trim().replaceAll(',', '.');
                final double? amount = double.tryParse(rawValue);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Введите лимит больше нуля'),
                      ),
                    );
                  return;
                }

                context.read<BudgetBloc>().add(
                      SetBudgetEvent(
                        budget: Budget(
                          id: existingBudget?.id ?? _budgetId(categoryKey),
                          categoryKey: categoryKey,
                          limitAmount: amount,
                          month: _currentMonth.month,
                          year: _currentMonth.year,
                        ),
                      ),
                    );
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }
}
