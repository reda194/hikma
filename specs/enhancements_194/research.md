# Research & Technical Decisions: Hikma App Enhancements

**Feature**: Hikma App Enhancements & Completion
**Date**: 2026-02-18
**Phase**: 0 - Outline & Research

## Overview

This document consolidates research findings for all technical decisions required to implement the enhancements specification. All unknowns from Technical Context have been resolved through analysis of existing codebase, Flutter/macOS best practices, and Hikma's constitutional principles.

---

## 1. Popup Architecture Resolution

### Decision
**Keep `HadithPopupOverlay` for MVP. Defer `window_manager` floating window to future phase.**

### Rationale
- `HadithPopupOverlay` (option 3) is already wired in `main.dart` and working
- `window_manager` approach has platform-specific edge cases (multi-monitor, DPI changes, window focus)
- Overlay provides sufficient UX for initial release
- Floating window can be added as enhancement without breaking changes

### Alternatives Considered
- **Option A (chosen)**: HadithPopupOverlay - Full-screen push route with fade animation
- **Option B**: HadithPopup with window_manager - True floating window, more platform-specific issues

### Implementation Notes
- Remove unused `HadithPopup` and `HadithPopupDialog` classes to reduce confusion
- Keep `HadithPopupOverlay` as single popup implementation
- `PopupBloc` already supports this model

---

## 2. Hadith Dataset Expansion Strategy

### Decision
**Bundle 200+ curated Hadiths in `assets/data/hadiths.json`. Source from public domain authentic collections.**

### Rationale
- Offline-first requirement (Constitution II) mandates bundled content
- API (api.hadith.gading.dev) is enhancement, not dependency
- 200 Hadiths at ~500 bytes each = ~100KB - well within 50MB binary budget
- JSON format already established, easy to extend

### Alternatives Considered
- **SQLite database**: Overkill for static data, adds dependency
- **Hive-boxed Hadiths**: Would require migration from JSON anyway
- **API-only download**: Violates offline-first principle

### Dataset Composition (200 Hadiths Target)

| Collection | Count | Source |
|------------|-------|--------|
| Sahih Al-Bukhari | 60 | Public domain, highest authenticity |
| Sahih Muslim | 50 | Second most authentic collection |
| Sunan Abu Dawud | 30 | Jurisprudence-focused Hadiths |
| Jami' Al-Tirmidhi | 25 | Includes weak/narrated classifications |
| Sunan Ibn Majah | 20 | Covers broad topics |
| Sunan Al-Nasa'i | 15 | Authentic narrations |

### JSON Format (Fixed)

```json
{
  "id": "bukhari-1-1",
  "arabicText": "إنما الأعمال بالنيات",
  "narrator": "عمر بن الخطاب",
  "sourceBook": "Sahih Al-Bukhari",
  "chapter": "الكتاب الأول",
  "bookNumber": 1,
  "hadithNumber": 1,
  "collection": "bukhari"
}
```

### First Hadith Fix
- Current corrupted entry has mixed/garbled text
- Replace with authentic: "إنما الأعمال بالنيات" (Actions are by intentions)

---

## 3. Scheduler Initialization & Settings Listener

### Decision
**Wire `SchedulerBloc` in `_HikmaHomeState._initialize()`. Add `BlocListener` to restart on settings change.**

### Rationale
- Follows existing BLoC architecture pattern
- `BlocListener` is standard Flutter pattern for reacting to state changes
- Scheduler needs to restart when `reminderInterval` changes

### Implementation Pattern

```dart
// In _HikmaHomeState._initialize()
void _initialize() async {
  // Load settings first
  context.read<SettingsBloc>().add(const LoadSettings());

  // Then start scheduler
  context.read<SchedulerBloc>().add(const StartScheduler());
}

// Listener in widget tree
BlocListener<SettingsBloc, SettingsState>(
  listener: (context, state) {
    if (state is SettingsLoaded) {
      final newInterval = state.settings.reminderInterval;
      context.read<SchedulerBloc>().add(
        UpdateSchedulerInterval(newInterval),
      );
    }
  },
  child: /* ... */,
)
```

---

## 4. HadithRepository.init() Call Site

### Decision
**Call in `_HikmaHomeState._initialize()` before any Hadith operations.**

### Rationale
- Repository must be initialized before Hive box access
- `_initialize()` is the app's startup sequence
- Ensures cache is ready for first Hadith fetch

### Implementation

```dart
void _initialize() async {
  // Initialize data layer first
  await _hadithRepository.init();
  await _settingsRepository.init();

  // Then load UI state
  context.read<SettingsBloc>().add(const LoadSettings());
  context.read<SchedulerBloc>().add(const StartScheduler());
}
```

---

## 5. No-Repeat History Strategy

### Decision
**Track last 30 Hadith IDs in `HadithBloc` state. Persist to Hive. Exclude from random selection.**

