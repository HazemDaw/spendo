import '../../domain/repositories/transaction_repository.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction.dart';
import '../datasources/transaction_local_datasource.dart';
import '../models/transaction_model.dart';
import 'package:dartz/dartz.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl({
    required this.localDatasource,
  });

  final TransactionLocalDatasource localDatasource;

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsByPeriod(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final models = await localDatasource.getByPeriod(start, end);
      return Right<Failure, List<Transaction>>(
        models.map((TransactionModel model) => model.toEntity()).toList(),
      );
    } on Exception catch (exception) {
      return Left<Failure, List<Transaction>>(_mapFailure(exception));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsByCategory(
    String categoryKey,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final models = await localDatasource.getByCategory(categoryKey, start, end);
      return Right<Failure, List<Transaction>>(
        models.map((TransactionModel model) => model.toEntity()).toList(),
      );
    } on Exception catch (exception) {
      return Left<Failure, List<Transaction>>(_mapFailure(exception));
    }
  }

  @override
  Future<Either<Failure, double>> getBalance() async {
    try {
      final models = await localDatasource.getByPeriod(
        DateTime.fromMillisecondsSinceEpoch(0),
        DateTime(9999, 12, 31, 23, 59, 59, 999),
      );
      final double balance = models.fold<double>(
        0,
        (double sum, TransactionModel model) => switch (model.type) {
          TransactionType.income => sum + model.amount,
          TransactionType.expense => sum - model.amount,
        },
      );
      return Right<Failure, double>(balance);
    } on Exception catch (exception) {
      return Left<Failure, double>(_mapFailure(exception));
    }
  }

  @override
  Future<Either<Failure, Unit>> addTransaction(Transaction transaction) async {
    try {
      await localDatasource.save(TransactionModel.fromEntity(transaction));
      return const Right<Failure, Unit>(unit);
    } on Exception catch (exception) {
      return Left<Failure, Unit>(_mapFailure(exception));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTransaction(Transaction transaction) async {
    try {
      await localDatasource.update(TransactionModel.fromEntity(transaction));
      return const Right<Failure, Unit>(unit);
    } on Exception catch (exception) {
      return Left<Failure, Unit>(_mapFailure(exception));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTransaction(String id) async {
    try {
      await localDatasource.delete(id);
      return const Right<Failure, Unit>(unit);
    } on Exception catch (exception) {
      return Left<Failure, Unit>(_mapFailure(exception));
    }
  }

  Failure _mapFailure(Exception exception) {
    return CacheFailure(exception.toString());
  }
}
