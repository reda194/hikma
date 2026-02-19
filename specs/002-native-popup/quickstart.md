# Quickstart: Native Popup Development

**Feature**: 002-native-popup
**Date**: 2026-02-19

## Prerequisites

- Flutter 3.19+ with macOS desktop enabled
- Xcode 13+ with macOS 11+ SDK
- CocoaPods installed
- Existing Hikma project cloned

---

## Setup

1. **Checkout the feature branch**:
   ```bash
   git checkout 002-native-popup
   flutter pub get
   cd macos && pod install && cd ..
   ```

2. **Verify existing setup**:
   ```bash
   flutter doctor
   flutter devices
   flutter run -d macos
   ```

---

## Implementation Order

### Phase 1: Critical Bug Fix (10 min)

**File**: `lib/bloc/scheduler/scheduler_bloc.dart`

**Lines to modify**: 99, 180

**Change**:
```dart
// OLD:
_popupBloc.add(const ShowPopup(hadithId: ''));

// NEW:
_popupBloc.add(ShowPopup(hadith: hadithState.hadith));
```

**Test**: Run app, trigger notification, verify popup appears with content.

---

### Phase 2: Swift NSPanel Implementation (2-3 hours)

**File**: `macos/Runner/PopupWindowController.swift` (NEW)

**Key code**:
```swift
import Cocoa
import FlutterMacOS

class PopupWindowController {
    static var shared: PopupWindowController?
    var panel: NSPanel?
    var flutterViewController: FlutterViewController?

    func showPopup(
        hadithData: [String: Any],
        position: PopupPositionType,
        duration: TimeInterval
    ) {
        // Create NSPanel
        // Set up NSVisualEffectView for frosted glass
        // Position on screen
        // Show panel
    }

    func hidePopup() {
        panel?.orderOut(nil)
    }
}
```

**File**: `macos/Runner/PopupWindowPlugin.swift` (NEW)

**Key code**:
```swift
public class PopupWindowPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.hikma.app/popup_window",
            binaryMessenger: registrar.messenger
        )
        let instance = PopupWindowPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterPluginResult) {
        switch call.method {
        case "showPopup":
            // Extract hadith data, position, duration
            // Call PopupWindowController.shared.showPopup()
        case "hidePopup":
            // Call PopupWindowController.shared.hidePopup()
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
```

**Register in `AppDelegate.swift`**:
```swift
import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    override func applicationDidFinishLaunching(_ notification: Notification) {
        let controller = window?.contentViewController as! FlutterViewController
        PopupWindowPlugin.register(with: registrar as! FlutterPluginRegistrar)
    }
}
```

---

### Phase 3: Platform Channel Bridge (1-2 hours)

**File**: `lib/core/utils/popup_window_manager.dart` (NEW)

**Key code**:
```dart
class PopupWindowManager {
  static const _channel = MethodChannel('com.hikma.app/popup_window');

  static Future<void> showPopup({
    required Hadith hadith,
    required PopupPositionType positionType,
    required Duration duration,
  }) async {
    await _channel.invokeMethod('showPopup', {
      'hadith': hadith.toJson(),
      'positionType': positionType.index,
      'duration': duration.inMilliseconds,
    });
  }

  static Future<void> hidePopup() async {
    await _channel.invokeMethod('hidePopup');
  }
}
```

---

### Phase 4: Update PopupBloc (1-2 hours)

**File**: `lib/bloc/popup/popup_bloc.dart`

**Changes**:
1. Add `HadithBloc` dependency
2. Add `HoverChanged`, `CopyHadith`, `ShowNextHadith` event handlers
3. Update `ShowPopup` handler to call `PopupWindowManager.showPopup()`
4. Add hover pause/resume logic

**File**: `lib/bloc/popup/popup_state.dart`

**Changes**:
1. `PopupVisible` now includes `hadith: Hadith` (not just ID)
2. Add `isHovered: bool` field
3. Add `temporaryPosition: Offset?` field

**File**: `lib/bloc/popup/popup_event.dart`

**Changes**:
1. `ShowPopup` takes `hadith: Hadith` (not `hadithId: String`)
2. Add `HoverChanged`, `CopyHadith`, `ShowNextHadith` events

---

### Phase 5: NotificationPopup Widget (2-3 hours)

**File**: `lib/ui/popup/notification_popup.dart` (NEW)

**Key features**:
- MouseRegion for hover detection
- Circular progress indicator (CustomPainter)
- Action buttons appear on hover
- Slide-in/slide-out animations
- RTL Arabic text display

