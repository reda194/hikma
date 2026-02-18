import '../../../data/models/user_settings.dart';
import 'package:equatable/equatable.dart';

/// Base class for all Popup events
abstract class PopupEvent extends Equatable {
  const PopupEvent();

  @override
  List<Object?> get props => [];
}

/// Event to show the Hadith popup
class ShowPopup extends PopupEvent {
  final String hadithId;
  final PopupPosition? position;

  const ShowPopup({
    required this.hadithId,
    this.position,
  });

  @override
  List<Object?> get props => [hadithId, position];
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
