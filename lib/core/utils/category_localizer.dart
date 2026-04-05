import '../../features/categories/domain/entities/category.dart';
import '../../l10n/app_localizations.dart';

class CategoryLocalizer {
  CategoryLocalizer._();

  static String label(AppLocalizations l10n, Category category) {
    return fromKey(l10n, category.labelKey);
  }

  static String fromKey(AppLocalizations l10n, String labelKey) {
    switch (labelKey) {
      case 'categoryFood':
        return l10n.categoryFood;
      case 'categoryTransport':
        return l10n.categoryTransport;
      case 'categoryHousing':
        return l10n.categoryHousing;
      case 'categoryHealth':
        return l10n.categoryHealth;
      case 'categoryClothing':
        return l10n.categoryClothing;
      case 'categoryEntertainment':
        return l10n.categoryEntertainment;
      case 'categoryCommunication':
        return l10n.categoryCommunication;
      case 'categoryPets':
        return l10n.categoryPets;
      case 'categoryGifts':
        return l10n.categoryGifts;
      case 'categorySport':
        return l10n.categorySport;
      default:
        return labelKey;
    }
  }
}
