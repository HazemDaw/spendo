import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Transactions extends Table {
  TextColumn get id => text()();
  RealColumn get amount => real()();
  TextColumn get categoryKey => text().nullable()();
  TextColumn get type => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get categoryKey => text().nullable()();
  RealColumn get limitAmount => real()();
  IntColumn get month => integer()();
  IntColumn get year => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class CustomCategories extends Table {
  TextColumn get id => text()();
  TextColumn get label => text()();
  IntColumn get colorValue => integer()();
  IntColumn get iconIndex => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class OrbitSlots extends Table {
  IntColumn get slotIndex => integer()();
  TextColumn get categoryKey => text()();
  BoolColumn get isCustom => boolean()();

  @override
  Set<Column> get primaryKey => {slotIndex};
}

@DriftDatabase(
  tables: <Type>[Transactions, Budgets, CustomCategories, OrbitSlots],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'spendo_db');
  }
}
