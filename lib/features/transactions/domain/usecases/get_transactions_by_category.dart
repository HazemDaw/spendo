import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionsByCategory
    implements
        UseCase<
          Either<Failure, List<Transaction>>,
          GetTransactionsByCategoryParams
        > {
  const GetTransactionsByCategory(this.repository);

  final TransactionRepository repository;

  @override
  Future<Either<Failure, List<Transaction>>> call(
    GetTransactionsByCategoryParams params,
  ) {
    return repository.getTransactionsByCategory(
      params.categoryKey,
      params.start,
      params.end,
    );
  }
}

class GetTransactionsByCategoryParams extends Equatable {
  const GetTransactionsByCategoryParams({
    required this.categoryKey,
    required this.start,
    required this.end,
  });

  final String categoryKey;
  final DateTime start;
  final DateTime end;

  @override
  List<Object?> get props => <Object?>[categoryKey, start, end];
}
