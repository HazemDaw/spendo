# CLAUDE.md — Spendo

> **Thesis title:** "Разработка кроссплатформенного мобильного приложения для отслеживания личных расходов"
> **App name:** Spendo
> **Target platforms:** Android & iOS (Flutter)

---

## 🎭 Role & Persona

Act as a **Senior Flutter Developer**, **Software Architect**, and **Academic Thesis Advisor**.

The developer is a **final-year software engineering student** with experience in real-world systems.
- Do **not** explain basic Dart/Flutter/programming concepts.
- Provide **production-ready, optimized, scalable** code only.
- Always provide the **complete file path** as a comment at the top of every code block:
  `// lib/features/transactions/presentation/pages/home_page.dart`
- When making a significant architectural or library decision, briefly explain the
  **trade-offs** so the developer can use them in their graduation thesis.
- If a requirement is ambiguous, **ask one clarifying question** before writing large
  code blocks.
- Keep explanations focused on the **"why"**, not the "what".

---

## 🚦 Development Phases

### ✅ Phase 1 — UI Shell (COMPLETE)
All screens built with hardcoded mock data. No BLoC, no Isar, no Firebase.
Mock data lives in `lib/core/mock/mock_data.dart`.
Every widget is extracted into its own file.

### 🔲 Phase 2 — State & Local Logic (CURRENT)
- Introduce BLoC / Cubit and wire to Phase 1 UI.
- Integrate Isar as the local database.
- App must work 100% offline after this phase.
- Do NOT introduce Firebase or any remote service in this phase.

### 🔲 Phase 3 — Backend & Sync
- Firebase Auth (email/password + Google Sign-In).
- Cloud Firestore sync layer.
- Merge local Isar data to Firestore on first login.

---

## 🌐 Language Rules

| Context | Language |
|---|---|
| Code, identifiers, comments | **English only** |
| End-user UI strings & error messages | **Russian — via l10n only** |
| `.arb` keys | English camelCase keys, Russian values |

> ✅ `AppLocalizations.of(context)!.addExpense` → `"Добавить расход"`
> ❌ Never hardcode Cyrillic strings inside widget code.

---

## 🏗️ Architecture: Clean Architecture — 3-Layer Strict

```
lib/
├── core/
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── usecases/
│   │   └── usecase.dart                  # Abstract UseCase<Type, Params>
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── app_colors.dart
│   ├── mock/
│   │   └── mock_data.dart                # Phase 1 — remove in Phase 2
│   └── utils/
│       ├── currency_formatter.dart
│       └── date_utils.dart
│
├── features/
│   ├── transactions/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── transaction_local_datasource.dart   # Isar (Phase 2)
│   │   │   │   └── transaction_remote_datasource.dart  # Firestore (Phase 3)
│   │   │   ├── models/
│   │   │   │   └── transaction_model.dart              # Isar schema + toEntity()
│   │   │   └── repositories/
│   │   │       └── transaction_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── transaction.dart
│   │   │   ├── repositories/
│   │   │   │   └── transaction_repository.dart
│   │   │   └── usecases/
│   │   │       ├── add_transaction.dart
│   │   │       ├── update_transaction.dart
│   │   │       ├── delete_transaction.dart
│   │   │       ├── get_transactions_by_period.dart
│   │   │       ├── get_transactions_by_category.dart
│   │   │       └── get_balance.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── transaction_bloc.dart
│   │       │   ├── transaction_event.dart
│   │       │   └── transaction_state.dart
│   │       ├── pages/
│   │       │   ├── home_page.dart             ✅ built
│   │       │   ├── add_transaction_page.dart  ✅ built
│   │       │   └── transaction_list_page.dart ✅ built
│   │       └── widgets/
│   │           ├── donut_chart_widget.dart        ✅ built
│   │           ├── category_icon_button.dart      ✅ built
│   │           ├── connector_lines_painter.dart   ✅ built
│   │           ├── balance_bar.dart               ✅ built
│   │           ├── calculator_keypad.dart         ✅ built
│   │           └── transaction_list_item.dart     ✅ built
│   │
│   ├── categories/
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── category.dart
│   │   └── presentation/
│   │       └── widgets/
│   │           └── category_picker_sheet.dart     ✅ built
│   │
│   └── auth/                                      # Phase 3
│       └── presentation/
│           └── pages/
│               ├── login_page.dart
│               └── register_page.dart
│
├── injection_container.dart              # get_it — Phase 2
└── main.dart
```

