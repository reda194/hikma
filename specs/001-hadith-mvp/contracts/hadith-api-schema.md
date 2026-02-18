# API Contracts

**Feature**: Hikma MVP - Hadith Reminder App for macOS
**Date**: 2026-02-18

---

## Overview

This document defines all external API contracts and data formats used in Hikma.

---

## 1. External Hadith API

### Base URL

```
https://api.hadith.gading.dev
```

### Endpoints

#### Get Books in Collection

```
GET /books/{collection}
```

**Path Parameters:**
- `collection`: One of `bukhari`, `muslim`, `abudawud`, `tirmidhi`, `ibnmajah`, `nasai`

**Response:**

```json
{
  "data": [
    {
      "bookNumber": 1,
      "bookName": "Revelation"
    },
    {
      "bookNumber": 2,
      "bookName": "Belief"
    }
  ]
}
```

#### Get Hadiths from Book

```
GET /books/{collection}/{bookNumber}
```

**Path Parameters:**
- `collection`: One of the six collections
- `bookNumber`: Book number (integer)

**Query Parameters:**
- `limit`: Optional, number of Hadiths to return (default: 50)
- `offset`: Optional, pagination offset (default: 0)

**Response:**

```json
{
  "data": [
    {
      "id": "bukhari-1-1",
      "hadithNumber": 1,
      "bookNumber": 1,
      "collection": "bukhari",
      "arabic": "حدثنا الحميدي عبد الله بن محمد...",
      "english": "Narrated by 'Umar bin Al-Khattab...",
      "chapter": "How the Divine Revelation started to be revealed to Allah's Apostle",
      "narrator": "عمر بن الخطاب",
      "grades": [
        {
          "graded_by": "Darussalam",
          "grade": "Sahih"
        }
      ]
    }
  ],
  "pagination": {
    "total": 100,
    "limit": 50,
    "offset": 0,
    "nextPage": "/books/bukhari/1?limit=50&offset=50"
  }
}
```

#### Get Random Hadith

```
GET /books/{collection}/random
```

**Path Parameters:**
- `collection`: One of `all`, `bukhari`, `muslim`, `abudawud`, `tirmidhi`, `ibnmajah`, `nasai`

**Response:**

```json
{
  "data": {
    "id": "bukhari-1-1",
    "hadithNumber": 1,
    "bookNumber": 1,
    "collection": "bukhari",
    "arabic": "حدثنا الحميدي عبد الله بن محمد...",
    "english": "Narrated by 'Umar bin Al-Khattab...",
    "chapter": "How the Divine Revelation started to be revealed to Allah's Apostle",
    "narrator": "عمر بن الخطاب"
  }
}
```

### Error Responses

All error responses follow this format:

```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Book not found"
  }
}
```

---

## 2. Bundled JSON Format

### File Location

```
assets/data/hadiths.json
```

### Schema

```json
{
  "metadata": {
    "version": "1.0",
    "count": 250,
    "lastUpdated": "2026-02-18",
    "source": "Curated from authentic collections"
  },
  "collections": [
    {
      "name": "bukhari",
      "displayName": "Sahih Al-Bukhari",
      "arabicName": "صحيح البخاري",
      "count": 50
    },
    {
      "name": "muslim",
      "displayName": "Sahih Muslim",
      "arabicName": "صحيح مسلم",
      "count": 50
    }
  ],
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

---

## 3. Hive Storage Schema

### Settings Box

**Box Name:** `settings`

**Key-Value Pairs:**

```dart
{
  'reminder_interval': 1,           // int (ReminderInterval index)
  'popup_duration': 2,              // int (PopupDuration index)
  'source_collection': 6,           // int (HadithCollection index)
  'font_size': 2,                   // int (FontSize index)
  'sound_enabled': false,           // bool
  'auto_start': true,               // bool
  'show_in_dock': false,            // bool
  'popup_position': {               // Map or null
    'dx': 100.0,
    'dy': 100.0
  }
}
```

### Favorites Box

**Box Name:** `favorites`

**Key-Value Pairs (Key = Hadith ID):**

```dart
{
  'bukhari-1-1': {
    'hadith': {
      'id': 'bukhari-1-1',
      'arabicText': '...',
      'narrator': 'عمر بن الخطاب',
      'sourceBook': 'Sahih Al-Bukhari',
      'chapter': 'كيف كان بدء الوحي',
      'bookNumber': 1,
      'hadithNumber': 1,
      'collection': 'bukhari'
    },
    'savedAt': '2026-02-18T10:30:00Z'
  }
}
```

### Cache Box

**Box Name:** `cache`

For caching API-fetched Hadiths:

```dart
{
  'cached_bukhari-1-1': {
    'hadith': { ... },
    'cachedAt': '2026-02-18T10:30:00Z',
    'expiresAt': '2026-02-25T10:30:00Z'
  }
}
```

---

## 4. Internal BLoC Events

### HadithBloc Events

```dart
abstract class HadithEvent {}

