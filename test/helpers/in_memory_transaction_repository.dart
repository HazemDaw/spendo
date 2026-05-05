import 'package:dartz/dartz.dart';
import 'package:spendo/core/error/failures.dart';
import 'package:spendo/features/transactions/domain/entities/transaction.dart';
import 'package:spendo/features/transactions/domain/repositories/transaction_repository.dart';

class InMemoryTransactionRepository implements TransactionRepository {
  InMemoryTransactionRepository({
    List<Transaction>? seedTransactions,
    this.loadDelay = Duration.zero,
  }) : _transactions = List<Transaction>.from(seedTransactions ?? const <Transaction>[]);

  final Duration loadDelay;
  final List<Transaction> _transactions;

  @override
  Future<Either<Failure, Unit>> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    return const Right<Failure, Unit>(unit);
  }

  @override
  Future<Either<Failure, Unit>> deleteTransaction(String id) async {
    _transactions.removeWhere((Transaction transaction) => transaction.id == id);
    return const Right<Failure, Unit>(unit);
  }

  @override
  Future<Either<Failure, void>> restoreFromCloud() async {
    return const Right<Failure, void>(null);
  }

  @override
  Future<Either<Failure, double>> getBalance() async {
    final double balance = _transactions.fold<double>(
      0,
      (double total, Transaction transaction) => switch (transaction.type) {
        TransactionType.income => total + transaction.amount,
        TransactionType.expense => total - transaction.amount,
      },
    );
    return Right<Failure, double>(balance);
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsByCategory(
    String categoryKey,
    DateTime start,
    DateTime end,
  ) async {
    await _waitForLoad();
    return Right<Failure, List<Transaction>>(
      _transactions.where((Transaction transaction) {
        return transaction.categoryKey == categoryKey &&
            _isWithinRange(transaction.date, start, end);
      }).toList(),
    );
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsByPeriod(
    DateTime start,
    DateTime end,
  ) async {
    await _waitForLoad();
    return Right<Failure, List<Transaction>>(
      _transactions.where((Transaction transaction) {
        return _isWithinRange(transaction.date, start, end);
      }).toList(),
    );
  }

  @override
  Future<Either<Failure, Unit>> updateTransaction(Transaction transaction) async {
    final int index = _transactions.indexWhere(
      (Transaction current) => current.id == transaction.id,
    );
    if (index >= 0) {
      _transactions[index] = transaction;
    }
    return const Right<Failure, Unit>(unit);
  }

  Future<void> _waitForLoad() async {
    if (loadDelay == Duration.zero) {
      return;
    }
    await Future<void>.delayed(loadDelay);
  }

  bool _isWithinRange(DateTime date, DateTime start, DateTime end) {
    return !date.isBefore(start) && !date.isAfter(end);
  }
}
