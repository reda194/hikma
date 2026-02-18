import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:hikma/bloc/scheduler/scheduler_bloc.dart';
import 'package:hikma/bloc/scheduler/scheduler_event.dart';
import 'package:hikma/bloc/scheduler/scheduler_state.dart';
import 'package:hikma/bloc/hadith/hadith_bloc.dart';
import 'package:hikma/data/repositories/settings_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([SettingsRepository, HadithBloc])
import 'scheduler_bloc_test.mocks.dart';

/// BLoC tests for SchedulerBloc start/stop functionality
void main() {
  late MockSettingsRepository mockSettingsRepository;
  late MockHadithBloc mockHadithBloc;
  late SchedulerBloc schedulerBloc;

  setUp(() {
    mockSettingsRepository = MockSettingsRepository();
    mockHadithBloc = MockHadithBloc();
    schedulerBloc = SchedulerBloc(
      settingsRepository: mockSettingsRepository,
      hadithBloc: mockHadithBloc,
    );
  });

  tearDown(() {
    schedulerBloc.close();
  });

  group('SchedulerBloc', () {
    blocTest<SchedulerBloc, SchedulerState>(
      'emits SchedulerRunning when StartScheduler is added',
      build: () {
        when(mockSettingsRepository.loadSettings())
            .thenAnswer((_) async => const UserSettings());
        return schedulerBloc;
      },
      act: (bloc) => bloc.add(const StartScheduler()),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<SchedulerRunning>()
            .having((s) => s.interval, 'interval', isNotNull)
            .having((s) => s.elapsedSeconds, 'elapsedSeconds', 0),
      ],
    );

    blocTest<SchedulerBloc, SchedulerState>(
      'emits SchedulerStopped when StopScheduler is added',
      build: () {
        when(mockSettingsRepository.loadSettings())
            .thenAnswer((_) async => const UserSettings());
        return schedulerBloc;
      },
      seed: () => SchedulerRunning(
        interval: const Duration(hours: 1),
        elapsedSeconds: 0,
      ),
      act: (bloc) => bloc.add(const StopScheduler()),
      expect: () => [
        isA<SchedulerStopped>()
            .having((s) => s.configuredInterval, 'configuredInterval', isNotNull),
      ],
    );

    blocTest<SchedulerBloc, SchedulerState>(
      'restarts when SettingsChanged event is added while running',
      build: () {
        when(mockSettingsRepository.loadSettings())
            .thenAnswer((_) async => const UserSettings());
        return schedulerBloc;
      },
      seed: () => SchedulerRunning(
        interval: const Duration(hours: 1),
        elapsedSeconds: 100,
      ),
      act: (bloc) => bloc.add(const SettingsChanged()),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<SchedulerRunning>()
            .having((s) => s.elapsedSeconds, 'elapsedSeconds', 0),
      ],
    );

    blocTest<SchedulerBloc, SchedulerState>(
      'resets timer when ResetTimer is added',
      build: () {
        when(mockSettingsRepository.loadSettings())
            .thenAnswer((_) async => const UserSettings());
        return schedulerBloc;
      },
      seed: () => SchedulerRunning(
        interval: const Duration(hours: 1),
        elapsedSeconds: 1800,
      ),
      act: (bloc) => bloc.add(const ResetTimer()),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<SchedulerRunning>()
            .having((s) => s.elapsedSeconds, 'elapsedSeconds', 0),
      ],
    );
  });
}
