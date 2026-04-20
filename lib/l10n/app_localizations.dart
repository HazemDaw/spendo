import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

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
  ];

  String get appTitle;
  String get periodToday;
  String get periodWeek;
  String get periodMonth;
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
  String get transactionDeletedMessage;
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
      <String>['ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale".',
  );
}
