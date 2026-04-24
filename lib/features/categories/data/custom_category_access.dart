import '../../../injection_container.dart';
import 'custom_category_store.dart';

CustomCategoryStore? maybeCustomCategoryStore() {
  if (!sl.isRegistered<CustomCategoryStore>()) {
    return null;
  }

  return sl<CustomCategoryStore>();
}
