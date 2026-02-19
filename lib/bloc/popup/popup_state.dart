import '../../../data/models/user_settings.dart';
import '../../../data/models/hadith.dart';
import 'package:equatable/equatable.dart';

/// Base class for all Popup states
abstract class PopupState extends Equatable {
  const PopupState();

  @override
  List<Object?> get props => [];
}

/// State when popup is hidden
class PopupHidden extends PopupState {
  final PopupPosition? lastPosition;

  const PopupHidden({this.lastPosition});

  @override
  List<Object?> get props => [lastPosition];
}

/// State when popup is visible with full Hadith object
class PopupVisible extends PopupState {
  final Hadith hadith;
  final PopupPosition? position;
  final PopupPositionType positionType;
  final int remainingMillis; // Remaining time in milliseconds
  final Duration displayDuration; // Total display duration
  final bool isHovered;
  final bool isDismissible;

  const PopupVisible({
    required this.hadith,
    this.position,
    this.positionType = PopupPositionType.bottomRight,
    this.remainingMillis = 0,
    this.displayDuration = const Duration(seconds: 8),
    this.isHovered = false,
    this.isDismissible = true,
  });

  PopupVisible copyWith({
    Hadith? hadith,
    PopupPosition? position,
    PopupPositionType? positionType,
    int? remainingMillis,
    Duration? displayDuration,
    bool? isHovered,
    bool? isDismissible,
  }) {
    return PopupVisible(
      hadith: hadith ?? this.hadith,
      position: position ?? this.position,
      positionType: positionType ?? this.positionType,
      remainingMillis: remainingMillis ?? this.remainingMillis,
      displayDuration: displayDuration ?? this.displayDuration,
      isHovered: isHovered ?? this.isHovered,
      isDismissible: isDismissible ?? this.isDismissible,
    );
  }

  /// Calculate progress (0.0 to 1.0)
  double get progress {
    if (displayDuration.inMilliseconds == 0) return 0.0;
    final elapsed = displayDuration.inMilliseconds - remainingMillis;
    return (elapsed / displayDuration.inMilliseconds).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [
        hadith,
        position,
        positionType,
        remainingMillis,
        displayDuration,
        isHovered,
        isDismissible,
      ];
}
