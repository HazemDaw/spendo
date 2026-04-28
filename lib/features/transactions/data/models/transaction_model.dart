import '../../domain/entities/transaction.dart';

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.amount,
    this.categoryKey,
    required this.type,
    required this.date,
    this.note,
  });

  final String id;
  final double amount;
  final String? categoryKey;
  final String type;
  final DateTime date;
  final String? note;

  Transaction toEntity() => Transaction(
        id: id,
        amount: amount,
        categoryKey: categoryKey,
        type: type == 'expense'
            ? TransactionType.expense
            : TransactionType.income,
        date: date,
        note: note,
      );

  static TransactionModel fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      amount: transaction.amount,
      categoryKey: transaction.categoryKey,
      type: transaction.type == TransactionType.expense ? 'expense' : 'income',
      date: transaction.date,
      note: transaction.note,
    );
  }
}

extension TransactionModelTypeName on String {
  String get name => this;
}
