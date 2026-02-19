import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:system_tray/system_tray.dart';

import '../../bloc/hadith/hadith_bloc.dart';
import '../../bloc/hadith/hadith_event.dart';
import '../../bloc/hadith/hadith_state.dart';
import '../../bloc/popup/popup_bloc.dart';
import '../../bloc/popup/popup_event.dart';
import '../../data/models/hadith_collection.dart';

/// MenuBarManager handles the system tray icon and menu
class MenuBarManager {
  final HadithBloc _hadithBloc;
  final PopupBloc _popupBloc;

  // Global navigator key for navigation outside widget tree
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // System tray instance
  final SystemTray _systemTray = SystemTray();
  final Menu _menu = Menu();

  bool _isInitialized = false;
  HotKey? _hadithHotKey;

  // App window reference for showing/hiding
  WindowListener? _windowListener;

  // Stream subscription to listen for Hadith state changes
  // Used to wait for Hadith loading before showing popup
  StreamSubscription<HadithState>? _hadithStateSubscription;

  MenuBarManager({
    required HadithBloc hadithBloc,
    required PopupBloc popupBloc,
  })  : _hadithBloc = hadithBloc,
        _popupBloc = popupBloc {
    _initWindowListener();
  }

  void _initWindowListener() {
    _windowListener = _WindowListenerWrapper(
      onWindowCloseAction: () async {
        // Instead of closing, hide to system tray
        await windowManager.hide();
      },
    );
    windowManager.addListener(_windowListener!);
  }

  /// Initialize the menu bar icon
  Future<void> init() async {
    if (_isInitialized) return;

    // Register keyboard shortcut for showing Hadith (Cmd+Shift+H)
    await _registerKeyboardShortcut();

    // Initialize system tray with icon
    await _initSystemTray();

    _isInitialized = true;
  }

  /// Initialize the system tray with icon and menu
  Future<void> _initSystemTray() async {
    // Get the path to the system tray icon
    final String iconPath;

    if (Platform.isMacOS) {
      // For macOS, use the menu bar icon
      iconPath = 'assets/images/menu_bar_icon.png';
    } else if (Platform.isWindows) {
      iconPath = 'assets/images/menu_bar_icon.png';
    } else {
      iconPath = 'assets/images/menu_bar_icon.png';
    }

    // Initialize system tray
    await _systemTray.initSystemTray(
      title: 'Hikma',
      iconPath: iconPath,
    );

    // Build the context menu
    await _menu.buildFrom([
      MenuItemLabel(
        label: 'Show Hadith',
        onClicked: (menuItem) => _showHadith(),
      ),
      MenuItemLabel(
        label: 'Daily Hadith',
        onClicked: (menuItem) => _showDailyHadith(),
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
      MenuItemLabel(
        label: 'About',
        onClicked: (menuItem) => _showAbout(),
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Contemplation Mode',
        onClicked: (menuItem) => _showContemplationMode(),
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Quit Hikma',
        onClicked: (menuItem) => _quit(),
      ),
    ]);

    // Set the context menu
    await _systemTray.setContextMenu(_menu);

    // Register event handler for tray icon clicks
    _systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick) {
        // On macOS, show the main window on click
        if (Platform.isMacOS) {
          _showMainWindow();
        }
      } else if (eventName == kSystemTrayEventRightClick) {
        // On macOS, show context menu on right-click
        if (Platform.isMacOS) {
          _systemTray.popUpContextMenu();
        }
      }
    });
  }

  /// Show the main application window
  Future<void> _showMainWindow() async {
    await windowManager.show();
    await windowManager.focus();
  }

  /// Register the Cmd+Shift+H hotkey for showing a Hadith popup
  Future<void> _registerKeyboardShortcut() async {
    _hadithHotKey = HotKey(
      KeyCode.keyH,
      modifiers: [KeyModifier.meta, KeyModifier.shift],
      scope: HotKeyScope.system,
      identifier: 'show_hadith_hotkey',
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
    if (_windowListener != null) {
      windowManager.removeListener(_windowListener!);
    }
    // Cancel the state subscription to prevent memory leaks
    await _hadithStateSubscription?.cancel();
    _hadithStateSubscription = null;
  }

  void _showHadith() {
    // Cancel any existing subscription to avoid duplicate listeners
    _hadithStateSubscription?.cancel();

    // Listen for the Hadith to load before showing popup
    _hadithStateSubscription = _hadithBloc.stream.listen((state) {
      if (state is HadithLoaded) {
        // Hadith loaded successfully, show popup now
<<<<<<< HEAD
        _popupBloc.add(ShowPopup(hadith: state.hadith));
=======
        _popupBloc.add(const ShowPopup(hadithId: ''));
>>>>>>> 8a599ac9c3c1eca8c974aa056302c07a5b1e9ec6
        // Cancel subscription after showing popup
        _hadithStateSubscription?.cancel();
        _hadithStateSubscription = null;
      } else if (state is HadithError) {
        // Hadith failed to load, cancel subscription
        _hadithStateSubscription?.cancel();
        _hadithStateSubscription = null;
      }
    });

    // Fetch the Hadith after setting up the listener
    _hadithBloc.add(const FetchRandomHadith(collection: HadithCollection.all));
  }

  void _showDailyHadith() {
    // Cancel any existing subscription to avoid duplicate listeners
    _hadithStateSubscription?.cancel();

    // Listen for the Hadith to load before showing popup
    _hadithStateSubscription = _hadithBloc.stream.listen((state) {
      if (state is HadithLoaded) {
        // Hadith loaded successfully, show popup now
<<<<<<< HEAD
        _popupBloc.add(ShowPopup(hadith: state.hadith));
=======
        _popupBloc.add(const ShowPopup(hadithId: ''));
>>>>>>> 8a599ac9c3c1eca8c974aa056302c07a5b1e9ec6
        // Cancel subscription after showing popup
        _hadithStateSubscription?.cancel();
        _hadithStateSubscription = null;
      } else if (state is HadithError) {
        // Hadith failed to load, cancel subscription
        _hadithStateSubscription?.cancel();
        _hadithStateSubscription = null;
      }
    });

    // Load the daily Hadith after setting up the listener
    _hadithBloc.add(const LoadDailyHadith());
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
    // Rebuild menu if settings changed
    // For now, this is a no-op as menu items are static
  }
}

/// WindowListener wrapper for handling window close events
class _WindowListenerWrapper extends WindowListener {
  final VoidCallback onWindowCloseAction;

  _WindowListenerWrapper({required this.onWindowCloseAction});

  @override
  void onWindowClose() {
    onWindowCloseAction();
  }

  @override
  void onWindowFocus() {
    // Optional: Handle window focus
  }
}
