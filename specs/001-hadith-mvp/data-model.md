# Phase 1: Data Model

**Feature**: Hikma MVP - Hadith Reminder App for macOS
**Date**: 2026-02-18
**Status**: Complete

---

## Overview

This document defines all data entities used in Hikma, their relationships, validation rules, and state transitions for BLoC implementations.

---

## Entity Definitions

### 1. Hadith

Represents a single Prophetic narration with its content and metadata.

#### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String | Yes | Unique identifier (e.g., "bukhari-1-1") |
| arabicText | String | Yes | Full Hadith text in Arabic |
| narrator | String | Yes | Narrator name (e.g., "عمر بن الخطاب") |
| sourceBook | String | Yes | Source collection name (e.g., "Sahih Al-Bukhari") |
| chapter | String | Yes | Chapter reference |
| bookNumber | int | Yes | Book number within collection |
| hadithNumber | int | Yes | Hadith number within book |
| collection | HadithCollection | Yes | Enum value for source collection |

#### Validation Rules

- `arabicText` must not be empty
- `sourceBook` must be one of the six authentic collections
- `bookNumber` and `hadithNumber` must be positive integers
- `id` must be unique across all Hadith instances

#### Dart Implementation

```dart
class Hadith extends Equatable {
  final String id;
  final String arabicText;
  final String narrator;
  final String sourceBook;
  final String chapter;
  final int bookNumber;
  final int hadithNumber;
  final HadithCollection collection;

  const Hadith({
    required this.id,
    required this.arabicText,
    required this.narrator,
    required this.sourceBook,
    required this.chapter,
    required this.bookNumber,
    required this.hadithNumber,
    required this.collection,
  });

  Hadith copyWith({ ... }) { ... }

  @override
  List<Object?> get props => [id, arabicText, narrator, sourceBook, chapter, bookNumber, hadithNumber, collection];
}
```

---

### 2. HadithCollection

Enum representing the six authentic collections (Kutub al-Sittah).

#### Values

| Value | Arabic Name | Display Name |
|-------|-------------|--------------|
| bukhari | صحيح البخاري | Sahih Al-Bukhari |
| muslim | صحيح مسلم | Sahih Muslim |
| abuDawud | سنن أبي داود | Sunan Abu Dawud |
| tirmidhi | جامع الترمذي | Jami' Al-Tirmidhi |
| ibnMajah | سنن ابن ماجه | Sunan Ibn Majah |
| nasai | سنن النسائي | Sunan Al-Nasa'i |
| all | جميع الكتب | All Collections |

#### Dart Implementation

```dart
enum HadithCollection {
  bukhari,
  muslim,
  abuDawud,
  tirmidhi,
  ibnMajah,
  nasai,
  all;

  String get displayName {
    switch (this) {
      case HadithCollection.bukhari: return 'Sahih Al-Bukhari';
      case HadithCollection.muslim: return 'Sahih Muslim';
      case HadithCollection.abuDawud: return 'Sunan Abu Dawud';
      case HadithCollection.tirmidhi: return 'Jami\' Al-Tirmidhi';
      case HadithCollection.ibnMajah: return 'Sunan Ibn Majah';
      case HadithCollection.nasai: return 'Sunan Al-Nasa\'i';
      case HadithCollection.all: return 'All Collections';
    }
  }

  String get arabicName {
    switch (this) {
      case HadithCollection.bukhari: return 'صحيح البخاري';
      case HadithCollection.muslim: return 'صحيح مسلم';
      case HadithCollection.abuDawud: return 'سنن أبي داود';
      case HadithCollection.tirmidhi: return 'جامع الترمذي';
      case HadithCollection.ibnMajah: return 'سنن ابن ماجه';
      case HadithCollection.nasai: return 'سنن النسائي';
      case HadithCollection.all: return 'جميع الكتب';
    }
  }

  String get apiValue {
    switch (this) {
      case HadithCollection.bukhari: return 'bukhari';
      case HadithCollection.muslim: return 'muslim';
      case HadithCollection.abuDawud: return 'abudawud';
      case HadithCollection.tirmidhi: return 'tirmidhi';
      case HadithCollection.ibnMajah: return 'ibnmajah';
      case HadithCollection.nasai: return 'nasai';
      case HadithCollection.all: return 'all';
    }
  }
}
```

---

### 3. UserSettings

