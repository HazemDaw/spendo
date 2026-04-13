import 'package:equatable/equatable.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/transaction.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class LoadTransactionsEvent extends TransactionEvent {
  const LoadTransactionsEvent(this.period, {this.referenceDate});

  final TransactionPeriod period;
  final DateTime? referenceDate;

  @override
  List<Object?> get props => <Object?>[period, referenceDate];
}

class AddTransactionEvent extends TransactionEvent {
  const AddTransactionEvent(this.transaction);

  final Transaction transaction;

  @override
  List<Object?> get props => <Object?>[transaction];
}

class UpdateTransactionEvent extends TransactionEvent {
  const UpdateTransactionEvent(this.transaction);

  final Transaction transaction;

  @override
  List<Object?> get props => <Object?>[transaction];
}

class DeleteTransactionEvent extends TransactionEvent {
  const DeleteTransactionEvent(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
