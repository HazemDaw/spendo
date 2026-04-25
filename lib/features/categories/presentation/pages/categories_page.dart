import 'package:flutter/material.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/category_localizer.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/custom_category_store.dart';
import '../../data/datasources/orbit_slot_datasource.dart';
import '../../data/models/custom_category_model.dart';
import '../../data/models/orbit_slot_model.dart';
import '../../domain/entities/category.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  static const List<IconData> _iconChoices = <IconData>[
    Icons.star,
    Icons.favorite,
    Icons.work,
    Icons.school,
    Icons.flight,
    Icons.hotel,
    Icons.directions_bike,
    Icons.local_cafe,
    Icons.sports_soccer,
    Icons.music_note,
    Icons.movie,
    Icons.beach_access,
  ];

  final CustomCategoryStore _categoryStore = sl<CustomCategoryStore>();
  final OrbitSlotDatasource _orbitSlotDatasource = sl<OrbitSlotDatasource>();

  bool _isLoading = true;
  Map<int, String> _slotAssignments = <int, String>{};

  List<Category> get _builtInCategories => defaultOrbitSlotCategoryKeys
      .map((String key) => MockData.categoryByKey(key)!)
      .toList();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    await _categoryStore.ensureLoaded();
    final List<OrbitSlotModel> slots = await _orbitSlotDatasource.getSlots();
    if (!mounted) {
      return;
    }

    setState(() {
      _slotAssignments = <int, String>{
        for (final OrbitSlotModel slot in slots) slot.slotIndex: slot.categoryKey,
      };
      _isLoading = false;
    });
  }

  Future<void> _reloadSlotAssignments() async {
    final List<OrbitSlotModel> slots = await _orbitSlotDatasource.getSlots();
    if (!mounted) {
      return;
    }

    setState(() {
      _slotAssignments = <int, String>{
        for (final OrbitSlotModel slot in slots) slot.slotIndex: slot.categoryKey,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Категории'),
        actions: <Widget>[
          IconButton(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder<List<CustomCategoryModel>>(
              valueListenable: _categoryStore.listenable,
              builder: (
                BuildContext context,
                List<CustomCategoryModel> customCategories,
                _,
              ) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: Text(
                        'Встроенные (нажмите чтобы заменить)',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    ..._builtInCategories.asMap().entries.map(
                      (MapEntry<int, Category> entry) => _buildBuiltInTile(
                        entry.value,
                        entry.key,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _SectionHeader(title: 'Пользовательские'),
                    if (customCategories.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          'Нет пользовательских категорий.\nНажмите + чтобы добавить.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    else
                      ...customCategories.map(_buildCustomTile),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildBuiltInTile(Category category, int slotIndex) {
    final String? replacedBy = _getReplacingCustomKey(category.key);
    final CustomCategoryModel? customCategory = replacedBy == null
        ? null
        : _customCategoryById(replacedBy);

    if (customCategory == null) {
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: category.color.withValues(alpha: 0.15),
          child: Icon(category.icon, color: category.color, size: 20),
        ),
        title: Text(CategoryLocalizer.label(_l10n, category)),
        trailing: const Icon(
          Icons.swap_horiz,
          color: AppColors.primary,
        ),
        onTap: () => _showSwapDialog(slotIndex, category),
      );
    }

    final Color customColor = Color(customCategory.colorValue);
    final IconData customIcon = IconData(
      customCategory.iconCodePoint,
      fontFamily: customCategory.fontFamily,
    );

    return ListTile(
      leading: Stack(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: category.color.withValues(alpha: 0.15),
            child: Icon(category.icon, color: category.color, size: 20),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: customColor,
              child: Icon(customIcon, size: 12, color: Colors.white),
            ),
          ),
        ],
      ),
      title: Text(CategoryLocalizer.label(_l10n, category)),
      subtitle: Row(
        children: <Widget>[
          const Icon(
            Icons.arrow_forward,
            size: 12,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            customCategory.label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
            ),
          ),
        ],
      ),
      trailing: const Icon(
        Icons.swap_horiz,
        color: AppColors.primary,
      ),
      onTap: () => _showSwapDialog(slotIndex, category),
    );
  }

  Widget _buildCustomTile(CustomCategoryModel category) {
    final Color color = Color(category.colorValue);
    final IconData icon = IconData(
      category.iconCodePoint,
      fontFamily: category.fontFamily,
    );

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(category.label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            onPressed: () => _showEditDialog(category),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () => _confirmDelete(category),
            icon: const Icon(Icons.delete),
            color: AppColors.expense,
          ),
        ],
      ),
    );
  }

  Future<void> _showAddDialog() async {
    final _CategoryDialogResult? result = await _showCategoryDialog();
    if (result == null) {
      return;
    }

    await _saveCategory(result);
  }

  Future<void> _showEditDialog(CustomCategoryModel category) async {
    final _CategoryDialogResult? result = await _showCategoryDialog(
      initialCategory: category,
    );
    if (result == null) {
      return;
    }

    await _saveCategory(result, existingId: category.id);
  }

  Future<void> _saveCategory(
    _CategoryDialogResult result, {
    String? existingId,
  }) async {
    final CustomCategoryModel model = CustomCategoryModel()
      ..id = existingId ?? 'custom_${DateTime.now().microsecondsSinceEpoch}'
      ..label = result.label
      ..colorValue = result.color.toARGB32()
      ..iconCodePoint = result.icon.codePoint
      ..fontFamily = result.icon.fontFamily ?? 'MaterialIcons';

    await _categoryStore.save(model);
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> _confirmDelete(CustomCategoryModel category) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Удалить категорию?'),
          content: const Text(
            'Это не удалит существующие транзакции этой категории.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Удалить',
                style: TextStyle(color: AppColors.expense),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final bool affectsOrbit = (await _orbitSlotDatasource.getSlots()).any(
      (OrbitSlotModel slot) => slot.isCustom && slot.categoryKey == category.id,
    );
    await _categoryStore.delete(category.id);
    await _orbitSlotDatasource.getSlots();
    if (!mounted) {
      return;
    }

    if (affectsOrbit) {
      Navigator.pop(context, 'updated');
      return;
    }

    setState(() {});
  }

  Future<void> _showSwapDialog(int slotIndex, Category currentCategory) async {
    final List<CustomCategoryModel> customCategories = _categoryStore.models;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              height: 420,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Заменить '${CategoryLocalizer.label(_l10n, currentCategory)}'",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Выберите пользовательскую категорию',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: customCategories.isEmpty
                        ? const Center(
                            child: Text(
                              'Нет пользовательских категорий.\nСоздайте их с помощью кнопки +',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : ListView(
                            children: customCategories.map(
                              (CustomCategoryModel category) {
                                final Color color = Color(category.colorValue);
                                final IconData icon = IconData(
                                  category.iconCodePoint,
                                  fontFamily: category.fontFamily,
                                );

                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        color.withValues(alpha: 0.15),
                                    child: Icon(
                                      icon,
                                      color: color,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(category.label),
                                  trailing: const Icon(
                                    Icons.arrow_forward,
                                    color: AppColors.primary,
                                  ),
                                  onTap: () async {
                                    await _orbitSlotDatasource.setSlot(
                                      slotIndex,
                                      category.id,
                                      true,
                                    );
                                    if (!mounted ||
                                        !sheetContext.mounted ||
                                        !context.mounted) {
                                      return;
                                    }
                                    await _reloadSlotAssignments();
                                    if (!mounted ||
                                        !sheetContext.mounted ||
                                        !context.mounted) {
                                      return;
                                    }
                                    Navigator.pop(sheetContext);
                                    Navigator.pop(context, 'updated');
                                  },
                                );
                              },
                            ).toList(),
                          ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.restore,
                      color: AppColors.textSecondary,
                    ),
                    title: const Text('Восстановить по умолчанию'),
                    onTap: () async {
                      await _orbitSlotDatasource.resetSlot(slotIndex);
                      if (!mounted ||
                          !sheetContext.mounted ||
                          !context.mounted) {
                        return;
                      }
                      await _reloadSlotAssignments();
                      if (!mounted ||
                          !sheetContext.mounted ||
                          !context.mounted) {
                        return;
                      }
                      Navigator.pop(sheetContext);
                      Navigator.pop(context, 'updated');
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<_CategoryDialogResult?> _showCategoryDialog({
    CustomCategoryModel? initialCategory,
  }) {
    final TextEditingController controller = TextEditingController(
      text: initialCategory?.label ?? '',
    );
    Color selectedColor = initialCategory == null
        ? AppColors.categoryPalette.first
        : Color(initialCategory.colorValue);
    IconData selectedIcon = initialCategory == null
        ? _iconChoices.first
        : IconData(
            initialCategory.iconCodePoint,
            fontFamily: initialCategory.fontFamily,
          );
    String? errorText;

    return showDialog<_CategoryDialogResult>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              scrollable: true,
              title: Text(
                initialCategory == null ? 'Новая категория' : 'Редактировать',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Название',
                      errorText: errorText,
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Цвет:',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppColors.categoryPalette.map((Color color) {
                      final bool isSelected =
                          color.toARGB32() == selectedColor.toARGB32();
                      return InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () {
                          setState(() {
                            selectedColor = color;
                          });
                        },
                        child: CircleAvatar(
                          backgroundColor: color,
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Иконка:',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _iconChoices.map((IconData icon) {
                      final bool isSelected =
                          icon.codePoint == selectedIcon.codePoint;
                      return SizedBox(
                        width: 52,
                        height: 52,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              selectedIcon = icon;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.divider,
                              ),
                              color: isSelected
                                  ? AppColors.primaryLight
                                  : Colors.transparent,
                            ),
                            child: Icon(icon, color: selectedColor),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final String label = controller.text.trim();
                    if (label.isEmpty) {
                      setState(() {
                        errorText = 'Введите название';
                      });
                      return;
                    }

                    Navigator.pop(
                      context,
                      _CategoryDialogResult(
                        label: label,
                        color: selectedColor,
                        icon: selectedIcon,
                      ),
                    );
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  String? _getReplacingCustomKey(String categoryKey) {
    final int slotIndex = defaultOrbitSlotCategoryKeys.indexOf(categoryKey);
    if (slotIndex == -1) {
      return null;
    }

    final String assignedKey =
        _slotAssignments[slotIndex] ?? defaultOrbitSlotCategoryKeys[slotIndex];
    if (assignedKey == categoryKey) {
      return null;
    }

    return assignedKey;
  }

  CustomCategoryModel? _customCategoryById(String id) {
    for (final CustomCategoryModel category in _categoryStore.models) {
      if (category.id == id) {
        return category;
      }
    }

    return null;
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
    );
  }
}

class _CategoryDialogResult {
  const _CategoryDialogResult({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}
