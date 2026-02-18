# Hikma — حكمة | Development Roadmap
**Last Updated:** February 2026  
**Status:** Architecture Complete — Needs Runtime & Content Work  
**Author:** Reda Abd El Jalil

---

## Overview

Hikma is a macOS desktop app (Flutter + BLoC) that delivers authentic Hadith through non-intrusive floating popups. The architecture is solid — 5 BLoCs, offline-first data layer, frosted glass popup, menu bar integration. What needs work is making it actually run correctly, expanding content, and adding the missing user-facing features.

This document covers everything: critical bugs, missing features, UX improvements, and ideas beyond the original PRD.

---

## 🔴 CRITICAL — Fix First (App Won't Work Without These)

### [C-01] Auto-start the Scheduler on App Launch
**Problem:** `SchedulerBloc` and `StartScheduler()` exist and work, but nothing calls them when the app starts. The popup will never appear.  
**Fix:** In `_HikmaHomeState._initialize()`, after settings load, dispatch:
```dart
widget.schedulerBloc.add(const StartScheduler());
```
Also wire the `SchedulerBloc` to listen to `SettingsBloc` — when the user changes the reminder interval, the scheduler must restart with the new interval.

---

### [C-02] Hadith Dataset Is Too Small (10 vs. 200–500 Target)
**Problem:** `assets/data/hadiths.json` contains only **10 Hadiths** (5 Bukhari, 5 Muslim). The app will repeat the same Hadiths constantly when offline. The PRD target is 200–500 curated Hadiths.  
**Fix:** Expand the JSON dataset with:
- Sahih Al-Bukhari — at least 50 Hadiths
- Sahih Muslim — at least 50 Hadiths  
- Sunan Abu Dawud — at least 30 Hadiths
- Jami' Al-Tirmidhi — at least 30 Hadiths
- Sunan Ibn Majah — at least 20 Hadiths
- Sunan Al-Nasa'i — at least 20 Hadiths  

JSON format per Hadith:
```json
{
  "id": "bukhari-1-1",
  "arabicText": "...",
  "narrator": "...",
  "sourceBook": "Sahih Al-Bukhari",
  "chapter": "...",
  "bookNumber": 1,
  "hadithNumber": 1,
  "collection": "bukhari"
}
```
**Note:** The current 10-entry dataset also has a corrupted first Hadith (text is mixed/garbled). Fix it.

---

### [C-03] Resolve Popup Architecture Conflict
**Problem:** There are 3 popup implementations that partially conflict:
1. `HadithPopup` — uses `window_manager` as a separate floating window
2. `HadithPopupDialog` — a Material Dialog overlay
3. `HadithPopupOverlay` — full-screen push route (currently wired in `main.dart`)

`main.dart` uses `HadithPopupOverlay` (option 3), but `PopupBloc` and `HadithPopup` (option 1) are designed around a separate window that lives outside the main app window. This causes confusion.  

**Decision needed:**
- **Option A (recommended):** Keep `HadithPopupOverlay` for now (simpler, no window management issues), delete the unused `HadithPopup` window class. Re-add it in a later phase when floating window behavior is fully tested.
- **Option B:** Commit to `window_manager` approach — requires more platform testing but gives true floating behavior.

---

### [C-04] `HadithRepository.init()` Is Never Called
**Problem:** `HadithRepository` has an `init()` method that opens the cache Hive box and pre-loads local Hadiths. It is never called — the repository initializes without this setup, which may cause null reference errors on cache access.  
**Fix:** Call `_hadithRepository.init()` in `_initializeRepositories()` or in `_HikmaHomeState._initialize()`.

---

### [C-05] Run Flutter Analyze + Fix All Errors
**Problem:** The project has not been compiled or analyzed. There may be type errors, missing method signatures, or version conflicts (especially with `flutter_acrylic`, `system_tray`, and `window_manager` on the current Flutter/macOS SDK).  
**Steps:**
```bash
cd /Users/reda_abdel_galil/Downloads/hikma
flutter pub get
flutter analyze
flutter build macos --debug
```
Resolve all errors before any other development.

---

## 🟡 IMPORTANT — Core Features from PRD Not Yet Built

### [F-01] Hadith History / No-Repeat Logic
**Problem:** Currently, every popup picks a random Hadith from the pool with no memory. The user may see the same Hadith 3 times in a row.  
**Fix:** Add a `recentlyShownIds` list (last 20-50 IDs) to `HadithBloc` state. When fetching a random Hadith locally, exclude IDs already in this list. Persist it in Hive so it survives app restarts.

---

### [F-02] Daily Featured Hadith
One special Hadith pinned for the entire day — separate from the scheduled reminders. Accessible from the menu bar as "Today's Hadith."  
**Implementation:**
- Store `dailyHadith` + `dailyHadithDate` in Hive
- On each app launch, if stored date ≠ today → pick a new Hadith and store it
- Expose it via `HadithBloc` with a `LoadDailyHadith` event
- Show it in the menu bar as a quick-view item

