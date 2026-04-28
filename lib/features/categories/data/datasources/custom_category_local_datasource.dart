import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/custom_category_model.dart';

abstract class CustomCategoryLocalDatasource {
  Future<List<CustomCategoryModel>> getAll();

  Future<CustomCategoryModel?> getById(String id);

  Future<void> save(CustomCategoryModel model);

  Future<void> delete(String id);
}

class CustomCategoryLocalDatasourceImpl
    implements CustomCategoryLocalDatasource {
  const CustomCategoryLocalDatasourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<CustomCategoryModel>> getAll() async {
    final List<CustomCategory> rows =
        await _db.select(_db.customCategories).get();
    final List<CustomCategoryModel> categories = rows.map(_rowToModel).toList();
    categories.sort(
      (CustomCategoryModel a, CustomCategoryModel b) =>
          a.label.toLowerCase().compareTo(b.label.toLowerCase()),
    );
    return categories;
  }

  @override
  Future<CustomCategoryModel?> getById(String id) async {
    final CustomCategory? row = await (_db.select(_db.customCategories)
          ..where((c) => c.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _rowToModel(row);
  }

  @override
  Future<void> save(CustomCategoryModel model) async {
    await _db.into(_db.customCategories).insertOnConflictUpdate(
          CustomCategoriesCompanion(
            id: Value<String>(model.id),
            label: Value<String>(model.label),
            colorValue: Value<int>(model.colorValue),
            iconIndex: Value<int>(model.iconIndex),
          ),
        );
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.customCategories)..where((c) => c.id.equals(id)))
        .go();
  }

  CustomCategoryModel _rowToModel(CustomCategory row) {
    return CustomCategoryModel()
      ..id = row.id
      ..label = row.label
      ..colorValue = row.colorValue
      ..iconIndex = row.iconIndex;
  }
}
