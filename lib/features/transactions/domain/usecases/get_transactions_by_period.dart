import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionsByPeriod
    implements
        UseCase<Either<Failure, List<Transaction>>, GetTransactionsByPeriodParams> {
  const GetTransactionsByPeriod(this.repository);

  final TransactionRepository repository;

  @override
  Future<Either<Failure, List<Transaction>>> call(
    GetTransactionsByPeriodParams params,
  ) {
    return repository.getTransactionsByPeriod(params.start, params.end);
  }
}

class GetTransactionsByPeriodParams extends Equatable {
  const GetTransactionsByPeriodParams({
    required this.start,
    required this.end,
  });

  final DateTime start;
  final DateTime end;

  @override
  List<Object?> get props => <Object?>[start, end];
}
