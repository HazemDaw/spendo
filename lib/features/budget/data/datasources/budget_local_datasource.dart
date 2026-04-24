import 'package:isar/isar.dart';

import '../models/budget_model.dart';

abstract class BudgetLocalDatasource {
  const BudgetLocalDatasource();

  Future<List<BudgetModel>> getByMonthYear(int month, int year);
  Future<void> save(BudgetModel model);
  Future<void> delete(String id);
}

class BudgetLocalDatasourceImpl implements BudgetLocalDatasource {
  const BudgetLocalDatasourceImpl(this.isar);

  final Isar isar;

  @override
  Future<List<BudgetModel>> getByMonthYear(int month, int year) {
    return isar.txn<List<BudgetModel>>(
      () => isar.budgetModels
          .filter()
          .monthEqualTo(month)
          .yearEqualTo(year)
          .findAll(),
    );
  }

  @override
  Future<void> save(BudgetModel model) async {
    await isar.writeTxn(() => _putByExternalId(model));
  }

  @override
  Future<void> delete(String id) async {
    await isar.writeTxn(() async {
      final BudgetModel? existing =
          await isar.budgetModels.where().idEqualTo(id).findFirst();
      if (existing != null) {
        await isar.budgetModels.delete(existing.isarId);
      }
    });
  }

  Future<void> _putByExternalId(BudgetModel model) async {
    final BudgetModel? existing =
        await isar.budgetModels.where().idEqualTo(model.id).findFirst();
    if (existing != null) {
      model.isarId = existing.isarId;
    }

    await isar.budgetModels.put(model);
  }
}
