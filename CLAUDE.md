# CLAUDE.md - Spendo

This file is the working guide for future Claude/Codex sessions in this repo.

If this document and the code disagree, the code is the source of truth. Update
this file when architectural decisions, product direction, or implementation
status changes.

---

## Project Snapshot

- App: `Spendo`
- Type: Flutter mobile app for personal expense tracking
- Context: graduation project / thesis work
- Platforms: Android and iOS
- Current state: Phase 2 complete (offline-first with Isar + BLoC).
  Pre-Phase 3 polish in progress. Auth and cloud sync not implemented yet.

---

## Current Progression

### Phase 1 - UI foundation
Completed. Core screens and custom Monefy-inspired visual direction in place.

### Phase 2 - local state and persistence
Completed. Implemented in the current codebase:
- `get_it` dependency injection
- Isar transaction storage
- transaction data model, datasource, repository, and use cases
- `TransactionBloc` with load/add/update/delete events
- `KeypadCubit`
- add/edit/delete transaction flow backed by the bloc
- transaction list screen backed by loaded state
- startup load for the current month
- widget and bloc tests for the implemented transaction flow

Important nuance:
- `PeriodCubit` is registered in DI but is not the current driver of the home
  screen UI
- the home screen still uses local widget state to cycle period and dispatches
  `LoadTransactionsEvent` directly

### Pre-Phase 3 Polish (CURRENT)
In progress. Must be fully verified before Phase 3 begins.

| Fix | Status |
|---|---|
| Note field restricted to English input only | 🔲 Not fixed |
| Balance bar not tappable / no all-transactions screen | 🔲 Not built |
| Date header hardcoded, not reflecting real current date | 🔲 Not fixed |
| Left drawer is a stub | 🔲 Not built |
| Right drawer is a stub | 🔲 Not built |

### Phase 3 - auth and sync
Not started. Do not begin until all Pre-Phase 3 items above are resolved.

Current placeholder state:
- `/login` and `/register` routes exist but pages are placeholders
- remote datasource file exists as a placeholder
- no Firebase packages in `pubspec.yaml`

---

## Tech Stack In Use

- Flutter
- `flutter_bloc`
- `equatable`
- `dartz`
- `go_router`
- `get_it`
- `isar` + `isar_flutter_libs`
- `path_provider`
- `intl`
- `google_fonts`
- `fl_chart`

Do not introduce a new state management or persistence stack unless explicitly
requested. The current direction is BLoC + Isar.

---

## Architecture

Clean-architecture-flavored:
- `presentation` triggers events and renders state
- `domain` defines entities, repositories, and use cases
- `data` implements repositories and datasources
- repositories return `Either<Failure, T>` instead of throwing upward

Current transaction flow:
```
UI -> TransactionBloc -> UseCases -> TransactionRepository
   -> TransactionLocalDatasource -> Isar
```

Main files:
- `lib/main.dart`
- `lib/injection_container.dart`
- `lib/features/transactions/presentation/bloc/transaction_bloc.dart`
- `lib/features/transactions/data/datasources/transaction_local_datasource.dart`
- `lib/features/transactions/data/repositories/transaction_repository_impl.dart`
- `lib/features/transactions/data/models/transaction_model.dart`

---

## Current Routing

Defined in `lib/main.dart`:
- `/`                          -> home
- `/add`                       -> add transaction
- `/edit/:transactionId`       -> edit transaction
- `/transactions/:categoryKey` -> category transaction list
- `/all-transactions`          -> all transactions grouped by category (to be built)
- `/login`                     -> placeholder
- `/register`                  -> placeholder

At app startup:
- `Intl.defaultLocale = 'ru_RU'`
- DI is initialized
- `TransactionBloc` is created at app level
- app dispatches `LoadTransactionsEvent(TransactionPeriod.month)`

---

## UI Direction That Must Be Preserved

The home screen is a custom fixed-reference composition.
Treat it as visually locked unless the user explicitly asks for redesign.

Preserve these characteristics:
- `home_page.dart` uses a reference canvas of `738 x 1600`
- the screen is scaled via `FittedBox`
- layout is heavily position-based, not standard responsive column layout
- the home screen uses a mint/green Monefy-like palette
- the home screen intentionally overrides the general app theme colors
- orbit icons and connectors are custom positioned around the donut chart

