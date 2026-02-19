# Tasks: Native Floating Hadith Popup

**Input**: Design documents from `/specs/002-native-popup/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/popup_bloc.md, quickstart.md

**Tests**: Tests are OPTIONAL for this feature. Test tasks are NOT included unless explicitly requested.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Include exact file paths in descriptions

## Path Conventions

- **Flutter macOS**: `lib/` for source, `test/` for tests
- **BLoC files**: `lib/bloc/<feature>/` containing bloc, event, state files
- **UI files**: `lib/ui/screens/` and `lib/ui/widgets/`
- **Models**: `lib/data/models/`
- **Swift macOS**: `macos/Runner/`
- **Utils**: `lib/core/utils/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Verify branch `002-native-popup` is checked out and clean
- [ ] T002 Run `flutter pub get` to ensure all dependencies are installed
- [ ] T003 Run `cd macos && pod install` to update macOS native dependencies

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T004 Add `PopupPositionType` enum to `lib/data/models/user_settings.dart`
- [ ] T005 Add `popupPositionType` field to `UserSettings` class in `lib/data/models/user_settings.dart`
- [ ] T006 Add `popupDisplayDuration` int field to `UserSettings` class in `lib/data/models/user_settings.dart` (default 8, range 4-30)
- [ ] T007 Update `UserSettings.toJson()` to include `popupPositionType` and `popupDisplayDuration`
- [ ] T008 Update `UserSettings.fromJson()` to parse `popupPositionType` and `popupDisplayDuration`
- [ ] T009 [P] Add `getPopupPositionType()` and `setPopupPositionType()` methods to `lib/data/repositories/settings_repository.dart`
- [ ] T010 [P] Add `getPopupDisplayDuration()` and `setPopupDisplayDuration()` methods to `lib/data/repositories/settings_repository.dart`
- [ ] T011 Add storage key constants to `lib/core/constants/storage_keys.dart` for position type and duration

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: Critical Bug Fix - Scheduler Empty hadithId (Priority: P0)

**Goal**: Fix the scheduler bug where an empty hadithId prevents popup display

**Independent Test**: Trigger a scheduled notification and verify the popup appears with actual hadith content

- [ ] T012 Fix empty hadithId bug in `lib/bloc/scheduler/scheduler_bloc.dart` line 99
- [ ] T013 Fix empty hadithId bug in `lib/bloc/scheduler/scheduler_bloc.dart` line 180

**Checkpoint**: Scheduler now passes valid hadith objects to PopupBloc

---

## Phase 4: User Story 1 - Floating Popup Display (Priority: P1) 🎯 MVP

**Goal**: Hadith popup appears as a native floating window, visible even when main app is hidden

**Independent Test**: Trigger popup while main app is hidden in menu bar - verify NSPanel appears with hadith content

### Swift Native Implementation

- [ ] T014 [P] Create `macos/Runner/PopupWindowController.swift` with NSPanel implementation
- [ ] T015 [P] Implement `showPopup()` method in `PopupWindowController.swift` with NSPanel setup and frosted glass
- [ ] T016 [P] Implement `hidePopup()` method in `PopupWindowController.swift`
- [ ] T017 [P] Implement `updateHadith()` method in `PopupWindowController.swift` to replace current hadith
- [ ] T018 [P] Implement multi-display cursor detection in `PopupWindowController.swift` using NSEvent.mouseLocation
- [ ] T019 [P] Implement `PopupPositionCalculator` struct in `PopupWindowController.swift` for position calculations

### Platform Channel Bridge

