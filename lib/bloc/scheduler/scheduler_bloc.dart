import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../hadith/hadith_bloc.dart';
import '../../../data/models/user_settings.dart';
import '../../../data/repositories/settings_repository.dart';
import 'scheduler_event.dart';
import 'scheduler_state.dart';

/// SchedulerBloc manages periodic Hadith popup scheduling
class SchedulerBloc extends Bloc<SchedulerEvent, SchedulerState> {
  final SettingsRepository _settingsRepository;
  final HadithBloc _hadithBloc;

  Timer? _schedulerTimer;
  Timer? _elapsedTimer;
  int _elapsedSeconds = 0;

  SchedulerBloc({
    required SettingsRepository settingsRepository,
    required HadithBloc hadithBloc,
  })  : _settingsRepository = settingsRepository,
        _hadithBloc = hadithBloc,
        super(const SchedulerInitial()) {
    on<StartScheduler>(_onStartScheduler);
    on<StopScheduler>(_onStopScheduler);
    on<ResetTimer>(_onResetTimer);
    on<SettingsChanged>(_onSettingsChanged);
  }

  @override
  Future<void> close() {
    _schedulerTimer?.cancel();
    _elapsedTimer?.cancel();
    return super.close();
  }

  /// Handle StartScheduler event
  Future<void> _onStartScheduler(
    StartScheduler event,
    Emitter<SchedulerState> emit,
  ) async {
    // Cancel any existing timers
    _schedulerTimer?.cancel();
    _elapsedTimer?.cancel();

    try {
      final settings = await _settingsRepository.loadSettings();
      final interval = settings.reminderInterval.duration;

      final nextPopupTime = DateTime.now().add(interval);
      _elapsedSeconds = 0;

      emit(SchedulerRunning(
        nextPopupTime: nextPopupTime,
        interval: interval,
        elapsedSeconds: 0,
      ));

      // Start the elapsed timer for progress tracking
      _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _elapsedSeconds++;

        if (state is SchedulerRunning) {
          final currentState = state as SchedulerRunning;
          emit(currentState.copyWith(
            elapsedSeconds: _elapsedSeconds,
          ));
        }
      });

      // Start the main scheduler timer
      _schedulerTimer = Timer(interval, () {
        _elapsedTimer?.cancel();

        if (state is SchedulerRunning) {
          final currentState = state as SchedulerRunning;
          emit(currentState.copyWith(
            elapsedSeconds: interval.inSeconds,
          ));
        }

        // Trigger a new Hadith fetch
        _hadithBloc.add(const FetchRandomHadith());

        // Schedule next popup
        add(const StartScheduler());
      });
    } catch (e) {
      emit(SchedulerStopped(
        reason: 'Failed to start scheduler: ${e.toString()}',
      ));
    }
  }

  /// Handle StopScheduler event
  Future<void> _onStopScheduler(
    StopScheduler event,
    Emitter<SchedulerState> emit,
  ) async {
    _schedulerTimer?.cancel();
    _elapsedTimer?.cancel();
    _elapsedSeconds = 0;

    Duration? interval;
    if (state is SchedulerRunning) {
      interval = (state as SchedulerRunning).interval;
    }

    emit(SchedulerStopped(
      configuredInterval: interval,
      reason: 'Scheduler stopped by user',
    ));
  }

  /// Handle ResetTimer event
  Future<void> _onResetTimer(
    ResetTimer event,
    Emitter<SchedulerState> emit,
  ) async {
    if (state is SchedulerRunning) {
      final currentState = state as SchedulerRunning;
      _schedulerTimer?.cancel();
      _elapsedTimer?.cancel();
      _elapsedSeconds = 0;

      final nextPopupTime = DateTime.now().add(currentState.interval);

      emit(currentState.copyWith(
        nextPopupTime: nextPopupTime,
        elapsedSeconds: 0,
      ));

      _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _elapsedSeconds++;

        if (state is SchedulerRunning) {
          final runningState = state as SchedulerRunning;
          emit(runningState.copyWith(
            elapsedSeconds: _elapsedSeconds,
          ));
        }
      });

      _schedulerTimer = Timer(currentState.interval, () {
        _elapsedTimer?.cancel();

        if (state is SchedulerRunning) {
          final runningState = state as SchedulerRunning;
          emit(runningState.copyWith(
            elapsedSeconds: runningState.interval.inSeconds,
          ));
        }

        _hadithBloc.add(const FetchRandomHadith());
        add(const StartScheduler());
      });
    }
  }

  /// Handle SettingsChanged event
  Future<void> _onSettingsChanged(
    SettingsChanged event,
    Emitter<SchedulerState> emit,
  ) async {
    if (state is SchedulerRunning) {
      // Restart scheduler with new interval
      add(const StartScheduler());
    }
  }
}
