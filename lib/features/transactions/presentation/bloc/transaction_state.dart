import 'package:equatable/equatable.dart';

import '../../domain/entities/transaction.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => <Object?>[];
}

class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

class TransactionLoaded extends TransactionState {
  const TransactionLoaded({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.categoryTotals,
    required this.oldestTransactionDate,
  });

  final List<Transaction> transactions;
  final double totalIncome;
  final double totalExpense;
  final Map<String, double> categoryTotals;
  final DateTime? oldestTransactionDate;

  @override
  List<Object?> get props => <Object?>[
        transactions,
        totalIncome,
        totalExpense,
        categoryTotals,
        oldestTransactionDate,
      ];
}

class TransactionError extends TransactionState {
  const TransactionError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
