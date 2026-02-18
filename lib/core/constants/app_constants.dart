/// Application-wide constants
class AppConstants {
  AppConstants._();

  static const String appName = 'Hikma';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Hadith Reminder for macOS';

  // Default popup dimensions
  static const double popupWidth = 480.0;
  static const double popupMinHeight = 200.0;
  static const double popupMaxHeight = 600.0;
  static const double popupBorderRadius = 16.0;

  // Default position (centered on typical screen)
  static const double defaultPopupX = 100.0;
  static const double defaultPopupY = 100.0;

  // Cache duration for API-fetched Hadiths
  static const Duration cacheExpiration = Duration(days: 7);

  // API base URL
  static const String apiBaseUrl = 'https://api.hadith.gading.dev';

  // Development mode
  static const bool isDevelopment = bool.fromEnvironment('DEV', defaultValue: true);
}
