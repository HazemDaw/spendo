import 'package:isar/isar.dart';

import '../../domain/entities/transaction.dart';

part 'transaction_model.g.dart';

@collection
class TransactionModel {
  Id isarId = Isar.autoIncrement;

  @Index()
  late String id;

  late double amount;

  @Index()
  String? categoryKey;

  @Enumerated(EnumType.name)
  late TransactionType type;

  @Index()
  late DateTime date;

  String? note;

  Transaction toEntity() => Transaction(
        id: id,
        amount: amount,
        categoryKey: categoryKey,
        type: type,
        date: date,
        note: note,
      );

  static TransactionModel fromEntity(Transaction transaction) {
    return TransactionModel()
      ..id = transaction.id
      ..amount = transaction.amount
      ..categoryKey = transaction.categoryKey
      ..type = transaction.type
      ..date = transaction.date
      ..note = transaction.note;
  }
}
