import 'package:flutter_test/flutter_test.dart';
import 'package:spendo/core/utils/date_utils.dart';
import 'package:spendo/features/transactions/domain/entities/transaction.dart';
import 'package:spendo/features/transactions/domain/usecases/add_transaction.dart';
import 'package:spendo/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:spendo/features/transactions/domain/usecases/get_transactions_by_period.dart';
import 'package:spendo/features/transactions/domain/usecases/update_transaction.dart';
import 'package:spendo/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:spendo/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:spendo/features/transactions/presentation/bloc/transaction_state.dart';

import '../../../../helpers/in_memory_transaction_repository.dart';

void main() {
  test('add, update, and delete reload the current period', () async {
    final Transaction initialExpense = Transaction(
      id: 'expense-1',
      amount: 120,
      categoryKey: 'food',
      type: TransactionType.expense,
      date: DateTime.now(),
      note: 'Lunch',
    );
    final InMemoryTransactionRepository repository =
        InMemoryTransactionRepository(
          seedTransactions: <Transaction>[initialExpense],
        );
    final TransactionBloc bloc = TransactionBloc(
      addTransaction: AddTransaction(repository),
      getTransactionsByPeriod: GetTransactionsByPeriod(repository),
      updateTransaction: UpdateTransaction(repository),
      deleteTransaction: DeleteTransaction(repository),
    );
    addTearDown(bloc.close);

    final TransactionLoaded initialLoaded = await _dispatchAndWaitForLoaded(
      bloc,
      const LoadTransactionsEvent(TransactionPeriod.month),
    );
    expect(initialLoaded.transactions, hasLength(1));
    expect(initialLoaded.totalExpense, 120);
    expect(initialLoaded.totalIncome, 0);
    expect(initialLoaded.categoryTotals['food'], 120);

    final TransactionLoaded afterAdd = await _dispatchAndWaitForLoaded(
      bloc,
      AddTransactionEvent(
        Transaction(
          id: 'income-1',
          amount: 900,
          type: TransactionType.income,
          date: DateTime.now(),
          note: 'Salary',
        ),
      ),
    );
    expect(afterAdd.transactions, hasLength(2));
    expect(afterAdd.totalIncome, 900);
    expect(afterAdd.totalExpense, 120);

    final TransactionLoaded afterUpdate = await _dispatchAndWaitForLoaded(
      bloc,
      UpdateTransactionEvent(
        Transaction(
          id: 'expense-1',
          amount: 200,
          categoryKey: 'food',
          type: TransactionType.expense,
          date: initialExpense.date,
          note: 'Lunch and coffee',
        ),
      ),
    );
    expect(afterUpdate.totalExpense, 200);
    expect(afterUpdate.categoryTotals['food'], 200);
    expect(
      afterUpdate.transactions
          .singleWhere((Transaction transaction) => transaction.id == 'expense-1')
          .note,
      'Lunch and coffee',
    );

    final TransactionLoaded afterDelete = await _dispatchAndWaitForLoaded(
      bloc,
      const DeleteTransactionEvent('expense-1'),
    );
    expect(afterDelete.transactions, hasLength(1));
    expect(afterDelete.totalExpense, 0);
    expect(afterDelete.totalIncome, 900);
    expect(afterDelete.categoryTotals.containsKey('food'), isFalse);
  });
}

Future<TransactionLoaded> _dispatchAndWaitForLoaded(
  TransactionBloc bloc,
  TransactionEvent event,
) async {
  final Future<TransactionLoaded> nextLoaded = bloc.stream
      .where((TransactionState state) => state is TransactionLoaded)
      .cast<TransactionLoaded>()
      .first;
  bloc.add(event);
  return nextLoaded;
}
