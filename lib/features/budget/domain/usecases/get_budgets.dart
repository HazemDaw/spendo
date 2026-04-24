import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class GetBudgets
    implements UseCase<Either<Failure, List<Budget>>, GetBudgetsParams> {
  const GetBudgets(this.repository);

  final BudgetRepository repository;

  @override
  Future<Either<Failure, List<Budget>>> call(GetBudgetsParams params) {
    return repository.getBudgets(params.month, params.year);
  }
}

class GetBudgetsParams extends Equatable {
  const GetBudgetsParams({
    required this.month,
    required this.year,
  });

  final int month;
  final int year;

  @override
  List<Object?> get props => <Object?>[month, year];
}
