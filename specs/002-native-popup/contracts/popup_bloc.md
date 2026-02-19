# BLoC Contract: PopupBloc

**Feature**: 002-native-popup
**Version**: 2.0
**Status**: Updated for native popup

## Overview

PopupBloc manages popup visibility, hover state, auto-dismiss timer, and user interactions for the native NSPanel-based hadith popup.

---

## State Contract

### Base State

```dart
abstract class PopupState extends Equatable {
  const PopupState();

  @override
  List<Object?> get props => [];
}
```

### PopupHidden

```dart
class PopupHidden extends PopupState {
  final PopupPositionType? lastPositionType;
  final DateTime? dismissedAt;

  const PopupHidden({
    this.lastPositionType,
    this.dismissedAt,
  });

  @override
  List<Object?> get props => [lastPositionType, dismissedAt];
}
```

**Usage**: Initial state and when popup is not visible.

### PopupVisible

```dart
class PopupVisible extends PopupState {
  final Hadith hadith;
  final PopupPositionType positionType;
  final int remainingMillis;
  final bool isHovered;
  final Duration displayDuration;
  final Offset? temporaryPosition;  // Drag position (not saved)

  const PopupVisible({
    required this.hadith,
    required this.positionType,
    required this.remainingMillis,
    this.isHovered = false,
    required this.displayDuration,
    this.temporaryPosition,
  });

  /// Copy with method for immutable state updates
  PopupVisible copyWith({
    Hadith? hadith,
    PopupPositionType? positionType,
    int? remainingMillis,
    bool? isHovered,
    Duration? displayDuration,
    Offset? temporaryPosition,
  }) {
    return PopupVisible(
      hadith: hadith ?? this.hadith,
      positionType: positionType ?? this.positionType,
      remainingMillis: remainingMillis ?? this.remainingMillis,
      isHovered: isHovered ?? this.isHovered,
      displayDuration: displayDuration ?? this.displayDuration,
      temporaryPosition: temporaryPosition ?? this.temporaryPosition,
    );
  }

  @override
  List<Object?> get props => [
    hadith,
    positionType,
    remainingMillis,
    isHovered,
    displayDuration,
    temporaryPosition,
  ];
}
```

**Usage**: State when popup is displayed and visible to user.

---

## Event Contract

### Base Event

```dart
abstract class PopupEvent extends Equatable {
  const PopupEvent();

  @override
  List<Object?> get props => [];
}
```

### ShowPopup

```dart
class ShowPopup extends PopupEvent {
  final Hadith hadith;
  final PopupPositionType? positionType;
  final Duration? duration;

  const ShowPopup({
    required this.hadith,
    this.positionType,
    this.duration,
  });

  @override
  List<Object?> get props => [hadith, positionType, duration];
}
```

**Handler Behavior**:
1. Play notification sound if enabled in settings
2. Load position type from settings if not provided
3. Load duration from settings if not provided (clamped 4-30s)
4. Emit `PopupVisible` state with provided hadith
5. Start auto-dismiss timer (unless duration is 0/manual)
6. Trigger platform channel to show NSPanel

### HidePopup

```dart
class HidePopup extends PopupEvent {
  const HidePopup();
}
```

**Handler Behavior**:
1. Cancel auto-dismiss timer
2. Trigger platform channel to hide NSPanel
3. Emit `PopupHidden` state with last position

### DismissPopup

```dart
class DismissPopup extends PopupEvent {
  const DismissPopup();
}
```

**Handler Behavior**:
1. Cancel auto-dismiss timer
2. Trigger platform channel to hide NSPanel
3. Emit `PopupHidden` state
4. Save temporary position if user dragged (optional per spec)

### HoverChanged

```dart
class HoverChanged extends PopupEvent {
  final bool isHovered;

  const HoverChanged({required this.isHovered});

  @override
  List<Object?> get props => [isHovered];
}
```

**Handler Behavior**:
1. If `isHovered == true`: Pause auto-dismiss timer
2. If `isHovered == false`: Resume auto-dismiss timer
3. Update state with new hover value

### StartAutoDismiss

```dart
class StartAutoDismiss extends PopupEvent {
  final Duration duration;

  const StartAutoDismiss(this.duration);

  @override
  List<Object?> get props => [duration];
}
```

**Handler Behavior**:
1. Cancel existing timer if any
2. If duration is 0: Return without starting timer
3. Start periodic timer (100ms intervals for smooth progress)
4. Emit state updates with decreasing `remainingMillis`
5. Auto-dispatch `DismissPopup` when timer reaches 0

### CopyHadith

```dart
class CopyHadith extends PopupEvent {
  final Hadith hadith;

  const CopyHadith({required this.hadith});

  @override
  List<Object?> get props => [hadith];
}
```

**Handler Behavior**:
1. Format hadith as: "Arabic text\n- Narrator\n- Source, Chapter"
2. Copy to system clipboard
3. No state change (silent operation)

### ShowNextHadith

```dart
class ShowNextHadith extends PopupEvent {
  const ShowNextHadith();
}
```

**Handler Behavior**:
1. Dispatch `FetchRandomHadith` event to HadithBloc
2. Wait for HadithBloc to emit HadithLoaded
3. Auto-dispatch new `ShowPopup` with loaded hadith
4. Reset auto-dismiss timer with same duration

### UpdateTemporaryPosition

```dart
class UpdateTemporaryPosition extends PopupEvent {
  final Offset offset;

  const UpdateTemporaryPosition({required this.offset});

  @override
  List<Object?> get props => [offset];
}
```

**Handler Behavior**:
1. Update state with new `temporaryPosition`
2. Trigger platform channel to move NSPanel
3. Does NOT persist to settings (per spec)

---

## Bloc Contract

