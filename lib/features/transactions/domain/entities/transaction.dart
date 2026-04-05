import 'package:equatable/equatable.dart';

enum TransactionType { expense, income }

class Transaction extends Equatable {
  const Transaction({
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
  final TransactionType type;
  final DateTime date;
  final String? note;

  @override
  List<Object?> get props =>
      <Object?>[id, amount, categoryKey, type, date, note];
}
