import 'package:hive/hive.dart';
import '../models/hadith_collection.dart';
import '../models/user_settings.dart';
import '../../core/constants/storage_keys.dart';

/// SettingsRepository handles persistence of user settings via Hive
class SettingsRepository {
  final HiveInterface _hive;

  SettingsRepository({HiveInterface? hive}) : _hive = hive ?? Hive;

  late Box _settingsBox;

  /// Initialize the settings repository
  Future<void> init() async {
    if (!_hive.isBoxOpen(StorageKeys.settingsBox)) {
      await _hive.openBox(StorageKeys.settingsBox);
    }
    _settingsBox = _hive.box(StorageKeys.settingsBox);
  }

  /// Load settings from storage or return defaults
  Future<UserSettings> loadSettings() async {
    await init();

    final intervalIndex =
        _settingsBox.get(StorageKeys.reminderInterval, defaultValue: 1);
    final durationIndex =
        _settingsBox.get(StorageKeys.popupDuration, defaultValue: 2);
    final collectionIndex =
        _settingsBox.get(StorageKeys.sourceCollection, defaultValue: 6);
    final fontIndex = _settingsBox.get(StorageKeys.fontSize, defaultValue: 2);
    final sound =
        _settingsBox.get(StorageKeys.soundEnabled, defaultValue: false);
    final autoStart =
        _settingsBox.get(StorageKeys.autoStart, defaultValue: true);
    final showInDock =
        _settingsBox.get(StorageKeys.showInDock, defaultValue: false);
    final darkMode =
        _settingsBox.get(StorageKeys.darkModeEnabled, defaultValue: false);

    final positionData = _settingsBox.get(StorageKeys.popupPosition);
    final positionTypeIndex =
        _settingsBox.get(StorageKeys.popupPositionType, defaultValue: 3);
    final displayDuration =
        _settingsBox.get(StorageKeys.popupDisplayDuration, defaultValue: 8);
    final layoutModeIndex =
        _settingsBox.get(StorageKeys.popupLayoutMode, defaultValue: 0);

    return UserSettings(
      reminderInterval: ReminderInterval.fromIndex(intervalIndex as int),
      popupDuration: PopupDuration.fromIndex(durationIndex as int),
      sourceCollection: HadithCollection.fromIndex(collectionIndex as int),
      fontSize: FontSize.fromIndex(fontIndex as int),
      soundEnabled: sound as bool,
      autoStartEnabled: autoStart as bool,
      showInDock: showInDock as bool,
      darkModeEnabled: darkMode as bool,
      popupPosition: positionData != null
          ? PopupPosition.fromJson(
              Map<String, dynamic>.from(positionData as Map),
            )
          : null,
      popupPositionType: PopupPositionType.fromIndex(positionTypeIndex as int),
      popupDisplayDuration: displayDuration as int,
      popupLayoutMode: PopupLayoutMode.fromIndex(layoutModeIndex as int),
    );
  }

  /// Save settings to storage
  Future<void> saveSettings(UserSettings settings) async {
    await init();

    await _settingsBox.put(
      StorageKeys.reminderInterval,
      settings.reminderInterval.index,
    );
    await _settingsBox.put(
      StorageKeys.popupDuration,
      settings.popupDuration.index,
    );
    await _settingsBox.put(
      StorageKeys.sourceCollection,
      settings.sourceCollection.index,
    );
    await _settingsBox.put(
      StorageKeys.fontSize,
      settings.fontSize.index,
    );
    await _settingsBox.put(
      StorageKeys.soundEnabled,
      settings.soundEnabled,
    );
    await _settingsBox.put(
      StorageKeys.autoStart,
      settings.autoStartEnabled,
    );
    await _settingsBox.put(
      StorageKeys.showInDock,
      settings.showInDock,
    );
    await _settingsBox.put(
      StorageKeys.darkModeEnabled,
      settings.darkModeEnabled,
    );

    if (settings.popupPosition != null) {
      await _settingsBox.put(
        StorageKeys.popupPosition,
        settings.popupPosition!.toJson(),
      );
    } else {
      await _settingsBox.delete(StorageKeys.popupPosition);
    }

    await _settingsBox.put(
      StorageKeys.popupPositionType,
      settings.popupPositionType.index,
    );

    await _settingsBox.put(
      StorageKeys.popupDisplayDuration,
      settings.popupDisplayDuration,
    );

    await _settingsBox.put(
      StorageKeys.popupLayoutMode,
      settings.popupLayoutMode.index,
    );
  }

  /// Update popup position
  Future<void> updatePopupPosition(PopupPosition position) async {
    await init();
    await _settingsBox.put(
      StorageKeys.popupPosition,
      position.toJson(),
    );
  }

  /// Get popup position
  Future<PopupPosition?> getPopupPosition() async {
    await init();
    final data = _settingsBox.get(StorageKeys.popupPosition);
    if (data != null) {
      return PopupPosition.fromJson(
        Map<String, dynamic>.from(data as Map),
      );
    }
    return null;
  }

  /// Clear all settings
  Future<void> clearSettings() async {
    await init();
    await _settingsBox.clear();
  }

  /// Get popup position type
  Future<PopupPositionType> getPopupPositionType() async {
    await init();
    final index = _settingsBox.get(
      StorageKeys.popupPositionType,
      defaultValue: 3, // bottomRight default
    );
    return PopupPositionType.fromIndex(index as int);
  }

  /// Set popup position type
  Future<void> setPopupPositionType(PopupPositionType positionType) async {
    await init();
    await _settingsBox.put(
      StorageKeys.popupPositionType,
      positionType.index,
    );
  }

  /// Get popup display duration in seconds
  Future<int> getPopupDisplayDuration() async {
    await init();
    return _settingsBox.get(
      StorageKeys.popupDisplayDuration,
      defaultValue: 8,
    ) as int;
  }

  /// Set popup display duration in seconds
  Future<void> setPopupDisplayDuration(int seconds) async {
    await init();
    // Clamp to valid range 4-30 seconds
    final clamped = seconds.clamp(4, 30);
    await _settingsBox.put(
      StorageKeys.popupDisplayDuration,
      clamped,
    );
  }
}
