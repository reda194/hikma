# Implementation Plan: Hikma App Enhancements & Completion

**Branch**: `enhancements_194` | **Date**: 2026-02-18 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/enhancements_194/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Complete the Hikma Hadith reminder macOS application by implementing critical fixes, core features, polish items, and testing. The app architecture exists (BLoC pattern, offline-first data layer) but requires proper initialization, expanded content (200+ Hadiths), and missing user-facing features.

**Technical Approach**: Fix initialization pipeline, expand bundled Hadith dataset, implement BLoC wiring for settings-driven scheduler restart, add history tracking for no-repeat logic, implement favorites search, wire up existing packages (launch_at_login, hotkey_manager, audioplayers), add dark mode toggle, onboarding screen, and comprehensive test coverage.

## Technical Context

**Language/Version**: Dart 3.3+ (Flutter 3.19+)
**Primary Dependencies**: flutter_bloc, hive_flutter, dio, window_manager, system_tray, flutter_acrylic, google_fonts, connectivity_plus, equatable, launch_at_login, hotkey_manager, audioplayers
**Storage**: Hive (local key-value) + bundled JSON (Hadith content)
**Testing**: flutter_test (widget tests), bloc_test (BLoC tests), integration_test
**Target Platform**: macOS 11+ (Big Sur or later)
**Project Type**: single (Flutter macOS desktop)
**Performance Goals**: <50MB memory usage, <2s cold start, 60fps animations
**Constraints**: <50MB binary size, offline-capable, sandboxed for Mac App Store
**Scale/Scope**: 200+ bundled Hadiths, 5 existing BLoCs, ~15 screens/widgets

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Per `.specify/memory/constitution.md`, all features MUST satisfy:

- [x] **Simplicity**: Feature justified against core mission? No unnecessary complexity?
  - **PASS**: All enhancements directly support Hadith delivery (no-repeats, favorites, stats) or improve UX (settings, dark mode, shortcuts). No feature creep.
- [x] **Offline-First**: Does it work without internet? Bundled data sufficient?
  - **PASS**: Expanding bundled JSON to 200+ Hadiths. All features work offline (favorites, search, stats, contemplation mode).
- [x] **BLoC Architecture**: State in BLoC only? No widget-side business logic?
  - **PASS**: All new features follow existing BLoC pattern. HadithBloc gains history tracking, SettingsBloc gains theme toggle, FavoritesBloc gains search filtering.
- [x] **macOS Native**: Feels native on macOS? Menu bar integration proper?
  - **PASS**: All features use macOS packages (launch_at_login, hotkey_manager). Menu bar enhanced with proper items. Frosted glass effects maintained.
- [x] **Authentic Content**: Hadith properly cited? Source book and narrator included?
  - **PASS**: All 200+ Hadiths include narrator, source book, chapter, and reference numbers. Corrupted first Hadith fixed.
- [x] **Privacy**: No user data collection? All stored locally?
  - **PASS**: Statistics, favorites, settings, and history all stored locally via Hive. No telemetry or analytics.

**Constitution Status**: PASS - No violations. All features aligned with core principles.

## Project Structure

### Documentation (this feature)

```text
specs/enhancements_194/
├── spec.md              # Feature specification
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
│   └── bloc-events-states.md  # BLoC event/state contracts
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
# Hikma Flutter Project Structure
lib/
├── core/              # constants, theme, utils (shared across app)
│   ├── constants/
│   │   └── app_constants.dart           # App-wide constants
│   ├── theme/
│   │   ├── app_colors.dart              # Color palette
│   │   └── app_theme.dart               # Light/dark themes
│   └── utils/
│       ├── menu_bar_manager.dart        # Menu bar logic
│       └── assets_loader.dart           # JSON asset loading (NEW)
├── data/              # models, repositories, APIs
│   ├── models/
│   │   ├── hadith.dart                  # Hadith entity
│   │   ├── hadith_collection.dart       # Collection enum
│   │   ├── user_settings.dart           # User preferences
│   │   ├── popup_position.dart          # Position storage
│   │   ├── read_statistics.dart         # Stats tracking (NEW)
│   │   └── daily_hadith.dart            # Daily featured (NEW)
│   ├── repositories/
│   │   ├── hadith_repository.dart       # Hadith data access
│   │   ├── settings_repository.dart     # Settings persistence
│   │   └── favorites_repository.dart    # Favorites storage
│   └── services/
│       ├── hadith_api_service.dart      # Remote API client
│       └── audio_service.dart           # Sound playback (NEW)
├── bloc/              # BLoC files per feature
│   ├── hadith/
│   │   ├── hadith_bloc.dart
│   │   ├── hadith_event.dart
│   │   └── hadith_state.dart
│   ├── scheduler/
│   │   ├── scheduler_bloc.dart
│   │   ├── scheduler_event.dart
│   │   └── scheduler_state.dart
│   ├── favorites/
│   │   ├── favorites_bloc.dart
│   │   ├── favorites_event.dart
│   │   └── favorites_state.dart
│   ├── settings/
│   │   ├── settings_bloc.dart
│   │   ├── settings_event.dart
│   │   └── settings_state.dart
│   ├── popup/
│   │   ├── popup_bloc.dart
│   │   ├── popup_event.dart
│   │   └── popup_state.dart
│   └── statistics/                      # NEW - Read statistics tracking
│       ├── statistics_bloc.dart
│       ├── statistics_event.dart
│       └── statistics_state.dart
└── ui/                # screens, widgets, popup
    ├── screens/
    │   ├── home_screen.dart
    │   ├── settings_screen.dart
    │   ├── favorites_screen.dart
    │   ├── onboarding_screen.dart       # NEW
    │   ├── about_screen.dart
    │   └── contemplation_screen.dart    # NEW
    ├── widgets/
    │   ├── hadith_card.dart
    │   ├── search_bar.dart              # NEW - Favorites search
    │   ├── progress_bar.dart            # NEW - Popup countdown
    │   └── stats_widget.dart            # NEW - Reading statistics
    └── popup/
        ├── hadith_popup.dart
        └── popup_content.dart

assets/
└── data/
    └── hadiths.json                     # Expanded to 200+ entries (UPDATED)
sounds/
    └── notification.mp3                 # Subtle notification sound (NEW)

test/
├── widget/            # widget tests
│   ├── popup_content_test.dart
│   ├── favorites_screen_test.dart
│   └── settings_screen_test.dart
├── bloc/              # BLoC tests
│   ├── hadith_bloc_test.dart
│   ├── scheduler_bloc_test.dart
│   ├── favorites_bloc_test.dart
│   └── settings_bloc_test.dart
└── integration/       # integration tests
    └── app_flow_test.dart
```

**Structure Decision**: Flutter macOS desktop application with enforced BLoC architecture per constitution. New features extend existing BLoCs rather than creating new architectural patterns.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| N/A | No violations | Constitution passed without issues |

