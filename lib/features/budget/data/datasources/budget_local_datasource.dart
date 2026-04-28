import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/budget_model.dart';

abstract class BudgetLocalDatasource {
  const BudgetLocalDatasource();

  Future<List<BudgetModel>> getByMonthYear(int month, int year);
  Future<void> save(BudgetModel model);
  Future<void> delete(String id);
}

class BudgetLocalDatasourceImpl implements BudgetLocalDatasource {
  const BudgetLocalDatasourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<BudgetModel>> getByMonthYear(int month, int year) async {
    final List<Budget> rows = await (_db.select(_db.budgets)
          ..where((b) => b.month.equals(month) & b.year.equals(year)))
        .get();
    return rows.map(_rowToModel).toList();
  }

  @override
  Future<void> save(BudgetModel model) async {
    await _db.into(_db.budgets).insertOnConflictUpdate(
          BudgetsCompanion(
            id: Value<String>(model.id),
            categoryKey: Value<String?>(model.categoryKey),
            limitAmount: Value<double>(model.limitAmount),
            month: Value<int>(model.month),
            year: Value<int>(model.year),
          ),
        );
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.budgets)..where((b) => b.id.equals(id))).go();
  }

  BudgetModel _rowToModel(Budget row) {
    return BudgetModel(
      id: row.id,
      categoryKey: row.categoryKey,
      limitAmount: row.limitAmount,
      month: row.month,
      year: row.year,
    );
  }
}