### Rationale
- 30 Hadiths at 30-min interval = 15 hours before possible repeat
- Hive persistence maintains history across app restarts
- BLoC state approach follows constitutional architecture

### Implementation

```dart
// In HadithState
class HadithLoaded extends HadithState {
  final Hadith hadith;
  final List<String> recentlyShownIds;  // NEW

  const HadithLoaded({
    required this.hadith,
    this.recentlyShownIds = const [],
  });
}

// In HadithBloc
on<FetchRandomHadith>((event, emit) async {
  final currentState = state as HadithLoaded;
  final excludeIds = currentState.recentlyShownIds;

  final hadith = await _repository.fetchRandom(excludeIds: excludeIds);

  final newHistory = [...excludeIds, hadith.id]
    ..takeLast(30)  // Keep only last 30
    ..toList();

  await _repository.saveHistory(newHistory);  // Persist to Hive

  emit(HadithLoaded(hadith: hadith, recentlyShownIds: newHistory));
});
```

---

## 6. Daily Featured Hadith Implementation

### Decision
**Store `dailyHadithId` + `dailyDate` in Hive. Check on app launch, refresh if date changed.**

### Rationale
- Hive is already in use for settings
- Simple key-value storage sufficient
- Date comparison logic is straightforward

### Data Model

```dart
class DailyHadithStorage {
  final String hadithId;
  final String date;  // YYYY-MM-DD format

  DailyHadithStorage({required this.hadithId, required this.date});
}

// Hive keys
const String _dailyHadithKey = 'daily_hadith';
const String _dailyDateKey = 'daily_date';
```

### Refresh Logic

```dart
Hadith? _loadDailyHadith() {
  final storedDate = _hiveBox.get(_dailyDateKey, defaultValue: '');
  final today = DateTime.now().toIso8601String().substring(0, 10);

  if (storedDate != today) {
    // Pick new Hadith for today
    final newHadith = _pickRandomHadith();
    _hiveBox.put(_dailyHadithKey, newHadith.id);
    _hiveBox.put(_dailyDateKey, today);
    return newHadith;
  }

  final hadithId = _hiveBox.get(_dailyHadithKey);
  return _getHadithById(hadithId);
}
```

---

## 7. Read Statistics Tracking

### Decision
**Track daily counts in Hive with date-keyed format. Weekly total computed from last 7 days.**

### Rationale
- Simple counter per day is sufficient
- Hive key pattern: `"reads_YYYY-MM-DD": count`
- Weekly calculation is sum of last 7 keys

### Implementation

```dart
class ReadStatistics {
  final Map<String, int> dailyReads;

  int getTodayCount() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return dailyReads['reads_$today'] ?? 0;
  }

  int getWeekCount() {
    final total = 0;
    for (int i = 0; i < 7; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final key = date.toIso8601String().substring(0, 10);
      total += dailyReads['reads_$key'] ?? 0;
    }
    return total;
  }

  void incrementToday() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final key = 'reads_$today';
    dailyReads[key] = (dailyReads[key] ?? 0) + 1;
    _hiveBox.put(key, dailyReads[key]);
  }
}
```

---

## 8. Favorites Search Implementation

### Decision
**Client-side filtering using Dart `where()` on loaded list. Real-time as user types.**

### Rationale
- Favorites list is small (typically <100 items)
- No server-side search needed
- Real-time filtering provides better UX
- Simpler than full-text search library

### Implementation

```dart
// In FavoritesBloc
class FavoritesLoaded extends FavoritesState {
  final List<Hadith> favorites;
  final String searchQuery;  // NEW

  List<Hadith> get displayedFavorites {
    if (searchQuery.isEmpty) return favorites;

    final query = searchQuery.toLowerCase();
    return favorites.where((h) =>
      h.arabicText.contains(query) ||
      h.narrator.toLowerCase().contains(query) ||
      h.sourceBook.toLowerCase().contains(query)
    ).toList();
  }
}

on<SearchFavorites>((event, emit) {
  final currentState = state as FavoritesLoaded;
  emit(currentState.copyWith(searchQuery: event.query));
});
```

---

## 9. Auto-Launch Package Integration

### Decision
**Use existing `launch_at_login` package. Wire in `SettingsBloc` event handler.**

### Rationale
- Package already in `pubspec.yaml`
- Simple API: `LaunchAtLogin.setLaunchAtLogin(bool)`
- Works reliably on macOS

### Implementation

```dart
// In SettingsBloc
import 'package:launch_at_login/launch_at_login.dart';

on<ToggleAutoStart>((event, emit) async {
  final newSettings = currentState.settings.copyWith(
    autoStartEnabled: event.enabled,
  );

  await LaunchAtLogin.setLaunchAtLogin(event.enabled);
  await _settingsRepository.saveSettings(newSettings);

  emit(SettingsLoaded(settings: newSettings));
});
```

