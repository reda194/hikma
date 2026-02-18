# Tasks: Hikma App Enhancements & Completion

**Input**: Design documents from `/specs/enhancements_194/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/bloc-events-states.md

**Tests**: Tests are OPTIONAL. This spec includes test tasks as BLoC and widget tests are part of the success criteria (SC-016, SC-017, SC-018). Include test tasks for each story.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Flutter macOS**: `lib/` for source, `test/` for tests
- **BLoC files**: `lib/bloc/<feature>/` containing bloc, event, state files
- **UI files**: `lib/ui/screens/` and `lib/ui/widgets/`
- **Models**: `lib/data/models/`
- **Tests**: `test/widget/`, `test/bloc/`, `test/integration/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and compilation fixes

- [ ] T001 Run flutter analyze and fix all compilation errors per research.md #20
- [ ] T002 Fix corrupted first Hadith in assets/data/hadiths.json (replace with "إنما الأعمال بالنيات")
- [ ] T003 Verify pubspec.yaml includes all required packages (launch_at_login, hotkey_manager, audioplayers)
- [ ] T004 [P] Create sounds directory at assets/sounds/ and add notification.mp3 placeholder

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T005 Add darkModeEnabled property to UserSettings model in lib/data/models/user_settings.dart
- [ ] T006 Add init() method call in _HikmaHomeState._initialize() in lib/ui/screens/home_screen.dart
- [ ] T007 Wire SchedulerBloc start in _HikmaHomeState._initialize() in lib/ui/screens/home_screen.dart
- [ ] T008 Add BlocListener for SettingsBloc to restart scheduler on interval change in lib/ui/screens/home_screen.dart
- [ ] T009 Create AudioService class in lib/data/services/audio_service.dart
- [ ] T010 [P] Remove unused HadithPopup and HadithPopupDialog classes from lib/ui/popup/hadith_popup.dart
- [ ] T011 Verify HadithPopupOverlay is properly wired in lib/main.dart

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - App Works on First Launch (Priority: P1) 🎯 MVP

**Goal**: App initializes properly, loads settings, starts background scheduler, menu bar icon appears, Hadith popups begin appearing

**Independent Test**: Launch the app fresh (no previous data), verify menu bar icon appears within 3 seconds, and a Hadith popup appears at the configured interval

### Tests for User Story 1

- [ ] T012 [P] [US1] Widget test for HikmaHome initialization in test/widget/home_screen_test.dart
- [ ] T013 [P] [US1] BLoC test for SchedulerBloc start/stop in test/bloc/scheduler_bloc_test.dart

### Implementation for User Story 1

- [ ] T014 [US1] Implement _initialize() method in _HikmaHomeState in lib/ui/screens/home_screen.dart
- [ ] T015 [US1] Wire HadithRepository.init() call in _initialize() method in lib/ui/screens/home_screen.dart
- [ ] T016 [US1] Wire SettingsRepository.init() call in _initialize() method in lib/ui/screens/home_screen.dart
- [ ] T017 [US1] Wire SettingsBloc.LoadSettings event in _initialize() method in lib/ui/screens/home_screen.dart
- [ ] T018 [US1] Wire SchedulerBloc.StartScheduler event after settings load in lib/ui/screens/home_screen.dart
- [ ] T019 [US1] Add BlocListener for SettingsBloc to restart scheduler on interval change in lib/ui/screens/home_screen.dart
- [ ] T020 [US1] Verify menu bar icon appears within 3 seconds in lib/core/utils/menu_bar_manager.dart

**Checkpoint**: At this point, User Story 1 should be fully functional - app launches and popups appear automatically

---

## Phase 4: User Story 2 - View Varied Hadith Content (Priority: P1)

**Goal**: Each popup shows different content without excessive repetition, Hadith collection spans multiple authentic sources

**Independent Test**: Receive 20 popups over 2 days and verify no duplicate Hadiths appear (history tracking prevents repeats)

### Tests for User Story 2

- [ ] T021 [P] [US2] BLoC test for history tracking in HadithBloc in test/bloc/hadith_bloc_test.dart

### Implementation for User Story 2

