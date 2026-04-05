import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../categories/domain/entities/category.dart';
import 'category_icon_button.dart';

class CategoryIconOrbit extends StatelessWidget {
  const CategoryIconOrbit({
    super.key,
    required this.categories,
    required this.centerChild,
    required this.onCategoryTap,
  });

  final List<Category> categories;
  final Widget centerChild;
  final ValueChanged<Category> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 420,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double size = math.min(constraints.maxWidth, 400);
          const double iconSize = 84;
          final double centerSize = size * 0.62;
          final double center = size / 2;
          final double radiusX = (size - iconSize) / 2 - 8;
          final double radiusY = (size - iconSize) / 2 - 14;

          return Center(
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned.fill(
                    child: Center(
                      child: SizedBox.square(
                        dimension: centerSize,
                        child: centerChild,
                      ),
                    ),
                  ),
                  for (int index = 0; index < categories.length; index++)
                    Positioned(
                      left: center +
                          radiusX *
                              math.cos(
                                  (2 * math.pi / categories.length) * index -
                                      math.pi / 2) -
                          iconSize / 2,
                      top: center +
                          radiusY *
                              math.sin(
                                  (2 * math.pi / categories.length) * index -
                                      math.pi / 2) -
                          iconSize / 2,
                      child: CategoryIconButton(
                        category: categories[index],
                        onPressed: () => onCategoryTap(categories[index]),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