Represents the user's configuration preferences.

#### Fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| reminderInterval | ReminderInterval | Yes | 1 hour | How often to show popup |
| popupDuration | PopupDuration | Yes | 2 minutes | How long popup stays visible |
| sourceCollection | HadithCollection | Yes | all | Which Hadith collection to display |
| fontSize | FontSize | Yes | Large | Arabic text font size |
| soundEnabled | bool | Yes | false | Play sound when popup appears |
| autoStartEnabled | bool | Yes | true | Start app on system login |
| showInDock | bool | Yes | false | Show app icon in Dock |
| popupPosition | Offset? | No | null | Last saved popup position |

#### Enums

```dart
enum ReminderInterval {
  minutes30,
  hour1,
  hours2,
  hours4,
  hours8,
  daily;

  Duration get duration {
    switch (this) {
      case ReminderInterval.minutes30: return Duration(minutes: 30);
      case ReminderInterval.hour1: return Duration(hours: 1);
      case ReminderInterval.hours2: return Duration(hours: 2);
      case ReminderInterval.hours4: return Duration(hours: 4);
      case ReminderInterval.hours8: return Duration(hours: 8);
      case ReminderInterval.daily: return Duration(days: 1);
    }
  }
}

enum PopupDuration {
  seconds30,
  minute1,
  minutes2,
  minutes5,
  manual;

  Duration? get duration {
    switch (this) {
      case PopupDuration.seconds30: return Duration(seconds: 30);
      case PopupDuration.minute1: return Duration(minutes: 1);
      case PopupDuration.minutes2: return Duration(minutes: 2);
      case PopupDuration.minutes5: return Duration(minutes: 5);
      case PopupDuration.manual: return null; // No auto-dismiss
    }
  }
}

enum FontSize {
  small,
  medium,
  large,
  extraLarge;

  double get size {
    switch (this) {
      case FontSize.small: return 18.0;
      case FontSize.medium: return 22.0;
      case FontSize.large: return 26.0;
      case FontSize.extraLarge: return 32.0;
    }
  }
}
```

#### Dart Implementation

```dart
class UserSettings extends Equatable {
  final ReminderInterval reminderInterval;
  final PopupDuration popupDuration;
  final HadithCollection sourceCollection;
  final FontSize fontSize;
  final bool soundEnabled;
  final bool autoStartEnabled;
  final bool showInDock;
  final Offset? popupPosition;

  const UserSettings({
    this.reminderInterval = ReminderInterval.hour1,
    this.popupDuration = PopupDuration.minutes2,
    this.sourceCollection = HadithCollection.all,
    this.fontSize = FontSize.large,
    this.soundEnabled = false,
    this.autoStartEnabled = true,
    this.showInDock = false,
    this.popupPosition,
  });

  UserSettings copyWith({
    ReminderInterval? reminderInterval,
    PopupDuration? popupDuration,
    HadithCollection? sourceCollection,
    FontSize? fontSize,
    bool? soundEnabled,
    bool? autoStartEnabled,
    bool? showInDock,
    Offset? popupPosition,
  }) {
    return UserSettings(
      reminderInterval: reminderInterval ?? this.reminderInterval,
      popupDuration: popupDuration ?? this.popupDuration,
      sourceCollection: sourceCollection ?? this.sourceCollection,
      fontSize: fontSize ?? this.fontSize,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      autoStartEnabled: autoStartEnabled ?? this.autoStartEnabled,
      showInDock: showInDock ?? this.showInDock,
      popupPosition: popupPosition ?? this.popupPosition,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reminderInterval': reminderInterval.index,
      'popupDuration': popupDuration.index,
      'sourceCollection': sourceCollection.index,
      'fontSize': fontSize.index,
      'soundEnabled': soundEnabled,
      'autoStartEnabled': autoStartEnabled,
      'showInDock': showInDock,
      'popupPosition': popupPosition != null
          ? {'dx': popupPosition!.dx, 'dy': popupPosition!.dy}
          : null,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      reminderInterval: ReminderInterval.values[json['reminderInterval'] ?? 1],
      popupDuration: PopupDuration.values[json['popupDuration'] ?? 2],
      sourceCollection: HadithCollection.values[json['sourceCollection'] ?? 6],
      fontSize: FontSize.values[json['fontSize'] ?? 2],
      soundEnabled: json['soundEnabled'] ?? false,
      autoStartEnabled: json['autoStartEnabled'] ?? true,
      showInDock: json['showInDock'] ?? false,
      popupPosition: json['popupPosition'] != null
          ? Offset(
              json['popupPosition']['dx']?.toDouble() ?? 0,
              json['popupPosition']['dy']?.toDouble() ?? 0,
            )
          : null,
    );
  }

  @override
  List<Object?> get props => [
        reminderInterval,
        popupDuration,
        sourceCollection,
        fontSize,
        soundEnabled,
        autoStartEnabled,
        showInDock,
        popupPosition,
      ];
}
```

