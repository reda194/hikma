# Phase 0: Research & Technical Decisions

**Feature**: Hikma MVP - Hadith Reminder App for macOS
**Date**: 2026-02-18
**Status**: Complete

---

## Overview

This document captures the research findings and technical decisions for implementing Hikma as a Flutter macOS desktop application. All decisions align with the project constitution defined in `.specify/memory/constitution.md`.

---

## 1. Hadith API Selection

### Options Evaluated

| API | Base URL | Collections | Rate Limit | Auth |
|-----|----------|-------------|------------|------|
| api.hadith.gading.dev | https://api.hadith.gading.dev | Bukhari, Muslim, Abu Dawud, Tirmidhi, Ibn Majah, Nasa'i | Unknown | None |
* ahadith.co | https://ahadith.co | Bukhari, Muslim, Abu Dawud, Tirmidhi, Ibn Majah, Nasa'i, Muwatta, Others | Unknown | None |
* Sunnah.com | https://sunnah.com | Bukhari, Muslim, Abu Dawud, Tirmidhi, Ibn Majah, Nasa'i, Muwatta, Others | Unknown | None |
* Al Quran Cloud API | https://api.alquran.cloud | Various collections including Hadith | 100 req/hour | API Key |

### Decision: api.hadith.gading.dev (Primary)

**Rationale**:
- Supports all six authentic collections (Kutub al-Sittah) required by spec
- No authentication required (aligns with Privacy principle)
- JSON response format (easy to parse with Dart)
- Active maintenance as of 2025
- Simple, predictable endpoint structure

**Fallback Strategy**:
- Bundled local JSON (200-500 curated Hadiths) ensures app works without API
- API failures are handled silently with transparent fallback to local data
- No user-facing error messages for network issues (Offline-First principle)

### API Usage Pattern

```dart
// Endpoint pattern: https://api.hadith.gading.dev/books/{collection}/{bookNumber}
// Response format includes: { id, arabic, narration, book, bookNumber, hadithNumber }

class HadithApiService {
  final Dio _dio;
  final String baseUrl = 'https://api.hadith.gading.dev';

  Future<List<Hadith>> fetchHadiths(HadithCollection collection, int bookNumber) async {
    // Implementation with try-catch for silent fallback
  }
}
```

---

## 2. BLoC Implementation Patterns

### Decision: flutter_bloc ^8.1.0 with Equatable

**Rationale**:
- `flutter_bloc` is the de facto standard for state management in Flutter
- Explicit event/state pattern ensures testability (Constitution Principle III)
- `equatable` simplifies state equality comparisons
- Clear separation of concerns: UI widgets emit events, BLoCs process and emit states

### BLoC Structure per Feature

Each BLoC follows this pattern:

```dart
// 1. Abstract Event
abstract class HadithEvent extends Equatable {
  const HadithEvent();
}

// 2. Concrete Events
class FetchRandomHadith extends HadithEvent { ... }
class FilterByCollection extends HadithEvent { ... }

// 3. State with Equatable
class HadithState extends Equatable {
  final Hadith? hadith;
  final bool isLoading;
  final String? error;

  const HadithState({
    this.hadith,
    this.isLoading = false,
    this.error,
  });

  HadithState copyWith({ ... }) { ... }

  @override
  List<Object?> get props => [hadith, isLoading, error];
}

// 4. BLoC
class HadithBloc extends Bloc<HadithEvent, HadithState> {
  final HadithRepository _repository;

  HadithBloc(this._repository) : super(HadithState.initial()) {
    on<FetchRandomHadith>(_onFetchRandomHadith);
    on<FilterByCollection>(_onFilterByCollection);
  }

  Future<void> _onFetchRandomHadith(
    FetchRandomHadith event,
    Emitter<HadithState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final hadith = await _repository.getRandomHadith(state.collection);
      emit(state.copyWith(hadith: hadith, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      // No error state - silent fallback to local data handled in repository
    }
  }
}
```

### BLoC-to-BLoC Communication

- **SettingsBloc** broadcasts settings changes via a stream
- Other BLoCs listen to settings changes and update behavior accordingly
- Example: SchedulerBloc listens to interval changes from SettingsBloc

```dart
// In SchedulerBloc
SettingsBloc _settingsBloc;

SchedulerBloc(this._settingsBloc) {
  _settingsBloc.stream.listen((settings) {
    if (settings.intervalChanged) {
      _reschedule(settings.newInterval);
    }
  });
}
```

---

## 3. macOS Window Management

### Decision: window_manager ^0.3.0

