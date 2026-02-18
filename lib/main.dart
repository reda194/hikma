import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/storage_keys.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/menu_bar_manager.dart';
import 'bloc/hadith/hadith_bloc.dart';
import 'bloc/hadith/hadith_event.dart';
import 'bloc/hadith/hadith_state.dart';
import 'bloc/scheduler/scheduler_bloc.dart';
import 'bloc/scheduler/scheduler_event.dart';
import 'bloc/scheduler/scheduler_state.dart';
import 'bloc/settings/settings_bloc.dart';
import 'bloc/settings/settings_event.dart';
import 'bloc/settings/settings_state.dart';
import 'bloc/favorites/favorites_bloc.dart';
import 'bloc/favorites/favorites_event.dart';
import 'bloc/favorites/favorites_state.dart';
import 'bloc/popup/popup_bloc.dart';
import 'bloc/popup/popup_event.dart';
import 'bloc/popup/popup_state.dart';
import 'data/repositories/hadith_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/favorites_repository.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/favorites_screen.dart';
import 'ui/screens/about_screen.dart';
import 'ui/popup/hadith_popup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Open Hive boxes
  await Hive.openBox(StorageKeys.settingsBox);
  await Hive.openBox(StorageKeys.favoritesBox);
  await Hive.openBox(StorageKeys.cacheBox);

  // Initialize window manager
  await windowManager.ensureInitialized();

  runApp(const HikmaApp());
}

class HikmaApp extends StatefulWidget {
  const HikmaApp({super.key});

  @override
  State<HikmaApp> createState() => _HikmaAppState();
}

class _HikmaAppState extends State<HikmaApp> {
  late final SettingsRepository _settingsRepository;
  late final FavoritesRepository _favoritesRepository;
  late final HadithRepository _hadithRepository;

  late final SettingsBloc _settingsBloc;
  late final FavoritesBloc _favoritesBloc;
  late final PopupBloc _popupBloc;
  late final HadithBloc _hadithBloc;
  late final SchedulerBloc _schedulerBloc;

  late final MenuBarManager _menuBarManager;

  @override
  void initState() {
    super.initState();
    _initializeRepositories();
  }

  void _initializeRepositories() {
    _settingsRepository = SettingsRepository();
    _favoritesRepository = FavoritesRepository();
    _hadithRepository = HadithRepository();

    // Initialize BLoCs
    _settingsBloc = SettingsBloc(_settingsRepository);
    _favoritesBloc = FavoritesBloc(_favoritesRepository);
    _popupBloc = PopupBloc(_settingsRepository);
    _hadithBloc = HadithBloc(_hadithRepository, _favoritesBloc);
    _schedulerBloc = SchedulerBloc(_settingsBloc, _popupBloc, _hadithBloc);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create (_) => _settingsBloc),
        BlocProvider(create (_) => _favoritesBloc),
        BlocProvider(create (_) => _popupBloc),
        BlocProvider(create (_) => _hadithBloc),
        BlocProvider(create (_) => _schedulerBloc),
      ],
      child: MaterialApp(
        title: 'Hikma',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: HikmaHome(
          menuBarManager: _menuBarManager,
          settingsBloc: _settingsBloc,
          schedulerBloc: _schedulerBloc,
        ),
        routes: {
          '/settings': (context) => SettingsScreen(
                hadithBloc: _hadithBloc,
                favoritesBloc: _favoritesBloc,
              ),
          '/favorites': (context) => FavoritesScreen(
                favoritesBloc: _favoritesBloc,
              ),
          '/about': (context) => const AboutScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  @override
  void dispose() {
    _settingsBloc.close();
    _favoritesBloc.close();
    _popupBloc.close();
    _hadithBloc.close();
    _schedulerBloc.close();
    super.dispose();
  }
}

class HikmaHome extends StatefulWidget {
  final MenuBarManager menuBarManager;
  final SettingsBloc settingsBloc;
  final SchedulerBloc schedulerBloc;

  const HikmaHome({
    super.key,
    required this.menuBarManager,
    required this.settingsBloc,
    required this.schedulerBloc,
  });

  @override
  State<HikmaHome> createState() => _HikmaHomeState();
}

class _HikmaHomeState extends State<HikmaHome> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Initialize repositories
    await widget.settingsBloc.repository.init();
    await widget.schedulerBloc.hadithBloc.repository.init();
    await widget.schedulerBloc.favoritesBloc.repository.init();

    // Load initial settings
    widget.settingsBloc.add(LoadSettings());

    // Load favorites
    widget.schedulerBloc.favoritesBloc.add(LoadFavorites());

    // Initialize menu bar
    await widget.menuBarManager.init();

    // Hide from dock initially
    await windowManager.setPreventClose(true);

    // Listen to settings for dock visibility
    widget.settingsBloc.stream.listen((state) {
      if (state is SettingsLoaded) {
        _updateDockVisibility(state.settings.showInDock);
      }
    });

    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _updateDockVisibility(bool showInDock) async {
    await windowManager.setSkipTaskbar(!showInDock);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SchedulerState>(
      bloc: widget.schedulerBloc,
      listener: (context, state) {
        if (state is SchedulerRunning) {
          // Scheduler is running
        }
      },
      child: BlocListener<PopupState>(
        bloc: widget.schedulerBloc.popupBloc,
        listener: (context, state) {
          if (state is PopupVisible) {
            _showPopup(state.hadith);
          }
        },
        child: Acrylic(
          type: AcrylicType.frosted,
          child: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.nights_stay,
                    size: 64,
                    color: const Color(0xFF1B4F72),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Hikma',
                    style: GoogleFonts.notoNaskhArabic(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B4F72),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hadith Reminder for macOS',
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xFF7F8C8D),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (!_isInitialized)
                    const CircularProgressIndicator()
                  else
                    Column(
                      children: [
                        Text(
                          'Running in background',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Use the menu bar icon to access features',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF95A5A6),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPopup(dynamic hadith) {
    // Navigate to popup overlay
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return HadithPopupOverlay(hadith: hadith);
        },
        opaque: false,
      ),
    );
  }
}

class HadithPopupOverlay extends StatelessWidget {
  final dynamic hadith;

  const HadithPopupOverlay({super.key, required this.hadith});

  @override
  Widget build(BuildContext context) {
    return HadithPopup(hadith: hadith);
  }
}
