# Spendo

Cross-platform Flutter mobile app for personal finance tracking, built as a full graduation thesis project.

![Flutter 3.19+](https://img.shields.io/badge/Flutter-3.19%2B-02569B?logo=flutter&logoColor=white)
![Platform Android | iOS](https://img.shields.io/badge/platform-Android%20%7C%20iOS-3DDC84)
![License: MIT](https://img.shields.io/badge/license-MIT-green)
![Offline-first](https://img.shields.io/badge/offline--first-enabled-2F855A)

## Screenshots

<!-- Add screenshots here -->

Home screen · Insights · Budget

## Overview

Spendo helps users track income, expenses, budgets, and spending patterns from a mobile-first interface. It was built as a full graduation thesis project, not a throwaway demo, with production-style architecture and persistent local storage. The app is designed for offline-first personal finance tracking with optional Firebase authentication, cloud sync, and restore. It ships as a working Android APK.

## Features

**Core**

- Track income and expenses with add, edit, delete, and undo flows.
- Switch between day, week, month, year, all-time, and custom intervals.
- Use a Monefy-inspired home screen with category orbit icons and a donut chart.

**Analytics & Insights**

- Review spending insights for largest category, period comparison, expensive days, and budget status.
- View spending trends with chart visualizations.

**Budget & Categories**

- Set budget limits with progress indicators and warning states.
- Manage custom categories with local and cloud persistence.

**Data & Sync**

- Store data offline with Drift/SQLite as the primary local database.
- Sync and restore data with Firebase Auth and Cloud Firestore when configured.
- Export reports to PDF and CSV.
- Scan receipts with OCR, editable draft items, and confirmation before saving.

**Personalization**

- Use dark mode, English/Russian localization, and currency display settings.

## Architecture

Spendo follows Clean Architecture with Presentation, Domain, and Data layers.
BLoC/Cubit models UI state as predictable, testable state machines.
Drift/SQLite provides SQL-backed, type-safe persistence and release-build stability; it replaced Isar after an unfixable Android release build issue.
The local database is the source of truth; Firestore is used only for authenticated sync and restore.
Repositories return `Either<Failure, T>` for expected failures instead of throwing.

```text
UI → BLoC → Use Cases → Repository → Drift/SQLite / Firestore
```

## Tech Stack

| Technology | Purpose |
| --- | --- |
| Flutter | Cross-platform mobile UI |
| flutter_bloc | State management |
| Drift / SQLite | Offline local database |
| Firebase Auth | Email/password and Google authentication |
| Cloud Firestore | Optional cloud sync and restore |
| go_router | Navigation |
| get_it | Dependency injection |
| fl_chart | Charts and visualizations |
| shared_preferences | Persisted app settings |
| pdf / csv / share_plus | Export and sharing |
| tesseract_ocr / Google ML Kit | Receipt OCR |

## Getting Started

### Prerequisites

- Flutter SDK 3.19.0 or newer
- Android Studio or VS Code
- A Firebase project if you want authentication and cloud sync

### Install Dependencies

```bash
flutter pub get
```

### Configure Firebase

1. Create a Firebase project.
2. Enable Authentication with Email/Password and Google Sign-In.
3. Enable Cloud Firestore.
4. Run FlutterFire configuration:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=YOUR_PROJECT_ID
```

This generates the local Firebase config files needed by the app, including
`lib/firebase_options.dart` and Android/iOS platform config files.

For Google Sign-In on Android, add your SHA-1 fingerprint in the Firebase
console.

### Run

```bash
flutter run
```

### Test

```bash
flutter test
```

### Build Release APK

```bash
flutter build apk --release --no-tree-shake-icons
```

The `--no-tree-shake-icons` flag is currently required because category icons
use dynamic `IconData`.

## Project Structure

```text
lib/
  core/
    database/      Drift database
    services/      Export and receipt scanner services
    theme/         App theme and dark mode
    locale/        Localization state
    currency/      Currency settings
    utils/         Date, currency, and category helpers
  features/
    auth/          Firebase authentication
    budget/        Budget limits and warnings
    categories/    Built-in and custom categories
    insights/      Spending insights and charts
    onboarding/    First-run onboarding
    transactions/  Main transaction workflows
  l10n/            English and Russian localization files
```

## Known Limitations

- Recurring transactions have a UI placeholder but no completed logic yet.
- Multi-account support is not implemented.
- Budget data is shown in-app but does not have a dedicated export report.
- The release APK build currently needs `--no-tree-shake-icons`.

## Academic Context

Spendo was developed as a graduation thesis project at Amur State University (09.03.04 — Software Engineering). It is a fully functional Android application with a clean architecture, bilingual support (Russian/English), and a working Firebase integration. The public repository contains the complete application source code.
