import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_datasource.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  const BudgetRepositoryImpl({
    required this.localDatasource,
  });

  final BudgetLocalDatasource localDatasource;

  @override
  Future<Either<Failure, List<Budget>>> getBudgets(int month, int year) async {
    try {
      final List<BudgetModel> models =
          await localDatasource.getByMonthYear(month, year);
      return Right<Failure, List<Budget>>(
        models.map((BudgetModel model) => model.toEntity()).toList(),
      );
    } on Exception catch (exception) {
      return Left<Failure, List<Budget>>(CacheFailure(exception.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> setBudget(Budget budget) async {
    try {
      await localDatasource.save(BudgetModel.fromEntity(budget));
      return const Right<Failure, Unit>(unit);
    } on Exception catch (exception) {
      return Left<Failure, Unit>(CacheFailure(exception.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteBudget(String id) async {
    try {
      await localDatasource.delete(id);
      return const Right<Failure, Unit>(unit);
    } on Exception catch (exception) {
      return Left<Failure, Unit>(CacheFailure(exception.toString()));
    }
  }
}