class FetchRandomHadith extends HadithEvent {
  final HadithCollection collection;
}

class FilterByCollection extends HadithEvent {
  final HadithCollection collection;
}

class CacheHadith extends HadithEvent {
  final Hadith hadith;
}

class CheckFavoriteStatus extends HadithEvent {
  final String hadithId;
}
```

### SchedulerBloc Events

```dart
abstract class SchedulerEvent {}

class StartScheduler extends SchedulerEvent {}

class StopScheduler extends SchedulerEvent {}

class ResetTimer extends SchedulerEvent {}

class SettingsChanged extends SchedulerEvent {
  final UserSettings settings;
}
```

### FavoritesBloc Events

```dart
abstract class FavoritesEvent {}

class LoadFavorites extends FavoritesEvent {}

class AddFavorite extends FavoritesEvent {
  final Hadith hadith;
}

class RemoveFavorite extends FavoritesEvent {
  final String hadithId;
}

class ToggleFavorite extends FavoritesEvent {
  final Hadith hadith;
}

class IsFavorite extends FavoritesEvent {
  final String hadithId;
}
```

### SettingsBloc Events

```dart
abstract class SettingsEvent {}

class LoadSettings extends SettingsEvent {}

class UpdateSettings extends SettingsEvent {
  final UserSettings settings;
}

class UpdateReminderInterval extends SettingsEvent {
  final ReminderInterval interval;
}

class UpdatePopupDuration extends SettingsEvent {
  final PopupDuration duration;
}

class UpdateSourceCollection extends SettingsEvent {
  final HadithCollection collection;
}

class UpdateFontSize extends SettingsEvent {
  final FontSize fontSize;
}

class ToggleSound extends SettingsEvent {}

class ToggleAutoStart extends SettingsEvent {}

class ToggleShowInDock extends SettingsEvent {}
```

### PopupBloc Events

```dart
abstract class PopupEvent {}

class ShowPopup extends PopupEvent {
  final Hadith? hadith;  // null = fetch random
}

class HidePopup extends PopupEvent {}

class DismissPopup extends PopupEvent {}

class StartAutoDismiss extends PopupEvent {
  final int seconds;
}

class UpdatePosition extends PopupEvent {
  final Offset position;
}
```

---

## 5. UI Widget Props

### HadithCard Props

```dart
class HadithCardProps extends Equatable {
  final String arabicText;
  final String narrator;
  final String sourceBook;
  final String chapter;
  final FontSize fontSize;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onDismiss;
}
```

### SettingsScreen Props

```dart
class SettingsScreenProps extends Equatable {
  final UserSettings settings;
  final Function(ReminderInterval) onIntervalChange;
  final Function(PopupDuration) onDurationChange;
  final Function(HadithCollection) onCollectionChange;
  final Function(FontSize) onFontSizeChange;
  final Function(bool) onSoundToggle;
  final Function(bool) onAutoStartToggle;
  final Function(bool) onShowInDockToggle;
}
```

---

*API Contracts v1.0 | Last Updated: 2026-02-18*
