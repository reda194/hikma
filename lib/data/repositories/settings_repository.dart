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

    final positionData = _settingsBox.get(StorageKeys.popupPosition);

    return UserSettings(
      reminderInterval: ReminderInterval.fromIndex(intervalIndex as int),
      popupDuration: PopupDuration.fromIndex(durationIndex as int),
      sourceCollection: HadithCollection.fromIndex(collectionIndex as int),
      fontSize: FontSize.fromIndex(fontIndex as int),
      soundEnabled: sound as bool,
      autoStartEnabled: autoStart as bool,
      showInDock: showInDock as bool,
      popupPosition: positionData != null
          ? PopupPosition.fromJson(positionData as Map<String, dynamic>)
          : null,
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

    if (settings.popupPosition != null) {
      await _settingsBox.put(
        StorageKeys.popupPosition,
        settings.popupPosition!.toJson(),
      );
    } else {
      await _settingsBox.delete(StorageKeys.popupPosition);
    }
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
      return PopupPosition.fromJson(data as Map<String, dynamic>);
    }
    return null;
  }

  /// Clear all settings
  Future<void> clearSettings() async {
    await init();
    await _settingsBox.clear();
  }
}
