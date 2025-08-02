import 'word.dart';

enum GameMode { daily, timeAttack, endless }

class GameResult {
  final GameMode mode;
  final int score;
  final int totalWords;
  final Duration? timeTaken;
  final List<WordAttempt> attempts;
  final DateTime timestamp;
  final int? livesRemaining;
  final int? lives; // Initial number of lives for endless mode

  GameResult({
    required this.mode,
    required this.score,
    required this.totalWords,
    this.timeTaken,
    required this.attempts,
    required this.timestamp,
    this.livesRemaining,
    this.lives,
  });

  factory GameResult.fromJson(Map<String, dynamic> json) {
    return GameResult(
      mode: GameMode.values.firstWhere(
        (e) => e.toString() == 'GameMode.${json['mode']}',
        orElse: () => GameMode.daily,
      ),
      score: json['score'] ?? 0,
      totalWords: json['totalWords'] ?? 0,
      timeTaken:
          json['timeTaken'] != null
              ? Duration(milliseconds: json['timeTaken'])
              : null,
      attempts:
          (json['attempts'] as List?)
              ?.map((e) => WordAttempt.fromJson(e))
              .toList() ??
          [],
      timestamp: DateTime.parse(json['timestamp']),
      livesRemaining: json['livesRemaining'],
      lives: json['lives'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode.toString().split('.').last,
      'score': score,
      'totalWords': totalWords,
      'timeTaken': timeTaken?.inMilliseconds,
      'attempts': attempts.map((e) => e.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
      'livesRemaining': livesRemaining,
      'lives': lives,
    };
  }

  double get accuracy => totalWords > 0 ? score / totalWords : 0.0;
}

class WordAttempt {
  final String wordShown;
  final String correctSpelling;
  final bool isCorrect;
  final bool userSaidCorrect;

  WordAttempt({
    required this.wordShown,
    required this.correctSpelling,
    required this.isCorrect,
    required this.userSaidCorrect,
  });

  factory WordAttempt.fromJson(Map<String, dynamic> json) {
    return WordAttempt(
      wordShown: json['wordShown'] ?? '',
      correctSpelling: json['correctSpelling'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
      userSaidCorrect: json['userSaidCorrect'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wordShown': wordShown,
      'correctSpelling': correctSpelling,
      'isCorrect': isCorrect,
      'userSaidCorrect': userSaidCorrect,
    };
  }
}
