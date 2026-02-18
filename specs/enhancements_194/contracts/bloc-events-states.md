# BLoC Contracts: Hikma App Enhancements

**Feature**: Hikma App Enhancements & Completion
**Date**: 2026-02-18
**Phase**: 1 - Design & Contracts

## Overview

This document defines the event and state contracts for all BLoCs. It specifies extensions to existing BLoCs and new event/state definitions for enhanced functionality.

---

## HadithBloc Extensions

### Events

| Event | Payload | Description |
|-------|---------|-------------|
| `FetchRandomHadith` | `collection?: HadithCollection` | Fetch a random Hadith (optionally filtered by collection) |
| `LoadDailyHadith` | - | Load today's featured Hadith |
| `RefreshDailyHadith` | - | Force-refresh today's Hadith (pick new one) |
| `IncrementReadCount` | - | Track that a Hadith was viewed | **NEW** |

### States

| State | Properties | Description |
|-------|------------|-------------|
| `HadithInitial` | - | Initial state before any fetch |
| `HadithLoading` | - | Loading in progress |
| `HadithLoaded` | `hadith: Hadith`, `recentlyShownIds: List<String>`, `dailyHadith?: Hadith` | Hadith successfully loaded with history tracking |
| `HadithError` | `message: String` | Error loading Hadith |

### State Transitions

```
HadithInitial
    └─[FetchRandomHadith]──▶ HadithLoading
                               └─[success]──▶ HadithLoaded
                               └─[error]────▶ HadithError

HadithLoaded
    └─[FetchRandomHadith]──▶ HadithLoading
    └─[LoadDailyHadith]─────▶ HadithLoaded (with dailyHadith set)
    └─[IncrementReadCount]──▶ HadithLoaded (no state change, side effect)

HadithError
    └─[FetchRandomHadith]──▶ HadithLoading
```

---

## SchedulerBloc Extensions

### Events

| Event | Payload | Description |
|-------|---------|-------------|
| `StartScheduler` | - | Start the reminder timer |
| `StopScheduler` | - | Stop the reminder timer |
| `UpdateSchedulerInterval` | `interval: ReminderInterval` | Change interval and restart timer | **NEW** |

### States

| State | Properties | Description |
|-------|------------|-------------|
| `SchedulerInitial` | - | Scheduler not started |
| `SchedulerRunning` | `interval: ReminderInterval`, `nextPopupTime: DateTime?` | Scheduler is active |
| `SchedulerStopped` | - | Scheduler stopped |
| `SchedulerError` | `message: String` | Scheduler error |

### State Transitions

```
SchedulerInitial
    └─[StartScheduler]──▶ SchedulerRunning

SchedulerRunning
    └─[StopScheduler]────────────▶ SchedulerStopped
    └─[UpdateSchedulerInterval]──▶ SchedulerRunning (with new interval)

SchedulerStopped
    └─[StartScheduler]──▶ SchedulerRunning
```

---

## FavoritesBloc Extensions

### Events

| Event | Payload | Description |
|-------|---------|-------------|
| `LoadFavorites` | - | Load user's favorites |
| `ToggleFavorite` | `hadith: Hadith` | Add or remove from favorites |
| `SearchFavorites` | `query: String` | Filter favorites by search query | **NEW** |

### States

| State | Properties | Description |
|-------|------------|-------------|
| `FavoritesInitial` | - | Initial state |
| `FavoritesLoading` | - | Loading favorites |
| `FavoritesLoaded` | `favorites: List<Hadith>`, `searchQuery: String` | Favorites loaded with optional filter |
| `FavoritesError` | `message: String` | Error loading favorites |

### Computed Properties

```dart
// In FavoritesLoaded state
List<Hadith> get displayedFavorites {
  if (searchQuery.isEmpty) return favorites;

  final query = searchQuery.toLowerCase();
  return favorites.where((h) =>
    h.arabicText.contains(query) ||
    h.narrator.toLowerCase().contains(query) ||
    h.sourceBook.toLowerCase().contains(query)
  ).toList();
}
```

### State Transitions

