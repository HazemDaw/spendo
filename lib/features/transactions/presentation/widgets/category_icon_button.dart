import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/category_localizer.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../categories/domain/entities/category.dart';

class CategoryIconButton extends StatelessWidget {
  const CategoryIconButton({
    super.key,
    required this.category,
    required this.onPressed,
    this.selected = false,
    this.showContainer = true,
    this.label,
    this.labelStyle,
    this.iconOpacity = 1,
    this.iconSize = 30,
    this.width = 84,
    this.containerSize = 64,
    this.labelMaxLines = 2,
    this.labelOverflow = TextOverflow.ellipsis,
    this.labelSoftWrap = true,
    this.labelOffset = 8,
  });

  final Category category;
  final VoidCallback onPressed;
  final bool selected;
  final bool showContainer;
  final String? label;
  final TextStyle? labelStyle;
  final double iconOpacity;
  final double iconSize;
  final double width;
  final double containerSize;
  final int labelMaxLines;
  final TextOverflow labelOverflow;
  final bool labelSoftWrap;
  final double labelOffset;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String resolvedLabel =
        label ?? CategoryLocalizer.label(l10n, category);
    final Widget icon = Opacity(
      opacity: iconOpacity,
      child: Icon(category.icon, color: category.color, size: iconSize),
    );

    if (!showContainer) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: SizedBox(
          width: containerSize,
          height: containerSize,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: <Widget>[
              SizedBox(
                width: containerSize,
                height: containerSize,
                child: Center(child: icon),
              ),
              Positioned(
                top: containerSize + labelOffset,
                left: -24,
                right: -24,
                child: Text(
                  resolvedLabel,
                  textAlign: TextAlign.center,
                  maxLines: labelMaxLines,
                  overflow: labelOverflow,
                  softWrap: labelSoftWrap,
                  style: labelStyle ?? Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: width,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: containerSize,
              height: containerSize,
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryLight : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? AppColors.primary : Colors.transparent,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(child: icon),
            ),
            const SizedBox(height: 8),
            Text(
              resolvedLabel,
              textAlign: TextAlign.center,
              maxLines: labelMaxLines,
              overflow: labelOverflow,
              softWrap: labelSoftWrap,
              style: labelStyle ?? Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
