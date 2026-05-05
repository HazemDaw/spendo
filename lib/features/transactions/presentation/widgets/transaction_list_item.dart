import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/currency/currency_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/category_localizer.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../categories/data/custom_category_access.dart';
import '../../../categories/domain/entities/category.dart';
import '../../domain/entities/transaction.dart';

class TransactionListItem extends StatelessWidget {
  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  final Transaction transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Category? category =
        maybeCustomCategoryStore()?.resolveCategory(transaction.categoryKey);
    final Color amountColor = transaction.type == TransactionType.expense
        ? AppColors.expense
        : AppColors.income;
    final String currencySymbol = context.watch<CurrencyCubit>().state;
    final String dateLabel =
        DateFormat('EEE, d MMM', 'ru_RU').format(transaction.date);

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(
          category?.icon ?? Icons.payments_outlined,
          color: category?.color ?? AppColors.primary,
        ),
      ),
      title: Text(
        category == null
            ? (transaction.categoryKey ?? l10n.actionIncome)
            : CategoryLocalizer.label(l10n, category),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      subtitle: Text(
        transaction.note ?? '',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            CurrencyFormatter.format(
              transaction.amount,
              symbol: currencySymbol,
            ),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: amountColor),
          ),
          const SizedBox(height: 4),
          Text(
            dateLabel,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
