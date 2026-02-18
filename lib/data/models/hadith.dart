import 'package:equatable/equatable.dart';
import 'hadith_collection.dart';

/// Hadith entity representing a single Prophetic narration
class Hadith extends Equatable {
  final String id;
  final String arabicText;
  final String narrator;
  final String sourceBook;
  final String chapter;
  final int bookNumber;
  final int hadithNumber;
  final HadithCollection collection;

  const Hadith({
    required this.id,
    required this.arabicText,
    required this.narrator,
    required this.sourceBook,
    required this.chapter,
    required this.bookNumber,
    required this.hadithNumber,
    required this.collection,
  });

  Hadith copyWith({
    String? id,
    String? arabicText,
    String? narrator,
    String? sourceBook,
    String? chapter,
    int? bookNumber,
    int? hadithNumber,
    HadithCollection? collection,
  }) {
    return Hadith(
      id: id ?? this.id,
      arabicText: arabicText ?? this.arabicText,
      narrator: narrator ?? this.narrator,
      sourceBook: sourceBook ?? this.sourceBook,
      chapter: chapter ?? this.chapter,
      bookNumber: bookNumber ?? this.bookNumber,
      hadithNumber: hadithNumber ?? this.hadithNumber,
      collection: collection ?? this.collection,
    );
  }

  /// Convert Hadith to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arabicText': arabicText,
      'narrator': narrator,
      'sourceBook': sourceBook,
      'chapter': chapter,
      'bookNumber': bookNumber,
      'hadithNumber': hadithNumber,
      'collection': collection.apiValue,
    };
  }

  /// Create Hadith from JSON
  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      id: json['id'] as String,
      arabicText: json['arabicText'] as String,
      narrator: json['narrator'] as String,
      sourceBook: json['sourceBook'] as String,
      chapter: json['chapter'] as String,
      bookNumber: json['bookNumber'] as int,
      hadithNumber: json['hadithNumber'] as int,
      collection: HadithCollection.fromApiValue(
        json['collection'] as String? ?? 'all',
      ),
    );
  }

  /// Create Hadith from API response
  factory Hadith.fromApi(Map<String, dynamic> data) {
    final collection = HadithCollection.fromApiValue(
      data['collection'] as String? ?? 'bukhari',
    );
    final bookNum = data['bookNumber'] as int? ?? 1;
    final hadithNum = data['hadithNumber'] as int? ?? 1;

    return Hadith(
      id: '${collection.apiValue}-$bookNum-$hadithNum',
      arabicText: data['arabic'] as String? ?? '',
      narrator: data['narrator'] as String? ?? '',
      sourceBook: collection.displayName,
      chapter: data['chapter'] as String? ?? '',
      bookNumber: bookNum,
      hadithNumber: hadithNum,
      collection: collection,
    );
  }

  /// Create an empty Hadith placeholder
  factory Hadith.empty() {
    return const Hadith(
      id: '',
      arabicText: '',
      narrator: '',
      sourceBook: '',
      chapter: '',
      bookNumber: 0,
      hadithNumber: 0,
      collection: HadithCollection.all,
    );
  }

  @override
  List<Object?> get props => [
        id,
        arabicText,
        narrator,
        sourceBook,
        chapter,
        bookNumber,
        hadithNumber,
        collection,
      ];
}