- [ ] T020 Create `macos/Runner/PopupWindowPlugin.swift` with MethodChannel handler
- [ ] T021 Implement `showPopup` method handler in `PopupWindowPlugin.swift` accepting hadith data, position, duration
- [ ] T022 Implement `hidePopup` method handler in `PopupWindowPlugin.swift`
- [ ] T023 Implement `updateHadith` method handler in `PopupWindowPlugin.swift`
- [ ] T024 Implement `onHoverChanged` callback from Swift to Flutter in `PopupWindowPlugin.swift`
- [ ] T025 Implement `onAction` callback from Swift to Flutter in `PopupWindowPlugin.swift` for button clicks
- [ ] T026 Register `PopupWindowPlugin` in `macos/Runner/AppDelegate.swift`
- [ ] T027 Create `lib/core/utils/popup_window_manager.dart` with MethodChannel wrapper class
- [ ] T028 Implement `showPopup()` method in `popup_window_manager.dart` calling platform channel
- [ ] T029 Implement `hidePopup()` method in `popup_window_manager.dart` calling platform channel
- [ ] T030 Implement `updateHadith()` method in `popup_window_manager.dart` calling platform channel

### BLoC Updates for NSPanel

- [ ] T031 Add `HadithBloc` dependency to `PopupBloc` constructor in `lib/bloc/popup/popup_bloc.dart`
- [ ] T032 Update `ShowPopup` event to accept `hadith: Hadith` instead of `hadithId: String` in `lib/bloc/popup/popup_event.dart`
- [ ] T033 Update `PopupVisible` state to include `hadith: Hadith` field in `lib/bloc/popup/popup_state.dart`
- [ ] T034 Update `PopupVisible` state to include `isHovered: bool` field in `lib/bloc/popup/popup_state.dart`
- [ ] T035 Update `PopupVisible` state to include `remainingMillis: int` field in `lib/bloc/popup/popup_state.dart`
- [ ] T036 Update `PopupVisible` state to include `displayDuration: Duration` field in `lib/bloc/popup/popup_state.dart`
- [ ] T037 Update `PopupVisible` state to include `positionType: PopupPositionType` field in `lib/bloc/popup/popup_state.dart`
- [ ] T038 Implement `ShowPopup` event handler in `PopupBloc` to call `PopupWindowManager.showPopup()`
- [ ] T039 Implement `HidePopup` event handler in `PopupBloc` to call `PopupWindowManager.hidePopup()`
- [ ] T040 Add `disposeOnAppQuit` handler in `PopupBloc` for clean NSPanel cleanup

**Checkpoint**: User Story 1 complete - Popup appears as native NSPanel with hadith content

---

## Phase 5: User Story 2 - Hover to Pause and Interact (Priority: P2)

**Goal**: User can hover to pause auto-dismiss and access action buttons (Save, Copy, Next)

**Independent Test**: Hover over popup and verify timer pauses; click action buttons and verify they work

### BLoC Events and Handlers

- [ ] T041 [P] Create `HoverChanged` event in `lib/bloc/popup/popup_event.dart`
- [ ] T042 [P] Create `CopyHadith` event in `lib/bloc/popup/popup_event.dart`
- [ ] T043 [P] Create `ShowNextHadith` event in `lib/bloc/popup/popup_event.dart`
- [ ] T044 Implement `HoverChanged` handler with timer pause/resume logic in `lib/bloc/popup/popup_bloc.dart`
- [ ] T045 Implement `CopyHadith` handler with clipboard formatting (Arabic + narrator + source) in `lib/bloc/popup/popup_bloc.dart`
- [ ] T046 Implement `ShowNextHadith` handler triggering HadithBloc fetch in `lib/bloc/popup/popup_bloc.dart`

### Popup UI Widget

- [ ] T047 Create `lib/ui/popup/notification_popup.dart` widget with slide-in/slide-out animations
- [ ] T048 Implement `MouseRegion` with hover detection in `notification_popup.dart`
- [ ] T049 Implement circular progress indicator using `CustomPainter` in `notification_popup.dart`
- [ ] T050 Implement slide-in animation from right side in `notification_popup.dart`
- [ ] T051 Implement slide-out animation to right side in `notification_popup.dart`
- [ ] T052 Implement close button (X) in top-right corner in `notification_popup.dart`
- [ ] T053 [P] Implement Save action button (star icon) in `notification_popup.dart`
- [ ] T054 [P] Implement Copy action button in `notification_popup.dart`
- [ ] T055 [P] Implement Next action button in `notification_popup.dart`
- [ ] T056 Implement action buttons reveal animation on hover in `notification_popup.dart`
- [ ] T057 Implement Arabic text display with RTL direction in `notification_popup.dart`
- [ ] T058 Implement citation badges (collection, number) in `notification_popup.dart`
- [ ] T059 Connect HoverChanged events to `MouseRegion` callbacks in `notification_popup.dart`
- [ ] T060 Connect action button taps to respective BLoC events in `notification_popup.dart`

