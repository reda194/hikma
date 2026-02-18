import 'package:equatable/equatable.dart';

/// ReadStatistics model for tracking Hadith reading activity
class ReadStatistics extends Equatable {
  final Map<String, int> dailyCounts; // date string -> count
  final List<String> recentDates; // chronological list of dates

  const ReadStatistics({
    this.dailyCounts = const {},
    this.recentDates = const [],
  });

  ReadStatistics copyWith({
    Map<String, int>? dailyCounts,
    List<String>? recentDates,
  }) {
    return ReadStatistics(
      dailyCounts: dailyCounts ?? this.dailyCounts,
      recentDates: recentDates ?? this.recentDates,
    );
  }

  /// Get today's date as a string (YYYY-MM-DD)
  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Get the count of Hadiths read today
  int getTodayCount() {
    final today = _getTodayString();
    return dailyCounts[today] ?? 0;
  }

  /// Get the count of Hadiths read this week (last 7 days)
  int getWeekCount() {
    final now = DateTime.now();
    int total = 0;

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      total += dailyCounts[dateString] ?? 0;
    }

    return total;
  }

  /// Get the total count of all Hadiths read
  int getTotalCount() {
    return dailyCounts.values.fold(0, (sum, count) => sum + count);
  }

  /// Increment the read count for today
  ReadStatistics incrementToday() {
    final today = _getTodayString();
    final newCounts = Map<String, int>.from(dailyCounts);
    newCounts[today] = (newCounts[today] ?? 0) + 1;

    final newDates = List<String>.from(recentDates);
    if (newDates.isEmpty || newDates.last != today) {
      newDates.add(today);
    }

    // Keep only last 30 days to prevent unbounded growth
    if (newDates.length > 30) {
      final oldDate = newDates.removeAt(0);
      newCounts.remove(oldDate);
    }

    return ReadStatistics(
      dailyCounts: newCounts,
      recentDates: newDates,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'dailyCounts': dailyCounts,
      'recentDates': recentDates,
    };
  }

  /// Create from JSON
  factory ReadStatistics.fromJson(Map<String, dynamic> json) {
    return ReadStatistics(
      dailyCounts: Map<String, int>.from(json['dailyCounts'] ?? {}),
      recentDates: List<String>.from(json['recentDates'] ?? []),
    );
  }

  /// Empty statistics
  static const empty = ReadStatistics();

  @override
  List<Object?> get props => [dailyCounts, recentDates];
}