```
FavoritesInitial
    └─[LoadFavorites]──▶ FavoritesLoading
                           └─[success]──▶ FavoritesLoaded
                           └─[error]────▶ FavoritesError

FavoritesLoaded
    └─[ToggleFavorite]──▶ FavoritesLoaded (with updated list)
    └─[SearchFavorites]─▶ FavoritesLoaded (with new searchQuery)
```

---

## SettingsBloc Extensions

### Events

| Event | Payload | Description |
|-------|---------|-------------|
| `LoadSettings` | - | Load user settings |
| `UpdateFontSize` | `size: FontSize` | Change font size |
| `UpdateReminderInterval` | `interval: ReminderInterval` | Change reminder frequency |
| `UpdatePopupDuration` | `duration: PopupDuration` | Change popup duration |
| `UpdateSourceCollection` | `collection: HadithCollection` | Change preferred source |
| `ToggleSound` | `enabled: bool` | Enable/disable notification sound |
| `ToggleAutoStart` | `enabled: bool` | Enable/disable launch at login | **WIRED** |
| `ToggleShowInDock` | `enabled: bool` | Enable/disable Dock icon |
| `ToggleDarkMode` | `enabled: bool` | Enable/disable dark mode | **NEW** |
| `SavePopupPosition` | `position: PopupPosition` | Save popup coordinates | **WIRED** |

### States

| State | Properties | Description |
|-------|------------|-------------|
| `SettingsInitial` | - | Initial state |
| `SettingsLoading` | - | Loading settings |
| `SettingsLoaded` | `settings: UserSettings` | Settings loaded |
| `SettingsError` | `message: String` | Error loading settings |

### State Transitions

```
SettingsInitial
    └─[LoadSettings]──▶ SettingsLoading
                          └─[success]──▶ SettingsLoaded
                          └─[error]────▶ SettingsError

SettingsLoaded
    └─[UpdateFontSize]──────────▶ SettingsLoaded (with new fontSize)
    └─[UpdateReminderInterval]──▶ SettingsLoaded (with new interval)
    └─[ToggleDarkMode]──────────▶ SettingsLoaded (with darkModeEnabled)
    ... (all update events return to SettingsLoaded)
```

---

## PopupBloc (Verify, No Major Changes)

### Events

| Event | Payload | Description |
|-------|---------|-------------|
| `ShowPopup` | `hadithId: String` | Display popup for specific Hadith |
| `ShowRandomHadith` | - | Display popup with random Hadith |
| `DismissPopup` | `savePosition: bool` | Hide popup |
| `UpdatePosition` | `dx: double`, `dy: double` | Update popup position from drag |

### States

| State | Properties | Description |
|-------|------------|-------------|
| `PopupInitial` | - | No popup shown |
| `PopupVisible` | `hadithId: String`, `remainingSeconds: int`, `isDismissible: bool` | Popup is displayed |
| `PopupHidden` | - | Popup is hidden |

### Countdown Behavior

```dart
// In PopupBloc
Timer? _dismissTimer;

on<ShowPopup>((event, emit) async {
  emit(PopupVisible(
    hadithId: event.hadithId,
    remainingSeconds: settings.popupDuration.totalSeconds,
    isDismissible: true,
  ));

  _dismissTimer?.cancel();
  if (settings.popupDuration != PopupDuration.manual) {
    _dismissTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final current = state as PopupVisible;
      if (current.remainingSeconds <= 1) {
        add(const DismissPopup(savePosition: true));
        timer.cancel();
      } else {
        emit(current.copyWith(
          remainingSeconds: current.remainingSeconds - 1,
        ));
      }
    });
  }
});
```

---

## New BLoC: StatisticsBloc (Optional)

### Events

| Event | Payload | Description |
|-------|---------|-------------|
| `LoadStatistics` | - | Load reading statistics |
| `IncrementDailyCount` | - | Increment today's read count |
| `ResetStatistics` | - | Clear all statistics (for testing) |

### States

| State | Properties | Description |
|-------|------------|-------------|
| `StatisticsInitial` | - | Initial state |
| `StatisticsLoaded` | `todayCount: int`, `weekCount: int` | Statistics loaded |

### Note

This BLoC is optional. Statistics can be tracked directly in `HadithBloc` using `IncrementReadCount` event without a separate BLoC. The simpler approach is recommended.

