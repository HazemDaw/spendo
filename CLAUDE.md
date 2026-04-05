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

## 🚦 Development Phases — CRITICAL

The project is developed in **strict phases**. Never mix concerns across phases.

### ✅ Phase 1 — UI Shell (CURRENT)
- Build every screen and widget with **hardcoded mock data only**.
- **No BLoC, no Cubit** — only `setState` for local UI interactions (keypad input,
  date picker, selected category).
- **No Isar, no Firebase, no real services.**
- Goal: every screen pixel-perfect against the specs below, every widget extracted
  and reusable.
- All sample data lives in `lib/core/mock/mock_data.dart`.

### 🔲 Phase 2 — State & Local Logic
- Introduce BLoC / Cubit and wire to Phase 1 UI.
- Integrate Isar as the local database.
- App works 100 % offline after this phase.

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
│   │   └── mock_data.dart                # Phase 1 only — hardcoded samples
│   └── utils/
│       ├── currency_formatter.dart       # Russian locale formatting
│       └── date_utils.dart
│
├── features/
│   ├── transactions/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── transaction_local_datasource.dart   # Isar  (Phase 2)
│   │   │   │   └── transaction_remote_datasource.dart  # Firestore (Phase 3)
│   │   │   ├── models/
│   │   │   │   └── transaction_model.dart
│   │   │   └── repositories/
│   │   │       └── transaction_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── transaction.dart      # Pure Dart — zero Flutter / framework imports
│   │   │   ├── repositories/
│   │   │   │   └── transaction_repository.dart  # Abstract interface
│   │   │   └── usecases/
│   │   │       ├── add_transaction.dart
│   │   │       ├── update_transaction.dart
│   │   │       ├── delete_transaction.dart
│   │   │       ├── get_transactions_by_period.dart
│   │   │       ├── get_transactions_by_category.dart
│   │   │       └── get_balance.dart
│   │   └── presentation/
│   │       ├── bloc/                     # Introduced in Phase 2
│   │       ├── pages/
│   │       │   ├── home_page.dart
│   │       │   ├── add_transaction_page.dart   # create + edit modes
│   │       │   └── transaction_list_page.dart  # filtered by category
│   │       └── widgets/
│   │           ├── donut_chart_widget.dart
│   │           ├── category_icon_button.dart
│   │           ├── balance_bar.dart
│   │           ├── calculator_keypad.dart
│   │           └── transaction_list_item.dart
│   │
│   ├── categories/
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── category.dart
│   │   └── presentation/
│   │       └── widgets/
│   │           └── category_picker_sheet.dart
│   │
│   └── auth/                             # Phase 3
│       └── presentation/
│           └── pages/
│               ├── login_page.dart
│               └── register_page.dart
│
├── injection_container.dart              # get_it — Phase 2+
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
> Stick to this stack unless the developer explicitly asks to evaluate an alternative.

---

## 🎨 Design System

### Color Palette — Purple / Violet

