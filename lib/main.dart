import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'core/locale/locale_cubit.dart';
import 'core/currency/currency_cubit.dart';
import 'core/mock/mock_data.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/utils/date_utils.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/budget/presentation/bloc/budget_bloc.dart';
import 'features/budget/presentation/bloc/budget_event.dart';
import 'features/budget/presentation/pages/budget_page.dart';
import 'features/categories/data/custom_category_store.dart';
import 'features/categories/presentation/pages/categories_page.dart';
import 'features/insights/presentation/pages/insights_page.dart';
import 'features/transactions/domain/entities/transaction.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';
import 'features/transactions/presentation/bloc/transaction_event.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/transactions/presentation/pages/add_transaction_page.dart';
import 'features/transactions/presentation/pages/all_transactions_page.dart';
import 'features/transactions/presentation/pages/home_page.dart';
import 'features/transactions/presentation/pages/transaction_list_page.dart';
import 'firebase_options.dart';
import 'injection_container.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'ru_RU';
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initDependencies();
  await sl<CustomCategoryStore>().ensureLoaded();
  runApp(const SpendoApp());
}

class SpendoApp extends StatelessWidget {
  const SpendoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<ThemeCubit>(
          create: (_) => sl<ThemeCubit>(),
        ),
        BlocProvider<LocaleCubit>(
          create: (_) => sl<LocaleCubit>(),
        ),
        BlocProvider<CurrencyCubit>(
          create: (_) => sl<CurrencyCubit>(),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(const CheckAuthStatusEvent()),
        ),
        BlocProvider<TransactionBloc>(
          create: (_) => sl<TransactionBloc>()
            ..add(const LoadTransactionsEvent(TransactionPeriod.month)),
        ),
        BlocProvider<BudgetBloc>(
          create: (_) => sl<BudgetBloc>()
            ..add(
              LoadBudgetsEvent(
                month: DateTime.now().month,
                year: DateTime.now().year,
              ),
            ),
        ),
      ],
      child: const _SpendoMaterialApp(),
    );
  }
}

class _SpendoMaterialApp extends StatelessWidget {
  const _SpendoMaterialApp();

  @override
  Widget build(BuildContext context) {
    final ThemeMode themeMode = context.watch<ThemeCubit>().state;

    return BlocBuilder<LocaleCubit, Locale>(
      builder: (BuildContext context, Locale locale) {
        return MaterialApp.router(
          title: 'Spendo',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          routerConfig: _router,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        );
      },
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
      path: '/budget',
      name: 'budget',
      builder: (BuildContext context, GoRouterState state) => const BudgetPage(),
    ),
    GoRoute(
      path: '/insights',
      name: 'insights',
      builder: (BuildContext context, GoRouterState state) {
        final Map<String, String> query = state.uri.queryParameters;
        final TransactionPeriod period = TransactionPeriod.values.firstWhere(
          (TransactionPeriod value) => value.name == query['period'],
          orElse: () => TransactionPeriod.month,
        );

        return InsightsPage(
          period: period,
          referenceDate: _dateFromQuery(query['referenceDate'], DateTime.now()),
          intervalStart: _nullableDateFromQuery(query['intervalStart']),
          intervalEnd: _nullableDateFromQuery(query['intervalEnd']),
        );
      },
    ),
    GoRoute(
      path: '/categories',
      name: 'categories',
      builder: (BuildContext context, GoRouterState state) =>
          const CategoriesPage(),
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

DateTime _dateFromQuery(String? value, DateTime fallback) {
  final int? milliseconds = int.tryParse(value ?? '');
  if (milliseconds == null) {
    return fallback;
  }
  return DateTime.fromMillisecondsSinceEpoch(milliseconds);
}

DateTime? _nullableDateFromQuery(String? value) {
  final int? milliseconds = int.tryParse(value ?? '');
  if (milliseconds == null) {
    return null;
  }
  return DateTime.fromMillisecondsSinceEpoch(milliseconds);
}