**Rationale**:
- Provides cross-platform window control with macOS-specific features
- Supports floating windows (without title bar)
- Position persistence across app restarts
- Drag-to-move functionality
- Alignment with Constitution Principle IV (macOS Native Experience)

### Implementation Pattern

```dart
import 'package:window_manager/window_manager.dart';

class HadithPopup extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    _initWindow();
  }

  Future<void> _initWindow() async {
    await windowManager.ensureInitialized();

    final WindowOptions windowOptions = WindowOptions(
      size: Size(480, 300), // Width fixed, height adapts
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: true, // Don't show in dock
      titleBarStyle: TitleBarStyle.hidden, // No title bar
      windowButtonVisibility: false, // No traffic lights
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    // Load saved position
    final savedPosition = await _getSavedPosition();
    if (savedPosition != null) {
      await windowManager.setPosition(savedPosition);
    }
  }

  // Enable dragging
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        windowManager.setPosition(
          Offset(
            windowManager.position.dx + details.delta.dx,
            windowManager.position.dy + details.delta.dy,
          ),
        );
      },
      child: ... // popup content
    );
  }

  @override
  void dispose() {
    // Save position before closing
    _savePosition(await windowManager.position);
    super.dispose();
  }
}
```

---

## 4. Menu Bar Integration

### Decision: system_tray ^2.0.0

**Rationale**:
- Native macOS menu bar icon with dropdown menu
- Custom icon support (crescent moon PNG)
- Left-click and right-click menu handling
- Proper lifecycle management (app can run without windows)

### Implementation Pattern

```dart
import 'package:system_tray/system_tray.dart';

class MenuBarManager {
  final SystemTray _systemTray = SystemTray();
  final Menu _menu = Menu();

  Future<void> init() async {
    // Load icon from assets
    await _systemTray.init(
      iconPath: 'assets/images/menu_bar_icon.png',
      tooltip: 'Hikma - Hadith Reminder',
    );

    // Build menu
    await _menu.build([
      MenuItemLabel(label: 'Show Hadith', onClicked: _showHadith),
      MenuItemLabel(label: 'Favorites', onClicked: _showFavorites),
      MenuItemLabel(label: 'Settings', onClicked: _showSettings),
      MenuSeparator(),
      MenuItemLabel(label: 'About Hikma', onClicked: _showAbout),
      MenuItemLabel(label: 'Quit', onClicked: _quit),
    ]);

    await _systemTray.setMenu(_menu);

    // Handle menu bar click events
    _systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick) {
        _showHadith(null);
      }
    });
  }

  void _showHadith(_) {
    // Trigger popup via PopupBloc
    popupBloc.add(ShowPopup());
  }
}
```

---

## 5. Offline-First Architecture

### Decision: Hive ^1.1.0 + Bundled JSON

**Rationale**:
- Hive is fast, lightweight, and requires no setup (no native database)
- Bundled JSON ships with app for immediate offline capability
- API fetches cache into Hive for future offline access
- No user-facing connectivity issues (Constitution Principle II)

### Storage Schema

```dart
// Hive Boxes
const String HADITH_BOX = 'hadiths';
const String SETTINGS_BOX = 'settings';
const String FAVORITES_BOX = 'favorites';

// Storage Keys
class StorageKeys {
  static const String reminderInterval = 'reminder_interval';
  static const String popupDuration = 'popup_duration';
  static const String sourceCollection = 'source_collection';
  static const String fontSize = 'font_size';
  static const String soundEnabled = 'sound_enabled';
  static const String autoStart = 'auto_start';
  static const String showInDock = 'show_in_dock';
  static const String popupPosition = 'popup_position';
}
```

### Repository Pattern with Fallback

```dart
class HadithRepository {
  final LocalHadithService _localService;
  final HadithApiService _apiService;
  final ConnectivityService _connectivity;

  Future<Hadith> getRandomHadith(HadithCollection collection) async {
    // Try API first if online
    if (await _connectivity.isOnline) {
      try {
        final hadith = await _apiService.fetchRandomHadith(collection);
        // Cache to local storage
        await _localService.cacheHadith(hadith);
        return hadith;
      } catch (e) {
        // Silent fallback to local
      }
    }

    // Always have local fallback
    return await _localService.getRandomHadith(collection);
  }
}
```

---

## 6. RTL Text Handling

### Decision: Flutter Directionality with TextDirection.rtl

**Rationale**:
- Flutter has built-in RTL support
- Noto Naskh Arabic font designed for Arabic script
- TextDirection.rtl automatically handles proper text alignment
- No need for manual text reversal

### Implementation Pattern

