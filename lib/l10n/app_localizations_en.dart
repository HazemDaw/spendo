import 'app_localizations.dart';

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([super.locale = 'en']);

  @override
  String get appTitle => 'Spendo';

  @override
  String get periodToday => 'Today';

  @override
  String get periodWeek => 'Week';

  @override
  String get periodMonth => 'Month';

  @override
  String get periodYear => 'Year';

  @override
  String get periodAll => 'All time';

  @override
  String get periodInterval => 'Interval';

  @override
  String get allTime => 'All time';

  @override
  String get balanceLabel => 'Balance';

  @override
  String get actionExpense => 'Expense';

  @override
  String get actionIncome => 'Income';

  @override
  String get categoryFood => 'Food & Groceries';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryHousing => 'Housing';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryClothing => 'Clothing';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryCommunication => 'Communication';

  @override
  String get categoryPets => 'Pets';

  @override
  String get categoryGifts => 'Gifts';

  @override
  String get categorySport => 'Sport';

  @override
  String get addTransactionPlaceholder => 'Add transaction screen, phase 1';

  @override
  String get transactionListPlaceholder =>
      'Category transactions screen, phase 1';

  @override
  String get addExpenseTitle => 'Add expense';

  @override
  String get addIncomeTitle => 'Add income';

  @override
  String get editTransactionTitle => 'Edit transaction';

  @override
  String get saveAction => 'Save';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get deleteAction => 'Delete';

  @override
  String get dateLabel => 'Date';

  @override
  String get noteLabel => 'Note';

  @override
  String get pickCategoryAction => 'CHOOSE CATEGORY';

  @override
  String get invalidAmountMessage => 'Enter an amount greater than zero';

  @override
  String get invalidCategoryMessage => 'Choose a category';

  @override
  String get transactionAddedMessage => 'Transaction added';

  @override
  String get transactionUpdatedMessage => 'Changes saved';

  @override
  String get transactionSavedSuccessMessage => 'Transaction saved';

  @override
  String get transactionDeletedMessage => 'Transaction deleted';

  @override
  String get deleteTransactionTitle => 'Delete transaction?';

  @override
  String get deleteTransactionMessage => 'This action cannot be undone';

  @override
  String get noTransactionsInCategory => 'No transactions in this category';

  @override
  String get totalExpenseLabel => 'Total expenses';

  @override
  String get allTransactionsTitle => 'All transactions';

  @override
  String get incomeSectionTitle => 'Income';

  @override
  String get noTransactions => 'No transactions';

  @override
  String get drawerStub => 'Phase 1 placeholder';

  @override
  String get categoryPickerStub => 'Category picker, phase 1';

  @override
  String get authLoginPhase3 => 'Login, phase 3';

  @override
  String get authRegisterPhase3 => 'Register, phase 3';

  @override
  String get authLoginTitle => 'Sign in';

  @override
  String get authRegisterTitle => 'Register';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authSignInAction => 'Sign in';

  @override
  String get authSignInWithGoogleAction => 'Sign in with Google';

  @override
  String get authRegisterAction => 'Register';

  @override
  String get authLoginOrRegisterAction => 'Sign in / Register';

  @override
  String get authNoAccountPrompt => 'No account? Register';

  @override
  String get authHaveAccountPrompt => 'Already have an account? Sign in';

  @override
  String get authSignOutAction => 'Sign out';

  @override
  String get authOrDivider => 'or';

  @override
  String get authEmailRequiredMessage => 'Enter email';

  @override
  String get authPasswordRequiredMessage => 'Enter password';

  @override
  String get authPasswordTooShortMessage =>
      'Password must contain at least 6 characters';

  @override
  String get authPasswordsDoNotMatchMessage => 'Passwords do not match';

  @override
  String get drawerUserName => 'Spendo User';

  @override
  String get drawerUserEmail => 'user@spendo.app';

  @override
  String get drawerAllAccounts => 'Personal account';

  @override
  String get drawerBudget => 'Budget';

  @override
  String get drawerCategories => 'Categories';

  @override
  String get drawerDarkTheme => 'Dark mode';

  @override
  String get drawerExportData => 'Export data';

  @override
  String get drawerAbout => 'About Spendo';

  @override
  String get drawerAboutDescription => 'An app for tracking personal expenses.';

  @override
  String get drawerSettingsTitle => 'Settings';

  @override
  String get featureComingSoonMessage => 'This feature will be available later';

  @override
  String get syncTitle => 'Sync';

  @override
  String get syncSyncedSubtitle => 'Synced';

  @override
  String get syncLocalOnlySubtitle => 'Local only';

  @override
  String get commonOk => 'OK';

  @override
  String get chartOther => 'Other';

  @override
  String get languageTitleRussian => 'Язык: Русский';

  @override
  String get languageTitleEnglish => 'Language: English';

  @override
  String get currencyLabel => 'Currency';

  @override
  String get insightsTitle => 'Insights';

  @override
  String get insightsDailySpendingTitle => 'Daily Spending';

  @override
  String get insightsMonthlySpendingTitle => 'Monthly Spending';

  @override
  String get insightsEmptyTitle => 'No insights yet';

  @override
  String get insightsEmptyMessage =>
      'Add a few transactions for this period and Spendo will find useful patterns.';

  @override
  String get insightsErrorTitle => 'Could not load insights';

  @override
  String get insightLargestCategoryTitle => 'Largest expense category';

  @override
  String get insightSpendingTrendTitle => 'Spending trend';

  @override
  String get insightExpensiveDayTitle => 'Most expensive day';

  @override
  String get insightBudgetStatusTitle => 'Budget status';

  @override
  String insightLargestCategoryDescription(String category, String amount) =>
      '$category is your largest expense this period at $amount';

  @override
  String get insightNoExpensesThisPeriod =>
      'No expense categories yet this period';

  @override
  String insightSpentMore(int percent) =>
      'You spent $percent% more than last period';

  @override
  String insightSpentLess(int percent) =>
      'You spent $percent% less than last period';

  @override
  String get insightSpentSame => 'Your spending is the same as last period';

  @override
  String insightNoPreviousExpenses(String amount) =>
      'No expenses last period; this period you spent $amount';

  @override
  String insightMostExpensiveDay(String day) =>
      '$day is your most expensive day';

  @override
  String get insightNoExpenseDay => 'No expense day stands out yet';

  @override
  String insightBudgetOnTrack(int percent) =>
      'You are on track — $percent% of your monthly budget used';

  @override
  String insightBudgetExceeded(String amount) =>
      'You have exceeded your monthly budget by $amount';

  @override
  String get insightBudgetNotSet => 'No total monthly budget is set yet';

  @override
  String get exportTitle => 'Export Data';

  @override
  String get exportChooseFormat => 'Choose format';

  @override
  String get exportPdf => 'Export to PDF';

  @override
  String get exportPdfSubtitle => 'Report grouped by categories';

  @override
  String get exportCsv => 'Export to CSV';

  @override
  String get exportCsvSubtitle => 'Table for Excel / Google Sheets';

  @override
  String get exportLoadError => 'Could not load transactions';

  @override
  String exportError(String error) => 'Export error: $error';

  @override
  String get exportReportTitle => 'Spendo — Expense Report';

  @override
  String exportGeneratedLabel(String date) => 'Generated: $date';

  @override
  String exportIncomeLabel(String amount) => 'Income: $amount';

  @override
  String exportExpenseLabel(String amount) => 'Expenses: $amount';

  @override
  String exportBalanceLabel(String amount) => 'Balance: $amount';

  @override
  String get exportExpenseType => 'Expense';

  @override
  String get exportIncomeType => 'Income';

  @override
  String get exportCsvDateHeader => 'Date';

  @override
  String get exportCsvTypeHeader => 'Type';

  @override
  String get exportCsvCategoryHeader => 'Category';

  @override
  String get exportCsvAmountHeader => 'Amount';

  @override
  String get exportCsvNoteHeader => 'Note';

  @override
  String get exportPdfDateHeader => 'Date';

  @override
  String get exportPdfAmountHeader => 'Amount';

  @override
  String get exportPdfNoteHeader => 'Note';

  @override
  String get budgetTitle => 'Budget';

  @override
  String get budgetTotalLabel => 'Total Budget';

  @override
  String get budgetSetTotal => 'Set total budget';

  @override
  String get budgetGeneralLabel => 'Total Budget';

  @override
  String budgetExceededWarning(String categories) =>
      'Budget exceeded: $categories';

  @override
  String budgetWarningLabel(String categories) =>
      'Approaching limit: $categories';

  @override
  String get budgetDetailsAction => 'Details';

  @override
  String budgetSpentLabel(String amount) => 'Spent: $amount';

  @override
  String budgetLimitLabel(String amount) => 'Limit: $amount';

  @override
  String budgetRemainingLabel(String amount) => 'Remaining: $amount';

  @override
  String budgetUsedPercent(int percent) => '$percent% used';

  @override
  String get budgetLimitInputLabel => 'Limit';

  @override
  String get budgetInvalidLimitMessage => 'Enter a limit greater than zero';

  @override
  String get budgetTotalCategoryLabel => 'total';

  @override
  String get deleteConfirmTitle => 'Delete category?';

  @override
  String get deleteConfirmMessage =>
      'This will not delete existing transactions in this category.';

  @override
  String get personalAccount => 'Personal Account';

  @override
  String get incomeLabel => 'Income';

  @override
  String get expenseLabel => 'Expenses';

  @override
  String transactionsCount(int count) => 'Transactions: $count';

  @override
  String get closeAction => 'Close';

  @override
  String get signInToSync => 'Sign in to sync';

  @override
  String get builtInCategoriesHint => 'Built-in (tap to replace)';

  @override
  String get customCategories => 'Custom';

  @override
  String get noCustomCategories => 'No custom categories.\nTap + to add one.';

  @override
  String replaceCategoryTitle(String category) => "Replace '$category'";

  @override
  String get chooseCustomCategory => 'Choose a custom category';

  @override
  String get noCustomCategoriesCreate =>
      'No custom categories.\nCreate them with the + button';

  @override
  String get restoreDefault => 'Restore default';

  @override
  String get newCategory => 'New category';

  @override
  String get editCategory => 'Edit';

  @override
  String get categoryNameLabel => 'Name';

  @override
  String get categoryColorLabel => 'Color:';

  @override
  String get categoryIconLabel => 'Icon:';

  @override
  String get categoryNameRequiredMessage => 'Enter a name';

  @override
  String get searchTransactionsHint => 'Search transactions...';

  @override
  String get nothingFound => 'Nothing found';
}
