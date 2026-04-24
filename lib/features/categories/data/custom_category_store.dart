import 'package:flutter/foundation.dart'
    show ValueListenable, ValueNotifier, debugPrint;

import '../../../core/mock/mock_data.dart';
import '../domain/entities/category.dart';
import '../../auth/domain/repositories/auth_repository.dart';
import 'datasources/custom_category_local_datasource.dart';
import 'datasources/custom_category_remote_datasource.dart';
import 'models/custom_category_model.dart';

class CustomCategoryStore {
  CustomCategoryStore({
    required CustomCategoryLocalDatasource localDatasource,
    required CustomCategoryRemoteDatasource remoteDatasource,
    required AuthRepository authRepository,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource,
        _authRepository = authRepository;

  final CustomCategoryLocalDatasource _localDatasource;
  final CustomCategoryRemoteDatasource _remoteDatasource;
  final AuthRepository _authRepository;
  final ValueNotifier<List<CustomCategoryModel>> _categories =
      ValueNotifier<List<CustomCategoryModel>>(<CustomCategoryModel>[]);

  bool _loaded = false;

  ValueListenable<List<CustomCategoryModel>> get listenable => _categories;

  List<CustomCategoryModel> get models => _categories.value;

  List<Category> get customCategories =>
      models.map((CustomCategoryModel model) => model.toCategory()).toList();

  Future<void> ensureLoaded() async {
    if (_loaded) {
      return;
    }

    await reload();
  }

  Future<void> reload() async {
    _categories.value = await _localDatasource.getAll();
    _loaded = true;
  }

  Category? resolveCategory(String? key) {
    final Category? builtInCategory = MockData.categoryByKey(key);
    if (builtInCategory != null) {
      return builtInCategory;
    }
    if (key == null) {
      return null;
    }

    for (final CustomCategoryModel model in models) {
      if (model.id == key) {
        return model.toCategory();
      }
    }

    return null;
  }

  Future<void> save(CustomCategoryModel model) async {
    await _localDatasource.save(model);
    await reload();
    _mirrorToRemote(() => _remoteDatasource.save(model));
  }

  Future<void> delete(String id) async {
    await _localDatasource.delete(id);
    await reload();
    _mirrorToRemote(() => _remoteDatasource.delete(id));
  }

  void _mirrorToRemote(Future<void> Function() action) {
    if (_authRepository.currentUserId == null) {
      return;
    }

    Future<void>.microtask(() async {
      try {
        await action();
      } catch (error) {
        debugPrint('Firestore category sync failed: $error');
      }
    });
  }
}
