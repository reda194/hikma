import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hikma/main.dart';
import 'package:hikma/bloc/settings/settings_bloc.dart';
import 'package:hikma/bloc/settings/settings_state.dart';
import 'package:hikma/bloc/scheduler/scheduler_bloc.dart';
import 'package:hikma/bloc/scheduler/scheduler_state.dart';
import 'package:hikma/bloc/hadith/hadith_bloc.dart';
import 'package:hikma/bloc/hadith/hadith_state.dart';
import 'package:hikma/bloc/favorites/favorites_bloc.dart';
import 'package:hikma/bloc/popup/popup_bloc.dart';
import 'package:hikma/core/utils/menu_bar_manager.dart';

/// Widget tests for HikmaHome initialization
void main() {
  group('HikmaHome Initialization', () {
    late SettingsBloc settingsBloc;
    late SchedulerBloc schedulerBloc;
    late HadithBloc hadithBloc;
    late FavoritesBloc favoritesBloc;
    late PopupBloc popupBloc;
    late MenuBarManager menuBarManager;

    setUp(() {
      // Initialize BLoCs with mock repositories
      settingsBloc = SettingsBloc(settingsRepository: MockSettingsRepository());
      schedulerBloc = SchedulerBloc(
        settingsRepository: MockSettingsRepository(),
        hadithBloc: hadithBloc,
      );
      hadithBloc = HadithBloc(hadithRepository: MockHadithRepository());
      favoritesBloc = FavoritesBloc(favoritesRepository: MockFavoritesRepository());
      popupBloc = PopupBloc(settingsRepository: MockSettingsRepository());
      menuBarManager = MenuBarManager(
        hadithBloc: hadithBloc,
        popupBloc: popupBloc,
      );
    });

    tearDown(() {
      settingsBloc.close();
      schedulerBloc.close();
      hadithBloc.close();
      favoritesBloc.close();
      popupBloc.close();
    });

    testWidgets('HikmaHome initializes and displays loading state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<SettingsBloc>.value(value: settingsBloc),
            BlocProvider<SchedulerBloc>.value(value: schedulerBloc),
            BlocProvider<HadithBloc>.value(value: hadithBloc),
            BlocProvider<FavoritesBloc>.value(value: favoritesBloc),
            BlocProvider<PopupBloc>.value(value: popupBloc),
          ],
          child: const MaterialApp(
            home: HikmaHome(
              menuBarManager: menuBarManager,
              settingsBloc: settingsBloc,
              schedulerBloc: schedulerBloc,
              favoritesBloc: favoritesBloc,
              hadithBloc: hadithBloc,
              popupBloc: popupBloc,
            ),
          ),
        ),
      );

      // Verify loading indicator is shown initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('HikmaHome displays running state after initialization',
        (WidgetTester tester) async {
      // Emit SettingsLoaded state
      settingsBloc.emit(SettingsLoaded(settings: const UserSettings()));

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<SettingsBloc>.value(value: settingsBloc),
            BlocProvider<SchedulerBloc>.value(value: schedulerBloc),
            BlocProvider<HadithBloc>.value(value: hadithBloc),
            BlocProvider<FavoritesBloc>.value(value: favoritesBloc),
            BlocProvider<PopupBloc>.value(value: popupBloc),
          ],
          child: const MaterialApp(
            home: HikmaHome(
              menuBarManager: menuBarManager,
              settingsBloc: settingsBloc,
              schedulerBloc: schedulerBloc,
              favoritesBloc: favoritesBloc,
              hadithBloc: hadithBloc,
              popupBloc: popupBloc,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify "Running in background" text is shown
      expect(find.text('Running in background'), findsOneWidget);
      expect(find.text('Use the menu bar icon to access features'), findsOneWidget);
    });
  });
}

// Mock classes for testing
class MockSettingsRepository extends SettingsRepository {
  @override
  Future<void> init() async {}

  @override
  Future<UserSettings> loadSettings() async {
    return const UserSettings();
  }

  @override
  Future<void> saveSettings(UserSettings settings) async {}

  @override
  Future<void> updatePopupPosition(PopupPosition position) async {}

  @override
  Future<PopupPosition?> getPopupPosition() async {
    return null;
  }

  @override
  Future<void> clearSettings() async {}
}

class MockHadithRepository extends HadithRepository {
  @override
  Future<void> init() async {}

  @override
  Future<Hadith?> getRandomHadith([HadithCollection? collection]) async {
    return Hadith.empty();
  }

  @override
  Future<List<Hadith>> getHadithsByCollection(HadithCollection collection) async {
    return [];
  }

  @override
  Future<Hadith?> getHadithById(String id) async {
    return null;
  }

  @override
  Future<int> get localCount => 10;
}

class MockFavoritesRepository extends FavoritesRepository {
  @override
  Future<List<String>> loadFavoriteIds() async {
    return [];
  }

  @override
  Future<void> addFavorite(String hadithId) async {}

  @override
  Future<void> removeFavorite(String hadithId) async {}

  @override
  Future<bool> isFavorite(String hadithId) async {
    return false;
  }

  @override
  Future<void> clearFavorites() async {}
}
