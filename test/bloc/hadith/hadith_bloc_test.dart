import 'package:flutter_test/flutter_test.dart';
import 'package:hikma/bloc/hadith/hadith_bloc.dart';
import 'package:hikma/bloc/hadith/hadith_event.dart';
import 'package:hikma/bloc/hadith/hadith_state.dart';
import 'package:hikma/data/models/hadith.dart';
import 'package:hikma/data/models/hadith_collection.dart';
import 'package:mocktail/mocktail.dart';

import '../../mock/repositories.dart';

/// Mock HadithRepository with mocktail setup
class MockHadithRepositoryWithSetup extends MockHadithRepository {
  MockHadithRepositoryWithSetup() {
    // Register fallback values for mocktail
    registerFallbackValue(HadithLoaded(
      hadith: Hadith(
        id: '',
        arabicText: '',
        narrator: '',
        sourceBook: '',
        chapter: '',
        bookNumber: 0,
        hadithNumber: 0,
        collection: HadithCollection.all,
      ),
    ));
    registerFallbackValue(HadithCollection.bukhari);
  }
}

void main() {
  late MockHadithRepositoryWithSetup mockHadithRepository;
  late HadithBloc hadithBloc;
  late Hadith testHadith;

  setUp(() {
    mockHadithRepository = MockHadithRepositoryWithSetup();
    hadithBloc = HadithBloc(hadithRepository: mockHadithRepository);

    testHadith = TestHelpers.createTestHadith(
      id: 'test-hadith-1',
      arabicText: 'Test Arabic Hadith Text',
      narrator: 'Prophet Muhammad (peace be upon him)',
      sourceBook: 'Sahih Al-Bukhari',
      chapter: 'Belief',
      bookNumber: 1,
      hadithNumber: 1,
      collection: HadithCollection.bukhari,
    );
  });

  tearDown(() {
    hadithBloc.close();
  });

  group('HadithBloc', () {
    group('FetchRandomHadith', () {
      test('emits [HadithLoading, HadithLoaded] when fetch is successful',
          () async {
        // Arrange
        when(() => mockHadithRepository.getRandomHadithExcluding(
              excludeIds: any(named: 'excludeIds'),
              collection: any(named: 'collection'),
            )).thenAnswer((_) async => null);

        when(() => mockHadithRepository.getRandomHadith(any()))
            .thenAnswer((_) async => testHadith);

        when(() => mockHadithRepository.saveHistory(any()))
            .thenAnswer((_) async {});

        // Assert later
        final expected = [
          const HadithLoading(),
          isA<HadithLoaded>()
              .having((s) => s.hadith.id, 'hadith.id', 'test-hadith-1')
              .having((s) => s.recentlyShownIds.length, 'history length', 1),
        ];

        expectLater(hadithBloc.stream, emitsInOrder(expected));

        // Act
        hadithBloc.add(const FetchRandomHadith());
      });

      test('emits [HadithLoading, HadithError] when fetch fails', () async {
        // Arrange
        when(() => mockHadithRepository.getRandomHadithExcluding(
              excludeIds: any(named: 'excludeIds'),
              collection: any(named: 'collection'),
            )).thenAnswer((_) async => null);

        when(() => mockHadithRepository.getRandomHadith(any()))
            .thenThrow(Exception('Network error'));

        // Assert later
        final expected = [
          const HadithLoading(),
          isA<HadithError>().having(
            (s) => s.message,
            'message',
            contains('Failed to load Hadith'),
          ),
        ];

        expectLater(hadithBloc.stream, emitsInOrder(expected));

        // Act
        hadithBloc.add(const FetchRandomHadith());
      });

      test('uses exclusion list to avoid recently shown Hadiths', () async {
        // Arrange
        final newHadith = TestHelpers.createTestHadith(id: 'test-hadith-3');

        when(() => mockHadithRepository.getRandomHadithExcluding(
              excludeIds: any(named: 'excludeIds'),
              collection: any(named: 'collection'),
            )).thenAnswer((_) async => newHadith);

        when(() => mockHadithRepository.saveHistory(any()))
            .thenAnswer((_) async {});

        // Assert later - verify the random Hadith is loaded
        final expected = [
          const HadithLoading(),
          isA<HadithLoaded>()
              .having((s) => s.hadith.id, 'hadith.id', 'test-hadith-3'),
        ];

        expectLater(hadithBloc.stream, emitsInOrder(expected));

        // Act
        hadithBloc.add(const FetchRandomHadith());

        // Verify exclusion method was called
        await Future.delayed(const Duration(milliseconds: 100));
        verify(() => mockHadithRepository.getRandomHadithExcluding(
              excludeIds: any(named: 'excludeIds'),
              collection: any(named: 'collection'),
            )).called(1);
      });

      test('falls back to regular fetch when exclusion returns null', () async {
        // Arrange
        when(() => mockHadithRepository.getRandomHadithExcluding(
              excludeIds: any(named: 'excludeIds'),
              collection: any(named: 'collection'),
            )).thenAnswer((_) async => null);

        when(() => mockHadithRepository.getRandomHadith(any()))
            .thenAnswer((_) async => testHadith);

        when(() => mockHadithRepository.saveHistory(any()))
            .thenAnswer((_) async {});

        // Assert later
        expectLater(
          hadithBloc.stream,
          emitsInOrder([
            const HadithLoading(),
            isA<HadithLoaded>().having(
              (s) => s.hadith.id,
              'hadith.id',
              'test-hadith-1',
            ),
          ]),
        );

        // Act
        hadithBloc.add(const FetchRandomHadith());
      });
    });

    group('LoadDailyHadith', () {
      test('emits [HadithLoading, HadithLoaded] when daily Hadith is loaded',
          () async {
        // Arrange
        when(() => mockHadithRepository.getDailyHadith())
            .thenAnswer((_) async => testHadith);

        // Assert later
        final expected = [
          const HadithLoading(),
          isA<HadithLoaded>()
              .having((s) => s.hadith.id, 'hadith.id', 'test-hadith-1')
              .having(
                  (s) => s.dailyHadith?.id, 'dailyHadith.id', 'test-hadith-1'),
        ];

        expectLater(hadithBloc.stream, emitsInOrder(expected));

        // Act
        hadithBloc.add(const LoadDailyHadith());
      });

      test('emits [HadithLoading, HadithError] when daily Hadith load fails',
          () async {
        // Arrange
        when(() => mockHadithRepository.getDailyHadith())
            .thenAnswer((_) async => null);

        // Assert later
        final expected = [
          const HadithLoading(),
          isA<HadithError>().having(
            (s) => s.message,
            'message',
            'Could not load daily Hadith',
          ),
        ];

        expectLater(hadithBloc.stream, emitsInOrder(expected));

        // Act
        hadithBloc.add(const LoadDailyHadith());
      });

      test('handles exceptions when loading daily Hadith', () async {
        // Arrange
        when(() => mockHadithRepository.getDailyHadith())
            .thenThrow(Exception('Database error'));

        // Assert later
        final expected = [
          const HadithLoading(),
          isA<HadithError>().having(
            (s) => s.message,
            'message',
            contains('Failed to load daily Hadith'),
          ),
        ];

        expectLater(hadithBloc.stream, emitsInOrder(expected));

        // Act
        hadithBloc.add(const LoadDailyHadith());
      });
    });

    group('RefreshDailyHadith', () {
      test('emits [HadithLoading, HadithLoaded] when refresh is successful',
          () async {
        // Arrange
        final newHadith = TestHelpers.createTestHadith(id: 'new-daily-hadith');
        when(() => mockHadithRepository.refreshDailyHadith())
            .thenAnswer((_) async => newHadith);

        // Assert later
        final expected = [
          const HadithLoading(),
          isA<HadithLoaded>()
              .having((s) => s.hadith.id, 'hadith.id', 'new-daily-hadith')
              .having(
                (s) => s.dailyHadith?.id,
                'dailyHadith.id',
                'new-daily-hadith',
              ),
        ];

        expectLater(hadithBloc.stream, emitsInOrder(expected));

        // Act
        hadithBloc.add(const RefreshDailyHadith());
      });

      test('emits [HadithLoading, HadithError] when refresh fails', () async {
        // Arrange
        when(() => mockHadithRepository.refreshDailyHadith())
            .thenAnswer((_) async => null);

        // Assert later
        final expected = [
          const HadithLoading(),
          isA<HadithError>().having(
            (s) => s.message,
            'message',
            'Could not refresh daily Hadith',
          ),
        ];

        expectLater(hadithBloc.stream, emitsInOrder(expected));

        // Act
        hadithBloc.add(const RefreshDailyHadith());
      });
    });

    group('IncrementReadCount', () {
      test('calls incrementReadCount on repository without changing state',
          () async {
        // Arrange
        when(() => mockHadithRepository.incrementReadCount())
            .thenAnswer((_) async {});

        hadithBloc.emit(HadithLoaded(hadith: testHadith));

        // Act
        hadithBloc.add(const IncrementReadCount());
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify
        verify(() => mockHadithRepository.incrementReadCount()).called(1);
      });

      test('silently handles errors when incrementing read count', () async {
        // Arrange
        when(() => mockHadithRepository.incrementReadCount())
            .thenThrow(Exception('Storage error'));

        hadithBloc.emit(HadithLoaded(hadith: testHadith));

        // Act - should not throw
        hadithBloc.add(const IncrementReadCount());
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify call was attempted
        verify(() => mockHadithRepository.incrementReadCount()).called(1);
      });
    });

    group('FilterByCollection', () {
      test('emits [HadithLoading, HadithLoaded] when filter is successful',
          () async {
        // Arrange
        final hadiths = TestHelpers.createTestHadiths(5);

        when(() => mockHadithRepository.getHadithsByCollection(any()))
            .thenAnswer((_) async => hadiths);

        // Assert later
        expectLater(
          hadithBloc.stream,
          emitsInOrder([
            const HadithLoading(),
            isA<HadithLoaded>()
                .having((s) => s.filteredHadiths.length, 'filtered count', 5),
          ]),
        );

        // Act
        hadithBloc.add(const FilterByCollection(HadithCollection.bukhari));
      });

      test('emits [HadithLoading, HadithError] when filter fails', () async {
        // Arrange
        when(() => mockHadithRepository.getHadithsByCollection(any()))
            .thenThrow(Exception('Collection not found'));

        // Assert later
        final expected = [
          const HadithLoading(),
          isA<HadithError>().having(
            (s) => s.message,
            'message',
            contains('Failed to filter Hadiths'),
          ),
        ];

        expectLater(hadithBloc.stream, emitsInOrder(expected));

        // Act
        hadithBloc.add(const FilterByCollection(HadithCollection.muslim));
      });
    });
  });
}
