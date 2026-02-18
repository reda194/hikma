import 'package:dio/dio.dart';
import '../models/hadith.dart';
import '../../core/constants/app_constants.dart';

/// HadithApiService handles fetching Hadiths from the external API
class HadithApiService {
  final Dio _dio;
  final String baseUrl;

  HadithApiService({Dio? dio})
      : _dio = dio ?? Dio(),
        baseUrl = AppConstants.apiBaseUrl {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.sendTimeout = const Duration(seconds: 10);
  }

  /// Fetch a random Hadith from the specified collection
  Future<Hadith?> fetchRandomHadith(String collection) async {
    try {
      final response = await _dio.get(
        '/books/$collection/random',
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? response.data['data']
            : response.data;

        if (data is Map<String, dynamic>) {
          return Hadith.fromApi(data);
        }
      }
      return null;
    } catch (e) {
      // Silent error handling - return null to trigger fallback
      return null;
    }
  }

  /// Fetch Hadiths from a specific book in a collection
  Future<List<Hadith>> fetchHadithsFromBook(
    String collection,
    int bookNumber, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/books/$collection/$bookNumber',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as List?;
        if (data != null) {
          return data
              .map((item) => Hadith.fromApi(item as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get all books in a collection
  Future<List<Map<String, dynamic>>> fetchBooks(String collection) async {
    try {
      final response = await _dio.get('/books/$collection');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as List?;
        if (data != null) {
          return data.map((e) => e as Map<String, dynamic>).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
