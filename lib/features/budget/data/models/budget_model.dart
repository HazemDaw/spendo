import '../../domain/entities/budget.dart';

class BudgetModel {
  const BudgetModel({
    required this.id,
    this.categoryKey,
    required this.limitAmount,
    required this.month,
    required this.year,
  });

  final String id;
  final String? categoryKey;
  final double limitAmount;
  final int month;
  final int year;

  Budget toEntity() {
    return Budget(
      id: id,
      categoryKey: categoryKey,
      limitAmount: limitAmount,
      month: month,
      year: year,
    );
  }

  static BudgetModel fromEntity(Budget budget) {
    return BudgetModel(
      id: budget.id,
      categoryKey: budget.categoryKey,
      limitAmount: budget.limitAmount,
      month: budget.month,
      year: budget.year,
    );
  }
}