```dart
// lib/core/theme/app_colors.dart
class AppColors {
  // Primary
  static const Color primary       = Color(0xFF7C3AED); // Violet-600
  static const Color primaryLight  = Color(0xFFEDE9FE); // Violet-100
  static const Color primaryDark   = Color(0xFF5B21B6); // Violet-800

  // Semantic
  static const Color income        = Color(0xFF10B981); // Emerald-500
  static const Color expense       = Color(0xFFEF4444); // Red-500
  static const Color incomeLight   = Color(0xFFD1FAE5);
  static const Color expenseLight  = Color(0xFFFEE2E2);

  // Neutrals
  static const Color background    = Color(0xFFF5F3FF); // Violet-50
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color textPrimary   = Color(0xFF1E1B4B); // Indigo-950
  static const Color textSecondary = Color(0xFF6B7280); // Gray-500
  static const Color divider       = Color(0xFFE5E7EB);
  static const Color emptyDonut    = Color(0xFFD1D5DB); // Gray-300 — empty state

  // Category chart colors — index matches category list
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
| Category icon tap target | 64 × 64 |
| Keypad button height | 64.0 |
| Keypad operator column color | AppColors.primaryLight |
| Keypad operator text color | AppColors.primary |

---

## 💱 Currency & Number Formatting

**Locale:** Russian (`ru_RU`)
**Format:** `1 250,50 ₽` — space as thousands separator, comma as decimal, ₽ symbol at end.

```dart
// lib/core/utils/currency_formatter.dart
// Use NumberFormat from the intl package:
// NumberFormat.currency(locale: 'ru_RU', symbol: '₽', decimalDigits: 2)
// Example output: "1 250,50 ₽"
```

All monetary values stored internally as `double` in **kopecks-as-double** (e.g. 1250.50).
Display always goes through `CurrencyFormatter` — never format inline in widgets.

---

## 📱 Screen Specs

---

### Screen 1: `home_page.dart`

**Route:** `/` (root)

```
┌────────────────────────────────────────┐
│  [≡]        Spendo          [⚙]        │  AppBar
├────────────────────────────────────────┤
│   [Day]    [Week]    [Month]           │  FilterChip row — period selector
├────────────────────────────────────────┤
│                                        │
│    Category icons orbit the donut      │
│    chart using polar coordinates.      │
│    (see layout math below)             │
│                                        │
│    Donut center (no transactions):     │
│      grey ring + "₽ 0,00" centered    │
│                                        │
│    Donut center (with transactions):   │
│      "₽ 0,00"       ← income (green)  │
│      "₽ 16 592,00"  ← expense (red)   │
│                                        │
├────────────────────────────────────────┤
│ ████  Balance  −₽ 16 592,00  ████████ │  Balance bar
├────────────────────────────────────────┤
│    [○  − Расход]    [○  + Доход]       │  Action buttons
└────────────────────────────────────────┘
```

**Donut chart (`donut_chart_widget.dart`):**
- Widget: `fl_chart` `PieChart`
- Each segment: color = `AppColors.categoryPalette[categoryIndex]`
- Segment arc size: proportional to total expense amount per category
- Center hole radius: ~55 % of total chart radius
- Center widget: `Column` with income text (green) and expense text (red/primary)
- **Empty state:** single grey segment (`AppColors.emptyDonut`) covering 360°,
  center shows `"₽ 0,00"` in `textSecondary` — no category breakdown
- **Tapping a segment:** navigates to `transaction_list_page.dart` passing the
  `categoryKey` as a route parameter

**Category icon orbit (`category_icon_button.dart`):**
- Layout: `Stack` + `Positioned`, 10 icons placed via polar-to-Cartesian math:
  ```
  dx = centerX + radiusX * cos(angle)
  dy = centerY + radiusY * sin(angle)
  angle = (2π / 10) * index − π/2   // start from top
  ```
- Each `CategoryIconButton`: icon (32px) above, Russian l10n label below (12px)
- Tap → navigates to `add_transaction_page.dart` in **create mode** with
  `initialCategory` and `TransactionType.expense` pre-set

**Period filter:**
- `FilterChip` row: Сегодня / Неделя / Месяц
- Phase 1: `setState` to track `selectedPeriod`, re-filter mock data

**Balance bar:**
- Full-width `Container`, `AppColors.primary` background, white text
- Shows: `"Баланс  −₽ 16 592,00"` (negative when expenses > income)

**Action buttons:**
- Two `OutlinedButton` with circular shape
- Left: red outline + red `−` icon → `"− Расход"` → navigates to
  `add_transaction_page.dart` in **create mode**, `TransactionType.expense`
- Right: green outline + green `+` icon → `"+ Доход"` → navigates to
  `add_transaction_page.dart` in **create mode**, `TransactionType.income`,
  no category pre-selected (income has no category in v1)

---

### Screen 2: `add_transaction_page.dart`

**Two modes — passed via constructor or route params:**

| Mode | Trigger | Pre-filled data | AppBar right icon |
|---|---|---|---|
| `create` | Tapping category icon or action button | type + optional category | none |
| `edit` | Tapping a transaction in the list | all fields from existing Transaction | 🗑 delete icon |

**Route:**
- Create: `/add?type=expense&categoryKey=food`
- Edit: `/edit/:transactionId`

```
┌────────────────────────────────────────┐
│  ←   Новый расход / Редактировать  [🗑]│  AppBar — delete icon only in edit mode
├────────────────────────────────────────┤
│  📅  Среда, 25 марта                   │  Tappable row → showDatePicker
├────────────────────────────────────────┤
│ ┌────────────────────────────────────┐ │
│ │  ₽  |  200 + 50             [⌫]  │ │  Amount display — primaryDark bg
│ │  RUB                               │ │  Shows live expression string while typing
│ └────────────────────────────────────┘ │  Evaluates on = press
│                                        │
│  ✏  Примечание ______________________ │  Optional TextField, no border, pen icon
│                                        │
├────────────────────────────────────────┤
│  [1]  [2]  [3]  [+]                   │
│  [4]  [5]  [6]  [−]                   │  calculator_keypad.dart
│  [7]  [8]  [9]  [×]                   │
│  [.]  [0]  [=]  [÷]                   │
├────────────────────────────────────────┤
│       [ ВЫБРАТЬ КАТЕГОРИЮ  ▼ ]        │  → opens CategoryPickerSheet
└────────────────────────────────────────┘
```

**Calculator behavior (`calculator_keypad.dart`):**
- Amount display shows the **raw expression string** as the user types: `"200 + 50"`
- On `=` press: evaluate the expression → replace display with result: `"250"`
- On `⌫` press: remove the last character from the expression string
- Operator buttons (`+ − × ÷`) are highlighted: `AppColors.primaryLight` bg,
  `AppColors.primary` text
- After `=` evaluates, pressing a digit starts a new expression
- Store expression in `setState` (`String _expression`) during Phase 1

**Date row:**
- Tap → `showDatePicker` with `initialDate: DateTime.now()`
- Display format: `"EEEE, d MMMM"` in Russian locale (e.g. `"Среда, 25 марта"`)

**Category picker (`category_picker_sheet.dart`):**
- `showModalBottomSheet` with drag handle
- `GridView` 4 columns of `CategoryIconButton`
- Selected category highlighted: `AppColors.primaryLight` background,
  `AppColors.primary` border
- Income transactions (`TransactionType.income`) skip category — button label
  shows `"Доход"` and sheet does not open

**On save — create mode (Phase 1):**
- Validate: expression must evaluate to `> 0` and a category must be selected
  (for expenses)
- Pop and show `SnackBar`: `"Расход добавлен"` / `"Доход добавлен"`

**On save — edit mode (Phase 1):**
- Same validation, pop and show `SnackBar`: `"Изменения сохранены"`

**On delete — edit mode (Phase 1):**
- Tap 🗑 → `showDialog` confirmation: `"Удалить транзакцию?"` with
  `"Отмена"` / `"Удалить"` buttons
- On confirm: pop and show `SnackBar`: `"Транзакция удалена"`

---

### Screen 3: `transaction_list_page.dart`

**Trigger:** Tapping a donut chart segment on the home screen.
**Route:** `/transactions/:categoryKey`

```
┌────────────────────────────────────────┐
│  ←   [Category Icon]  Еда и продукты  │  AppBar — category icon + Russian name
├────────────────────────────────────────┤
│  Итого расходы:  ₽ 5 320,00           │  Summary bar — total for this category
├────────────────────────────────────────┤
│  ┌──────────────────────────────────┐  │
│  │ [🍔] Еда и продукты  Пн, 24 мар │  │
│  │       Мясо 🍗           −₽320,00│  │  TransactionListItem
│  └──────────────────────────────────┘  │
│  ┌──────────────────────────────────┐  │
│  │ [🍔] Еда и продукты  Вт, 25 мар │  │
│  │       Кофе               −₽90,00│  │
│  └──────────────────────────────────┘  │
│  ...                                   │
└────────────────────────────────────────┘
```

**`TransactionListItem` widget (`transaction_list_item.dart`):**
- Left: category `Icon` in a colored circular avatar (`AppColors.primaryLight` bg)
- Middle: category Russian label (top, `textSecondary`), note text (bottom, `textPrimary`)
- Right: amount formatted in Russian locale, colored red for expense / green for income
- Sub-info: date formatted as `"Пн, 24 мар"` (`"EEE, d MMM"` Russian locale)
- Tap → navigates to `add_transaction_page.dart` in **edit mode** passing the
  `transactionId`

**List:**
- `ListView.separated` with `Divider` separator
- Sorted: most recent date first
- Filtered: only transactions matching `categoryKey` and selected `period`

**Empty state for this screen:**
- Centered icon + text: `"Нет транзакций в этой категории"`

---

### Drawer: `AppLeftDrawer`

```
┌───────────────────────────┐
│ [Avatar]   Spendo User    │  Mock in Phase 1
│            user@mail.com  │
├───────────────────────────┤
│ 📅  Период                │  → sub-items: Сегодня / Неделя / Месяц / Свой
│ 💰  Все счета             │  → TBD (single account in v1)
│ 📊  Бюджет                │  → TBD
├───────────────────────────┤
│ ☁  Синхронизация: Офлайн  │  Static in Phase 1 — live in Phase 3
└───────────────────────────┘
```

### Drawer: `AppRightDrawer`

```
┌───────────────────────────┐
│ ⚙  Настройки              │
├───────────────────────────┤
│ 🏷  Категории             │  → TBD manage categories page
│ 🌙  Тёмная тема           │  → Toggle widget (non-functional Phase 1)
│ 📤  Экспорт               │  → TBD (PDF / CSV)
│ 🔐  Войти                 │  → Auth flow — Phase 3
├───────────────────────────┤
│ ℹ️  О приложении          │  → Static AlertDialog
└───────────────────────────┘
```

---

## 🗂️ Categories — v1 Predefined Set

| Index | Flutter Icon | Key | Russian Label | Hex Color |
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

Categories are defined as a static list in `lib/core/mock/mock_data.dart` during
Phase 1, then migrated to `CategoryRepository` in Phase 2.

---

## 🧱 Domain Entities

```dart
// lib/features/transactions/domain/entities/transaction.dart

