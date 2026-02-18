import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

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

  MenuBarManager({
    required HadithBloc hadithBloc,
    required PopupBloc popupBloc,
  })  : _hadithBloc = hadithBloc,
        _popupBloc = popupBloc;

  /// Initialize the menu bar icon
  Future<void> init() async {
    if (_isInitialized) return;

    // TODO: Re-implement with system_tray 2.0+ API
    // The system_tray package API has changed significantly
    // For now, the app will run without system tray functionality

    _isInitialized = true;
  }

  void _showHadith() {
    _hadithBloc.add(const FetchRandomHadith(collection: HadithCollection.all));
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

  Future<void> _quit() async {
    await windowManager.destroy();
    exit(0);
  }

  /// Update the menu (call when settings change)
  Future<void> update() async {
    // No-op for now
  }
}