---

### [F-03] Hadith Read Counter (Daily + Weekly Stats)
Show the user how many Hadiths they've seen today and this week.  
**Implementation:**
- In `HadithBloc`, when a popup is shown, increment a counter stored in Hive
- Track by date key: `"reads_2026-02-18": 5`
- Display in Settings screen or a small status widget in the menu bar
- Weekly total: sum the last 7 days

---

### [F-04] Contemplation Mode (Full-Screen Calm View)
A manually triggered full-screen, distraction-free Hadith reading experience. Triggered from the menu bar.  
**Design:**
- Full window, dark or cream background
- Large Arabic text centered on screen
- Soft gradient background (navy to deep teal)
- Bookmark button + "Next Hadith" button
- Press Escape or click anywhere to exit
- Gentle fade-in animation

---

### [F-05] Auto-Launch on Login (Wire Up the Package)
`launch_at_login` package is already in `pubspec.yaml` but is not wired to the `ToggleAutoStart` settings event.  
**Fix:** In `SettingsBloc`, when `ToggleAutoStart` is dispatched:
```dart
import 'package:launch_at_login/launch_at_login.dart';
LaunchAtLogin.setLaunchAtLogin(event.enabled);
```

---

### [F-06] Keyboard Shortcut to Trigger Popup (Wire Up the Package)
`hotkey_manager` package is in `pubspec.yaml` but unused.  
**Suggested shortcut:** `⌘ + Shift + H` → immediately shows a Hadith popup.  
**Implementation:** Register the hotkey in `MenuBarManager.init()`:
```dart
await hotKeyManager.register(
  HotKey(KeyCode.keyH, modifiers: [KeyModifier.meta, KeyModifier.shift]),
  keyDownHandler: (_) => hadithBloc.add(const FetchRandomHadith()),
);
```

---

### [F-07] Notification Sound (Wire Up the Package)
`audioplayers` package is in `pubspec.yaml` but unused. The `soundEnabled` setting exists in `UserSettings`.  
**Fix:** When a popup is triggered and `settings.soundEnabled == true`, play a soft notification sound (include a default `.mp3` or `.wav` file in `assets/`). Keep it under 1 second — subtle.

---

### [F-08] Popup Progress Bar (Auto-Dismiss Countdown)
The `PopupBloc` tracks `remainingSeconds` but `PopupContent` may not visually show it.  
**Fix:** Add a thin animated progress bar at the bottom of the popup that shrinks from full to empty as the auto-dismiss timer counts down. Gives the user a visual cue without being intrusive.

---

### [F-09] Copy Hadith to Clipboard
Simple button (copy icon) on the popup and favorites screen. Copies the Hadith text + narrator + source as a formatted string. Useful for sharing via WhatsApp, etc.
```
"إنما الأعمال بالنيات" — عمر بن الخطاب | صحيح البخاري
```

---

### [F-10] Search in Favorites
The favorites screen currently shows all saved Hadiths in a list. Add a search bar at the top that filters by text or narrator name in real-time using Dart's `where()` on the loaded list.

---

## 🟢 POLISH & QUALITY

### [P-01] Dark Mode Support
`AppTheme.darkTheme` is defined but `ThemeMode` is hardcoded to `ThemeMode.light` in `main.dart`. Add a `darkModeEnabled` setting and wire it to `ThemeMode`.

---

### [P-02] Popup Position Memory
`PopupPosition` model and `popupPosition` in `UserSettings` exist, but it's not confirmed the position is being restored on next popup show. Verify the flow:
1. User drags popup → `UpdatePosition` event dispatched
2. `PopupBloc` saves to Hive via `SettingsRepository`
3. Next popup show → reads saved position → applies to `_position` in popup widget

---

### [P-03] First-Launch Onboarding
When the app launches for the first time, show a simple one-screen welcome:
- App name + tagline
- What the app does (one sentence)
- "Start receiving Hadiths" button → triggers `StartScheduler()`

Store `hasSeenOnboarding: bool` in Hive to show only once.

---

### [P-04] Empty State for Offline + No Local Data
If somehow the local JSON fails to load AND there's no internet, show a graceful empty state in the popup (instead of crashing or showing nothing). Display: "Could not load a Hadith. Please check your connection."

---

### [P-05] Improve Menu Bar Right-Click Menu
Currently `MenuBarManager` exists but the full right-click menu content is unclear. Ensure the menu includes:
- **Show Hadith Now** — triggers popup immediately
- **Today's Hadith** — shows daily featured Hadith
- **Favorites** — opens favorites window
- **Settings** — opens settings window
- **About Hikma** — opens about screen
- ─────────────────
- **Quit** — exits app

---

