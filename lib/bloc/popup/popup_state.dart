import '../../../data/models/user_settings.dart';
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

/// State when popup is visible
class PopupVisible extends PopupState {
  final String hadithId;
  final PopupPosition position;
  final int remainingSeconds;
  final bool isDismissible;

  const PopupVisible({
    required this.hadithId,
    required this.position,
    this.remainingSeconds = 0,
    this.isDismissible = true,
  });

  PopupVisible copyWith({
    String? hadithId,
    PopupPosition? position,
    int? remainingSeconds,
    bool? isDismissible,
  }) {
    return PopupVisible(
      hadithId: hadithId ?? this.hadithId,
      position: position ?? this.position,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isDismissible: isDismissible ?? this.isDismissible,
    );
  }

  @override
  List<Object?> get props => [
        hadithId,
        position,
        remainingSeconds,
        isDismissible,
      ];
}
