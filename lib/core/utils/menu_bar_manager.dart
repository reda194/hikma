import 'dart:io';
import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

import '../../bloc/hadith/hadith_bloc.dart';
import '../../bloc/hadith/hadith_event.dart';
import '../../bloc/popup/popup_bloc.dart';
import '../../bloc/popup/popup_event.dart';

/// MenuBarManager handles the system tray icon and menu
class MenuBarManager {
  final SystemTray _systemTray = SystemTray();
  final Menu _menu = Menu();
  final HadithBloc _hadithBloc;
  final PopupBloc _popupBloc;
  final BuildContext _context;

  bool _isInitialized = false;

  MenuBarManager({
    required HadithBloc hadithBloc,
    required PopupBloc popupBloc,
    required BuildContext context,
  })  : _hadithBloc = hadithBloc,
        _popupBloc = popupBloc,
        _context = context;

  /// Initialize the menu bar icon
  Future<void> init() async {
    if (_isInitialized) return;

    await _systemTray.init(
      iconPath: 'assets/images/menu_bar_icon.png',
      toolTip: 'Hikma - Hadith Reminder',
    );

    await _buildMenu();
    await _registerEventHandler();

    _isInitialized = true;
  }

  Future<void> _buildMenu() async {
    await _menu.build([
      MenuItemLabel(
        label: 'Show Hadith',
        onClicked: (menuItem) => _showHadith(),
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Favorites',
        onClicked: (menuItem) => _showFavorites(),
      ),
      MenuItemLabel(
        label: 'Settings',
        onClicked: (menuItem) => _showSettings(),
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'About Hikma',
        onClicked: (menuItem) => _showAbout(),
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Quit',
        onClicked: (menuItem) => _quit(),
      ),
    ]);

    await _systemTray.setMenu(_menu);
  }

  Future<void> _registerEventHandler() async {
    _systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick) {
        _showHadith();
      }
    });
  }

  void _showHadith() {
    _hadithBloc.add(const FetchRandomHadith());
    // Small delay to let Hadith load, then show popup
    Future.delayed(const Duration(milliseconds: 300), () {
      _popupBloc.add(const ShowPopup());
    });
  }

  void _showFavorites() {
    Navigator.of(_context).pushNamed('/favorites');
  }

  void _showSettings() {
    Navigator.of(_context).pushNamed('/settings');
  }

  void _showAbout() {
    Navigator.of(_context).pushNamed('/about');
  }

  Future<void> _quit() async {
    await windowManager.destroy();
    exit(0);
  }

  /// Update the menu (call when settings change)
  Future<void> update() async {
    await _systemTray.setMenu(_menu);
  }
}
