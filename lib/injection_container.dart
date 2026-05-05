import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/database/app_database.dart';
import 'core/currency/currency_cubit.dart';
import 'core/locale/locale_cubit.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/data/datasources/firebase_auth_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/categories/data/custom_category_store.dart';
import 'features/categories/data/datasources/custom_category_local_datasource.dart';
import 'features/categories/data/datasources/custom_category_remote_datasource.dart';
import 'features/categories/data/datasources/orbit_slot_datasource.dart';
import 'features/insights/presentation/bloc/insights_cubit.dart';
import 'features/budget/data/datasources/budget_local_datasource.dart';
import 'features/budget/data/repositories/budget_repository_impl.dart';
import 'features/budget/domain/repositories/budget_repository.dart';
import 'features/budget/domain/usecases/delete_budget.dart';
import 'features/budget/domain/usecases/get_budgets.dart';
import 'features/budget/domain/usecases/set_budget.dart';
import 'features/budget/presentation/bloc/budget_bloc.dart';
import 'features/transactions/data/datasources/transaction_local_datasource.dart';
import 'features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/domain/repositories/transaction_repository.dart';
import 'features/transactions/domain/usecases/add_transaction.dart';
import 'features/transactions/domain/usecases/delete_transaction.dart';
import 'features/transactions/domain/usecases/get_balance.dart';
import 'features/transactions/domain/usecases/get_transactions_by_category.dart';
import 'features/transactions/domain/usecases/get_transactions_by_period.dart';
import 'features/transactions/domain/usecases/update_transaction.dart';
import 'features/transactions/presentation/bloc/keypad_cubit.dart';
import 'features/transactions/presentation/bloc/period_cubit.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  if (!sl.isRegistered<AppDatabase>()) {
    final AppDatabase db = AppDatabase();
    sl.registerSingleton<AppDatabase>(db);
  }

  if (!sl.isRegistered<SharedPreferences>()) {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sl.registerSingleton<SharedPreferences>(sharedPreferences);
  }

  if (!sl.isRegistered<TransactionLocalDatasource>()) {
    sl.registerLazySingleton<TransactionLocalDatasource>(
      () => TransactionLocalDatasourceImpl(sl()),
    );
  }

  if (!sl.isRegistered<BudgetLocalDatasource>()) {
    sl.registerLazySingleton<BudgetLocalDatasource>(
      () => BudgetLocalDatasourceImpl(sl()),
    );
  }

  if (!sl.isRegistered<CustomCategoryLocalDatasource>()) {
    sl.registerLazySingleton<CustomCategoryLocalDatasource>(
      () => CustomCategoryLocalDatasourceImpl(sl()),
    );
  }

  if (!sl.isRegistered<OrbitSlotDatasource>()) {
    sl.registerLazySingleton<OrbitSlotDatasource>(
      () => OrbitSlotDatasourceImpl(
        db: sl(),
        customCategoryDatasource: sl(),
      ),
    );
  }

  if (!sl.isRegistered<TransactionRemoteDatasource>()) {
    sl.registerLazySingleton<TransactionRemoteDatasource>(
      FirestoreTransactionDatasource.new,
    );
  }

  if (!sl.isRegistered<CustomCategoryRemoteDatasource>()) {
    sl.registerLazySingleton<CustomCategoryRemoteDatasource>(
      FirestoreCustomCategoryDatasource.new,
    );
  }

  if (!sl.isRegistered<FirebaseAuthDatasource>()) {
    sl.registerLazySingleton<FirebaseAuthDatasource>(
      FirebaseAuthDatasourceImpl.new,
    );
  }

  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(datasource: sl()),
    );
  }

  if (!sl.isRegistered<TransactionRepository>()) {
    sl.registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImpl(
        localDatasource: sl(),
        remoteDatasource: sl(),
        authRepository: sl(),
      ),
    );
  }

  if (!sl.isRegistered<BudgetRepository>()) {
    sl.registerLazySingleton<BudgetRepository>(
      () => BudgetRepositoryImpl(localDatasource: sl()),
    );
  }

  if (!sl.isRegistered<CustomCategoryStore>()) {
    sl.registerLazySingleton<CustomCategoryStore>(
      () => CustomCategoryStore(
        localDatasource: sl(),
        remoteDatasource: sl(),
        authRepository: sl(),
      ),
    );
  }

  if (!sl.isRegistered<AddTransaction>()) {
    sl.registerLazySingleton<AddTransaction>(() => AddTransaction(sl()));
    sl.registerLazySingleton<GetTransactionsByPeriod>(
      () => GetTransactionsByPeriod(sl()),
    );
    sl.registerLazySingleton<GetTransactionsByCategory>(
      () => GetTransactionsByCategory(sl()),
    );
    sl.registerLazySingleton<GetBalance>(() => GetBalance(sl()));
    sl.registerLazySingleton<UpdateTransaction>(() => UpdateTransaction(sl()));
    sl.registerLazySingleton<DeleteTransaction>(() => DeleteTransaction(sl()));
  }

  if (!sl.isRegistered<GetBudgets>()) {
    sl.registerLazySingleton<GetBudgets>(() => GetBudgets(sl()));
    sl.registerLazySingleton<SetBudget>(() => SetBudget(sl()));
    sl.registerLazySingleton<DeleteBudget>(() => DeleteBudget(sl()));
  }

  if (!sl.isRegistered<TransactionBloc>()) {
    sl.registerFactory<TransactionBloc>(
      () => TransactionBloc(
        addTransaction: sl(),
        getTransactionsByPeriod: sl(),
        updateTransaction: sl(),
        deleteTransaction: sl(),
      ),
    );
  }
  if (!sl.isRegistered<BudgetBloc>()) {
    sl.registerFactory<BudgetBloc>(
      () => BudgetBloc(
        getBudgets: sl(),
        setBudget: sl(),
        deleteBudget: sl(),
      ),
    );
  }
  if (!sl.isRegistered<InsightsCubit>()) {
    sl.registerFactory<InsightsCubit>(
      () => InsightsCubit(
        transactionRepository: sl(),
        budgetRepository: sl(),
      ),
    );
  }
  if (!sl.isRegistered<AuthBloc>()) {
    sl.registerFactoryParam<AuthBloc, TransactionBloc, void>(
      (TransactionBloc transactionBloc, _) => AuthBloc(
        authRepository: sl(),
        localDatasource: sl(),
        remoteDatasource: sl(),
        transactionRepository: sl(),
        transactionBloc: transactionBloc,
        sharedPreferences: sl(),
      ),
    );
  }
  if (!sl.isRegistered<KeypadCubit>()) {
    sl.registerFactory<KeypadCubit>(KeypadCubit.new);
  }
  if (!sl.isRegistered<PeriodCubit>()) {
    sl.registerFactory<PeriodCubit>(PeriodCubit.new);
  }
  if (!sl.isRegistered<ThemeCubit>()) {
    sl.registerFactory<ThemeCubit>(() => ThemeCubit(sl<SharedPreferences>()));
  }
  if (!sl.isRegistered<LocaleCubit>()) {
    sl.registerFactory<LocaleCubit>(
      () => LocaleCubit(sl<SharedPreferences>()),
    );
  }
  if (!sl.isRegistered<CurrencyCubit>()) {
    sl.registerFactory<CurrencyCubit>(
      () => CurrencyCubit(sl<SharedPreferences>()),
    );
  }
}

Future<void> init() => initDependencies();
