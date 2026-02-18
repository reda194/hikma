import 'package:hive/hive.dart';
import '../models/favorite.dart';
import '../models/hadith.dart';
import '../../core/constants/storage_keys.dart';

/// FavoritesRepository manages bookmarked Hadiths via Hive
class FavoritesRepository {
  final HiveInterface _hive;

  FavoritesRepository({HiveInterface? hive}) : _hive = hive ?? Hive;

  late Box _favoritesBox;

  /// Initialize the favorites repository
  Future<void> init() async {
    if (!_hive.isBoxOpen(StorageKeys.favoritesBox)) {
      await _hive.openBox(StorageKeys.favoritesBox);
    }
    _favoritesBox = _hive.box(StorageKeys.favoritesBox);
  }

  /// Get all favorited Hadiths
  Future<List<Favorite>> getAllFavorites() async {
    await init();

    final favorites = <Favorite>[];

    for (final key in _favoritesBox.keys) {
      final data = _favoritesBox.get(key);
      if (data != null && data is Map<String, dynamic>) {
        try {
          favorites.add(Favorite.fromJson(data));
        } catch (_) {
          // Skip corrupted entries
        }
      }
    }

    // Sort by savedAt descending (newest first)
    favorites.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return favorites;
  }

  /// Check if a Hadith is favorited
  Future<bool> isFavorite(String hadithId) async {
    await init();
    return _favoritesBox.containsKey(hadithId);
  }

  /// Add a Hadith to favorites
  Future<void> addFavorite(Hadith hadith) async {
    await init();

    final favorite = Favorite(
      hadith: hadith,
      savedAt: DateTime.now(),
    );

    await _favoritesBox.put(hadith.id, favorite.toJson());
  }

  /// Remove a Hadith from favorites
  Future<void> removeFavorite(String hadithId) async {
    await init();
    await _favoritesBox.delete(hadithId);
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(Hadith hadith) async {
    await init();

    if (await isFavorite(hadith.id)) {
      await removeFavorite(hadith.id);
      return false;
    } else {
      await addFavorite(hadith);
      return true;
    }
  }

  /// Get count of favorites
  Future<int> get count async {
    await init();
    return _favoritesBox.length;
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    await init();
    await _favoritesBox.clear();
  }
}
