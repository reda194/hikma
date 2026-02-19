import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikma/bloc/favorites/favorites_bloc.dart';
import 'package:hikma/bloc/favorites/favorites_event.dart';
import 'package:hikma/bloc/favorites/favorites_state.dart';
import 'package:hikma/data/models/favorite.dart';
import 'package:hikma/data/models/hadith.dart';
import 'package:hikma/data/models/hadith_collection.dart';
import 'package:mocktail/mocktail.dart';

import '../../mock/repositories.dart';

/// Mock FavoritesRepository with mocktail setup
class MockFavoritesRepositoryWithSetup extends MockFavoritesRepository {
  MockFavoritesRepositoryWithSetup() {
    // Register fallback values for mocktail
    registerFallbackValue(const FavoritesLoaded(
      favorites: [],
      favoriteIds: {},
      searchQuery: '',
    ));
    registerFallbackValue(Hadith(
      id: '',
      arabicText: '',
      narrator: '',
      sourceBook: '',
      chapter: '',
      bookNumber: 0,
      hadithNumber: 0,
      collection: HadithCollection.bukhari,
    ));
  }
}

void main() {
  late MockFavoritesRepositoryWithSetup mockFavoritesRepository;
  late FavoritesBloc favoritesBloc;
  late Hadith testHadith;

  setUp(() {
    mockFavoritesRepository = MockFavoritesRepositoryWithSetup();
    favoritesBloc = FavoritesBloc(
      favoritesRepository: mockFavoritesRepository,
    );

    testHadith = TestHelpers.createTestHadith(
      id: 'test-hadith-1',
      arabicText: 'Test Arabic Hadith Text',
      narrator: 'Prophet Muhammad (peace be upon him)',
      sourceBook: 'Sahih Al-Bukhari',
      chapter: 'Belief',
      bookNumber: 1,
      hadithNumber: 1,
    );
  });

  tearDown(() {
    favoritesBloc.close();
  });

  group('FavoritesBloc', () {
    group('LoadFavorites', () {
      test('emits [FavoritesLoading, FavoritesLoaded] when load is successful',
          () async {
        // Arrange
        final testFavorites = [
          TestHelpers.createTestFavorite(
            hadith: testHadith,
            savedAt: DateTime(2026, 1, 1),
          ),
          TestHelpers.createTestFavorite(
            hadith: TestHelpers.createTestHadith(id: 'test-hadith-2'),
            savedAt: DateTime(2026, 1, 2),
          ),
        ];

        when(() => mockFavoritesRepository.getAllFavorites())
            .thenAnswer((_) async => testFavorites);

        // Assert later
        final expected = [
          const FavoritesLoading(),
          isA<FavoritesLoaded>()
              .having((s) => s.favorites.length, 'count', 2)
              .having((s) => s.favoriteIds.length, 'favoriteIds length', 2)
              .having(
                (s) => s.isFavorite('test-hadith-1'),
                'isFavorite test-hadith-1',
                true,
              )
              .having(
                (s) => s.isFavorite('test-hadith-2'),
                'isFavorite test-hadith-2',
                true,
              )
              .having(
                (s) => s.isFavorite('non-existent'),
                'isFavorite non-existent',
                false,
              ),
        ];

        expectLater(favoritesBloc.stream, emitsInOrder(expected));

        // Act
        favoritesBloc.add(const LoadFavorites());
      });

      test('emits [FavoritesLoading, FavoritesLoaded] with empty list when no favorites',
          () async {
        // Arrange
        when(() => mockFavoritesRepository.getAllFavorites())
            .thenAnswer((_) async => []);

        // Assert later
        final expected = [
          const FavoritesLoading(),
          isA<FavoritesLoaded>()
              .having((s) => s.favorites, 'favorites', isEmpty)
              .having((s) => s.favoriteIds, 'favoriteIds', isEmpty),
        ];

        expectLater(favoritesBloc.stream, emitsInOrder(expected));

        // Act
        favoritesBloc.add(const LoadFavorites());
      });

      test('emits [FavoritesLoading, FavoritesError] when load fails',
          () async {
        // Arrange
        when(() => mockFavoritesRepository.getAllFavorites())
            .thenThrow(Exception('Database error'));

        // Assert later
        final expected = [
          const FavoritesLoading(),
          isA<FavoritesError>().having(
            (s) => s.message,
            'message',
            contains('Failed to load favorites'),
          ),
        ];

        expectLater(favoritesBloc.stream, emitsInOrder(expected));

        // Act
        favoritesBloc.add(const LoadFavorites());
      });
    });

    group('ToggleFavorite', () {
      test('adds Hadith to favorites when not previously favorited',
          () async {
        // Arrange
        final updatedFavorites = [
          TestHelpers.createTestFavorite(hadith: testHadith),
        ];

        when(() => mockFavoritesRepository.toggleFavorite(any()))
            .thenAnswer((_) async => true);

        when(() => mockFavoritesRepository.getAllFavorites())
            .thenAnswer((_) async => updatedFavorites);

        // Assert later
        final expected = [
          isA<FavoritesLoaded>()
              .having((s) => s.favorites.length, 'count', 1)
              .having((s) => s.favoriteIds.contains('test-hadith-1'),
                  'contains test-hadith-1', true),
        ];

        expectLater(favoritesBloc.stream, emitsInOrder(expected));

        // Act
        favoritesBloc.add(ToggleFavorite(testHadith));
      });

      test('removes Hadith from favorites when previously favorited',
          () async {
        // Arrange
        when(() => mockFavoritesRepository.toggleFavorite(any()))
            .thenAnswer((_) async => false);

        when(() => mockFavoritesRepository.getAllFavorites())
            .thenAnswer((_) async => []);

        // Assert later
        final expected = [
          isA<FavoritesLoaded>()
              .having((s) => s.favorites, 'favorites', isEmpty)
              .having(
                (s) => s.favoriteIds.contains('test-hadith-1'),
                'contains test-hadith-1',
                false,
              ),
        ];

        expectLater(favoritesBloc.stream, emitsInOrder(expected));

        // Act
        favoritesBloc.add(ToggleFavorite(testHadith));
      });

      test('preserves current state on error', () async {
        // Arrange
        final currentState = FavoritesLoaded(
          favorites: [TestHelpers.createTestFavorite(hadith: testHadith)],
          favoriteIds: {'test-hadith-1'},
        );

        when(() => mockFavoritesRepository.toggleFavorite(any()))
            .thenThrow(Exception('Storage error'));

        favoritesBloc.emit(currentState);

        // Act
        favoritesBloc.add(ToggleFavorite(testHadith));
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify state is preserved (emits same state)
        expect(
          favoritesBloc.state,
          isA<FavoritesLoaded>().having(
            (s) => s.favoriteIds.contains('test-hadith-1'),
            'contains test-hadith-1',
            true,
          ),
        );
      });
    });

    group('AddFavorite', () {
      test('successfully adds a Hadith to favorites', () async {
        // Arrange
        when(() => mockFavoritesRepository.addFavorite(any()))
            .thenAnswer((_) async {});

        when(() => mockFavoritesRepository.getAllFavorites())
            .thenAnswer((_) async => [
                  TestHelpers.createTestFavorite(hadith: testHadith),
                ]);

        // Assert later
        final expected = [
          isA<FavoritesLoaded>()
              .having((s) => s.favorites.length, 'count', 1)
              .having(
                (s) => s.favorites.first.hadith.id,
                'first favorite id',
                'test-hadith-1',
              ),
        ];

        expectLater(favoritesBloc.stream, emitsInOrder(expected));

        // Act
        favoritesBloc.add(AddFavorite(testHadith));
      });

      test('handles errors when adding to favorites', () async {
        // Arrange
        when(() => mockFavoritesRepository.addFavorite(any()))
            .thenThrow(Exception('Storage full'));

        // Act - should not throw
        favoritesBloc.add(AddFavorite(testHadith));
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify the call was made
        verify(() => mockFavoritesRepository.addFavorite(testHadith)).called(1);
      });
    });

    group('RemoveFavorite', () {
      test('successfully removes a Hadith from favorites', () async {
        // Arrange
        when(() => mockFavoritesRepository.removeFavorite('test-hadith-1'))
            .thenAnswer((_) async {});

        when(() => mockFavoritesRepository.getAllFavorites())
            .thenAnswer((_) async => []);

        // Assert later
        final expected = [
          isA<FavoritesLoaded>()
              .having((s) => s.favorites, 'favorites', isEmpty)
              .having(
                (s) => s.favoriteIds.contains('test-hadith-1'),
                'contains test-hadith-1',
                false,
              ),
        ];

        expectLater(favoritesBloc.stream, emitsInOrder(expected));

        // Act
        favoritesBloc.add(const RemoveFavorite('test-hadith-1'));
      });

      test('handles errors when removing from favorites', () async {
        // Arrange
        when(() => mockFavoritesRepository.removeFavorite(any()))
            .thenThrow(Exception('Not found'));

        // Act - should not throw
        favoritesBloc.add(const RemoveFavorite('test-hadith-1'));
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify the call was made
        verify(() => mockFavoritesRepository.removeFavorite('test-hadith-1'))
            .called(1);
      });
    });

    group('ClearFavorites', () {
      test('successfully clears all favorites', () async {
        // Arrange
        when(() => mockFavoritesRepository.clearFavorites())
            .thenAnswer((_) async {});

        // Assert later
        final expected = [
          isA<FavoritesLoaded>()
              .having((s) => s.favorites, 'favorites', isEmpty)
              .having((s) => s.favoriteIds, 'favoriteIds', isEmpty)
              .having((s) => s.count, 'count', 0),
        ];

        expectLater(favoritesBloc.stream, emitsInOrder(expected));

        // Act
        favoritesBloc.add(const ClearFavorites());
      });

      test('handles errors when clearing favorites', () async {
        // Arrange
        final currentState = FavoritesLoaded(
          favorites: [
            TestHelpers.createTestFavorite(hadith: testHadith),
          ],
          favoriteIds: {'test-hadith-1'},
        );

        when(() => mockFavoritesRepository.clearFavorites())
            .thenThrow(Exception('Database locked'));

        favoritesBloc.emit(currentState);

        // Act
        favoritesBloc.add(const ClearFavorites());
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify the call was made
        verify(() => mockFavoritesRepository.clearFavorites()).called(1);
      });
    });

    group('SearchFavorites', () {
      test('filters favorites by search query', () async {
        // Arrange
        final hadith1 = TestHelpers.createTestHadith(
          id: 'hadith-1',
          arabicText: 'Say: He is Allah, the One',
          chapter: 'Faith',
        );
        final hadith2 = TestHelpers.createTestHadith(
          id: 'hadith-2',
          arabicText: 'Actions are judged by intentions',
          chapter: 'Belief',
        );
        final hadith3 = TestHelpers.createTestHadith(
          id: 'hadith-3',
          arabicText: 'The strong person is not the wrestler',
          chapter: 'Piety',
        );

        final currentState = FavoritesLoaded(
          favorites: [
            TestHelpers.createTestFavorite(hadith: hadith1),
            TestHelpers.createTestFavorite(hadith: hadith2),
            TestHelpers.createTestFavorite(hadith: hadith3),
          ],
          favoriteIds: {'hadith-1', 'hadith-2', 'hadith-3'},
        );

        favoritesBloc.emit(currentState);

        // Assert later - expect state with search query
        final expected = [
          isA<FavoritesLoaded>()
              .having((s) => s.searchQuery, 'searchQuery', 'intention')
              .having((s) => s.displayedFavorites.length, 'filtered count', 1)
              .having((s) => s.displayedFavorites.first.hadith.id, 'first id',
                  'hadith-2'),
        ];

        expectLater(favoritesBloc.stream, emitsInOrder(expected));

        // Act - search for "intention"
        favoritesBloc.add(const SearchFavorites('intention'));
      });

      test('returns all favorites when search query is empty', () async {
        // Arrange
        final hadith1 = TestHelpers.createTestHadith(id: 'hadith-1');
        final hadith2 = TestHelpers.createTestHadith(id: 'hadith-2');

        final currentState = FavoritesLoaded(
          favorites: [
            TestHelpers.createTestFavorite(hadith: hadith1),
            TestHelpers.createTestFavorite(hadith: hadith2),
          ],
          favoriteIds: {'hadith-1', 'hadith-2'},
          searchQuery: 'some query',
        );

        favoritesBloc.emit(currentState);

        // Assert later - expect state with empty search query
        final expected = [
          isA<FavoritesLoaded>()
              .having((s) => s.searchQuery, 'searchQuery', '')
              .having((s) => s.displayedFavorites.length, 'displayed count', 2),
        ];

        expectLater(favoritesBloc.stream, emitsInOrder(expected));

        // Act - clear search
        favoritesBloc.add(const SearchFavorites(''));
      });

      test('searches across multiple fields (arabic, narrator, source, chapter)',
          () {
        // Arrange
        final hadith1 = TestHelpers.createTestHadith(
          id: 'hadith-1',
          arabicText: 'Text about prayer',
          narrator: 'Abu Hurairah',
          sourceBook: 'Sahih Al-Bukhari',
          chapter: 'Prayer',
        );

        final currentState = FavoritesLoaded(
          favorites: [
            TestHelpers.createTestFavorite(hadith: hadith1),
          ],
          favoriteIds: {'hadith-1'},
        );

        favoritesBloc.emit(currentState);

        // Act - search by narrator
        favoritesBloc.add(const SearchFavorites('abu hurairah'));

        // Assert
        final newState = favoritesBloc.state as FavoritesLoaded;
        expect(newState.displayedFavorites.length, 1);
        expect(newState.displayedFavorites.first.hadith.id, 'hadith-1');
      });
    });

    group('FavoritesLoaded state', () {
      test('count property returns correct number of favorites', () {
        // Arrange & Act
        final state = FavoritesLoaded(
          favorites: [
            TestHelpers.createTestFavorite(),
            TestHelpers.createTestFavorite(
              hadith: TestHelpers.createTestHadith(id: 'hadith-2'),
            ),
            TestHelpers.createTestFavorite(
              hadith: TestHelpers.createTestHadith(id: 'hadith-3'),
            ),
          ],
          favoriteIds: {'hadith-1', 'hadith-2', 'hadith-3'},
        );

        // Assert
        expect(state.count, 3);
      });

      test('copyWith creates new state with updated values', () {
        // Arrange
        final state = FavoritesLoaded(
          favorites: [TestHelpers.createTestFavorite()],
          favoriteIds: {'hadith-1'},
        );

        // Act
        final updated = state.copyWith(
          searchQuery: 'test query',
          favorites: [
            TestHelpers.createTestFavorite(),
            TestHelpers.createTestFavorite(
              hadith: TestHelpers.createTestHadith(id: 'hadith-2'),
            ),
          ],
        );

        // Assert
        expect(updated.searchQuery, 'test query');
        expect(updated.favorites.length, 2);
        expect(state.searchQuery, ''); // Original unchanged
      });
    });
  });
}
