import '../models/hadith.dart';
import '../models/hadith_collection.dart';
import '../services/hadith_api_service.dart';
import '../services/local_hadith_service.dart';
import '../services/connectivity_service.dart';
import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/storage_keys.dart';

/// HadithRepository manages Hadith data access with offline-first strategy
class HadithRepository {
  final HadithApiService _apiService;
  final LocalHadithService _localService;
  final ConnectivityService _connectivityService;
  final HiveInterface _hive;

  HadithRepository({
    HadithApiService? apiService,
    LocalHadithService? localService,
    ConnectivityService? connectivityService,
    HiveInterface? hive,
  })  : _apiService = apiService ?? HadithApiService(),
        _localService = localService ?? LocalHadithService(),
        _connectivityService = connectivityService ?? ConnectivityService(),
        _hive = hive ?? Hive;

  late Box _cacheBox;

  /// Initialize the repository
  Future<void> init() async {
    if (!_hive.isBoxOpen(StorageKeys.cacheBox)) {
      await _hive.openBox(StorageKeys.cacheBox);
    }
    _cacheBox = _hive.box(StorageKeys.cacheBox);

    // Pre-load local Hadiths
    await _localService.loadHadiths();
  }

  /// Get a random Hadith with offline fallback
  /// Tries API first when online, falls back to local JSON
  Future<Hadith?> getRandomHadith([HadithCollection? collection]) async {
    final collectionValue = collection?.apiValue ?? 'all';

    // Try cache first
    final cached = _getCachedHadith(collectionValue);
    if (cached != null) {
      return cached;
    }

    // Try API if online
    if (await _connectivityService.isOnline) {
      try {
        final apiHadith = await _apiService.fetchRandomHadith(collectionValue);
        if (apiHadith != null) {
          // Cache the result
          await _cacheHadith(apiHadith);
          return apiHadith;
        }
      } catch (_) {
        // Silent fallback to local
      }
    }

    // Fallback to local bundled JSON
    return await _localService.getRandomHadith(collection);
  }

  /// Get Hadiths filtered by collection
  Future<List<Hadith>> getHadithsByCollection(
    HadithCollection collection) async {
    if (collection == HadithCollection.all) {
      return await _localService.getHadithsByCollection(collection);
    }

    // Try API first when online
    if (await _connectivityService.isOnline) {
      try {
        final apiHadiths =
            await _apiService.fetchHadithsFromBook(collection.apiValue, 1);
        if (apiHadiths.isNotEmpty) {
          return apiHadiths;
        }
      } catch (_) {
        // Fallback to local
      }
    }

    // Fallback to local
    return await _localService.getHadithsByCollection(collection);
  }

  /// Get a specific Hadith by ID
  Future<Hadith?> getHadithById(String id) async {
    // Check local first
    final local = _localService.getById(id);
    if (local != null) {
      return local;
    }

    // Check cache
    return _getCachedHadithById(id);
  }

  /// Cache a Hadith from the API
  Future<void> _cacheHadith(Hadith hadith) async {
    final expiresAt =
        DateTime.now().add(AppConstants.cacheExpiration).toIso8601String();

    await _cacheBox.put('${StorageKeys.cachePrefix}${hadith.id}', {
      'hadith': hadith.toJson(),
      StorageKeys.cacheTimestamp: DateTime.now().toIso8601String(),
      StorageKeys.cacheExpiresAt: expiresAt,
    });
  }

  /// Get a cached Hadith if not expired
  Hadith? _getCachedHadith(String collection) {
    // Find any cached Hadith matching the collection
    for (final key in _cacheBox.keys) {
      if (key.toString().startsWith(StorageKeys.cachePrefix)) {
        final data = _cacheBox.get(key);
        if (data != null && data is Map<String, dynamic>) {
          final expiresAtStr = data[StorageKeys.cacheExpiresAt] as String?;
          if (expiresAtStr != null) {
            final expiresAt = DateTime.parse(expiresAtStr);
            if (DateTime.now().isBefore(expiresAt)) {
              final hadithData = data['hadith'] as Map<String, dynamic>;
              final hadith = Hadith.fromJson(hadithData);
              if (collection == 'all' || hadith.collection.apiValue == collection) {
                return hadith;
              }
            }
          }
        }
      }
    }
    return null;
  }

  /// Get cached Hadith by ID
  Hadith? _getCachedHadithById(String id) {
    final data = _cacheBox.get('${StorageKeys.cachePrefix}$id');
    if (data != null && data is Map<String, dynamic>) {
      final expiresAtStr = data[StorageKeys.cacheExpiresAt] as String?;
      if (expiresAtStr != null) {
        final expiresAt = DateTime.parse(expiresAtStr);
        if (DateTime.now().isBefore(expiresAt)) {
          return Hadith.fromJson(data['hadith'] as Map<String, dynamic>);
        }
      }
    }
    return null;
  }

  /// Clear expired cache entries
  Future<void> clearExpiredCache() async {
    final now = DateTime.now();

    for (final key in _cacheBox.keys) {
      if (key.toString().startsWith(StorageKeys.cachePrefix)) {
        final data = _cacheBox.get(key);
        if (data != null && data is Map<String, dynamic>) {
          final expiresAtStr = data[StorageKeys.cacheExpiresAt] as String?;
          if (expiresAtStr != null) {
            final expiresAt = DateTime.parse(expiresAtStr);
            if (now.isAfter(expiresAt)) {
              await _cacheBox.delete(key);
            }
          }
        }
      }
    }
  }

  /// Get count of local Hadiths
  Future<int> get localCount => _localService.count;
}
