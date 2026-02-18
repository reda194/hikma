# Quickstart Guide: Hikma App Enhancements

**Feature**: Hikma App Enhancements & Completion
**Date**: 2026-02-18
**Phase**: 1 - Design & Contracts

## For Developers

This guide helps you quickly understand how to implement the enhancements feature.

---

## Prerequisites

1. Flutter 3.19+ SDK installed
2. macOS 11+ (Big Sur) development machine
3. Xcode Command Line Tools
4. Git access to repository

---

## Initial Setup

```bash
# Clone and navigate
git clone https://github.com/reda194/hikma.git
cd hikma

# Checkout feature branch
git checkout enhancements_194

# Install dependencies
flutter pub get

# Verify setup
flutter doctor
flutter analyze
```

---

## Project Structure Overview

```
lib/
├── core/          # Shared utilities, themes, constants
├── data/          # Models, repositories, API services
├── bloc/          # State management (HadithBloc, SchedulerBloc, etc.)
├── ui/            # Screens, widgets, popup components
└── main.dart      # App entry point
```

---

## Architecture Principles

### 1. BLoC Pattern (State Management)

All state lives in BLoCs. Widgets are purely reactive.

```dart
// GOOD: BLoC manages state
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HadithBloc, HadithState>(
      builder: (context, state) {
        if (state is HadithLoaded) {
          return HadithCard(hadith: state.hadith);
        }
        return CircularProgressIndicator();
      },
    );
  }
}

// BAD: Widget manages state
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}
class _MyWidgetState extends State<MyWidget> {
  Hadith? _hadith;  // ❌ Don't do this
}
```

### 2. Offline-First

Always try local data first. API is enhancement only.

```dart
Future<Hadith> fetchRandom({List<String> excludeIds}) async {
  // Try local cache first
  final local = _getRandomLocal(excludeIds);
  if (local != null) return local;

  // Fallback to API
  return await _apiService.fetchRandom(excludeIds);
}
```

### 3. Repository Pattern

BLoCs don't know about data sources. They talk to repositories.

```dart
// In BLoC
on<FetchRandomHadith>((event, emit) async {
  final hadith = await _repository.fetchRandom();
  emit(HadithLoaded(hadith: hadith));
});

// Repository handles data sources
class HadithRepository {
  Future<Hadith> fetchRandom() {
    // Hive, JSON, or API - BLoC doesn't care
  }
}
```

---

## Implementation Tasks (By Priority)

### Week 1: Critical Fixes

1. **Run Flutter Analyze**
   ```bash
   flutter analyze
   # Fix all reported errors
   ```

2. **Initialize Repository on App Launch**
   ```dart
   // In _HikmaHomeState._initialize()
   await _hadithRepository.init();
   await _settingsRepository.init();
   ```

3. **Auto-start Scheduler**
   ```dart
   // In _HikmaHomeState._initialize()
   context.read<SchedulerBloc>().add(const StartScheduler());
   ```

4. **Clean up Popup Architecture**
   - Remove unused `HadithPopup` class
   - Remove unused `HadithPopupDialog` class
   - Keep only `HadithPopupOverlay`

5. **Expand Hadith Dataset**
   - Add 200 Hadiths to `assets/data/hadiths.json`
   - Fix corrupted first entry

### Week 2: Core Features

1. **No-Repeat History**
   ```dart
   // Add to HadithBloc state
   class HadithLoaded extends HadithState {
     final List<String> recentlyShownIds;  // NEW
   }
   ```

2. **Wire Auto-Launch**
   ```dart
   // In SettingsBloc
   on<ToggleAutoStart>((event, emit) async {
     await LaunchAtLogin.setLaunchAtLogin(event.enabled);
   });
   ```

3. **Register Keyboard Shortcut**
   ```dart
   // In MenuBarManager.init()
   await _hotKeyManager.register(
     HotKey(KeyCode.keyH, modifiers: [KeyModifier.meta, KeyModifier.shift]),
     keyDownHandler: (_) => _hadithBloc.add(const FetchRandomHadith()),
   );
   ```

4. **Play Notification Sound**
   ```dart
   // Create AudioService, use in PopupBloc
   if (settings.soundEnabled) {
     await _audioService.playNotificationSound();
   }
   ```

