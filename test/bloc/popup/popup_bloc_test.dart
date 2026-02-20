import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikma/bloc/hadith/hadith_bloc.dart';
import 'package:hikma/bloc/hadith/hadith_event.dart';
import 'package:hikma/bloc/hadith/hadith_state.dart';
import 'package:hikma/bloc/popup/popup_bloc.dart';
import 'package:hikma/bloc/popup/popup_event.dart';
import 'package:hikma/bloc/popup/popup_state.dart';
import 'package:hikma/data/models/hadith_collection.dart';
import 'package:hikma/data/models/user_settings.dart';
import 'package:hikma/data/repositories/settings_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../mock/repositories.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockHadithBloc extends Mock implements HadithBloc {}

class FakeHadithEvent extends Fake implements HadithEvent {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(FakeHadithEvent());
  });

  const audioPlayersChannel = MethodChannel('xyz.luan/audioplayers');

  late MockSettingsRepository mockSettingsRepository;
  late MockHadithBloc mockHadithBloc;
  late PopupBloc popupBloc;
  late StreamController<HadithState> hadithStreamController;

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioPlayersChannel, (call) async {
      switch (call.method) {
        case 'create':
          return 'test-player-id';
        case 'setReleaseMode':
        case 'play':
        case 'stop':
        case 'dispose':
          return null;
        default:
          return null;
      }
    });

    mockSettingsRepository = MockSettingsRepository();
    mockHadithBloc = MockHadithBloc();
    hadithStreamController = StreamController<HadithState>.broadcast();

    when(() => mockHadithBloc.stream)
        .thenAnswer((_) => hadithStreamController.stream);
    when(() => mockHadithBloc.close()).thenAnswer((_) async {});
    when(() => mockHadithBloc.add(any())).thenReturn(null);

    when(() => mockSettingsRepository.loadSettings()).thenAnswer(
      (_) async => const UserSettings(
        popupPositionType: PopupPositionType.bottomRight,
        popupDisplayDuration: 8,
        soundEnabled: false,
      ),
    );

    popupBloc = PopupBloc(
      settingsRepository: mockSettingsRepository,
      hadithBloc: mockHadithBloc,
    );
  });

  tearDown(() async {
    await popupBloc.close();
    await hadithStreamController.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioPlayersChannel, null);
  });

  test('ShowPopup emits PopupVisible with hadith data', () async {
    final hadith = TestHelpers.createTestHadith(
      id: 'popup-test-1',
      arabicText: 'نص حديث للاختبار',
      collection: HadithCollection.bukhari,
    );

    expectLater(
      popupBloc.stream,
      emits(
        isA<PopupVisible>()
            .having((s) => s.hadith.id, 'hadith id', 'popup-test-1'),
      ),
    );

    popupBloc.add(ShowPopup(hadith: hadith));
  });

  test('On macOS, ShowPopup does not invoke native popup window channel',
      () async {
    if (!Platform.isMacOS) {
      return;
    }

    const popupWindowChannel = MethodChannel('com.hikma.app/popup_window');
    var showPopupCalls = 0;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(popupWindowChannel, (call) async {
      if (call.method == 'showPopup') {
        showPopupCalls++;
      }
      return null;
    });

    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(popupWindowChannel, null);
    });

    final hadith = TestHelpers.createTestHadith(id: 'popup-test-2');
    popupBloc.add(ShowPopup(hadith: hadith));
    await Future<void>.delayed(const Duration(milliseconds: 150));

    expect(showPopupCalls, 0);
    expect(popupBloc.state, isA<PopupVisible>());
  });
}
