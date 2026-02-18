import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/hadith.dart';
import '../models/hadith_collection.dart';

/// LocalHadithService handles loading Hadiths from bundled JSON
class LocalHadithService {
  final List<Hadith> _cachedHadiths = [];
  bool _isLoaded = false;

  /// Load Hadiths from bundled JSON asset
  Future<List<Hadith>> loadHadiths() async {
    if (_isLoaded) {
      return _cachedHadiths;
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/data/hadiths.json');
      final Map<String, dynamic> json = jsonDecode(jsonString);

      final List<dynamic> hadithsData = json['hadiths'] as List<dynamic>;

      for (var item in hadithsData) {
        final hadith = Hadith.fromJson(item as Map<String, dynamic>);
        _cachedHadiths.add(hadith);
      }

      _isLoaded = true;
      return _cachedHadiths;
    } catch (e) {
      // Return empty list on error - app will handle gracefully
      return [];
    }
  }

  /// Get a random Hadith from the local collection
  Future<Hadith?> getRandomHadith([HadithCollection? filter]) async {
    if (!_isLoaded) {
      await loadHadiths();
    }

    if (_cachedHadiths.isEmpty) {
      return null;
    }

    List<Hadith> pool = _cachedHadiths;

    if (filter != null && filter != HadithCollection.all) {
      pool = _cachedHadiths
          .where((h) => h.collection == filter)
          .toList();

      if (pool.isEmpty) {
        // Fallback to all if filter yields no results
        pool = _cachedHadiths;
      }
    }

    pool.shuffle();
    return pool.first;
  }

  /// Get Hadiths by collection
  Future<List<Hadith>> getHadithsByCollection(HadithCollection collection) async {
    if (!_isLoaded) {
      await loadHadiths();
    }

    if (collection == HadithCollection.all) {
      return List.from(_cachedHadiths);
    }

    return _cachedHadiths
        .where((h) => h.collection == collection)
        .toList();
  }

  /// Get total count of local Hadiths
  Future<int> get count async {
    if (!_isLoaded) {
      await loadHadiths();
    }
    return _cachedHadiths.length;
  }

  /// Search for a Hadith by ID
  Hadith? getById(String id) {
    try {
      return _cachedHadiths.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get a random Hadith excluding specific IDs
  Future<Hadith?> getRandomHadithExcluding({
    required List<String> excludeIds,
    HadithCollection? collection,
  }) async {
    if (!_isLoaded) {
      await loadHadiths();
    }

    if (_cachedHadiths.isEmpty) {
      return null;
    }

    List<Hadith> pool = _cachedHadiths;

    // Filter by collection if specified
    if (collection != null && collection != HadithCollection.all) {
      pool = pool.where((h) => h.collection == collection).toList();

      if (pool.isEmpty) {
        // Fallback to all if filter yields no results
        pool = _cachedHadiths;
      }
    }

    // Exclude recently shown IDs
    pool = pool.where((h) => !excludeIds.contains(h.id)).toList();

    // If all are excluded, return a random one anyway (better than nothing)
    if (pool.isEmpty) {
      return await getRandomHadith(collection);
    }

    pool.shuffle();
    return pool.first;
  }
}
