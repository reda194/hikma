import '../../../data/models/user_settings.dart';
import '../../../data/models/hadith.dart';
import 'package:equatable/equatable.dart';

/// Base class for all Popup events
abstract class PopupEvent extends Equatable {
  const PopupEvent();

  @override
  List<Object?> get props => [];
}

/// Event to show the Hadith popup with full Hadith object
class ShowPopup extends PopupEvent {
  final Hadith hadith;
  final PopupPosition? position;

  const ShowPopup({
    required this.hadith,
    this.position,
  });

  @override
  List<Object?> get props => [hadith, position];
}

/// Event to hide the popup
class HidePopup extends PopupEvent {
  const HidePopup();
}

/// Event to dismiss the popup (user action)
class DismissPopup extends PopupEvent {
  final bool savePosition;

  const DismissPopup({this.savePosition = true});

  @override
  List<Object?> get props => [savePosition];
}

/// Event to start auto-dismiss timer
class StartAutoDismiss extends PopupEvent {
  final Duration duration;

  const StartAutoDismiss(this.duration);

  @override
  List<Object?> get props => [duration];
}

/// Event to update popup position
class UpdatePosition extends PopupEvent {
  final double dx;
  final double dy;

  const UpdatePosition({required this.dx, required this.dy});

  @override
  List<Object?> get props => [dx, dy];
}

/// Event to update temporary popup position (drag-to-move)
class UpdateTemporaryPosition extends PopupEvent {
  final double dx;
  final double dy;

  const UpdateTemporaryPosition({required this.dx, required this.dy});

  @override
  List<Object?> get props => [dx, dy];
}

/// Event when hover state changes
class HoverChanged extends PopupEvent {
  final bool isHovered;

  const HoverChanged({required this.isHovered});

  @override
  List<Object?> get props => [isHovered];
}

/// Event to copy Hadith text to clipboard
class CopyHadith extends PopupEvent {
  const CopyHadith();
}

/// Event to show next Hadith
class ShowNextHadith extends PopupEvent {
  const ShowNextHadith();
}

/// Event to save/remove Hadith from favorites
class ToggleFavorite extends PopupEvent {
  final String hadithId;

  const ToggleFavorite({required this.hadithId});

  @override
  List<Object?> get props => [hadithId];
}
