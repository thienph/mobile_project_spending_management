import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// Tables
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get icon => text()();
  TextColumn get color => text()();
  TextColumn get type => text()(); // 'income' or 'expense'
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get date => dateTime()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get type => text()(); // 'income' or 'expense'
  TextColumn get note => text().nullable()();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  IntColumn get recurringTransactionId => integer().nullable().references(RecurringTransactions, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class RecurringTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get description => text().nullable()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get type => text()(); // 'income' or 'expense'
  TextColumn get frequency => text()(); // 'daily', 'weekly', 'monthly', 'yearly'
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  DateTimeColumn get nextOccurrence => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class SavingGoals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  RealColumn get targetAmount => real()();
  RealColumn get currentAmount => real().withDefault(const Constant(0))();
  DateTimeColumn get targetDate => dateTime().nullable()();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  RealColumn get amount => real()();
  TextColumn get period => text()(); // 'daily', 'weekly', 'monthly', 'yearly'
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  BoolColumn get alertEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get alertThreshold => integer().withDefault(const Constant(80))(); // Alert when 80% reached
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [
  Categories,
  Transactions,
  RecurringTransactions,
  SavingGoals,
  Budgets,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Insert default categories
        await _insertDefaultCategories();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle future migrations here
      },
    );
  }

  Future<void> _insertDefaultCategories() async {
    // Default expense categories
    await into(categories).insert(CategoriesCompanion.insert(
      name: 'Ăn uống',
      icon: '🍔',
      color: '#FF6B6B',
      type: 'expense',
      isDefault: const Value(true),
    ));
    await into(categories).insert(CategoriesCompanion.insert(
      name: 'Đi lại',
      icon: '🚗',
      color: '#4ECDC4',
      type: 'expense',
      isDefault: const Value(true),
    ));
    await into(categories).insert(CategoriesCompanion.insert(
      name: 'Mua sắm',
      icon: '🛍️',
      color: '#95E1D3',
      type: 'expense',
      isDefault: const Value(true),
    ));
    await into(categories).insert(CategoriesCompanion.insert(
      name: 'Giải trí',
      icon: '🎮',
      color: '#F38181',
      type: 'expense',
      isDefault: const Value(true),
    ));
    await into(categories).insert(CategoriesCompanion.insert(
      name: 'Y tế',
      icon: '🏥',
      color: '#AA96DA',
      type: 'expense',
      isDefault: const Value(true),
    ));
    await into(categories).insert(CategoriesCompanion.insert(
      name: 'Giáo dục',
      icon: '📚',
      color: '#FCBAD3',
      type: 'expense',
      isDefault: const Value(true),
    ));
    await into(categories).insert(CategoriesCompanion.insert(
      name: 'Hóa đơn',
      icon: '📄',
      color: '#FFFFD2',
      type: 'expense',
      isDefault: const Value(true),
    ));
    await into(categories).insert(CategoriesCompanion.insert(
      name: 'Khác',
      icon: '📦',
      color: '#A8DADC',
      type: 'expense',
      isDefault: const Value(true),
    ));

    // Default income categories
    await into(categories).insert(CategoriesCompanion.insert(
      name: 'Lương',
      icon: '💰',
      color: '#06D6A0',
      type: 'income',
      isDefault: const Value(true),
    ));
    await into(categories).insert(CategoriesCompanion.insert(
      name: 'Thưởng',
      icon: '🎁',
      color: '#118AB2',
      type: 'income',
      isDefault: const Value(true),
    ));
    await into(categories).insert(CategoriesCompanion.insert(
      name: 'Đầu tư',
      icon: '📈',
      color: '#073B4C',
      type: 'income',
      isDefault: const Value(true),
    ));
    await into(categories).insert(CategoriesCompanion.insert(
      name: 'Thu nhập khác',
      icon: '💵',
      color: '#06D6A0',
      type: 'income',
      isDefault: const Value(true),
    ));
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'spending_management.db'));
    return NativeDatabase(file);
  });
}
