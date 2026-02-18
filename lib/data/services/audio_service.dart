import 'package:audioplayers/audioplayers.dart';

/// AudioService handles notification sound playback
class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool _isInitialized = false;

  /// Initialize the audio service
  Future<void> init() async {
    if (_isInitialized) return;
    await _player.setReleaseMode(ReleaseMode.release);
    _isInitialized = true;
  }

  /// Play the notification sound
  Future<void> playNotificationSound() async {
    await init();
    try {
      await _player.play(AssetSource('sounds/notification.mp3'));
    } catch (_) {
      // Silent fail if sound file is missing
    }
  }

  /// Stop any currently playing sound
  Future<void> stop() async {
    await _player.stop();
  }

  /// Release resources
  Future<void> dispose() async {
    await _player.dispose();
    _isInitialized = false;
  }
}
