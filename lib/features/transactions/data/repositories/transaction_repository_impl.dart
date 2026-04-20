import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../datasources/transaction_remote_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
    required this.authRepository,
  });

  final TransactionLocalDatasource localDatasource;
  final TransactionRemoteDatasource remoteDatasource;
  final AuthRepository authRepository;

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
      final TransactionModel model = TransactionModel.fromEntity(transaction);
      await localDatasource.save(model);
      _mirrorToRemote(() => remoteDatasource.save(model));
      return const Right<Failure, Unit>(unit);
    } on Exception catch (exception) {
      return Left<Failure, Unit>(_mapFailure(exception));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTransaction(Transaction transaction) async {
    try {
      final TransactionModel model = TransactionModel.fromEntity(transaction);
      await localDatasource.update(model);
      _mirrorToRemote(() => remoteDatasource.update(model));
      return const Right<Failure, Unit>(unit);
    } on Exception catch (exception) {
      return Left<Failure, Unit>(_mapFailure(exception));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTransaction(String id) async {
    try {
      await localDatasource.delete(id);
      _mirrorToRemote(() => remoteDatasource.delete(id));
      return const Right<Failure, Unit>(unit);
    } on Exception catch (exception) {
      return Left<Failure, Unit>(_mapFailure(exception));
    }
  }

  Failure _mapFailure(Exception exception) {
    return CacheFailure(exception.toString());
  }

  void _mirrorToRemote(Future<void> Function() action) {
    if (authRepository.currentUserId == null) {
      return;
    }

    Future<void>.microtask(() async {
      try {
        await action();
      } catch (error) {
        debugPrint('Firestore sync failed: $error');
      }
    });
  }
}
