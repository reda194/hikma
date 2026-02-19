# Data Model: Native Floating Hadith Popup

**Feature**: 002-native-popup
**Date**: 2026-02-19
**Status**: Complete

## Overview

This document defines the data entities and their relationships for the native popup feature.

---

## Entity Definitions

### 1. PopupPositionType (NEW)

**Purpose**: Enum representing user-configurable popup screen positions.

```dart
enum PopupPositionType {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,  // Default - follows macOS convention
  center,
}
```

**Attributes**:
- `name`: String (e.g., "bottomRight")
- `displayName`: Localized string for UI
- `defaultValue`: `bottomRight`

**Storage**: Persisted in UserSettings as enum index (int)

---

### 2. PopupDisplayDuration (NEW)

**Purpose**: User-configurable popup display duration in seconds.

```dart
class PopupDisplayDuration {
  final int seconds;  // Range: 4-30
  static const int min = 4;
  static const int max = 30;
  static const int defaultSeconds = 8;
}
```

**Attributes**:
- `seconds`: int (4-30 range, clamped)
- `defaultValue`: 8 seconds

**Storage**: Persisted in UserSettings as int

**Validation**:
```dart
int clampedDuration => seconds.clamp(PopupDisplayDuration.min, PopupDisplayDuration.max);
```

---

### 3. UserSettings (MODIFIED)

**Purpose**: Central user configuration storage.

**New Fields**:
```dart
class UserSettings extends Equatable {
  // Existing fields...
  final ReminderInterval reminderInterval;
  final PopupDuration popupDuration;  // Existing enum - consider replacing
  final HadithCollection sourceCollection;
  final FontSize fontSize;
  final bool soundEnabled;
  final bool autoStartEnabled;
  final bool showInDock;
  final bool darkModeEnabled;
  final PopupPosition? popupPosition;  // Existing - remove or migrate

  // NEW fields:
  final PopupPositionType popupPositionType;  // Replaces popupPosition
  final int popupDisplayDuration;  // Seconds (4-30)
}
```

**Migration Strategy**:
- Existing `popupPosition` (x,y coordinates) migrated to closest `popupPositionType`
- Existing `popupDuration` enum replaced with `popupDisplayDuration` int

**JSON Schema**:
```json
{
  "popupPositionType": 3,  // Index: 0=topLeft, 1=topRight, 2=bottomLeft, 3=bottomRight, 4=center
  "popupDisplayDuration": 8  // Seconds
}
```

---

### 4. PopupVisible State (MODIFIED)

**Purpose**: BLoC state when popup is displayed.

**Changes**:
```dart
class PopupVisible extends PopupState {
  // OLD:
  final String hadithId;  // Just ID
  final PopupPosition position;  // x,y coordinates
  final int remainingSeconds;

  // NEW:
  final Hadith hadith;  // Full hadith object
  final PopupPositionType positionType;
  final int remainingMillis;  // Milliseconds for smooth progress
  final bool isHovered;  // NEW - hover state
  final Duration displayDuration;
}
```

**Attributes**:
- `hadith`: Hadith - Complete hadith object (arabicText, narrator, sourceBook, etc.)
- `positionType`: PopupPositionType - User's configured position preference
- `remainingMillis`: int - Milliseconds until auto-dismiss (for smooth progress circle)
- `isHovered`: bool - Whether mouse cursor is over popup
- `displayDuration`: Duration - Total display duration (for timer calculations)
- `temporaryPosition`: Offset? - Current dragged position (not saved)

---

### 5. PopupEvent (MODIFIED)

**Purpose**: Events for popup state transitions.

**New Events**:
```dart
// Show popup with full hadith (MODIFIED from hadithId string)
class ShowPopup extends PopupEvent {
  final Hadith hadith;
  final PopupPositionType? positionType;
  final Duration? duration;
}

// Hover state changed (NEW)
class HoverChanged extends PopupEvent {
  final bool isHovered;
}

// Copy hadith to clipboard (NEW)
class CopyHadith extends PopupEvent {
  final Hadith hadith;
}

// Show next random hadith (NEW)
class ShowNextHadith extends PopupEvent {}

// Update temporary drag position (MODIFIED)
class UpdatePosition extends PopupEvent {
  final Offset offset;  // Temporary position (not saved)
}
```

---

### 6. PopupDisplayState (NEW)

**Purpose**: Runtime state of the popup window (not persisted).

**Attributes**:
```dart
class PopupDisplayState {
  final bool isVisible;
  final bool isHovered;
  final Duration remainingTime;
  final Hadith? currentHadith;
  final AnimationState animationState;
  final Offset? draggedPosition;
  final DateTime? appearedAt;
}
```

**Lifecycle**:
1. `isVisible` becomes true when ShowPopup event fires
2. `isHovered` toggles via HoverChanged events
3. `remainingTime` counts down until zero
4. `animationState` tracks entrance/exit animations
5. State resets when popup is dismissed

---

## Entity Relationships

