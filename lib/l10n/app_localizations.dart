import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('ru'),
    Locale('en'),
  ];

  String get appTitle;
  String get periodToday;
  String get periodWeek;
  String get periodMonth;
  String get periodYear;
  String get periodAll;
  String get periodInterval;
  String get allTime;
  String get balanceLabel;
  String get actionExpense;
  String get actionIncome;
  String get categoryFood;
  String get categoryTransport;
  String get categoryHousing;
  String get categoryHealth;
  String get categoryClothing;
  String get categoryEntertainment;
  String get categoryCommunication;
  String get categoryPets;
  String get categoryGifts;
  String get categorySport;
  String get addTransactionPlaceholder;
  String get transactionListPlaceholder;
  String get addExpenseTitle;
  String get addIncomeTitle;
  String get editTransactionTitle;
  String get saveAction;
  String get cancelAction;
  String get deleteAction;
  String get dateLabel;
  String get noteLabel;
  String get pickCategoryAction;
  String get invalidAmountMessage;
  String get invalidCategoryMessage;
  String get transactionAddedMessage;
  String get transactionUpdatedMessage;
  String get transactionSavedSuccessMessage;
  String get transactionDeletedMessage;
  String get undoDeleteAction;
  String get deleteTransactionTitle;
  String get deleteTransactionMessage;
  String get noTransactionsInCategory;
  String get totalExpenseLabel;
  String get allTransactionsTitle;
  String get incomeSectionTitle;
  String get noTransactions;
  String get drawerStub;
  String get categoryPickerStub;
  String get authLoginPhase3;
  String get authRegisterPhase3;
  String get authLoginTitle;
  String get authRegisterTitle;
  String get authEmailLabel;
  String get authPasswordLabel;
  String get authConfirmPasswordLabel;
  String get authSignInAction;
  String get authSignInWithGoogleAction;
  String get authRegisterAction;
  String get authLoginOrRegisterAction;
  String get authNoAccountPrompt;
  String get authHaveAccountPrompt;
  String get authSignOutAction;
  String get authOrDivider;
  String get authEmailRequiredMessage;
  String get authPasswordRequiredMessage;
  String get authPasswordTooShortMessage;
  String get authPasswordsDoNotMatchMessage;
  String get drawerUserName;
  String get drawerUserEmail;
  String get drawerAllAccounts;
  String get drawerBudget;
  String get drawerCategories;
  String get drawerDarkTheme;
  String get drawerExportData;
  String get drawerAbout;
  String get drawerAboutDescription;
  String get drawerSettingsTitle;
  String get featureComingSoonMessage;
  String get syncTitle;
  String get syncSyncedSubtitle;
  String get syncLocalOnlySubtitle;
  String get commonOk;
  String get chartOther;
  String get languageTitleRussian;
  String get languageTitleEnglish;
  String get currencyLabel;
  String get insightsTitle;
  String get insightsDailySpendingTitle;
  String get insightsMonthlySpendingTitle;
  String get insightsNoDataTitle;
  String get insightsNoDataSubtitle;
  String get insightsAddTransactionAction;
  String get insightsNoTransactionsPeriodTitle;
  String get insightsNoTransactionsPeriodSubtitle;
  String get insightsEmptyTitle;
  String get insightsEmptyMessage;
  String get insightsErrorTitle;
  String get insightLargestCategoryTitle;
  String get insightSpendingTrendTitle;
  String get insightExpensiveDayTitle;
  String get insightBudgetStatusTitle;
  String insightLargestCategoryDescription(String category, String amount);
  String get insightNoExpensesThisPeriod;
  String insightSpentMore(int percent);
  String insightSpentLess(int percent);
  String get insightSpentSame;
  String insightNoPreviousExpenses(String amount);
  String insightMostExpensiveDay(String day);
  String get insightNoExpenseDay;
  String insightBudgetOnTrack(int percent);
  String insightBudgetExceeded(String amount);
  String get insightBudgetNotSet;
  String get exportTitle;
  String get exportChooseFormat;
  String get exportPdf;
  String get exportPdfSubtitle;
  String get exportCsv;
  String get exportCsvSubtitle;
  String get exportLoadError;
  String exportError(String error);
  String get exportReportTitle;
  String exportGeneratedLabel(String date);
  String exportIncomeLabel(String amount);
  String exportExpenseLabel(String amount);
  String exportBalanceLabel(String amount);
  String get exportExpenseType;
  String get exportIncomeType;
  String get exportCsvDateHeader;
  String get exportCsvTypeHeader;
  String get exportCsvCategoryHeader;
  String get exportCsvAmountHeader;
  String get exportCsvNoteHeader;
  String get exportPdfDateHeader;
  String get exportPdfAmountHeader;
  String get exportPdfNoteHeader;
  String get budgetTitle;
  String get budgetTotalLabel;
  String get budgetSetTotal;
  String get budgetGeneralLabel;
  String budgetExceededWarning(String categories);
  String budgetWarningLabel(String categories);
  String get budgetDetailsAction;
  String budgetSpentLabel(String amount);
  String budgetLimitLabel(String amount);
  String budgetRemainingLabel(String amount);
  String budgetUsedPercent(int percent);
  String get budgetLimitInputLabel;
  String get budgetInvalidLimitMessage;
  String get budgetTotalCategoryLabel;
  String get deleteConfirmTitle;
  String get deleteConfirmMessage;
  String get personalAccount;
  String get incomeLabel;
  String get expenseLabel;
  String transactionsCount(int count);
  String get closeAction;
  String get signInToSync;
  String get builtInCategoriesHint;
  String get customCategories;
  String get noCustomCategories;
  String replaceCategoryTitle(String category);
  String get chooseCustomCategory;
  String get noCustomCategoriesCreate;
  String get restoreDefault;
  String get newCategory;
  String get editCategory;
  String get categoryNameLabel;
  String get categoryColorLabel;
  String get categoryIconLabel;
  String get categoryNameRequiredMessage;
  String get searchTransactionsHint;
  String get nothingFound;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(
      lookupAppLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ru', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale".',
  );
}
