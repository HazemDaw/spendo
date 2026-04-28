import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
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
  Future<DateTime?> getOldestTransactionDate();
}

class TransactionLocalDatasourceImpl implements TransactionLocalDatasource {
  const TransactionLocalDatasourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<TransactionModel>> getAll() async {
    final List<Transaction> rows = await (_db.select(_db.transactions)
          ..orderBy(
            <OrderingTerm Function($TransactionsTable)>[
              (t) => OrderingTerm.desc(t.date),
            ],
          ))
        .get();
    return rows.map(_rowToModel).toList();
  }

  @override
  Future<List<TransactionModel>> getByPeriod(
    DateTime start,
    DateTime end,
  ) async {
    final List<Transaction> rows = await (_db.select(_db.transactions)
          ..where(
            (t) =>
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerOrEqualValue(end),
          )
          ..orderBy(
            <OrderingTerm Function($TransactionsTable)>[
              (t) => OrderingTerm.desc(t.date),
            ],
          ))
        .get();
    return rows.map(_rowToModel).toList();
  }

  @override
  Future<List<TransactionModel>> getByCategory(
    String key,
    DateTime start,
    DateTime end,
  ) async {
    final List<Transaction> rows = await (_db.select(_db.transactions)
          ..where(
            (t) =>
                t.categoryKey.equals(key) &
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerOrEqualValue(end),
          )
          ..orderBy(
            <OrderingTerm Function($TransactionsTable)>[
              (t) => OrderingTerm.desc(t.date),
            ],
          ))
        .get();
    return rows.map(_rowToModel).toList();
  }

  @override
  Future<void> save(TransactionModel model) async {
    await _db.into(_db.transactions).insertOnConflictUpdate(
          TransactionsCompanion(
            id: Value<String>(model.id),
            amount: Value<double>(model.amount),
            categoryKey: Value<String?>(model.categoryKey),
            type: Value<String>(model.type),
            date: Value<DateTime>(model.date),
            note: Value<String?>(model.note),
          ),
        );
  }

  @override
  Future<void> update(TransactionModel model) => save(model);

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<DateTime?> getOldestTransactionDate() async {
    final Transaction? row = await (_db.select(_db.transactions)
          ..orderBy(
            <OrderingTerm Function($TransactionsTable)>[
              (t) => OrderingTerm.asc(t.date),
            ],
          )
          ..limit(1))
        .getSingleOrNull();
    return row?.date;
  }

  TransactionModel _rowToModel(Transaction row) => TransactionModel(
        id: row.id,
        amount: row.amount,
        categoryKey: row.categoryKey,
        type: row.type,
        date: row.date,
        note: row.note,
      );
}
