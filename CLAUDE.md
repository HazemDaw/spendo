# CLAUDE.md - Spendo

This file is the working guide for future Claude/Codex sessions in this repo.

If this document and the code disagree, the code is the source of truth. Update
this file when architecture, product direction, or implementation status changes.

---

## Project Snapshot

- App: `Spendo`
- Type: Flutter mobile app for personal expense tracking
- Context: Graduation project / thesis — Amur State University, 09.03.04
- Platforms: Android and iOS
- Current state: **Feature-complete. Final thesis build. Do not add new features.**
- Core direction: Offline-first expense tracking with a custom Monefy-inspired
  home screen, Drift/SQLite persistence, BLoC state management, Firebase auth/sync,
  Russian/English localization, persistent dark mode, budgets, export, spending
  insights, and custom categories.

---

## Complete Feature Set

### Phase 1 — UI and Transaction Experience

- Custom home screen with fixed-reference `738 x 1600` canvas scaled by `FittedBox`
- Donut chart with category totals
- Orbit category icons around the chart with connector lines
- PageView-based period swiping (physical swipe, carousel feel)
- Adjacent period labels on the home screen
- Six period types: day, week, month, year, all time, interval
- Add, edit, and delete transactions
- Transaction undo snackbar after delete (4s window)
- Transaction success feedback (violet SnackBar + haptic on save)
- Calculator keypad for amount entry with expression evaluation
- Category picker
- Category transaction list
- All transactions screen with filter chips (type + category) and search
- Search over transactions via SearchDelegate
- Left drawer and right drawer
- Balance bar navigation to all transactions
- Date labels based on selected period and reference date
- Localized home labels and actions
- Haptic feedback on key interactive elements

### Phase 2 — Offline-First Data and State

- Drift/SQLite offline-first database (4 tables: Transactions, Budgets,
  CustomCategories, OrbitSlots)
- Clean Architecture layers: presentation, domain, data
- Repository APIs returning `Either<Failure, T>`
- Transaction data model, datasource, repository, and use cases
- `TransactionBloc` for loading, adding, updating, deleting, and reloading
- `KeypadCubit` for calculator keypad state
- `PeriodCubit` registered for period state support
- `get_it` dependency injection
- Local custom category storage
- Budget storage
- Widget and bloc tests for core transaction behavior

### Phase 3 — Auth and Cloud Sync

- Firebase Auth (email/password + Google Sign-In)
- Auth BLoC/state flow
- Auth-aware drawer header with Google profile photo
- Firestore transaction sync (local → cloud on every write)
- First-login upload of local Drift transactions to Firestore
- **Restore from cloud on fresh install**: on sign-in with empty local DB,
  all Firestore transactions are pulled down and saved to Drift
- Local-only mode for unauthenticated users
- Sync status displayed in the left drawer

### Extra Features

- Persistent dark mode via `ThemeCubit` and `SharedPreferences`
- Russian/English language switching via `LocaleCubit` and `SharedPreferences`
- `flutter_localizations` and generated app localization classes
- Currency display selector (₽, $, €) via `CurrencyCubit` + `SharedPreferences`
- PDF export (header, period label, income/expense summary, category breakdown table,
  transaction list grouped by category)
