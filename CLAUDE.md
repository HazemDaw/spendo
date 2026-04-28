# CLAUDE.md - Spendo

This file is the working guide for future Claude/Codex sessions in this repo.

If this document and the code disagree, the code is the source of truth. Update
this file when architecture, product direction, or implementation status changes.

---

## Project Snapshot

- App: `Spendo`
- Type: Flutter mobile app for personal expense tracking
- Context: graduation project / thesis work
- Platforms: Android and iOS
- Current state: complete thesis build. Phases 1, 2, and 3 are implemented.
- Core direction: offline-first expense tracking with a custom Monefy-inspired
  home screen, Drift/SQLite persistence, BLoC state management, Firebase auth/sync,
  Russian/English localization, persistent dark mode, budgets, export, and
  custom categories.

---

## Complete Feature Set

### Phase 1 - UI and Transaction Experience

Complete. The app includes the full user-facing transaction experience:

- Custom home screen with fixed-reference `738 x 1600` canvas scaled by
  `FittedBox`
- Donut chart with category totals
- Orbit category icons around the chart
- Connector lines between orbit icons and chart slices
- Swipe navigation between periods
- Full-screen animated period transition
- Adjacent period labels on the home screen
- Six period types: day, week, month, year, all time, interval
- Add, edit, and delete transactions
- Calculator keypad for amount entry
- Category picker
- Category transaction list
- All transactions screen
- Search over transactions
- Left drawer and right drawer
- Balance bar navigation to all transactions
- Date labels based on the selected period and current reference date
- Localized home labels and actions

### Phase 2 - Offline-First Data and State

Complete. Local state and persistence are implemented with:

- Drift/SQLite offline-first database
- Clean-architecture-style layers: presentation, domain, data
- Repository APIs returning `Either<Failure, T>`
- Transaction data model, datasource, repository, and use cases
- `TransactionBloc` for loading, adding, updating, deleting, and reloading
  transactions
- `KeypadCubit` for calculator keypad state
- `PeriodCubit` registered for period state support
- `get_it` dependency injection
- Local custom category storage
- Budget storage
- Widget and bloc tests for core transaction behavior

### Phase 3 - Auth and Cloud Sync

Complete. Authentication and remote sync are implemented with:

- Firebase Auth
- Email/password sign-in and registration
- Google sign-in
- Auth BLoC/state flow
- Auth-aware drawer header
- Google profile photo in the authenticated drawer header when available
- Firestore transaction sync
- First-login upload of local Drift transactions
- Local-only mode for unauthenticated users
- Sync status displayed in the left drawer

### Extra Features

Complete. The app also includes:

- Persistent dark mode via `ThemeCubit` and `SharedPreferences`
- Russian and English language switching via `LocaleCubit` and
  `SharedPreferences`
- `flutter_localizations` and generated app localization classes
- PDF export
- CSV export
- Budget limits
- Budget warning banner on the home screen
- Budget page with total and per-category limits
- Custom categories
- Categories page
- Orbit slot swapping
- Custom category picker support
- Export bottom sheet
- Right drawer settings/actions
- Recurring transactions placeholder

---

## Tech Stack In Use

- Flutter
- `flutter_bloc`
- `equatable`
- `dartz`
- `go_router`
- `get_it`
- `drift` + `drift_flutter` + `sqlite3_flutter_libs`
- `path_provider`
- `shared_preferences`
- `intl`
- `flutter_localizations`
- `google_fonts`
- `fl_chart`
- Firebase Core
- Firebase Auth
- Cloud Firestore
- Google Sign-In
- `pdf`
- `csv`
- `share_plus`

Do not introduce a new state management or persistence stack unless explicitly
requested. The app direction is BLoC + Drift/SQLite + Firebase sync.

---

## Architecture

The app follows a clean-architecture-flavored structure:

- `presentation` triggers events and renders state
- `domain` defines entities, repositories, and use cases
- `data` implements repositories, datasources, models, and persistence details
- Repositories return `Either<Failure, T>` instead of throwing upward for
  expected failures
- Dependency registration is centralized in `lib/injection_container.dart`

Transaction flow:

```text
UI -> TransactionBloc -> UseCases -> TransactionRepository
   -> Local/Remote Datasources -> Drift/SQLite / Firestore
```

Core files:

- `lib/main.dart`
- `lib/injection_container.dart`
- `lib/core/theme/theme_cubit.dart`
- `lib/core/locale/locale_cubit.dart`
- `lib/core/utils/date_utils.dart`
- `lib/features/transactions/presentation/bloc/transaction_bloc.dart`
- `lib/features/transactions/data/datasources/transaction_local_datasource.dart`
- `lib/features/transactions/data/datasources/transaction_remote_datasource.dart`
- `lib/features/transactions/data/repositories/transaction_repository_impl.dart`
- `lib/features/auth/presentation/bloc/auth_bloc.dart`
- `lib/features/auth/data/datasources/firebase_auth_datasource.dart`

---

## Routing

Routes are defined in `lib/main.dart`.

- `/` -> home
- `/add` -> add transaction
- `/edit/:transactionId` -> edit transaction
- `/transactions/:categoryKey` -> category transaction list
- `/all-transactions` -> all transactions grouped by category
- `/budget` -> budget page
- `/categories` -> categories page
- `/login` -> login
- `/register` -> registration

At app startup:

- Dependency injection is initialized
- `ThemeCubit` loads persisted dark/light preference
- `LocaleCubit` loads persisted Russian/English preference
- `Intl.defaultLocale` is kept in sync with the selected app locale
- `TransactionBloc` loads the current period
- Auth state is checked and sync behavior follows authentication status

---

## Home Screen Direction

