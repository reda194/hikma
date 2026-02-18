import 'package:equatable/equatable.dart';
import 'hadith.dart';

/// Favorite entity representing a bookmarked Hadith
class Favorite extends Equatable {
  final Hadith hadith;
  final DateTime savedAt;

  const Favorite({
    required this.hadith,
    required this.savedAt,
  });

  Favorite copyWith({
    Hadith? hadith,
    DateTime? savedAt,
  }) {
    return Favorite(
      hadith: hadith ?? this.hadith,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hadithId': hadith.id,
      'savedAt': savedAt.toIso8601String(),
      'hadith': hadith.toJson(),
    };
  }

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      hadith: Hadith.fromJson(json['hadith'] as Map<String, dynamic>),
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [hadith, savedAt];
}