- [ ] T022 [US2] Add recentlyShownIds property to HadithLoaded state in lib/bloc/hadith/hadith_state.dart
- [ ] T023 [US2] Add saveHistory() method to HadithRepository in lib/data/repositories/hadith_repository.dart
- [ ] T024 [US2] Add loadHistory() method to HadithRepository in lib/data/repositories/hadith_repository.dart
- [ ] T025 [US2] Update FetchRandomHadith handler to exclude history IDs in lib/bloc/hadith/hadith_bloc.dart
- [ ] T026 [US2] Persist history to Hive after each Hadith fetch in lib/bloc/hadith/hadith_bloc.dart
- [ ] T027 [US2] Expand assets/data/hadiths.json to 200+ Hadiths (60 Bukhari, 50 Muslim, 30 Abu Dawud, 25 Tirmidhi, 20 Ibn Majah, 15 Nasa'i)
- [ ] T028 [US2] Fix corrupted first Hadith entry in assets/data/hadiths.json

**Checkpoint**: At this point, User Story 2 should be fully functional - 200+ unique Hadiths with no-repeat tracking

---

## Phase 5: User Story 10 - Graceful Error Handling (Priority: P1)

**Goal**: App continues working offline with graceful fallbacks, friendly error messages when data fails

**Independent Test**: Disconnect internet, launch app, verify it loads from offline dataset. Corrupt offline data, verify friendly error message

### Tests for User Story 10

- [ ] T029 [P] [US10] Widget test for error state display in test/widget/popup_content_test.dart

### Implementation for User Story 10

- [ ] T030 [US10] Add offline fallback logic to HadithRepository.fetchRandom() in lib/data/repositories/hadith_repository.dart
- [ ] T031 [US10] Add HadithError state with friendly message in lib/bloc/hadith/hadith_state.dart
- [ ] T032 [US10] Emit HadithError when both API and offline data fail in lib/bloc/hadith/hadith_bloc.dart
- [ ] T033 [US10] Handle HadithError state in PopupContent widget in lib/ui/popup/popup_content.dart
- [ ] T034 [US10] Add empty state UI for when no Hadith can be loaded in lib/ui/popup/popup_content.dart

**Checkpoint**: At this point, User Story 10 should be fully functional - app works offline with graceful error handling

---

## Phase 6: User Story 3 - Access Today's Featured Hadith (Priority: P2)

**Goal**: Special Hadith selected for the day, accessible from menu bar, remains same throughout the day

**Independent Test**: Open menu bar, select "Today's Hadith", verify it shows. Open again 2 hours later, verify the same Hadith appears

### Tests for User Story 3

- [ ] T035 [P] [US3] BLoC test for daily Hadith refresh logic in test/bloc/hadith_bloc_test.dart

### Implementation for User Story 3

- [ ] T036 [US3] Create DailyHadith model in lib/data/models/daily_hadith.dart
- [ ] T037 [US3] Add LoadDailyHadith event to HadithBloc in lib/bloc/hadith/hadith_event.dart
- [ ] T038 [US3] Add AddRefreshDailyHadith event to HadithBloc in lib/bloc/hadith/hadith_event.dart
- [ ] T039 [US3] Add dailyHadith property to HadithLoaded state in lib/bloc/hadith/hadith_state.dart
- [ ] T040 [US3] Implement daily Hadith storage in Hive in lib/data/repositories/hadith_repository.dart
- [ ] T041 [US3] Implement date comparison logic to refresh daily Hadith in lib/data/repositories/hadith_repository.dart
- [ ] T042 [US3] Add "Today's Hadith" menu item to MenuBarManager in lib/core/utils/menu_bar_manager.dart
- [ ] T043 [US3] Wire LoadDailyHadith event from menu bar in lib/core/utils/menu_bar_manager.dart

**Checkpoint**: At this point, User Story 3 should be fully functional - daily featured Hadith accessible from menu bar

---

## Phase 7: User Story 4 - Save and Organize Favorites (Priority: P2)

**Goal**: Star Hadiths to save them, browse favorites in Favorites screen, search by text

**Independent Test**: Star 3 different Hadiths, open Favorites screen, verify all 3 appear. Use search to find one by text

### Tests for User Story 4

- [ ] T044 [P] [US4] Widget test for FavoritesScreen in test/widget/favorites_screen_test.dart
- [ ] T045 [P] [US4] BLoC test for FavoritesBloc search in test/bloc/favorites_bloc_test.dart

### Implementation for User Story 4

- [ ] T046 [US4] Add searchQuery property to FavoritesLoaded state in lib/bloc/favorites/favorites_state.dart
- [ ] T047 [US4] Add displayedFavorites computed property to FavoritesLoaded in lib/bloc/favorites/favorites_state.dart
- [ ] T048 [US4] Add SearchFavorites event to FavoritesBloc in lib/bloc/favorites/favorites_event.dart
- [ ] T049 [US4] Implement search handler in FavoritesBloc in lib/bloc/favorites/favorites_bloc.dart
- [ ] T050 [US4] Create search bar widget in lib/ui/widgets/search_bar.dart
- [ ] T051 [US4] Add search bar to FavoritesScreen in lib/ui/screens/favorites_screen.dart
- [ ] T052 [US4] Add empty state UI for no favorites in lib/ui/screens/favorites_screen.dart
- [ ] T053 [US4] Add empty state UI for no search results in lib/ui/screens/favorites_screen.dart

**Checkpoint**: At this point, User Story 4 should be fully functional - favorites with search capability

---

## Phase 8: User Story 5 - Personalized App Experience (Priority: P2)

**Goal**: Adjust font size, reminder frequency, popup duration, sound notifications, dark mode, auto-start behavior

**Independent Test**: Change each setting, verify it takes effect immediately or on next popup

### Tests for User Story 5

- [ ] T054 [P] [US5] BLoC test for SettingsBloc dark mode toggle in test/bloc/settings_bloc_test.dart
- [ ] T055 [P] [US5] BLoC test for SettingsBloc auto-start toggle in test/bloc/settings_bloc_test.dart

### Implementation for User Story 5

- [ ] T056 [US5] Wire ToggleAutoStart event to launch_at_login package in lib/bloc/settings/settings_bloc.dart
- [ ] T057 [US5] Add macOS entitlement for auto-start in macos/Runner/DebugProfile.entitlements
- [ ] T058 [US5] Add macOS entitlement for auto-start in macos/Runner/Release.entitlements
- [ ] T059 [US5] Add ToggleDarkMode event to SettingsBloc in lib/bloc/settings/settings_event.dart
- [ ] T060 [US5] Handle ToggleDarkMode in SettingsBloc in lib/bloc/settings/settings_bloc.dart
- [ ] T061 [US5] Wire ThemeMode to darkModeEnabled setting in lib/main.dart
- [ ] T062 [US5] Wire AudioService.playNotificationSound() to PopupBloc in lib/bloc/popup/popup_bloc.dart
- [ ] T063 [US5] Verify soundEnabled setting triggers audio playback in lib/bloc/popup/popup_bloc.dart

**Checkpoint**: At this point, User Story 5 should be fully functional - all settings work including dark mode and auto-start

---

## Phase 9: User Story 6 - Quick Access via Keyboard (Priority: P3)

**Goal**: Press Command+Shift+H to immediately show a Hadith popup

**Independent Test**: Press Cmd+Shift+H, verify popup appears within 1 second

### Tests for User Story 6

- [ ] T064 [P] [US6] Integration test for keyboard shortcut in test/integration/keyboard_shortcut_test.dart

### Implementation for User Story 6

- [ ] T065 [US6] Initialize HotKeyManager in MenuBarManager.init() in lib/core/utils/menu_bar_manager.dart
- [ ] T066 [US6] Register Cmd+Shift+H hotkey in MenuBarManager.init() in lib/core/utils/menu_bar_manager.dart
- [ ] T067 [US6] Wire hotkey handler to FetchRandomHadith event in lib/core/utils/menu_bar_manager.dart
- [ ] T068 [US6] Dispose HotKeyManager on app exit in lib/core/utils/menu_bar_manager.dart

**Checkpoint**: At this point, User Story 6 should be fully functional - keyboard shortcut shows popup

---

## Phase 10: User Story 8 - Share Hadith with Others (Priority: P3)

**Goal**: Copy Hadith to clipboard with formatted string (Arabic text — Narrator | Source)

**Independent Test**: Tap copy button, paste into text editor, verify format includes Arabic text, narrator, and source

### Tests for User Story 8

- [ ] T069 [P] [US8] Widget test for copy to clipboard in test/widget/popup_content_test.dart

### Implementation for User Story 8

- [ ] T070 [US8] Create copyHadithToClipboard() function in lib/ui/popup/popup_content.dart
- [ ] T071 [US8] Format clipboard text as "Arabic — Narrator | Source" in lib/ui/popup/popup_content.dart
- [ ] T072 [US8] Add copy button to PopupContent widget in lib/ui/popup/popup_content.dart
- [ ] T073 [US8] Show SnackBar confirmation "Hadith copied" after copy in lib/ui/popup/popup_content.dart
- [ ] T074 [US8] Import flutter/services.dart for Clipboard in lib/ui/popup/popup_content.dart

**Checkpoint**: At this point, User Story 8 should be fully functional - copy to clipboard works with proper formatting

---

## Phase 11: User Story 9 - View Reading Statistics (Priority: P3)

**Goal**: Track daily and weekly Hadith read counts, display in Settings

**Independent Test**: Read 5 Hadiths in a day, open Settings, verify counter shows 5 for today

### Tests for User Story 9

- [ ] T075 [P] [US9] BLoC test for statistics tracking in test/bloc/hadith_bloc_test.dart

### Implementation for User Story 9

- [ ] T076 [US9] Create ReadStatistics model in lib/data/models/read_statistics.dart
- [ ] T077 [US9] Add getTodayCount() method to ReadStatistics in lib/data/models/read_statistics.dart
- [ ] T078 [US9] Add getWeekCount() method to ReadStatistics in lib/data/models/read_statistics.dart
- [ ] T079 [US9] Add incrementToday() method to ReadStatistics in lib/data/models/read_statistics.dart
- [ ] T080 [US9] Add IncrementReadCount event to HadithBloc in lib/bloc/hadith/hadith_event.dart
- [ ] T081 [US9] Handle IncrementReadCount in HadithBloc in lib/bloc/hadith/hadith_bloc.dart
- [ ] T082 [US9] Create stats widget in lib/ui/widgets/stats_widget.dart
- [ ] T083 [US9] Add stats display to SettingsScreen in lib/ui/screens/settings_screen.dart

**Checkpoint**: At this point, User Story 9 should be fully functional - reading statistics tracked and displayed

---

## Phase 12: User Story 7 - Contemplation Mode (Priority: P3)

**Goal**: Full-screen, distraction-free Hadith reading with large text and dark gradient background

**Independent Test**: Open Contemplation Mode, verify full-screen display with minimal distractions. Press Escape to exit

### Tests for User Story 7

- [ ] T084 [P] [US7] Widget test for ContemplationScreen in test/widget/contemplation_screen_test.dart

### Implementation for User Story 7

- [ ] T085 [US7] Create ContemplationScreen widget in lib/ui/screens/contemplation_screen.dart
- [ ] T086 [US7] Add full-screen route with gradient background in lib/ui/screens/contemplation_screen.dart
- [ ] T087 [US7] Add large centered Arabic text display in lib/ui/screens/contemplation_screen.dart
- [ ] T088 [US7] Add "Next Hadith" button to ContemplationScreen in lib/ui/screens/contemplation_screen.dart
- [ ] T089 [US7] Add "Bookmark" button to ContemplationScreen in lib/ui/screens/contemplation_screen.dart
- [ ] T090 [US7] Add Escape key handler to exit ContemplationMode in lib/ui/screens/contemplation_screen.dart
- [ ] T091 [US7] Add fade-in animation (300ms) to ContemplationScreen in lib/ui/screens/contemplation_screen.dart
- [ ] T092 [US7] Add "Contemplation Mode" menu item to MenuBarManager in lib/core/utils/menu_bar_manager.dart

**Checkpoint**: At this point, User Story 7 should be fully functional - contemplation mode provides focused reading experience

---

## Phase 13: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T093 [P] Add visual countdown progress bar to PopupContent in lib/ui/popup/popup_content.dart
- [ ] T094 [P] Create OnboardingScreen widget in lib/ui/screens/onboarding_screen.dart
- [ ] T095 Add hasSeenOnboarding check to _initialize() in lib/ui/screens/home_screen.dart
- [ ] T096 [P] Verify popup position memory works correctly in lib/ui/popup/hadith_popup.dart
- [ ] T097 [P] Update menu bar with all items (Show Hadith Now, Today's Hadith, Favorites, Settings, About, Quit) in lib/core/utils/menu_bar_manager.dart
- [ ] T098 [P] Add empty state illustrations for favorites and search results in lib/ui/screens/favorites_screen.dart
- [ ] T099 Verify app window hides instead of quitting on close in lib/main.dart
- [ ] T100 [P] Add BLoC tests for all state transitions in test/bloc/
- [ ] T101 [P] Add widget tests for all screens in test/widget/
- [ ] T102 Create integration test for full user journey in test/integration/app_flow_test.dart

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-12)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Phase 13)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 10 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 3 (P2)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 4 (P2)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 5 (P2)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 6 (P3)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 8 (P3)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 9 (P3)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 7 (P3)**: Can start after Foundational (Phase 2) - No dependencies on other stories

