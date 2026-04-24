import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/delete_budget.dart';
import '../../domain/usecases/get_budgets.dart';
import '../../domain/usecases/set_budget.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  BudgetBloc({
    required GetBudgets getBudgets,
    required SetBudget setBudget,
    required DeleteBudget deleteBudget,
  })  : _getBudgets = getBudgets,
        _setBudget = setBudget,
        _deleteBudget = deleteBudget,
        _currentMonth = DateTime.now().month,
        _currentYear = DateTime.now().year,
        super(const BudgetInitial()) {
    on<LoadBudgetsEvent>(_onLoadBudgets);
    on<SetBudgetEvent>(_onSetBudget);
    on<DeleteBudgetEvent>(_onDeleteBudget);
  }

  final GetBudgets _getBudgets;
  final SetBudget _setBudget;
  final DeleteBudget _deleteBudget;

  int _currentMonth;
  int _currentYear;

  Future<void> _onLoadBudgets(
    LoadBudgetsEvent event,
    Emitter<BudgetState> emit,
  ) async {
    _currentMonth = event.month;
    _currentYear = event.year;
    emit(const BudgetLoading());

    final result = await _getBudgets(
      GetBudgetsParams(month: event.month, year: event.year),
    );
    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (budgets) => emit(BudgetLoaded(budgets: budgets)),
    );
  }

  Future<void> _onSetBudget(
    SetBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    emit(const BudgetLoading());

    final result = await _setBudget(event.budget);
    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (_) => add(LoadBudgetsEvent(month: _currentMonth, year: _currentYear)),
    );
  }

  Future<void> _onDeleteBudget(
    DeleteBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    emit(const BudgetLoading());

    final result = await _deleteBudget(event.id);
    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (_) => add(LoadBudgetsEvent(month: _currentMonth, year: _currentYear)),
    );
  }
}
