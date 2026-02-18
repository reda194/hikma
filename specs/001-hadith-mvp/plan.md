# Implementation Plan: Hikma MVP - Hadith Reminder App for macOS

**Branch**: `001-hadith-mvp` | **Date**: 2026-02-18 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-hadith-mvp/spec.md`

## Summary

Hikma is a macOS desktop application that delivers authentic Hadith (Prophetic narrations) through non-intrusive floating popups at scheduled intervals. The app runs silently in the background, accessible via a menu bar icon, and provides spiritual content in Arabic with proper citations.

**Technical Approach**: Built with Flutter for macOS Desktop using BLoC architecture for state management. Data is stored locally using Hive with bundled JSON fallback for offline-first reliability. The app uses native macOS integrations (menu bar, window management) to feel like a native application.

---

## Technical Context

**Language/Version**: Dart 3.3+ (Flutter 3.19+)
**Primary Dependencies**: flutter_bloc, hive_flutter, dio, window_manager, system_tray, flutter_acrylic, google_fonts, connectivity_plus, equatable
**Storage**: Hive (local key-value) + bundled JSON (Hadith content)
**Testing**: flutter_test (widget tests), bloc_test (BLoC tests), integration_test
**Target Platform**: macOS 11+ (Big Sur or later)
**Project Type**: single (Flutter macOS desktop)
**Performance Goals**: <50MB memory usage, <2s cold start, 60fps animations
**Constraints**: <50MB binary size, offline-capable, sandboxed for Mac App Store
**Scale/Scope**: ~500 bundled Hadiths, 5 BLoCs (HadithBloc, SchedulerBloc, FavoritesBloc, SettingsBloc, PopupBloc), ~15 screens/widgets

---

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Per `.specify/memory/constitution.md`, all features MUST satisfy:

| Principle | Status | Notes |
|-----------|--------|-------|
| **Simplicity** | ✅ PASS | Single-purpose app focused on Hadith delivery. All features directly support core mission. |
| **Offline-First** | ✅ PASS | Bundled JSON with 200-500 Hadiths ensures full offline functionality. API is enhancement only. |
| **BLoC Architecture** | ✅ PASS | 5 BLoCs defined (HadithBloc, SchedulerBloc, FavoritesBloc, SettingsBloc, PopupBloc) with clear separation. |
| **macOS Native** | ✅ PASS | Menu bar integration, frosted glass effects, draggable windows, proper sandboxing planned. |
| **Authentic Content** | ✅ PASS | All Hadiths include narrator name, source book, chapter reference. Only authentic collections (Sihah Sittah). |
| **Privacy** | ✅ PASS | No analytics, no account system, all data stored locally via Hive. |

**Result**: All gates passed. No violations to justify.

---

## Project Structure

### Documentation (this feature)

```text
specs/001-hadith-mvp/
├── plan.md              # This file
├── research.md          # Phase 0: Technical research and decisions
├── data-model.md        # Phase 1: Entity definitions and data flow
├── quickstart.md        # Phase 1: Developer setup guide
├── contracts/           # Phase 1: API contracts and data schemas
└── tasks.md             # Phase 2: Implementation tasks (via /speckit.tasks)
```

### Source Code (repository root)

```text
lib/
├── core/                          # Shared app-wide resources
│   ├── constants/
│   │   ├── app_constants.dart     # App metadata, defaults
│   │   ├── collection_constants.dart # Hadith collection definitions
│   │   └── storage_keys.dart      # Hive box/key constants
│   ├── theme/
│   │   ├── app_theme.dart         # Color palette, typography
│   │   └── app_colors.dart        # Color constants (#1B4F72, #117A65, etc.)
│   └── utils/
│       ├── connectvity_utils.dart # Network status helpers
│       └── position_utils.dart    # Window position calculations
│
├── data/                          # Data layer (models, repositories, services)
│   ├── models/
│   │   ├── hadith.dart            # Hadith entity
│   │   ├── user_settings.dart     # User settings entity
│   │   ├── favorite.dart          # Favorite entity
│   │   └── hadith_collection.dart # Collection enum/metadata
│   ├── repositories/
│   │   ├── hadith_repository.dart # Hadith data access (local + API)
│   │   ├── settings_repository.dart # Settings persistence (Hive)
│   │   └── favorites_repository.dart # Favorites CRUD (Hive)
│   └── services/
│       ├── hadith_api_service.dart # External API client (Dio)
│       ├── local_hadith_service.dart # Bundled JSON loader
│       └── connectivity_service.dart  # Network status wrapper
│
├── bloc/                          # BLoC state management
│   ├── hadith/
│   │   ├── hadith_event.dart
│   │   ├── hadith_state.dart
│   │   └── hadith_bloc.dart       # Hadith fetching, filtering, caching
│   ├── scheduler/
│   │   ├── scheduler_event.dart
│   │   ├── scheduler_state.dart
│   │   └── scheduler_bloc.dart    # Timer management, popup triggering
│   ├── favorites/
│   │   ├── favorites_event.dart
│   │   ├── favorites_state.dart
│   │   └── favorites_bloc.dart    # Add/remove/load favorites
│   ├── settings/
│   │   ├── settings_event.dart
│   │   ├── settings_state.dart
│   │   └── settings_bloc.dart     # Settings load/save/broadcast
│   └── popup/
│       ├── popup_event.dart
│       ├── popup_state.dart
│       └── popup_bloc.dart        # Popup visibility, position, auto-dismiss
│
├── ui/                            # UI layer (screens, widgets)
│   ├── screens/
│   │   ├── settings_screen.dart   # Settings configuration
│   │   ├── favorites_screen.dart  # Favorites list
│   │   └── about_screen.dart      # App info
│   ├── widgets/
│   │   ├── hadith_card.dart       # Hadith display widget
│   │   ├── citation_text.dart     # Narrator/source display
│   │   ├── bookmark_button.dart   # Star icon with state
│   │   └── empty_state.dart       # Empty favorites message
│   └── popup/
│       ├── hadith_popup.dart      # Main floating popup window
│       └── popup_content.dart     # Popup internal layout
│
└── main.dart                      # App entry point

