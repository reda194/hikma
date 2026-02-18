import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/hadith.dart';
import '../../../data/repositories/hadith_repository.dart';
import 'hadith_event.dart';
import 'hadith_state.dart';

/// HadithBloc manages Hadith data flow and state
class HadithBloc extends Bloc<HadithEvent, HadithState> {
  final HadithRepository _hadithRepository;

  HadithBloc({
    required HadithRepository hadithRepository,
  })  : _hadithRepository = hadithRepository,
        super(const HadithInitial()) {
    on<FetchRandomHadith>(_onFetchRandomHadith);
    on<FilterByCollection>(_onFilterByCollection);
    on<CacheHadith>(_onCacheHadith);
    on<LoadDailyHadith>(_onLoadDailyHadith);
    on<RefreshDailyHadith>(_onRefreshDailyHadith);
    on<IncrementReadCount>(_onIncrementReadCount);
  }

  /// Expose repository for external initialization
  HadithRepository get repository => _hadithRepository;

  /// Handle FetchRandomHadith event
  Future<void> _onFetchRandomHadith(
    FetchRandomHadith event,
    Emitter<HadithState> emit,
  ) async {
    emit(const HadithLoading());

    try {
      // Get current history if state is loaded
      List<String> history = [];
      if (state is HadithLoaded) {
        history = (state as HadithLoaded).recentlyShownIds;
      }

      // Try to fetch random Hadith excluding history
      Hadith? hadith = await _hadithRepository.getRandomHadithExcluding(
        excludeIds: history,
        collection: event.collection,
      );

      // Fallback to regular fetch if exclusion didn't work
      hadith ??= await _hadithRepository.getRandomHadith(event.collection);

      if (hadith != null) {
        // Update history (keep last 30)
        final newHistory = [...history, hadith.id];
        if (newHistory.length > 30) {
          newHistory.removeRange(0, newHistory.length - 30);
        }

        // Persist history to Hive
        await _hadithRepository.saveHistory(newHistory);

        emit(HadithLoaded(
          hadith: hadith,
          recentlyShownIds: newHistory,
        ));
      } else {
        emit(const HadithError('No Hadith found'));
      }
    } catch (e) {
      emit(HadithError('Failed to load Hadith: ${e.toString()}'));
    }
  }

  /// Handle FilterByCollection event
  Future<void> _onFilterByCollection(
    FilterByCollection event,
    Emitter<HadithState> emit,
  ) async {
    emit(const HadithLoading());

    try {
      // Get current history if state is loaded
      List<String> history = [];
      if (state is HadithLoaded) {
        history = (state as HadithLoaded).recentlyShownIds;
      }

      final hadiths = await _hadithRepository.getHadithsByCollection(
        event.collection,
      );

      // Filter out recently shown Hadiths
      final availableHadiths = hadiths
          .where((h) => !history.contains(h.id))
          .toList();

      // Use filtered list or fallback to all
      final pool = availableHadiths.isNotEmpty ? availableHadiths : hadiths;

      if (pool.isNotEmpty) {
        final randomHadith = pool[(pool.length * (DateTime.now().millisecond % 1000) / 1000).floor()];

        emit(HadithLoaded(
          hadith: randomHadith,
          filteredHadiths: hadiths,
          recentlyShownIds: history,
        ));
      } else {
        final fallbackHadith = await _hadithRepository.getRandomHadith(event.collection);
        emit(HadithLoaded(
          hadith: fallbackHadith ?? Hadith.empty(),
          filteredHadiths: hadiths,
          recentlyShownIds: history,
        ));
      }
    } catch (e) {
      emit(HadithError('Failed to filter Hadiths: ${e.toString()}'));
    }
  }

  /// Handle CacheHadith event
  Future<void> _onCacheHadith(
    CacheHadith event,
    Emitter<HadithState> emit,
  ) async {
    if (state is HadithLoaded) {
      try {
        final currentState = state as HadithLoaded;
        // The repository handles caching internally
        emit(currentState);
      } catch (e) {
        emit(HadithError('Failed to cache Hadith: ${e.toString()}'));
      }
    }
  }

  /// Handle LoadDailyHadith event
  Future<void> _onLoadDailyHadith(
    LoadDailyHadith event,
    Emitter<HadithState> emit,
  ) async {
    emit(const HadithLoading());

    try {
      final dailyHadith = await _hadithRepository.getDailyHadith();

      if (dailyHadith != null) {
        // Preserve current state properties
        final currentHistory = state is HadithLoaded
            ? (state as HadithLoaded).recentlyShownIds
            : <String>[];

        emit(HadithLoaded(
          hadith: dailyHadith,
          recentlyShownIds: currentHistory,
          dailyHadith: dailyHadith,
        ));
      } else {
        emit(const HadithError('Could not load daily Hadith'));
      }
    } catch (e) {
      emit(HadithError('Failed to load daily Hadith: ${e.toString()}'));
    }
  }

  /// Handle RefreshDailyHadith event
  Future<void> _onRefreshDailyHadith(
    RefreshDailyHadith event,
    Emitter<HadithState> emit,
  ) async {
    emit(const HadithLoading());

    try {
      final newDailyHadith = await _hadithRepository.refreshDailyHadith();

      if (newDailyHadith != null) {
        // Preserve current state properties
        final currentHistory = state is HadithLoaded
            ? (state as HadithLoaded).recentlyShownIds
            : <String>[];

        emit(HadithLoaded(
          hadith: newDailyHadith,
          recentlyShownIds: currentHistory,
          dailyHadith: newDailyHadith,
        ));
      } else {
        emit(const HadithError('Could not refresh daily Hadith'));
      }
    } catch (e) {
      emit(HadithError('Failed to refresh daily Hadith: ${e.toString()}'));
    }
  }

  /// Handle IncrementReadCount event
  Future<void> _onIncrementReadCount(
    IncrementReadCount event,
    Emitter<HadithState> emit,
  ) async {
    try {
      await _hadithRepository.incrementReadCount();
      // Don't change state, just update the statistics
      if (state is HadithLoaded) {
        emit(state as HadithLoaded);
      }
    } catch (e) {
      // Silently fail - statistics is optional functionality
    }
  }
}
