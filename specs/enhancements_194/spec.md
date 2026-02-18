# Feature Specification: Hikma App Enhancements & Completion

**Feature Branch**: `enhancements_194`
**Created**: 2026-02-18
**Status**: Draft
**Input**: Complete all enhancements outlined in ROADMAP.md to make Hikma fully functional

## Overview

This specification covers all enhancements needed to complete the Hikma Hadith reminder macOS application. The app architecture exists (BLoC pattern, offline-first data layer, frosted glass popup, menu bar integration) but critical initialization is missing, features are incomplete, and the dataset is too small.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - App Works on First Launch (Priority: P1)

A user downloads and launches Hikma for the first time. The app initializes properly, loads settings, starts the background scheduler, and the menu bar icon appears. Hadith popups begin appearing at the configured interval.

**Why this priority**: Without proper initialization, the app doesn't function at all. Users would see an app that does nothing.

**Independent Test**: Launch the app fresh (no previous data), verify menu bar icon appears within 3 seconds, and a Hadith popup appears at the configured interval.

**Acceptance Scenarios**:

1. **Given** a fresh install of Hikma, **When** the user launches the app, **Then** the menu bar icon appears within 3 seconds
2. **Given** the app has launched, **When** the configured reminder interval elapses, **Then** a Hadith popup appears automatically
3. **Given** the app is running, **When** the user changes the reminder interval in settings, **Then** the scheduler restarts with the new interval

### User Story 2 - View Varied Hadith Content (Priority: P1)