```dart
class PopupBloc extends Bloc<PopupEvent, PopupState> {
  final SettingsRepository _settingsRepository;
  final AudioService _audioService;
  final HadithBloc _hadithBloc;

  Timer? _autoDismissTimer;
  int _remainingMillis = 0;

  PopupBloc({
    required SettingsRepository settingsRepository,
    required AudioService audioService,
    required HadithBloc hadithBloc,
  })  : _settingsRepository = settingsRepository,
        _audioService = audioService,
        _hadithBloc = hadithBloc,
        super(const PopupHidden()) {
    on<ShowPopup>(_onShowPopup);
    on<HidePopup>(_onHidePopup);
    on<DismissPopup>(_onDismissPopup);
    on<HoverChanged>(_onHoverChanged);
    on<StartAutoDismiss>(_onStartAutoDismiss);
    on<CopyHadith>(_onCopyHadith);
    on<ShowNextHadith>(_onShowNextHadith);
    on<UpdateTemporaryPosition>(_onUpdateTemporaryPosition);
  }

  @override
  Future<void> close() {
    _autoDismissTimer?.cancel();
    return super.close();
  }
}
```

---

## Handler Implementations

### ShowPopup Handler

```dart
Future<void> _onShowPopup(
  ShowPopup event,
  Emitter<PopupState> emit,
) async {
  // Play sound if enabled
  final settings = await _settingsRepository.loadSettings();
  if (settings.soundEnabled) {
    _audioService.playNotificationSound();
  }

  // Get position type
  final positionType = event.positionType ??
      settings.popupPositionType ??
      PopupPositionType.bottomRight;

  // Get duration (clamped 4-30s)
  int durationSeconds = event.duration?.inSeconds ??
      settings.popupDisplayDuration ??
      8;
  durationSeconds = durationSeconds.clamp(4, 30);
  final duration = Duration(seconds: durationSeconds);

  // Calculate initial remaining millis
  final remainingMillis = duration.inMilliseconds;

  // Emit visible state
  emit(PopupVisible(
    hadith: event.hadith,
    positionType: positionType,
    remainingMillis: remainingMillis,
    displayDuration: duration,
  ));

  // Start auto-dismiss timer
  add(StartAutoDismiss(duration));
}
```

### HoverChanged Handler

```dart
Future<void> _onHoverChanged(
  HoverChanged event,
  Emitter<PopupState> emit,
) async {
  if (state is! PopupVisible) return;

  final currentState = state as PopupVisible;

  if (event.isHovered && _autoDismissTimer != null && !_autoDismissTimer!.isActive) {
    // Already paused, do nothing
    return;
  }

  if (event.isHovered) {
    // Pause timer
    _autoDismissTimer?.cancel();
  } else {
    // Resume timer
    add(StartAutoDismiss(currentState.displayDuration));
  }

  // Update hover state
  emit(currentState.copyWith(isHovered: event.isHovered));
}
```

### CopyHadith Handler

```dart
Future<void> _onCopyHadith(
  CopyHadith event,
  Emitter<PopupState> emit,
) async {
  final hadith = event.hadith;
  final text = '${hadith.arabicText}\n'
                '- ${hadith.narrator}\n'
                '- ${hadith.sourceBook}, ${hadith.chapter}';

  await Clipboard.setData(ClipboardData(text: text));
  // No state change
}
```

### ShowNextHadith Handler

```dart
Future<void> _onShowNextHadith(
  ShowNextHadith event,
  Emitter<PopupState> emit,
) async {
  if (state is! PopupVisible) return;

  final currentState = state as PopupVisible;

  // Fetch new hadith
  _hadithBloc.add(const FetchRandomHadith(collection: HadithCollection.all));

  // Wait for load and show new popup
  await Future.delayed(const Duration(milliseconds: 100));
  final hadithState = _hadithBloc.state;
  if (hadithState is HadithLoaded) {
    add(ShowPopup(
      hadith: hadithState.hadith,
      positionType: currentState.positionType,
      duration: currentState.displayDuration,
    ));
  }
}
```

---

## Dependencies

```dart
// Required repositories
final SettingsRepository _settingsRepository;
final AudioService _audioService;
final HadithBloc _hadithBloc;

// Required imports
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:flutter/services.dart';
```

---

## Testing Contract

### Given-When-Then Scenarios

**Scenario 1: Show Popup**
```dart
test('shows popup with hadith when ShowPopup event is added', () {
  // Given
  final hadith = Hadith.empty();
  bloc.add(ShowPopup(hadith: hadith));

  // When
  await Future.delayed(Duration.zero);

  // Then
  expect(state, isA<PopupVisible>());
  expect((state as PopupVisible).hadith, equals(hadith));
});
```

**Scenario 2: Hover Pauses Timer**
```dart
test('pauses auto-dismiss timer when hovered', () async {
  // Given
  bloc.add(ShowPopup(
    hadith: Hadith.empty(),
    duration: Duration(seconds: 8),
  ));
  await Future.delayed(Duration.zero);

  // When
  bloc.add(const HoverChanged(isHovered: true));

  // Then
  expect((state as PopupVisible).isHovered, isTrue);
  // Timer should be canceled (verified via mock)
});
```

**Scenario 3: Copy Hadith**
```dart
test('copies hadith to clipboard when CopyHadith event is added', () async {
  // Given
  final hadith = Hadith(
    id: '1',
    arabicText: 'Test hadith',
    narrator: 'Test narrator',
    sourceBook: 'Test book',
    chapter: 'Test chapter',
  );

  // When
  bloc.add(CopyHadith(hadith: hadith));

  // Then
  final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
  expect(clipboardData?.text, contains('Test hadith'));
  expect(clipboardData?.text, contains('Test narrator'));
});
```