**Structure**:
```dart
class NotificationPopup extends StatefulWidget {
  final Hadith hadith;
  final Duration displayDuration;

  @override
  State<NotificationPopup> createState() => _NotificationPopupState();
}

class _NotificationPopupState extends State<NotificationPopup>
    with TickerProviderStateMixin {

  bool _isHovered = false;
  late AnimationController _slideController;
  late AnimationController _progressController;

  @override
  Widget build(BuildContext context) {
    return BlocListener<PopupBloc, PopupState>(
      listener: (context, state) {
        // Handle state changes
      },
      child: MouseRegion(
        onEnter: (_) => add(HoverChanged(isHovered: true)),
        onExit: (_) => add(HoverChanged(isHovered: false)),
        child: SlideTransition(
          // UI with progress circle, action buttons
        ),
      ),
    );
  }
}
```

---

### Phase 6: Position Picker Widget (1 hour)

**File**: `lib/ui/widgets/position_picker.dart` (NEW)

**UI**: 16:9 rectangle with 5 clickable corner positions

```dart
class PositionPicker extends StatelessWidget {
  final PopupPositionType selected;
  final ValueChanged<PopupPositionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        // Screen preview with 5 position buttons
        child: Stack(
          children: [
            _PositionButton(
              position: PopupPositionType.topLeft,
              selected: selected == PopupPositionType.topLeft,
              onTap: () => onChanged(PopupPositionType.topLeft),
              alignment: Alignment.topLeft,
            ),
            // ... other 4 positions
          ],
        ),
      ),
    );
  }
}
```

---

### Phase 7: Duration Slider (30 min)

**File**: `lib/ui/widgets/duration_slider.dart` (NEW)

**UI**: Slider with 4-30 second range and live preview

```dart
class DurationSlider extends StatelessWidget {
  final int duration;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          value: duration.toDouble(),
          min: 4,
          max: 30,
          divisions: 26,
          label: '$duration seconds',
          onChanged: (value) => onChanged(value.toInt()),
        ),
        Text('$duration seconds'),
      ],
    );
  }
}
```

---

### Phase 8: Update Settings Screen (30 min)

**File**: `lib/ui/screens/settings_screen.dart`

**Add to Hadith section**:
```dart
ListTile(
  leading: const Icon(Icons.open_with),
  title: const Text('Popup Position'),
  subtitle: Text(_getPositionLabel(settings.popupPositionType)),
  trailing: const Icon(Icons.chevron_right),
  onTap: () => _showPositionPicker(context),
),

ListTile(
  leading: const Icon(Icons.timer),
  title: const Text('Popup Duration'),
  subtitle: Text('${settings.popupDisplayDuration} seconds'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () => _showDurationSlider(context),
)
```

---

## Testing

### Run the app

```bash
flutter run -d macos
```

### Test scenarios

1. **Popup appears when triggered**
   - Set reminder interval to 1 minute
   - Wait for popup
   - Verify NSPanel appears with hadith content

2. **Hover pauses timer**
   - Move mouse over popup
   - Verify progress circle stops
   - Move mouse away
   - Verify progress resumes

3. **Position picker works**
   - Open Settings → Popup Position
   - Select "Top Left"
   - Trigger popup
   - Verify appears in top-left

4. **Duration slider works**
   - Open Settings → Popup Duration
   - Set to 5 seconds
   - Trigger popup
   - Verify dismisses after ~5 seconds

5. **Multi-display**
   - Move mouse to second display
   - Trigger popup
   - Verify appears on cursor display

---

## Debugging

### View NSPanel logs

```swift
// In PopupWindowController.swift
print("Panel showing at: \(panel?.frame)")
```

### Check platform channel calls

```dart
// In popup_window_manager.dart
try {
  await _channel.invokeMethod('showPopup', data);
  print('Popup shown successfully');
} catch (e) {
  print('Error showing popup: $e');
}
```

### Flutter DevTools

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

---

## Common Issues

**Issue**: NSPanel doesn't appear
- **Check**: Window level is set to `.floating`
- **Check**: `panel.makeKeyAndOrderFront(nil)` is called

**Issue**: Popup appears on wrong screen
- **Check**: Multi-display cursor detection logic
- **Check**: `NSScreen.screens` iteration

**Issue**: Hadith content is empty
- **Check**: Scheduler passes hadith.id correctly
- **Check**: HadithBloc emits HadithLoaded before ShowPopup

**Issue**: Hover doesn't pause timer
- **Check**: HoverChanged events fire
- **Check**: Timer cancellation logic

---

## Resources

- [NSPanel Documentation](https://developer.apple.com/documentation/appkit/nspanel)
- [Flutter macOS Desktop](https://flutter.dev/macos)
- [Platform Channels](https://docs.flutter.dev/development/platform-integration/platform-channels)
- [Hikma Constitution](../../../.specify/memory/constitution.md)
