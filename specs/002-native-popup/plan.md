# Implementation Plan: Native Floating Hadith Popup

**Branch**: `002-native-popup` | **Date**: 2026-02-19 | **Spec**: [spec.md](./spec.md)

## Summary

Transform the existing Hikma popup from a Flutter dialog overlay to a native macOS floating NSWindow that appears independently of the main application window. The popup will feature frosted glass effects, hover-to-pause behavior, circular progress indicator, action buttons (Save, Copy, Next), configurable screen position (5 options), and user-customizable display duration (4-30 seconds). The existing scheduler bug (empty hadithId) will be fixed.

**Technical Approach**: Use platform channels to create a native NSPanel in Swift, bridged to Flutter via method channels. The popup UI will use Flutter widgets rendered in the separate window with BLoC state management.

## Technical Context

**Language/Version**: Dart 3.3+ (Flutter 3.19+), Swift 5.0+ (macOS native)
**Primary Dependencies**: flutter_bloc, hive_flutter, dio, window_manager, system_tray, flutter_acrylic, google_fonts, connectivity_plus, equatable
**Storage**: Hive (local key-value) + bundled JSON (Hadith content)
**Testing**: flutter_test (widget tests), bloc_test (BLoC tests), integration_test
**Target Platform**: macOS 11+ (Big Sur or later) - requires NSPanel and NSVisualEffectView
**Project Type**: Single (Flutter macOS desktop)
**Performance Goals**: <50MB memory usage, <2s cold start, 60fps animations, <500ms popup appearance latency
**Constraints**: <50MB binary size, offline-capable, sandboxed for Mac App Store
**Scale/Scope**: ~300 bundled Hadiths, ~10 BLoCs, ~20 screens/widgets

### Architecture Decisions

| Decision | Rationale |
|----------|-----------|
| **NSPanel via Platform Channel** | window_manager only controls one window; NSPanel allows separate floating window that appears above fullscreen apps |
| **Flutter Engine in NSPanel** | Reuses existing UI widgets and BLoC architecture, avoiding duplicate native UI implementation |
| **Method Channel Bridge** | Simple bidirectional communication for show/hide/position/update commands |
| **Multi-Display Cursor Detection** | Uses NSEvent.mouseLocation to identify active display, positioning popup where user is looking |
| **Temporary Drag Position** | Dragging moves popup for current session only; next notification uses saved preference |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Per `.specify/memory/constitution.md`, all features MUST satisfy:

- [x] **Simplicity**: Feature justified against core mission? Yes - popup delivery is the PRIMARY method for Hadith reminders. Native window is essential for appearing when app is hidden.
- [x] **Offline-First**: Does it work without internet? Yes - uses bundled local JSON Hadith data, no network required.
- [x] **BLoC Architecture**: State in BLoC only? Yes - PopupBloc manages visibility, timer, position. No widget-side business logic.
- [x] **macOS Native**: Feels native on macOS? Yes - NSPanel with frosted glass, follows macOS notification conventions.
- [x] **Authentic Content**: Hadith properly cited? Yes - Arabic text + narrator + source book displayed in all popups.
- [x] **Privacy**: No user data collection? Yes - all preferences stored locally in Hive, no telemetry.

**Gate Status**: ✅ PASSED - No constitutional violations.

## Project Structure

### Documentation (this feature)

```text
specs/002-native-popup/
├── plan.md              # This file
├── research.md          # Phase 0: Technical research
├── data-model.md        # Phase 1: Data entities
├── quickstart.md        # Phase 1: Developer quickstart
├── contracts/           # Phase 1: BLoC contracts
│   ├── popup_bloc.dart
│   ├── popup_event.dart
│   └── popup_state.dart
└── tasks.md             # Phase 2: Implementation tasks
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── constants/
│   │   └── storage_keys.dart      # Existing - add popup duration key
│   ├── utils/
│   │   ├── menu_bar_manager.dart  # Existing
│   │   └── popup_window_manager.dart  # NEW - Flutter side of platform channel
│   └── theme/
│       └── app_colors.dart        # Existing
├── data/
│   ├── models/
│   │   ├── hadith.dart            # Existing
│   │   ├── hadith_collection.dart # Existing
│   │   └── user_settings.dart     # MODIFY - add popupPositionType, popupDisplayDuration
│   └── repositories/
│       ├── hadith_repository.dart # Existing
│       ├── settings_repository.dart # MODIFY - add position/duration persistence
│       └── favorites_repository.dart # Existing
├── bloc/
│   ├── hadith/                     # Existing
│   ├── scheduler/                  # MODIFY - fix empty hadithId bug
│   ├── favorites/                  # Existing
│   ├── settings/                   # Existing
│   └── popup/                      # MODIFY - add hover state, hadith object
│       ├── popup_bloc.dart
│       ├── popup_event.dart
│       └── popup_state.dart
├── ui/
│   ├── screens/
│   │   ├── settings_screen.dart    # MODIFY - add position/duration pickers
│   │   └── ...
│   ├── popup/
│   │   ├── hadith_popup.dart       # MODIFY - remove overlay, update for NSPanel
│   │   ├── popup_content.dart      # Existing - may need updates
│   │   └── notification_popup.dart # NEW - NSPanel-compatible widget
│   └── widgets/
│       └── position_picker.dart    # NEW - visual 5-option position selector
└── main.dart                       # MODIFY - register platform channel

macos/Runner/
├── AppDelegate.swift               # MODIFY - register plugin
├── PopupWindowController.swift     # NEW - NSPanel native implementation
└── PopupWindowPlugin.swift         # NEW - Flutter plugin bridge

test/
├── widget/
│   └── notification_popup_test.dart  # NEW
├── bloc/
│   ├── popup_bloc_test.dart          # MODIFY - add hover/duration tests
│   └── scheduler_bloc_test.dart      # MODIFY - verify hadithId fix
└── integration/
    └── popup_flow_test.dart          # NEW
```

