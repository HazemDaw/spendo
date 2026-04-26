# Spendo — Personal Finance Tracker

## About

Spendo is a cross-platform Flutter mobile application for tracking personal income and expenses. The project was built as a graduation project at Amur State University.

Thesis title:

- English: Development of a cross-platform mobile application for personal finance tracking
- Russian: Разработка кроссплатформенного мобильного приложения для учета личных финансов

## Features

- Donut chart with category orbit (Monefy-inspired)
- Offline-first architecture (works without internet)
- Add/edit/delete income and expenses
- Custom categories with orbit slot management
- Budget limits with visual warnings (80% and 100%)
- 6 period types: Day, Week, Month, Year, All time, Custom interval
- Swipe navigation between periods with animation
- Dark mode (persists across restarts)
- Russian/English language switching (persists)
- Export to PDF and CSV
- Firebase Authentication (email/password + Google Sign-In)
- Cloud sync via Firestore (offline-first, syncs when authenticated)
- Search transactions by note or category
- Budget management per category and total monthly budget
- Custom category management

## Architecture

Spendo uses Clean Architecture with 3 layers:

- Presentation: Flutter widgets + BLoC
- Domain: entities, use cases, repository interfaces
- Data: Isar local DB, Firestore remote

```text
UI -> BLoC -> Use Cases -> Repository -> Isar (local) / Firestore (remote)
```

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform mobile UI framework |
| flutter_bloc | State management with BLoC/Cubit |
| Isar | Local offline-first database |
| Firebase Auth | Email/password and Google authentication |
| Cloud Firestore | Remote cloud sync |
| go_router | Declarative navigation and routing |
| get_it | Dependency injection |
| fl_chart | Donut chart visualization |
| google_fonts | Custom typography |
| intl | Date, number, and locale formatting |
| dartz | Functional result types (`Either`) |
| equatable | Value equality for states and events |
| shared_preferences | Persisted settings for theme and locale |
| pdf | PDF report generation |
| csv | CSV export generation |
| share_plus | Sharing exported files |

## Screenshots

[Add screenshots here]

## Setup & Installation

### Prerequisites

- Flutter SDK >= 3.19.0
- Android Studio or VS Code
- Firebase project (see Firebase Setup)

### Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com).
2. Enable Authentication (Email/Password + Google).
3. Enable Cloud Firestore.
4. Run:

```bash
flutterfire configure --project=YOUR_PROJECT_ID
```

5. This generates `lib/firebase_options.dart`.

### Run the project

```bash
git clone https://github.com/[YOUR_GITHUB_USERNAME]/spendo.git
cd spendo
flutter pub get
flutter run
```

## Project Structure

```text
lib/
├── core/           # Theme, utils, error handling, localization
├── features/
│   ├── transactions/   # Main feature: CRUD, BLoC, Isar, Firestore
│   ├── categories/     # Built-in + custom categories, orbit slots
│   ├── budget/         # Budget limits and warnings
│   └── auth/           # Firebase authentication
└── main.dart
```

## Academic Context

- University: Amur State University (ФГБОУ ВО АмГУ)
- Faculty: Mathematics and Informatics
- Direction: 09.03.02 Information Systems and Technologies
- Academic supervisor: С.Г. Самохвалова

---

# Spendo — Приложение для учёта личных расходов

## О проекте

Spendo — это кроссплатформенное мобильное приложение на Flutter для учёта личных доходов и расходов. Проект разработан как выпускная квалификационная работа в Амурском государственном университете.

Тема выпускной квалификационной работы:

- На английском: Development of a cross-platform mobile application for personal finance tracking
- На русском: Разработка кроссплатформенного мобильного приложения для учета личных финансов

## Возможности

- Donut chart с орбитой категорий (вдохновлено Monefy)
- Offline-first архитектура (работает без интернета)
- Добавление, редактирование и удаление доходов и расходов
- Пользовательские категории с управлением слотами орбиты
- Бюджетные лимиты с визуальными предупреждениями (80% и 100%)
- 6 типов периодов: День, Неделя, Месяц, Год, Всё время, Пользовательский интервал
- Навигация свайпом между периодами с анимацией
- Тёмная тема (сохраняется после перезапуска)
- Переключение языка Русский/English (сохраняется)
- Экспорт в PDF и CSV
- Firebase Authentication (email/password + Google Sign-In)
- Облачная синхронизация через Firestore (offline-first, синхронизация при авторизации)
- Поиск транзакций по заметке или категории
- Управление бюджетом по категориям и общим месячным бюджетом
- Управление пользовательскими категориями

## Архитектура

Spendo использует Clean Architecture с 3 слоями:

- Presentation: Flutter widgets + BLoC
- Domain: entities, use cases, repository interfaces
- Data: Isar local DB, Firestore remote

```text
UI -> BLoC -> Use Cases -> Repository -> Isar (local) / Firestore (remote)
```

## Технологический стек

| Технология | Назначение |
|---|---|
| Flutter | Кроссплатформенный UI framework для мобильной разработки |
| flutter_bloc | Управление состоянием через BLoC/Cubit |
| Isar | Локальная offline-first база данных |
| Firebase Auth | Авторизация через email/password и Google |
| Cloud Firestore | Удалённая облачная синхронизация |
| go_router | Декларативная навигация и маршрутизация |
| get_it | Dependency injection |
| fl_chart | Визуализация donut chart |
| google_fonts | Пользовательская типографика |
| intl | Форматирование дат, чисел и локалей |
| dartz | Функциональные типы результата (`Either`) |
| equatable | Value equality для states и events |
| shared_preferences | Сохранение настроек темы и языка |
| pdf | Генерация PDF-отчётов |
| csv | Генерация CSV-экспорта |
| share_plus | Отправка экспортированных файлов |

## Скриншоты

[Добавьте скриншоты здесь]

## Настройка и установка

### Требования

- Flutter SDK >= 3.19.0
- Android Studio или VS Code
- Firebase project (см. раздел Firebase Setup)

### Firebase Setup

1. Создайте Firebase project на [console.firebase.google.com](https://console.firebase.google.com).
2. Включите Authentication (Email/Password + Google).
3. Включите Cloud Firestore.
4. Выполните команду:

```bash
flutterfire configure --project=YOUR_PROJECT_ID
```

5. Команда создаст файл `lib/firebase_options.dart`.

### Запуск проекта

```bash
git clone https://github.com/[YOUR_GITHUB_USERNAME]/spendo.git
cd spendo
flutter pub get
flutter run
```

## Структура проекта

```text
lib/
├── core/           # Theme, utils, error handling, localization
├── features/
│   ├── transactions/   # Main feature: CRUD, BLoC, Isar, Firestore
│   ├── categories/     # Built-in + custom categories, orbit slots
│   ├── budget/         # Budget limits and warnings
│   └── auth/           # Firebase authentication
└── main.dart
```

## Академический контекст

- Университет: Амурский государственный университет (ФГБОУ ВО АмГУ)
- Факультет: Математики и информатики
- Направление: 09.03.02 Информационные системы и технологии
- Научный руководитель: С.Г. Самохвалова