5. **Add Progress Bar**
   ```dart
   // In PopupContent
   LinearProgressIndicator(value: remainingSeconds / totalDuration)
   ```

6. **Copy to Clipboard**
   ```dart
   await Clipboard.setData(ClipboardData(
     text: '${hadith.arabicText} — ${hadith.narrator} | ${hadith.sourceBook}'
   ));
   ```

### Week 3: Polish

1. **Daily Featured Hadith**
   - Add `DailyHadith` model
   - Store in Hive with date key
   - Refresh when date changes

2. **Read Statistics**
   - Track daily counts in Hive
   - Display in Settings or menu bar

3. **Favorites Search**
   - Add `searchQuery` to FavoritesState
   - Filter displayed list
   - Update UI in real-time

4. **Dark Mode**
   - Add `darkModeEnabled` to UserSettings
   - Wire to ThemeMode in main.dart

5. **Onboarding Screen**
   - Create OnboardingScreen widget
   - Show on first launch only

### Week 4: Testing

1. **BLoC Tests**
   ```dart
   test('emits HadithLoaded when fetch succeeds', () {
     // ... bloc_test setup
   });
   ```

2. **Widget Tests**
   ```bash
   flutter test test/widget/
   ```

3. **Integration Test**
   ```bash
   flutter test test/integration/
   ```

---

## Common Patterns

### Creating a New BLoC Event

```dart
// 1. Add event to hadith_event.dart
abstract class HadithEvent {}
class FetchRandomHadith extends HadithEvent {}
class YourNewEvent extends HadithEvent { /* ... */ }

// 2. Handle in hadith_bloc.dart
on<YourNewEvent>((event, emit) async {
  // Your logic
});

// 3. Emit from widget
context.read<HadithBloc>().add(YourNewEvent());
```

### Adding to UserSettings

```dart
// 1. Add property to model
class UserSettings {
  final bool yourNewProperty;  // Add this
  // ... with copyWith
}

// 2. Add to Hive serialization
// (if using Hive adapter)

// 3. Add SettingsEvent
class ToggleYourNewProperty extends SettingsEvent {
  final bool enabled;
}

// 4. Handle in SettingsBloc
on<ToggleYourNewProperty>((event, emit) async {
  // Update and save
});
```

### Creating a New Screen

```dart
// 1. Create widget in lib/ui/screens/
class YourScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Screen')),
      body: /* Your content */,
    );
  }
}

// 2. Add navigation
Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => YourScreen()),
);
```

---

## Testing Commands

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/bloc/hadith_bloc_test.dart

# Run integration test
flutter test test/integration/app_flow_test.dart

# Build for testing
flutter build macos --debug
```

---

## Debugging Tips

1. **Check BLoC state changes**
   ```dart
   // In build method
   BlocBuilder<YourBloc, YourState>(
     builder: (context, state) {
       print('Current state: $state');  // Debug log
       return /* ... */;
     },
   )
   ```

2. **View Hive data**
   ```bash
   # Hive boxes stored in app support directory
   ~/Library/Containers/dev.hikma.Hikma/Data/Documents/
   ```

3. **Enable Flutter logging**
   ```bash
   flutter run --verbose
   ```

---

## File Checklist

When implementing a feature, ensure you update:

- [ ] Model class (if adding new entity)
- [ ] Repository class (if data access changes)
- [ ] BLoC event file (add new events)
- [ ] BLoC state file (add new states or properties)
- [ ] BLoC class (handle new events)
- [ ] UI widget (consume state, emit events)
- [ ] Tests (BLoC and widget tests)

---

## Gotchas

1. **Hive requires initialization** before any access
2. **Window manager** needs `setAsFrameless()` on setup
3. **System tray** must be registered before showing
4. **Hot keys** must be registered on app launch
5. **Audio player** must be disposed on app exit

---

## Resources

- [Flutter BLoC Library](https://bloclibrary.dev)
- [Hive Documentation](https://docs.hivedb.dev)
- [macOS window_manager](https://pub.dev/packages/window_manager)
- [Hikma Constitution](../.specify/memory/constitution.md)

---

**Status**: Ready for implementation. See [tasks.md](../specs/enhancements_194/tasks.md) for detailed task breakdown.
