# CLAUDE.md - Spendo

This file is the working guide for future Claude/Codex sessions in this repo.

If this document and the code disagree, the code is the source of truth. Update
this file when architectural decisions, product direction, or implementation
status changes.

## Project Snapshot

- App: `Spendo`
- Type: Flutter mobile app for personal expense tracking
- Context: graduation project / thesis work
- Platforms: Android and iOS
- Current state: offline-first transaction flow is implemented locally with Isar
  and BLoC; auth and cloud sync are not implemented yet

## Current Progression

### Phase 1 - UI foundation

Completed. The core screens and custom Monefy-inspired visual direction are in
place.

### Phase 2 - local state and persistence

Implemented in the current codebase:

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

- Phase 2 is not just planned anymore; it exists in code
- `PeriodCubit` is registered in DI but is not the current driver of the home
  screen UI
- the home screen still uses local widget state to cycle period and dispatches
  `LoadTransactionsEvent` directly

### Phase 3 - auth and sync

Not implemented yet.

Current status:

- `/login` and `/register` routes exist
- login/register pages are placeholders only
- remote datasource file exists as a placeholder
- no Firebase packages are present in `pubspec.yaml`

## Tech Stack In Use

- Flutter
- `flutter_bloc`
- `equatable`
- `dartz`
- `go_router`
- `get_it`
- `isar`
- `isar_flutter_libs`
- `path_provider`
- `intl`
- `google_fonts`
- `fl_chart`

Do not introduce a new state management or persistence stack unless explicitly
requested. The current direction is BLoC + Isar.

## Architecture

The intended architecture is still clean-architecture-flavored:

- `presentation` triggers events and renders state
- `domain` defines entities, repositories, and use cases
- `data` implements repositories and datasources
- repositories return `Either<Failure, T>` instead of throwing upward

Current transaction flow:

`UI -> TransactionBloc -> UseCases -> TransactionRepository -> TransactionLocalDatasource -> Isar`

Main files:

- `lib/main.dart`
- `lib/injection_container.dart`
- `lib/features/transactions/presentation/bloc/transaction_bloc.dart`
- `lib/features/transactions/data/datasources/transaction_local_datasource.dart`
- `lib/features/transactions/data/repositories/transaction_repository_impl.dart`
- `lib/features/transactions/data/models/transaction_model.dart`

## Current Routing

Defined in `lib/main.dart`:

- `/` -> home
- `/add` -> add transaction
- `/edit/:transactionId` -> edit transaction
- `/transactions/:categoryKey` -> category transaction list
- `/login` -> placeholder
- `/register` -> placeholder

At app startup:

- `Intl.defaultLocale = 'ru_RU'`
- DI is initialized
- `TransactionBloc` is created at app level
- the app immediately dispatches `LoadTransactionsEvent(TransactionPeriod.month)`

## UI Direction That Must Be Preserved

The old CLAUDE spec described a purple layout with chip-based filtering. That is
no longer the real app state.

The current home screen is a custom fixed-reference composition and should be
treated as visually locked unless the user explicitly asks for redesign work.

Preserve these characteristics:

- `home_page.dart` uses a reference canvas of `738 x 1600`
- the screen is scaled via `FittedBox`
- the layout is heavily position-based, not standard responsive column layout
- the home screen uses a mint/green Monefy-like palette
- the home screen intentionally overrides the general app theme colors
- orbit icons and connectors are custom positioned around the donut chart

Do not "normalize" the home screen into generic Material widgets or force it to
match the shared `AppTheme` unless asked.

Also note:

- standard screens still rely on `AppTheme` and the purple token set in
  `lib/core/theme`
- the home screen and the shared theme currently have different visual systems
- that mismatch is real in the codebase; do not silently "fix" it during
  unrelated tasks

## Data and Domain Notes

### Transaction entity

- `TransactionType` supports `expense` and `income`
- income can have `categoryKey == null`
- transactions are identified by string `id`

### Period handling

- supported periods: `day`, `week`, `month`
- date-range logic lives in `lib/core/utils/date_utils.dart`
- the home screen cycles period locally and reloads the bloc state

### Category metadata

`MockData` is still used for category definitions such as:

- category keys
- icons
- colors
- label keys

This is still valid. Do not remove `MockData` blindly just because transaction
storage moved to Isar.

Important limitation in the current home screen:

- the app defines 10 categories in `MockData`
- the orbit around the donut currently maps only 8 categories
- `pets` and `gifts` exist in metadata but are not part of the home orbit layout

Do not assume all categories are rendered on the home orbit without checking the
implementation first.

## State Management Notes

### Implemented

- `TransactionBloc`
- `KeypadCubit`
- `TransactionState`: initial, loading, loaded, error
- mutation events reload the current period after success

### Partially adopted

- `PeriodCubit` exists, is registered in DI, but is not the current source of
  truth for home screen period changes

If you need to improve period state later, refactor carefully. Do not claim the
current UI already uses `PeriodCubit`.

## Localization Rules

- code, identifiers, and comments stay in English
- app locale is Russian-oriented
- localization is generated from `lib/l10n/*.arb`
- prefer l10n strings for user-facing text on standard screens

Current reality:

- several newer screens already use generated localizations
- the home screen still contains hardcoded English labels and some custom text
- preserve behavior unless the task is specifically about localization cleanup

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

## Working Rules For Future Sessions

1. Do not revert the home screen to the old purple spec from previous versions
   of this file.
2. Treat the current custom home layout as deliberate and fragile.
3. Keep transaction persistence offline-first unless the task is explicitly about
   Phase 3.
4. Keep repository APIs returning `Either<Failure, T>`.
5. Do not throw from repositories for expected data-layer failures.
6. Avoid large architecture rewrites when the user asked for a focused feature or
   bug fix.
7. Prefer preserving route names and existing navigation contracts.
8. Before changing category rendering, verify whether the change affects orbit
   layout, donut slices, list filtering, and category picker behavior.

## Known Gaps / Pending Work

- Firebase auth is not wired
- Firestore sync is not started
- login/register remain placeholder pages
- drawers on the home screen are still stubs
- shared theme and home screen design system are inconsistent
- some mock-era artifacts remain in the repo and should be evaluated before
  removal
- README is still the default Flutter scaffold and does not reflect the project

## Suggested Next Major Milestones

If work continues from the current state, the next sensible areas are:

1. finish Phase 3 auth and sync
2. decide whether to unify or intentionally preserve the split visual systems
3. replace remaining UI stubs such as drawers and auth placeholders
4. tighten localization coverage on the home screen
5. expand tests around persistence, routing, and category-specific flows

## Thesis Framing

If asked for thesis-oriented explanations, frame decisions like this:

1. what was implemented
2. why it was chosen over nearby alternatives
3. trade-offs
4. how it supports the project goals

Useful thesis angles in this repo:

- offline-first storage with Isar
- BLoC for explicit state transitions
- repository abstraction for domain isolation
- Flutter for cross-platform delivery
- incremental phase-based delivery from UI shell to local persistence to sync