The home screen is a custom fixed-reference composition. Treat it as visually
locked unless the user explicitly asks for redesign.

Preserve these characteristics:

- `home_page.dart` uses a `738 x 1600` reference canvas
- The screen is scaled via `FittedBox`
- Layout is heavily position-based, not a standard responsive column layout
- The composition is fragile; do not normalize it into generic Material layout
- The home screen uses a custom Monefy-inspired visual system
- Standard screens rely on `AppTheme` and the purple token set in
  `lib/core/theme`
- Orbit icons, connector lines, donut geometry, balance bar, and action buttons
  are visually sensitive

Before changing category rendering, verify whether the change affects:

- Orbit layout
- Donut slices
- Connector lines
- List filtering
- Category picker behavior
- Budget warning labels
- Custom category mapping

---

## Data and Domain Notes

### Transactions

- `TransactionType` supports `expense` and `income`
- Income transactions can have `categoryKey == null`
- Transactions are identified by string `id`
- Mutations reload the active period after success
- Transaction state is exposed through `TransactionBloc`

### Periods

Supported periods:

- `day`
- `week`
- `month`
- `year`
- `all`
- `interval`

Date-range logic lives in `lib/core/utils/date_utils.dart`. The home screen
uses period state to dispatch `LoadTransactionsEvent` with reference date and,
for intervals, optional start/end dates.

### Categories

- Built-in category metadata lives in `MockData`
- Do not remove `MockData`; transaction storage moved to Drift/SQLite, but category
  metadata still depends on it
- Custom categories are persisted locally
- Category labels must go through `CategoryLocalizer` / `AppLocalizations`
- Orbit slot swapping lets users replace default orbit slots with custom
  categories

### Budgets

- Budgets support total limits and per-category limits
- Budget page shows built-in and visible custom categories
- Home page displays a warning banner when budgets approach or exceed limits
- Budget warning labels are localized

### Auth and Sync

- Unauthenticated users can use the app in local-only mode
- Authenticated users sync through Firestore
- First login uploads local Drift transactions
- Drawer sync status reflects auth/sync state
- Authenticated drawer header shows display name/email and Google photo when
  available

---

## Localization Rules

- The app supports Russian and English via `flutter_localizations`
- User-facing strings must never be hardcoded in widget code
- Always use `AppLocalizations` for user-facing strings
- Category names should use `CategoryLocalizer`
- Language preference persists via `SharedPreferences` in `LocaleCubit`
- `LocaleCubit` updates `Intl.defaultLocale`
- ARB files live in `lib/l10n`
- Keep English strings in `app_en.arb`
- Keep Russian strings in `app_ru.arb`
- Generated localization classes are checked in and used by the app

---

## Theme Rules

- Dark mode persists via `SharedPreferences` in `ThemeCubit`
- Standard screens should use `AppTheme` and `AppColors`
- The home screen intentionally has a distinct custom visual system
- Do not silently force the home screen to match generic app theme styling

---

## Testing Status

Existing tests cover:

- Transaction bloc reload behavior after add/update/delete
- Add transaction keypad input
- Edit-screen hydration after async load

Test helpers:

- `test/helpers/in_memory_transaction_repository.dart`

When making non-trivial changes, run:

- `flutter analyze`
- `flutter test`

If a command times out or hangs, record that clearly in the final response.

---

## Working Rules For Future Sessions

1. Treat the current app as feature-complete for the thesis build.
2. Do not reintroduce phase prompts or old "not started" language.
3. Do not revert the home screen to the old purple spec.
4. Home screen uses `FittedBox` with a `738 x 1600` reference canvas; treat it as
   fragile and do not normalize it.
5. Never hardcode user-facing strings; always use `AppLocalizations`.
6. Preserve Russian/English localization and persisted language switching.
7. Preserve persisted dark mode behavior.
8. Keep transaction persistence offline-first.
9. Keep repository APIs returning `Either<Failure, T>`.
10. Do not throw from repositories for expected data-layer failures.
11. Avoid large architecture rewrites when the user asked for a focused fix.
12. Prefer preserving route names and existing navigation contracts.
13. Before changing category rendering, verify orbit, donut, connectors, lists,
    picker behavior, and budget behavior.
14. Run `flutter analyze` and `flutter test` after every non-trivial change.
15. Work with existing dirty files; never revert user changes unless explicitly
    requested.

---

## Known Gaps / Post-Thesis Roadmap

These are roadmap items, not blockers for the final thesis build:

- Recurring transactions: UI placeholder exists, logic is not built
- Financial insights / analytics screen
- Multi-account support
- Budget export
- Custom category in home orbit: currently picker/storage support exists, but
  full home-orbit rendering is not complete
- Pets and gifts missing from default orbit: the app defines 10 built-in
  categories, but the default home orbit shows 8 of 10

---

## Thesis Framing

When asked for thesis-oriented explanations, structure as:

1. What was implemented
2. Why it was chosen over nearby alternatives
3. Trade-offs
4. How it supports the project goals

| Topic | Thesis angle |
|---|---|
| Clean Architecture | SOLID, testability, layer isolation |
| Drift/SQLite over Isar | SQL-backed portability, generated type-safe queries, release-build stability |
| BLoC over setState | Predictable state machine, testability, explicit event log |
| Offline-first | Resilience, UX continuity, local-first UX |
| Repository pattern | Datasource abstraction, domain independence |
| Flutter cross-platform | Single codebase trade-offs vs native |
| Firebase Auth + Firestore | Managed BaaS vs self-hosted: cost, scalability, lock-in |
| Localization | Internationalization readiness and accessibility for RU/EN users |
| Persistent settings | User preference continuity through local storage |
| FittedBox canvas approach | Fixed-reference visual fidelity vs responsive flexibility |
