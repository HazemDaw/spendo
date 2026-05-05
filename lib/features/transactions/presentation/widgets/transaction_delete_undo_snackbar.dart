import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';

class TransactionDeleteResult {
  const TransactionDeleteResult(this.transaction);

  final Transaction transaction;
}

void showTransactionDeletedUndoSnackBar(
  BuildContext context,
  Transaction transaction,
) {
  final AppLocalizations l10n = AppLocalizations.of(context)!;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(l10n.transactionDeletedMessage),
        backgroundColor: Colors.grey.shade900,
        duration: const Duration(milliseconds: 4000),
        action: SnackBarAction(
          label: l10n.undoDeleteAction,
          textColor: const Color(0xFF7C3AED),
          onPressed: () {
            context.read<TransactionBloc>().add(
                  AddTransactionEvent(transaction),
                );
          },
        ),
      ),
    );
}
