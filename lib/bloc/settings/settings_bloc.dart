import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/user_settings.dart';
import '../../../data/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

/// SettingsBloc manages user settings with Hive persistence
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsBloc({
    required SettingsRepository settingsRepository,
  })  : _settingsRepository = settingsRepository,
        super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateSettings>(_onUpdateSettings);
    on<UpdateReminderInterval>(_onUpdateReminderInterval);
    on<UpdatePopupDuration>(_onUpdatePopupDuration);
    on<UpdateSourceCollection>(_onUpdateSourceCollection);
    on<UpdateFontSize>(_onUpdateFontSize);
    on<ToggleSound>(_onToggleSound);
    on<ToggleAutoStart>(_onToggleAutoStart);
    on<ToggleShowInDock>(_onToggleShowInDock);
    on<ToggleDarkMode>(_onToggleDarkMode);
  }

  /// Expose repository for external initialization
  SettingsRepository get repository => _settingsRepository;

  /// Handle LoadSettings event
  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());

    try {
      final settings = await _settingsRepository.loadSettings();
      emit(SettingsLoaded(settings: settings));
    } catch (e) {
      // Return default settings on error
      emit(SettingsLoaded(settings: const UserSettings()));
    }
  }

  /// Handle UpdateSettings event
  Future<void> _onUpdateSettings(
    UpdateSettings event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _settingsRepository.saveSettings(event.settings);
      emit(SettingsLoaded(settings: event.settings));
    } catch (e) {
      // Keep current state on error
      if (state is SettingsLoaded) {
        emit(state);
      }
    }
  }

  /// Handle UpdateReminderInterval event
  Future<void> _onUpdateReminderInterval(
    UpdateReminderInterval event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is! SettingsLoaded) return;

    try {
      final currentState = state as SettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(
        reminderInterval: event.interval,
      );

      await _settingsRepository.saveSettings(updatedSettings);
      emit(SettingsLoaded(settings: updatedSettings));
    } catch (e) {
      // Keep current state on error
    }
  }

  /// Handle UpdatePopupDuration event
  Future<void> _onUpdatePopupDuration(
    UpdatePopupDuration event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is! SettingsLoaded) return;

    try {
      final currentState = state as SettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(
        popupDuration: event.duration,
      );

      await _settingsRepository.saveSettings(updatedSettings);
      emit(SettingsLoaded(settings: updatedSettings));
    } catch (e) {
      // Keep current state on error
    }
  }

  /// Handle UpdateSourceCollection event
  Future<void> _onUpdateSourceCollection(
    UpdateSourceCollection event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is! SettingsLoaded) return;

    try {
      final currentState = state as SettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(
        sourceCollection: event.collection,
      );

      await _settingsRepository.saveSettings(updatedSettings);
      emit(SettingsLoaded(settings: updatedSettings));
    } catch (e) {
      // Keep current state on error
    }
  }

  /// Handle UpdateFontSize event
  Future<void> _onUpdateFontSize(
    UpdateFontSize event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is! SettingsLoaded) return;

    try {
      final currentState = state as SettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(
        fontSize: event.fontSize,
      );

      await _settingsRepository.saveSettings(updatedSettings);
      emit(SettingsLoaded(settings: updatedSettings));
    } catch (e) {
      // Keep current state on error
    }
  }

  /// Handle ToggleSound event
  Future<void> _onToggleSound(
    ToggleSound event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is! SettingsLoaded) return;

    try {
      final currentState = state as SettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(
        soundEnabled: event.enabled,
      );

      await _settingsRepository.saveSettings(updatedSettings);
      emit(SettingsLoaded(settings: updatedSettings));
    } catch (e) {
      // Keep current state on error
    }
  }

  /// Handle ToggleAutoStart event
  Future<void> _onToggleAutoStart(
    ToggleAutoStart event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is! SettingsLoaded) return;

    try {
      final currentState = state as SettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(
        autoStartEnabled: event.enabled,
      );

      await _settingsRepository.saveSettings(updatedSettings);
      emit(SettingsLoaded(settings: updatedSettings));
    } catch (e) {
      // Keep current state on error
    }
  }

  /// Handle ToggleShowInDock event
  Future<void> _onToggleShowInDock(
    ToggleShowInDock event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is! SettingsLoaded) return;

    try {
      final currentState = state as SettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(
        showInDock: event.enabled,
      );

      await _settingsRepository.saveSettings(updatedSettings);
      emit(SettingsLoaded(settings: updatedSettings));
    } catch (e) {
      // Keep current state on error
    }
  }

  /// Handle ToggleDarkMode event
  Future<void> _onToggleDarkMode(
    ToggleDarkMode event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is! SettingsLoaded) return;

    try {
      final currentState = state as SettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(
        darkModeEnabled: event.enabled,
      );

      await _settingsRepository.saveSettings(updatedSettings);
      emit(SettingsLoaded(settings: updatedSettings));
    } catch (e) {
      // Keep current state on error
    }
  }
}
