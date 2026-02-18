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

/// Event to cache a Hadith for offline access
class CacheHadith extends HadithEvent {
  final String hadithId;

  const CacheHadith(this.hadithId);

  @override
  List<Object?> get props => [hadithId];
}
