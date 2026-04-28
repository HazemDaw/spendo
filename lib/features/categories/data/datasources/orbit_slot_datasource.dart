import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
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
    required AppDatabase db,
    required CustomCategoryLocalDatasource customCategoryDatasource,
  })  : _db = db,
        _customCategoryDatasource = customCategoryDatasource;

  final AppDatabase _db;
  final CustomCategoryLocalDatasource _customCategoryDatasource;

  @override
  Future<List<OrbitSlotModel>> getSlots() async {
    final List<OrbitSlot> rows = await _db.select(_db.orbitSlots).get();
    final Map<int, OrbitSlotModel> storedSlots = <int, OrbitSlotModel>{
      for (final OrbitSlot row in rows) row.slotIndex: _rowToModel(row),
    };
    final List<OrbitSlotModel> slots = <OrbitSlotModel>[];

    for (int index = 0; index < defaultOrbitSlotCategoryKeys.length; index++) {
      final OrbitSlotModel slot = storedSlots[index] ?? _defaultSlot(index);
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

    await _db.transaction(() async {
      final List<OrbitSlot> rows = await _db.select(_db.orbitSlots).get();
      final Map<int, OrbitSlotModel> storedSlots = <int, OrbitSlotModel>{
        for (final OrbitSlot row in rows) row.slotIndex: _rowToModel(row),
      };

      for (int index = 0;
          index < defaultOrbitSlotCategoryKeys.length;
          index++) {
        if (index == slotIndex) {
          continue;
        }

        final OrbitSlotModel slot = storedSlots[index] ?? _defaultSlot(index);
        if (slot.categoryKey == categoryKey && slot.isCustom == isCustom) {
          await (_db.delete(_db.orbitSlots)
                ..where((o) => o.slotIndex.equals(index)))
              .go();
        }
      }

      await _db.into(_db.orbitSlots).insertOnConflictUpdate(
            OrbitSlotsCompanion(
              slotIndex: Value<int>(slotIndex),
              categoryKey: Value<String>(categoryKey),
              isCustom: Value<bool>(isCustom),
            ),
          );
    });
  }

  @override
  Future<void> resetSlot(int slotIndex) async {
    if (!_isValidSlotIndex(slotIndex)) {
      return;
    }

    await (_db.delete(_db.orbitSlots)
          ..where((o) => o.slotIndex.equals(slotIndex)))
        .go();
  }

  OrbitSlotModel _defaultSlot(int slotIndex) {
    return OrbitSlotModel()
      ..slotIndex = slotIndex
      ..categoryKey = defaultOrbitSlotCategoryKeys[slotIndex]
      ..isCustom = false;
  }

  OrbitSlotModel _rowToModel(OrbitSlot row) {
    return OrbitSlotModel()
      ..slotIndex = row.slotIndex
      ..categoryKey = row.categoryKey
      ..isCustom = row.isCustom;
  }

  bool _isValidSlotIndex(int slotIndex) {
    return slotIndex >= 0 && slotIndex < defaultOrbitSlotCategoryKeys.length;
  }
}
