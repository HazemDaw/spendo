// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _categoryKeyMeta =
      const VerificationMeta('categoryKey');
  @override
  late final GeneratedColumn<String> categoryKey = GeneratedColumn<String>(
      'category_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, amount, categoryKey, type, date, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category_key')) {
      context.handle(
          _categoryKeyMeta,
          categoryKey.isAcceptableOrUnknown(
              data['category_key']!, _categoryKeyMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      categoryKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_key']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final String id;
  final double amount;
  final String? categoryKey;
  final String type;
  final DateTime date;
  final String? note;
  const Transaction(
      {required this.id,
      required this.amount,
      this.categoryKey,
      required this.type,
      required this.date,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || categoryKey != null) {
      map['category_key'] = Variable<String>(categoryKey);
    }
    map['type'] = Variable<String>(type);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      amount: Value(amount),
      categoryKey: categoryKey == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryKey),
      type: Value(type),
      date: Value(date),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<String>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      categoryKey: serializer.fromJson<String?>(json['categoryKey']),
      type: serializer.fromJson<String>(json['type']),
      date: serializer.fromJson<DateTime>(json['date']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'amount': serializer.toJson<double>(amount),
      'categoryKey': serializer.toJson<String?>(categoryKey),
      'type': serializer.toJson<String>(type),
      'date': serializer.toJson<DateTime>(date),
      'note': serializer.toJson<String?>(note),
    };
  }

  Transaction copyWith(
          {String? id,
          double? amount,
          Value<String?> categoryKey = const Value.absent(),
          String? type,
          DateTime? date,
          Value<String?> note = const Value.absent()}) =>
      Transaction(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        categoryKey: categoryKey.present ? categoryKey.value : this.categoryKey,
        type: type ?? this.type,
        date: date ?? this.date,
        note: note.present ? note.value : this.note,
      );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      categoryKey:
          data.categoryKey.present ? data.categoryKey.value : this.categoryKey,
      type: data.type.present ? data.type.value : this.type,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('categoryKey: $categoryKey, ')
          ..write('type: $type, ')
          ..write('date: $date, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, amount, categoryKey, type, date, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.categoryKey == this.categoryKey &&
          other.type == this.type &&
          other.date == this.date &&
          other.note == this.note);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> id;
  final Value<double> amount;
  final Value<String?> categoryKey;
  final Value<String> type;
  final Value<DateTime> date;
  final Value<String?> note;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.categoryKey = const Value.absent(),
    this.type = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required double amount,
    this.categoryKey = const Value.absent(),
    required String type,
    required DateTime date,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        amount = Value(amount),
        type = Value(type),
        date = Value(date);
  static Insertable<Transaction> custom({
    Expression<String>? id,
    Expression<double>? amount,
    Expression<String>? categoryKey,
    Expression<String>? type,
    Expression<DateTime>? date,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (categoryKey != null) 'category_key': categoryKey,
      if (type != null) 'type': type,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith(
      {Value<String>? id,
      Value<double>? amount,
      Value<String?>? categoryKey,
      Value<String>? type,
      Value<DateTime>? date,
      Value<String?>? note,
      Value<int>? rowid}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryKey: categoryKey ?? this.categoryKey,
      type: type ?? this.type,
      date: date ?? this.date,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (categoryKey.present) {
      map['category_key'] = Variable<String>(categoryKey.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('categoryKey: $categoryKey, ')
          ..write('type: $type, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryKeyMeta =
      const VerificationMeta('categoryKey');
  @override
  late final GeneratedColumn<String> categoryKey = GeneratedColumn<String>(
      'category_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _limitAmountMeta =
      const VerificationMeta('limitAmount');
  @override
  late final GeneratedColumn<double> limitAmount = GeneratedColumn<double>(
      'limit_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<int> month = GeneratedColumn<int>(
      'month', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
      'year', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, categoryKey, limitAmount, month, year];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(Insertable<Budget> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_key')) {
      context.handle(
          _categoryKeyMeta,
          categoryKey.isAcceptableOrUnknown(
              data['category_key']!, _categoryKeyMeta));
    }
    if (data.containsKey('limit_amount')) {
      context.handle(
          _limitAmountMeta,
          limitAmount.isAcceptableOrUnknown(
              data['limit_amount']!, _limitAmountMeta));
    } else if (isInserting) {
      context.missing(_limitAmountMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
          _monthMeta, month.isAcceptableOrUnknown(data['month']!, _monthMeta));
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
          _yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      categoryKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_key']),
      limitAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}limit_amount'])!,
      month: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}month'])!,
      year: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}year'])!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  final String id;
  final String? categoryKey;
  final double limitAmount;
  final int month;
  final int year;
  const Budget(
      {required this.id,
      this.categoryKey,
      required this.limitAmount,
      required this.month,
      required this.year});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || categoryKey != null) {
      map['category_key'] = Variable<String>(categoryKey);
    }
    map['limit_amount'] = Variable<double>(limitAmount);
    map['month'] = Variable<int>(month);
    map['year'] = Variable<int>(year);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      categoryKey: categoryKey == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryKey),
      limitAmount: Value(limitAmount),
      month: Value(month),
      year: Value(year),
    );
  }

  factory Budget.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      id: serializer.fromJson<String>(json['id']),
      categoryKey: serializer.fromJson<String?>(json['categoryKey']),
      limitAmount: serializer.fromJson<double>(json['limitAmount']),
      month: serializer.fromJson<int>(json['month']),
      year: serializer.fromJson<int>(json['year']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryKey': serializer.toJson<String?>(categoryKey),
      'limitAmount': serializer.toJson<double>(limitAmount),
      'month': serializer.toJson<int>(month),
      'year': serializer.toJson<int>(year),
    };
  }

  Budget copyWith(
          {String? id,
          Value<String?> categoryKey = const Value.absent(),
          double? limitAmount,
          int? month,
          int? year}) =>
      Budget(
        id: id ?? this.id,
        categoryKey: categoryKey.present ? categoryKey.value : this.categoryKey,
        limitAmount: limitAmount ?? this.limitAmount,
        month: month ?? this.month,
        year: year ?? this.year,
      );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      id: data.id.present ? data.id.value : this.id,
      categoryKey:
          data.categoryKey.present ? data.categoryKey.value : this.categoryKey,
      limitAmount:
          data.limitAmount.present ? data.limitAmount.value : this.limitAmount,
      month: data.month.present ? data.month.value : this.month,
      year: data.year.present ? data.year.value : this.year,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('id: $id, ')
          ..write('categoryKey: $categoryKey, ')
          ..write('limitAmount: $limitAmount, ')
          ..write('month: $month, ')
          ..write('year: $year')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, categoryKey, limitAmount, month, year);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.id == this.id &&
          other.categoryKey == this.categoryKey &&
          other.limitAmount == this.limitAmount &&
          other.month == this.month &&
          other.year == this.year);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<String> id;
  final Value<String?> categoryKey;
  final Value<double> limitAmount;
  final Value<int> month;
  final Value<int> year;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.categoryKey = const Value.absent(),
    this.limitAmount = const Value.absent(),
    this.month = const Value.absent(),
    this.year = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String id,
    this.categoryKey = const Value.absent(),
    required double limitAmount,
    required int month,
    required int year,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        limitAmount = Value(limitAmount),
        month = Value(month),
        year = Value(year);
  static Insertable<Budget> custom({
    Expression<String>? id,
    Expression<String>? categoryKey,
    Expression<double>? limitAmount,
    Expression<int>? month,
    Expression<int>? year,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryKey != null) 'category_key': categoryKey,
      if (limitAmount != null) 'limit_amount': limitAmount,
      if (month != null) 'month': month,
      if (year != null) 'year': year,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? categoryKey,
      Value<double>? limitAmount,
      Value<int>? month,
      Value<int>? year,
      Value<int>? rowid}) {
    return BudgetsCompanion(
      id: id ?? this.id,
      categoryKey: categoryKey ?? this.categoryKey,
      limitAmount: limitAmount ?? this.limitAmount,
      month: month ?? this.month,
      year: year ?? this.year,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (categoryKey.present) {
      map['category_key'] = Variable<String>(categoryKey.value);
    }
    if (limitAmount.present) {
      map['limit_amount'] = Variable<double>(limitAmount.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('categoryKey: $categoryKey, ')
          ..write('limitAmount: $limitAmount, ')
          ..write('month: $month, ')
          ..write('year: $year, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomCategoriesTable extends CustomCategories
    with TableInfo<$CustomCategoriesTable, CustomCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorValueMeta =
      const VerificationMeta('colorValue');
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
      'color_value', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _iconIndexMeta =
      const VerificationMeta('iconIndex');
  @override
  late final GeneratedColumn<int> iconIndex = GeneratedColumn<int>(
      'icon_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, label, colorValue, iconIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_categories';
  @override
  VerificationContext validateIntegrity(Insertable<CustomCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
          _colorValueMeta,
          colorValue.isAcceptableOrUnknown(
              data['color_value']!, _colorValueMeta));
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('icon_index')) {
      context.handle(_iconIndexMeta,
          iconIndex.isAcceptableOrUnknown(data['icon_index']!, _iconIndexMeta));
    } else if (isInserting) {
      context.missing(_iconIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomCategory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      colorValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_value'])!,
      iconIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}icon_index'])!,
    );
  }

  @override
  $CustomCategoriesTable createAlias(String alias) {
    return $CustomCategoriesTable(attachedDatabase, alias);
  }
}

class CustomCategory extends DataClass implements Insertable<CustomCategory> {
  final String id;
  final String label;
  final int colorValue;
  final int iconIndex;
  const CustomCategory(
      {required this.id,
      required this.label,
      required this.colorValue,
      required this.iconIndex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['label'] = Variable<String>(label);
    map['color_value'] = Variable<int>(colorValue);
    map['icon_index'] = Variable<int>(iconIndex);
    return map;
  }

  CustomCategoriesCompanion toCompanion(bool nullToAbsent) {
    return CustomCategoriesCompanion(
      id: Value(id),
      label: Value(label),
      colorValue: Value(colorValue),
      iconIndex: Value(iconIndex),
    );
  }

  factory CustomCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomCategory(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      iconIndex: serializer.fromJson<int>(json['iconIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String>(label),
      'colorValue': serializer.toJson<int>(colorValue),
      'iconIndex': serializer.toJson<int>(iconIndex),
    };
  }

  CustomCategory copyWith(
          {String? id, String? label, int? colorValue, int? iconIndex}) =>
      CustomCategory(
        id: id ?? this.id,
        label: label ?? this.label,
        colorValue: colorValue ?? this.colorValue,
        iconIndex: iconIndex ?? this.iconIndex,
      );
  CustomCategory copyWithCompanion(CustomCategoriesCompanion data) {
    return CustomCategory(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      colorValue:
          data.colorValue.present ? data.colorValue.value : this.colorValue,
      iconIndex: data.iconIndex.present ? data.iconIndex.value : this.iconIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomCategory(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('colorValue: $colorValue, ')
          ..write('iconIndex: $iconIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label, colorValue, iconIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomCategory &&
          other.id == this.id &&
          other.label == this.label &&
          other.colorValue == this.colorValue &&
          other.iconIndex == this.iconIndex);
}

class CustomCategoriesCompanion extends UpdateCompanion<CustomCategory> {
  final Value<String> id;
  final Value<String> label;
  final Value<int> colorValue;
  final Value<int> iconIndex;
  final Value<int> rowid;
  const CustomCategoriesCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.iconIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomCategoriesCompanion.insert({
    required String id,
    required String label,
    required int colorValue,
    required int iconIndex,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        label = Value(label),
        colorValue = Value(colorValue),
        iconIndex = Value(iconIndex);
  static Insertable<CustomCategory> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<int>? colorValue,
    Expression<int>? iconIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (colorValue != null) 'color_value': colorValue,
      if (iconIndex != null) 'icon_index': iconIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomCategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? label,
      Value<int>? colorValue,
      Value<int>? iconIndex,
      Value<int>? rowid}) {
    return CustomCategoriesCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      colorValue: colorValue ?? this.colorValue,
      iconIndex: iconIndex ?? this.iconIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (iconIndex.present) {
      map['icon_index'] = Variable<int>(iconIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('colorValue: $colorValue, ')
          ..write('iconIndex: $iconIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrbitSlotsTable extends OrbitSlots
    with TableInfo<$OrbitSlotsTable, OrbitSlot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrbitSlotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _slotIndexMeta =
      const VerificationMeta('slotIndex');
  @override
  late final GeneratedColumn<int> slotIndex = GeneratedColumn<int>(
      'slot_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _categoryKeyMeta =
      const VerificationMeta('categoryKey');
  @override
  late final GeneratedColumn<String> categoryKey = GeneratedColumn<String>(
      'category_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isCustomMeta =
      const VerificationMeta('isCustom');
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
      'is_custom', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_custom" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [slotIndex, categoryKey, isCustom];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'orbit_slots';
  @override
  VerificationContext validateIntegrity(Insertable<OrbitSlot> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('slot_index')) {
      context.handle(_slotIndexMeta,
          slotIndex.isAcceptableOrUnknown(data['slot_index']!, _slotIndexMeta));
    }
    if (data.containsKey('category_key')) {
      context.handle(
          _categoryKeyMeta,
          categoryKey.isAcceptableOrUnknown(
              data['category_key']!, _categoryKeyMeta));
    } else if (isInserting) {
      context.missing(_categoryKeyMeta);
    }
    if (data.containsKey('is_custom')) {
      context.handle(_isCustomMeta,
          isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta));
    } else if (isInserting) {
      context.missing(_isCustomMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {slotIndex};
  @override
  OrbitSlot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrbitSlot(
      slotIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}slot_index'])!,
      categoryKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_key'])!,
      isCustom: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_custom'])!,
    );
  }

  @override
  $OrbitSlotsTable createAlias(String alias) {
    return $OrbitSlotsTable(attachedDatabase, alias);
  }
}

class OrbitSlot extends DataClass implements Insertable<OrbitSlot> {
  final int slotIndex;
  final String categoryKey;
  final bool isCustom;
  const OrbitSlot(
      {required this.slotIndex,
      required this.categoryKey,
      required this.isCustom});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['slot_index'] = Variable<int>(slotIndex);
    map['category_key'] = Variable<String>(categoryKey);
    map['is_custom'] = Variable<bool>(isCustom);
    return map;
  }

  OrbitSlotsCompanion toCompanion(bool nullToAbsent) {
    return OrbitSlotsCompanion(
      slotIndex: Value(slotIndex),
      categoryKey: Value(categoryKey),
      isCustom: Value(isCustom),
    );
  }

  factory OrbitSlot.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrbitSlot(
      slotIndex: serializer.fromJson<int>(json['slotIndex']),
      categoryKey: serializer.fromJson<String>(json['categoryKey']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'slotIndex': serializer.toJson<int>(slotIndex),
      'categoryKey': serializer.toJson<String>(categoryKey),
      'isCustom': serializer.toJson<bool>(isCustom),
    };
  }

  OrbitSlot copyWith({int? slotIndex, String? categoryKey, bool? isCustom}) =>
      OrbitSlot(
        slotIndex: slotIndex ?? this.slotIndex,
        categoryKey: categoryKey ?? this.categoryKey,
        isCustom: isCustom ?? this.isCustom,
      );
  OrbitSlot copyWithCompanion(OrbitSlotsCompanion data) {
    return OrbitSlot(
      slotIndex: data.slotIndex.present ? data.slotIndex.value : this.slotIndex,
      categoryKey:
          data.categoryKey.present ? data.categoryKey.value : this.categoryKey,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrbitSlot(')
          ..write('slotIndex: $slotIndex, ')
          ..write('categoryKey: $categoryKey, ')
          ..write('isCustom: $isCustom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(slotIndex, categoryKey, isCustom);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrbitSlot &&
          other.slotIndex == this.slotIndex &&
          other.categoryKey == this.categoryKey &&
          other.isCustom == this.isCustom);
}

class OrbitSlotsCompanion extends UpdateCompanion<OrbitSlot> {
  final Value<int> slotIndex;
  final Value<String> categoryKey;
  final Value<bool> isCustom;
  const OrbitSlotsCompanion({
    this.slotIndex = const Value.absent(),
    this.categoryKey = const Value.absent(),
    this.isCustom = const Value.absent(),
  });
  OrbitSlotsCompanion.insert({
    this.slotIndex = const Value.absent(),
    required String categoryKey,
    required bool isCustom,
  })  : categoryKey = Value(categoryKey),
        isCustom = Value(isCustom);
  static Insertable<OrbitSlot> custom({
    Expression<int>? slotIndex,
    Expression<String>? categoryKey,
    Expression<bool>? isCustom,
  }) {
    return RawValuesInsertable({
      if (slotIndex != null) 'slot_index': slotIndex,
      if (categoryKey != null) 'category_key': categoryKey,
      if (isCustom != null) 'is_custom': isCustom,
    });
  }

  OrbitSlotsCompanion copyWith(
      {Value<int>? slotIndex,
      Value<String>? categoryKey,
      Value<bool>? isCustom}) {
    return OrbitSlotsCompanion(
      slotIndex: slotIndex ?? this.slotIndex,
      categoryKey: categoryKey ?? this.categoryKey,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (slotIndex.present) {
      map['slot_index'] = Variable<int>(slotIndex.value);
    }
    if (categoryKey.present) {
      map['category_key'] = Variable<String>(categoryKey.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrbitSlotsCompanion(')
          ..write('slotIndex: $slotIndex, ')
          ..write('categoryKey: $categoryKey, ')
          ..write('isCustom: $isCustom')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $CustomCategoriesTable customCategories =
      $CustomCategoriesTable(this);
  late final $OrbitSlotsTable orbitSlots = $OrbitSlotsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [transactions, budgets, customCategories, orbitSlots];
}

typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  required String id,
  required double amount,
  Value<String?> categoryKey,
  required String type,
  required DateTime date,
  Value<String?> note,
  Value<int> rowid,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<String> id,
  Value<double> amount,
  Value<String?> categoryKey,
  Value<String> type,
  Value<DateTime> date,
  Value<String?> note,
  Value<int> rowid,
});

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryKey => $composableBuilder(
      column: $table.categoryKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryKey => $composableBuilder(
      column: $table.categoryKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get categoryKey => $composableBuilder(
      column: $table.categoryKey, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$TransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (
      Transaction,
      BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>
    ),
    Transaction,
    PrefetchHooks Function()> {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String?> categoryKey = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsCompanion(
            id: id,
            amount: amount,
            categoryKey: categoryKey,
            type: type,
            date: date,
            note: note,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required double amount,
            Value<String?> categoryKey = const Value.absent(),
            required String type,
            required DateTime date,
            Value<String?> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsCompanion.insert(
            id: id,
            amount: amount,
            categoryKey: categoryKey,
            type: type,
            date: date,
            note: note,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (
      Transaction,
      BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>
    ),
    Transaction,
    PrefetchHooks Function()>;
typedef $$BudgetsTableCreateCompanionBuilder = BudgetsCompanion Function({
  required String id,
  Value<String?> categoryKey,
  required double limitAmount,
  required int month,
  required int year,
  Value<int> rowid,
});
typedef $$BudgetsTableUpdateCompanionBuilder = BudgetsCompanion Function({
  Value<String> id,
  Value<String?> categoryKey,
  Value<double> limitAmount,
  Value<int> month,
  Value<int> year,
  Value<int> rowid,
});

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryKey => $composableBuilder(
      column: $table.categoryKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get limitAmount => $composableBuilder(
      column: $table.limitAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get month => $composableBuilder(
      column: $table.month, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnFilters(column));
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryKey => $composableBuilder(
      column: $table.categoryKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get limitAmount => $composableBuilder(
      column: $table.limitAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get month => $composableBuilder(
      column: $table.month, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnOrderings(column));
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get categoryKey => $composableBuilder(
      column: $table.categoryKey, builder: (column) => column);

  GeneratedColumn<double> get limitAmount => $composableBuilder(
      column: $table.limitAmount, builder: (column) => column);

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);
}

class $$BudgetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BudgetsTable,
    Budget,
    $$BudgetsTableFilterComposer,
    $$BudgetsTableOrderingComposer,
    $$BudgetsTableAnnotationComposer,
    $$BudgetsTableCreateCompanionBuilder,
    $$BudgetsTableUpdateCompanionBuilder,
    (Budget, BaseReferences<_$AppDatabase, $BudgetsTable, Budget>),
    Budget,
    PrefetchHooks Function()> {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> categoryKey = const Value.absent(),
            Value<double> limitAmount = const Value.absent(),
            Value<int> month = const Value.absent(),
            Value<int> year = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BudgetsCompanion(
            id: id,
            categoryKey: categoryKey,
            limitAmount: limitAmount,
            month: month,
            year: year,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> categoryKey = const Value.absent(),
            required double limitAmount,
            required int month,
            required int year,
            Value<int> rowid = const Value.absent(),
          }) =>
              BudgetsCompanion.insert(
            id: id,
            categoryKey: categoryKey,
            limitAmount: limitAmount,
            month: month,
            year: year,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BudgetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BudgetsTable,
    Budget,
    $$BudgetsTableFilterComposer,
    $$BudgetsTableOrderingComposer,
    $$BudgetsTableAnnotationComposer,
    $$BudgetsTableCreateCompanionBuilder,
    $$BudgetsTableUpdateCompanionBuilder,
    (Budget, BaseReferences<_$AppDatabase, $BudgetsTable, Budget>),
    Budget,
    PrefetchHooks Function()>;
typedef $$CustomCategoriesTableCreateCompanionBuilder
    = CustomCategoriesCompanion Function({
  required String id,
  required String label,
  required int colorValue,
  required int iconIndex,
  Value<int> rowid,
});
typedef $$CustomCategoriesTableUpdateCompanionBuilder
    = CustomCategoriesCompanion Function({
  Value<String> id,
  Value<String> label,
  Value<int> colorValue,
  Value<int> iconIndex,
  Value<int> rowid,
});

class $$CustomCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CustomCategoriesTable> {
  $$CustomCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get iconIndex => $composableBuilder(
      column: $table.iconIndex, builder: (column) => ColumnFilters(column));
}

class $$CustomCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomCategoriesTable> {
  $$CustomCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get iconIndex => $composableBuilder(
      column: $table.iconIndex, builder: (column) => ColumnOrderings(column));
}

class $$CustomCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomCategoriesTable> {
  $$CustomCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => column);

  GeneratedColumn<int> get iconIndex =>
      $composableBuilder(column: $table.iconIndex, builder: (column) => column);
}

class $$CustomCategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CustomCategoriesTable,
    CustomCategory,
    $$CustomCategoriesTableFilterComposer,
    $$CustomCategoriesTableOrderingComposer,
    $$CustomCategoriesTableAnnotationComposer,
    $$CustomCategoriesTableCreateCompanionBuilder,
    $$CustomCategoriesTableUpdateCompanionBuilder,
    (
      CustomCategory,
      BaseReferences<_$AppDatabase, $CustomCategoriesTable, CustomCategory>
    ),
    CustomCategory,
    PrefetchHooks Function()> {
  $$CustomCategoriesTableTableManager(
      _$AppDatabase db, $CustomCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<int> colorValue = const Value.absent(),
            Value<int> iconIndex = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomCategoriesCompanion(
            id: id,
            label: label,
            colorValue: colorValue,
            iconIndex: iconIndex,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String label,
            required int colorValue,
            required int iconIndex,
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomCategoriesCompanion.insert(
            id: id,
            label: label,
            colorValue: colorValue,
            iconIndex: iconIndex,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CustomCategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CustomCategoriesTable,
    CustomCategory,
    $$CustomCategoriesTableFilterComposer,
    $$CustomCategoriesTableOrderingComposer,
    $$CustomCategoriesTableAnnotationComposer,
    $$CustomCategoriesTableCreateCompanionBuilder,
    $$CustomCategoriesTableUpdateCompanionBuilder,
    (
      CustomCategory,
      BaseReferences<_$AppDatabase, $CustomCategoriesTable, CustomCategory>
    ),
    CustomCategory,
    PrefetchHooks Function()>;
typedef $$OrbitSlotsTableCreateCompanionBuilder = OrbitSlotsCompanion Function({
  Value<int> slotIndex,
  required String categoryKey,
  required bool isCustom,
});
typedef $$OrbitSlotsTableUpdateCompanionBuilder = OrbitSlotsCompanion Function({
  Value<int> slotIndex,
  Value<String> categoryKey,
  Value<bool> isCustom,
});

class $$OrbitSlotsTableFilterComposer
    extends Composer<_$AppDatabase, $OrbitSlotsTable> {
  $$OrbitSlotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get slotIndex => $composableBuilder(
      column: $table.slotIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryKey => $composableBuilder(
      column: $table.categoryKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCustom => $composableBuilder(
      column: $table.isCustom, builder: (column) => ColumnFilters(column));
}

class $$OrbitSlotsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrbitSlotsTable> {
  $$OrbitSlotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get slotIndex => $composableBuilder(
      column: $table.slotIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryKey => $composableBuilder(
      column: $table.categoryKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCustom => $composableBuilder(
      column: $table.isCustom, builder: (column) => ColumnOrderings(column));
}

class $$OrbitSlotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrbitSlotsTable> {
  $$OrbitSlotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get slotIndex =>
      $composableBuilder(column: $table.slotIndex, builder: (column) => column);

  GeneratedColumn<String> get categoryKey => $composableBuilder(
      column: $table.categoryKey, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);
}

class $$OrbitSlotsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrbitSlotsTable,
    OrbitSlot,
    $$OrbitSlotsTableFilterComposer,
    $$OrbitSlotsTableOrderingComposer,
    $$OrbitSlotsTableAnnotationComposer,
    $$OrbitSlotsTableCreateCompanionBuilder,
    $$OrbitSlotsTableUpdateCompanionBuilder,
    (OrbitSlot, BaseReferences<_$AppDatabase, $OrbitSlotsTable, OrbitSlot>),
    OrbitSlot,
    PrefetchHooks Function()> {
  $$OrbitSlotsTableTableManager(_$AppDatabase db, $OrbitSlotsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrbitSlotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrbitSlotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrbitSlotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> slotIndex = const Value.absent(),
            Value<String> categoryKey = const Value.absent(),
            Value<bool> isCustom = const Value.absent(),
          }) =>
              OrbitSlotsCompanion(
            slotIndex: slotIndex,
            categoryKey: categoryKey,
            isCustom: isCustom,
          ),
          createCompanionCallback: ({
            Value<int> slotIndex = const Value.absent(),
            required String categoryKey,
            required bool isCustom,
          }) =>
              OrbitSlotsCompanion.insert(
            slotIndex: slotIndex,
            categoryKey: categoryKey,
            isCustom: isCustom,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OrbitSlotsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OrbitSlotsTable,
    OrbitSlot,
    $$OrbitSlotsTableFilterComposer,
    $$OrbitSlotsTableOrderingComposer,
    $$OrbitSlotsTableAnnotationComposer,
    $$OrbitSlotsTableCreateCompanionBuilder,
    $$OrbitSlotsTableUpdateCompanionBuilder,
    (OrbitSlot, BaseReferences<_$AppDatabase, $OrbitSlotsTable, OrbitSlot>),
    OrbitSlot,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$CustomCategoriesTableTableManager get customCategories =>
      $$CustomCategoriesTableTableManager(_db, _db.customCategories);
  $$OrbitSlotsTableTableManager get orbitSlots =>
      $$OrbitSlotsTableTableManager(_db, _db.orbitSlots);
}
