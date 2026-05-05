import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/get_transactions_by_period.dart';
import '../../domain/usecases/update_transaction.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc({
    required AddTransaction addTransaction,
    required GetTransactionsByPeriod getTransactionsByPeriod,
    required UpdateTransaction updateTransaction,
    required DeleteTransaction deleteTransaction,
  })  : _addTransaction = addTransaction,
        _getTransactionsByPeriod = getTransactionsByPeriod,
        _updateTransaction = updateTransaction,
        _deleteTransaction = deleteTransaction,
        super(const TransactionInitial()) {
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<AddTransactionEvent>(_onAddTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
  }

  final AddTransaction _addTransaction;
  final GetTransactionsByPeriod _getTransactionsByPeriod;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;

  TransactionPeriod _currentPeriod = TransactionPeriod.month;
  DateTime _currentReferenceDate = DateTime.now();
  DateTime? _currentIntervalStart;
  DateTime? _currentIntervalEnd;

  void reloadCurrentPeriod() {
    add(
      LoadTransactionsEvent(
        _currentPeriod,
        referenceDate: _currentReferenceDate,
        intervalStart: _currentIntervalStart,
        intervalEnd: _currentIntervalEnd,
      ),
    );
  }

  Future<void> _onLoadTransactions(
    LoadTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    _currentPeriod = event.period;
    _currentReferenceDate = event.referenceDate ?? DateTime.now();
    _currentIntervalStart = event.intervalStart;
    _currentIntervalEnd = event.intervalEnd;
    emit(const TransactionLoading());

    final TransactionDateRange range = AppDateUtils.getPeriodRange(
      event.period,
      referenceDate: _currentReferenceDate,
      intervalStart: event.intervalStart,
      intervalEnd: event.intervalEnd,
    );
    final periodResult = await _getTransactionsByPeriod(
      GetTransactionsByPeriodParams(
        start: range.start,
        end: range.end,
      ),
    );
    final oldestResult = await _getTransactionsByPeriod(
      GetTransactionsByPeriodParams(
        start: DateTime.fromMillisecondsSinceEpoch(0),
        end: DateTime(9999, 12, 31, 23, 59, 59, 999),
      ),
    );

    periodResult.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transactions) {
        oldestResult.fold(
          (failure) => emit(TransactionError(failure.message)),
          (allTransactions) => emit(
            _buildLoadedState(
              transactions,
              oldestTransactionDate: allTransactions.isEmpty
                  ? null
                  : allTransactions
                      .map((Transaction transaction) => transaction.date)
                      .reduce(
                        (DateTime oldest, DateTime current) =>
                            current.isBefore(oldest) ? current : oldest,
                      ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onAddTransaction(
    AddTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());

    final result = await _addTransaction(event.transaction);
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) => add(
        LoadTransactionsEvent(
          _currentPeriod,
          referenceDate: _currentReferenceDate,
          intervalStart: _currentIntervalStart,
          intervalEnd: _currentIntervalEnd,
        ),
      ),
    );
  }

  Future<void> _onUpdateTransaction(
    UpdateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());

    final result = await _updateTransaction(event.transaction);
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) => add(
        LoadTransactionsEvent(
          _currentPeriod,
          referenceDate: _currentReferenceDate,
          intervalStart: _currentIntervalStart,
          intervalEnd: _currentIntervalEnd,
        ),
      ),
    );
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());

    final result = await _deleteTransaction(event.id);
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) => add(
        LoadTransactionsEvent(
          _currentPeriod,
          referenceDate: _currentReferenceDate,
          intervalStart: _currentIntervalStart,
          intervalEnd: _currentIntervalEnd,
        ),
      ),
    );
  }

  TransactionLoaded _buildLoadedState(
    List<Transaction> transactions, {
    required DateTime? oldestTransactionDate,
  }) {
    double totalIncome = 0;
    double totalExpense = 0;
    final Map<String, double> categoryTotals = <String, double>{};

    for (final Transaction transaction in transactions) {
      switch (transaction.type) {
        case TransactionType.income:
          totalIncome += transaction.amount;
        case TransactionType.expense:
          totalExpense += transaction.amount;
          if (transaction.categoryKey != null) {
            categoryTotals.update(
              transaction.categoryKey!,
              (double value) => value + transaction.amount,
              ifAbsent: () => transaction.amount,
            );
          }
      }
    }

    return TransactionLoaded(
      transactions: transactions,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      categoryTotals: categoryTotals,
      oldestTransactionDate: oldestTransactionDate,
    );
  }
}
