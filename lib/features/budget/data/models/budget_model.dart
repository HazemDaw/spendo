import 'package:isar/isar.dart';

import '../../domain/entities/budget.dart';

part 'budget_model.g.dart';

@collection
class BudgetModel {
  Id isarId = Isar.autoIncrement;

  @Index()
  late String id;

  @Index()
  String? categoryKey;

  late double limitAmount;

  @Index()
  late int month;

  @Index()
  late int year;

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
    return BudgetModel()
      ..id = budget.id
      ..categoryKey = budget.categoryKey
      ..limitAmount = budget.limitAmount
      ..month = budget.month
      ..year = budget.year;
  }
}