```dart
class HadithText extends StatelessWidget {
  final String arabicText;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Text(
        arabicText,
        style: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 24, // Large by default
          height: 1.8, // Line height for readability
        ),
        textAlign: TextAlign.right,
      ),
    );
  }
}
```

### Font Loading via google_fonts

```dart
import 'package:google_fonts/google_fonts.dart';

final arabicTextStyle = GoogleFonts.notoNaskhArabic(
  fontSize: 24,
  height: 1.8,
  fontWeight: FontWeight.w400,
);
```

---

## 7. Frosted Glass Effects

### Decision: flutter_acrylic ^1.1.0

**Rationale**:
- Native macOS blur effects (vibrancy)
- Performance-efficient (uses platform APIs)
- Matches macOS design language (Constitution Principle IV)
- Alternative would be platform channels with NSVisualEffectView

### Implementation Pattern

```dart
import 'package:flutter_acrylic/flutter_acrylic.dart';

class HadithPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Acrylic(
      type: AcrylicType.frosted,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: // popup content
      ),
    );
  }
}
```

---

## 8. Auto-Start on Login

### Decision: launch_at_login ^0.1.0 or manual LoginItem management

**Rationale**:
- macOS uses LoginItems for auto-start apps
- Package simplifies ServiceManagement framework access
- User preference stored in Hive, applied on change

### Implementation Pattern

```dart
import 'package:launch_at_login/launch_at_login.dart';

class AutoStartManager {
  final SettingsRepository _settings;

  Future<void> updateAutoStart(bool enabled) async {
    await LaunchAtLogin.setLaunchAtLogin(enabled);
    await _settings.setBool(StorageKeys.autoStart, enabled);
  }

  Future<bool> isEnabled() async {
    return await LaunchAtLogin.getLaunchAtLogin();
  }
}
```

---

## 9. Scheduler Implementation

### Decision: Timer-based with Dart Timer

**Rationale**:
- Built-in Dart Timer (no dependencies)
- Handles all interval options (30min to daily)
- Survives app suspend/resume (resets on wake)
- Simple and reliable

### Implementation Pattern

```dart
class SchedulerBloc extends Bloc<SchedulerEvent, SchedulerState> {
  Timer? _timer;

  SchedulerBloc(this._settingsBloc) {
    on<StartScheduler>(_onStart);
    on<StopScheduler>(_onStop);
    on<SettingsChanged>(_onSettingsChanged);

    // Listen to settings changes
    _settingsBloc.stream.listen((settings) {
      add(SettingsChanged(settings));
    });
  }

  Future<void> _onStart(
    StartScheduler event,
    Emitter<SchedulerState> emit,
  ) async {
    _timer?.cancel();
    final interval = _settingsBloc.currentSettings.interval;

    _timer = Timer.periodic(
      Duration(minutes: interval.inMinutes),
      (_) => popupBloc.add(ShowPopup()),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
```

---

## 10. Notification Sound

### Decision: AudioPlayer from audioplayers package or macOS NSSound

**Rationale**:
- Simple, short notification sound
- No need for complex audio management
- Can use bundled asset file

### Implementation Pattern

```dart
import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  final AudioPlayer _player = AudioPlayer();
  final SettingsRepository _settings;

  Future<void> playPopupSound() async {
    if (!await _settings.getBool(StorageKeys.soundEnabled)) {
      return;
    }

    await _player.play(AssetSource('sounds/notification.mp3'));
  }
}
```

---

## Summary of Technical Decisions

| Area | Decision | Key Package(s) |
|------|----------|----------------|
| Hadith API | api.hadith.gading.dev | dio ^5.4.0 |
| State Management | BLoC with Equatable | flutter_bloc ^8.1.0, equatable ^2.0.5 |
| Local Storage | Hive key-value store | hive_flutter ^1.1.0 |
| Window Management | Floating popup with drag | window_manager ^0.3.0 |
| Menu Bar | System tray icon | system_tray ^2.0.0 |
| RTL Text | Flutter Directionality | google_fonts ^6.1.0 |
| Frosted Glass | Acrylic/vibrancy effect | flutter_acrylic ^1.1.0 |
| Connectivity | Network status detection | connectivity_plus ^5.0.0 |
| Auto-Start | LoginItem management | launch_at_login ^0.1.0 |
| Sound | Simple notification audio | audioplayers ^5.2.0 |

---

## Next Steps

With Phase 0 research complete, proceed to Phase 1:
- [ ] Create data-model.md with entity definitions
- [ ] Define contracts/ with API schemas
- [ ] Write quickstart.md with setup instructions

---

*Research Document v1.0 | Last Updated: 2026-02-18*