enum TransactionType { expense, income }

class Transaction extends Equatable {
  final String id;
  final double amount;          // stored in full units (e.g. 1250.50)
  final String? categoryKey;    // null for income in v1
  final TransactionType type;
  final DateTime date;
  final String? note;

  const Transaction({
    required this.id,
    required this.amount,
    this.categoryKey,
    required this.type,
    required this.date,
    this.note,
  });

  @override
  List<Object?> get props => [id, amount, categoryKey, type, date, note];
}
```

```dart
// lib/features/categories/domain/entities/category.dart

class Category extends Equatable {
  final String key;
  final String labelKey;   // l10n key → Russian label
  final IconData icon;
  final Color color;

  const Category({
    required this.key,
    required this.labelKey,
    required this.icon,
    required this.color,
  });

  @override
  List<Object?> get props => [key];
}
```

---

## 🧩 Code Standards

```
DO:
  - Extract any widget exceeding ~40 lines into its own dedicated file
  - Use const constructors everywhere possible
  - Use Either<Failure, T> for all repository return types (Phase 2+)
  - Check `mounted` before using BuildContext across any async gap
  - Route with go_router named routes exclusively
  - Use debugPrint() — never print()
  - Format all monetary values through CurrencyFormatter only

DON'T:
  - Hardcode Russian / Cyrillic strings in widget code — always use l10n
  - Place business logic inside widgets or pages
  - Throw exceptions from repositories — catch and return Failure
  - Use global variables or static singletons for services
  - Import data/ from presentation/ or domain/
  - Format currency inline in widgets
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