**Layer rules — always enforced:**
- `domain/` has zero Flutter imports and zero `data/` imports.
- `presentation/` calls use cases only — never repositories or datasources directly.
- `data/` implements domain interfaces; it never defines them.

---

## 🛠️ Tech Stack

| Concern | Library |
|---|---|
| Framework | Flutter `>=3.19.0` |
| State management | `flutter_bloc ^8.1.5` |
| Local DB | `isar ^3.1.0` + `isar_flutter_libs` |
| Cloud DB | `cloud_firestore ^4.x` |
| Auth | `firebase_auth ^4.x` |
| Firebase core | `firebase_core ^2.x` |
| DI / service locator | `get_it ^7.6.0` |
| Routing | `go_router ^13.x` |
| Charts | `fl_chart ^0.68.0` |
| Localization | `flutter_localizations` + `intl` |
| Equality | `equatable ^2.0.5` |
| Error handling | `dartz ^0.10.1` |
| Fonts | `google_fonts` (Inter) |

> **Never suggest:** GetX, Provider, MobX, Hive, sqflite, Riverpod.

---

## 🎨 Design System

### Color Palette — Purple / Violet

```dart
// lib/core/theme/app_colors.dart
class AppColors {
  static const Color primary       = Color(0xFF7C3AED); // Violet-600
  static const Color primaryLight  = Color(0xFFEDE9FE); // Violet-100
  static const Color primaryDark   = Color(0xFF5B21B6); // Violet-800
  static const Color income        = Color(0xFF10B981); // Emerald-500
  static const Color expense       = Color(0xFFEF4444); // Red-500
  static const Color incomeLight   = Color(0xFFD1FAE5);
  static const Color expenseLight  = Color(0xFFFEE2E2);
  static const Color background    = Color(0xFFF5F3FF); // Violet-50
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color textPrimary   = Color(0xFF1E1B4B); // Indigo-950
  static const Color textSecondary = Color(0xFF6B7280); // Gray-500
  static const Color divider       = Color(0xFFE5E7EB);
  static const Color emptyDonut    = Color(0xFFD1D5DB); // Gray-300

  static const List<Color> categoryPalette = [
    Color(0xFF7C3AED), // 0 food
    Color(0xFF2563EB), // 1 transport
    Color(0xFF059669), // 2 housing
    Color(0xFFD97706), // 3 health
    Color(0xFFDC2626), // 4 clothing
    Color(0xFF9333EA), // 5 entertainment
    Color(0xFF0891B2), // 6 communication
    Color(0xFFDB2777), // 7 pets
    Color(0xFF65A30D), // 8 gifts
    Color(0xFFF59E0B), // 9 sport
  ];
}
```

### Theme Application Rules (CRITICAL — prevents green leak from Monefy)

```dart
// lib/core/theme/app_theme.dart
ThemeData(
  scaffoldBackgroundColor: AppColors.background,   // 0xFFF5F3FF — violet-50, NOT green
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.primary,             // 0xFF7C3AED — violet, NOT green
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
)
```

> If the background looks mint green or the AppBar looks green, the theme is not
> applied correctly. background must be `0xFFF5F3FF`, AppBar must be `0xFF7C3AED`.

### Typography — Inter (google_fonts)

| Usage | Weight | Size |
|---|---|---|
| Amount display | 700 | 36 |
| AppBar title | 700 | 20 |
| Category labels | 500 | 12 |
| Transaction amount | 600 | 16 |
| Body / notes | 400 | 14 |
| Secondary info | 400 | 12 |

### Spacing & Shape

| Token | Value |
|---|---|
| Base unit | 8.0 |
| Card border radius | 16.0 |
| Button border radius | 12.0 |
| Keypad button height | 64.0 |
| Keypad operator bg | AppColors.primaryLight |
| Keypad operator text | AppColors.primary |

---

## 💱 Currency & Number Formatting

