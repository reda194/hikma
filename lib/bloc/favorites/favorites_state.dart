import '../../../data/models/favorite.dart';
import 'package:equatable/equatable.dart';

/// Base class for all Favorites states
abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

/// Initial state before favorites have been loaded
class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

/// State while favorites are loading
class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

/// State when favorites have been successfully loaded
class FavoritesLoaded extends FavoritesState {
  final List<Favorite> favorites;
  final Set<String> favoriteIds;
  final String searchQuery;

  const FavoritesLoaded({
    this.favorites = const [],
    this.favoriteIds = const {},
    this.searchQuery = '',
  });

  FavoritesLoaded copyWith({
    List<Favorite>? favorites,
    Set<String>? favoriteIds,
    String? searchQuery,
  }) {
    return FavoritesLoaded(
      favorites: favorites ?? this.favorites,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool isFavorite(String hadithId) => favoriteIds.contains(hadithId);

  int get count => favorites.length;

  /// Get favorites filtered by search query
  List<Favorite> get displayedFavorites {
    if (searchQuery.isEmpty) {
      return favorites;
    }

    final query = searchQuery.toLowerCase();
    return favorites.where((favorite) {
      final arabicText = favorite.hadith.arabicText.toLowerCase();
      final narrator = favorite.hadith.narrator.toLowerCase();
      final sourceBook = favorite.hadith.sourceBook.toLowerCase();
      final chapter = favorite.hadith.chapter.toLowerCase();

      return arabicText.contains(query) ||
          narrator.contains(query) ||
          sourceBook.contains(query) ||
          chapter.contains(query);
    }).toList();
  }

  @override
  List<Object?> get props => [favorites, favoriteIds, searchQuery];
}

/// State when an error occurs
class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError(this.message);

  @override
  List<Object?> get props => [message];
}
