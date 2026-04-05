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
        amount: 1250.50,
        categoryKey: 'food',
        type: TransactionType.expense,
        date: now.subtract(const Duration(hours: 3)),
        note: 'Lunch set',
      ),
      Transaction(
        id: 'tx_002',
        amount: 240.00,
        categoryKey: 'transport',
        type: TransactionType.expense,
        date: now.subtract(const Duration(hours: 8)),
        note: 'Taxi',
      ),
      Transaction(
        id: 'tx_003',
        amount: 8000.00,
        type: TransactionType.income,
        date: now.subtract(const Duration(hours: 10)),
        note: 'Freelance',
      ),
      Transaction(
        id: 'tx_004',
        amount: 510.25,
        categoryKey: 'communication',
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 1, hours: 2)),
        note: 'Phone bill',
      ),
      Transaction(
        id: 'tx_005',
        amount: 680.00,
        categoryKey: 'health',
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 2, hours: 6)),
        note: 'Pharmacy',
      ),
      Transaction(
        id: 'tx_006',
        amount: 32750.00,
        type: TransactionType.income,
        date: now.subtract(const Duration(days: 3)),
        note: 'Salary',
      ),
      Transaction(
        id: 'tx_007',
        amount: 12400.00,
        categoryKey: 'housing',
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 4)),
        note: 'Rent',
      ),
      Transaction(
        id: 'tx_008',
        amount: 950.00,
        categoryKey: 'entertainment',
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 5)),
        note: 'Cinema',
      ),
      Transaction(
        id: 'tx_009',
        amount: 430.00,
        categoryKey: 'pets',
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 6)),
        note: 'Pet food',
      ),
      Transaction(
        id: 'tx_010',
        amount: 1700.00,
        categoryKey: 'clothing',
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 8)),
        note: 'Sweater',
      ),
      Transaction(
        id: 'tx_011',
        amount: 720.00,
        categoryKey: 'gifts',
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 11)),
        note: 'Birthday gift',
      ),
      Transaction(
        id: 'tx_012',
        amount: 1350.00,
        categoryKey: 'sport',
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 13)),
        note: 'Gym pass',
      ),
      Transaction(
        id: 'tx_013',
        amount: 560.00,
        categoryKey: 'food',
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 16)),
        note: 'Groceries',
      ),
    ];
  }
}