**Locale:** Russian (`ru_RU`)
**Format:** `1 250,50 ₽`

```dart
// lib/core/utils/currency_formatter.dart
// NumberFormat.currency(locale: 'ru_RU', symbol: '₽', decimalDigits: 2)
```

All monetary values stored as `double`. Display always via `CurrencyFormatter` — never inline.

---

## 📐 Home Screen — VERIFIED WORKING LAYOUT

> These are the exact values that produce the correct Monefy-like layout.
> Do NOT change these numbers without explicit instruction.

### Sizing constants

```dart
const double kOrbitBoxSize    = 360.0;  // outer Stack size
const double kChartInset      = 80.0;   // Positioned inset → chart = 200x200
const double kChartOuterRadius = 100.0; // centerSpaceRadius(62) + sectionRadius(38)
const double kIconOrbitRadius  = 158.0; // icon centers sit at 158px from box center
const double kBoxCenter        = 180.0; // kOrbitBoxSize / 2
// Gap from chart edge to icon center: 158 - 100 = 58px ✅
```

### Layout structure

```dart
Column(
  children: [
    PeriodFilterChips(),
    SizedBox(height: 16),
    Center(
      child: SizedBox(
        width: kOrbitBoxSize,   // 360
        height: kOrbitBoxSize,  // 360
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Donut chart — inset 80px on all sides → 200x200
            Positioned.fill(
              left: 80, right: 80, top: 80, bottom: 80,
              child: DonutChartWidget(...),
            ),
            // 2. Connector lines — fills full 360x360
            Positioned.fill(child: CustomPaint(painter: ConnectorLinesPainter(...))),
            // 3. Category icons — Positioned via polar coordinates
            ...categoriesWithPositions,
          ],
        ),
      ),
    ),
    SizedBox(height: 16),   // ← fixed gap, NO Spacer(), NO Expanded()
    BalanceBar(),
    SizedBox(height: 16),
    ActionButtons(),
    SizedBox(height: 32),
  ],
)
```

> RULE: Never wrap the SizedBox(360,360) in Expanded or Flexible.
> Never use MediaQuery to size the chart.
> Never use Spacer() between chart and balance bar.

### Donut chart (fl_chart PieChart)

```dart
PieChart(
  PieChartData(
    centerSpaceRadius: 62,     // hole radius — DO NOT CHANGE
    sectionsSpace: 2,
    startDegreeOffset: -90,    // 0° at top
    sections: [
      PieChartSectionData(
        radius: 38,            // ring thickness — DO NOT CHANGE
        // outer edge = 62 + 38 = 100px from chart center ✅
      ),
    ],
  ),
)
```

### Category icon polar coordinate formula

```dart
// Box center = (180, 180). Orbit radius = 158.
final double angle = (2 * pi / 10) * index - (pi / 2);
final double iconCenterX = 180 + 158 * cos(angle);
final double iconCenterY = 180 + 158 * sin(angle);
// Positioned: left = iconCenterX - 20, top = iconCenterY - 20
// (icon widget is 40x40, offset by half to center on point)
```

### CategoryIconButton spec

```dart
// NO card background, NO rounded rect, NO shadow, NO border
// Size: 40x40 GestureDetector
// Icon: 26px, color = AppColors.categoryPalette[index]
// Icon opacity: 1.0 if hasSpending, else 0.35
// Label below icon:
//   hasSpending → percentage string e.g. "35%"
//   no spending → Russian category name (short)
//   fontSize: 10, color: AppColors.textSecondary
//   overflow: TextOverflow.visible, softWrap: false
```

### ConnectorLinesPainter spec

```dart
// lib/features/transactions/presentation/widgets/connector_lines_painter.dart
// Only draw line if category has spending > 0
// lineStart = icon center (polar formula at orbitRadius 158)
// lineEnd   = outer ring point (polar formula at chartOuterRadius 100)
// Paint: color = Colors.grey.withOpacity(0.4), strokeWidth: 0.8, StrokeCap.round
```

### Action buttons spec

