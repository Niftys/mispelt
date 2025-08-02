import 'package:share_plus/share_plus.dart';
import '../models/game_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ShareService {
  /// Share game result with social media and other platforms
  /// Returns true if successful, false otherwise
  static Future<bool> shareGameResult(GameResult result) async {
    final shareText = _generateShareText(result);

    try {
      // On web, copy to clipboard instead of opening share dialog
      if (kIsWeb) {
        await Clipboard.setData(ClipboardData(text: shareText));
        print('Text copied to clipboard: $shareText');
        return true; // Successfully copied to clipboard
      } else {
        // On mobile, use the native share dialog
        await Share.share(
          shareText,
          subject: 'Check out my spelling game score!',
        );
        return true; // Share dialog opened successfully
      }
    } catch (e) {
      print('Error sharing game result: $e');
      return false; // Failed to share
    }
  }

  /// Generate share text based on game result
  static String _generateShareText(GameResult result) {
    final modeText = _getModeText(result.mode);
    final scoreText = _getScoreText(result);
    final timeText =
        result.timeTaken != null
            ? ' in ${_formatDuration(result.timeTaken!)}'
            : '';

    // Website URL for sharing
    const websiteUrl = 'https://mispelt.vercel.app/';

    return '''I just scored $scoreText on $modeText$timeText!

Play the daily spelling challenge: $websiteUrl''';
  }

  /// Get mode display text
  static String _getModeText(GameMode mode) {
    switch (mode) {
      case GameMode.daily:
        return 'Daily Challenge';
      case GameMode.timeAttack:
        return 'Time Attack';
      case GameMode.endless:
        return 'Endless Mode';
    }
  }

  /// Get score display text
  static String _getScoreText(GameResult result) {
    final accuracy = (result.accuracy * 100).toInt();

    switch (result.mode) {
      case GameMode.daily:
        // Option 1: Current format
        return '${result.score}/${result.totalWords} correct ($accuracy%)';

      case GameMode.timeAttack:
        // Option 1: Current format
        return '${result.score} words in ${_formatDuration(result.timeTaken!)}';

      case GameMode.endless:
        // Option 1: Current format
        return '${result.score} words with ${result.livesRemaining ?? 0} lives left';
    }
  }

  /// Format duration for display
  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
