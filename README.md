# Quản lý Thu Chi - Ứng dụng Mobile

Ứng dụng quản lý thu chi cá nhân, phân tích tài chính, đặt mục tiêu tiết kiệm và cảnh báo chi tiêu được xây dựng bằng Flutter.

## Tính năng chính

### Đã triển khai
- Kiến trúc Clean Architecture với BLoC pattern
- Database Schema với Drift/SQLite
- Dependency Injection với GetIt
- Navigation System với GoRouter
- Theme System với Material Design 3
- Core Utilities: Date/Number/String extensions

### Đang phát triển
- Theo dõi thu chi: Ghi nhận, chỉnh sửa, xóa giao dịch thu/chi
- Phân tích tài chính: Biểu đồ, thống kê, báo cáo theo ngày/tuần/tháng/năm
- Mục tiêu tiết kiệm: Đặt và theo dõi tiến độ các mục tiêu tài chính
- Cảnh báo chi tiêu: Thông báo khi vượt ngân sách hoặc đạt mục tiêu

## Kiến trúc

### Clean Architecture Layers

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

- **Framework**: Flutter 3.10+
- **Language**: Dart 3.10+
- **State Management**: flutter_bloc 8.1+
- **Database**: Drift 2.20+
- **Navigation**: go_router 14.6+
- **DI**: get_it 8.0+
- **Charts**: fl_chart 0.69+
- **Notifications**: flutter_local_notifications 18.0+
- **Firebase**: firebase_core, firebase_crashlytics
- **Testing**: bloc_test, mocktail

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

# Build APK (Android)
flutter build apk --release

# Build iOS
flutter build ios --release
```