- CSV export
- Budget limits (total + per-category)
- Budget warning banner on home screen (tappable → navigates to budget page)
- Budget progress indicator (orange at 80%, red at 100%)
- Pulsing animation on donut segment of over-budget category
- Budget page with total and per-category limits
- Custom categories with orbit slot swapping
- Categories page
- Custom category picker support
- Export bottom sheet
- Right drawer settings/actions
- Spending Insights screen with 4 auto-generated insight cards + bar chart
- Onboarding flow (3 screens, shown only on first launch, persisted via SharedPreferences)
- Branded app icon and splash screen (violet #7C3AED)

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
- `flutter_launcher_icons` (dev)
- `flutter_native_splash` (dev)

Do not introduce a new state management or persistence stack unless explicitly
requested. The app direction is BLoC + Drift/SQLite + Firebase sync.

---

## Architecture

The app follows a clean-architecture-flavored structure:

- `presentation` triggers events and renders state
- `domain` defines entities, repositories, and use cases
- `data` implements repositories, datasources, models, and persistence details
- Repositories return `Either<Failure, T>` instead of throwing for expected failures
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
- `lib/core/currency/currency_cubit.dart`
- `lib/core/utils/date_utils.dart`
- `lib/features/transactions/presentation/bloc/transaction_bloc.dart`
- `lib/features/transactions/data/datasources/transaction_local_datasource.dart`
- `lib/features/transactions/data/datasources/transaction_remote_datasource.dart`
- `lib/features/transactions/data/repositories/transaction_repository_impl.dart`
- `lib/features/auth/presentation/bloc/auth_bloc.dart`
- `lib/features/auth/data/datasources/firebase_auth_datasource.dart`
- `lib/features/insights/presentation/bloc/insights_cubit.dart`
- `lib/features/insights/presentation/pages/insights_page.dart`

---

## Routing

Routes are defined in `lib/main.dart`.

- `/onboarding` -> onboarding flow (first launch only)
- `/` -> home
- `/add` -> add transaction
- `/edit/:transactionId` -> edit transaction
- `/transactions/:categoryKey` -> category transaction list
- `/all-transactions` -> all transactions with filter chips
- `/budget` -> budget page
- `/categories` -> categories page
- `/insights` -> spending insights screen
- `/login` -> login
- `/register` -> registration

At app startup:

- Dependency injection is initialized
- `ThemeCubit` loads persisted dark/light preference
- `LocaleCubit` loads persisted Russian/English preference
- `CurrencyCubit` loads persisted currency symbol preference
- `Intl.defaultLocale` is kept in sync with the selected app locale
- `TransactionBloc` loads the current period
- Onboarding check: if `onboarding_complete` is false → `/onboarding`, else `/`
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
- Period swiping uses `PageView` with a large virtual page count (e.g. 10000)
  centered at the middle. The two action buttons (income/expense) are OUTSIDE
  the PageView and must never move during swipes.
- `_chartCenter = Offset(369, 686)` — do NOT change
- `_donutOuterRadius = 205` — do NOT change
- Colors via `isDark` boolean on home screen, NOT `Theme.of(context)`
- Standard screens rely on `AppTheme` and `AppColors`

Before changing category rendering, verify whether the change affects:
orbit layout, donut slices, connector lines, list filtering, category picker
behavior, budget warning labels, custom category mapping.

---

## Insights Screen

- Located at `lib/features/insights/presentation/pages/insights_page.dart`
- Accessible from right drawer (lightbulb icon)
- `InsightsCubit` calculates all insights locally from Drift data — no network calls
- Depends on `TransactionRepository` and `BudgetRepository`
- 4 insight cards:
  1. Largest expense category this period
  2. Spending vs previous period (% change)
  3. Most expensive day of the week
  4. Budget status (on track / exceeded)
- Bar chart below cards: daily spending (or monthly for year/all-time periods)
  - Highest bar highlighted in red #EF4444
  - Gradient fill, rounded tops, no border frame
  - Chart title changes dynamically based on grouping
- Two empty states: no transactions ever / no transactions this period
- Loading state: CircularProgressIndicator

---

## Data and Domain Notes

### Transactions

- `TransactionType` supports `expense` and `income`
- Income transactions can have `categoryKey == null`
- Transactions are identified by string `id`
- Mutations reload the active period after success
- Transaction state is exposed through `TransactionBloc`
- Delete shows undo SnackBar (4s, grey background, re-adds via AddTransactionEvent)

### Periods

Supported periods: `day`, `week`, `month`, `year`, `all`, `interval`

Date-range logic lives in `lib/core/utils/date_utils.dart`. The home screen uses
PageView-based swiping; page changes update `_referenceDate` and dispatch
`LoadTransactionsEvent`. 12-month back limit is enforced.

### Categories

- Built-in category metadata lives in `MockData` — do not remove
- Custom categories are persisted locally in Drift `CustomCategories` table
- Category labels go through `CategoryLocalizer` / `AppLocalizations`
- Orbit slot swapping persisted in `OrbitSlots` table
- `iconIndex` used instead of dynamic `IconData` for tree-shaking safety

### Budgets

- Total and per-category monthly limits stored in Drift `Budgets` table
- Warning banner on home screen is tappable → navigates to `/budget`
- Donut segment of over-budget category has pulsing opacity animation
- Progress indicator: orange at 80%, red at 100%

### Currency

- `CurrencyCubit` holds selected symbol: ₽, $, €
- Persists via `SharedPreferences`
- `currency_formatter.dart` reads from `CurrencyCubit`
- Selector in right drawer

### Auth and Sync

- Unauthenticated users: full local-only mode
- Authenticated users: every write syncs to Firestore as background microtask
- First login: local Drift transactions uploaded to Firestore
- Fresh install + sign-in: Firestore transactions restored to local Drift
  (triggered when local DB is empty after sign-in)
- Drawer sync status reflects auth/sync state

---

## Localization Rules

- App supports Russian and English via `flutter_localizations`
- Never hardcode user-facing strings in widget code
- Always use `AppLocalizations` for user-facing strings
- Category names use `CategoryLocalizer`
- Language preference persists via `SharedPreferences` in `LocaleCubit`
- `LocaleCubit` updates `Intl.defaultLocale`
- ARB files: `lib/l10n/app_en.arb` and `lib/l10n/app_ru.arb`
- Generated localization classes are checked in

---

## Theme Rules

- Dark mode persists via `SharedPreferences` in `ThemeCubit`
- Standard screens use `AppTheme` and `AppColors`
- Home screen has intentionally distinct custom visual system using `isDark` boolean
- Do not silently force home screen to match generic app theme styling

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

---

## Working Rules For Future Sessions

1. The app is **feature-complete**. Do not add new features without explicit request.
2. Do not reintroduce phase prompts or "not started" language.
3. Do not revert the home screen to any old spec.
4. Home screen `FittedBox` canvas (`738 x 1600`) is fragile — do not normalize it.
5. The two action buttons (income/expense) must always remain OUTSIDE the PageView.
6. Never hardcode user-facing strings; always use `AppLocalizations`.
7. Preserve Russian/English localization and persisted language switching.
8. Preserve persisted dark mode and currency symbol behavior.
9. Keep transaction persistence offline-first.
10. Keep repository APIs returning `Either<Failure, T>`.
11. Do not throw from repositories for expected data-layer failures.
12. Avoid large architecture rewrites for focused fixes.
13. Prefer preserving route names and existing navigation contracts.
14. Before changing category rendering, verify orbit, donut, connectors, lists,
    picker, and budget behavior.
15. Run `flutter analyze` and `flutter test` after every non-trivial change.
16. Never revert user changes unless explicitly requested.
17. `CurrencyCubit` must be used for all currency symbol display — never hardcode ₽.
18. InsightsCubit must never make network calls — local Drift data only.

---

## Known Gaps / Post-Thesis Roadmap

- Recurring transactions: UI placeholder exists, logic not built
- Multi-account support
- Budget export
- Fix dynamic `IconData` to remove `--no-tree-shake-icons` build flag
- Pets and gifts missing from default orbit (8/10 slots shown)
- `PeriodCubit` registered but home screen drives period via local `_referenceDate`
- Home screen colors use `isDark` boolean, not theme system

---

## Thesis Framing

When asked for thesis-oriented explanations, structure as:
1. What was implemented
2. Why it was chosen over alternatives
3. Trade-offs
4. How it supports the project goals

| Topic | Thesis angle |
|---|---|
| Clean Architecture | SOLID, testability, layer isolation |
| Drift/SQLite over Isar | SQL-backed portability, type-safe queries, release-build stability |
| BLoC over setState | Predictable state machine, testability, explicit event log |
| Offline-first | Resilience, UX continuity, local-first data ownership |
| Repository pattern | Datasource abstraction, domain independence |
| Flutter cross-platform | Single codebase vs native trade-offs |
| Firebase Auth + Firestore | Managed BaaS vs self-hosted: cost, scalability, lock-in |
| Localization | RU/EN internationalization, ARB-based string management |
| Persistent settings | User preference continuity via SharedPreferences |
| FittedBox canvas | Fixed-reference visual fidelity vs responsive flexibility |
| PageView period swiping | Native-feeling carousel navigation vs AnimatedSwitcher |
| CurrencyCubit | Lightweight display preference layer without conversion complexity |
| InsightsCubit | Local analytics engine — domain logic in pure Dart, zero network |
| Onboarding | First-run UX, SharedPreferences persistence, go_router integration |