Do not normalize the home screen into generic Material widgets or force it to
match the shared `AppTheme` unless explicitly asked.

Also note:
- standard screens rely on `AppTheme` and the purple token set in `lib/core/theme`
- the home screen and shared theme currently have different visual systems
- that mismatch is intentional in the codebase — do not silently fix it

---

## Pre-Phase 3 Fix Specs

### Fix 1 — Note Field Language Bug

File: `add_transaction_page.dart`

The note TextField must accept all languages including Russian/Cyrillic.

Required TextField properties:
```dart
keyboardType: TextInputType.text
textInputAction: TextInputAction.done
enableSuggestions: true
autocorrect: false
```

Check that NO `inputFormatters` are attached to the note field.
If any `FilteringTextInputFormatter` or custom formatter exists on the
note field, remove it entirely.

Do not touch the amount/expression display field — that is separate.

---

### Fix 2 — Balance Bar → All Transactions Screen

#### Balance bar change
Wrap the existing balance bar Container in a GestureDetector:
```dart
onTap: () => context.push('/all-transactions')
```
Do not change the visual appearance of the balance bar.

#### New screen: `all_transactions_page.dart`

File: `lib/features/transactions/presentation/pages/all_transactions_page.dart`
Route: `/all-transactions`

AppBar:
- title: "Все транзакции" (l10n)
- leading: back arrow

Layout: `ListView` of category sections.

Each section:
1. Category header row:
   - `[CategoryIcon]  [Russian category name]  [total amount]`
   - background: `AppColors.primaryLight`
   - padding: 12px vertical, 16px horizontal
   - total amount: red for expense categories, green for income
2. `TransactionListItem` widgets for each transaction in that category
   - reuse existing `TransactionListItem` exactly as-is
   - sorted: most recent date first within each category
3. `Divider` between sections

Section ordering: sort by total absolute amount, largest section first.

Income transactions (`categoryKey == null`) group under a section
labeled "Доход" with `Icons.arrow_upward` in `AppColors.income` color.

Empty state: centered icon + "Нет транзакций".

Data source: reads from `TransactionBloc` loaded state — the same
transactions already loaded on the home screen.

---

### Fix 3 — Date Header Must Reflect Real Current Date

The date text displayed above the donut chart must be computed from
`DateTime.now()` and the currently selected period — never hardcoded.

Rules:
- "Сегодня" selected → `DateFormat('d MMM yyyy', 'ru_RU').format(DateTime.now())`
  example: "9 апр 2026"
- "Неделя" selected → "3 апр — 9 апр"
  (Monday of current week → today, Russian locale)
- "Месяц" selected → `DateFormat('MMM yyyy', 'ru_RU').format(DateTime.now())`
  example: "апр 2026"

Use `DateFormat` from the `intl` package with locale `'ru_RU'`.
Remove all hardcoded date strings from the home screen.
Do not touch the chart, icons, balance bar, or any other widget.

---

### Fix 4 — Left Drawer (AppLeftDrawer)

File: `lib/features/transactions/presentation/widgets/app_left_drawer.dart`

Wire to Scaffold: `drawer: AppLeftDrawer(...)`
Left hamburger icon in AppBar calls: `Scaffold.of(context).openDrawer()`

Structure:

**DrawerHeader:**
- background: `AppColors.primary`
- `CircleAvatar` (radius 30, bg: `AppColors.primaryLight`)
  - child: `Icon(Icons.person, color: AppColors.primary, size: 30)`
- "Spendo User" — white, w600, 16px
- "user@spendo.app" — white70, 13px

**Period section:**
- `ListTile` showing current period label with `Icons.calendar_today`
- Indented sub-list of 3 tappable items: Сегодня / Неделя / Месяц
- Selected item shows a checkmark
- Tapping updates the home screen period and closes the drawer

**Accounts section:**
```dart
ListTile(
  leading: Icon(Icons.account_balance_wallet, color: AppColors.primary),
  title: Text("Все счета"),
  trailing: Icon(Icons.chevron_right),
  onTap: () => showDialog(... "Функция будет доступна позже"),
)
```

