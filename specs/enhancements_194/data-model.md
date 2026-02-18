# Data Model: Hikma App Enhancements

**Feature**: Hikma App Enhancements & Completion
**Date**: 2026-02-18
**Phase**: 1 - Design & Contracts

## Overview

This document defines all data entities for the enhancements feature. It extends existing models with new properties and introduces new entities for statistics, daily Hadith, and history tracking.

---

## Existing Models (Reference)

### Hadith
**Path**: `lib/data/models/hadith.dart`

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| id | String | Yes | Unique identifier (e.g., "bukhari-1-1") |
| arabicText | String | Yes | Arabic text of the Hadith |
| narrator | String | Yes | Narrator name |
| sourceBook | String | Yes | Source book name |
| chapter | String | Yes | Chapter reference |
| bookNumber | int | Yes | Book number in collection |
| hadithNumber | int | Yes | Hadith number within book |
| collection | HadithCollection | Yes | Collection enum value |

### HadithCollection (Enum)
**Path**: `lib/data/models/hadith_collection.dart`

| Value | Display Name | Arabic Name |
|-------|--------------|-------------|
| bukhari | Sahih Al-Bukhari | صحيح البخاري |
| muslim | Sahih Muslim | صحيح مسلم |
| abuDawud | Sunan Abu Dawud | سنن أبي داود |
| tirmidhi | Jami' Al-Tirmidhi | جامع الترمذي |
| ibnMajah | Sunan Ibn Majah | سنن ابن ماجه |
| nasai | Sunan Al-Nasa'i | سنن النسائي |
| all | All Collections | جميع المصادر |

### UserSettings
**Path**: `lib/data/models/user_settings.dart`

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| fontSize | FontSize | Yes | medium | Text display size |
| reminderInterval | ReminderInterval | Yes | oneHour | Time between popups |
| popupDuration | PopupDuration | Yes | thirtySeconds | How long popup shows |
| soundEnabled | bool | Yes | true | Play notification sound |
| autoStartEnabled | bool | Yes | false | Launch at login |
| showInDock | bool | Yes | false | Show Dock icon |
| sourceCollection | HadithCollection | Yes | all | Preferred source |
| popupPosition | PopupPosition? | No | null | Saved popup location |
| darkModeEnabled | bool | Yes | false | **NEW** Dark theme toggle |

### PopupPosition
**Path**: `lib/data/models/popup_position.dart`

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| dx | double | Yes | X coordinate from screen left |
| dy | double | Yes | Yes | Y coordinate from screen top |

### FontSize (Enum)
**Path**: `lib/data/models/user_settings.dart`

| Value | Display Label | Font Size (pt) |
|-------|---------------|----------------|
| small | Small | 22 |
| medium | Medium | 26 |
| large | Large | 30 |
| extraLarge | Extra Large | 36 |

### ReminderInterval (Enum)
**Path**: `lib/data/models/user_settings.dart`

| Value | Display Label | Duration (minutes) |
|-------|---------------|-------------------|
| fifteenMinutes | 15 minutes | 15 |
| thirtyMinutes | 30 minutes | 30 |
| oneHour | 1 hour | 60 |
| twoHours | 2 hours | 120 |
| fourHours | 4 hours | 240 |

### PopupDuration (Enum)
**Path**: `lib/data/models/user_settings.dart`

| Value | Display Label | Duration (seconds) |
|-------|---------------|-------------------|
| fifteenSeconds | 15 seconds | 15 |
| thirtySeconds | 30 seconds | 30 |
| oneMinute | 1 minute | 60 |
| twoMinutes | 2 minutes | 120 |
| manual | Manual | null (no auto-dismiss) |

---

## New Models

### ReadStatistics
**Path**: `lib/data/models/read_statistics.dart` (NEW)

Tracks daily and weekly Hadith reading statistics.

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| dailyReads | Map<String, int> | Yes | Date string → count (key: "YYYY-MM-DD") |

#### Validation Rules
- Date keys must be valid ISO date strings (YYYY-MM-DD)
- Count values must be non-negative integers
- Map must not be null (use empty map for no reads)

#### Helper Methods
```dart
int getTodayCount()      // Returns count for today's date
int getWeekCount()       // Returns sum of last 7 days
void incrementToday()    // Increments today's count by 1
```

#### Storage Format (Hive)
```
Key: "reads_2026-02-18" → Value: 5
Key: "reads_2026-02-17" → Value: 3
...
```

---

### DailyHadith
**Path**: `lib/data/models/daily_hadith.dart` (NEW)

Stores the featured Hadith of the day.

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| hadithId | String | Yes | ID of the featured Hadith |
| date | String | Yes | Date in YYYY-MM-DD format |

#### Validation Rules
- `hadithId` must match an existing Hadith ID in the dataset
- `date` must be valid ISO date string (YYYY-MM-DD)
- Date must not be in the future

#### Behavior
- If stored date != today's date → refresh with new Hadith
- If stored date == today's date → use stored Hadith

#### Storage Format (Hive)
```
Key: "daily_hadith_id" → Value: "bukhari-1-1"
Key: "daily_hadith_date" → Value: "2026-02-18"
```

---

### HadithHistory
**Path**: Integrated into `HadithBloc` state (NOT a separate model)

Tracks recently shown Hadith IDs to prevent repetition.

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| recentlyShownIds | List<String> | Yes | Last N Hadith IDs shown |

