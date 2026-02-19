import '../../../data/models/hadith_collection.dart';
import 'package:equatable/equatable.dart';

/// Base class for all Hadith events
abstract class HadithEvent extends Equatable {
  const HadithEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch a random Hadith
class FetchRandomHadith extends HadithEvent {
  final HadithCollection? collection;

  const FetchRandomHadith({this.collection});

  @override
  List<Object?> get props => [collection];
}

/// Event to filter Hadiths by collection
class FilterByCollection extends HadithEvent {
  final HadithCollection collection;

  const FilterByCollection(this.collection);

  @override
  List<Object?> get props => [collection];
}

/// Event to load today's featured Hadith
class LoadDailyHadith extends HadithEvent {
  const LoadDailyHadith();

  @override
  List<Object?> get props => [];
}

/// Event to refresh today's featured Hadith
class RefreshDailyHadith extends HadithEvent {
  const RefreshDailyHadith();

  @override
  List<Object?> get props => [];
}

/// Event to increment the read count for today
class IncrementReadCount extends HadithEvent {
  const IncrementReadCount();

  @override
  List<Object?> get props => [];
}
