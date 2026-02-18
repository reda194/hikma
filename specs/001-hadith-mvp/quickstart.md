# Quickstart Guide: Hikma Development

**Feature**: Hikma MVP - Hadith Reminder App for macOS
**Date**: 2026-02-18

---

## Overview

This guide helps you set up a development environment for Hikma and start contributing to the project.

---

## Prerequisites

### Required Software

| Tool | Version | Purpose |
|------|---------|---------|
| Flutter SDK | 3.19.0 or later | App framework |
| Dart SDK | 3.3.0 or later | Programming language |
| Xcode | 14.0 or later | macOS build tools |
| macOS | 11.0 (Big Sur) or later | Development platform |

### Verification

```bash
# Check Flutter installation
flutter --version
flutter doctor

# Enable macOS desktop
flutter config --enable-macos-desktop
flutter create --platforms=macos .
```

---

## Project Setup

### 1. Clone Repository

```bash
git clone <repository-url>
cd hikma
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Verify macOS Setup

```bash
flutter doctor -v
```

Expected output should show:
- ✓ Flutter SDK
- ✓ macOS toolchain - develop for macOS
- ✓ Xcode - develop for macOS
- ✓ Android Studio (optional, for VS Code users)

---

## Development Workflow

### Running the App

```bash
# Run on macOS
flutter run -d macos

# Run with hot reload enabled
flutter run -d macos --hot
```

### Hot Reload

While the app is running:
- Press `r` in the terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

---

## Project Structure

```
hikma/
├── lib/                    # Source code
│   ├── core/              # Constants, theme, utils
│   ├── data/              # Models, repositories, services
│   ├── bloc/              # BLoC state management
│   ├── ui/                # Screens, widgets
│   └── main.dart          # App entry point
├── assets/                 # Assets
│   ├── data/
│   │   └── hadiths.json   # Bundled Hadiths
│   ├── fonts/             # Arabic font
│   └── images/            # App icons
├── test/                   # Tests
├── specs/                  # Feature specifications
└── pubspec.yaml           # Dependencies
```

---

## Adding Hadiths to Bundled Collection

### 1. Edit the Hadiths JSON

Open `assets/data/hadiths.json`:

```json
{
  "metadata": {
    "version": "1.0",
    "count": 250,
    "lastUpdated": "2026-02-18"
  },
  "collections": [...],
  "hadiths": [
    {
      "id": "bukhari-1-1",
      "arabic": "حدثنا الحميدي عبد الله بن محمد...",
      "narrator": "عمر بن الخطاب",
      "sourceBook": "Sahih Al-Bukhari",
      "chapter": "كيف كان بدء الوحي",
      "bookNumber": 1,
      "hadithNumber": 1,
      "collection": "bukhari"
    }
  ]
}
```

### 2. Update pubspec.yaml

Ensure the asset is declared:

```yaml
flutter:
  assets:
    - assets/data/hadiths.json
```

### 3. Run flutter pub get

```bash
flutter pub get
```

---

## Testing Offline Mode

### Disable Network

To test offline functionality:

```bash
# Turn off WiFi or use macOS's Network Link Conditioner
# Then run the app
flutter run -d macos
```

Expected behavior:
- App should launch normally
- Hadiths should display from bundled JSON
- No error messages about connectivity

### Verify Hive Storage

```bash
# Hive stores data in:
~/Library/Application Support/com.example.hikma/
```

---

## Building for Release

### 1. Update Version

Edit `macos/Runner/Info.plist` and `pubspec.yaml`:

```xml
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
```

### 2. Build Release

```bash
flutter build macos --release
```

Output: `build/macos/Build/Products/Release/hikma.app`

### 3. Code Sign

```bash
codesign --force --deep --sign "Developer ID Application: Your Name" build/macos/Build/Products/Release/hikma.app
```

---

## Mac App Store Submission

### 1. Configure Entitlements

Edit `macos/Runner/DebugProfile.entitlements` and `Release.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
</dict>
</plist>
```

### 2. Create App Store Connect Listing

- App name: Hikma - Hadith Reminder
- Bundle ID: com.yourname.hikma
- Category: Education or Lifestyle
- Age rating: 4+

### 3. Upload via Transporter

```bash
# Create an archive
flutter build macos --release

# Upload via Transporter.app or xcrun
xcrun altool --upload-app --type osx --file build/macos/Build/Products/Release/hikma.app
```

---

## Common Issues

### Issue: "No suitable device found"

```bash
# Enable macOS platform
flutter config --enable-macos-desktop

# Create macOS runner if missing
flutter create --platforms=macos .
```

### Issue: "Hive not initialized"

Ensure Hive is initialized in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('favorites');
  await Hive.openBox('cache');
  runApp(HikmaApp());
}
```

### Issue: "Arabic text not displaying"

Ensure Noto Naskh Arabic font is loaded:

```dart
// In pubspec.yaml
flutter:
  fonts:
    - family: NotoNaskhArabic
      fonts:
        - asset: assets/fonts/NotoNaskhArabic-Regular.ttf
```

---

## Debugging Tips

### Enable Logging

```dart
import 'package:flutter/foundation.dart';

// Use debugPrint for development
debugPrint('Hadith loaded: ${hadith.id}');
```

### BLoC Observer

Add to `main.dart`:

```dart
Bloc.observer = AppBlocObserver();

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('${bloc.runtimeType} $change');
  }
}
```

### Flutter Inspector

```bash
# Run with verbose logging
flutter run -d macos -v
```

---

## IDE Recommendations

### VS Code Extensions

- Flutter
- Dart
- Awesome Flutter Snippets
- Bloc

### Keybindings

| Action | Keybinding |
|--------|-----------|
| Hot Reload | Cmd+S |
| Hot Restart | Cmd+Shift+S |
| Run | F5 |
| Debug | Shift+F5 |

---

## Resources

- [Flutter macOS Desktop](https://docs.flutter.dev/platform-integration/macos)
- [flutter_bloc Documentation](https://bloclibrary.dev)
- [Hive Documentation](https://docs.hivedb.dev)
- [Hikma Constitution](./.specify/memory/constitution.md)

---

*Quickstart Guide v1.0 | Last Updated: 2026-02-18*
