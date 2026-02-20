import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/storage_keys.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/menu_bar_manager.dart';
import 'bloc/hadith/hadith_bloc.dart';
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
import 'data/models/user_settings.dart';
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
  Rect? _normalWindowBounds;
  static const Size _homeMinWindowSize = Size(760, 520);
  Size _popupWindowSize = const Size(760, 500);

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
    await windowManager.setMinimumSize(_homeMinWindowSize);
    await windowManager.setMaximumSize(const Size(4096, 4096));
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
    _popupWindowSize = _resolvePopupWindowSize(popupState);

    await windowManager.setAlwaysOnTop(true);
    await windowManager.setResizable(false);
    await windowManager.setMinimumSize(_popupWindowSize);
    await windowManager.setMaximumSize(_popupWindowSize);
    await windowManager.setTitleBarStyle(
      TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );
    await windowManager.setSize(_popupWindowSize);
    final popupPosition = popupState.position;
    if (popupPosition != null) {
      await windowManager.setPosition(
        Offset(popupPosition.dx, popupPosition.dy),
      );
    }
    await windowManager.show();
    await windowManager.focus();
  }

  Size _resolvePopupWindowSize(PopupVisible popupState) {
    final settingsState = widget.settingsBloc.state;
    final mode = settingsState is SettingsLoaded
        ? settingsState.settings.popupLayoutMode
        : PopupLayoutMode.compact;

    final textLength = popupState.hadith.arabicText.trim().length;
    final estimatedLines = (textLength / 42).ceil().clamp(3, 16);
    final baseHeight = mode == PopupLayoutMode.compact ? 300.0 : 350.0;
    final perLine = mode == PopupLayoutMode.compact ? 14.0 : 17.0;
    final minHeight = mode == PopupLayoutMode.compact ? 380.0 : 440.0;
    final maxHeight = mode == PopupLayoutMode.compact ? 540.0 : 620.0;
    final dynamicHeight = (baseHeight + (estimatedLines * perLine) + 120)
        .clamp(minHeight, maxHeight);
    return Size(760, dynamicHeight);
  }

  Future<void> _exitPopupMode() async {
    await windowManager.setAlwaysOnTop(false);
    await windowManager.setResizable(true);
    await windowManager.setMinimumSize(_homeMinWindowSize);
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
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              if (isDark) const Color(0xFF07101A) else const Color(0xFFF7FCFF),
              if (isDark) const Color(0xFF0B1724) else const Color(0xFFEDF6FD),
              if (isDark) const Color(0xFF0F2233) else const Color(0xFFE3F0FA),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -140,
              right: -120,
              child: _AmbientOrb(
                size: 320,
                color: scheme.primary.withValues(alpha: isDark ? 0.22 : 0.18),
              ),
            ),
            Positioned(
              bottom: -170,
              left: -110,
              child: _AmbientOrb(
                size: 300,
                color: scheme.secondary.withValues(alpha: isDark ? 0.2 : 0.16),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth =
                    (constraints.maxWidth - 56).clamp(320.0, 760.0).toDouble();
                final statusWidth =
                    (cardWidth - 40).clamp(240.0, 560.0).toDouble();

                return SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 28,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            (constraints.maxHeight - 56).clamp(0.0, 3000.0),
                      ),
                      child: Center(
                        child: SizedBox(
                          width: cardWidth,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(36),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  scheme.surface
                                      .withValues(alpha: isDark ? 0.32 : 0.84),
                                  scheme.surface
                                      .withValues(alpha: isDark ? 0.18 : 0.58),
                                ],
                              ),
                              border: Border.all(
                                color: scheme.onSurface
                                    .withValues(alpha: isDark ? 0.2 : 0.12),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(alpha: isDark ? 0.24 : 0.08),
                                  blurRadius: 40,
                                  offset: const Offset(0, 24),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 102,
                                  width: 102,
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: scheme.primary.withValues(
                                        alpha: isDark ? 0.26 : 0.15),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: scheme.primary
                                          .withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Image.asset(
                                    'assets/images/brand_logo.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Hikma',
                                    maxLines: 1,
                                    style: GoogleFonts.cormorantGaramond(
                                      fontSize: 56,
                                      fontWeight: FontWeight.w700,
                                      color: scheme.onSurface,
                                      height: 0.95,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Liquid wisdom panel for timeless daily hadith reflection',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.tajawal(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.2,
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.72),
                                  ),
                                ),
                                const SizedBox(height: 26),
                                _isInitialized
                                    ? Container(
                                        width: statusWidth,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: scheme.secondary
                                              .withValues(alpha: 0.14),
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          border: Border.all(
                                            color: scheme.secondary
                                                .withValues(alpha: 0.38),
                                          ),
                                        ),
                                        child: Wrap(
                                          alignment: WrapAlignment.center,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          spacing: 8,
                                          children: [
                                            Icon(
                                              Icons.check_circle_rounded,
                                              size: 20,
                                              color: scheme.secondary,
                                            ),
                                            Text(
                                              'Running in background via menu bar and dock',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.tajawal(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: scheme.secondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : const Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 8),
                                        child: CircularProgressIndicator(),
                                      ),
                                const SizedBox(height: 14),
                                Text(
                                  'Close the window anytime. Hikma stays alive in the background and is always reachable from the menu bar and Dock.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.tajawal(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.68),
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupWindow(PopupVisible popupState) {
    final hadith = popupState.hadith;
    final remainingSeconds = (popupState.remainingMillis / 1000).ceil();

    return Scaffold(
      backgroundColor: const Color(0xFF0E3551),
      body: GestureDetector(
        onPanStart: (_) async {
          await windowManager.startDragging();
        },
        onPanEnd: (_) async {
          final position = await windowManager.getPosition();
          widget.popupBloc.add(
            UpdatePosition(dx: position.dx, dy: position.dy),
          );
        },
        child: SizedBox.expand(
          child: PopupContent(
            hadith: hadith,
            remainingSeconds: remainingSeconds,
            isDismissible: popupState.isDismissible,
            onClose: () => widget.popupBloc.add(
              const DismissPopup(savePosition: true),
            ),
          ),
        ),
      ),
    );
  }
}

class _AmbientOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _AmbientOrb({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0.02),
            ],
          ),
        ),
      ),
    );
  }
}
