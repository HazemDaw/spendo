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
  String get periodYear => 'Год';

  @override
  String get periodAll => 'Все время';

  @override
  String get periodInterval => 'Интервал';

  @override
  String get allTime => 'Все время';

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
  String get transactionSavedSuccessMessage => 'Транзакция сохранена';

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
      'Приложение для отслеживания личных расходов. Дау Хазем 2105-об';

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

  @override
  String get languageTitleRussian => 'Язык: Русский';

  @override
  String get languageTitleEnglish => 'Language: English';

  @override
  String get currencyLabel => 'Валюта';

  @override
  String get insightsTitle => 'Аналитика';

  @override
  String get insightsEmptyTitle => 'Пока нет аналитики';

  @override
  String get insightsEmptyMessage =>
      'Добавьте несколько транзакций за этот период, и Spendo найдет полезные закономерности.';

  @override
  String get insightsErrorTitle => 'Не удалось загрузить аналитику';

  @override
  String get insightLargestCategoryTitle => 'Крупнейшая категория расходов';

  @override
  String get insightSpendingTrendTitle => 'Динамика расходов';

  @override
  String get insightExpensiveDayTitle => 'Самый дорогой день';

  @override
  String get insightBudgetStatusTitle => 'Статус бюджета';

  @override
  String insightLargestCategoryDescription(String category, String amount) =>
      '$category — ваша крупнейшая статья расходов за период: $amount';

  @override
  String get insightNoExpensesThisPeriod =>
      'В этом периоде пока нет категорий расходов';

  @override
  String insightSpentMore(int percent) =>
      'Вы потратили на $percent% больше, чем в прошлом периоде';

  @override
  String insightSpentLess(int percent) =>
      'Вы потратили на $percent% меньше, чем в прошлом периоде';

  @override
  String get insightSpentSame =>
      'Ваши расходы не изменились по сравнению с прошлым периодом';

  @override
  String insightNoPreviousExpenses(String amount) =>
      'В прошлом периоде расходов не было; в этом вы потратили $amount';

  @override
  String insightMostExpensiveDay(String day) =>
      '$day — ваш самый дорогой день';

  @override
  String get insightNoExpenseDay => 'Пока нет дня с заметными расходами';

  @override
  String insightBudgetOnTrack(int percent) =>
      'Вы в рамках плана — использовано $percent% месячного бюджета';

  @override
  String insightBudgetExceeded(String amount) =>
      'Вы превысили месячный бюджет на $amount';

  @override
  String get insightBudgetNotSet => 'Общий месячный бюджет еще не задан';

  @override
  String get exportTitle => 'Экспорт данных';

  @override
  String get exportChooseFormat => 'Выберите формат';

  @override
  String get exportPdf => 'Экспорт в PDF';

  @override
  String get exportPdfSubtitle => 'Отчет с группировкой по категориям';

  @override
  String get exportCsv => 'Экспорт в CSV';

  @override
  String get exportCsvSubtitle => 'Таблица для Excel / Google Sheets';

  @override
  String get exportLoadError => 'Не удалось загрузить транзакции';

  @override
  String exportError(String error) => 'Ошибка экспорта: $error';

  @override
  String get exportReportTitle => 'Spendo — Отчет о расходах';

  @override
  String exportGeneratedLabel(String date) => 'Сформирован: $date';

  @override
  String exportIncomeLabel(String amount) => 'Доходы: $amount';

  @override
  String exportExpenseLabel(String amount) => 'Расходы: $amount';

  @override
  String exportBalanceLabel(String amount) => 'Баланс: $amount';

  @override
  String get exportExpenseType => 'Расход';

  @override
  String get exportIncomeType => 'Доход';

  @override
  String get exportCsvDateHeader => 'Дата';

  @override
  String get exportCsvTypeHeader => 'Тип';

  @override
  String get exportCsvCategoryHeader => 'Категория';

  @override
  String get exportCsvAmountHeader => 'Сумма';

  @override
  String get exportCsvNoteHeader => 'Примечание';

  @override
  String get exportPdfDateHeader => 'Дата';

  @override
  String get exportPdfAmountHeader => 'Сумма';

  @override
  String get exportPdfNoteHeader => 'Примечание';

  @override
  String get budgetTitle => 'Бюджет';

  @override
  String get budgetTotalLabel => 'Общий бюджет';

  @override
  String get budgetSetTotal => 'Установить общий бюджет';

  @override
  String get budgetGeneralLabel => 'Общий бюджет';

  @override
  String budgetExceededWarning(String categories) =>
      'Превышен бюджет: $categories';

  @override
  String budgetWarningLabel(String categories) =>
      'Близко к лимиту: $categories';

  @override
  String get budgetDetailsAction => 'Подробнее';

  @override
  String budgetSpentLabel(String amount) => 'Потрачено: $amount';

  @override
  String budgetLimitLabel(String amount) => 'Лимит: $amount';

  @override
  String budgetRemainingLabel(String amount) => 'Остаток: $amount';

  @override
  String budgetUsedPercent(int percent) => '$percent% использовано';

  @override
  String get budgetLimitInputLabel => 'Лимит';

  @override
  String get budgetInvalidLimitMessage =>
      'Введите лимит больше нуля';

  @override
  String get budgetTotalCategoryLabel => 'общий';

  @override
  String get deleteConfirmTitle => 'Удалить категорию?';

  @override
  String get deleteConfirmMessage =>
      'Это не удалит существующие транзакции этой категории.';

  @override
  String get personalAccount => 'Личный счет';

  @override
  String get incomeLabel => 'Доходы';

  @override
  String get expenseLabel => 'Расходы';

  @override
  String transactionsCount(int count) => 'Транзакций: $count';

  @override
  String get closeAction => 'Закрыть';

  @override
  String get signInToSync => 'Войдите для синхронизации';

  @override
  String get builtInCategoriesHint =>
      'Встроенные (нажмите чтобы заменить)';

  @override
  String get customCategories => 'Пользовательские';

  @override
  String get noCustomCategories =>
      'Нет пользовательских категорий.\nНажмите + чтобы добавить.';

  @override
  String replaceCategoryTitle(String category) => "Заменить '$category'";

  @override
  String get chooseCustomCategory => 'Выберите пользовательскую категорию';

  @override
  String get noCustomCategoriesCreate =>
      'Нет пользовательских категорий.\nСоздайте их с помощью кнопки +';

  @override
  String get restoreDefault => 'Восстановить по умолчанию';

  @override
  String get newCategory => 'Новая категория';

  @override
  String get editCategory => 'Редактировать';

  @override
  String get categoryNameLabel => 'Название';

  @override
  String get categoryColorLabel => 'Цвет:';

  @override
  String get categoryIconLabel => 'Иконка:';

  @override
  String get categoryNameRequiredMessage => 'Введите название';

  @override
  String get searchTransactionsHint => 'Поиск транзакций...';

  @override
  String get nothingFound => 'Ничего не найдено';
}
