import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/budget_repository.dart';

class DeleteBudget implements UseCase<Either<Failure, Unit>, String> {
  const DeleteBudget(this.repository);

  final BudgetRepository repository;

  @override
  Future<Either<Failure, Unit>> call(String params) {
    return repository.deleteBudget(params);
  }
}
