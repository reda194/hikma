/// Hive storage box and key constants
class StorageKeys {
  StorageKeys._();

  // Box names
  static const String settingsBox = 'settings';
  static const String favoritesBox = 'favorites';
  static const String cacheBox = 'cache';

  // Settings keys
  static const String reminderInterval = 'reminder_interval';
  static const String popupDuration = 'popup_duration';
  static const String sourceCollection = 'source_collection';
  static const String fontSize = 'font_size';
  static const String soundEnabled = 'sound_enabled';
  static const String autoStart = 'auto_start';
  static const String showInDock = 'show_in_dock';
  static const String darkModeEnabled = 'dark_mode_enabled';
  static const String popupPosition = 'popup_position';
  static const String popupPositionType = 'popup_position_type';
  static const String popupDisplayDuration = 'popup_display_duration';

  // Daily Hadith keys
  static const String dailyHadithId = 'daily_hadith_id';
  static const String dailyHadithDate = 'daily_hadith_date';

  // Hadith history key
  static const String hadithHistory = 'hadith_history';

  // Reading statistics key
  static const String readStatistics = 'read_statistics';

  // Onboarding key
  static const String onboardingCompleted = 'onboarding_completed';

  // Cache keys
  static const String cachePrefix = 'cached_';
  static const String cacheTimestamp = 'cached_at';
  static const String cacheExpiresAt = 'expires_at';
}