assets/
├── data/
│   └── hadiths.json              # Bundled Hadith collection (200-500)
├── fonts/
│   └── NotoNaskhArabic/          # Arabic font files
└── images/
    └── menu_bar_icon.png         # Crescent moon icon

test/
├── widget/                        # Widget tests
├── bloc/                          # BLoC tests
└── integration/                   # End-to-end tests
```

**Structure Decision**: Flutter macOS desktop application with enforced BLoC architecture per constitution. Clean separation between data (repositories), business logic (BLoCs), and presentation (UI).

---

## Complexity Tracking

> **No violations - this section intentionally left empty**

All constitution gates passed without requiring justifications for complexity.

---

## Phase 0: Research & Decisions

See [research.md](./research.md) for detailed technical research including:

1. **Hadith API Selection** - Analysis of api.hadith.gading.dev vs alternatives
2. **BLoC Implementation Patterns** - Event/state design patterns for Flutter 3.19
3. **macOS Window Management** - window_manager package for floating popups
4. **Menu Bar Integration** - system_tray package patterns for macOS
5. **Offline-First Architecture** - Hive + bundled JSON data strategy
6. **RTL Text Handling** - Flutter Directionality and Arabic typography
7. **Frosted Glass Effects** - flutter_acrylic vs platform-channel approaches

---

## Phase 1: Design Artifacts

### Data Model

See [data-model.md](./data-model.md) for complete entity definitions including:
- Hadith entity with fields and validation
- UserSettings entity with defaults
- Favorite entity with relationships
- HadithCollection enum and metadata
- State transition diagrams for each BLoC

### API Contracts

See [contracts/](./contracts/) directory for:
- Hadith API response schema
- Local JSON bundling format
- Hive storage schema
- Settings serialization format

### Quickstart Guide

See [quickstart.md](./quickstart.md) for:
- Development environment setup
- Running the app locally
- Adding new Hadiths to bundled collection
- Testing offline mode
- Building for Mac App Store

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 0 (Research) → Phase 1 (Design) → Phase 2 (Implementation)
     ↓                      ↓                    ↓
  Technical          Data Model,          Task breakdown
  Decisions          Contracts,           via /speckit.tasks
  Made               Quickstart
```

### User Story Implementation Order

Based on spec priorities (P1 → P2 → P3):

1. **P1 - Scheduled Hadith Popup** (Core value)
   - Requires: HadithBloc, SchedulerBloc, PopupBloc, hadith repository
   - Dependencies: Local JSON service, popup UI components

2. **P1 - Offline Hadith Access** (Reliability)
   - Requires: HadithBloc with fallback logic, bundled JSON
   - Dependencies: Hadith repository with offline mode

3. **P2 - Menu Bar Access** (Navigation)
   - Requires: system_tray integration, menu handlers
   - Dependencies: SettingsBloc for state, main app coordination

4. **P2 - Personalized Settings** (Customization)
   - Requires: SettingsBloc, settings repository, settings screen UI
   - Dependencies: Hive setup, settings persistence

5. **P3 - Favorites Management** (Enhancement)
   - Requires: FavoritesBloc, favorites repository, favorites screen UI
   - Dependencies: Hadith entity, Hive setup

### Parallel Opportunities

After foundational setup (Hive, repositories, BLoC structure):
- User Stories 1 and 2 can be developed in parallel (share HadithBloc)
- User Stories 3 and 4 can be developed in parallel (independent features)
- User Story 5 depends on Hadith entity being stable

---

## Next Steps

1. **Review** This plan to confirm technical approach aligns with expectations
2. **Run** `/speckit.tasks` to generate detailed implementation tasks
3. **Begin** Phase 1 (Setup) following task order
4. **Verify** each user story independently before proceeding

---

*Implementation Plan v1.0 | Generated: 2026-02-18*