### macOS Entitlements Required
- Add to `macos/Runner/DebugProfile.entitlements` and `Release.entitlements`:
```xml
<key>com.apple.security.automation.apple-events</key>
<true/>
```

---

## 10. Keyboard Shortcut Registration

### Decision
**Register `Cmd+Shift+H` using `hotkey_manager` in `MenuBarManager.init()`. Triggers `FetchRandomHadith`.**

### Rationale
- Package already in `pubspec.yaml`
- Global hotkey works even when app is not focused
- Shortcut is memorable (H for Hadith)

### Implementation

```dart
// In MenuBarManager
import 'package:hotkey_manager/hotkey_manager.dart';

final _hotKeyManager = HotKeyManager();

Future<void> init() async {
  await _hotKeyManager.register(
    HotKey(
      KeyCode.keyH,
      modifiers: [KeyModifier.meta, KeyModifier.shift],
    ),
    keyDownHandler: (_) {
      _hadithBloc.add(const FetchRandomHadith());
    },
  );
}
```

---

## 11. Notification Sound Playback

### Decision
**Use existing `audioplayers` package. Play 0.5-second subtle chime when popup shows.**

### Rationale
- Package already in `pubspec.yaml`
- Audio file included in assets (~50KB)
- Configurable via `soundEnabled` setting

### Sound Asset
- File: `assets/sounds/notification.mp3`
- Duration: <1 second
- Type: Soft chime or bell (non-intrusive)

### Implementation

```dart
// Create new service: lib/data/services/audio_service.dart
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playNotificationSound() async {
    await _player.play(AssetSource('sounds/notification.mp3'));
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}

// In PopupBloc listener
if (state.settings.soundEnabled) {
  await _audioService.playNotificationSound();
}
```

---

## 12. Popup Countdown Progress Bar

### Decision
**Add `LinearProgressIndicator` at bottom of popup. Animates from 1.0 to 0.0 over duration.**

### Rationale
- `remainingSeconds` already tracked in `PopupBloc`
- Flutter's `LinearProgressIndicator` provides smooth animation
- Visual cue without being intrusive

### Implementation

```dart
// In PopupContent widget
Widget _buildCountdownIndicator(int remainingSeconds, int totalDuration) {
  final progress = remainingSeconds / totalDuration;

  return Container(
    height: 3,
    child: LinearProgressIndicator(
      value: progress,
      backgroundColor: Colors.white.withOpacity(0.1),
      valueColor: AlwaysStoppedAnimation<Color>(
        Colors.white.withOpacity(0.8),
      ),
    ),
  );
}
```

---

## 13. Copy to Clipboard Format

### Decision
**Format: Arabic text — Narrator | Source Book**

### Rationale
- Single-line format for easy pasting into messages
- Includes all required citations (Constitution V)
- Works well for WhatsApp, iMessage, email

### Example Output
```
إنما الأعمال بالنيات — عمر بن الخطاب | صحيح البخاري
```

### Implementation

```dart
import 'package:flutter/services.dart';

Future<void> copyHadithToClipboard(Hadith hadith) async {
  final formatted = '${hadith.arabicText} — ${hadith.narrator} | ${hadith.sourceBook}';
  await Clipboard.setData(ClipboardData(text: formatted));

  // Show brief confirmation
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Hadith copied'),
      duration: Duration(seconds: 2),
    ),
  );
}
```

---

## 14. Dark Mode Implementation

### Decision
**Add `darkModeEnabled` to `UserSettings`. Wire to `ThemeMode` in `main.dart`. Use existing `AppTheme.darkTheme`.**

### Rationale
- Dark theme already defined
- Only need to expose toggle and wire to `ThemeMode`
- System theme detection via `MediaQuery.platformBrightness`

### Implementation

```dart
// In UserSettings model
class UserSettings {
  final bool darkModeEnabled;  // NEW
  // ... other fields
}

// In main.dart
class HikmaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final themeMode = state is SettingsLoaded && state.settings.darkModeEnabled
            ? ThemeMode.dark
            : ThemeMode.light;

        return MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          // ...
        );
      },
    );
  }
}
```

---

## 15. First-Launch Onboarding

### Decision
**Single-screen welcome. Track `hasSeenOnboarding` bool in Hive. Show only once.**

### Rationale
- One screen is sufficient for simple app
- Hive flag prevents repeat showing
- Minimal friction to first-time users

### Onboarding Screen Content
- App icon + name "Hikma" (حكمة)
- Tagline: "Authentic Hadith reminders throughout your day"
- Description: "Receive beautiful Hadith popups at your chosen interval. Save favorites, track your reading, and grow in knowledge."
- Button: "Start Receiving Hadiths" → triggers `StartScheduler()`

