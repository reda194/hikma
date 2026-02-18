import 'package:equatable/equatable.dart';

/// Base class for all Scheduler events
abstract class SchedulerEvent extends Equatable {
  const SchedulerEvent();

  @override
  List<Object?> get props => [];
}

/// Event to start the scheduler for periodic Hadith popups
class StartScheduler extends SchedulerEvent {
  const StartScheduler();
}

/// Event to stop the scheduler
class StopScheduler extends SchedulerEvent {
  const StopScheduler();
}

/// Event to reset the timer to the beginning of the interval
class ResetTimer extends SchedulerEvent {
  const ResetTimer();
}

/// Event triggered when settings change that affect scheduling
class SettingsChanged extends SchedulerEvent {
  final Duration? newInterval;

  const SettingsChanged({this.newInterval});

  @override
  List<Object?> get props => [newInterval];
}
