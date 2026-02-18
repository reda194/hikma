import '../../../data/models/hadith.dart';
import 'package:equatable/equatable.dart';

/// Base class for all Hadith states
abstract class HadithState extends Equatable {
  const HadithState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any Hadith has been loaded
class HadithInitial extends HadithState {
  const HadithInitial();
}

/// Loading state while fetching a Hadith
class HadithLoading extends HadithState {
  const HadithLoading();
}

/// State when a Hadith has been successfully loaded
class HadithLoaded extends HadithState {
  final Hadith hadith;
  final List<Hadith> filteredHadiths;
  final List<String> recentlyShownIds;
  final Hadith? dailyHadith;

  const HadithLoaded({
    required this.hadith,
    this.filteredHadiths = const [],
    this.recentlyShownIds = const [],
    this.dailyHadith,
  });

  HadithLoaded copyWith({
    Hadith? hadith,
    List<Hadith>? filteredHadiths,
    List<String>? recentlyShownIds,
    Hadith? dailyHadith,
  }) {
    return HadithLoaded(
      hadith: hadith ?? this.hadith,
      filteredHadiths: filteredHadiths ?? this.filteredHadiths,
      recentlyShownIds: recentlyShownIds ?? this.recentlyShownIds,
      dailyHadith: dailyHadith ?? this.dailyHadith,
    );
  }

  @override
  List<Object?> get props => [hadith, filteredHadiths, recentlyShownIds, dailyHadith];
}

/// Error state when Hadith loading fails
class HadithError extends HadithState {
  final String message;

  const HadithError(this.message);

  @override
  List<Object?> get props => [message];
}
