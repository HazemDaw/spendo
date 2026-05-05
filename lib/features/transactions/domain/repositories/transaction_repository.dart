import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<Transaction>>> getTransactionsByPeriod(
    DateTime start,
    DateTime end,
  );

  Future<Either<Failure, List<Transaction>>> getTransactionsByCategory(
    String categoryKey,
    DateTime start,
    DateTime end,
  );

  Future<Either<Failure, double>> getBalance();

  Future<Either<Failure, Unit>> addTransaction(Transaction transaction);

  Future<Either<Failure, Unit>> updateTransaction(Transaction transaction);

  Future<Either<Failure, Unit>> deleteTransaction(String id);

  Future<Either<Failure, void>> restoreFromCloud();
}
