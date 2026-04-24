import 'package:shared_preferences/shared_preferences.dart';

import '../models/custom_category_model.dart';
import '../models/orbit_slot_model.dart';
import 'custom_category_local_datasource.dart';

const List<String> defaultOrbitSlotCategoryKeys = <String>[
  'entertainment',
  'clothing',
  'communication',
  'housing',
  'transport',
  'food',
  'sport',
  'health',
];

abstract class OrbitSlotDatasource {
  Future<List<OrbitSlotModel>> getSlots();

  Future<void> setSlot(int slotIndex, String categoryKey, bool isCustom);

  Future<void> resetSlot(int slotIndex);
}

class OrbitSlotDatasourceImpl implements OrbitSlotDatasource {
  const OrbitSlotDatasourceImpl({
    required SharedPreferences sharedPreferences,
    required CustomCategoryLocalDatasource customCategoryDatasource,
  })  : _sharedPreferences = sharedPreferences,
        _customCategoryDatasource = customCategoryDatasource;

  static const String _categoryKeyPrefix = 'home_orbit_slot_category_';
  static const String _isCustomPrefix = 'home_orbit_slot_is_custom_';

  final SharedPreferences _sharedPreferences;
  final CustomCategoryLocalDatasource _customCategoryDatasource;

  @override
  Future<List<OrbitSlotModel>> getSlots() async {
    final List<OrbitSlotModel> slots = <OrbitSlotModel>[];

    for (int index = 0; index < defaultOrbitSlotCategoryKeys.length; index++) {
      final OrbitSlotModel slot = _storedSlot(index);
      if (slot.isCustom) {
        final CustomCategoryModel? category =
            await _customCategoryDatasource.getById(slot.categoryKey);
        if (category == null) {
          await resetSlot(index);
          slots.add(_defaultSlot(index));
          continue;
        }
      } else if (!defaultOrbitSlotCategoryKeys.contains(slot.categoryKey)) {
        await resetSlot(index);
        slots.add(_defaultSlot(index));
        continue;
      }

      slots.add(slot);
    }

    return slots;
  }

  @override
  Future<void> setSlot(int slotIndex, String categoryKey, bool isCustom) async {
    if (!_isValidSlotIndex(slotIndex)) {
      return;
    }

    for (int index = 0; index < defaultOrbitSlotCategoryKeys.length; index++) {
      if (index == slotIndex) {
        continue;
      }

      final OrbitSlotModel slot = _storedSlot(index);
      if (slot.categoryKey == categoryKey && slot.isCustom == isCustom) {
        await resetSlot(index);
      }
    }

    await _sharedPreferences.setString(
      _categoryKey(slotIndex),
      categoryKey,
    );
    await _sharedPreferences.setBool(
      _isCustomKey(slotIndex),
      isCustom,
    );
  }

  @override
  Future<void> resetSlot(int slotIndex) async {
    if (!_isValidSlotIndex(slotIndex)) {
      return;
    }

    await _sharedPreferences.remove(_categoryKey(slotIndex));
    await _sharedPreferences.remove(_isCustomKey(slotIndex));
  }

  OrbitSlotModel _defaultSlot(int slotIndex) {
    return OrbitSlotModel()
      ..slotIndex = slotIndex
      ..categoryKey = defaultOrbitSlotCategoryKeys[slotIndex]
      ..isCustom = false;
  }

  OrbitSlotModel _storedSlot(int slotIndex) {
    final String? categoryKey = _sharedPreferences.getString(
      _categoryKey(slotIndex),
    );
    final bool isCustom =
        _sharedPreferences.getBool(_isCustomKey(slotIndex)) ?? false;

    if (categoryKey == null) {
      return _defaultSlot(slotIndex);
    }

    return OrbitSlotModel()
      ..slotIndex = slotIndex
      ..categoryKey = categoryKey
      ..isCustom = isCustom;
  }

  bool _isValidSlotIndex(int slotIndex) {
    return slotIndex >= 0 && slotIndex < defaultOrbitSlotCategoryKeys.length;
  }

  String _categoryKey(int slotIndex) => '$_categoryKeyPrefix$slotIndex';

  String _isCustomKey(int slotIndex) => '$_isCustomPrefix$slotIndex';
}