## 🗄️ Data Strategy (Phase 2+ reference)

```
User action
    │
    ▼
[Isar — local DB]    Primary source of truth. Always offline-capable.
    │
    ▼  (only when authenticated)
[Cloud Firestore]    Cloud backup & multi-device sync.

Firestore path structure:
  users/{uid}/transactions/{transactionId}
  users/{uid}/categories/{categoryId}      ← custom categories only (Phase 2+)
```

Repository returns `Either<Failure, T>` — domain layer never sees exceptions.

---

## 🔐 Auth Plan (Phase 3)

- Providers: **Email/Password** + **Google Sign-In** via `firebase_auth`
- Unauthenticated users: full app in **local-only mode**, zero login gate
- First successful login: upload all Isar data to Firestore
- Auth state drives `go_router` redirect guards on protected routes

---

## 🎓 Thesis Reference

When the developer asks for a thesis explanation, structure the answer:
1. What was chosen + alternatives considered
2. Why — technical justification
3. Trade-offs — what is given up
4. How it applies specifically to this project

| Topic | Thesis angle |
|---|---|
| Clean Architecture layers | SOLID, testability, separation of concerns |
| Offline-first strategy | Resilience, UX, swappable data layer |
| Repository pattern | Datasource abstraction, domain independence |
| BLoC pattern | Predictable state machine, testability, explicit events |
| Flutter cross-platform | Single codebase trade-offs vs native development |
| Firebase Auth + Firestore | Managed BaaS trade-offs vs self-hosted backend |

