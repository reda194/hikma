# Feature Specification: Native Floating Hadith Popup

**Feature Branch**: `002-native-popup`
**Created**: 2026-02-19
**Status**: Draft
**Input**: User description: "Transform hadith popup from dialog to native floating NSWindow with frosted glass effect, hover-to-pause behavior, progress circle, action buttons (Save, Copy, Next), and configurable screen position"

## Clarifications

### Session 2026-02-19

- Q: On which monitor should the popup appear when the user has multiple displays connected? → A: Display with the mouse cursor (follows user attention)
- Q: When the user quits the Hikma application while a popup is displayed, what should happen? → A: Popup dismisses immediately when app quits
- Q: What format should be used when copying hadith to clipboard? → A: Arabic text + narrator + source book (complete citation)
- Q: Should the popup display duration be user-configurable in settings? → A: Yes - user can adjust in settings (range: 4-30 seconds)
- Q: When a user drags the popup to a new location, should that position be saved as the new default? → A: No - temporary for current session only

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Floating Popup Display (Priority: P1)

User receives a hadith reminder notification that appears as a floating window on their screen, similar to macOS system notifications. The popup appears even when the main application window is hidden or minimized.

**Why this priority**: This is the core functionality - without a working popup display, users cannot receive hadith reminders, which is the primary purpose of the application.

**Independent Test**: Can be fully tested by triggering a hadith notification while the main app is hidden in the menu bar. The popup should appear on screen regardless of main app visibility.

**Acceptance Scenarios**:

1. **Given** the application is running in the background (hidden in menu bar), **When** a scheduled hadith reminder triggers, **Then** a floating popup window appears on the screen
2. **Given** the popup is displayed, **When** the user is in fullscreen mode with another application, **Then** the popup still appears visible on top
3. **Given** the popup is displayed, **When** the display duration elapses without user interaction, **Then** the popup automatically dismisses with a slide-out animation
4. **Given** the user has multiple displays and the cursor is on display B, **When** a notification triggers, **Then** the popup appears on display B (follows cursor)

---

### User Story 2 - Hover to Pause and Interact (Priority: P2)

User can hover over the popup to pause its auto-dismiss timer, revealing action buttons that allow them to save the hadith to favorites, copy it to clipboard, or view the next hadith.

**Why this priority**: This enables user interaction with the hadith content, transforming the popup from a passive notification into an actionable interface.

**Independent Test**: Can be tested by triggering a popup and moving the mouse cursor over it. The timer should pause and action buttons should appear.

**Acceptance Scenarios**:

1. **Given** the popup is displayed, **When** the user hovers the mouse cursor over it, **Then** the auto-dismiss timer pauses
2. **Given** the user is hovering over the popup, **When** they move the cursor away, **Then** the timer resumes from where it left off
3. **Given** the user is hovering over the popup, **When** they click the "Save" button on a non-favorited hadith, **Then** the hadith is added to favorites and the button changes to indicate favorited state
4. **Given** the user is hovering over the popup, **When** they click the "Copy" button, **Then** the hadith text with Arabic text, narrator, and source book is copied to the system clipboard
5. **Given** the user is hovering over the popup, **When** they click the "Next" button, **Then** a new random hadith is loaded and displayed in the popup

---

### User Story 3 - Configurable Popup Position (Priority: P3)

User can configure where on their screen the popup appears (corners or center) through the settings screen, with a visual preview to help them choose.

**Why this priority**: This provides personalization and allows users to position the popup in a location that doesn't interfere with their workflow.

**Independent Test**: Can be tested by opening settings, selecting a different popup position, triggering a notification, and verifying the popup appears at the selected location.

**Acceptance Scenarios**:

1. **Given** the user is in the settings screen, **When** they tap on "Popup Position", **Then** a visual position picker appears showing 5 options (4 corners + center)
2. **Given** the position picker is open, **When** they select "Top Left", **Then** the popup position is saved and subsequent notifications appear in the top-left corner
3. **Given** the user has selected a position, **When** they trigger a hadith notification, **Then** the popup appears at the configured position with appropriate margin from screen edges
4. **Given** the user changes screen resolution or moves between displays, **When** a popup is triggered, **Then** the popup remains visible and within screen boundaries (auto-clamped to visible area)
5. **Given** the user manually drags the popup to a new location, **When** the next notification appears, **Then** it uses the originally configured position (drag is temporary)

---

### User Story 4 - Duration Customization (Priority: P3)

User can adjust how long the popup remains visible before auto-dismissing, accommodating different reading speeds and preferences.

**Why this priority**: This provides accessibility and personalization for users who read faster or slower than the default duration.

**Independent Test**: Can be tested by changing the duration setting, triggering a notification, and measuring the time until auto-dismiss.

**Acceptance Scenarios**:

1. **Given** the user is in settings screen, **When** they adjust the "Popup Duration" slider, **Then** the value saves and displays the selected duration
2. **Given** the user has set duration to 5 seconds, **When** a popup appears without hover interaction, **Then** it auto-dismisses after exactly 5 seconds
3. **Given** the user sets duration below 4 seconds or above 30 seconds, **When** they attempt to save, **Then** the value clamps to the minimum (4s) or maximum (30s) allowed range

---

### Edge Cases

