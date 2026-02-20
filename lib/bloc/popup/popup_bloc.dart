import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/user_settings.dart';
import '../../../data/models/hadith.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/services/audio_service.dart';
import '../../../core/utils/popup_window_manager.dart';
import '../hadith/hadith_bloc.dart';
import '../hadith/hadith_event.dart';
import '../hadith/hadith_state.dart';
import 'popup_event.dart';
import 'popup_state.dart';

/// PopupBloc manages popup visibility, position, and auto-dismiss behavior
/// Integrates with native NSPanel via PopupWindowManager
class PopupBloc extends Bloc<PopupEvent, PopupState> {
  final SettingsRepository _settingsRepository;
  final AudioService _audioService;
  final HadithBloc _hadithBloc;

  Timer? _autoDismissTimer;
  int _remainingMillis = 0;
  bool _isHovered = false;
  Hadith? _currentHadith;
  Duration _currentDisplayDuration = const Duration(seconds: 8);
  PopupPositionType _currentPositionType = PopupPositionType.bottomRight;

  // Stream subscription for HadithBloc
  StreamSubscription? _hadithBlocSubscription;

  PopupBloc({
    required SettingsRepository settingsRepository,
    required HadithBloc hadithBloc,
    AudioService? audioService,
  })  : _settingsRepository = settingsRepository,
        _hadithBloc = hadithBloc,
        _audioService = audioService ?? AudioService(),
        super(const PopupHidden()) {
    on<ShowPopup>(_onShowPopup);
    on<HidePopup>(_onHidePopup);
    on<DismissPopup>(_onDismissPopup);
    on<StartAutoDismiss>(_onStartAutoDismiss);
    on<UpdatePosition>(_onUpdatePosition);
    on<UpdateTemporaryPosition>(_onUpdateTemporaryPosition);
    on<HoverChanged>(_onHoverChanged);
    on<CopyHadith>(_onCopyHadith);
    on<ShowNextHadith>(_onShowNextHadith);
    on<ToggleFavorite>(_onToggleFavorite);

    // Initialize platform channel callbacks
    _setupPlatformChannelCallbacks();
  }

  /// Setup callbacks from native platform
  void _setupPlatformChannelCallbacks() {
    PopupWindowManager.setOnHoverChanged((isHovered) {
      add(HoverChanged(isHovered: isHovered));
    });

    PopupWindowManager.setOnAction((action) {
      switch (action) {
        case 'save':
          if (_currentHadith != null) {
            add(ToggleFavorite(hadithId: _currentHadith!.id));
          }
          break;
        case 'copy':
          add(const CopyHadith());
          break;
        case 'next':
          add(const ShowNextHadith());
          break;
        case 'close':
          add(const DismissPopup());
          break;
      }
    });
  }

  @override
  Future<void> close() {
    _autoDismissTimer?.cancel();
    _hadithBlocSubscription?.cancel();
    PopupWindowManager.dispose();
    return super.close();
  }

  /// Handle ShowPopup event - shows native NSPanel popup
  Future<void> _onShowPopup(
    ShowPopup event,
    Emitter<PopupState> emit,
  ) async {
    _currentHadith = event.hadith;

    // Load settings for position type and duration
    final settings = await _settingsRepository.loadSettings();
    _currentPositionType = settings.popupPositionType;
    _currentDisplayDuration = Duration(seconds: settings.popupDisplayDuration);
    _remainingMillis = _currentDisplayDuration.inMilliseconds;

    // Play notification sound if enabled
    if (settings.soundEnabled) {
      _audioService.playNotificationSound();
    }

    // On macOS we render popup content in the main Flutter window to avoid
    // second-engine rendering issues that can produce a blank/black window.
    if (!Platform.isMacOS) {
      try {
        await PopupWindowManager.showPopup(
          hadith: event.hadith,
          positionType: _currentPositionType,
          duration: _currentDisplayDuration,
        );
      } catch (e) {
        // Fallback to Flutter dialog if native popup fails
        debugPrint('Native popup failed, showing dialog: $e');
        _emitDialogState(event, settings, emit);
        return;
      }
    }

    // Emit state with full Hadith object
    emit(PopupVisible(
      hadith: event.hadith,
      position: event.position,
      positionType: _currentPositionType,
      remainingMillis: _remainingMillis,
      displayDuration: _currentDisplayDuration,
      isHovered: _isHovered,
      isDismissible: true,
    ));
  }

  /// Fallback to emit dialog state when native popup fails
  void _emitDialogState(
    ShowPopup event,
    UserSettings settings,
    Emitter<PopupState> emit,
  ) {
    PopupPosition? position = event.position;
    if (position == null) {
      position = const PopupPosition(100.0, 100.0);
    }

    emit(PopupVisible(
      hadith: event.hadith,
      position: position,
      positionType: settings.popupPositionType,
      remainingMillis: _currentDisplayDuration.inMilliseconds,
      displayDuration: _currentDisplayDuration,
      isHovered: _isHovered,
      isDismissible: true,
    ));
  }

