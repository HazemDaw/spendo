import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/category_localizer.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../categories/data/custom_category_access.dart';
import '../../../categories/domain/entities/category.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_state.dart';
import '../widgets/transaction_list_item.dart';

class AllTransactionsPage extends StatefulWidget {
  const AllTransactionsPage({
    super.key,
    required this.initialTransactions,
  });

  final List<Transaction> initialTransactions;

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  static const String _incomeSectionKey = '__income__';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return BlocListener<TransactionBloc, TransactionState>(
      listener: (BuildContext context, TransactionState state) {
        if (state is TransactionError &&
            (ModalRoute.of(context)?.isCurrent ?? false)) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(l10n.allTransactionsTitle),
        ),
        body: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (BuildContext context, TransactionState state) {
            final List<Transaction> transactions = state is TransactionLoaded
                ? state.transactions
                : widget.initialTransactions;
            final List<_CategorySection> sections = _buildSections(
              l10n,
              transactions,
            );

            if (sections.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noTransactions,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: sections.length,
              separatorBuilder: (_, __) => const Divider(height: 32),
              itemBuilder: (BuildContext context, int index) {
                final _CategorySection section = sections[index];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Row(
                        children: <Widget>[
                          Icon(section.icon, color: section.iconColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              section.title,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            CurrencyFormatter.format(section.total),
                            style: TextStyle(
                              color: section.isIncome
                                  ? AppColors.income
                                  : AppColors.expense,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...section.transactions.map(
                      (Transaction transaction) => TransactionListItem(
                        transaction: transaction,
                        onTap: () => _openTransaction(transaction),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<_CategorySection> _buildSections(
    AppLocalizations l10n,
    List<Transaction> transactions,
  ) {
    final Map<String, List<Transaction>> transactionsBySection =
        <String, List<Transaction>>{};

    for (final Transaction transaction in transactions) {
      final String sectionKey = transaction.categoryKey ?? _incomeSectionKey;
      transactionsBySection.putIfAbsent(sectionKey, () => <Transaction>[]);
      transactionsBySection[sectionKey]!.add(transaction);
    }

    final List<_CategorySection> sections = transactionsBySection.entries.map(
      (MapEntry<String, List<Transaction>> entry) {
        final bool isIncome = entry.key == _incomeSectionKey;
        final List<Transaction> sectionTransactions = List<Transaction>.from(
          entry.value,
        )..sort(
            (Transaction a, Transaction b) => b.date.compareTo(a.date),
          );
        final double total = sectionTransactions.fold<double>(
          0,
          (double sum, Transaction transaction) => sum + transaction.amount,
        );

        if (isIncome) {
          return _CategorySection(
            title: l10n.incomeSectionTitle,
            icon: Icons.arrow_upward,
            iconColor: AppColors.income,
            isIncome: true,
            total: total,
            transactions: sectionTransactions,
          );
        }

        final Category? category =
            maybeCustomCategoryStore()?.resolveCategory(entry.key);

        return _CategorySection(
          title: category == null
              ? entry.key
              : CategoryLocalizer.label(l10n, category),
          icon: category?.icon ?? Icons.payments_outlined,
          iconColor: category?.color ?? AppColors.primary,
          isIncome: false,
          total: total,
          transactions: sectionTransactions,
        );
      },
    ).toList()
      ..sort(
        (_CategorySection a, _CategorySection b) =>
            b.total.abs().compareTo(a.total.abs()),
      );

    return sections;
  }

  Future<void> _openTransaction(Transaction transaction) async {
    final Object? result = await context.pushNamed(
      'editTransaction',
      pathParameters: <String, String>{
        'transactionId': transaction.id,
      },
    );
    if (!mounted) {
      return;
    }
    _showResult(result);
  }

  void _showResult(Object? result) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String? message = switch (result) {
      'deleted' => l10n.transactionDeletedMessage,
      _ => null,
    };

    if (message == null) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CategorySection {
  const _CategorySection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.isIncome,
    required this.total,
    required this.transactions,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final bool isIncome;
  final double total;
  final List<Transaction> transactions;
}
