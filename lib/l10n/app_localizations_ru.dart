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
  String get addExpenseTitle => 'Добавить расход';

  @override
  String get addIncomeTitle => 'Добавить доход';

  @override
  String get editTransactionTitle => 'Редактировать';

  @override
  String get saveAction => 'Сохранить';

  @override
  String get cancelAction => 'Отмена';

  @override
  String get deleteAction => 'Удалить';

  @override
  String get dateLabel => 'Дата';

  @override
  String get noteLabel => 'Заметка';

  @override
  String get pickCategoryAction => 'ВЫБРАТЬ КАТЕГОРИЮ';

  @override
  String get invalidAmountMessage => 'Введите сумму больше нуля';

  @override
  String get invalidCategoryMessage => 'Выберите категорию';

  @override
  String get transactionAddedMessage => 'Транзакция добавлена';

  @override
  String get transactionUpdatedMessage => 'Изменения сохранены';

  @override
  String get transactionDeletedMessage => 'Транзакция удалена';

  @override
  String get deleteTransactionTitle => 'Удалить транзакцию?';

  @override
  String get deleteTransactionMessage => 'Это действие нельзя отменить';

  @override
  String get noTransactionsInCategory => 'Нет транзакций в этой категории';

  @override
  String get totalExpenseLabel => 'Итого расходы';

  @override
  String get allTransactionsTitle => 'Все транзакции';

  @override
  String get incomeSectionTitle => 'Доход';

  @override
  String get noTransactions => 'Нет транзакций';

  @override
  String get drawerStub => 'Фаза 1, скоро';

  @override
  String get categoryPickerStub => 'Выбор категории, фаза 1';

  @override
  String get authLoginPhase3 => 'Вход, этап 3';

  @override
  String get authRegisterPhase3 => 'Регистрация, этап 3';

  @override
  String get authLoginTitle => 'Вход';

  @override
  String get authRegisterTitle => 'Регистрация';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Пароль';

  @override
  String get authConfirmPasswordLabel => 'Подтвердите пароль';

  @override
  String get authSignInAction => 'Войти';

  @override
  String get authSignInWithGoogleAction => 'Войти через Google';

  @override
  String get authRegisterAction => 'Зарегистрироваться';

  @override
  String get authLoginOrRegisterAction => 'Войти / Зарегистрироваться';

  @override
  String get authNoAccountPrompt => 'Нет аккаунта? Зарегистрироваться';

  @override
  String get authHaveAccountPrompt => 'Уже есть аккаунт? Войти';

  @override
  String get authSignOutAction => 'Выйти';

  @override
  String get authOrDivider => 'или';

  @override
  String get authEmailRequiredMessage => 'Введите email';

  @override
  String get authPasswordRequiredMessage => 'Введите пароль';

  @override
  String get authPasswordTooShortMessage =>
      'Пароль должен содержать минимум 6 символов';

  @override
  String get authPasswordsDoNotMatchMessage => 'Пароли не совпадают';

  @override
  String get drawerUserName => 'Spendo User';

  @override
  String get drawerUserEmail => 'user@spendo.app';

  @override
  String get drawerAllAccounts => 'Все счета';

  @override
  String get drawerBudget => 'Бюджет';

  @override
  String get drawerCategories => 'Категории';

  @override
  String get drawerDarkTheme => 'Тёмная тема';

  @override
  String get drawerExportData => 'Экспорт данных';

  @override
  String get drawerAbout => 'О приложении';

  @override
  String get drawerAboutDescription =>
      'Приложение для отслеживания личных расходов.';

  @override
  String get drawerSettingsTitle => 'Настройки';

  @override
  String get featureComingSoonMessage => 'Функция будет доступна позже';

  @override
  String get syncTitle => 'Синхронизация';

  @override
  String get syncSyncedSubtitle => 'Синхронизировано';

  @override
  String get syncLocalOnlySubtitle => 'Только локально';

  @override
  String get commonOk => 'OK';

  @override
  String get chartOther => 'Прочее';
}
