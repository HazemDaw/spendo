import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/currency/currency_cubit.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/category_localizer.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/transaction_delete_undo_snackbar.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({
    super.key,
    required this.categoryKey,
  });

  final String categoryKey;

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  @override
  void initState() {
    super.initState();
    final TransactionState state = context.read<TransactionBloc>().state;
    if (state is TransactionInitial) {
      context
          .read<TransactionBloc>()
          .add(const LoadTransactionsEvent(TransactionPeriod.month));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String currencySymbol = context.watch<CurrencyCubit>().state;
    final category = MockData.categoryByKey(widget.categoryKey);

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
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                category?.icon ?? Icons.payments_outlined,
                color: category?.color ?? AppColors.primary,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  category == null
                      ? l10n.appTitle
                      : CategoryLocalizer.label(l10n, category),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        body: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (BuildContext context, TransactionState state) {
            if (state is TransactionInitial || state is TransactionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is! TransactionLoaded) {
              return const SizedBox.shrink();
            }

            final List<Transaction> transactions = state.transactions
                .where((Transaction transaction) =>
                    transaction.categoryKey == widget.categoryKey)
                .toList()
              ..sort(
                (Transaction a, Transaction b) => b.date.compareTo(a.date),
              );
            final double total = transactions.fold<double>(
              0,
              (double sum, Transaction transaction) => sum + transaction.amount,
            );

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.totalExpenseLabel,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          CurrencyFormatter.format(
                            total,
                            symbol: currencySymbol,
                          ),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (transactions.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              category?.icon ?? Icons.inbox_outlined,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.noTransactionsInCategory,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: transactions.length,
                        separatorBuilder: (_, __) => const Divider(height: 24),
                        itemBuilder: (BuildContext context, int index) {
                          final Transaction transaction = transactions[index];
                          return TransactionListItem(
                            transaction: transaction,
                            onTap: () async {
                              final Object? result = await context.pushNamed(
                                'editTransaction',
                                pathParameters: <String, String>{
                                  'transactionId': transaction.id,
                                },
                              );
                              if (!mounted) {
                                return;
                              }
                              _showResult(result, transaction);
                            },
                          );
                        },
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

  void _showResult(Object? result, Transaction fallbackTransaction) {
    final Transaction? deletedTransaction = switch (result) {
      TransactionDeleteResult(:final transaction) => transaction,
      'deleted' => fallbackTransaction,
      _ => null,
    };
    if (deletedTransaction != null) {
      showTransactionDeletedUndoSnackBar(context, deletedTransaction);
    }
  }
}
