import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/storage_keys.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/menu_bar_manager.dart';
import 'bloc/hadith/hadith_bloc.dart';
import 'bloc/hadith/hadith_state.dart';
import 'bloc/scheduler/scheduler_bloc.dart';
import 'bloc/scheduler/scheduler_event.dart';
import 'bloc/scheduler/scheduler_state.dart';
import 'bloc/settings/settings_bloc.dart';
import 'bloc/settings/settings_event.dart';
import 'bloc/settings/settings_state.dart';
import 'bloc/favorites/favorites_bloc.dart';
import 'bloc/favorites/favorites_event.dart';
import 'bloc/popup/popup_bloc.dart';
import 'bloc/popup/popup_state.dart';
import 'data/repositories/hadith_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/favorites_repository.dart';
import 'data/services/audio_service.dart';
import 'data/models/hadith.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/favorites_screen.dart';
import 'ui/screens/about_screen.dart';
import 'ui/screens/contemplation_screen.dart';
import 'ui/screens/onboarding_screen.dart';
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
    _menuBarManager = MenuBarManager(
      hadithBloc: _hadithBloc,
      popupBloc: _popupBloc,
    );
  }

  void _initializeRepositories() {
    _settingsRepository = SettingsRepository();
    _favoritesRepository = FavoritesRepository();
    _hadithRepository = HadithRepository();

    // Initialize BLoCs in correct order (HadithBloc first, as PopupBloc depends on it)
    _settingsBloc = SettingsBloc(settingsRepository: _settingsRepository);
    _favoritesBloc = FavoritesBloc(favoritesRepository: _favoritesRepository);
    _hadithBloc = HadithBloc(hadithRepository: _hadithRepository);
    _popupBloc = PopupBloc(
      settingsRepository: _settingsRepository,
      hadithBloc: _hadithBloc,
      audioService: AudioService(),
    );
    _schedulerBloc = SchedulerBloc(
      settingsRepository: _settingsRepository,
      hadithBloc: _hadithBloc,
      popupBloc: _popupBloc,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBloc>.value(
      value: _settingsBloc,
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          // Determine theme mode based on settings
          final themeMode = settingsState is SettingsLoaded &&
              settingsState.settings.darkModeEnabled
              ? ThemeMode.dark
              : ThemeMode.light;

          return MultiBlocProvider(
            providers: [
              BlocProvider<FavoritesBloc>.value(value: _favoritesBloc),
              BlocProvider<PopupBloc>.value(value: _popupBloc),
              BlocProvider<HadithBloc>.value(value: _hadithBloc),
              BlocProvider<SchedulerBloc>.value(value: _schedulerBloc),
            ],
            child: MaterialApp(
              title: 'Hikma',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              navigatorKey: MenuBarManager.navigatorKey,
              home: HikmaHome(
                menuBarManager: _menuBarManager,
                settingsBloc: _settingsBloc,
                schedulerBloc: _schedulerBloc,
                favoritesBloc: _favoritesBloc,
                hadithBloc: _hadithBloc,
                popupBloc: _popupBloc,
              ),
              routes: {
                '/settings': (context) => const SettingsScreen(),
                '/favorites': (context) => const FavoritesScreen(),
                '/about': (context) => const AboutScreen(),
                '/contemplation': (context) => const ContemplationScreen(),
              },
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _menuBarManager.dispose();
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
  final FavoritesBloc favoritesBloc;
  final HadithBloc hadithBloc;
  final PopupBloc popupBloc;

  const HikmaHome({
    super.key,
    required this.menuBarManager,
    required this.settingsBloc,
    required this.schedulerBloc,
    required this.favoritesBloc,
    required this.hadithBloc,
    required this.popupBloc,
  });

  @override
  State<HikmaHome> createState() => _HikmaHomeState();
}

class _HikmaHomeState extends State<HikmaHome> {
  bool _isInitialized = false;
  bool _repositoriesInitialized = false;
  bool _onboardingCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
    _initialize();
  }

  Future<void> _checkOnboardingStatus() async {
    final settingsBox = Hive.box(StorageKeys.settingsBox);
    final completed = settingsBox.get(
      StorageKeys.onboardingCompleted,
      defaultValue: false,
    ) as bool;
    if (mounted) {
      setState(() {
        _onboardingCompleted = completed;
      });
    }
  }

  void _completeOnboarding() {
    setState(() {
      _onboardingCompleted = true;
    });
  }

  Future<void> _initialize() async {
    // Initialize repositories first
    if (!_repositoriesInitialized) {
      try {
        // Access repositories through the BLoCs to call init()
        final hadithRepo = widget.hadithBloc.repository;
        final settingsRepo = widget.settingsBloc.repository;
        await hadithRepo.init();
        await settingsRepo.init();
        _repositoriesInitialized = true;
      } catch (e) {
        // Continue even if init fails - repositories may initialize lazily
        _repositoriesInitialized = true;
      }
    }

    // Load initial settings
    widget.settingsBloc.add(const LoadSettings());

    // Load favorites
    widget.favoritesBloc.add(const LoadFavorites());

    // Initialize menu bar
    await widget.menuBarManager.init();

    // Hide from dock initially
    await windowManager.setPreventClose(true);

    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _updateDockVisibility(bool showInDock) async {
    await windowManager.setSkipTaskbar(!showInDock);
  }

  @override
  Widget build(BuildContext context) {
    // Show onboarding screen if not completed
    if (!_onboardingCompleted) {
      return OnboardingScreen(
        onOnboardingComplete: _completeOnboarding,
      );
    }

    return BlocListener<SettingsBloc, SettingsState>(
      bloc: widget.settingsBloc,
      listener: (context, state) {
        if (state is SettingsLoaded) {
          // Start scheduler when settings are loaded
          widget.schedulerBloc.add(const StartScheduler());

          // Update dock visibility based on settings
          _updateDockVisibility(state.settings.showInDock);
        }
      },
      child: BlocListener<SchedulerBloc, SchedulerState>(
        bloc: widget.schedulerBloc,
        listener: (context, state) {
          if (state is SchedulerRunning) {
            // Scheduler is running
          }
        },
        child: BlocListener<PopupBloc, PopupState>(
          bloc: widget.popupBloc,
          listener: (context, state) {
            if (state is PopupVisible) {
              // Get hadith from HadithBloc state
              final hadithState = widget.hadithBloc.state;
              if (hadithState is HadithLoaded) {
                _showPopup(hadithState.hadith);
              }
            }
          },
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

  void _showPopup(Hadith hadith) {
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
