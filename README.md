# Spendo — Personal Finance Tracker

## About

Spendo is a cross-platform Flutter mobile application for tracking personal income and expenses, built as a graduation project at Amur State University.

**Thesis title:**
- English: Development of a cross-platform mobile application for personal finance tracking
- Russian: Разработка кроссплатформенного мобильного приложения для учёта личных финансов

---

## Features

### Core Experience
- Monefy-inspired home screen with donut chart and category orbit icons
- Physical swipe navigation between periods (PageView carousel)
- Six period types: Day, Week, Month, Year, All time, Custom interval
- Add, edit, and delete income and expenses
- Calculator keypad with expression evaluation (e.g. 200 + 50)
- Transaction undo after delete (4-second window)
- Success feedback on transaction save

### Analytics & Insights
- Spending Insights screen with 4 auto-generated cards:
  - Largest expense category this period
  - Spending vs previous period (% change)
  - Most expensive day of the week
  - Budget status (on track / exceeded)
- Bar chart showing daily or monthly spending trends
- All Transactions screen with type and category filter chips

### Budget & Categories
- Total and per-category monthly budget limits
- Visual progress indicator (orange at 80%, red at 100%)
- Tappable budget warning banner on home screen
- Pulsing animation on over-budget donut segment
- Custom categories with orbit slot management

### Data & Sync
- Offline-first architecture (full functionality without internet)
- Firebase Authentication (email/password + Google Sign-In)
- Cloud sync via Firestore (syncs on every write when authenticated)
- Restore from cloud on fresh install — sign in to recover all data
- Export to PDF (with period summary + category breakdown)
- Export to CSV

### Personalization
- Dark mode (persists across restarts)
- Russian/English language switching (persists)
- Currency display selector: ₽, $, € (persists)
- Branded app icon and splash screen

### First-Run Experience
- 3-screen onboarding flow (shown only on first launch)
- Explains home screen, drawers, and offline-first behavior

---

## Architecture

Spendo uses Clean Architecture with 3 layers:

- **Presentation:** Flutter widgets + BLoC/Cubit
- **Domain:** entities, use cases, repository interfaces
- **Data:** Drift/SQLite local DB, Firestore remote

```text
UI -> BLoC -> Use Cases -> Repository -> Drift/SQLite (local) / Firestore (remote)
```

---

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform mobile UI framework |
| flutter_bloc | State management with BLoC/Cubit |
| Drift/SQLite | Local offline-first database |
| Firebase Auth | Email/password and Google authentication |
| Cloud Firestore | Remote cloud sync and restore |
| go_router | Declarative navigation and routing |
| get_it | Dependency injection |
| fl_chart | Donut chart + bar chart visualization |
| google_fonts | Custom typography |
| intl | Date, number, and locale formatting |
| dartz | Functional result types (`Either`) |
| equatable | Value equality for states and events |
| shared_preferences | Persisted theme, locale, and currency settings |
| pdf | PDF report generation |
| csv | CSV export |
| share_plus | System share dialog |

---

## Screenshots

*Add screenshots here*

---

## Setup & Installation

### Prerequisites

- Flutter SDK >= 3.19.0
- Android Studio or VS Code
- Firebase project (see Firebase Setup below)

### Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable Authentication (Email/Password + Google)
3. Enable Cloud Firestore
4. Run:

```bash
flutterfire configure --project=YOUR_PROJECT_ID
```

5. This generates `lib/firebase_options.dart`
6. Add your SHA-1 fingerprint to Firebase for Google Sign-In

### Run the Project

```bash
git clone https://github.com/[YOUR_GITHUB_USERNAME]/spendo.git
cd spendo
flutter pub get
flutter run
```

### Build Release APK

```bash
flutter build apk --release --no-tree-shake-icons
```

> `--no-tree-shake-icons` is required due to dynamic `IconData` usage in the
> custom categories feature. Post-thesis fix planned.

---

## Project Structure