```
UserSettings
    ├── PopupPositionType (1:1) ───> Determines popup location
    ├── PopupDisplayDuration (1:1) ──> Controls auto-dismiss timer
    └── PopupPosition (legacy) ────> Migrate to PopupPositionType

PopupBloc
    ├── manages ──> PopupVisible state
    ├── emits ───> ShowPopup, HoverChanged, CopyHadith, ShowNextHadith events
    └── consumes ─> UserSettings (from repository)

Hadith
    ├── displayed in ──> PopupVisible state
    ├── contains ───> arabicText, narrator, sourceBook, chapter
    └── copied via ──> CopyHadith event

SchedulerBloc
    ├── triggers ───> ShowPopup event (FIX: pass hadith.id)
    └── monitors ──> HadithBloc state for loaded hadith
```

---

## Data Flow Diagram

```
┌─────────────────┐
│  SchedulerBloc  │
│                 │
│ Timer expires   │──┐
└─────────────────┘  │
                     │ ShowPopup(hadith)
┌────────────────────▼──────────────┐
│          PopupBloc                 │
│                                    │
│  ┌──────────────────────────────┐ │
│  │  PopupVisible State          │ │
│  │  - hadith: Hadith            │ │
│  │  - positionType: Enum        │ │
│  │  - remainingMillis: int      │ │
│  │  - isHovered: bool           │ │
│  └──────────────────────────────┘ │
│                                    │
│  Events:                           │
│  - HoverChanged(bool)              │
│  - CopyHadith(Hadith)              │
│  - ShowNextHadith()                │
└────────────────────┬───────────────┘
                     │
┌────────────────────▼───────────────┐
│  NotificationPopup Widget           │
│                                    │
│  - Displays hadith.arabicText      │
│  - Shows progress circle           │
│  - Action buttons (Save, Copy,     │
│    Next) appear on hover           │
│  - Detects MouseRegion hover        │
└────────────────────┬───────────────┘
                     │ Platform Channel
┌────────────────────▼───────────────┐
│  Swift NSPanel                       │
│                                    │
│  - Native window                   │
│  - Frosted glass background        │
│  - Tracks hover state              │
│  - Positioned on cursor display   │
└────────────────────────────────────┘
```

---

## State Transitions

``                    ShowPopup(hadith)
                         │
                         ▼
┌─────────────────────────────────────┐
│       PopupVisible                   │
│  (hadith, positionType,              │
│   remainingMillis=8000, isHovered=false)│
└─────────────────────────────────────┘
                         │
         ┌───────────────┼───────────────┐
         │               │               │
    HoverChanged    Timer expires   DismissPopup
    (isHovered=true)  (remainingMillis=0)
         │               │               │
         ▼               │               │
    ┌─────────┐          │               │
    │ Paused  │          │               │
    └─────────┘          │               │
         │               │               │
    HoverChanged         │               │
    (isHovered=false)    │               │
         │               │               │
         └───────┬───────┘               │
                 │                       │
                 ▼                       ▼
         ┌─────────────────────┐   ┌──────────┐
         │  Countdown resumes  │   │ Popup    │
         │  Timer continues    │   │ Hidden    │
         └─────────────────────┘   └──────────┘
```

---

## Validation Rules

### PopupDisplayDuration
```dart
bool isValidDuration(int seconds) {
  return seconds >= 4 && seconds <= 30;
}
```

### Hadith Content
```dart
bool isValidHadith(Hadith hadith) {
  return hadith.arabicText.isNotEmpty &&
         hadith.narrator.isNotEmpty &&
         hadith.sourceBook.isNotEmpty &&
         hadith.id.isNotEmpty;
}
```

### Position Bounds
```dart
bool isValidPosition(NSPoint position, NSScreen screen) {
  let margin: CGFloat = 24;
  let popupWidth: CGFloat = 420;
  let popupHeight: CGFloat = 280;

  return position.x >= margin &&
         position.x <= screen.frame.width - popupWidth - margin &&
         position.y >= margin &&
         position.y <= screen.frame.height - popupHeight - margin;
}
```

---

## Migration Plan

### From Current Implementation

**Current State**:
- `PopupPosition` class with x,y coordinates
- `PopupDuration` enum (30s, 1m, 2m, 5m, Manual)
- `ShowPopup` event with hadithId string
- Scheduler passes empty hadithId

**Migration Steps**:
1. Add `PopupPositionType` enum
2. Add `popupPositionType` field to UserSettings
3. Add `popupDisplayDuration` int field to UserSettings
4. Modify `PopupVisible` state to use full Hadith object
5. Update `ShowPopup` event signature
6. Fix scheduler to pass hadith.id
7. Migrate existing user data (if any)
8. Remove deprecated fields after validation period

**Backward Compatibility**:
- Read old `popupPosition` x,y and infer closest `popupPositionType`
- Read old `popupDuration` enum and convert to seconds
- Default to bottom-right / 8 seconds if data missing
