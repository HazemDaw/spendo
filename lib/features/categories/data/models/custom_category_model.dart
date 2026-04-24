import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../../domain/entities/category.dart';

part 'custom_category_model.g.dart';

@collection
class CustomCategoryModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  late String label;
  late int colorValue;
  late int iconCodePoint;
  late String fontFamily;

  Category toCategory() {
    return Category(
      key: id,
      labelKey: label,
      icon: IconData(iconCodePoint, fontFamily: fontFamily),
      color: Color(colorValue),
    );
  }
}