**Structure Decision**: Flutter macOS desktop application with enforced BLoC architecture per constitution. Native Swift code for NSPanel creation and management.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|---------------------------------------|
| Platform Channel (Swift) | window_manager package only controls one window; second window requires native NSPanel | Using single window for both app and popup would prevent popup from appearing when app is hidden (breaks core functionality) |
| Separate Flutter Engine | Popup needs independent rendering lifecycle from main app | Rendering popup in main window's context requires main window to be visible (violates FR-001) |

## Phase 0: Research & Technical Decisions

### Unknowns to Resolve

1. **NSPanel with Flutter View**: How to embed Flutter content in NSPanel?
   - Research: FlutterMacOS embed API, FlutterViewController in NSPanel content view
   - Decision: Use FlutterViewController as NSPanel's contentView

2. **Multi-Display Cursor Detection**: How to detect which display has the cursor?
   - Research: NSEvent.mouseLocation, NSScreen.screens
   - Decision: Iterate NSScreen.screens, find which contains mouseLocation

3. **Platform Channel Communication**: What methods to expose?
   - Research: MethodChannel patterns for window control
   - Decision: showPopup(hadithData, position, duration), hidePopup(), updateHadith(hadithData)

4. **Scheduler Bug Fix**: Empty hadithId in scheduler_bloc.dart
   - Research: Current implementation passes empty string
   - Decision: Pass hadithState.hadith.id instead

### Research Output

See [research.md](./research.md) for detailed findings.

## Phase 1: Design & Contracts

### Data Model

See [data-model.md](./data-model.md) for entity definitions.

### BLoC Contracts

See [contracts/](./contracts/) for event/state definitions.

### Key Additions

**New Enums/Classes**:
```dart
enum PopupPositionType {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,  // default
  center,
}
```

**UserSettings Updates**:
```dart
class UserSettings {
  // Existing fields...
  final PopupPositionType popupPositionType;  // NEW
  final int popupDisplayDuration;  // NEW - seconds (4-30)
}
```

**PopupState Updates**:
```dart
class PopupVisible extends PopupState {
  final Hadith hadith;  // NEW - full hadith object instead of just ID
  final PopupPositionType positionType;
  final int remainingMillis;  // Changed to millis for smoother progress
  final bool isHovered;  // NEW - hover state
  // ...
}
```

**PopupEvent Additions**:
```dart
class HoverChanged extends PopupEvent {  // NEW
  final bool isHovered;
}

class CopyHadith extends PopupEvent {  // NEW
  final Hadith hadith;
}

class ShowNextHadith extends PopupEvent {}  // NEW
```

## Phase 2: Implementation Tasks

See [tasks.md](./tasks.md) - generated by `/speckit.tasks` command.

## Implementation Order

1. **Fix Scheduler Bug** (P0 - Critical) - scheduler_bloc.dart line 99
2. **Swift NSPanel Implementation** (P0 - Core)
3. **Platform Channel Bridge** (P0 - Core)
4. **Update PopupBloc** (P1 - State management)
5. **NotificationPopup UI** (P1 - User-facing)
6. **Position Picker Widget** (P2 - Enhancement)
7. **Duration Slider Widget** (P2 - Enhancement)
8. **Multi-Display Support** (P2 - Enhancement)
9. **Testing & Polish** (P3 - Quality)
