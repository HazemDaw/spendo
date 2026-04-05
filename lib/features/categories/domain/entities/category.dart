import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

class Category extends Equatable {
  const Category({
    required this.key,
    required this.labelKey,
    required this.icon,
    required this.color,
  });

  final String key;
  final String labelKey;
  final IconData icon;
  final Color color;

  @override
  List<Object?> get props => <Object?>[key];
}