### Swift Integration

- [ ] T061 Add NSTrackingArea setup in `PopupWindowController.swift` for reliable hover detection
- [ ] T062 Implement hover state callbacks from Swift to Flutter in `PopupWindowPlugin.swift`

**Checkpoint**: User Story 2 complete - Hover pauses timer, action buttons functional

---

## Phase 6: User Story 3 - Configurable Popup Position (Priority: P3)

**Goal**: User can configure popup position (5 options) via visual picker in settings

**Independent Test**: Open settings, select different position, trigger popup - verify appears at selected location

### Settings Repository

- [ ] T063 Update `loadSettings()` in `lib/data/repositories/settings_repository.dart` to load `popupPositionType`
- [ ] T064 Update `saveSettings()` in `lib/data/repositories/settings_repository.dart` to persist `popupPositionType`
- [ ] T065 Update `updatePopupPosition()` method in `lib/data/repositories/settings_repository.dart`

### Settings UI

- [ ] T066 Create `lib/ui/widgets/position_picker.dart` widget with 5-position visual selector
- [ ] T067 Implement 16:9 screen preview rectangle in `position_picker.dart`
- [ ] T068 Implement top-left position button in `position_picker.dart`
- [ ] T069 Implement top-right position button in `position_picker.dart`
- [ ] T070 Implement bottom-left position button in `position_picker.dart`
- [ ] T071 Implement bottom-right position button in `position_picker.dart`
- [ ] T072 Implement center position button in `position_picker.dart`
- [ ] T073 Implement visual selection indicator in `position_picker.dart`

### Settings Screen Integration

- [ ] T074 Add "Popup Position" list tile to Hadith section in `lib/ui/screens/settings_screen.dart`
- [ ] T075 Implement `_showPositionPicker()` modal bottom sheet in `settings_screen.dart`
- [ ] T076 Connect position picker changes to SettingsBloc in `settings_screen.dart`

**Checkpoint**: User Story 3 complete - Position configurable via settings UI

---

## Phase 7: User Story 4 - Duration Customization (Priority: P3)

**Goal**: User can adjust popup display duration (4-30 seconds) in settings

**Independent Test**: Open settings, adjust duration slider, trigger popup - verify dismisses after selected time

### Settings UI

- [ ] T077 Create `lib/ui/widgets/duration_slider.dart` widget with 4-30 second range
- [ ] T078 Implement Slider widget with 26 divisions in `duration_slider.dart`
- [ ] T079 Implement live duration preview label in `duration_slider.dart`
- [ ] T080 Implement clamping validation (4-30 range) in `duration_slider.dart`

### Settings Screen Integration

- [ ] T081 Add "Popup Duration" list tile to Hadith section in `lib/ui/screens/settings_screen.dart`
- [ ] T082 Implement `_showDurationSlider()` modal in `settings_screen.dart`
- [ ] T083 Connect duration slider changes to SettingsBloc in `settings_screen.dart`