```text
lib/
├── core/
│   ├── database/         # Drift AppDatabase (4 tables)
│   ├── theme/            # ThemeCubit, AppColors, AppTheme
│   ├── locale/           # LocaleCubit
│   ├── currency/         # CurrencyCubit
│   ├── constants/        # kCategoryIcons list
│   ├── mock/             # MockData (built-in category metadata)
│   └── utils/            # date_utils, currency_formatter
├── features/
│   ├── transactions/     # Main feature: CRUD, BLoC, Drift, Firestore
│   ├── categories/       # Built-in + custom categories, orbit slots
│   ├── budget/           # Budget limits and warnings
│   ├── insights/         # InsightsCubit, InsightsPage, bar chart
│   └── auth/             # Firebase authentication
├── l10n/
│   ├── app_en.arb
│   └── app_ru.arb
├── injection_container.dart
└── main.dart
```

---

## Routes

| Route | Screen |
|---|---|
| `/onboarding` | First-launch onboarding (3 screens) |
| `/` | Home screen |
| `/add` | Add transaction |
| `/edit/:transactionId` | Edit transaction |
| `/transactions/:categoryKey` | Category transaction list |
| `/all-transactions` | All transactions with filter chips |
| `/budget` | Budget page |
| `/categories` | Categories management |
| `/insights` | Spending insights + bar chart |
| `/login` | Login |
| `/register` | Registration |

---

## Known Limitations

These are known post-thesis improvement areas:

- **Recurring transactions:** UI placeholder exists, logic not implemented
- **Multi-account support:** not implemented (single account per user)
- **`--no-tree-shake-icons` flag:** required due to dynamic IconData in categories
- **Pets and gifts categories:** defined but missing from the default home orbit (8/10 slots shown)
- **Home screen colors:** use `isDark` boolean instead of the theme system (intentional for canvas stability)

---

## Academic Context

- **University:** Amur State University (ФГБОУ ВО «АмГУ»)
- **Faculty:** Mathematics and Informatics
- **Direction:** 09.03.04 — Software Engineering (Программная инженерия)
- **Academic supervisor:** С.Г. Самохвалова, associate professor, candidate of technical sciences
- **Department head:** А.В. Бушманов

---

# Spendo — Приложение для учёта личных финансов

## О проекте

Spendo — кроссплатформенное мобильное приложение на Flutter для учёта личных доходов и расходов, разработанное в качестве выпускной квалификационной работы в Амурском государственном университете.

**Тема ВКР:** Разработка кроссплатформенного мобильного приложения для учёта личных финансов

---

## Возможности

### Основные функции
- Главный экран с donut chart и орбитой категорий (стиль Monefy)
- Физический свайп между периодами (PageView, карусель)
- 6 типов периодов: День, Неделя, Месяц, Год, Всё время, Интервал
- Добавление, редактирование и удаление транзакций
- Калькуляторная клавиатура с вычислением выражений
- Отмена удаления транзакции (4 секунды)
- Подтверждение при сохранении транзакции

### Аналитика
- Экран аналитики (Insights) с 4 автоматическими выводами
- Столбчатая диаграмма расходов по дням / месяцам
- Экран всех транзакций с фильтрами по типу и категории

### Бюджет и категории
- Общий и категориальный лимиты бюджета
- Визуальный прогресс (оранжевый при 80%, красный при 100%)
- Тапабельный баннер предупреждения на главном экране
- Пользовательские категории с управлением слотами орбиты

### Данные и синхронизация
- Offline-first архитектура
- Firebase Authentication (email/пароль + Google)
- Синхронизация с Firestore при каждой записи
- Восстановление данных из облака при переустановке приложения
- Экспорт в PDF (с разбивкой по категориям) и CSV

### Персонализация
- Тёмная тема (сохраняется)
- Переключение языка RU/EN (сохраняется)
- Выбор валюты: ₽, $, € (сохраняется)
- Брендированная иконка и сплэш-экран
- Онбординг при первом запуске (3 экрана)

---

## Архитектура

Clean Architecture с 3 слоями: Presentation (Flutter + BLoC), Domain (entities, use cases), Data (Drift/SQLite + Firestore).

## Академический контекст

- **Университет:** ФГБОУ ВО «АмГУ»
- **Факультет:** Математики и информатики
- **Направление:** 09.03.04 — Программная инженерия
- **Научный руководитель:** С.Г. Самохвалова, доцент, канд. техн. наук
- **Зав. кафедрой:** А.В. Бушманов
