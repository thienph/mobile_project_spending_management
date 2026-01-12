# Quản lý Thu Chi - Ứng dụng Mobile

Ứng dụng quản lý thu chi cá nhân được xây dựng bằng Flutter, hỗ trợ người dùng theo dõi giao dịch tài chính và phân tích chi tiêu một cách trực quan.

> **Phiên bản**: MVP1

## Mô tả ứng dụng

 [Xem mô tả chi tiết tại PRODUCT.md](./docs/PRODUCT.md)

## Kiến trúc

### Kiến trúc 4 Layers

```
lib/
├── core/                       # Utilities và configuration
│   ├── constants/             # Constants, enums
│   ├── di/                    # Dependency injection
│   ├── errors/                # Error handling
│   ├── navigation/            # Navigation
│   ├── theme/                 # Theme & styling
│   └── utils/                 # Extensions & helpers
│
├── data/                      # Data layer
│   ├── datasources/          
│   │   └── local/            # Drift/SQLite database
│   ├── models/               # Data models
│   └── repositories/         # Repository implementations
│
├── domain/                    # Business logic
│   ├── entities/             # Business entities
│   ├── repositories/         # Repository interfaces
│   └── usecases/             # Use cases
│       ├── transactions/
│       ├── analytics/
│       ├── goals/
│       └── alerts/
│
└── presentation/             # UI layer
    ├── bloc/                 # State management
    │   ├── transactions/
    │   ├── analytics/
    │   ├── goals/
    │   └── alerts/
    ├── screens/              # Screens
    │   ├── home/
    │   ├── transactions/
    │   ├── analytics/
    │   ├── goals/
    │   └── alerts/
    └── widgets/              # Reusable widgets
        └── common/
```

### Database Schema

Bảng dữ liệu (Drift):
- categories - Danh mục thu/chi
- transactions - Giao dịch
- recurring_transactions - Giao dịch định kỳ
- saving_goals - Mục tiêu tiết kiệm
- budgets - Ngân sách

## Tech Stack

### Core Technologies
- **Framework**: Flutter 3.10.4+ (Cross-platform mobile development)
- **Language**: Dart 3.10.4+
- **Architecture**: 4 layers (core, data, domain, presentation)

### State Management & Navigation
- **State**: flutter_bloc 8.1+ with Equatable
- **Navigation**: go_router 14.6+ (declarative routing)
- **DI**: get_it 8.0+ (service locator pattern)

### Data & Persistence
- **Database**: Drift 2.20+ (type-safe SQLite wrapper)
- **Storage**: SQLite3 (offline-first architecture)
- **Error Handling**: dartz (functional Either<Failure, Success>)

### UI & Visualization
- **Design**: Material Design 3
- **Charts**: fl_chart 0.69+ (pie charts, line charts)
- **Date/Number**: intl 0.20+ (localization)

### Quality & Monitoring
- **Testing**: bloc_test 9.1+, mocktail 1.0+
- **Crashlytics**: firebase_crashlytics 4.1+ (error tracking)
- **Linting**: flutter_lints 6.0+

### Planned Features
- **Notifications**: flutter_local_notifications 18.0+ (local alerts)
- **UUID**: uuid 4.5+ (unique identifiers)

## Cài đặt

### Yêu cầu
- Flutter SDK 3.10.4+
- Dart SDK 3.10.4+
- Android Studio / VS Code
- iOS: Xcode 14+ (tùy chọn)

### Các bước cài đặt

1. Clone repository
```bash
git clone <repository-url>
cd mobile_project_spending_management
```

2. Cài đặt dependencies
```bash
flutter pub get
```

3. Generate database code
```bash
dart run build_runner build --delete-conflicting-outputs
```

4. Chạy ứng dụng
```bash
flutter run
```

## Nền tảng hỗ trợ

- Android: API 21+ (Android 5.0+)
- iOS: iOS 12.0+

## Testing

```bash
# Chạy tất cả tests
flutter test

# Chạy test cụ thể
flutter test test/domain/usecases/transactions/add_transaction_test.dart

# Coverage
flutter test --coverage
```

## Build

```bash
# Generate code (khi thay đổi database)
dart run build_runner build --delete-conflicting-outputs

# Clean build (khi gặp lỗi build)
flutter clean && flutter pub get

# Build Android APK
flutter build apk --release

# Build Android App Bundle (Google Play)
flutter build appbundle --release

# Build iOS (yêu cầu macOS + Xcode)
flutter build ios --release
```
