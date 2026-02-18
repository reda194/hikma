import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/favorites_repository.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

/// FavoritesBloc manages favorited Hadiths with Hive CRUD operations
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepository _favoritesRepository;

  FavoritesBloc({
    required FavoritesRepository favoritesRepository,
  })  : _favoritesRepository = favoritesRepository,
        super(const FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<AddFavorite>(_onAddFavorite);
    on<RemoveFavorite>(_onRemoveFavorite);
    on<ToggleFavorite>(_onToggleFavorite);
    on<IsFavorite>(_onIsFavorite);
    on<ClearFavorites>(_onClearFavorites);
    on<SearchFavorites>(_onSearchFavorites);
  }

  /// Handle LoadFavorites event
  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesLoading());

    try {
      final favorites = await _favoritesRepository.getAllFavorites();
      final favoriteIds = favorites.map((f) => f.hadith.id).toSet();

      emit(FavoritesLoaded(
        favorites: favorites,
        favoriteIds: favoriteIds,
      ));
    } catch (e) {
      emit(FavoritesError('Failed to load favorites: ${e.toString()}'));
    }
  }

  /// Handle AddFavorite event
  Future<void> _onAddFavorite(
    AddFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await _favoritesRepository.addFavorite(event.hadith);

      // Reload favorites to get updated list
      final favorites = await _favoritesRepository.getAllFavorites();
      final favoriteIds = favorites.map((f) => f.hadith.id).toSet();

      emit(FavoritesLoaded(
        favorites: favorites,
        favoriteIds: favoriteIds,
      ));
    } catch (e) {
      // Keep current state on error
      if (state is FavoritesLoaded) {
        emit(state);
      }
    }
  }

  /// Handle RemoveFavorite event
  Future<void> _onRemoveFavorite(
    RemoveFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await _favoritesRepository.removeFavorite(event.hadithId);

      // Reload favorites to get updated list
      final favorites = await _favoritesRepository.getAllFavorites();
      final favoriteIds = favorites.map((f) => f.hadith.id).toSet();

      emit(FavoritesLoaded(
        favorites: favorites,
        favoriteIds: favoriteIds,
      ));
    } catch (e) {
      // Keep current state on error
      if (state is FavoritesLoaded) {
        emit(state);
      }
    }
  }

  /// Handle ToggleFavorite event
  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final isFavorited = await _favoritesRepository.toggleFavorite(event.hadith);

      // Reload favorites to get updated list
      final favorites = await _favoritesRepository.getAllFavorites();
      final favoriteIds = favorites.map((f) => f.hadith.id).toSet();

      emit(FavoritesLoaded(
        favorites: favorites,
        favoriteIds: favoriteIds,
      ));
    } catch (e) {
      // Keep current state on error
      if (state is FavoritesLoaded) {
        emit(state);
      }
    }
  }

  /// Handle IsFavorite event (check without modifying state)
  Future<void> _onIsFavorite(
    IsFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    // This event doesn't change state, just queries
    // The result can be obtained via repository or from current state
    if (state is FavoritesLoaded) {
      final loadedState = state as FavoritesLoaded;
      // No state change needed, query via isFavorite method on state
      emit(loadedState);
    }
  }

  /// Handle ClearFavorites event
  Future<void> _onClearFavorites(
    ClearFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await _favoritesRepository.clearFavorites();

      emit(const FavoritesLoaded(
        favorites: [],
        favoriteIds: {},
      ));
    } catch (e) {
      // Keep current state on error
      if (state is FavoritesLoaded) {
        emit(state);
      }
    }
  }

  /// Handle SearchFavorites event
  void _onSearchFavorites(
    SearchFavorites event,
    Emitter<FavoritesState> emit,
  ) {
    if (state is FavoritesLoaded) {
      final loadedState = state as FavoritesLoaded;
      emit(loadedState.copyWith(searchQuery: event.query));
    }
  }
}
