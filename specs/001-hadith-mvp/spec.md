# Feature Specification: Hikma MVP - Hadith Reminder App for macOS

**Feature Branch**: `001-hadith-mvp`
**Created**: 2026-02-18
**Status**: Draft
**Input**: User description: "Hikma MVP - Complete Hadith Reminder App for macOS"

---

## Overview

Hikma is a macOS desktop application that delivers authentic Hadith (Prophetic narrations) to users through non-intrusive floating popups at scheduled intervals. The app runs silently in the background, accessible via a menu bar icon, and provides spiritual content in Arabic with proper citations.

**Target Audience**: Arabic-speaking Muslim professionals using macOS who seek daily Hadith reminders during work hours.

**Primary Value**: Users receive authentic, properly cited Hadith content without interrupting their workflow, fostering spiritual connection throughout the day.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Scheduled Hadith Popup (Priority: P1)

A user working on their Mac sees a beautiful floating popup appear automatically displaying a Hadith in Arabic. They read it, optionally save it to favorites, and dismiss it. The popup remembers its position and timing preferences for future appearances.

**Why this priority**: This is the core value proposition - without scheduled popups, the app has no purpose. All other features enhance but do not replace this fundamental experience.

**Independent Test**: Can be fully tested by launching the app and verifying that a Hadith popup appears at the configured interval, displays correctly, and can be dismissed. Delivers immediate spiritual value without any other features.

**Acceptance Scenarios**:

1. **Given** the app is running with default 1-hour interval, **When** the interval elapses, **Then** a popup appears displaying a Hadith with Arabic text, narrator name, and source book
2. **Given** a popup is visible, **When** user clicks the dismiss button (X), **Then** the popup closes immediately
3. **Given** a popup is visible, **When** user clicks the bookmark (star) button, **Then** the Hadith is saved to favorites and the star icon changes to filled state
4. **Given** the auto-dismiss timer is set to 2 minutes, **When** 2 minutes elapse without user interaction, **Then** the popup closes automatically
5. **Given** user drags the popup to a new position, **When** the next popup appears, **Then** it opens at the last saved position

---

### User Story 2 - Offline Hadith Access (Priority: P1)

A user opens their laptop while traveling without internet. The app immediately displays a Hadith from the bundled local collection, ensuring they never miss spiritual content regardless of connectivity.

**Why this priority**: Reliability is non-negotiable for a daily spiritual practice. Users should never see error messages or empty content due to network issues.

**Independent Test**: Can be fully tested by disconnecting from the internet and launching the app. Verifies that Hadiths load from local storage and display correctly. Delivers core value without any network dependency.

**Acceptance Scenarios**:

1. **Given** the device has no internet connection, **When** the app launches, **Then** it loads Hadith content from bundled local JSON without errors
2. **Given** the device has no internet connection, **When** a scheduled popup triggers, **Then** it displays a Hadith from the local collection
3. **Given** internet becomes available after being offline, **When** the app fetches new Hadiths, **Then** they are cached locally for future offline access
4. **Given** the bundled collection contains 200-500 Hadiths, **When** user cycles through all of them, **Then** the app randomly recycles through the collection

---

### User Story 3 - Menu Bar Access & Quick Controls (Priority: P2)

A user wants to quickly access the app without interrupting their work. They click the crescent moon icon in the menu bar to see the current Hadith, access settings, or view their favorites collection.

**Why this priority**: Menu bar integration is the primary entry point and makes the app feel native to macOS. Without it, users would need to hunt for the application window.

**Independent Test**: Can be fully tested by clicking the menu bar icon and verifying that all menu options work correctly. Provides essential navigation and quick access functionality.

**Acceptance Scenarios**:

1. **Given** the app is running, **When** user clicks the menu bar icon, **Then** a dropdown menu appears with options: "Show Hadith", "Favorites", "Settings", "About", "Quit"
2. **Given** the menu is open, **When** user selects "Show Hadith", **Then** the popup immediately appears with a random Hadith
3. **Given** the menu is open, **When** user selects "Favorites", **Then** a favorites screen opens showing all saved Hadiths
4. **Given** the menu is open, **When** user selects "Settings", **Then** the settings screen opens with all configurable options

---

### User Story 4 - Personalized Settings (Priority: P2)

A user wants to customize how often they receive Hadith reminders, how long the popup stays visible, which Hadith collections to display, and the font size for comfortable reading.

**Why this priority**: Personalization ensures the app adapts to individual preferences, making it more useful and less intrusive for different users throughout their day.

**Independent Test**: Can be fully tested by opening settings, changing each option, and verifying that the behavior changes accordingly. Delivers value by allowing users to tailor the experience to their needs.

