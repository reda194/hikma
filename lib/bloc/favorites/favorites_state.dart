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

  const FavoritesLoaded({
    this.favorites = const [],
    this.favoriteIds = const {},
  });

  FavoritesLoaded copyWith({
    List<Favorite>? favorites,
    Set<String>? favoriteIds,
  }) {
    return FavoritesLoaded(
      favorites: favorites ?? this.favoriteIds,
      favoriteIds: favoriteIds ?? this.favoriteIds,
    );
  }

  bool isFavorite(String hadithId) => favoriteIds.contains(hadithId);

  int get count => favorites.length;

  @override
  List<Object?> get props => [favorites, favoriteIds];
}

/// State when an error occurs
class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError(this.message);

  @override
  List<Object?> get props => [message];
}