### Implementation

```dart
// In _HikmaHomeState._initialize()
void _initialize() async {
  final hasSeenOnboarding = _hiveBox.get('hasSeenOnboarding', defaultValue: false);

  if (!hasSeenOnboarding) {
    // Show onboarding
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  } else {
    // Normal initialization
    context.read<SchedulerBloc>().add(const StartScheduler());
  }
}

// In OnboardingScreen
void _onGetStarted() {
  _hiveBox.put('hasSeenOnboarding', true);
  context.read<SchedulerBloc>().add(const StartScheduler());
  Navigator.of(context).pop();
}
```

---

## 16. Contemplation Mode Design

### Decision
**Full-screen route with dark gradient background. Large centered text. Minimal UI overlay.**

### Rationale
- Distraction-free reading experience
- Reuses existing Hadith display components
- Escape key exits (standard pattern)

### Visual Design
- Background: Linear gradient (navy #1a237e to deep teal #004d40)
- Text: Noto Naskh Arabic, 36-48pt
- Overlay buttons: "Next Hadith" (bottom right), "Bookmark" (bottom left), Exit hint (top center)
- Animation: Fade in (300ms)

---

## 17. Menu Bar Menu Structure

### Decision
**Implement comprehensive right-click menu with all primary actions.**

### Menu Items

| Item | Action |
|------|--------|
| Show Hadith Now | Triggers `FetchRandomHadith` immediately |
| Today's Hadith | Opens daily featured Hadith |
| Favorites | Opens Favorites screen |
| Settings | Opens Settings screen |
| About Hikma | Opens About screen |
| ───────────────── | Separator |
| Quit | Exits app |

### Implementation

```dart
// In MenuBarManager
Menu menu = Menu(
  items: [
    MenuItem(key: 'show_now', label: 'Show Hadith Now'),
    MenuItem(key: 'today', label: "Today's Hadith"),
    MenuItem(key: 'favorites', label: 'Favorites'),
    MenuItem(key: 'settings', label: 'Settings'),
    MenuItem(key: 'about', label: 'About Hikma'),
    MenuItem.separator(),
    MenuItem(key: 'quit', label: 'Quit'),
  ],
);

menu.registerItem('show_now', (_) => _hadithBloc.add(FetchRandomHadith()));
// ... wire other items
```

---

## 18. Empty State Handling

### Decision
**Graceful fallback when no Hadith can be loaded. Shows friendly message.**

### Empty States

| Scenario | Message |
|----------|---------|
| Offline + no local data | "Could not load a Hadith. Please check your connection." |
| No favorites | "Save your first Hadith to see it here." |
| No search results | "No matching Hadiths found." |
| API error | Silent fallback to offline (no error message) |

---

## 19. Popup Position Memory

### Decision
**Verify and fix position persistence. Save on drag end, restore on popup show.**

### Implementation (if not working)

```dart
// In PopupBloc
on<UpdatePosition>((event, emit) {
  final position = PopupPosition(dx: event.dx, dy: event.dy);
  _settingsRepository.savePopupPosition(position);
  emit(state.copyWith(position: position));
});

// In HadithPopup widget
@override
void initState() {
  super.initState();
  _position = BlocProvider.of<PopupBloc>(context)
    .state
    .position
    .valueOr(const Offset(100, 100));
}
```

---

## 20. Flutter Analyze & Compilation Fixes

### Decision
**Run `flutter analyze` and fix all errors. Address common issues:**

| Common Issue | Fix |
|--------------|-----|
| Missing imports | Add required imports |
| Type mismatches | Update type annotations |
| Deprecated APIs | Use current Flutter APIs |
| Const issues | Add/remove const as needed |
| Nullable types | Add null checks or default values |

---

## Summary of New Dependencies

All required packages already in `pubspec.yaml`. No new dependencies needed:

- `launch_at_login` - Already present
- `hotkey_manager` - Already present
- `audioplayers` - Already present

---

## Testing Strategy Research

### BLoC Testing
- Use `bloc_test` package
- Test all state transitions
- Mock repository dependencies

### Widget Testing
- Use `flutter_test`
- Test widget rendering with different states
- Verify user interactions emit correct events

### Integration Testing
- Use `flutter_driver` or `integration_test`
- Test full flow: launch → popup → favorite → verify

---

## Architecture Compliance

All decisions comply with Hikma Constitution:
- ✅ Simplicity: No new patterns, extend existing BLoCs
- ✅ Offline-first: All features work offline
- ✅ BLoC Architecture: State in BLoCs only
- ✅ macOS Native: Native packages, menu bar, shortcuts
- ✅ Authentic Content: Citations preserved
- ✅ Privacy: All local storage

---

**Status**: Phase 0 Complete. All unknowns resolved. Ready for Phase 1 design.