---

### 4. Favorite

Represents a Hadith that the user has bookmarked for later access.

#### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| hadith | Hadith | Yes | The favorited Hadith |
| savedAt | DateTime | Yes | When the Hadith was saved |

#### Dart Implementation

```dart
class Favorite extends Equatable {
  final Hadith hadith;
  final DateTime savedAt;

  const Favorite({
    required this.hadith,
    required this.savedAt,
  });

  Favorite copyWith({ Hadith? hadith, DateTime? savedAt }) {
    return Favorite(
      hadith: hadith ?? this.hadith,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hadithId': hadith.id,
      'savedAt': savedAt.toIso8601String(),
      // Hadith data serialized separately
    };
  }

  factory Favorite.fromJson(Map<String, dynamic> json, Hadith hadith) {
    return Favorite(
      hadith: hadith,
      savedAt: DateTime.parse(json['savedAt']),
    );
  }

  @override
  List<Object?> get props => [hadith, savedAt];
}
```

---

## Entity Relationships

```
┌─────────────────┐
│  Hadith         │
│  - id           │───┐
│  - arabicText   │   │
│  - narrator     │   │ 1
│  - sourceBook   │   │
│  - chapter      │   │
│  - collection   │───┘
└─────────────────┘
         │
         │ 1..*
         │
         ▼
┌─────────────────┐       ┌─────────────────┐
│  Favorite       │       │ UserSettings    │
│  - hadith (FK)  │       │ - interval      │
│  - savedAt      │       │ - duration      │
└─────────────────┘       │ - collection    │
                          │ - fontSize      │
                          │ - soundEnabled  │
                          │ - popupPosition │
                          └─────────────────┘
```

---

## BLoC State Definitions

### HadithBloc States

```dart
abstract class HadithState extends Equatable {
  const HadithState();
}

class HadithInitial extends HadithState {
  @override
  List<Object?> get props => [];
}

class HadithLoading extends HadithState {
  @override
  List<Object?> get props => [];
}

class HadithLoaded extends HadithState {
  final Hadith hadith;
  final bool isFavorite;

  const HadithLoaded(this.hadith, {this.isFavorite = false});

  @override
  List<Object?> get props => [hadith, isFavorite];
}

class HadithError extends HadithState {
  final String message;

  const HadithError(this.message);

  @override
  List<Object?> get props => [message];
}
```

### SchedulerBloc States

```dart
abstract class SchedulerState extends Equatable {
  const SchedulerState();
}

class SchedulerInitial extends SchedulerState {
  @override
  List<Object?> get props => [];
}

class SchedulerRunning extends SchedulerState {
  final DateTime nextPopupTime;

  const SchedulerRunning(this.nextPopupTime);

  @override
  List<Object?> get props => [nextPopupTime];
}

class SchedulerStopped extends SchedulerState {
  @override
  List<Object?> get props => [];
}
```

### FavoritesBloc States

```dart
abstract class FavoritesState extends Equatable {
  const FavoritesState();
}

class FavoritesInitial extends FavoritesState {
  @override
  List<Object?> get props => [];
}

class FavoritesLoading extends FavoritesState {
  @override
  List<Object?> get props => [];
}

class FavoritesLoaded extends FavoritesState {
  final List<Favorite> favorites;

  const FavoritesLoaded(this.favorites);

  @override
  List<Object?> get props => [favorites];
}
```

### SettingsBloc States

```dart
abstract class SettingsState extends Equatable {
  const SettingsState();
}

class SettingsInitial extends SettingsState {
  @override
  List<Object?> get props => [];
}

class SettingsLoaded extends SettingsState {
  final UserSettings settings;

  const SettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}
```

### PopupBloc States