```dart
// Two circular buttons — symbol only, NO text labels
// Size: 72x72, shape: BoxShape.circle
// Background: transparent
// Border: 3px solid

// Left button:  symbol '−', color = AppColors.expense  (0xFFEF4444)
// Right button: symbol '+', color = AppColors.income   (0xFF10B981)

// Symbol style: fontSize 36, fontWeight w300, color = button color
```

### Balance bar spec

```dart
// Full-width Container, background: AppColors.primary
// Row layout:
//   [SizedBox 16] [Icon(Icons.menu) white] [Spacer] [balance text white bold]
//   [Spacer] [Icon(Icons.menu) white] [SizedBox 16]
// Left menu icon → opens left drawer
// Right menu icon → opens right drawer
```

---

## 📱 Screen Specs

### Screen 2: `add_transaction_page.dart`

**Two modes:**

| Mode | Trigger | Pre-filled | AppBar right |
|---|---|---|---|
| `create` | Category icon tap / action button | type + optional category | none |
| `edit` | Transaction list item tap | all fields | 🗑 delete icon |

**Routes:**
- Create: `/add?type=expense&categoryKey=food`
- Edit: `/edit/:transactionId`

**Layout:**
```
AppBar: ← title [🗑 edit mode only]
📅 date row → showDatePicker
Amount display box (primaryDark bg): ₽ | expression | ⌫
Note TextField: pen icon + optional input
Calculator keypad 4×4
[ ВЫБРАТЬ КАТЕГОРИЮ ▼ ] button → CategoryPickerSheet
```

**Calculator:** expression string in setState. `=` evaluates. `⌫` removes last char.
Operators highlighted: primaryLight bg, primary text.

**Save (create):** validate amount > 0 + category selected → SnackBar `"Расход добавлен"`
**Save (edit):** same validation → SnackBar `"Изменения сохранены"`
**Delete:** confirm dialog → SnackBar `"Транзакция удалена"`

---

### Screen 3: `transaction_list_page.dart`

**Route:** `/transactions/:categoryKey`
**Trigger:** tap donut chart segment

```
AppBar: ← [CategoryIcon] CategoryRussianName
Summary bar: total for this category
ListView.separated — TransactionListItem widgets
  sorted: most recent first
  filtered: categoryKey + selectedPeriod
Empty state: centered icon + "Нет транзакций в этой категории"
```

**TransactionListItem:**
- Left: circular avatar (primaryLight bg) with category icon
- Middle: category label (textSecondary) + note (textPrimary)
- Right: amount (red=expense, green=income) + date `"Пн, 24 мар"`
- Tap → `add_transaction_page.dart` edit mode

---

### Drawer: `AppLeftDrawer`
```
Header: mock avatar + "Spendo User" + email
Items:  📅 Период | 💰 Все счета (TBD) | 📊 Бюджет (TBD)
Footer: ☁ Синхронизация: Офлайн
```

### Drawer: `AppRightDrawer`
```
Items: ⚙ Настройки | 🏷 Категории (TBD) | 🌙 Тёмная тема (toggle, P1 non-functional)
       📤 Экспорт (TBD) | 🔐 Войти (Phase 3)
Footer: ℹ️ О приложении → AlertDialog
```

---

## 🗂️ Categories — v1

| Index | Icon | Key | Russian Label | Color |
|---|---|---|---|---|
| 0 | `Icons.restaurant` | `food` | Еда и продукты | `0xFF7C3AED` |
| 1 | `Icons.directions_car` | `transport` | Транспорт | `0xFF2563EB` |
| 2 | `Icons.home` | `housing` | Жильё | `0xFF059669` |
| 3 | `Icons.local_pharmacy` | `health` | Здоровье | `0xFFD97706` |
| 4 | `Icons.checkroom` | `clothing` | Одежда | `0xFFDC2626` |
| 5 | `Icons.theater_comedy` | `entertainment` | Развлечения | `0xFF9333EA` |
| 6 | `Icons.phone` | `communication` | Связь | `0xFF0891B2` |
| 7 | `Icons.pets` | `pets` | Питомцы | `0xFFDB2777` |
| 8 | `Icons.card_giftcard` | `gifts` | Подарки | `0xFF65A30D` |
| 9 | `Icons.fitness_center` | `sport` | Спорт | `0xFFF59E0B` |

---

