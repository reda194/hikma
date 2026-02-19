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
import 'bloc/popup/popup_event.dart';
import 'data/repositories/hadith_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/favorites_repository.dart';
import 'data/services/audio_service.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/favorites_screen.dart';
import 'ui/screens/about_screen.dart';
import 'ui/screens/contemplation_screen.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/popup/popup_content.dart';

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

    // Initialize BLoCs
    _settingsBloc = SettingsBloc(settingsRepository: _settingsRepository);
    _favoritesBloc = FavoritesBloc(favoritesRepository: _favoritesRepository);
    _popupBloc = PopupBloc(
      settingsRepository: _settingsRepository,
      audioService: AudioService(),
    );
    _hadithBloc = HadithBloc(hadithRepository: _hadithRepository);
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
  Rect? _normalWindowBounds;
  static const Size _popupWindowSize = Size(760, 640);

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
    await windowManager.setTitleBarStyle(
      TitleBarStyle.hidden,
      windowButtonVisibility: true,
    );

    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _updateDockVisibility() async {
    // Always keep the app discoverable from Dock while running in background.
    await windowManager.setSkipTaskbar(false);
  }

  Future<void> _enterPopupMode(PopupVisible popupState) async {
    _normalWindowBounds ??= await windowManager.getBounds();

    await windowManager.setAlwaysOnTop(true);
    await windowManager.setResizable(false);
    await windowManager.setMinimumSize(_popupWindowSize);
    await windowManager.setMaximumSize(_popupWindowSize);
    await windowManager.setTitleBarStyle(
      TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );
    await windowManager.setSize(_popupWindowSize);
    await windowManager.setPosition(
      Offset(popupState.position.dx, popupState.position.dy),
    );
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> _exitPopupMode() async {
    await windowManager.setAlwaysOnTop(false);
    await windowManager.setResizable(true);
    await windowManager.setMinimumSize(const Size(600, 420));
    await windowManager.setMaximumSize(const Size(4096, 4096));
    await windowManager.setTitleBarStyle(
      TitleBarStyle.hidden,
      windowButtonVisibility: true,
    );
    if (_normalWindowBounds != null) {
      await windowManager.setBounds(_normalWindowBounds!);
    }
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

          // Keep Dock icon visible even when the window is hidden.
          _updateDockVisibility();
        }
      },
      child: BlocListener<SchedulerBloc, SchedulerState>(
        bloc: widget.schedulerBloc,
        listener: (context, state) {
          if (state is SchedulerRunning) {
            // Scheduler is running
          }
        },
        child: BlocConsumer<PopupBloc, PopupState>(
          bloc: widget.popupBloc,
          listener: (context, popupState) async {
            if (popupState is PopupVisible) {
              await _enterPopupMode(popupState);
              return;
            }
            if (popupState is PopupHidden) {
              await _exitPopupMode();
              await windowManager.hide();
            }
          },
          builder: (context, popupState) {
            if (popupState is PopupVisible) {
              return _buildPopupWindow(popupState);
            }
            return _buildHomeWindow();
          },
        ),
      ),
    );
  }

  Widget _buildHomeWindow() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              if (Theme.of(context).brightness == Brightness.dark)
                const Color(0xFF081018)
              else
                const Color(0xFFF5F9FC),
              if (Theme.of(context).brightness == Brightness.dark)
                const Color(0xFF0C1824)
              else
                const Color(0xFFEAF2F8),
              if (Theme.of(context).brightness == Brightness.dark)
                const Color(0xFF122435)
              else
                const Color(0xFFE3EDF6),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.nights_stay_rounded,
                    size: 36,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Hikma',
                  style: GoogleFonts.notoNaskhArabic(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Daily hadith reflections from your menu bar',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 24),
                _isInitialized
                    ? Container(
                        width: 520,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withValues(alpha: 0.34),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Running in background',
                              style: GoogleFonts.tajawal(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: CircularProgressIndicator(),
                      ),
                const SizedBox(height: 12),
                Text(
                  'Use the menu bar icon to open Favorites, Settings, and Contemplation Mode.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupWindow(PopupVisible popupState) {
    final hadithState = widget.hadithBloc.state;
    final hadith = hadithState is HadithLoaded ? hadithState.hadith : null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: GestureDetector(
            onPanStart: (_) async {
              await windowManager.startDragging();
            },
            onPanEnd: (_) async {
              final position = await windowManager.getPosition();
              widget.popupBloc.add(
                UpdatePosition(dx: position.dx, dy: position.dy),
              );
            },
            child: SizedBox(
              width: _popupWindowSize.width,
              child: hadith == null
                  ? const Center(child: CircularProgressIndicator())
                  : PopupContent(
                      hadith: hadith,
                      remainingSeconds: popupState.remainingSeconds,
                      isDismissible: popupState.isDismissible,
                      onClose: () => widget.popupBloc.add(
                        const DismissPopup(savePosition: true),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
