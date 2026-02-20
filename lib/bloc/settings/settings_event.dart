import '../../../data/models/hadith_collection.dart';
import '../../../data/models/user_settings.dart';
import 'package:equatable/equatable.dart';

/// Base class for all Settings events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load settings from storage
class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

/// Event to update multiple settings at once
class UpdateSettings extends SettingsEvent {
  final UserSettings settings;

  const UpdateSettings(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// Event to update reminder interval
class UpdateReminderInterval extends SettingsEvent {
  final ReminderInterval interval;

  const UpdateReminderInterval(this.interval);

  @override
  List<Object?> get props => [interval];
}

/// Event to update popup duration
class UpdatePopupDuration extends SettingsEvent {
  final PopupDuration duration;

  const UpdatePopupDuration(this.duration);

  @override
  List<Object?> get props => [duration];
}

/// Event to update source collection
class UpdateSourceCollection extends SettingsEvent {
  final HadithCollection collection;

  const UpdateSourceCollection(this.collection);

  @override
  List<Object?> get props => [collection];
}

/// Event to update font size
class UpdateFontSize extends SettingsEvent {
  final FontSize fontSize;

  const UpdateFontSize(this.fontSize);

  @override
  List<Object?> get props => [fontSize];
}

/// Event to toggle sound enabled
class ToggleSound extends SettingsEvent {
  final bool enabled;

  const ToggleSound(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Event to toggle auto start
class ToggleAutoStart extends SettingsEvent {
  final bool enabled;

  const ToggleAutoStart(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Event to toggle show in dock
class ToggleShowInDock extends SettingsEvent {
  final bool enabled;

  const ToggleShowInDock(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Event to toggle dark mode
class ToggleDarkMode extends SettingsEvent {
  final bool enabled;

  const ToggleDarkMode(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Event to update popup position type
class UpdatePopupPositionType extends SettingsEvent {
  final PopupPositionType positionType;

  const UpdatePopupPositionType(this.positionType);

  @override
  List<Object?> get props => [positionType];
}

/// Event to update popup display duration (in seconds)
class UpdatePopupDisplayDuration extends SettingsEvent {
  final int duration; // Duration in seconds (4-30)

  const UpdatePopupDisplayDuration(this.duration);

  @override
  List<Object?> get props => [duration];
}

/// Event to update popup layout mode (compact/spacious)
class UpdatePopupLayoutMode extends SettingsEvent {
  final PopupLayoutMode mode;

  const UpdatePopupLayoutMode(this.mode);

  @override
  List<Object?> get props => [mode];
}
