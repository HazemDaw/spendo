import 'package:flutter/material.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/custom_category_access.dart';
import '../../data/custom_category_store.dart';
import '../../data/models/custom_category_model.dart';
import '../../../transactions/presentation/widgets/category_icon_button.dart';

class CategoryPickerSheet extends StatefulWidget {
  const CategoryPickerSheet({
    super.key,
    this.selectedCategoryKey,
    required this.onCategorySelected,
  });

  final String? selectedCategoryKey;
  final ValueChanged<String> onCategorySelected;

  @override
  State<CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<CategoryPickerSheet> {
  final CustomCategoryStore? _categoryStore = maybeCustomCategoryStore();

  @override
  void initState() {
    super.initState();
    _categoryStore?.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder<List<CustomCategoryModel>>(
        valueListenable: _categoryStore?.listenable ??
            ValueNotifier<List<CustomCategoryModel>>(<CustomCategoryModel>[]),
        builder: (
          BuildContext context,
          List<CustomCategoryModel> customCategories,
          _,
        ) {
          return ListView(
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            children: <Widget>[
              const _PickerSectionHeader('Встроенные'),
              _buildGrid(
                children: MockData.categories.map((category) {
                  return CategoryIconButton(
                    category: category,
                    selected: category.key == widget.selectedCategoryKey,
                    onPressed: () => widget.onCategorySelected(category.key),
                  );
                }).toList(),
              ),
              if (customCategories.isNotEmpty) ...<Widget>[
                const SizedBox(height: 20),
                const _PickerSectionHeader('Пользовательские'),
                _buildGrid(
                  children: customCategories.map((CustomCategoryModel model) {
                    final category = model.toCategory();
                    return CategoryIconButton(
                      category: category,
                      selected: category.key == widget.selectedCategoryKey,
                      onPressed: () => widget.onCategorySelected(category.key),
                    );
                  }).toList(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildGrid({required List<Widget> children}) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.8,
      children: children,
    );
  }
}

class _PickerSectionHeader extends StatelessWidget {
  const _PickerSectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
    );
  }
}
