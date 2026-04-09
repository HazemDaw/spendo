import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendo/core/utils/date_utils.dart';
import 'package:spendo/features/transactions/domain/entities/transaction.dart';
import 'package:spendo/features/transactions/domain/usecases/add_transaction.dart';
import 'package:spendo/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:spendo/features/transactions/domain/usecases/get_transactions_by_period.dart';
import 'package:spendo/features/transactions/domain/usecases/update_transaction.dart';
import 'package:spendo/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:spendo/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:spendo/features/transactions/presentation/pages/add_transaction_page.dart';
import 'package:spendo/l10n/app_localizations.dart';

import '../../../helpers/in_memory_transaction_repository.dart';

void main() {
  testWidgets(
    'keypad taps update the amount on add screen',
    (WidgetTester tester) async {
      final InMemoryTransactionRepository repository =
          InMemoryTransactionRepository();
      final TransactionBloc bloc = TransactionBloc(
        addTransaction: AddTransaction(repository),
        getTransactionsByPeriod: GetTransactionsByPeriod(repository),
        updateTransaction: UpdateTransaction(repository),
        deleteTransaction: DeleteTransaction(repository),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider<TransactionBloc>.value(
          value: bloc,
          child: const MaterialApp(
            locale: Locale('ru'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: AddTransactionPage(type: 'expense'),
          ),
        ),
      );

      await tester.tap(find.widgetWithText(FilledButton, '1'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, '2'));
      await tester.pump();

      expect(find.text('12'), findsOneWidget);
    },
  );

  testWidgets(
    'edit mode hydrates after transactions finish loading',
    (WidgetTester tester) async {
      final InMemoryTransactionRepository repository =
          InMemoryTransactionRepository(
            loadDelay: const Duration(milliseconds: 10),
            seedTransactions: <Transaction>[
              Transaction(
                id: 'tx-edit',
                amount: 321,
                categoryKey: 'food',
                type: TransactionType.expense,
                date: DateTime.now(),
                note: 'Coffee beans',
              ),
            ],
          );
      final TransactionBloc bloc = TransactionBloc(
        addTransaction: AddTransaction(repository),
        getTransactionsByPeriod: GetTransactionsByPeriod(repository),
        updateTransaction: UpdateTransaction(repository),
        deleteTransaction: DeleteTransaction(repository),
      )..add(const LoadTransactionsEvent(TransactionPeriod.month));
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider<TransactionBloc>.value(
          value: bloc,
          child: const MaterialApp(
            locale: Locale('ru'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: AddTransactionPage(
              type: 'expense',
              transactionId: 'tx-edit',
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('321'), findsOneWidget);
      expect(find.text('Coffee beans'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    },
  );
}