#### Validation Rules
- List size: 0-30 items (max 30 tracked)
- All IDs must be valid Hadith IDs from dataset
- List maintains insertion order (oldest first)

#### Behavior
- When new Hadith shown → append ID to list
- If list size > 30 → remove first (oldest) item
- When fetching random → exclude all IDs in list

#### Storage Format (Hive)
```
Key: "hadith_history" → Value: ["bukhari-1-1", "muslim-2-5", ...]
```

---

## BLoC State Extensions

### HadithState Updates

**Current state** (needs extension):
```dart
abstract class HadithState {}
class HadithInitial extends HadithState {}
class HadithLoading extends HadithState {}
class HadithLoaded extends HadithState {
  final Hadith hadith;
}
class HadithError extends HadithState {
  final String message;
}
```

**Extended state** (after enhancements):
```dart
class HadithLoaded extends HadithState {
  final Hadith hadith;
  final List<String> recentlyShownIds;  // NEW
  final Hadith? dailyHadith;            // NEW - Today's featured

  const HadithLoaded({
    required this.hadith,
    this.recentlyShownIds = const [],
    this.dailyHadith,
  });
}
```

### FavoritesState Updates

**Current state** (needs extension):
```dart
abstract class FavoritesState {}
class FavoritesInitial extends FavoritesState {}
class FavoritesLoaded extends FavoritesState {
  final List<Hadith> favorites;
}
```

**Extended state** (after enhancements):
```dart
class FavoritesLoaded extends FavoritesState {
  final List<Hadith> favorites;
  final String searchQuery;              // NEW

  List<Hadith> get displayedFavorites {  // NEW - filtered list
    if (searchQuery.isEmpty) return favorites;
    // ... filtering logic
  }

  const FavoritesLoaded({
    required this.favorites,
    this.searchQuery = '',
  });
}
```

### PopupState Updates

**Current state** (already has remainingSeconds, verify visual display):
```dart
class PopupVisible extends PopupState {
  final String hadithId;
  final int remainingSeconds;  // Already exists
  final bool isDismissible;
}
```

**No changes needed** - just ensure UI uses `remainingSeconds` for progress bar.

---

## Hive Box Structure

### Box: settings_box
| Key | Type | Description |
|-----|------|-------------|
| user_settings | UserSettings | Main settings object |
| daily_hadith_id | String | Today's featured Hadith ID |
| daily_hadith_date | String | Today's date (YYYY-MM-DD) |
| hadith_history | List<String> | Recently shown Hadith IDs |
| popup_position | PopupPosition | Saved popup coordinates |
| has_seen_onboarding | bool | First-launch flag |

### Box: favorites_box
| Key | Type | Description |
|-----|------|-------------|
| favorites | List<String> | List of favorited Hadith IDs |

### Box: statistics_box
| Key Pattern | Type | Description |
|------------|------|-------------|
| reads_YYYY-MM-DD | int | Read count for specific date |

---

## Entity Relationships

```
UserSettings
    ├── FontSize (enum)
    ├── ReminderInterval (enum)
    ├── PopupDuration (enum)
    ├── HadithCollection (enum)
    └── PopupPosition ────┐
                          │
Hadith ──────────────────┤
    ├── id (PK)          │
    ├── collection ──────┘
    └── ...other fields
         │
         ├── HadithHistory (list of IDs) ┈┈┈▶ Hadith
         ├── DailyHadith.hadithId ───────────▶ Hadith
         └── Favorites (list of IDs) ┈┈┈┈┈▶ Hadith

ReadStatistics
    └── dailyReads: Map<Date, Count>
```

---

## JSON Schema for Hadith Dataset

```json
{
  "hadiths": [
    {
      "id": "string (required, unique, format: {collection}-{book}-{hadith})",
      "arabicText": "string (required, non-empty)",
      "narrator": "string (required, non-empty)",
      "sourceBook": "string (required, matches collection display name)",
      "chapter": "string (required)",
      "bookNumber": "integer (required, >= 1)",
      "hadithNumber": "integer (required, >= 1)",
      "collection": "string (required, one of: bukhari, muslim, abuDawud, tirmidhi, ibnMajah, nasai)"
    }
  ]
}
```

### Validation Constraints
- Total count: 200 Hadiths (minimum)
- No duplicate `id` values
- All `arabicText` must be valid UTF-8 Arabic
- `collection` values must match enum options
- First Hadith: Replace corrupted entry with "إنما الأعمال بالنيات"

---

## Migration Requirements

No database migrations needed (Hive is schemaless). However:

1. **Existing users**: On first launch after update:
   - Add `darkModeEnabled` default: `false`
   - Initialize empty `hadith_history` if missing
   - Initialize empty `dailyReads` map if missing

2. **New installs**: All features available immediately

---

## Data Access Patterns

### Reading Hadiths
```dart
// Try cache first, fallback to bundled JSON, last resort API
hadith = await repository.fetchRandom(excludeIds: history);
```

### Saving Favorites
```dart
// Append ID to list, persist to Hive
await repository.addFavorite(hadith.id);
```

### Updating Statistics
```dart
// Increment today's counter
final today = DateTime.now().toIso8601String().substring(0, 10);
final count = statisticsBox.get('reads_$today', defaultValue: 0) + 1;
statisticsBox.put('reads_$today', count);
```

---

**Status**: Phase 1 Data Model Complete. Ready for contracts generation.