- What happens when the user's screen resolution is smaller than the popup size? The popup should be clamped to fit within visible screen area.
- What happens when multiple popups are triggered in quick succession? Only one popup should be visible at a time; new hadiths replace the current popup content.
- What happens when the user clicks the close button while hovering? The popup should dismiss immediately regardless of timer state.
- What happens when the hadith text is extremely long? The content should be scrollable within the fixed popup dimensions.
- What happens when the system is in Dark Mode vs Light Mode? The popup should maintain its frosted glass appearance with appropriate contrast.
- What happens when audio playback fails? The notification should still appear (silent fallback).
- What happens when the hadith ID passed to the popup is empty or invalid? The popup should not appear and the error should be logged for debugging.
- What happens when the user quits the application while a popup is visible? The popup dismisses immediately with the application.
- What happens when cursor is on one display but configured position is on another? The popup appears on the display with the cursor (multi-display behavior takes precedence).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display hadith notifications in a separate floating window that appears independently of the main application window
- **FR-002**: System MUST position the floating window at the user's configured screen location (one of 5 positions: 4 corners or center)
- **FR-003**: System MUST ensure the popup window appears above all other application windows, including fullscreen applications
- **FR-004**: System MUST apply a frosted glass visual effect to the popup background (translucent blur)
- **FR-005**: System MUST display the hadith Arabic text in right-to-left format with appropriate font styling
- **FR-006**: System MUST display the hadith source and collection information as citation badges
- **FR-007**: System MUST automatically dismiss the popup after a user-configurable duration (default 8 seconds, range 4-30 seconds)
- **FR-008**: System MUST pause the auto-dismiss timer when the user hovers their cursor over the popup
- **FR-009**: System MUST resume the auto-dismiss timer when the user moves their cursor away from the popup
- **FR-010**: System MUST display a circular progress indicator showing remaining time before auto-dismiss
- **FR-011**: System MUST reveal action buttons (Save, Copy, Next) when the user hovers over the popup
- **FR-012**: System MUST allow users to save the current hadith to favorites via the Save button
- **FR-013**: System MUST allow users to copy the hadith text (Arabic + narrator + source book) to the clipboard via the Copy button
- **FR-014**: System MUST allow users to load and display a new random hadith via the Next button
- **FR-015**: System MUST indicate visually when a hadith is already saved as a favorite (filled star icon)
- **FR-016**: System MUST provide a close button that dismisses the popup immediately
- **FR-017**: System MUST animate the popup entrance with a slide-in from the right side
- **FR-018**: System MUST animate the popup exit with a slide-out to the right side
- **FR-019**: System MUST make the popup draggable by clicking and dragging on the background area (temporary position, not saved)
- **FR-020**: System MUST persist the user's chosen popup position in application settings
- **FR-021**: System MUST provide a visual position picker in settings showing all 5 position options
- **FR-022**: System MUST play a notification sound when the popup appears
- **FR-023**: System MUST fix the scheduler bug where an empty hadith ID prevents popup display
- **FR-024**: System MUST clamp the popup position to ensure it stays within visible screen boundaries
- **FR-025**: System MUST support multi-display scenarios by detecting which display contains the mouse cursor and showing the popup on that display
- **FR-026**: System MUST dismiss the popup immediately when the application quits
- **FR-027**: System MUST provide a settings option for users to configure popup display duration (4-30 seconds range with 8 second default)

### Key Entities

- **Popup Position Setting**: User preference for where the notification appears on screen. Attributes: position type (corner/center), coordinates (x, y), margin from edges.
- **Hadith Notification**: The transient display of a hadith to the user. Attributes: hadith reference, display duration, current timer state, hover state, visibility state.
- **Popup Display State**: Current state of the popup window. Attributes: is visible, is hovered, remaining time, current hadith, animation state, dragged position (temporary).
- **Notification History**: Record of recently displayed hadiths to avoid repetition. Attributes: list of hadith IDs, timestamps, display count.
- **Duration Setting**: User-configured display duration. Attributes: duration in seconds (4-30 range), default value (8).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Popup appears within 500 milliseconds after the scheduled reminder time
- **SC-002**: Popup remains visible for the full configured duration when no user interaction occurs (8 seconds default, 4-30 second range)
- **SC-003**: Hovering over the popup pauses the timer within 100 milliseconds of cursor entry
- **SC-004**: All action buttons (Save, Copy, Next) respond to clicks within 50 milliseconds
- **SC-005**: Copy action places hadith text (Arabic + narrator + source book) on system clipboard with correct RTL formatting
- **SC-006**: Save action correctly updates favorite status visually within 200 milliseconds
- **SC-007**: Position picker changes are saved and applied to subsequent notifications
- **SC-008**: Popup remains visible and positioned correctly when user switches between fullscreen and windowed applications
- **SC-009**: Popup appears on all macOS desktop spaces (virtual desktops)
- **SC-010**: The scheduler bug is eliminated - all triggered notifications display with valid hadith content
- **SC-011**: Popup drag interaction feels responsive with no lag or stutter
- **SC-012**: Notification sound plays without causing delays in popup appearance
- **SC-013**: Multi-display detection correctly identifies the display with the mouse cursor and positions popup there
- **SC-014**: Duration setting changes take effect immediately for the next notification
- **SC-015**: Popup dismisses within 100 milliseconds when application quits

## Assumptions

1. The user is running macOS 11.0 or later (required for NSPanel and frosted glass effects)
2. The application has permission to display notifications on the user's system
3. The user has a screen resolution of at least 1280x720 (ensures popup fits comfortably)
4. The hadith data source contains valid, non-empty hadith entries with all required fields
5. Audio playback for notification sounds is optional and should fail silently if unavailable
6. The default popup position (bottom-right) follows macOS notification conventions
7. Users prefer the popup to appear near screen edges rather than center by default
8. The popup should use the same hadith repository as the main application (shared data source)
9. Multi-display users typically work with the cursor on their active display, making cursor-following the optimal behavior
10. 4 seconds is the minimum practical reading time for hadith text; 30 seconds accommodates slower readers without indefinite display
11. Temporary drag positioning prevents accidental changes while allowing flexible repositioning during use
