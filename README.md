# 📸 OCR Expense Tracker

An offline-first, on-device OCR Expense Tracking mobile app built with **Flutter 3.x**, **Dart 3**, **Riverpod 2.x**, **Google ML Kit**, **SQLite**, and **CustomPainter**.

Designed specifically for students and club treasurers to effortlessly capture receipt photos, parse amounts, dates, and store names with regex heuristics, and visualize spending breakdowns with zero external charting dependencies.

---

## ✨ Features

- 📷 **Real-Time Camera & Viewfinder Overlay**:
  - Live camera preview with animated receipt-ratio framing guides and corner markers.
  - Flashlight toggle & dynamic tap-to-focus indicator ring.
  - Receipt cropping (via `image_cropper` / `ucrop`) before sending to OCR engine.
- ⚡ **Offline On-Device OCR**:
  - Powered by `google_mlkit_text_recognition` (Latin script).
  - Fast, privacy-preserving on-device processing without sending data to third-party servers.
- 🔍 **Regex Heuristic Parser (`ReceiptParser`)**:
  - **Amount Extraction**: Handles VN (`150.000 đ`, `150000 VND`, `1.500.000,00`) and international (`150,000`, `1,500.00`) formats, taking priority on keyword markers (`TOTAL`, `TỔNG CỘNG`, `THÀNH TIỀN`).
  - **Date Extraction**: Supports `DD/MM/YYYY`, `DD-MM-YYYY`, and word-month formats (`15 Sep 2026`, `tháng 9`).
  - **Merchant Extraction**: Smart header scanning prioritizing uppercase lines while ignoring invoice/tax/receipt keywords.
  - Returns `ParsedReceipt { amount, date, merchantName, rawText, confidence }`.
- 📝 **Interactive Review & Verification**:
  - Inspect the cropped receipt image with pinch-to-zoom or toggle to raw OCR text.
  - Manual overrides for any field before committing to storage.
  - Automatic category guessing based on merchant and receipt keywords.
- 💾 **Local SQLite Storage (`sqflite`)**:
  - Transactions persisted locally with `id`, `amount`, `date`, `merchantName`, `category`, `imagePath`, and `createdAt`.
  - Receipt image thumbnails stored permanently in the application documents directory.
  - 5 Fixed categories: `Food 🍔`, `Study 📚`, `Travel ✈️`, `Gear 🔧`, `Entertainment 🎬`.
- 📊 **CustomPainter Visualizations (Zero Chart Libraries)**:
  - **Animated Donut / Pie Chart**: Category breakdown with smooth sweep arc animation and tap-to-inspect category tooltips.
  - **Animated Weekly Bar Chart**: 7-day spending columns with height rise animation, gridlines, and tap value indicators.
- 🧭 **Navigation & UX**:
  - Bottom navigation bar: **Dashboard**, **History**, **Settings** + Floating **Scan** action button.
  - Full-text search and category filter bar in History screen.

---

## 🏗️ Architecture & Project Structure

