import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/hadith.dart';
import '../../../data/models/hadith_collection.dart';
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
  }

  /// Handle FetchRandomHadith event
  Future<void> _onFetchRandomHadith(
    FetchRandomHadith event,
    Emitter<HadithState> emit,
  ) async {
    emit(const HadithLoading());

    try {
      final hadith = await _hadithRepository.getRandomHadith(event.collection);

      if (hadith != null) {
        emit(HadithLoaded(hadith: hadith));
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
      final hadiths = await _hadithRepository.getHadithsByCollection(
        event.collection,
      );

      // Get a random hadith from filtered results
      if (hadiths.isNotEmpty) {
        final randomHadith = hadiths.isNotEmpty
            ? hadiths[(hadiths.length * (DateTime.now().millisecond % 1000) / 1000).floor()]
            : null;

        if (randomHadith != null) {
          emit(HadithLoaded(
            hadith: randomHadith,
            filteredHadiths: hadiths,
          ));
        }
      } else {
        final fallbackHadith = await _hadithRepository.getRandomHadith(event.collection);
        emit(HadithLoaded(
          hadith: fallbackHadith ?? Hadith.empty(),
          filteredHadiths: hadiths,
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
}