```dart
abstract class PopupState extends Equatable {
  const PopupState();
}

class PopupHidden extends PopupState {
  @override
  List<Object?> get props => [];
}

class PopupVisible extends PopupState {
  final Hadith hadith;
  final int remainingSeconds;
  final bool isAutoDismiss;

  const PopupVisible(
    this.hadith, {
    this.remainingSeconds = 0,
    this.isAutoDismiss = true,
  });

  @override
  List<Object?> get props => [hadith, remainingSeconds, isAutoDismiss];
}
```

---

## State Transition Diagrams

### HadithBloc

```
                    FetchRandomHadith
                         │
                         ▼
┌──────────────┐    ┌──────────┐    ┌──────────────┐
│ HadithInitial│───→│HadithLoad│───→│ HadithLoaded │
└──────────────┘    │  ing     │    └──────────────┘
                   └──────────┘           │
                       │                  │
                       │ Error            │ FilterChanged
                       ▼                  ▼
                   ┌──────────┐    ┌──────────────┐
                   │HadithError│───→│ HadithLoaded │
                   └──────────┘    └──────────────┘
```

### SchedulerBloc

```
                       StartScheduler
                            │
                            ▼
┌────────────────┐    ┌──────────────┐
│SchedulerInitial│───→│SchedulerRun │
└────────────────┘    │    ning     │
                      └──────────────┘
                            │
              ┌─────────────┼─────────────┐
              ▼             ▼             ▼
        SettingsChanged  IntervalEnd   StopScheduler
              │             │             │
              └─────────────┴─────────────┘
                            │
                            ▼
                      ┌──────────────┐
                      │SchedulerStop │
                      │    ped       │
                      └──────────────┘
```

### PopupBloc

```
                      ShowPopup
                          │
                          ▼
┌──────────────┐    ┌──────────────┐
│ PopupHidden  │───→│ PopupVisible │
└──────────────┘    │ (counting)   │
                      └──────────────┘
                            │
                   ┌────────┴────────┐
                   ▼                 ▼
            TimerElapsed       Dismiss
                   │                 │
                   ▼                 ▼
           PopupVisible      ┌──────────────┐
           (countdown)       │ PopupHidden  │
                              └──────────────┘
```

### FavoritesBloc

```
                      LoadFavorites
                           │
                           ▼
┌───────────────┐    ┌─────────────┐
│FavoritesInit  │───→│Favorites    │
│   ial         │    │  Loading    │
└───────────────┘    └─────────────┘
                           │
                    ┌──────┴──────┐
                    ▼             ▼
              Success         Error
                    │             │
                    ▼             ▼
            ┌─────────────┐  ┌─────────────┐
            │Favorites    │  │Favorites    │
            │  Loaded     │  │  Error      │
            └─────────────┘  └─────────────┘
                    │
        ┌───────────┼───────────┐
        ▼           ▼           ▼
    AddFavorite RemoveFav  ToggleFav
        │           │           │
        └───────────┴───────────┘
                    │
                    ▼
            ┌─────────────┐
            │Favorites    │
            │  Loaded     │
            │ (updated)   │
            └─────────────┘
```

---

## Storage Schema

### Hive Box Structure

```dart
// Box: 'settings'
{
  'reminder_interval': 1,  // ReminderInterval index
  'popup_duration': 2,     // PopupDuration index
  'source_collection': 6,  // HadithCollection index
  'font_size': 2,          // FontSize index
  'sound_enabled': false,
  'auto_start': true,
  'show_in_dock': false,
  'popup_position': {'dx': 100.0, 'dy': 100.0}  // or null
}

// Box: 'favorites'
{
  'fav_001': {  // Key is hadith ID
    'hadith': { ... },  // Full Hadith serialized
    'saved_at': '2026-02-18T10:30:00Z'
  },
  'fav_002': { ... },
  ...
}

// Box: 'cache'  // For API-fetched Hadiths
{
  'hadith_001': { ... },  // Cached Hadith
  'hadith_002': { ... },
  ...
}
```

---

## Next Steps

With data model complete, proceed to:
- [ ] Create contracts/ directory with API schemas
- [ ] Write quickstart.md with developer setup guide
- [ ] Run `/speckit.tasks` for implementation task breakdown

---

*Data Model Document v1.0 | Last Updated: 2026-02-18*
