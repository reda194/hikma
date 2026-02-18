# Tasks: Hikma MVP - Hadith Reminder App for macOS

**Input**: Design documents from `/specs/001-hadith-mvp/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/hadith-api-schema.md

**Tests**: Tests are OPTIONAL for this project - not explicitly requested in spec. Focus on implementation first.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Flutter macOS**: `lib/` for source, `test/` for tests
- **BLoC files**: `lib/bloc/<feature>/` containing bloc, event, state files
- **UI files**: `lib/ui/screens/` and `lib/ui/widgets/` and `lib/ui/popup/`
- **Models**: `lib/data/models/`
- **Repositories**: `lib/data/repositories/`
- **Services**: `lib/data/services/`
- **Constants**: `lib/core/constants/`
- **Theme**: `lib/core/theme/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic Flutter macOS structure

- [X] T001 Create Flutter macOS project structure in current directory
- [X] T002 Configure pubspec.yaml with dependencies (flutter_bloc ^8.1.0, hive_flutter ^1.1.0, dio ^5.4.0, window_manager ^0.3.0, system_tray ^2.0.0, flutter_acrylic ^1.1.0, google_fonts ^6.1.0, connectivity_plus ^5.0.0, equatable ^2.0.5)
- [X] T003 [P] Create lib/core/constants/ directory structure
- [X] T004 [P] Create lib/data/models/ directory structure
- [X] T005 [P] Create lib/data/repositories/ directory structure
- [X] T006 [P] Create lib/data/services/ directory structure
- [X] T007 [P] Create lib/bloc/ directory with subdirectories for hadith, scheduler, favorites, settings, popup
- [X] T008 [P] Create lib/ui/screens/, lib/ui/widgets/, lib/ui/popup/ directory structure
- [X] T009 [P] Create assets/data/, assets/fonts/, assets/images/ directories
- [X] T010 [P] Configure analysis_options.yaml for Dart/Flutter linting rules

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T011 Create app constants in lib/core/constants/app_constants.dart (app name, version, default values)
- [X] T012 Create collection constants in lib/core/constants/collection_constants.dart (HadithCollection enum values, API endpoints)
- [X] T013 Create storage keys in lib/core/constants/storage_keys.dart (Hive box names, key constants)
- [X] T014 [P] Create app theme in lib/core/theme/app_theme.dart (ThemeData, color palette from PRD)
- [X] T015 [P] Create app colors in lib/core/theme/app_colors.dart (#1B4F72, #117A65, #F8F9FA, #2C3E50, #EAF2F8)
- [X] T016 Initialize Hive in main.dart with boxes for settings, favorites, cache
- [X] T017 [P] Create Hadith model in lib/data/models/hadith.dart with Equatable
- [X] T018 [P] Create HadithCollection enum in lib/data/models/hadith_collection.dart
- [X] T019 [P] Create UserSettings model in lib/data/models/user_settings.dart with toJson/fromJson
- [X] T020 [P] Create Favorite model in lib/data/models/favorite.dart
- [X] T021 [P] Create ReminderInterval enum in lib/data/models/user_settings.dart (minutes30, hour1, hours2, hours4, hours8, daily)
- [X] T022 [P] Create PopupDuration enum in lib/data/models/user_settings.dart (seconds30, minute1, minutes2, minutes5, manual)
- [X] T023 [P] Create FontSize enum in lib/data/models/user_settings.dart (small, medium, large, extraLarge)
- [X] T024 Create HadithRepository interface in lib/data/repositories/hadith_repository.dart
- [X] T025 Create SettingsRepository in lib/data/repositories/settings_repository.dart (Hive persistence)
- [X] T026 Create FavoritesRepository in lib/data/repositories/favorites_repository.dart (Hive CRUD)
- [X] T027 Create HadithApiService in lib/data/services/hadith_api_service.dart (Dio client for api.hadith.gading.dev)
- [X] T028 Create LocalHadithService in lib/data/services/local_hadith_service.dart (bundled JSON loader)
- [X] T029 Create ConnectivityService in lib/data/services/connectivity_service.dart (connectivity_plus wrapper)
- [X] T030 Create bundled hadiths.json in assets/data/hadiths.json with 200-500 curated Hadiths
- [X] T031 Configure Google Fonts for Noto Naskh Arabic in pubspec.yaml
- [X] T032 Add menu bar icon asset (crescent moon) in assets/images/menu_bar_icon.png
- [X] T033 Update pubspec.yaml to include assets (hadiths.json, fonts, images)
- [X] T034 Create basic main.dart with MaterialApp and BLoC provider setup

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Scheduled Hadith Popup (Priority: P1) 🎯 MVP

**Goal**: Display Hadith popups automatically at configured intervals with draggable positioning and auto-dismiss timer

**Independent Test**: Launch app, wait for configured interval (default 1 hour for testing, use shorter value), verify popup appears with Arabic Hadith text, can be dismissed, position is remembered

### Implementation for User Story 1

- [X] T035 [P] [US1] Create HadithEvent in lib/bloc/hadith/hadith_event.dart (FetchRandomHadith, FilterByCollection, CacheHadith)
- [X] T036 [P] [US1] Create HadithState in lib/bloc/hadith/hadith_state.dart (HadithInitial, HadithLoading, HadithLoaded, HadithError)
- [X] T037 [US1] Create HadithBloc in lib/bloc/hadith/hadith_bloc.dart with FetchRandomHadith handler
- [X] T038 [US1] Implement HadithRepository.getRandomHadith() with offline fallback (API first, local JSON fallback)
- [X] T039 [US1] Implement HadithRepository.filterByCollection() for source filtering
- [X] T040 [P] [US1] Create SchedulerEvent in lib/bloc/scheduler/scheduler_event.dart (StartScheduler, StopScheduler, ResetTimer, SettingsChanged)
- [X] T041 [P] [US1] Create SchedulerState in lib/bloc/scheduler/scheduler_state.dart (SchedulerInitial, SchedulerRunning, SchedulerStopped)
- [X] T042 [US1] Create SchedulerBloc in lib/bloc/scheduler/scheduler_bloc.dart with Timer.periodic for popup scheduling
- [X] T043 [US1] Implement SchedulerBloc to listen to SettingsBloc changes and adjust interval dynamically
- [X] T044 [P] [US1] Create PopupEvent in lib/bloc/popup/popup_event.dart (ShowPopup, HidePopup, DismissPopup, StartAutoDismiss, UpdatePosition)
- [X] T045 [P] [US1] Create PopupState in lib/bloc/popup/popup_state.dart (PopupHidden, PopupVisible with countdown)
- [X] T046 [US1] Create PopupBloc in lib/bloc/popup/popup_bloc.dart with auto-dismiss timer logic
- [X] T047 [US1] Implement PopupBloc position tracking and persistence to Hive
- [X] T048 [US1] Create HadithPopup widget in lib/ui/popup/hadith_popup.dart with window_manager integration
- [X] T049 [US1] Implement draggable popup behavior using GestureDetector in HadithPopup
- [X] T050 [US1] Create PopupContent widget in lib/ui/popup/popup_content.dart with frosted glass effect (flutter_acrylic)
- [X] T051 [US1] Create HadithCard widget in lib/ui/widgets/hadith_card.dart with RTL Arabic text display
- [X] T052 [US1] Create CitationText widget in lib/ui/widgets/citation_text.dart for narrator/source/chapter display
- [X] T053 [US1] Implement BookmarkButton widget in lib/ui/widgets/bookmark_button.dart (star icon with filled/outline states)
- [X] T054 [US1] Wire HadithBloc to PopupBloc so ShowPopup event triggers Hadith fetch
- [X] T055 [US1] Wire SchedulerBloc to PopupBloc so timer triggers ShowPopup event
- [X] T056 [US1] Implement auto-dismiss countdown in PopupBloc with Timer
- [X] T057 [US1] Add popup position save/load using SettingsRepository
- [X] T058 [US1] Connect HadithCard BookmarkButton to FavoritesBloc (prepare FavoritesBloc event interface)
- [X] T059 [US1] Set up window_manager options in HadithPopup (480px width, adaptive height, hidden title bar, skip taskbar)
- [X] T060 [US1] Add window position bounds checking to keep popup visible on screen
- [X] T061 [US1] Implement long Hadith text handling with max height and scrolling
- [X] T062 [US1] Test scheduled popup with short interval (e.g., 30 seconds for development)

**Checkpoint**: At this point, User Story 1 should be fully functional - app shows Hadith popups on schedule, can be dismissed, position remembered

---

## Phase 4: User Story 2 - Offline Hadith Access (Priority: P1)

**Goal**: Ensure app works fully offline with bundled Hadiths, silent fallback when API fails

**Independent Test**: Disconnect internet, launch app, verify Hadith loads from local JSON, no error messages shown

### Implementation for User Story 2

- [X] T063 [P] [US2] Update HadithRepository to check ConnectivityService before API calls
- [X] T064 [US2] Implement silent error handling in HadithApiService (no exceptions thrown, fallback to local)
- [X] T065 [US2] Update HadithBloc to handle API failures gracefully without error states
- [X] T066 [US2] Implement LocalHadithService.loadHadiths() to parse bundled hadiths.json
- [X] T067 [US2] Add caching to HadithRepository - store API-fetched Hadiths in Hive cache box
- [X] T068 [US2] Implement cache expiration logic (e.g., 7 days) for cached Hadiths
- [X] T069 [US2] Update HadithRepository to check cache before API call when online
- [X] T070 [US2] Test offline mode: disconnect network, verify Hadith loads from bundled JSON
- [X] T071 [US2] Test online mode: verify API calls work and cache is populated
- [X] T072 [US2] Test transition: disconnect while online, verify app continues working with cached/bundled data
- [X] T073 [US2] Verify no user-facing error messages appear in any network scenario

**Checkpoint**: At this point, User Stories 1 AND 2 should both work - popups display reliably regardless of connectivity

---

## Phase 5: User Story 3 - Menu Bar Access & Quick Controls (Priority: P2)

**Goal**: Provide menu bar icon (crescent moon) with dropdown menu for quick access to all app features

**Independent Test**: Click menu bar icon, verify all menu options work (Show Hadith, Favorites, Settings, About, Quit)

### Implementation for User Story 3

- [X] T074 [P] [US3] Add system_tray package integration to main.dart
- [X] T075 [US3] Create MenuBarManager class in lib/core/utils/menu_bar_manager.dart
- [X] T076 [US3] Initialize SystemTray with crescent moon icon from assets/images/menu_bar_icon.png
- [X] T077 [US3] Create dropdown menu with options: "Show Hadith", "Favorites", "Settings", "About", "Quit"
- [X] T078 [US3] Wire "Show Hadith" menu item to PopupBloc.add(ShowPopup())
- [X] T079 [US3] Wire "Favorites" menu item to open FavoritesScreen (prepare screen)
- [X] T080 [US3] Wire "Settings" menu item to open SettingsScreen (prepare screen)
- [X] T081 [US3] Create AboutScreen in lib/ui/screens/about_screen.dart with app info
- [X] T082 [US3] Wire "About" menu item to show AboutScreen
- [X] T083 [US3] Wire "Quit" menu item to close app
- [X] T084 [US3] Add menu bar click handler to show popup on left-click
- [X] T085 [US3] Configure app to not show in Dock by default (LSUIElement in macOS)
- [X] T086 [US3] Test all menu bar options work correctly

**Checkpoint**: At this point, menu bar fully functional - all navigation and quick access working

---

## Phase 6: User Story 4 - Personalized Settings (Priority: P2)

**Goal**: Allow users to customize reminder interval, popup duration, source collection, font size, sound, auto-start, dock visibility

**Independent Test**: Open settings, change each option, verify behavior updates immediately and persists across restart

### Implementation for User Story 4

- [X] T087 [P] [US4] Create SettingsEvent in lib/bloc/settings/settings_event.dart (LoadSettings, UpdateSettings, UpdateReminderInterval, UpdatePopupDuration, UpdateSourceCollection, UpdateFontSize, ToggleSound, ToggleAutoStart, ToggleShowInDock)
- [X] T088 [P] [US4] Create SettingsState in lib/bloc/settings/settings_state.dart (SettingsInitial, SettingsLoaded)
- [X] T089 [US4] Create SettingsBloc in lib/bloc/settings/settings_bloc.dart with Hive persistence
- [X] T090 [US4] Implement SettingsBloc.loadSettings() to load from Hive or use defaults
- [X] T091 [US4] Implement SettingsBloc event handlers for each setting type
- [X] T092 [US4] Broadcast settings changes as stream for other BLoCs to listen
- [X] T093 [US4] Create SettingsScreen in lib/ui/screens/settings_screen.dart
- [X] T094 [US4] Create ReminderIntervalSelector widget with options (30min, 1h, 2h, 4h, 8h, daily)
- [X] T095 [US4] Create PopupDurationSelector widget with options (30s, 1min, 2min, 5min, manual)
- [X] T096 [US4] Create SourceCollectionSelector widget with collection options (All, Bukhari, Muslim, Abu Dawud, Tirmidhi, Ibn Majah, Nasa'i)
- [X] T097 [US4] Create FontSizeSelector widget with options (Small, Medium, Large, Extra Large)
- [X] T098 [US4] Create ToggleSwitch widgets for sound, auto-start, show in dock options
- [X] T099 [US4] Wire SettingsScreen to SettingsBloc via BlocProvider/BlocBuilder
- [X] T100 [US4] Connect SettingsBloc to SchedulerBloc for interval changes
- [X] T101 [US4] Connect SettingsBloc to PopupBloc for duration changes
- [X] T102 [US4] Connect SettingsBloc to HadithBloc for collection changes
- [X] T103 [US4] Connect SettingsBloc font size to HadithCard widget
- [X] T104 [US4] Add launch_at_login package for auto-start functionality
- [X] T105 [US4] Implement show/hide Dock icon based on setting
- [X] T106 [US4] Add notification sound player using audioplayers package
- [X] T107 [US4] Wire sound enabled setting to play sound on popup show
- [X] T108 [US4] Test all settings persist across app restart
- [X] T109 [US4] Test each setting change affects app behavior immediately

**Checkpoint**: At this point, User Stories 1-4 should all work - full customization available and functional

---

## Phase 7: User Story 5 - Favorites Management (Priority: P3)

**Goal**: Allow users to bookmark Hadiths, view favorites list, remove favorites

**Independent Test**: Bookmark several Hadiths, open favorites screen, verify all saved Hadiths appear, test remove functionality

### Implementation for User Story 5

- [X] T110 [P] [US5] Create FavoritesEvent in lib/bloc/favorites/favorites_event.dart (LoadFavorites, AddFavorite, RemoveFavorite, ToggleFavorite, IsFavorite)
- [X] T111 [P] [US5] Create FavoritesState in lib/bloc/favorites/favorites_state.dart (FavoritesInitial, FavoritesLoading, FavoritesLoaded, FavoritesError)
- [X] T112 [US5] Create FavoritesBloc in lib/bloc/favorites/favorites_bloc.dart
- [X] T113 [US5] Implement FavoritesBloc.addFavorite() to save to Hive favorites box
- [X] T114 [US5] Implement FavoritesBloc.removeFavorite() to delete from Hive
- [X] T115 [US5] Implement FavoritesBloc.toggleFavorite() with IsFavorite check
- [X] T116 [US5] Implement FavoritesBloc.loadFavorites() to retrieve all from Hive
- [X] T117 [US5] Update HadithBloc to check FavoritesBloc.isFavorite when loading Hadith
- [X] T118 [US5] Update HadithState to include isFavorite boolean
- [X] T119 [US5] Wire BookmarkButton in HadithCard to FavoritesBloc.toggleFavorite
- [X] T120 [US5] Update BookmarkButton to show filled/outline based on isFavorite state
- [X] T121 [US5] Create FavoritesScreen in lib/ui/screens/favorites_screen.dart
- [X] T122 [US5] Create FavoriteItem widget for displaying single favorited Hadith
- [X] T123 [US5] Create EmptyState widget for when no favorites saved
- [X] T124 [US5] Implement delete button/swipe on FavoriteItem to remove from favorites
- [X] T125 [US5] Wire FavoritesScreen to FavoritesBloc via BlocBuilder
- [X] T126 [US5] Test bookmarking Hadith updates button state immediately
- [X] T127 [US5] Test favorites persist across app restart
- [X] T128 [US5] Test favorites screen shows all saved Hadiths correctly

**Checkpoint**: At this point, all user stories should be independently functional - full MVP feature set complete

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [X] T129 [P] Add keyboard shortcut (Cmd+Shift+H) to show popup immediately using HotKey package
- [X] T130 [P] Optimize bundled hadiths.json size (minify, remove unnecessary whitespace)
- [X] T131 [P] Add app signing and sandboxing configuration in macos/Runner/*.entitlements
- [X] T132 [P] Configure app to auto-start on login via launch_at_login package
- [X] T133 [P] Add ProDir dependency (or similar) for production crash reporting
- [X] T134 Create README.md with project description, setup instructions, and credits
- [X] T135 Verify app binary size is under 50MB for Mac App Store
- [X] T136 Verify memory usage is under 50MB during normal operation
- [X] T137 Test app on different macOS versions (Big Sur, Monterey, Ventura, Sonoma)
- [X] T138 Create app icon set using iconutil for macOS app bundle
- [X] T139 Prepare App Store screenshots (macOS window showing popup, menu bar, settings)
- [X] T140 Write App Store description highlighting features (Arabic Hadith, offline-first, no tracking)
- [X] T141 Run quickstart.md validation - ensure all setup steps work
- [X] T142 Code cleanup: remove unused imports, format code with dart format
- [X] T143 Add dartdoc comments to all public APIs
- [X] T144 Verify RTL text rendering with various Arabic text lengths
- [X] T145 Test app behavior when system sleeps/wakes (scheduler should reset properly)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phases 3-7)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3 → P2 → P3)
- **Polish (Phase 8)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1 - Scheduled Popup)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P1 - Offline Access)**: Can start after Foundational (Phase 2) - Extends HadithRepository from US1
- **User Story 3 (P2 - Menu Bar)**: Can start after Foundational (Phase 2) - Independent of US1/US2
- **User Story 4 (P2 - Settings)**: Can start after Foundational (Phase 2) - Independent but broadcasts to other BLoCs
- **User Story 5 (P3 - Favorites)**: Can start after Foundational (Phase 2) - Integrates with HadithCard from US1

### Within Each User Story

- Events/states before BLoC implementation
- BLoC implementation before repository integration
- Repository implementation before UI wiring
- UI widgets before integration testing
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel (T003-T010)
- All Foundational model tasks marked [P] can run in parallel (T017-T023)
- Foundational service tasks marked [P] can run in parallel (T027-T029)
- Once Foundational phase completes:
  - User Stories 1, 3, 4, 5 can start in parallel (if team capacity allows)
  - User Story 2 should follow User Story 1 (extends same repository)
- Within each user story, all [P] marked tasks can run in parallel

---

## Parallel Example: User Story 1

```bash
# Launch event/state creation together:
Task: "Create HadithEvent in lib/bloc/hadith/hadith_event.dart"
Task: "Create SchedulerEvent in lib/bloc/scheduler/scheduler_event.dart"
Task: "Create PopupEvent in lib/bloc/popup/popup_event.dart"

# Launch widget creation together:
Task: "Create HadithCard widget in lib/ui/widgets/hadith_card.dart"
Task: "Create CitationText widget in lib/ui/widgets/citation_text.dart"
Task: "Create BookmarkButton widget in lib/ui/widgets/bookmark_button.dart"
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 2 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1 (Scheduled Popup)
4. Complete Phase 4: User Story 2 (Offline Access)
5. **STOP and VALIDATE**: Test core popup functionality works on and offline
6. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP core!)
3. Add User Story 2 → Test independently → Deploy/Demo (MVP complete!)
4. Add User Story 3 → Test independently → Deploy/Demo (Menu bar added)
5. Add User Story 4 → Test independently → Deploy/Demo (Settings added)
6. Add User Story 5 → Test independently → Deploy/Demo (Full feature set)

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1 (Scheduled Popup) + User Story 2 (Offline Access)
   - Developer B: User Story 3 (Menu Bar) + User Story 4 (Settings)
   - Developer C: User Story 5 (Favorites) - starts after HadithCard from Developer A is stable
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
- Constitution compliance: verify all 6 principles are upheld in implementation

---

## Task Summary

| Phase | Task Count | Description |
|-------|------------|-------------|
| Phase 1: Setup | 10 tasks | Project initialization and structure |
| Phase 2: Foundational | 24 tasks | Models, repositories, services, Hive setup |
| Phase 3: US1 - Scheduled Popup | 28 tasks | Core popup functionality with BLoCs and UI |
| Phase 4: US2 - Offline Access | 11 tasks | Offline-first reliability |
| Phase 5: US3 - Menu Bar | 13 tasks | Menu bar integration and navigation |
| Phase 6: US4 - Settings | 23 tasks | Settings screen and personalization |
| Phase 7: US5 - Favorites | 19 tasks | Favorites management |
| Phase 8: Polish | 17 tasks | Cross-cutting improvements |
| **Total** | **145 tasks** | Full MVP implementation |

---

*Tasks Document v1.0 | Generated: 2026-02-18*