A user receives Hadith popups throughout the day. Each popup shows different content without excessive repetition. The Hadith collection spans multiple authentic sources (Bukhari, Muslim, Abu Dawud, Tirmidhi, Ibn Majah, Nasa'i).

**Why this priority**: The current dataset has only 10 Hadiths (one is corrupted). Users would see the same content repeatedly, rendering the app useless.

**Independent Test**: Receive 20 popups over 2 days and verify no duplicate Hadiths appear (history tracking prevents repeats).

**Acceptance Scenarios**:

1. **Given** the app shows a Hadith popup, **When** the user views it, **Then** they don't see the same Hadith again within the next 20 popups
2. **Given** a Hadith is displayed, **When** the popup appears, **Then** the Arabic text is readable, properly formatted, and attributed to its source
3. **Given** the offline dataset is loaded, **When** the app has no internet, **Then** at least 200 unique Hadiths are available

### User Story 3 - Access Today's Featured Hadith (Priority: P2)

A user wants to see a special Hadith selected for the day. They click "Today's Hadith" from the menu bar and see a beautifully displayed Hadith that remains the same for the entire day.

**Why this priority**: Provides a daily spiritual anchor point. Users can reflect on one Hadith throughout the day.

**Independent Test**: Open menu bar, select "Today's Hadith", verify it shows. Open again 2 hours later, verify the same Hadith appears.

**Acceptance Scenarios**:

1. **Given** a new day begins, **When** the user first accesses "Today's Hadith", **Then** a new Hadith is selected and displayed
2. **Given** the user has viewed today's Hadith, **When** they access it again the same day, **Then** the same Hadith is shown
3. **Given** midnight passes, **When** the user accesses "Today's Hadith", **Then** a new Hadith for the new day is displayed

### User Story 4 - Save and Organize Favorites (Priority: P2)

A user sees a Hadith they want to remember. They click the star icon on the popup to save it. Later, they open the Favorites screen from the menu bar to browse, search, and re-read saved Hadiths.

**Why this priority**: Favorites is a core engagement feature that lets users build a personal collection.

**Independent Test**: Star 3 different Hadiths, open Favorites screen, verify all 3 appear. Use search to find one by text.

**Acceptance Scenarios**:

1. **Given** a Hadith popup is showing, **When** the user taps the star icon, **Then** the Hadith is saved to favorites and the star fills in
2. **Given** the user has saved favorites, **When** they open the Favorites screen, **Then** all saved Hadiths appear in a list
3. **Given** the Favorites screen is open, **When** the user types in the search box, **Then** the list filters to show matching Hadiths
4. **Given** a Hadith is favorited, **When** the user taps the star icon again, **Then** it is removed from favorites

### User Story 5 - Personalized App Experience (Priority: P2)

A user wants Hikma to match their preferences. They open Settings and adjust: font size, reminder frequency, popup duration, sound notifications, dark mode, and auto-start behavior.

**Why this priority**: Personalization increases user satisfaction and long-term engagement.

**Independent Test**: Change each setting, verify it takes effect immediately or on next popup.

**Acceptance Scenarios**:

1. **Given** the user opens Settings, **When** they select a larger font size, **Then** Hadith text displays larger
2. **Given** sound is enabled, **When** a popup appears, **Then** a subtle notification sound plays
3. **Given** dark mode is enabled, **When** the user views any screen, **Then** the dark color theme is applied
4. **Given** auto-start is enabled, **When** the user logs into their Mac, **Then** Hikma launches automatically

### User Story 6 - Quick Access via Keyboard (Priority: P3)

A user is working and wants to see a Hadith immediately. They press Command+Shift+H and a Hadith popup appears right away.

**Why this priority**: Power users appreciate keyboard shortcuts for quick access without navigating menus.

**Independent Test**: Press Cmd+Shift+H, verify popup appears within 1 second.

**Acceptance Scenarios**:

1. **Given** Hikma is running in background, **When** the user presses Cmd+Shift+H, **Then** a Hadith popup appears
2. **Given** a popup is already showing, **When** the user presses the shortcut, **Then** either no action or a new Hadith appears (configurable)

### User Story 7 - Contemplation Mode (Priority: P3)

A user wants to deeply reflect on a Hadith without distractions. They select "Contemplation Mode" from the menu bar. A full-screen, calm environment appears with large Arabic text, soft gradient background, and minimal UI.

**Why this priority**: Provides a focused reading experience for longer contemplation sessions.

**Independent Test**: Open Contemplation Mode, verify full-screen display with minimal distractions. Press Escape to exit.

**Acceptance Scenarios**:

1. **Given** the user selects Contemplation Mode, **When** it opens, **Then** the Hadith fills the screen with large centered text
2. **Given** Contemplation Mode is open, **When** the user presses Escape, **Then** the mode closes and returns to normal view
3. **Given** Contemplation Mode is open, **When** the user taps "Next Hadith", **Then** a new Hadith appears in the same contemplative view

### User Story 8 - Share Hadith with Others (Priority: P3)

A user sees an inspiring Hadith and wants to share it with a friend. They tap the copy button, which copies a formatted string with Arabic text, narrator, and source. They paste it into a message.

**Why this priority**: Sharing enables word-of-mouth growth and helps users spread beneficial knowledge.

**Independent Test**: Tap copy button, paste into a text editor, verify format includes Arabic text, narrator, and source.

**Acceptance Scenarios**:

1. **Given** a Hadith popup is showing, **When** the user taps the copy button, **Then** the Hadith is copied to clipboard in a formatted string
2. **Given** the Hadith is copied, **When** the user pastes it, **Then** the format includes: Arabic text, narrator, and source
3. **Given** the copy completes, **When** a confirmation message appears, **Then** it displays briefly ("Hadith copied")

### User Story 9 - View Reading Statistics (Priority: P3)

A user wants to track their spiritual progress. They open Settings and see how many Hadiths they've read today and this week.

**Why this priority**: Gamification and progress tracking encourage consistent engagement.

**Independent Test**: Read 5 Hadiths in a day, open Settings, verify counter shows 5 for today.

**Acceptance Scenarios**:

1. **Given** the user views a Hadith popup, **When** the popup displays, **Then** the daily read counter increments
2. **Given** the user has read Hadiths over a week, **When** they view statistics, **Then** both daily and weekly totals are shown
3. **Given** a new day starts, **When** the user views statistics, **Then** the daily counter resets but weekly total includes previous days

### User Story 10 - Graceful Error Handling (Priority: P1)

A user's internet disconnects or the API service is down. The app continues working by using the offline dataset. If offline data also fails to load, a friendly error message appears.

**Why this priority**: Users should never see crashes or blank screens. The app must handle all failure modes gracefully.

**Independent Test**: Disconnect internet, launch app, verify it loads from offline dataset. Corrupt offline data, verify friendly error message.

**Acceptance Scenarios**:

1. **Given** the user has no internet connection, **When** the app launches, **Then** it loads Hadiths from the local dataset
2. **Given** both online API and offline data fail, **When** the app tries to show a Hadith, **Then** a friendly message appears ("Could not load a Hadith. Please check your connection.")
3. **Given** an error occurs, **When** the user retries, **Then** the app attempts to reload without crashing

### Edge Cases

- **First launch with no settings**: App should create default settings and show first-launch onboarding
- **Empty favorites list**: Favorites screen should show an empty state illustration with "Save your first Hadith" message
- **All Hadiths exhausted in history pool**: When the user has seen all available Hadiths, the cycle should restart from the beginning
- **Corrupt settings file**: App should detect corruption and recreate defaults
- **External display with different DPI**: Popup should render correctly on retina and non-retina displays
- **System sleep/wake**: Scheduler should resume correctly after system wakes from sleep
- **Multiple language locales**: Arabic text should display correctly regardless of system locale
- **Very long Hadith text**: Popup should handle multi-line text without overflow
- **User dismisses popup quickly**: Scheduler should still track that a Hadith was shown for history tracking
- **Battery saver mode**: App should respect macOS low-power mode by reducing non-essential animations

## Requirements *(mandatory)*

### Functional Requirements

#### Critical Fixes (App Won't Work Without These)

- **FR-001**: System MUST auto-start the scheduler when the app launches
- **FR-002**: System MUST call HadithRepository.init() during app initialization
- **FR-003**: System MUST include at least 200 authentic Hadiths in the offline dataset
- **FR-004**: System MUST fix the corrupted first Hadith in the current dataset
- **FR-005**: System MUST compile without errors after running flutter analyze

#### Core Features

- **FR-006**: System MUST track recently shown Hadith IDs (last 20-50) to prevent repetition
- **FR-007**: System MUST persist Hadith history across app restarts
- **FR-008**: System MUST provide a "Today's Hadith" feature that changes daily
- **FR-009**: System MUST allow users to star/favorite Hadiths from any view
- **FR-010**: System MUST save favorites to persistent storage
- **FR-011**: System MUST provide a Favorites screen showing all saved Hadiths
- **FR-012**: System MUST include search functionality within Favorites
- **FR-013**: System MUST support auto-launch at system login
- **FR-014**: System MUST support global keyboard shortcut (Cmd+Shift+H) to show Hadith
- **FR-015**: System MUST play notification sound when popup appears (if enabled)
- **FR-016**: System MUST show a visual countdown progress bar on popup before auto-dismiss
- **FR-017**: System MUST allow copying Hadith text to clipboard in a formatted string
- **FR-018**: System MUST track daily and weekly Hadith read statistics
- **FR-019**: System MUST provide a Contemplation Mode for focused, full-screen reading
- **FR-020**: System MUST support dark mode theme

#### Settings & Preferences

- **FR-021**: System MUST allow users to adjust font size (small, medium, large, extra-large)
- **FR-022**: System MUST allow users to set reminder interval (15min, 30min, 1hr, 2hr, 4hr)
- **FR-023**: System MUST allow users to set popup duration (15sec, 30sec, 1min, 2min, manual)
- **FR-024**: System MUST allow users to enable/disable notification sound
- **FR-025**: System MUST allow users to enable/disable dark mode
- **FR-026**: System MUST allow users to enable/disable auto-start at login
- **FR-027**: System MUST allow users to choose Hadith source collection
- **FR-028**: System MUST allow users to show/hide app in Dock

#### UI/UX

- **FR-029**: System MUST show first-launch onboarding screen
- **FR-030**: System MUST restore popup position from previous session
- **FR-031**: System MUST show empty states when applicable (no favorites, no search results)
- **FR-032**: System MUST provide comprehensive menu bar right-click menu
- **FR-033**: System MUST hide main window instead of quitting when closed
- **FR-034**: System MUST support Arabic text rendering with proper fonts

#### Error Handling

- **FR-035**: System MUST fallback to offline dataset when API fails
- **FR-036**: System MUST show friendly error message when both API and offline data fail
- **FR-037**: System MUST handle network connectivity changes gracefully
- **FR-038**: System MUST validate and recover from corrupt settings/data files

### Key Entities

- **Hadith**: Represents a single Hadith with Arabic text, narrator, source, collection, chapter, book number, Hadith number
- **HadithCollection**: Enum representing source collections (Bukhari, Muslim, Abu Dawud, Tirmidhi, Ibn Majah, Nasa'i, All)
- **UserSettings**: User preferences including font size, reminder interval, popup duration, sound enabled, dark mode, auto-start, show in dock, source collection, popup position
- **PopupPosition**: Saved screen coordinates for popup placement
- **HadithHistory**: List of recently shown Hadith IDs to prevent repetition
- **DailyHadith**: Special Hadith selected for the current day with date tracking
- **ReadStatistics**: Daily and weekly counters tracking Hadith views
- **Favorites**: List of Hadith IDs bookmarked by the user
- **ReminderInterval**: Enum of time intervals (15min, 30min, 1hr, 2hr, 4hr)
- **PopupDuration**: Enum of durations (15sec, 30sec, 1min, 2min, manual)
- **FontSize**: Enum of size options (small, medium, large, extra-large)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: App launches and displays menu bar icon within 3 seconds on a typical Mac
- **SC-002**: At least 200 unique, authentic Hadiths are available offline
- **SC-003**: Users can see 20 consecutive Hadiths without any repetition
- **SC-004**: App compiles with zero errors from flutter analyze
- **SC-005**: All critical functions (popup, favorites, settings) work offline
- **SC-006**: Users can complete all settings changes within 30 seconds
- **SC-007**: Search filters results in real-time as user types (within 100ms)
- **SC-008**: Keyboard shortcut shows popup within 1 second
- **SC-009**: Notification sound plays within 200ms of popup appearing
- **SC-010**: Popup countdown progress bar updates smoothly (60 FPS)
- **SC-011**: Copy to clipboard formats Hadith correctly with all components (text, narrator, source)
- **SC-012**: Daily Hadith remains constant across multiple accesses in the same day
- **SC-013**: Read statistics accurately count all viewed Hadiths
- **SC-014**: Contemplation Mode activates and deactivates within 300ms
- **SC-015**: Dark mode toggle applies to all screens instantly
- **SC-016**: App passes all widget tests with 90%+ coverage
- **SC-017**: App passes all BLoC tests with 80%+ coverage
- **SC-018**: Integration test covers the full user journey end-to-end
- **SC-019**: Onboarding shows only on first launch
- **SC-020**: Popup position persists across app restarts (within 10px accuracy)

## Assumptions

- User has macOS 11 (Big Sur) or later
- User has stable internet connection at least occasionally (for initial setup)
- User can read Arabic text (app is Arabic-first)
- User understands basic macOS conventions (menu bar, right-click, shortcuts)
- Default Hadith API (api.hadith.gading.dev) remains available
- Local dataset can be bundled with app without size concerns (target under 5MB)
- User wants non-intrusive reminders (not push notifications)
- Audio assets for notification sounds can be included in app bundle
- Google Fonts Noto Naskh Arabic is acceptable for Arabic rendering

## Dependencies

- Hadith API availability: api.hadith.gading.dev
- Flutter/macOS platform stability for window_manager, system_tray, flutter_acrylic packages
- Hive for local data persistence
- launch_at_login package for auto-start functionality
- hotkey_manager package for keyboard shortcuts
- audioplayers package for notification sounds
- connectivity_plus package for network detection
- google_fonts package for Arabic typography

## Out of Scope

These items are explicitly NOT part of this enhancement phase:

- English translation toggle (Future: FUT-01)
- Share as image generation (Future: FUT-02)
- Email digest feature (Future: FUT-03)
- Multiple API fallbacks (Future: FUT-04)
- iCloud sync for favorites (Future: FUT-05)
- macOS Notification Center widget (Future: FUT-06)
- iOS/iPadOS version (Future: FUT-07)
- App Store submission preparation (Future: FUT-08)
- Social sharing beyond clipboard copy
- Hadith commenting or annotation features
- Custom reminder schedules (beyond predefined intervals)
- Multiple user profiles on same device
- Advanced analytics or crash reporting
- In-app purchases or premium features

## Execution Order

Following the recommended sequence from ROADMAP.md:

### Week 1 - Make It Work
1. flutter analyze + fix compilation errors (C-05)
2. Call HadithRepository.init() (C-04)
3. Auto-start Scheduler on launch (C-01)
4. Decide & clean up popup architecture (C-03)
5. Expand hadiths.json to 200+ Hadiths (C-02)

### Week 2 - Complete Core Features
1. No-repeat history logic (F-01)
2. Auto-launch on login (F-05)
3. Keyboard shortcut (F-06)
4. Notification sound (F-07)
5. Progress bar on popup (F-08)
6. Copy to clipboard (F-09)

### Week 3 - Polish & Quality
1. Daily Featured Hadith (F-02)
2. Read counter stats (F-03)
3. Search in favorites (F-10)
4. Dark mode (P-01)
5. First-launch onboarding (P-03)
6. Improve menu bar menu (P-05)

### Week 4 - Testing & Finalization
1. BLoC unit tests (T-01)
2. Widget tests (T-02)
3. Integration test (T-03)
4. Contemplation mode (F-04)
5. Popup position memory verification (P-02)
6. Empty state handling (P-04)
7. App window behavior verification (P-06)
