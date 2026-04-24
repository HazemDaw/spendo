import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  const Budget({
    required this.id,
    required this.categoryKey,
    required this.limitAmount,
    required this.month,
    required this.year,
  });

  final String id;
  final String? categoryKey;
  final double limitAmount;
  final int month;
  final int year;

  bool get isTotalBudget => categoryKey == null;

  @override
  List<Object?> get props => <Object?>[
        id,
        categoryKey,
        limitAmount,
        month,
        year,
      ];
}
