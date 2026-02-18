import '../../../data/models/user_settings.dart';
import 'package:equatable/equatable.dart';

/// Base class for all Settings states
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before settings have been loaded
class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

/// State when settings are loading
class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

/// State when settings have been successfully loaded
class SettingsLoaded extends SettingsState {
  final UserSettings settings;

  const SettingsLoaded({required this.settings});

  SettingsLoaded copyWith({
    UserSettings? settings,
  }) {
    return SettingsLoaded(
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [settings];
}