### Within Each User Story

- Tests should be written before or alongside implementation
- Models before services
- Services before BLoC handlers
- BLoC before UI widgets
- UI integration after BLoC is complete

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel (T003, T004)
- All Foundational tasks marked [P] can run in parallel (T010)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tests for each story marked [P] can run in parallel
- Within US1: T012, T013 can run in parallel
- Within US2: T021 can run in parallel with implementation
- Within US3: T035 can run in parallel with implementation
- Within US4: T044, T045 can run in parallel
- Within US5: T054, T055 can run in parallel
- Within US7: T084 can run in parallel with implementation
- Within US8: T069 can run in parallel with implementation
- Within US9: T075 can run in parallel with implementation
- Polish tasks T093-T099 can all run in parallel
- Test tasks T100-T102 can run in parallel

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together:
Task: "T012 [P] [US1] Widget test for HikmaHome initialization in test/widget/home_screen_test.dart"
Task: "T013 [P] [US1] BLoC test for SchedulerBloc start/stop in test/bloc/scheduler_bloc_test.dart"

# After tests, implementation tasks proceed sequentially (T014-T020 have dependencies)
```

---

## Implementation Strategy

### MVP First (User Stories 1, 2, 10 Only - All P1)

1. Complete Phase 1: Setup (T001-T004)
2. Complete Phase 2: Foundational (T005-T011) - CRITICAL
3. Complete Phase 3: User Story 1 (T012-T020) - App launches and popups appear
4. Complete Phase 4: User Story 2 (T021-T028) - Varied Hadith content
5. Complete Phase 5: User Story 10 (T029-T034) - Graceful error handling
6. **STOP and VALIDATE**: Test all P1 stories independently
7. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add P1 stories (US1, US2, US10) → Test independently → Deploy/Demo (MVP!)
3. Add P2 stories (US3, US4, US5) → Test independently → Deploy/Demo
4. Add P3 stories (US6, US7, US8, US9) → Test independently → Deploy/Demo
5. Complete Polish → Final release

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Stories 1, 2 (P1)
   - Developer B: User Stories 3, 4, 5 (P2)
   - Developer C: User Stories 6, 7, 8, 9, 10 (P3/P1)
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Follow BLoC architecture: State changes ONLY through BLoC events
- All Hadith content MUST be offline-capable (bundled JSON)
- Privacy: no telemetry, analytics, or cloud sync in implementation

---

## Summary

- **Total Tasks**: 102
- **Setup Phase**: 4 tasks
- **Foundational Phase**: 7 tasks
- **User Story Phases**: 91 tasks across 10 user stories
  - US1 (P1): 9 tasks
  - US2 (P1): 8 tasks
  - US10 (P1): 6 tasks
  - US3 (P2): 9 tasks
  - US4 (P2): 10 tasks
  - US5 (P2): 10 tasks
  - US6 (P3): 5 tasks
  - US8 (P3): 6 tasks
  - US9 (P3): 9 tasks
  - US7 (P3): 9 tasks
- **Polish Phase**: 10 tasks
- **Parallel Opportunities**: 35 tasks marked [P]

**Suggested MVP Scope**: Phases 1-5 (Setup + Foundational + P1 User Stories 1, 2, 10) = 34 tasks
