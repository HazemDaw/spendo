import 'app_localizations.dart';

class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([super.locale = 'ru']);

  @override
  String get appTitle => 'Spendo';

  @override
  String get periodToday => 'Сегодня';

  @override
  String get periodWeek => 'Неделя';

  @override
  String get periodMonth => 'Месяц';

  @override
  String get balanceLabel => 'Баланс';

  @override
  String get actionExpense => '- Расход';

  @override
  String get actionIncome => '+ Доход';

  @override
  String get categoryFood => 'Еда и продукты';

  @override
  String get categoryTransport => 'Транспорт';

  @override
  String get categoryHousing => 'Жильё';

  @override
  String get categoryHealth => 'Здоровье';

  @override
  String get categoryClothing => 'Одежда';

  @override
  String get categoryEntertainment => 'Развлечения';

  @override
  String get categoryCommunication => 'Связь';

  @override
  String get categoryPets => 'Питомцы';

  @override
  String get categoryGifts => 'Подарки';

  @override
  String get categorySport => 'Спорт';

  @override
  String get addTransactionPlaceholder => 'Экран добавления, фаза 1';

  @override
  String get transactionListPlaceholder => 'Список по категории, фаза 1';

  @override
  String get drawerStub => 'Фаза 1, скоро';

  @override
  String get categoryPickerStub => 'Выбор категории, фаза 1';

  @override
  String get authLoginPhase3 => 'Вход, этап 3';

  @override
  String get authRegisterPhase3 => 'Регистрация, этап 3';

  @override
  String get chartOther => 'Прочее';
}
