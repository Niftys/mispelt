class LeaderboardEntry {
  final String userId;
  final String username;
  final String gameMode;
  final int score;
  final int? timeInSeconds; // For daily mode
  final DateTime timestamp;
  final String? subMode; // For endless: "1_life" or "3_lives"

  LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.gameMode,
    required this.score,
    this.timeInSeconds,
    required this.timestamp,
    this.subMode,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'gameMode': gameMode,
      'score': score,
      'timeInSeconds': timeInSeconds,
      'timestamp': timestamp.toIso8601String(),
      'subMode': subMode,
    };
  }

  // Create from Map from Firestore
  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      gameMode: map['gameMode'] ?? '',
      score: map['score'] ?? 0,
      timeInSeconds: map['timeInSeconds'],
      timestamp: DateTime.parse(map['timestamp']),
      subMode: map['subMode'],
    );
  }

  // Get leaderboard key for grouping entries
  String get leaderboardKey {
    if (gameMode == 'endless' && subMode != null) {
      return '${gameMode}_$subMode';
    }
    return gameMode;
  }

  // Get display name for the leaderboard
  String get displayName {
    switch (gameMode) {
      case 'daily':
        return 'Daily Challenge';
      case 'timeAttack':
        return 'Time Attack';
      case 'endless':
        if (subMode == '1_life') return 'Endless (1 Life)';
        if (subMode == '3_lives') return 'Endless (3 Lives)';
        return 'Endless';
      default:
        return gameMode;
    }
  }
}