## 🧱 Domain Entities

```dart
// lib/features/transactions/domain/entities/transaction.dart
enum TransactionType { expense, income }

class Transaction extends Equatable {
  final String id;
  final double amount;
  final String? categoryKey;   // null for income in v1
  final TransactionType type;
  final DateTime date;
  final String? note;

  const Transaction({
    required this.id, required this.amount, this.categoryKey,
    required this.type, required this.date, this.note,
  });

  @override
  List<Object?> get props => [id, amount, categoryKey, type, date, note];
}
```

```dart
// lib/features/categories/domain/entities/category.dart
class Category extends Equatable {
  final String key;
  final String labelKey;
  final IconData icon;
  final Color color;

  const Category({
    required this.key, required this.labelKey,
    required this.icon, required this.color,
  });

  @override
  List<Object?> get props => [key];
}
```

---

## ⚙️ Phase 2 — Full Specification

### 2.1 BLoC Architecture

#### TransactionBloc

```dart
// Events
class LoadTransactionsEvent extends TransactionEvent {
  final TransactionPeriod period;  // today / week / month
}
class AddTransactionEvent extends TransactionEvent {
  final Transaction transaction;
}
class UpdateTransactionEvent extends TransactionEvent {
  final Transaction transaction;
}
class DeleteTransactionEvent extends TransactionEvent {
  final String id;
}

// States
class TransactionInitial extends TransactionState {}
class TransactionLoading extends TransactionState {}
class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  final double totalIncome;
  final double totalExpense;
  // categoryTotals: Map<String, double> for donut chart segments
  final Map<String, double> categoryTotals;
}
class TransactionError extends TransactionState {
  final String message;
}
```

#### KeypadCubit (replaces Phase 1 setState)

```dart
// State: String expression
// Methods: appendChar(String c), evaluate(), backspace(), clear()
// Lives in: lib/features/transactions/presentation/bloc/keypad_cubit.dart
```

#### PeriodCubit

```dart
// State: TransactionPeriod enum { today, week, month }
// Lives in: lib/features/transactions/presentation/bloc/period_cubit.dart
// home_page.dart listens to this and re-dispatches LoadTransactionsEvent
```

### 2.2 Isar Database Schema

```dart
// lib/features/transactions/data/models/transaction_model.dart

@collection
class TransactionModel {
  Id isarId = Isar.autoIncrement;

  @Index()
  late String id;           // UUID string

  late double amount;

  @Index()
  String? categoryKey;

  @Enumerated(EnumType.name)
  late TransactionType type;

  @Index()
  late DateTime date;

  String? note;

  // Conversion methods
  Transaction toEntity() => Transaction(
    id: id, amount: amount, categoryKey: categoryKey,
    type: type, date: date, note: note,
  );

  static TransactionModel fromEntity(Transaction t) => TransactionModel()
    ..id = t.id ..amount = t.amount ..categoryKey = t.categoryKey
    ..type = t.type ..date = t.date ..note = t.note;
}
```

### 2.3 Repository Interface

```dart
// lib/features/transactions/domain/repositories/transaction_repository.dart

abstract class TransactionRepository {
  Future<Either<Failure, List<Transaction>>> getTransactionsByPeriod(
    DateTime start, DateTime end,
  );
  Future<Either<Failure, List<Transaction>>> getTransactionsByCategory(
    String categoryKey, DateTime start, DateTime end,
  );
  Future<Either<Failure, double>> getBalance();
  Future<Either<Failure, Unit>> addTransaction(Transaction transaction);
  Future<Either<Failure, Unit>> updateTransaction(Transaction transaction);
  Future<Either<Failure, Unit>> deleteTransaction(String id);
}
```

### 2.4 Local Datasource (Isar)

```dart
// lib/features/transactions/data/datasources/transaction_local_datasource.dart

abstract class TransactionLocalDatasource {
  Future<List<TransactionModel>> getByPeriod(DateTime start, DateTime end);
  Future<List<TransactionModel>> getByCategory(String key, DateTime start, DateTime end);
  Future<void> save(TransactionModel model);
  Future<void> update(TransactionModel model);
  Future<void> delete(String id);
}

class TransactionLocalDatasourceImpl implements TransactionLocalDatasource {
  final Isar _isar;
  // Use _isar.writeTxn() for mutations
  // Use _isar.txn() for reads
  // Filter dates with: .filter().dateBetween(start, end)
}
```

