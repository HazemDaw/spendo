import 'package:equatable/equatable.dart';

import '../../domain/entities/budget.dart';

abstract class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object?> get props => <Object?>[];
}

class BudgetInitial extends BudgetState {
  const BudgetInitial();
}

class BudgetLoading extends BudgetState {
  const BudgetLoading();
}

class BudgetLoaded extends BudgetState {
  const BudgetLoaded({
    required this.budgets,
  });

  final List<Budget> budgets;

  @override
  List<Object?> get props => <Object?>[budgets];
}

class BudgetError extends BudgetState {
  const BudgetError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