**Acceptance Scenarios**:

1. **Given** the settings screen is open, **When** user changes reminder interval from 1 hour to 30 minutes, **Then** popups appear every 30 minutes
2. **Given** the settings screen is open, **When** user changes popup duration from 2 minutes to 30 seconds, **Then** subsequent popups close after 30 seconds
3. **Given** the settings screen is open, **When** user selects "Bukhari" as the source collection, **Then** only Hadiths from Sahih Al-Bukhari are displayed
4. **Given** the settings screen is open, **When** user selects "Extra Large" font size, **Then** Hadith text displays in larger Arabic font
5. **Given** the settings screen is open, **When** user enables sound alert, **Then** a soft notification sound plays when popup appears
6. **Given** user changes any setting, **When** they restart the app, **Then** all settings persist from the previous session

---

### User Story 5 - Favorites Management (Priority: P3)

A user reads a particularly meaningful Hadith and wants to save it for later reflection. They bookmark it and can access their collection of saved Hadiths anytime from the menu bar.

**Why this priority**: Favorites enhance the user experience by allowing them to build a personal collection, but the app functions without it. This is a nice-to-have feature that increases engagement over time.

**Independent Test**: Can be fully tested by bookmarking several Hadiths and verifying they appear in the favorites screen. Delivers value by creating a personal spiritual library.

**Acceptance Scenarios**:

1. **Given** a popup is displaying a Hadith, **When** user clicks the bookmark (star) button, **Then** the Hadith is added to favorites and the button changes to filled state
2. **Given** a Hadith is already bookmarked, **When** user clicks the filled star button, **Then** the Hadith is removed from favorites and the button changes to outline state
3. **Given** user has multiple saved favorites, **When** they open the favorites screen, **Then** all saved Hadiths are displayed in a scrollable list
4. **Given** the favorites list is displayed, **When** user swipes left on a Hadith (or clicks delete), **Then** that Hadith is removed from favorites
5. **Given** user closes and reopens the app, **When** they open favorites, **Then** all previously saved Hadiths remain

---

### Edge Cases

- What happens when the bundled Hadith collection becomes depleted?
  - **Answer**: The app randomly recycles through the bundled collection, ensuring users always see content even after extensive use

- What happens when the user's system is asleep or locked when a popup is scheduled?
  - **Answer**: The popup appears when the user wakes/unlocks the system, or the schedule adjusts to the next interval without accumulating missed popups

- What happens when a Hadith text is extremely long (e.g., several paragraphs)?
  - **Answer**: The popup height expands to accommodate the full text with a maximum height, after which scrolling becomes available within the popup

- What happens when the user manually changes display resolution or moves between screens?
  - **Answer**: The popup position is adjusted to remain visible on the active screen, defaulting to center if the saved position is off-screen

- What happens when the online API returns an error or invalid data?
  - **Answer**: The app silently falls back to the bundled local collection without showing error messages to the user

- What happens when the user has zero favorites saved?
  - **Answer**: The favorites screen displays a friendly empty state message encouraging users to bookmark Hadiths they find meaningful

---

## Requirements *(mandatory)*

### Functional Requirements

**Core Functionality**

- **FR-001**: System MUST display Hadith content in Arabic text with proper right-to-left (RTL) text direction
- **FR-002**: System MUST display narrator name, source book, and chapter reference for each Hadith
- **FR-003**: System MUST show floating popup at user-configured intervals (30 minutes, 1 hour, 2 hours, 4 hours, 8 hours, or daily)
- **FR-004**: System MUST automatically close popup after user-configured duration (30 seconds, 1 minute, 2 minutes, 5 minutes, or manual-only)
- **FR-005**: System MUST allow users to manually dismiss popup via close button (X)
- **FR-006**: System MUST allow users to drag the popup window to any position on screen
- **FR-007**: System MUST remember the popup position between sessions

**Data & Storage**

- **FR-008**: System MUST ship with bundled local JSON containing 200-500 curated Hadiths
- **FR-009**: System MUST function fully without internet connection using only local data
- **FR-010**: System MUST fetch Hadiths from online API when internet is available
- **FR-011**: System MUST cache online-fetched Hadiths locally for offline access
- **FR-012**: System MUST persist all user settings locally (interval, duration, source, font size, sound preference)
- **FR-013**: System MUST persist user's favorited Hadiths locally

**Menu Bar & Navigation**

- **FR-014**: System MUST display a crescent moon icon in the macOS menu bar
- **FR-015**: System MUST provide dropdown menu with options: "Show Hadith", "Favorites", "Settings", "About", "Quit"
- **FR-016**: System MUST show the current Hadith immediately when "Show Hadith" is selected
- **FR-017**: System MUST NOT display a separate dock icon by default (menu bar only operation)

