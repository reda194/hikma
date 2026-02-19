import 'package:mocktail/mocktail.dart';
import 'package:hive/hive.dart';
import 'package:hikma/data/models/hadith.dart';
import 'package:hikma/data/models/hadith_collection.dart';
import 'package:hikma/data/models/favorite.dart';
import 'package:hikma/data/models/read_statistics.dart';
import 'package:hikma/data/repositories/hadith_repository.dart';
import 'package:hikma/data/repositories/favorites_repository.dart';

/// Mock implementation of HadithRepository for testing
class MockHadithRepository extends Mock implements HadithRepository {}

/// Mock implementation of FavoritesRepository for testing
class MockFavoritesRepository extends Mock implements FavoritesRepository {}

/// Mock implementation of HiveInterface for testing
class MockHive extends Mock implements HiveInterface {}

/// Mock implementation of Box for testing
class MockBox extends Mock implements Box {}

/// Test utilities
class TestHelpers {
  /// Creates a test Hadith with default values
  static Hadith createTestHadith({
    String id = 'test-hadith-1',
    String arabicText = 'Test Arabic Text',
    String narrator = 'Test Narrator',
    String sourceBook = 'Test Source',
    String chapter = 'Test Chapter',
    int bookNumber = 1,
    int hadithNumber = 1,
    HadithCollection collection = HadithCollection.bukhari,
  }) {
    return Hadith(
      id: id,
      arabicText: arabicText,
      narrator: narrator,
      sourceBook: sourceBook,
      chapter: chapter,
      bookNumber: bookNumber,
      hadithNumber: hadithNumber,
      collection: collection,
    );
  }

  /// Creates a test Favorite with default values
  static Favorite createTestFavorite({
    Hadith? hadith,
    DateTime? savedAt,
  }) {
    return Favorite(
      hadith: hadith ?? createTestHadith(),
      savedAt: savedAt ?? DateTime.now(),
    );
  }

  /// Creates a list of test Hadiths
  static List<Hadith> createTestHadiths(int count) {
    return List.generate(
      count,
      (index) => createTestHadith(
        id: 'test-hadith-$index',
        arabicText: 'Test Arabic Text $index',
        hadithNumber: index + 1,
      ),
    );
  }
}
