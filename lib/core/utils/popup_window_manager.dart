import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../data/models/hadith.dart';
import '../../data/models/user_settings.dart';

/// Manager for native popup window via platform channel
class PopupWindowManager {
  static const _channel = MethodChannel('com.hikma.app/popup_window');
  static const _eventsChannel = MethodChannel('com.hikma.app/popup_events');
  static const _actionsChannel = MethodChannel('com.hikma.app/popup_actions');

  // Callback handlers
  static Function(bool)? _onHoverChanged;
  static Function(String)? _onAction;
  static bool _initialized = false;

  /// Initialize the platform channels and setup callbacks
  static Future<void> initialize() async {
    if (_initialized) return;

    // Setup event callbacks from Swift
    _eventsChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onHoverChanged':
          final hovered = call.arguments as bool? ?? false;
          _onHoverChanged?.call(hovered);
          return _onHoverChangedInternal(hovered);

        default:
          throw UnimplementedError('Unknown method: ${call.method}');
      }
    });

    // Setup action callbacks from Swift
    _actionsChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onAction':
          final action = call.arguments as String? ?? '';
          _onAction?.call(action);
          return _onActionInternal(action);

        default:
          throw UnimplementedError('Unknown method: ${call.method}');
      }
    });

    _initialized = true;
  }

  /// Set hover state change callback
  static void setOnHoverChanged(Function(bool) callback) {
    _onHoverChanged = callback;
  }

  /// Set action button callback
  static void setOnAction(Function(String) callback) {
    _onAction = callback;
  }

  /// Show the native popup window with Hadith content
  static Future<void> showPopup({
    required Hadith hadith,
    required PopupPositionType positionType,
    required Duration duration,
  }) async {
    await initialize();

    try {
      await _channel.invokeMethod('showPopup', {
        'hadith': hadith.toJson(),
        'positionType': positionType.index,
        'duration': duration.inMilliseconds,
      });
    } catch (e) {
      debugPrint('Error showing popup: $e');
      rethrow;
    }
  }

  /// Hide the native popup window
  static Future<void> hidePopup() async {
    try {
      await _channel.invokeMethod('hidePopup');
    } catch (e) {
      debugPrint('Error hiding popup: $e');
    }
  }

  /// Update the current Hadith content in the popup
  static Future<void> updateHadith(Hadith hadith) async {
    try {
      await _channel.invokeMethod('updateHadith', {
        'hadith': hadith.toJson(),
      });
    } catch (e) {
      debugPrint('Error updating hadith: $e');
    }
  }

  /// Get current popup position
  static Future<PopupPosition?> getPopupPosition() async {
    try {
      final result = await _channel.invokeMethod('getPopupPosition');
      if (result != null && result is Map<String, dynamic>) {
        return PopupPosition.fromJson(result);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting popup position: $e');
      return null;
    }
  }

  // Internal handlers for callbacks from Swift
  static void _onHoverChangedInternal(bool hovered) {
    debugPrint('Hover changed: $hovered');
  }

  static void _onActionInternal(String action) {
    debugPrint('Action triggered: $action');
  }

  /// Cleanup resources
  static void dispose() {
    _eventsChannel.setMethodCallHandler(null);
    _actionsChannel.setMethodCallHandler(null);
    _onHoverChanged = null;
    _onAction = null;
    _initialized = false;
  }
}