**Budget section:**
```dart
ListTile(
  leading: Icon(Icons.pie_chart, color: AppColors.primary),
  title: Text("Бюджет"),
  trailing: Icon(Icons.chevron_right),
  onTap: () => showDialog(... "Функция будет доступна позже"),
)
```

**Divider**

**Sync status (bottom, non-interactive):**
```dart
ListTile(
  leading: Icon(Icons.cloud_off, color: AppColors.textSecondary),
  title: Text("Синхронизация"),
  subtitle: Text("Только локально"),
)
```

---

### Fix 5 — Right Drawer (AppRightDrawer)

File: `lib/features/transactions/presentation/widgets/app_right_drawer.dart`

Wire to Scaffold: `endDrawer: AppRightDrawer()`
Right hamburger icon in balance bar calls: `Scaffold.of(context).openEndDrawer()`

Structure:

**DrawerHeader:**
- background: `AppColors.primaryDark`
- "Настройки" — white, w700, 20px

**Categories:**
```dart
ListTile(
  leading: Icon(Icons.label, color: AppColors.primary),
  title: Text("Категории"),
  trailing: Icon(Icons.chevron_right),
  onTap: () => showDialog(... "Управление категориями будет доступно позже"),
)
```

**Divider**

**Dark mode toggle (local setState only — no real theme change):**
```dart
SwitchListTile(
  secondary: Icon(Icons.dark_mode, color: AppColors.primary),
  title: Text("Тёмная тема"),
  value: _darkMode,
  onChanged: (val) => setState(() => _darkMode = val),
  activeColor: AppColors.primary,
)
```

**Export:**
```dart
ListTile(
  leading: Icon(Icons.upload_file, color: AppColors.primary),
  title: Text("Экспорт данных"),
  trailing: Icon(Icons.chevron_right),
  onTap: () => showDialog(... "Экспорт будет доступен позже"),
)
```

**Divider**

**Sign In:**
```dart
ListTile(
  leading: Icon(Icons.login, color: AppColors.primary),
  title: Text("Войти / Зарегистрироваться"),
  trailing: Icon(Icons.chevron_right),
  onTap: () {
    Navigator.pop(context);
    context.push('/login');
  },
)
```

**Divider**

**About:**
```dart
ListTile(
  leading: Icon(Icons.info_outline, color: AppColors.textSecondary),
  title: Text("О приложении"),
  onTap: () => showAboutDialog(
    context: context,
    applicationName: 'Spendo',
    applicationVersion: '1.0.0',
    children: [Text('Приложение для отслеживания личных расходов.')],
  ),
)
```

---

## Data and Domain Notes

### Transaction entity
- `TransactionType` supports `expense` and `income`
- income can have `categoryKey == null`
- transactions are identified by string `id`

### Period handling
- supported periods: `day`, `week`, `month`
- date-range logic lives in `lib/core/utils/date_utils.dart`
- home screen cycles period locally and reloads bloc state

### Category metadata
`MockData` is still used for category definitions (keys, icons, colors, label keys).
Do not remove `MockData` — transaction storage moved to Isar but category
metadata remains here.

Known limitation:
- app defines 10 categories in `MockData`
- orbit currently maps only 8 categories
- `pets` and `gifts` exist in metadata but are not in the home orbit layout
- do not assume all categories are rendered on the orbit without checking

---

## State Management Notes

### Implemented
- `TransactionBloc`
- `KeypadCubit`
- `TransactionState`: initial, loading, loaded, error
- mutation events reload the current period after success

### Partially adopted
- `PeriodCubit` exists, is registered in DI, but is not the current source of
  truth for home screen period changes
- do not claim the current UI already uses `PeriodCubit`

---

## Localization Rules

- code, identifiers, and comments stay in English
- app locale is Russian-oriented
- localization generated from `lib/l10n/*.arb`
- prefer l10n strings for user-facing text on standard screens

Current reality:
- several newer screens already use generated localizations
- home screen still contains some hardcoded English labels
- preserve behavior unless the task is specifically localization cleanup

---

## Testing Status

Existing tests cover:
- bloc reload behavior after add/update/delete
- add transaction keypad input
- edit-screen hydration after async load

