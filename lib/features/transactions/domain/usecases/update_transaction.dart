import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class UpdateTransaction
    implements UseCase<Either<Failure, Unit>, Transaction> {
  const UpdateTransaction(this.repository);

  final TransactionRepository repository;

  @override
  Future<Either<Failure, Unit>> call(Transaction params) {
    return repository.updateTransaction(params);
  }
}
