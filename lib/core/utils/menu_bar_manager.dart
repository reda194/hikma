import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../../bloc/hadith/hadith_bloc.dart';
import '../../bloc/hadith/hadith_event.dart';
import '../../bloc/popup/popup_bloc.dart';
import '../../bloc/popup/popup_event.dart';
import '../../data/models/hadith_collection.dart';

/// MenuBarManager handles the system tray icon and menu
/// NOTE: System tray integration disabled for now due to API compatibility issues
/// Will need to be re-implemented with correct system_tray 2.0+ API
class MenuBarManager {
  final HadithBloc _hadithBloc;
  final PopupBloc _popupBloc;

  // Global navigator key for navigation outside widget tree
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  bool _isInitialized = false;
  HotKey? _hadithHotKey;

  MenuBarManager({
    required HadithBloc hadithBloc,
    required PopupBloc popupBloc,
  })  : _hadithBloc = hadithBloc,
        _popupBloc = popupBloc;

  /// Initialize the menu bar icon
  Future<void> init() async {
    if (_isInitialized) return;

    // Register keyboard shortcut for showing Hadith (Cmd+Shift+H)
    await _registerKeyboardShortcut();

    // TODO: Re-implement with system_tray 2.0+ API
    // The system_tray package API has changed significantly
    // For now, the app will run without system tray functionality

    _isInitialized = true;
  }

  /// Register the Cmd+Shift+H hotkey for showing a Hadith popup
  Future<void> _registerKeyboardShortcut() async {
    _hadithHotKey = HotKey(
      key: PhysicalKeyboardKey.keyH,
      modifiers: [HotKeyModifier.command, HotKeyModifier.shift],
      scope: HotKeyScope.system,
    );

    await hotKeyManager.register(
      _hadithHotKey!,
      keyDownHandler: (hotKey) {
        _showHadith();
      },
    );
  }

  /// Dispose resources
  Future<void> dispose() async {
    if (_hadithHotKey != null) {
      await hotKeyManager.unregister(_hadithHotKey!);
      _hadithHotKey = null;
    }
  }

  void _showHadith() {
    _hadithBloc.add(const FetchRandomHadith(collection: HadithCollection.all));
    // Small delay to let Hadith load, then show popup
    Future.delayed(const Duration(milliseconds: 300), () {
      _popupBloc.add(const ShowPopup(hadithId: ''));
    });
  }

  void _showDailyHadith() {
    _hadithBloc.add(const LoadDailyHadith());
    // Small delay to let Hadith load, then show popup
    Future.delayed(const Duration(milliseconds: 300), () {
      _popupBloc.add(const ShowPopup(hadithId: ''));
    });
  }

  void _showFavorites() {
    navigatorKey.currentState?.pushNamed('/favorites');
  }

  void _showSettings() {
    navigatorKey.currentState?.pushNamed('/settings');
  }

  void _showAbout() {
    navigatorKey.currentState?.pushNamed('/about');
  }

  void _showContemplationMode() {
    navigatorKey.currentState?.pushNamed('/contemplation');
  }

  Future<void> _quit() async {
    await windowManager.destroy();
    exit(0);
  }

  /// Update the menu (call when settings change)
  Future<void> update() async {
    // No-op for now
  }
}