### 2.5 Dependency Injection (get_it)

```dart
// lib/injection_container.dart

Future<void> init() async {
  // Isar
  final isar = await Isar.open([TransactionModelSchema], directory: dir);
  sl.registerSingleton<Isar>(isar);

  // Datasources
  sl.registerLazySingleton<TransactionLocalDatasource>(
    () => TransactionLocalDatasourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(localDatasource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => AddTransaction(sl()));
  sl.registerLazySingleton(() => GetTransactionsByPeriod(sl()));
  // ... other use cases

  // BLoC
  sl.registerFactory(() => TransactionBloc(
    addTransaction: sl(),
    getTransactionsByPeriod: sl(),
    // ...
  ));
  sl.registerFactory(() => KeypadCubit());
  sl.registerFactory(() => PeriodCubit());
}
```

### 2.6 Wiring Phase 1 UI to Phase 2 BLoC

**home_page.dart changes:**
- Replace mock data calls with `BlocBuilder<TransactionBloc, TransactionState>`
- `TransactionLoaded` → pass `categoryTotals` to `DonutChartWidget`
- `TransactionLoading` → show `CircularProgressIndicator` in chart center
- `TransactionError` → show error `SnackBar`
- `PeriodCubit` drives the `FilterChip` selection

**add_transaction_page.dart changes:**
- Replace `setState _expression` with `BlocProvider<KeypadCubit>`
- On save → dispatch `AddTransactionEvent` or `UpdateTransactionEvent`
- On delete → dispatch `DeleteTransactionEvent`

**transaction_list_page.dart changes:**
- Replace mock list with `BlocBuilder<TransactionBloc, TransactionState>`
- Filter `TransactionLoaded.transactions` by `categoryKey`

### 2.7 Period Date Ranges

```dart
// lib/core/utils/date_utils.dart

DateTimeRange getPeriodRange(TransactionPeriod period) {
  final now = DateTime.now();
  return switch (period) {
    TransactionPeriod.today => DateTimeRange(
        start: DateTime(now.year, now.month, now.day),
        end: DateTime(now.year, now.month, now.day, 23, 59, 59),
      ),
    TransactionPeriod.week => DateTimeRange(
        start: now.subtract(Duration(days: now.weekday - 1)),
        end: now,
      ),
    TransactionPeriod.month => DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: now,
      ),
  };
}
```

### 2.8 Phase 2 Session Prompt (use when starting)

```
Read CLAUDE.md fully. We are in Phase 2.

Phase 1 UI is complete and must not be visually changed.
Do not modify any widget layout, colors, or sizes.

Task 1: Set up get_it injection_container.dart per the Phase 2 spec.
Task 2: Implement TransactionModel with Isar @collection annotation.
Task 3: Implement TransactionLocalDatasourceImpl using Isar.
Task 4: Implement TransactionRepositoryImpl wrapping the datasource,
        returning Either<Failure, T> — never throwing.
Task 5: Implement all use cases (AddTransaction, GetTransactionsByPeriod,
        GetTransactionsByCategory, UpdateTransaction, DeleteTransaction, GetBalance).
Task 6: Implement TransactionBloc with events and states from CLAUDE.md.
Task 7: Wire home_page.dart to TransactionBloc — replace mock data only,
        do not change any layout code.

Run flutter analyze after each task. Zero warnings before moving to next task.
```

---

## 🗄️ Data Strategy

```
User action
    │
    ▼
[Isar — local DB]    Primary source of truth. Always offline.
    │
    ▼  (Phase 3 — only when authenticated)
[Cloud Firestore]    Cloud backup & multi-device sync.

Firestore path:
  users/{uid}/transactions/{transactionId}
  users/{uid}/categories/{categoryId}
```

---

## 🔐 Auth Plan (Phase 3)

- Email/Password + Google Sign-In via `firebase_auth`
- Unauthenticated = full local-only mode, zero login gate
- First login = upload all Isar data to Firestore
- Auth state drives `go_router` redirect guards