```
ocr_expense_tracker/
├── android/
│   └── app/src/main/AndroidManifest.xml       # Camera & ML Kit permissions & metadata
├── ios/
│   └── Runner/Info.plist                      # Camera & Photo Library usage descriptions
├── pubspec.yaml
└── lib/
    ├── main.dart                              # App entry point & ProviderScope
    ├── presentation/
    │   └── shell_screen.dart                  # BottomNavigationBar & FAB
    ├── core/
    │   ├── constants/
    │   │   ├── app_colors.dart                # Dark-mode color palette & category tokens
    │   │   ├── app_text_styles.dart           # Typography scale
    │   │   └── expense_categories.dart        # Category enum, emoji, icon & colors
    │   ├── router/
    │   │   └── app_router.dart                # GoRouter with StatefulShellRoute
    │   ├── theme/
    │   │   └── app_theme.dart                 # Material 3 Dark Theme
    │   └── utils/
    │       ├── currency_formatter.dart        # VND currency formatting
    │       └── date_formatter.dart            # Date and calendar utility functions
    ├── data/
    │   ├── models/
    │   │   ├── expense_transaction.dart       # SQLite entity
    │   │   └── parsed_receipt.dart            # OCR extraction result model
    │   └── repositories/
    │       ├── database_helper.dart           # SQLite singleton & migrations
    │       └── transaction_repository.dart    # CRUD & aggregation queries
    └── features/
        ├── camera/
        │   ├── presentation/
        │   │   ├── camera_screen.dart         # Viewfinder & crop flow
        │   │   └── widgets/
        │   │       ├── camera_controls.dart   # Flash & capture controls
        │   │       └── camera_overlay.dart    # CustomPainter crop framing
        │   └── providers/
        │       └── camera_provider.dart       # Riverpod camera lifecycle notifier
        ├── ocr/
        │   ├── receipt_parser.dart            # Heuristic Regex Parser
        │   └── ocr_service.dart               # Google ML Kit wrapper
        ├── review/
        │   ├── presentation/
        │   │   ├── review_screen.dart         # Verification screen
        │   │   └── widgets/
        │   │       ├── editable_field_card.dart
        │   │       └── receipt_image_viewer.dart
        │   └── providers/
        │       └── review_provider.dart       # OCR review state notifier
        ├── dashboard/
        │   ├── presentation/
        │   │   ├── dashboard_screen.dart      # Main dashboard
        │   │   └── widgets/
        │   │       ├── bar_chart.dart         # CustomPainter Bar Chart
        │   │       ├── donut_chart.dart       # CustomPainter Donut Chart
        │   │       └── summary_card.dart      # Spending summary
        │   └── providers/
        │       └── dashboard_provider.dart    # Dashboard statistics provider
        ├── history/
        │   ├── presentation/
        │   │   ├── history_screen.dart        # Filterable transaction list
        │   │   └── widgets/
        │   │       ├── filter_bar.dart        # Chips & search bar
        │   │       └── transaction_card.dart  # Receipt card widget
        │   └── providers/
        │       └── history_provider.dart      # History state & filtering notifier
        └── settings/
            └── presentation/
                └── settings_screen.dart       # App & ML Kit specifications
```

---

## 📦 Packages & Dependencies (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Routing & Navigation
  go_router: ^14.2.7

  # Camera, Gallery & Image Cropping
  camera: ^0.11.0+2
  image_picker: ^1.1.2
  image_cropper: ^8.0.2
  image: ^4.2.0

  # On-Device ML Kit OCR
  google_mlkit_text_recognition: ^0.14.0

  # Local SQLite Database & Storage
  sqflite: ^2.3.3+1
  path_provider: ^2.1.4
  path: ^1.9.0

  # Utilities
  uuid: ^4.4.2
  intl: ^0.19.0
  permission_handler: ^11.3.1
  cupertino_icons: ^1.0.8
```

---

## 🚀 Setup & Installation Guide

### Prerequisites
- Flutter SDK `>= 3.0.0`
- Android Studio / Xcode
- Physical device or Emulator with Camera/Camera Mocking support

### 1. Install Dependencies
```bash
cd ocr_expense_tracker
flutter pub get
```

### 2. Android Configuration
Ensure `android/app/build.gradle` has `minSdkVersion` set to at least **21**:
```groovy
android {
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

Google ML Kit OCR model dependencies are automatically declared in `AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.mlkit.vision.DEPENDENCIES"
    android:value="ocr" />
```

### 3. iOS Configuration
In `ios/Podfile`, ensure platform is set to iOS 15.5 or higher:
```ruby
platform :ios, '15.5'
```
Run CocoaPods installation:
```bash
cd ios
pod install
cd ..
```

### 4. Run the App
```bash
# Run on connected device
flutter run
```

---

## 🧪 Testing Regex Parsing (`ReceiptParser`)

You can test `ReceiptParser` heuristics against Vietnamese sample receipts:
```dart
final parser = ReceiptParser();
final result = parser.parse('''
HIGHLANDS COFFEE
254 Nguyen Van Linh, Da Nang
Date: 11/09/2026
1x Freeze Tra Xanh   55.000
1x Phin Sua Da       39.000
TONG TIEN:           94.000 VND
CASH:               100.000 VND
''');

print(result.merchantName); // Highlands Coffee
print(result.amount);       // 94000.0
print(result.date);         // 2026-09-11
print(result.confidence);   // 1.0
```
