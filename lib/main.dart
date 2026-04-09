import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'core/mock/mock_data.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/date_utils.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/transactions/domain/entities/transaction.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';
import 'features/transactions/presentation/bloc/transaction_event.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/transactions/presentation/pages/add_transaction_page.dart';
import 'features/transactions/presentation/pages/all_transactions_page.dart';
import 'features/transactions/presentation/pages/home_page.dart';
import 'features/transactions/presentation/pages/transaction_list_page.dart';
import 'injection_container.dart' as di;
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'ru_RU';
  await di.init();
  runApp(const SpendoApp());
}

class SpendoApp extends StatelessWidget {
  const SpendoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransactionBloc>(
      create: (_) => di.sl<TransactionBloc>()
        ..add(const LoadTransactionsEvent(TransactionPeriod.month)),
      child: MaterialApp.router(
        title: 'Spendo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
        locale: const Locale('ru'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'home',
      builder: (BuildContext context, GoRouterState state) => const HomePage(),
    ),
    GoRoute(
      path: '/add',
      name: 'addTransaction',
      builder: (BuildContext context, GoRouterState state) {
        final String type = state.uri.queryParameters['type'] ?? 'expense';
        final String? categoryKey = state.uri.queryParameters['categoryKey'];

        return AddTransactionPage(
          type: type,
          initialCategoryKey: categoryKey,
        );
      },
    ),
    GoRoute(
      path: '/edit/:transactionId',
      name: 'editTransaction',
      builder: (BuildContext context, GoRouterState state) {
        return AddTransactionPage(
          type: 'expense',
          transactionId: state.pathParameters['transactionId']!,
        );
      },
    ),
    GoRoute(
      path: '/transactions/:categoryKey',
      name: 'transactionList',
      builder: (BuildContext context, GoRouterState state) {
        return TransactionListPage(
          categoryKey: state.pathParameters['categoryKey']!,
        );
      },
    ),
    GoRoute(
      path: '/all-transactions',
      name: 'allTransactions',
      builder: (BuildContext context, GoRouterState state) {
        final Object? extra = state.extra;
        final List<Transaction> initialTransactions = extra is List
            ? extra.whereType<Transaction>().toList()
            : MockData.sampleTransactions;

        return AllTransactionsPage(
          initialTransactions: initialTransactions,
        );
      },
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (BuildContext context, GoRouterState state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (BuildContext context, GoRouterState state) =>
          const RegisterPage(),
    ),
  ],
);