**Source Selection**

- **FR-018**: System MUST allow users to select Hadith source from: All Collections, Sahih Al-Bukhari, Sahih Muslim, Sunan Abu Dawud, Jami' Al-Tirmidhi, Sunan Ibn Majah, Sunan Al-Nasa'i
- **FR-019**: System MUST filter displayed Hadiths based on selected source when a specific collection is chosen

**Favorites Management**

- **FR-020**: System MUST allow users to bookmark (save) any displayed Hadith via star button
- **FR-021**: System MUST indicate whether a Hadith is already bookmarked (filled star vs outline)
- **FR-022**: System MUST allow users to remove Hadiths from favorites
- **FR-023**: System MUST display all favorited Hadiths in a dedicated favorites screen
- **FR-024**: System MUST support deleting individual Hadiths from favorites list

**Settings & Personalization**

- **FR-025**: System MUST provide configurable reminder interval options: 30 minutes, 1 hour, 2 hours, 4 hours, 8 hours, daily
- **FR-026**: System MUST provide configurable popup duration options: 30 seconds, 1 minute, 2 minutes, 5 minutes, manual-only (no auto-dismiss)
- **FR-027**: System MUST provide font size options: Small, Medium, Large, Extra Large (Large as default)
- **FR-028**: System MUST provide toggle for notification sound when popup appears (off by default)
- **FR-029**: System MUST provide option to auto-start app on system login (on by default)
- **FR-030**: System MUST provide option to show app in Dock (off by default, menu bar only)

**Visual Design**

- **FR-031**: System MUST use frosted glass/semi-transparent effect for popup background
- **FR-032**: System MUST use Noto Naskh Arabic font for Hadith text display
- **FR-033**: System MUST display popup with approximately 480px width, height adapting to content
- **FR-034**: System MUST use 16px border radius for popup window
- **FR-035**: System MUST apply subtle drop shadow to popup window

**Behavioral**

- **FR-036**: System MUST NOT display any error messages when offline (silent fallback to local data)
- **FR-037**: System MUST NOT collect any user telemetry, analytics, or tracking data
- **FR-038**: System MUST run with background memory usage under 50MB
- **FR-039**: System MUST support hotkey/keyboard shortcut to show popup immediately (default: Cmd+Shift+H, configurable)

---

### Key Entities

**Hadith**
- Represents a single Prophetic narration with its content and metadata
- Attributes: unique identifier, Arabic text, narrator name, source book (e.g., "Sahih Al-Bukhari"), chapter reference, book number, Hadith number
- Relationships: may be favorited by zero or more users

**User Settings**
- Represents the user's configuration preferences
- Attributes: reminder interval, popup duration, selected source collection, font size preference, sound enabled flag, auto-start enabled flag, show in dock flag, last popup position coordinates
- Relationships: none (single-user, local device)

**Favorite**
- Represents a Hadith that the user has bookmarked for later access
- Attributes: Hadith reference, timestamp when saved
- Relationships: references exactly one Hadith

**Hadith Collection**
- Represents a source book of Hadiths
- Attributes: collection name (e.g., "Sahih Al-Bukhari"), Arabic name, total Hadith count
- Relationships: contains multiple Hadiths

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

**User Experience**

- **SC-001**: Users can read a complete Hadith within 10 seconds of popup appearance (text renders immediately, no loading delay)
- **SC-002**: Users can dismiss a popup with a single click or touch interaction
- **SC-003**: Users can access any saved favorite Hadith within 3 seconds from the menu bar

**Performance & Reliability**

- **SC-004**: App launches and displays initial content within 2 seconds of system startup
- **SC-005**: App functions normally without internet connection (100% of offline scenarios work correctly)
- **SC-006**: Background memory usage remains under 50MB during normal operation
- **SC-007**: App binary size is under 50MB for Mac App Store approval

**Content Quality**

- **SC-008**: 100% of displayed Hadiths include proper citation (narrator, source book, chapter reference)
- **SC-009**: All Hadiths in the bundled collection are verified as authentic (Sahih) sources
- **SC-010**: Arabic text renders correctly with proper RTL direction and readable typography

**Privacy & Security**

- **SC-011**: Zero user data is transmitted to external servers (except for Hadith content fetching)
- **SC-012**: All user preferences and favorites remain stored locally on the user's device
- **SC-013**: No analytics, tracking, or telemetry is included in the application

**Engagement & Satisfaction**