---

## ✅ Feature Status

| Feature | Phase | Status |
|---|---|---|
| Home screen — donut chart + category orbit | 1 | 🔲 Not started |
| Home screen — period filter chips | 1 | 🔲 Not started |
| Home screen — balance bar | 1 | 🔲 Not started |
| Home screen — empty state (grey donut) | 1 | 🔲 Not started |
| Add transaction screen — create mode | 1 | 🔲 Not started |
| Add transaction screen — edit mode + delete | 1 | 🔲 Not started |
| Calculator keypad with expression display | 1 | 🔲 Not started |
| Category picker bottom sheet | 1 | 🔲 Not started |
| Transaction list screen (filtered by category) | 1 | 🔲 Not started |
| Left drawer | 1 | 🔲 Not started |
| Right drawer | 1 | 🔲 Not started |
| Russian locale currency formatting | 1 | 🔲 Not started |
| BLoC wiring + Isar integration | 2 | 🔲 Not started |
| Firebase Auth | 3 | 🔲 Not started |
| Firestore sync | 3 | 🔲 Not started |
| Dark mode | TBD | — |
| Export PDF / CSV | TBD | — |
| Budget limits per category | TBD | — |
| Recurring transactions | TBD | — |

---

## 🔲 Still To Decide (discuss before Phase 2)

- [ ] Minimum Android SDK version (default assumption: API 21 / Android 5.0)
- [ ] Splash screen design (current assumption: violet bg + white "S" wordmark)
- [ ] App icon design
- [ ] Whether the `[↺]` recurring icon is a real planned feature or removed from v1
- [ ] Income category support (v1 has no category for income — confirm this)
- [ ] Dark mode: Phase 2 or TBD?

---

## 🚀 Phase 1 — First Claude Code Session Prompt

Copy and paste this verbatim to start the first session:

```
Read CLAUDE.md fully before writing any code.

We are in Phase 1: UI only, mock data, setState for local interactions only.
No BLoC, no Isar, no Firebase.

Task 1: Scaffold the complete folder structure from CLAUDE.md.
Task 2: Implement app_colors.dart and app_theme.dart from the design system.
Task 3: Implement mock_data.dart with at least 10 sample transactions
        spread across at least 5 categories.
Task 4: Implement home_page.dart — donut chart, category icon orbit using
        polar coordinates, period filter chips, balance bar, and the two
        action buttons. Use mock data. Handle the empty state (grey donut).

Do not add BLoC, Isar, or Firebase code. Do not skip extracting widgets
into their own files.
```
