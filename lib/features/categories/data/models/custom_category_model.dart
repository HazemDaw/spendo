import 'package:flutter/material.dart';

import '../../domain/entities/category.dart';

const List<IconData> kCategoryIcons = <IconData>[
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

class CustomCategoryModel {
  String id = '';
  String label = '';
  int colorValue = 0;
  int iconIndex = 0;

  int get iconCodePoint => _icon.codePoint;

  set iconCodePoint(int value) {
    final int index = kCategoryIcons.indexWhere(
      (IconData icon) => icon.codePoint == value,
    );
    iconIndex = index < 0 ? 0 : index;
  }

  String get fontFamily => _icon.fontFamily ?? 'MaterialIcons';

  set fontFamily(String value) {}

  Category toCategory() {
    return Category(
      key: id,
      labelKey: label,
      icon: _icon,
      color: Color(colorValue),
    );
  }

  IconData get _icon {
    if (iconIndex < 0 || iconIndex >= kCategoryIcons.length) {
      return kCategoryIcons.first;
    }

    return kCategoryIcons[iconIndex];
  }
}