- **SC-014**: At least 80% of users who try the app continue to use it after one week (measured via Mac App Store engagement metrics, not in-app tracking)
- **SC-015**: User can configure all settings within 2 minutes of first use (intuitive settings screen)

**Platform Compliance**

- **SC-016**: App successfully passes Mac App Store review (follows all Apple guidelines for sandboxing, signing, and appropriate behavior)
- **SC-017**: App behaves as a native macOS application (menu bar integration, familiar UI patterns, proper window management)

---

## Assumptions

1. **Device**: Users have a Mac running macOS 11 (Big Sur) or later
2. **Language**: Primary users are Arabic speakers; English translations are planned for future versions but NOT included in v1.0
3. **Network**: Users may have intermittent internet connectivity; app must handle both online and offline states gracefully
4. **Single User**: Each Mac has a single user of the app; no multi-user account management is needed
5. **Hadith Sources**: The initial bundled collection focuses on the six most authentic books (Kutub al-Sittah); additional collections may be added in future versions
6. **API Reliability**: The chosen Hadith API (api.hadith.gading.dev or similar) remains available and returns structured data; if unavailable, local bundled content serves as complete fallback
7. **Distribution**: The app will be distributed via Mac App Store, requiring compliance with Apple's sandboxing and code signing requirements
8. **Font Availability**: Noto Naskh Arabic font can be bundled with the app or loaded via Google Fonts package within the app bundle
9. **Storage**: Users have sufficient disk space for the app (under 50MB) and local data storage (under 10MB for bundled Hadiths and user favorites)
10. **Screen Size**: Users have displays with at least 1280x720 resolution; the popup (480px wide) fits comfortably on such screens

---

## Out of Scope *(for MVP v1.0)*

The following features are explicitly NOT included in the MVP but may be considered for future versions:

1. **English translations** - v1.0 is Arabic-only
2. **Cloud sync** - favorites and settings are device-local only
3. **Social sharing** - no ability to share Hadiths to social media or messaging apps
4. **Account system** - no user accounts, authentication, or cross-device sync
5. **Search functionality** - users cannot search for specific Hadiths by topic or keywords
6. **Daily Featured Hadith** - a special Hadith pinned for the entire day (planned for v1.1)
7. **Hadith counter** - tracking how many Hadiths have been read (planned for v1.1)
8. **Contemplation mode** - full-screen calm view for focused reading (planned for v1.1)
9. **Custom themes** - users cannot customize colors beyond the defined design system
10. **iOS/Android versions** - v1.0 is macOS only; cross-platform is future consideration
11. **Commentary or explanations** - only the raw Hadith text with citation is provided
12. **Audio recitation** - no text-to-speech or audio playback of Hadiths

---

## Dependencies

**External Services**

- **Hadith API**: api.hadith.gading.dev (or similar) for fetching Hadith content when online
  - **Fallback**: Complete reliance on bundled local JSON if API is unavailable
  - **No authentication required**: API is publicly accessible

**System Requirements**

- **macOS Version**: 11.0 (Big Sur) or later
- **Permissions**: None required beyond standard app sandboxing
- **Network Access**: Optional, for fetching Hadith content from API

**Third-Party Packages**

The following packages will be used for implementation (this is technical detail for developers, not part of the user-facing spec):

- State management: BLoC pattern
- Local storage: Hive (key-value storage)
- HTTP client: for API requests
- Window management: for floating popup control
- Menu bar integration: for system tray icon
- Fonts: Noto Naskh Arabic
- Visual effects: for frosted glass blur effects

---

## Non-Functional Requirements

**Performance**

- App cold start time: under 2 seconds
- Popup appearance: instantaneous (< 100ms after trigger)
- Memory usage: under 50MB during normal operation
- Disk footprint: under 50MB for app bundle, under 10MB for data

**Reliability**

- Mean time between failures (MTBF): app should run continuously for weeks without crashes
- Graceful degradation: offline mode is fully functional, not a degraded experience
- Data persistence: user settings and favorites are never lost except by explicit user action

**Usability**

- All primary functions accessible within 3 clicks/taps from menu bar
- Settings screen can be navigated and understood without documentation
- Error conditions are handled silently without user-facing error messages

**Security & Privacy**

- No user data collection or transmission
- All data stored locally on user's device
- Network access only for fetching public Hadith content
- App sandboxing compliance for Mac App Store distribution

**Maintainability**

- Modular architecture allowing easy addition of new Hadith sources
- Clear separation between UI, business logic, and data layers
- Comprehensive logging for debugging (without collecting user-identifiable information)

---

## Open Questions

None at this time. All key decisions have been made based on the PRD and constitution.

---

*This specification is version 1.0 and was created on 2026-02-18.*
