import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/transaction_repository.dart';

class DeleteTransaction implements UseCase<Either<Failure, Unit>, String> {
  const DeleteTransaction(this.repository);

  final TransactionRepository repository;

  @override
  Future<Either<Failure, Unit>> call(String params) {
    return repository.deleteTransaction(params);
  }
}
