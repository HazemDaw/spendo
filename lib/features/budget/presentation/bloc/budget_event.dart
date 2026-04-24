import 'package:equatable/equatable.dart';

import '../../domain/entities/budget.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class LoadBudgetsEvent extends BudgetEvent {
  const LoadBudgetsEvent({
    required this.month,
    required this.year,
  });

  final int month;
  final int year;

  @override
  List<Object?> get props => <Object?>[month, year];
}

class SetBudgetEvent extends BudgetEvent {
  const SetBudgetEvent({
    required this.budget,
  });

  final Budget budget;

  @override
  List<Object?> get props => <Object?>[budget];
}

class DeleteBudgetEvent extends BudgetEvent {
  const DeleteBudgetEvent({
    required this.id,
  });

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
