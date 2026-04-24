import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class SetBudget implements UseCase<Either<Failure, Unit>, Budget> {
  const SetBudget(this.repository);

  final BudgetRepository repository;

  @override
  Future<Either<Failure, Unit>> call(Budget params) {
    return repository.setBudget(params);
  }
}