  /// Handle HidePopup event - hides native popup
  Future<void> _onHidePopup(
    HidePopup event,
    Emitter<PopupState> emit,
  ) async {
    _autoDismissTimer?.cancel();
    if (!Platform.isMacOS) {
      await PopupWindowManager.hidePopup();
    }

    PopupPosition? lastPosition;
    if (state is PopupVisible) {
      lastPosition = (state as PopupVisible).position;
    }

    emit(PopupHidden(lastPosition: lastPosition));
  }

  /// Handle DismissPopup event - user-initiated dismiss
  Future<void> _onDismissPopup(
    DismissPopup event,
    Emitter<PopupState> emit,
  ) async {
    _autoDismissTimer?.cancel();
    if (!Platform.isMacOS) {
      await PopupWindowManager.hidePopup();
    }

    PopupPosition? lastPosition;
    if (state is PopupVisible) {
      final currentState = state as PopupVisible;
      lastPosition = currentState.position;

      // Save position if requested
      if (event.savePosition && currentState.position != null) {
        await _settingsRepository.updatePopupPosition(currentState.position!);
      }
    }

    emit(PopupHidden(lastPosition: lastPosition));
  }

  /// Handle StartAutoDismiss event - starts countdown timer
  Future<void> _onStartAutoDismiss(
    StartAutoDismiss event,
    Emitter<PopupState> emit,
  ) async {
    _autoDismissTimer?.cancel();

    if (event.duration == Duration.zero) {
      // No auto-dismiss
      return;
    }

    _remainingMillis = event.duration.inMilliseconds;

    // Start countdown timer (updates every 100ms for smooth progress)
    _autoDismissTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isHovered) {
        _remainingMillis -= 100;

        if (_remainingMillis <= 0) {
          timer.cancel();
          add(const DismissPopup());
        } else if (state is PopupVisible) {
          final currentState = state as PopupVisible;
          emit(currentState.copyWith(remainingMillis: _remainingMillis));
        }
      }
    });

    // Emit initial state with countdown
    if (state is PopupVisible) {
      final currentState = state as PopupVisible;
      emit(currentState.copyWith(
        remainingMillis: _remainingMillis,
      ));
    }
  }

  /// Handle UpdatePosition event - permanent position change
  Future<void> _onUpdatePosition(
    UpdatePosition event,
    Emitter<PopupState> emit,
  ) async {
    if (state is PopupVisible) {
      final currentState = state as PopupVisible;
      final newPosition = PopupPosition(event.dx, event.dy);

      // Save to repository
      await _settingsRepository.updatePopupPosition(newPosition);

      emit(currentState.copyWith(position: newPosition));
    }
  }

  /// Handle UpdateTemporaryPosition event - drag-to-move (not saved)
  Future<void> _onUpdateTemporaryPosition(
    UpdateTemporaryPosition event,
    Emitter<PopupState> emit,
  ) async {
    if (state is PopupVisible) {
      final currentState = state as PopupVisible;
      final newPosition = PopupPosition(event.dx, event.dy);

      emit(currentState.copyWith(position: newPosition));
    }
  }

  /// Handle HoverChanged event - pause/resume timer on hover
  Future<void> _onHoverChanged(
    HoverChanged event,
    Emitter<PopupState> emit,
  ) async {
    _isHovered = event.isHovered;

    // Notify native popup of hover state
    // This is handled by PopupWindowManager callbacks

    if (state is PopupVisible) {
      final currentState = state as PopupVisible;
      emit(currentState.copyWith(isHovered: _isHovered));
    }
  }

  /// Handle CopyHadith event - copy formatted text to clipboard
  Future<void> _onCopyHadith(
    CopyHadith event,
    Emitter<PopupState> emit,
  ) async {
    if (_currentHadith == null) return;

    final hadith = _currentHadith!;
    final formattedText = '''
${hadith.arabicText}

${hadith.narrator}
${hadith.sourceBook} - ${hadith.chapter}
Hadith ${hadith.hadithNumber}
'''
        .trim();

    await Clipboard.setData(ClipboardData(text: formattedText));
    debugPrint('Copied Hadith to clipboard');
  }

  /// Handle ShowNextHadith event - fetch and display new random Hadith
  Future<void> _onShowNextHadith(
    ShowNextHadith event,
    Emitter<PopupState> emit,
  ) async {
    // Fetch new random Hadith via HadithBloc
    final settings = await _settingsRepository.loadSettings();
    _hadithBloc.add(FetchRandomHadith(collection: settings.sourceCollection));

    // Wait for Hadith to load, then show popup
    // The loaded Hadith will be emitted by HadithBloc
    // We need to subscribe to HadithBloc state changes
    _hadithBlocSubscription?.cancel();
    _hadithBlocSubscription = _hadithBloc.stream.listen((hadithState) {
      if (hadithState is HadithLoaded) {
        add(ShowPopup(hadith: hadithState.hadith));
        _hadithBlocSubscription?.cancel();
      }
    });
  }

  /// Handle ToggleFavorite event - add/remove Hadith from favorites
  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<PopupState> emit,
  ) async {
    // This will be handled by FavoritesBloc
    // For now, just log
    debugPrint('Toggle favorite for Hadith: ${event.hadithId}');
  }

  /// Dispose handler for app quit cleanup
  Future<void> disposeOnAppQuit() async {
    _autoDismissTimer?.cancel();
    await PopupWindowManager.hidePopup();
  }
}
