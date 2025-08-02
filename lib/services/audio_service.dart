import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isEnabled = true;

  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  static bool get isEnabled => _isEnabled;

  static Future<void> playCorrect() async {
    if (!_isEnabled) return;

    try {
      // Stop any currently playing sound to prevent conflicts
      await _audioPlayer.stop();
      // Small delay to ensure the stop command is processed
      await Future.delayed(const Duration(milliseconds: 10));
      // Play the correct sound
      await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
    } catch (e) {
      // If sound file doesn't exist, we'll just continue silently
      print('Could not play correct sound: $e');
    }
  }

  static Future<void> playIncorrect() async {
    if (!_isEnabled) return;

    try {
      // Stop any currently playing sound to prevent conflicts
      await _audioPlayer.stop();
      // Small delay to ensure the stop command is processed
      await Future.delayed(const Duration(milliseconds: 10));
      // Play the incorrect sound
      await _audioPlayer.play(AssetSource('sounds/incorrect.mp3'));
    } catch (e) {
      // If sound file doesn't exist, we'll just continue silently
      print('Could not play incorrect sound: $e');
    }
  }

  static void dispose() {
    _audioPlayer.dispose();
  }
}