### [P-06] App Window Behavior (Hide on Close)
The main window (`HikmaHome`) should not appear as a Dock window or be closeable normally. Verify:
- `windowManager.setPreventClose(true)` is set ✅ (already in code)
- Closing the window hides it (not quits) → routes back to menu bar icon
- `windowManager.setSkipTaskbar(!showInDock)` is set based on settings ✅

---

## 🧪 TESTING

### [T-01] Unit Tests for BLoCs
The `test/bloc/` directory exists but is likely empty. Write `bloc_test` tests for:
- `HadithBloc` — `FetchRandomHadith`, offline fallback, history dedup
- `SchedulerBloc` — timer fires at correct interval, resets on settings change
- `FavoritesBloc` — add, remove, load
- `SettingsBloc` — load defaults, save, persist across sessions

---

### [T-02] Widget Tests
`test/widget/` directory exists. Write widget tests for:
- `PopupContent` renders correctly with a Hadith
- `FavoritesScreen` shows empty state when no favorites
- `SettingsScreen` displays all settings correctly

---

### [T-03] Integration Test
`test/integration/` directory exists. Write one end-to-end test:
- App starts → settings load → scheduler starts → popup triggers → user bookmarks → popup dismisses → favorites screen shows bookmarked Hadith

---

## 🚀 FUTURE — Post-MVP Ideas

### [FUT-01] English Translation Toggle
Add `translationEnabled: bool` and `englishText: String?` to the `Hadith` model. API (`api.hadith.gading.dev`) already returns English text in some endpoints. Toggle shown on popup.

### [FUT-02] Share as Image
Generate a beautiful shareable image of the Hadith (using Flutter's `RepaintBoundary` → PNG). Styled with the app's color palette. Share via macOS share sheet.

### [FUT-03] Hadith of the Week — Email Digest
Weekly summary of all Hadiths seen, formatted nicely. Opt-in. Send via user's default mail client using `mailto:` URL scheme.

### [FUT-04] Multiple Source APIs
The current API (`api.hadith.gading.dev`) may go down. Add a fallback API (`ahadith.co`) with an adapter pattern in `HadithApiService` — if primary API fails 3 times, switch to secondary.

### [FUT-05] iCloud Sync for Favorites
Store favorites in iCloud Key-Value storage so they sync across the user's Mac devices. Requires `CloudKit` entitlement in macOS sandbox.

### [FUT-06] macOS Widget (Notification Center)
A macOS Today Widget showing the daily Hadith in Notification Center. Requires a separate macOS extension target.

### [FUT-07] iOS / iPadOS Version
The BLoC logic and data layer are already platform-agnostic. The only platform-specific code is `window_manager`, `system_tray`, and `flutter_acrylic` — all of which have Flutter guards. Estimated effort: 1 week for UI adaptation.

### [FUT-08] App Store Submission
- Design final app icon (crescent moon — navy/gold)
- Write App Store description (English + Arabic)
- Configure macOS entitlements (network client, no user data collection)
- Sign with Apple Developer certificate
- Submit for review

---

## Priority Order (Recommended Execution Sequence)

```
Week 1 — Make It Work
  [C-05] flutter analyze + fix compilation errors
  [C-04] Call HadithRepository.init()
  [C-01] Auto-start Scheduler on launch
  [C-03] Decide & clean up popup architecture
  [C-02] Expand hadiths.json to 200+ Hadiths

Week 2 — Complete Core Features
  [F-01] No-repeat history logic
  [F-05] Auto-launch on login
  [F-06] Keyboard shortcut
  [F-07] Notification sound
  [F-08] Progress bar on popup
  [F-09] Copy to clipboard

Week 3 — Polish & Quality
  [F-02] Daily Featured Hadith
  [F-03] Read counter stats
  [F-10] Search in favorites
  [P-01] Dark mode
  [P-03] First-launch onboarding
  [P-05] Improve menu bar menu

Week 4 — Testing & Store Prep
  [T-01] BLoC unit tests
  [T-02] Widget tests
  [T-03] Integration test
  [F-04] Contemplation mode
  [FUT-08] App Store submission prep
```

---

## File Reference

| Area | Key Files |
|------|-----------|
| Entry point | `lib/main.dart` |
| Scheduler | `lib/bloc/scheduler/scheduler_bloc.dart` |
| Hadith data | `lib/bloc/hadith/hadith_bloc.dart` |
| Popup UI | `lib/ui/popup/hadith_popup.dart`, `popup_content.dart` |
| Data layer | `lib/data/repositories/hadith_repository.dart` |
| Local dataset | `assets/data/hadiths.json` |
| Settings | `lib/data/models/user_settings.dart` |
| Menu bar | `lib/core/utils/menu_bar_manager.dart` |
| Constants | `lib/core/constants/app_constants.dart` |
| Theme | `lib/core/theme/app_colors.dart`, `app_theme.dart` |

---

*Hikma — حكمة | Built with intention. Guided by Sunnah.*
