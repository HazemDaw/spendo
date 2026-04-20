import 'package:isar/isar.dart';

import '../models/transaction_model.dart';

abstract class TransactionLocalDatasource {
  const TransactionLocalDatasource();

  Future<List<TransactionModel>> getAll();
  Future<List<TransactionModel>> getByPeriod(DateTime start, DateTime end);
  Future<List<TransactionModel>> getByCategory(
    String key,
    DateTime start,
    DateTime end,
  );
  Future<void> save(TransactionModel model);
  Future<void> update(TransactionModel model);
  Future<void> delete(String id);
}

class TransactionLocalDatasourceImpl implements TransactionLocalDatasource {
  const TransactionLocalDatasourceImpl(this.isar);

  final Isar isar;

  @override
  Future<List<TransactionModel>> getAll() async {
    return isar.txn<List<TransactionModel>>(
      () async {
        final List<TransactionModel> models =
            await isar.transactionModels.where().findAll();
        models.sort(
          (TransactionModel a, TransactionModel b) => b.date.compareTo(a.date),
        );
        return models;
      },
    );
  }

  @override
  Future<List<TransactionModel>> getByPeriod(DateTime start, DateTime end) {
    return isar.txn<List<TransactionModel>>(
      () => isar.transactionModels
          .filter()
          .dateBetween(start, end)
          .sortByDateDesc()
          .findAll(),
    );
  }

  @override
  Future<List<TransactionModel>> getByCategory(
    String key,
    DateTime start,
    DateTime end,
  ) {
    return isar.txn<List<TransactionModel>>(
      () => isar.transactionModels
          .filter()
          .categoryKeyEqualTo(key)
          .dateBetween(start, end)
          .sortByDateDesc()
          .findAll(),
    );
  }

  @override
  Future<void> save(TransactionModel model) async {
    await isar.writeTxn(() => _putByExternalId(model));
  }

  @override
  Future<void> update(TransactionModel model) async {
    await isar.writeTxn(() => _putByExternalId(model));
  }

  @override
  Future<void> delete(String id) async {
    await isar.writeTxn(() async {
      final TransactionModel? existing =
          await isar.transactionModels.where().idEqualTo(id).findFirst();
      if (existing != null) {
        await isar.transactionModels.delete(existing.isarId);
      }
    });
  }

  Future<void> _putByExternalId(TransactionModel model) async {
    final TransactionModel? existing =
        await isar.transactionModels.where().idEqualTo(model.id).findFirst();
    if (existing != null) {
      model.isarId = existing.isarId;
    }

    await isar.transactionModels.put(model);
  }
}
