import 'package:equatable/equatable.dart';

/// Base class for all Scheduler states
abstract class SchedulerState extends Equatable {
  const SchedulerState();

  @override
  List<Object?> get props => [];
}

/// Initial state before scheduler has been configured
class SchedulerInitial extends SchedulerState {
  const SchedulerInitial();
}

/// State when the scheduler is actively running
class SchedulerRunning extends SchedulerState {
  final DateTime nextPopupTime;
  final Duration interval;
  final int elapsedSeconds;

  const SchedulerRunning({
    required this.nextPopupTime,
    required this.interval,
    this.elapsedSeconds = 0,
  });

  SchedulerRunning copyWith({
    DateTime? nextPopupTime,
    Duration? interval,
    int? elapsedSeconds,
  }) {
    return SchedulerRunning(
      nextPopupTime: nextPopupTime ?? this.nextPopupTime,
      interval: interval ?? this.interval,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }

  double get progress {
    if (interval.inSeconds == 0) return 0;
    return elapsedSeconds / interval.inSeconds;
  }

  Duration get remaining {
    final remaining = interval - Duration(seconds: elapsedSeconds);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  @override
  List<Object?> get props => [nextPopupTime, interval, elapsedSeconds];
}

/// State when the scheduler is stopped
class SchedulerStopped extends SchedulerState {
  final Duration? configuredInterval;
  final String? reason;

  const SchedulerStopped({
    this.configuredInterval,
    this.reason,
  });

  @override
  List<Object?> get props => [configuredInterval, reason];
}
