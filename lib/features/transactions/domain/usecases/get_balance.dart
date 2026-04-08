import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/transaction_repository.dart';

class GetBalance implements UseCase<Either<Failure, double>, NoParams> {
  const GetBalance(this.repository);

  final TransactionRepository repository;

  @override
  Future<Either<Failure, double>> call(NoParams params) {
    return repository.getBalance();
  }
}
