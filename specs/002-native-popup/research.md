# Research: Native Floating Hadith Popup

**Feature**: 002-native-popup
**Date**: 2026-02-19
**Status**: Complete

## Overview

This document captures technical research and decisions for implementing a native macOS NSPanel-based popup window for Hikma hadith notifications.

---

## 1. NSPanel with Flutter View Integration

### Problem
The existing `window_manager` package only controls one window - the main application window. We need a separate floating window that appears even when the main app is hidden.

### Research Findings

**FlutterMacOS Architecture**:
- FlutterMacOS uses `FlutterViewController` to render Flutter content
- Multiple `FlutterViewController` instances can be created, but they share the same `FlutterEngine` by default
- For separate windows, we need to create a native NSPanel and embed a Flutter view

**NSPanel Characteristics**:
- `NSPanel` is a subclass of `NSWindow` designed for floating auxiliary windows
- Key style masks: `.nonactivatingPanel` (doesn't steal focus), `.fullSizeContentView` (no title bar), `.borderless`
- Window level `.floating` appears above regular windows but below fullscreen apps by default
- `.floating` level can be combined with `.popUpMenu` level for always-on-top behavior

### Decision

**Approach**: Create NSPanel in Swift, use FlutterViewController as contentView

```swift
let panel = NSPanel(
    contentRect: NSRect(x: x, y: y, width: 420, height: 280),
    styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless],
    backing: .buffered,
    defer: false
)
panel.level = .floating
panel.contentView = flutterViewController.view
```

**Rationale**:
- NSPanel is the macOS standard for floating palettes and notifications
- Non-activating panel doesn't steal focus from user's current application
- Full-size content view enables custom frosted glass styling
- Reuses existing Flutter UI components

---

## 2. Multi-Display Cursor Detection

### Problem
When user has multiple monitors, which display should show the popup?

### Research Findings

**macOS Display APIs**:
- `NSScreen.screens` - Array of all active displays
- `NSEvent.mouseLocation` - Current mouse position in global coordinates
- Each `NSScreen` has `frame` (global coordinates) and `visibleFrame` (excluding dock/menu bar)

**Coordinate System**:
- macOS uses bottom-left origin (0,0 is bottom-left of primary display)
- `NSEvent.mouseLocation` returns bottom-left origin coordinates
- Need to check which screen's frame contains the mouse point

### Decision

**Approach**: Iterate screens, find which contains mouse location

```swift
func getDisplayWithCursor() -> NSScreen {
    let mouseLocation = NSEvent.mouseLocation
    for screen in NSScreen.screens {
        if screen.frame.contains(mouseLocation) {
            return screen
        }
    }
    return NSScreen.main ?? NSScreen.screens.first!
}
```

**Rationale**:
- Follows user's attention focus
- Consistent with macOS notification behavior
- Simple, reliable API with no third-party dependencies

---

## 3. Platform Channel Communication

### Problem
Need bidirectional communication between Flutter and native Swift code for popup control.

### Research Findings

**MethodChannel Pattern**:
- Channel name: `"com.hikma.app/popup_window"`
- Methods from Flutter → Swift:
  - `showPopup`: Display hadith popup with data
  - `hidePopup`: Dismiss popup
  - `updateHadith`: Replace current hadith with new one
- Methods from Swift → Flutter:
  - `onHoverChanged`: Report mouse enter/leave
  - `onDismissed`: Report popup closed by user
  - `onAction`: Report button clicks (save, copy, next)

**Data Format**:
- Use JSON for complex data (hadith object)
- Use primitive types for simple values (booleans, numbers)

### Decision

**Method Signatures**:

| Method | Direction | Parameters | Returns |
|--------|-----------|------------|---------|
| showPopup | Flutter→Swift | hadith: Map<String, dynamic>, position: Map<String, dynamic>, duration: int | void |
| hidePopup | Flutter→Swift | - | void |
| updateHadith | Flutter→Swift | hadith: Map<String, dynamic> | void |
| onHoverChanged | Swift→Flutter | isHovered: bool | void |
| onAction | Swift→Flutter | action: String ("save", "copy", "next") | void |

**Rationale**:
- Clear separation of concerns (Flutter controls UI, Swift manages window)
- JSON serialization allows complex hadith data transfer
- Event callbacks enable interactive features (hover, buttons)

---

## 4. Scheduler Bug Fix (Empty hadithId)

### Problem
In `scheduler_bloc.dart` lines 96-100 and 177-181, the code passes an empty string for `hadithId`:

```dart
_popupDelayTimer = Timer(const Duration(milliseconds: 500), () {
  final hadithState = _hadithBloc.state;
  if (hadithState is HadithLoaded) {
    _popupBloc.add(const ShowPopup(hadithId: ''));  // ← BUG
  }
});
```

### Research Findings

**Root Cause**:
- The scheduler waits for HadithBloc to load, then passes empty ID
- PopupBloc needs the actual hadith ID to display content
- `HadithLoaded` state contains the full `Hadith` object with `id` field

**Solution**:
Pass `hadithState.hadith.id` instead of empty string.

**Scope**:
- Two locations in `scheduler_bloc.dart` need fixing
- Also need to update `PopupBloc` to accept full `Hadith` object (not just ID)
- Update `ShowPopup` event to carry full hadith data

### Decision

**Fix**:
```dart
_popupDelayTimer = Timer(const Duration(milliseconds: 500), () {
  final hadithState = _hadithBloc.state;
  if (hadithState is HadithLoaded) {
    _popupBloc.add(ShowPopup(
      hadith: hadithState.hadith,  // Pass full hadith object
    ));
  }
});
```

**Rationale**:
- Minimal code change, high impact
- Enables popup to display hadith content immediately
- Aligns with architecture decision to pass full hadith objects

---

## 5. Position Types & Calculation

### Problem
Need to map user-selected position types (corners, center) to actual screen coordinates.

### Research Findings

**Position Mapping**:
- For each position type, calculate `NSPoint(x, y)`
- Must account for popup size (420x280)
- Must respect screen margin (24px from edges)
- macOS coordinates use bottom-left origin (need to flip y-axis calculations)

**Calculation Logic**:
```
Top-Left:     x = margin,                   y = screenHeight - popupHeight - margin
Top-Right:    x = screenWidth - popupWidth - margin, y = screenHeight - popupHeight - margin
Bottom-Left:  x = margin,                   y = margin
Bottom-Right: x = screenWidth - popupWidth - margin, y = margin (default)
Center:       x = (screenWidth - popupWidth) / 2, y = (screenHeight - popupHeight) / 2
```

### Decision

**Implementation**: Create utility class `PopupPositionCalculator` in Swift

```swift
enum PopupPositionType: String {
    case topLeft, topRight, bottomLeft, bottomRight, center
}

struct PopupPositionCalculator {
    static func calculatePosition(
        _ type: PopupPositionType,
        screenSize: CGSize,
        popupSize: CGSize = CGSize(width: 420, height: 280),
        margin: CGFloat = 24
    ) -> NSPoint {
        // Implementation based on formula above
    }
}
```

**Rationale**:
- Encapsulates position logic in single class
- Easy to test with different screen sizes
- Consistent with redesign document specifications

---

## 6. Hover-to-Pause Behavior

### Problem
Popup should auto-dismiss after configured duration, but pause when user hovers.

### Research Findings

**Timer Management**:
- Use `Timer` in Dart for auto-dismiss countdown
- On hover enter: `timer.cancel()` or pause tracking
- On hover exit: Resume countdown from remaining time
- Use `AnimationController` for smooth circular progress indicator

**Hover Detection**:
- Flutter `MouseRegion` widget detects cursor enter/exit
- Callbacks trigger `HoverChanged` events to PopupBloc
- Swift NSPanel also needs tracking area setup for reliable hover detection

### Decision

**Approach**: Hybrid hover detection (Flutter MouseRegion + Swift NSTrackingArea)

**Rationale**:
- Flutter MouseRegion works for content area
- Swift NSTrackingArea ensures detection even at edges
- Dual approach provides redundancy for reliability

---

## 7. Clipboard Copy Format

### Problem
What format for copying hadith to clipboard?

### Research Findings

**User Clarification** (from spec): Arabic text + narrator + source book

**Format Example**:
```
[Arabic Hadith Text]
- Narrator: [Name]
- Source: [Book Name], Chapter [Chapter]
```

**macOS Clipboard API**:
- `NSPasteboard.generalPasteboard.setString()`
- Flutter: `Clipboard.setData(ClipboardData(text: "..."))`

### Decision

**Format**:
```dart
String formatForClipboard(Hadith hadith) {
  return '${hadith.arabicText}\n'
         '- ${hadith.narrator}\n'
         '- ${hadith.sourceBook}, ${hadith.chapter}';
}
```

**Rationale**:
- Complete citation for authenticity
- Readable format for sharing
- Consistent with constitution requirement for proper attribution

---

## 8. Frosted Glass Visual Effect

### Problem
Achieve macOS native frosted glass appearance.

### Research Findings

**NSVisualEffectView**:
- Material: `.hudWindow` or `.underWindowBackground`
- Blending mode: `.behindWindow`
- State: `.active`
- Corner radius via `layer?.cornerRadius`

**flutter_acrylic Package**:
- Currently used in app
- Provides `Window.setEffect()` API
- Supports `WindowEffect.acrylic` with color/alpha

### Decision

**Hybrid Approach**:
1. Use NSVisualEffectView in Swift as base layer
2. Flutter content renders transparently above
3. flutter_acrylic for main window compatibility

**Rationale**:
- Native NSVisualEffectView provides true system blur
- Flutter widgets overlay with transparency
- Consistent with macOS design language

---

## Summary of Decisions

| # | Decision | Rationale |
|---|----------|-----------|
| 1 | NSPanel with FlutterViewController | Standard macOS floating window, reuses Flutter UI |
| 2 | Mouse location display detection | Follows user attention, consistent with macOS |
| 3 | MethodChannel with JSON events | Clean bidirectional communication |
| 4 | Pass full Hadith object in ShowPopup | Fixes empty hadithId bug, enables content display |
| 5 | PopupPositionCalculator utility | Encapsulates coordinate calculations |
| 6 | Hybrid hover detection (Flutter + Swift) | Redundancy for reliability |
| 7 | Arabic + narrator + source format | Complete citation for authenticity |
| 8 | NSVisualEffectView base layer | True system blur, macOS native appearance |

---

## Next Steps

1. Create `PopupWindowController.swift` with NSPanel implementation
2. Create `PopupWindowPlugin.swift` for MethodChannel bridge
3. Update `PopupBloc` with new events and state
4. Create `NotificationPopup` widget in Flutter
5. Implement position picker and duration slider widgets
6. Fix scheduler bug (empty hadithId)