---

## 🧩 Code Standards

```
DO:
  - Extract any widget over ~40 lines into its own file
  - Use const constructors everywhere possible
  - Use Either<Failure, T> for all repository returns (Phase 2+)
  - Check mounted before using BuildContext across async gaps
  - Use go_router named routes exclusively
  - Use debugPrint() — never print()
  - Format all monetary values through CurrencyFormatter only

DON'T:
  - Hardcode Russian strings — always l10n
  - Put business logic in widgets
  - Throw exceptions from repositories — return Failure
  - Use global variables or static singletons for services
  - Import data/ from presentation/ or domain/
  - Wrap the chart SizedBox(360,360) in Expanded or Flexible
  - Use MediaQuery to size the donut chart
  - Use Spacer() between the chart and the balance bar
```

### Naming Conventions

| Element | Convention | Example |
|---|---|---|
| Files | `snake_case` | `transaction_list_item.dart` |
| Classes | `PascalCase` | `TransactionListItem` |
| Variables / methods | `camelCase` | `getTransactionsByCategory` |
| Constants | `kCamelCase` | `kDefaultCurrency` |
| Private members | `_camelCase` | `_expression` |
| l10n keys | `camelCase` | `addExpenseTitle` |
| BLoC Events | `VerbNounEvent` | `AddTransactionEvent` |
| BLoC States | `NounStateAdjective` | `TransactionLoaded` |
| Route names | `camelCase` | `transactionList` |

---

## 🎓 Thesis Reference

When asked for thesis explanation, structure as:
1. What was chosen + alternatives considered
2. Why — technical justification
3. Trade-offs
4. How it applies to this project

| Topic | Thesis angle |
|---|---|
| Clean Architecture | SOLID, testability, separation of concerns |
| Offline-first (Isar) | Resilience, UX, swappable data layer |
| Repository pattern | Datasource abstraction, domain independence |
| BLoC pattern | Predictable state machine, testability, explicit events |
| Flutter cross-platform | Single codebase trade-offs vs native |
| Firebase Auth + Firestore | Managed BaaS vs self-hosted backend |

---

## ✅ Feature Status

| Feature | Phase | Status |
|---|---|---|
| Home screen — donut chart + category orbit | 1 | ✅ Done |
| Home screen — period filter chips | 1 | ✅ Done |
| Home screen — balance bar | 1 | ✅ Done |
| Home screen — empty state (grey donut) | 1 | ✅ Done |
| Home screen — action buttons (circle, symbol only) | 1 | ✅ Done |
| Connector lines (icon → segment) | 1 | ✅ Done |
| Add transaction screen — create mode | 1 | ✅ Done |
| Add transaction screen — edit mode + delete | 1 | ✅ Done |
| Calculator keypad with expression display | 1 | ✅ Done |
| Category picker bottom sheet | 1 | ✅ Done |
| Transaction list screen (filtered by category) | 1 | ✅ Done |
| Left drawer | 1 | ✅ Done |
| Right drawer | 1 | ✅ Done |
| Russian locale currency formatting | 1 | ✅ Done |
| Isar DB + TransactionModel | 2 | 🔲 Not started |
| TransactionBloc wiring | 2 | 🔲 Not started |
| KeypadCubit | 2 | 🔲 Not started |
| PeriodCubit | 2 | 🔲 Not started |
| get_it DI setup | 2 | 🔲 Not started |
| Use cases (all 6) | 2 | 🔲 Not started |
| Firebase Auth | 3 | 🔲 Not started |
| Firestore sync | 3 | 🔲 Not started |
| Dark mode | TBD | — |
| Export PDF / CSV | TBD | — |
| Budget limits per category | TBD | — |
| Recurring transactions | TBD | — |

---

## 🔲 Still To Decide

- [ ] Minimum Android SDK (assumption: API 21 / Android 5.0)
- [ ] Splash screen design (assumption: violet bg + white "S")
- [ ] App icon
- [ ] Dark mode — Phase 2 or TBD?
- [ ] Income category support (currently none in v1 — confirm)
- [ ] Whether `[↺]` recurring icon is a real Phase 2 feature or removed
