import 'package:isar/isar.dart';

import '../models/custom_category_model.dart';

abstract class CustomCategoryLocalDatasource {
  Future<List<CustomCategoryModel>> getAll();

  Future<CustomCategoryModel?> getById(String id);

  Future<void> save(CustomCategoryModel model);

  Future<void> delete(String id);
}

class CustomCategoryLocalDatasourceImpl
    implements CustomCategoryLocalDatasource {
  const CustomCategoryLocalDatasourceImpl(this._isar);

  final Isar _isar;

  @override
  Future<List<CustomCategoryModel>> getAll() async {
    final List<CustomCategoryModel> categories =
        await _isar.customCategoryModels.where().findAll();
    categories.sort(
      (CustomCategoryModel a, CustomCategoryModel b) =>
          a.label.toLowerCase().compareTo(b.label.toLowerCase()),
    );
    return categories;
  }

  @override
  Future<CustomCategoryModel?> getById(String id) async {
    final List<CustomCategoryModel> categories = await getAll();
    for (final CustomCategoryModel category in categories) {
      if (category.id == id) {
        return category;
      }
    }

    return null;
  }

  @override
  Future<void> save(CustomCategoryModel model) async {
    final CustomCategoryModel? existing = await getById(model.id);
    if (existing != null) {
      model.isarId = existing.isarId;
    }

    await _isar.writeTxn(() async {
      await _isar.customCategoryModels.put(model);
    });
  }

  @override
  Future<void> delete(String id) async {
    final CustomCategoryModel? existing = await getById(id);
    if (existing == null) {
      return;
    }

    await _isar.writeTxn(() async {
      await _isar.customCategoryModels.delete(existing.isarId);
    });
  }
}
