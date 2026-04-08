import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'features/transactions/data/datasources/transaction_local_datasource.dart';
import 'features/transactions/data/models/transaction_model.dart';
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

Future<void> init() async {
  if (!sl.isRegistered<Isar>()) {
    final directory = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      <CollectionSchema<dynamic>>[TransactionModelSchema],
      directory: directory.path,
    );
    sl.registerSingleton<Isar>(isar);
  }

  if (!sl.isRegistered<TransactionLocalDatasource>()) {
    sl.registerLazySingleton<TransactionLocalDatasource>(
      () => TransactionLocalDatasourceImpl(sl()),
    );
  }

  if (!sl.isRegistered<TransactionRepository>()) {
    sl.registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImpl(localDatasource: sl()),
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

  sl.registerFactory<TransactionBloc>(
    () => TransactionBloc(
      addTransaction: sl(),
      getTransactionsByPeriod: sl(),
      updateTransaction: sl(),
      deleteTransaction: sl(),
    ),
  );
  sl.registerFactory<KeypadCubit>(KeypadCubit.new);
  sl.registerFactory<PeriodCubit>(PeriodCubit.new);
}