**Checkpoint**: User Story 4 complete - Duration configurable via slider

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T084 Implement drag-to-move popup functionality (temporary position only) in `lib/ui/popup/notification_popup.dart`
- [ ] T085 Implement `UpdateTemporaryPosition` event handler in `lib/bloc/popup/popup_bloc.dart`
- [ ] T086 Add position clamping logic to prevent popup appearing off-screen in `PopupWindowController.swift`
- [ ] T087 Implement app quit handler in `PopupWindowController.swift` to dismiss NSPanel immediately
- [ ] T088 Update notification sound to use macOS system sound or bundled asset in `lib/data/services/audio_service.dart`
- [ ] T089 Add Hikma logo watermark to popup header in `notification_popup.dart`
- [ ] T090 Implement top accent line gradient in `notification_popup.dart`
- [ ] T091 Verify popup appears on all macOS desktop spaces (virtual desktops)
- [ ] T092 Test multi-display scenarios with cursor following behavior
- [ ] T093 Test popup appearance with fullscreen applications
- [ ] T094 Test popup behavior during system Dark Mode/Light Mode transitions
- [ ] T095 Clean up deprecated `hadithId` string references throughout codebase
- [ ] T096 Remove or deprecate old `PopupPosition` x,y class in favor of `PopupPositionType`
- [ ] T097 Run quickstart.md validation checklist

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **Bug Fix (Phase 3)**: Depends on Foundational - should be done first as it's P0 critical
- **User Stories (Phases 4-7)**: All depend on Foundational phase completion
  - Can proceed sequentially (US1 → US2 → US3 → US4) or in parallel if team capacity allows
- **Polish (Phase 8)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - Core popup display functionality
- **User Story 2 (P2)**: Depends on US1 - builds on popup widget with interactions
- **User Story 3 (P3)**: Independent of US2 - settings-only changes
- **User Story 4 (P3)**: Independent of US2 - settings-only changes

### Within Each User Story

- Swift files can be created in parallel (marked [P])
- Platform channel bridge must complete before BLoC updates
- BLoC events must be created before handlers
- Widget implementation connects BLoC to Swift

### Parallel Opportunities

- Phase 1: All tasks can run in parallel
- Phase 2: Model updates (T004-T008) can run in parallel with repository methods (T009-T010)
- Phase 4: Swift files (T014-T019) can run in parallel with Dart utility (T027-T030)
- Phase 5: Event definitions (T041-T043) can run in parallel
- Phase 6: Position buttons (T068-T072) can run in parallel
- US3 and US4 can be worked on in parallel by different developers

---

## Parallel Example: Swift NSPanel Implementation (Phase 4)

```bash
# All Swift file creation can happen together:
Task: "Create PopupWindowController.swift with NSPanel implementation"
Task: "Implement showPopup() method in PopupWindowController.swift"
Task: "Implement hidePopup() method in PopupWindowController.swift"
Task: "Implement updateHadith() method in PopupWindowController.swift"
Task: "Implement multi-display cursor detection in PopupWindowController.swift"
Task: "Implement PopupPositionCalculator struct in PopupWindowController.swift"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: Critical Bug Fix (scheduler hadithId)
4. Complete Phase 4: User Story 1 (Native NSPanel popup)
5. **STOP and VALIDATE**: Test popup appears independently of main app
6. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Fix Scheduler Bug → Popups actually display content
3. Add User Story 1 → Test independently → Native NSPanel popup (MVP!)
4. Add User Story 2 → Test independently → Hover interactions work
5. Add User Story 3 → Test independently → Position configurable
6. Add User Story 4 → Test independently → Duration configurable
7. Polish → Full feature complete

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: Swift NSPanel (Phase 4) + Platform Channel
   - Developer B: BLoC updates (Phase 4)
3. Once Phase 4 is done:
   - Developer A: User Story 3 (Position Picker)
   - Developer B: User Story 4 (Duration Slider)
   - Developer C: User Story 2 (Hover + Actions)

---

## Summary

- **Total Tasks**: 97
- **Tasks per phase**:
  - Phase 1 (Setup): 3
  - Phase 2 (Foundational): 8
  - Phase 3 (Bug Fix): 2
  - Phase 4 (US1 - Popup Display): 27
  - Phase 5 (US2 - Hover/Interact): 22
  - Phase 6 (US3 - Position): 14
  - Phase 7 (US4 - Duration): 7
  - Phase 8 (Polish): 14

**Parallel Opportunities**: 33 tasks marked [P] can run in parallel within their phases

**MVP Scope**: Phases 1-4 (Setup through User Story 1) = 39 tasks for a working native popup

**Independent Test Criteria**:
- US1: Popup appears when main app is hidden
- US2: Hover pauses timer, buttons work
- US3: Position picker saves and applies
- US4: Duration slider saves and applies
