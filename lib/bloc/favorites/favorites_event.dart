import '../../../data/models/hadith.dart';
import 'package:equatable/equatable.dart';

/// Base class for all Favorites events
abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all favorited Hadiths
class LoadFavorites extends FavoritesEvent {
  const LoadFavorites();
}

/// Event to add a Hadith to favorites
class AddFavorite extends FavoritesEvent {
  final Hadith hadith;

  const AddFavorite(this.hadith);

  @override
  List<Object?> get props => [hadith];
}

/// Event to remove a Hadith from favorites
class RemoveFavorite extends FavoritesEvent {
  final String hadithId;

  const RemoveFavorite(this.hadithId);

  @override
  List<Object?> get props => [hadithId];
}

/// Event to toggle favorite status of a Hadith
class ToggleFavorite extends FavoritesEvent {
  final Hadith hadith;

  const ToggleFavorite(this.hadith);

  @override
  List<Object?> get props => [hadith];
}

/// Event to clear all favorites
class ClearFavorites extends FavoritesEvent {
  const ClearFavorites();
}

/// Event to search through favorites
class SearchFavorites extends FavoritesEvent {
  final String query;

  const SearchFavorites(this.query);

  @override
  List<Object?> get props => [query];
}
