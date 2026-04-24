import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/budget.dart';

abstract class BudgetRepository {
  Future<Either<Failure, List<Budget>>> getBudgets(int month, int year);
  Future<Either<Failure, Unit>> setBudget(Budget budget);
  Future<Either<Failure, Unit>> deleteBudget(String id);
}
