import 'package:flutter/material.dart';

import '../../features/categories/domain/entities/category.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import '../theme/app_colors.dart';

class MockData {
  MockData._();

  static final List<Category> categories = <Category>[
    Category(
      key: 'food',
      labelKey: 'categoryFood',
      icon: Icons.restaurant,
      color: AppColors.categoryPalette[0],
    ),
    Category(
      key: 'transport',
      labelKey: 'categoryTransport',
      icon: Icons.directions_car,
      color: AppColors.categoryPalette[1],
    ),
    Category(
      key: 'housing',
      labelKey: 'categoryHousing',
      icon: Icons.home,
      color: AppColors.categoryPalette[2],
    ),
    Category(
      key: 'health',
      labelKey: 'categoryHealth',
      icon: Icons.local_pharmacy,
      color: AppColors.categoryPalette[3],
    ),
    Category(
      key: 'clothing',
      labelKey: 'categoryClothing',
      icon: Icons.checkroom,
      color: AppColors.categoryPalette[4],
    ),
    Category(
      key: 'entertainment',
      labelKey: 'categoryEntertainment',
      icon: Icons.theater_comedy,
      color: AppColors.categoryPalette[5],
    ),
    Category(
      key: 'communication',
      labelKey: 'categoryCommunication',
      icon: Icons.phone,
      color: AppColors.categoryPalette[6],
    ),
    Category(
      key: 'pets',
      labelKey: 'categoryPets',
      icon: Icons.pets,
      color: AppColors.categoryPalette[7],
    ),
    Category(
      key: 'gifts',
      labelKey: 'categoryGifts',
      icon: Icons.card_giftcard,
      color: AppColors.categoryPalette[8],
    ),
    Category(
      key: 'sport',
      labelKey: 'categorySport',
      icon: Icons.fitness_center,
      color: AppColors.categoryPalette[9],
    ),
  ];

  static final List<Transaction> sampleTransactions = _buildTransactions();

  static Category? categoryByKey(String? key) {
    if (key == null) {
      return null;
    }

    for (final Category category in categories) {
      if (category.key == key) {
        return category;
      }
    }

    return null;
  }

  static List<Transaction> _buildTransactions() {
    final DateTime now = DateTime.now();

    return <Transaction>[
      Transaction(
        id: 'tx_001',
        amount: 5306,
        categoryKey: 'food',
        type: TransactionType.expense,
        date: DateTime(now.year, now.month, 6, 11, 30),
        note: 'Groceries',
      ),
      Transaction(
        id: 'tx_002',
        amount: 166,
        categoryKey: 'transport',
        type: TransactionType.expense,
        date: DateTime(now.year, now.month, 5, 8, 10),
        note: 'Bus ticket',
      ),
      Transaction(
        id: 'tx_003',
        amount: 8000.00,
        type: TransactionType.income,
        date: DateTime(now.year, now.month - 1, 19, 14, 0),
        note: 'Freelance',
      ),
      Transaction(
        id: 'tx_004',
        amount: 1090,
        categoryKey: 'communication',
        type: TransactionType.expense,
        date: DateTime(now.year, now.month, 4, 19, 20),
        note: 'Phone bill',
      ),
      Transaction(
        id: 'tx_005',
        amount: 166,
        categoryKey: 'health',
        type: TransactionType.expense,
        date: DateTime(now.year, now.month, 3, 9, 45),
        note: 'Vitamins',
      ),
      Transaction(
        id: 'tx_006',
        amount: 32750.00,
        type: TransactionType.income,
        date: DateTime(now.year, now.month - 1, 8, 12, 0),
        note: 'Salary',
      ),
      Transaction(
        id: 'tx_007',
        amount: 5812,
        categoryKey: 'housing',
        type: TransactionType.expense,
        date: DateTime(now.year, now.month, 2, 10, 0),
        note: 'Rent share',
      ),
      Transaction(
        id: 'tx_008',
        amount: 3620,
        categoryKey: 'entertainment',
        type: TransactionType.expense,
        date: DateTime(now.year, now.month, 1, 22, 15),
        note: 'Night out',
      ),
      Transaction(
        id: 'tx_009',
        amount: 430.00,
        categoryKey: 'pets',
        type: TransactionType.expense,
        date: DateTime(now.year, now.month - 1, 22, 13, 30),
        note: 'Pet food',
      ),
      Transaction(
        id: 'tx_010',
        amount: 266,
        categoryKey: 'clothing',
        type: TransactionType.expense,
        date: DateTime(now.year, now.month, 7, 16, 5),
        note: 'T-shirt repair',
      ),
      Transaction(
        id: 'tx_011',
        amount: 720.00,
        categoryKey: 'gifts',
        type: TransactionType.expense,
        date: DateTime(now.year, now.month - 1, 12, 18, 40),
        note: 'Birthday gift',
      ),
      Transaction(
        id: 'tx_012',
        amount: 166,
        categoryKey: 'sport',
        type: TransactionType.expense,
        date: DateTime(now.year, now.month, 5, 7, 25),
        note: 'Gym locker',
      ),
      Transaction(
        id: 'tx_013',
        amount: 560.00,
        categoryKey: 'food',
        type: TransactionType.expense,
        date: DateTime(now.year, now.month - 1, 5, 10, 15),
        note: 'Coffee beans',
      ),
    ];
  }
}
