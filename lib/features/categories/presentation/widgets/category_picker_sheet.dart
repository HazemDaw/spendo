import 'package:flutter/material.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../transactions/presentation/widgets/category_icon_button.dart';

class CategoryPickerSheet extends StatelessWidget {
  const CategoryPickerSheet({
    super.key,
    this.selectedCategoryKey,
    required this.onCategorySelected,
  });

  final String? selectedCategoryKey;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          shrinkWrap: true,
          itemCount: MockData.categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 106,
          ),
          itemBuilder: (BuildContext context, int index) {
            final category = MockData.categories[index];
            return CategoryIconButton(
              category: category,
              selected: category.key == selectedCategoryKey,
              onPressed: () => onCategorySelected(category.key),
            );
          },
        ),
      ),
    );
  }
}