Test helpers:
- `test/helpers/in_memory_transaction_repository.dart`

When making non-trivial changes, run:
- `flutter analyze`
- `flutter test`

---

## Working Rules For Future Sessions

1. Do not revert the home screen to the old purple spec.
2. Treat the current custom home layout as deliberate and fragile.
3. Keep transaction persistence offline-first unless the task is Phase 3.
4. Keep repository APIs returning `Either<Failure, T>`.
5. Do not throw from repositories for expected data-layer failures.
6. Avoid large architecture rewrites when the user asked for a focused fix.
7. Prefer preserving route names and existing navigation contracts.
8. Before changing category rendering, verify whether the change affects orbit
   layout, donut slices, list filtering, and category picker behavior.
9. Run `flutter analyze` and `flutter test` after every non-trivial change.
10. Fix one thing per session — do not bundle unrelated changes.

---

## Phase 3 Specification (do not start until Pre-Phase 3 is verified complete)

### Packages to add to pubspec.yaml
```yaml
firebase_core: ^2.x
firebase_auth: ^4.x
cloud_firestore: ^4.x
```

### Auth flow
- Providers: Email/Password + Google Sign-In
- Unauthenticated users: full local-only mode — zero forced login gate
- First successful login: batch upload all Isar transactions to Firestore
- Auth state drives `go_router` redirect guards

### Firestore structure
```
users/{uid}/transactions/{transactionId}
users/{uid}/categories/{categoryId}
```

### Remote datasource
- `TransactionRemoteDatasource` wraps Firestore
- implements same interface as `TransactionLocalDatasource`
- `TransactionRepositoryImpl` switches between local and remote based on
  auth state — domain layer is unaware of which is used

### Sync strategy
- all writes go to Isar first (offline-first preserved)
- if authenticated, mirror write to Firestore in background
- on first login: batch upload local Isar data to Firestore
- on app start with auth: fetch remote diff and merge into Isar

### Phase 3 session prompt
```
Read CLAUDE.md. We are starting Phase 3.
Phases 1 and 2 are complete. Pre-Phase 3 polish is verified complete.
Do not modify any existing UI, BLoC, Isar, or routing code.

Task 1: Add Firebase packages to pubspec.yaml and run flutterfire configure.
Task 2: Implement FirebaseAuthDatasource with email/password and Google Sign-In.
Task 3: Implement AuthBloc with SignIn/SignOut/CheckAuth events and states.
Task 4: Wire go_router redirect guards to AuthBloc state.
Task 5: Implement TransactionRemoteDatasource using Firestore.
Task 6: Update TransactionRepositoryImpl to sync to Firestore when authenticated.
Task 7: Implement first-login batch upload — all Isar transactions to Firestore.

Run flutter analyze and flutter test after each task.
Zero errors before moving to the next task.
```

---

## Known Gaps / Pending Work

- Pre-Phase 3 fixes (see table above) — in progress
- Firebase auth not wired
- Firestore sync not started
- login/register remain placeholder pages
- `pets` and `gifts` missing from home orbit — layout fix pending
- home screen localization incomplete (some hardcoded English remains)
- home screen and app theme are intentionally inconsistent — evaluate before Phase 3
- README is still default Flutter scaffold

---

## Thesis Framing

When asked for thesis-oriented explanations, structure as:
1. what was implemented
2. why it was chosen over nearby alternatives
3. trade-offs
4. how it supports the project goals

| Topic | Thesis angle |
|---|---|
| Clean Architecture | SOLID, testability, layer isolation |
| Isar over SQLite | Performance, Dart-native schema, no ORM overhead |
| BLoC over setState | Predictable state machine, testability, explicit event log |
| Offline-first | Resilience, UX continuity, swappable data layer |
| Repository pattern | Datasource abstraction, domain independence |
| Flutter cross-platform | Single codebase trade-offs vs native |
| Firebase Auth + Firestore | Managed BaaS vs self-hosted — cost, scalability, lock-in |
| Phase-based delivery | Risk reduction, incremental architecture validation |
| FittedBox canvas approach | Fixed-reference layout vs responsive — deliberate trade-off |
