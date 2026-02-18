import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/user_settings.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/services/audio_service.dart';
import 'popup_event.dart';
import 'popup_state.dart';

/// PopupBloc manages popup visibility, position, and auto-dismiss behavior
class PopupBloc extends Bloc<PopupEvent, PopupState> {
  final SettingsRepository _settingsRepository;
  final AudioService _audioService;

  Timer? _autoDismissTimer;
  int _remainingSeconds = 0;

  PopupBloc({
    required SettingsRepository settingsRepository,
    AudioService? audioService,
  })  : _settingsRepository = settingsRepository,
        _audioService = audioService ?? AudioService(),
        super(const PopupHidden()) {
    on<ShowPopup>(_onShowPopup);
    on<HidePopup>(_onHidePopup);
    on<DismissPopup>(_onDismissPopup);
    on<StartAutoDismiss>(_onStartAutoDismiss);
    on<UpdatePosition>(_onUpdatePosition);
  }

  @override
  Future<void> close() {
    _autoDismissTimer?.cancel();
    return super.close();
  }

  /// Handle ShowPopup event
  Future<void> _onShowPopup(
    ShowPopup event,
    Emitter<PopupState> emit,
  ) async {
    // Play notification sound if enabled
    final settings = await _settingsRepository.loadSettings();
    if (settings.soundEnabled) {
      _audioService.playNotificationSound();
    }

    PopupPosition? position = event.position;

    if (position == null) {
      // Load saved position or use default
      final savedPosition = await _settingsRepository.getPopupPosition();
      position = savedPosition ?? const PopupPosition(100.0, 100.0);
    }

    emit(PopupVisible(
      hadithId: event.hadithId,
      position: position,
      isDismissible: true,
    ));
  }

  /// Handle HidePopup event
  Future<void> _onHidePopup(
    HidePopup event,
    Emitter<PopupState> emit,
  ) async {
    _autoDismissTimer?.cancel();

    PopupPosition? lastPosition;
    if (state is PopupVisible) {
      lastPosition = (state as PopupVisible).position;
    }

    emit(PopupHidden(lastPosition: lastPosition));
  }

  /// Handle DismissPopup event
  Future<void> _onDismissPopup(
    DismissPopup event,
    Emitter<PopupState> emit,
  ) async {
    _autoDismissTimer?.cancel();

    PopupPosition? lastPosition;
    if (state is PopupVisible) {
      final currentState = state as PopupVisible;
      lastPosition = currentState.position;

      // Save position if requested
      if (event.savePosition) {
        await _settingsRepository.updatePopupPosition(currentState.position);
      }
    }

    emit(PopupHidden(lastPosition: lastPosition));
  }

  /// Handle StartAutoDismiss event
  Future<void> _onStartAutoDismiss(
    StartAutoDismiss event,
    Emitter<PopupState> emit,
  ) async {
    _autoDismissTimer?.cancel();

    if (event.duration == Duration.zero) {
      // No auto-dismiss
      return;
    }

    _remainingSeconds = event.duration.inSeconds;

    // Start countdown timer
    _autoDismissTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds--;

      if (state is PopupVisible) {
        final currentState = state as PopupVisible;
        emit(currentState.copyWith(
          remainingSeconds: _remainingSeconds,
        ));
      }

      if (_remainingSeconds <= 0) {
        timer.cancel();
        add(const DismissPopup());
      }
    });

    // Emit initial state with countdown
    if (state is PopupVisible) {
      final currentState = state as PopupVisible;
      emit(currentState.copyWith(
        remainingSeconds: _remainingSeconds,
      ));
    }
  }

  /// Handle UpdatePosition event
  Future<void> _onUpdatePosition(
    UpdatePosition event,
    Emitter<PopupState> emit,
  ) async {
    if (state is PopupVisible) {
      final currentState = state as PopupVisible;
      final newPosition = PopupPosition(event.dx, event.dy);

      emit(currentState.copyWith(position: newPosition));
    }
  }
}