---

## Inter-BLoC Communication

### SchedulerBloc listens to SettingsBloc

```dart
// In _HikmaHomeState
BlocListener<SettingsBloc, SettingsState>(
  listener: (context, state) {
    if (state is SettingsLoaded) {
      // Restart scheduler when interval changes
      context.read<SchedulerBloc>().add(
        UpdateSchedulerInterval(state.settings.reminderInterval),
      );

      // Update launch at login
      // (handled in SettingsBloc itself)
    }
  },
  child: /* ... */,
)
```

### HadithBloc notifies StatisticsBloc (if using separate BLoC)

```dart
// In HadithBloc
on<IncrementReadCount>((event, emit) {
  _statisticsRepository.incrementToday();
})
```

---

## Repository Interfaces

### HadithRepository

```dart
abstract class HadithRepository {
  Future<void> init();                                // Initialize Hive box
  Future<Hadith> fetchRandom({List<String> excludeIds, HadithCollection? collection});
  Future<Hadith?> getById(String id);                 // Get specific Hadith
  Future<Hadith> getDailyHadith();                    // Get today's featured
  Future<void> setDailyHadith(Hadith hadith);         // Set today's featured
  Future<void> saveHistory(List<String> ids);          // Save history
  Future<List<String>> loadHistory();                 // Load history
}
```

### SettingsRepository

```dart
abstract class SettingsRepository {
  Future<void> init();
  Future<UserSettings> loadSettings();
  Future<void> saveSettings(UserSettings settings);
  Future<void> savePopupPosition(PopupPosition position);
  Future<PopupPosition?> loadPopupPosition();
}
```

### FavoritesRepository

```dart
abstract class FavoritesRepository {
  Future<List<String>> loadFavoriteIds();
  Future<void> addFavorite(String hadithId);
  Future<void> removeFavorite(String hadithId);
  Future<bool> isFavorite(String hadithId);
}
```

### AudioService (NEW)

```dart
abstract class AudioService {
  Future<void> playNotificationSound();
  Future<void> stop();
  Future<void> dispose();
}
```

---

## Event Flow Examples

### App Launch Flow

```
App Start
    ├─▶ SettingsBloc.LoadSettings
    ├─▶ HadithRepository.init()
    ├─▶ SchedulerBloc.StartScheduler (after settings load)
    └─▶ Check onboarding (show if first launch)
```

### Popup Display Flow

```
Scheduler fires
    ├─▶ HadithBloc.FetchRandomHadith (exclude history)
    ├─▶ PopupBloc.ShowPopup (with hadithId)
    ├─▶ HadithBloc.IncrementReadCount
    └─▶ If soundEnabled: AudioService.playNotificationSound()
```

### Settings Change Flow

```
User changes reminder interval
    ├─▶ SettingsBloc.UpdateReminderInterval
    ├─▶ SettingsRepository.saveSettings()
    ├─▶ SchedulerBloc.UpdateSchedulerInterval (via BlocListener)
    └─▶ Scheduler restarts with new interval
```

---

## Testing Contracts

### HadithBloc Tests

```dart
blocTest<HadithBloc, HadithState>(
  'emits HadithLoaded with history when fetch succeeds',
  build: () => hadithBloc,
  act: (bloc) => bloc.add(const FetchRandomHadith()),
  expect: () => [
    HadithLoading(),
    isA<HadithLoaded>()
      .having((s) => s.hadith, 'hadith', isNotNull)
      .having((s) => s.recentlyShownIds.length, 'history', greaterThan(0)),
  ],
);
```

### SchedulerBloc Tests

```dart
blocTest<SchedulerBloc, SchedulerState>(
  'restarts when interval changes',
  build: () => schedulerBloc,
  seed: () => SchedulerRunning(interval: ReminderInterval.oneHour),
  act: (bloc) => bloc.add(const UpdateSchedulerInterval(ReminderInterval.thirtyMinutes)),
  expect: () => [
    SchedulerRunning(interval: ReminderInterval.thirtyMinutes),
  ],
);
```

---

**Status**: Phase 1 Contracts Complete. All BLoC interfaces defined.
