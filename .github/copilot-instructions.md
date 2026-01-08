# AI Coding Agent Instructions

## Architecture Overview

This Flutter app uses **Clean Architecture** (4 layers) with **BLoC state management**:

```
lib/
  core/          # Shared utilities, theme, DI, navigation, error handling
  data/          # Database, datasources, models, repository implementations
  domain/        # Entities, repository interfaces, use cases
  presentation/  # UI (screens/widgets), BLoCs (state management)
```

**Critical Data Flow**: Domain (business logic) → Data (persistence) ← Presentation (UI)
- Entities (domain) are never modified; Models (data) handle serialization
- Repositories are interfaces in domain, implementations in data
- BLoCs in presentation contain no domain knowledge—only state transitions

## Tech Stack

- **Database**: Drift + SQLite (5 tables: categories, transactions, recurring_transactions, saving_goals, budgets)
- **State Management**: flutter_bloc + Equatable (events → states)
- **DI**: GetIt (lazy singletons, initialized in main via `setupDependencyInjection()`)
- **Navigation**: GoRouter with feature routes (initial: `/`)
- **Theming**: Material Design 3 (primary: #6C63FF, accent: #00D4AA)
- **Notifications**: flutter_local_notifications (local only)
- **Firebase**: firebase_core, firebase_crashlytics (pending: run `flutterfire configure`)

## Essential Developer Commands

```bash
# First-time setup
flutter pub get
flutter pub run build_runner build      # Generate Drift code & other builders

# Development workflow
flutter run                              # Compile & run on emulator/device
flutter clean && flutter pub get         # Hard reset (if builds fail)
dart fix --apply                         # Auto-fix linting issues

# Database migrations
# Edit lib/data/datasources/local/app_database.dart, increment schemaVersion, 
# implement onUpgrade, run: flutter pub run build_runner build

# Testing
flutter test                             # Run all unit/widget/BLoC tests
flutter test test/                       # Run specific test directory
```

## Code Patterns & Conventions

### BLoC Pattern (State Management)
Every feature has its own bloc directory with:
- `{feature}_event.dart`: Events extend Equatable (immutable)
- `{feature}_state.dart`: States extend Equatable (Loading/Loaded/Error)
- `{feature}_bloc.dart`: Extends Bloc, mapEventToState, initial state
 - Use `on<Event>()` handlers; emit `Loading/Loaded/Error` as appropriate.

### Repository Pattern (Data Layer)
Repositories are **interfaces in domain**, **implementations in data**:
- Define interfaces under `domain/repositories`, implement in `data/repositories`.
- Return `Either<Failure, T>`; map Data Models ↔ Domain Entities.
- Catch DB errors and convert to `DatabaseFailure` (see `core/errors/failures.dart`).

### Extensions (DX Helpers)
Use extensions in `lib/core/utils/` for cleaner code:
```dart
// Date: DateTime.now().startOfDay, .toDateString(), .isToday, etc.
// Number: 50000.toCurrency() → "50,000 ₫", .toCompactCurrency(), .toPercentage()
// String: "hello".capitalize(), .isNumeric, .toDoubleOrZero()
```

## Dependency Injection Pattern (GetIt)

- Register lazy singletons in `core/di/injection.dart` via `setupDependencyInjection()`.
- Typical chain: `AppDatabase` → Repository → UseCase → Bloc.
- Provide blocs via DI or `BlocProvider` at screen level.

## Database (Drift) Specifics

- **Definition**: `lib/data/datasources/local/app_database.dart` (single source of truth)
- **Tables**: categories, transactions, recurring_transactions, saving_goals, budgets
- **Default data**: 12 default categories inserted on app first run (via `onCreate`)
- **Queries**: Type-safe; example: `database.select(database.transactions).where(...).get()`
- **Migrations**: Increment `schemaVersion`, implement `onUpgrade`, rebuild with `flutter pub run build_runner build`

## Routing Pattern (GoRouter)

- Use `AppRouter.router` (initial: `/`) in `core/navigation/app_router.dart`.
- Prefer named routes per feature; handle errors with `errorBuilder`.
- Navigate with `context.goNamed('routeName', queryParameters: {...})`.

## Common Tasks for AI Agents

| Task | Steps |
|------|-------|
| **Add new feature** | 1) Create entity (domain/entities) 2) Create repository interface (domain/repositories) 3) Create use cases (domain/usecases/{feature}) 4) Create models (data/models) 5) Implement repository (data/repositories) 6) Create BLoC (presentation/bloc/{feature}) 7) Create screens (presentation/screens/{feature}) 8) Register in DI (injection.dart) 9) Add routes (app_router.dart) 10) Add BLoC provider to screen |
| **Add database field** | 1) Edit AppDatabase schema (app_database.dart) 2) Increment schemaVersion 3) Update onUpgrade with migration logic 4) Run `flutter pub run build_runner build` 5) Update models, entities, queries |
| **Add new transaction type** | Update AppConstants.frequencyDaily/Weekly/Monthly/Yearly, update BudgetPeriod enum, add UI for new type |
| **Fix build errors** | Run `flutter clean && flutter pub get`, check Android desugaring (isCoreLibraryDesugaringEnabled), verify SDK versions in gradle.properties |
| **Test feature** | Create test files in `test/` mirroring `lib/` structure, use `bloc_test` for BLoC tests, `mocktail` for mocks |

## Critical Files to Understand First

1. **[lib/main.dart](../lib/main.dart)** - App initialization, DI setup, Firebase init (commented)
2. **[lib/core/di/injection.dart](../lib/core/di/injection.dart)** - Service locator configuration (GetIt)
3. **[lib/core/navigation/app_router.dart](../lib/core/navigation/app_router.dart)** - Route definitions (GoRouter)
4. **[lib/data/datasources/local/app_database.dart](../lib/data/datasources/local/app_database.dart)** - Database schema (Drift)
5. **[lib/core/theme/app_theme.dart](../lib/core/theme/app_theme.dart)** - Material Design 3 theme
6. **[lib/core/utils/](../lib/core/utils/)** - Extensions: date_extensions, number_extensions, string_extensions
7. **[pubspec.yaml](../pubspec.yaml)** - Dependencies (versioned)
8. **[INSTRUCTION.md](../INSTRUCTION.md)** - Detailed dev workflow & code examples

## Error Handling

Use `Failure` class hierarchy from `lib/core/errors/failures.dart`:
- Return `Either<Failure, T>` from repositories
- Catch errors and convert to appropriate Failure type (DatabaseFailure, ValidationFailure, ServerFailure, etc.)
- BLoCs emit state with error message from Failure

## Testing Patterns

Use `bloc_test` for BLoC tests and `mocktail` for mocks:
```dart
blocTest<TransactionBloc, TransactionState>(
  'emits [Loading, Loaded]',
  build: () => TransactionBloc(...),
  act: (bloc) => bloc.add(LoadTransactions(...)),
  expect: () => [TransactionLoading(), TransactionLoaded(...)],
);
```
For unit tests: Create mocks, test methods, verify with `verify()`.
Run: `flutter test` or `flutter test --coverage`
See [INSTRUCTION.md](../INSTRUCTION.md) for detailed examples.

## Reference Documentation

**For detailed instructions, see:**
- [INSTRUCTION.md](../INSTRUCTION.md) - Full dev workflow, setup, code examples, troubleshooting
- [README.md](../README.md) - Vietnamese features, roadmap, installation

---

**Last Updated**: January 8, 2026 | **Phase**: Phase 1 Complete (Core Architecture & Setup), Phase 2 Pending (Transactions Feature)
