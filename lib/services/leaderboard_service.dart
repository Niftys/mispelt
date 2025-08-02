import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save a score to the leaderboard (only if it's better than existing)
  static Future<void> saveScore({
    required String gameMode,
    required int score,
    int? timeInSeconds,
    String? subMode,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) {
      print('saveScore: Not saving - user is null or anonymous');
      return;
    }

    print('=== SAVE SCORE DEBUG ===');
    print('Game Mode: $gameMode');
    print('Score: $score');
    print('Time: $timeInSeconds');
    print('Sub Mode: $subMode');
    print('User ID: ${user.uid}');
    print(
      'Username: ${user.displayName ?? user.email?.split('@').first ?? 'User'}',
    );

    // Check if this score is better than the existing one
    final shouldSave = await _isScoreBetter(
      gameMode: gameMode,
      newScore: score,
      newTimeInSeconds: timeInSeconds,
      subMode: subMode,
    );

    print('Should save score: $shouldSave');

    if (!shouldSave) {
      print(
        'Score not saved: new score ($score) is not better than existing best',
      );
      return;
    }

    final entry = LeaderboardEntry(
      userId: user.uid,
      username: user.displayName ?? user.email?.split('@').first ?? 'User',
      gameMode: gameMode,
      score: score,
      timeInSeconds: timeInSeconds,
      timestamp: DateTime.now(),
      subMode: subMode,
    );

    // For daily mode, include the date in the document ID to reset daily
    String documentId = user.uid;
    if (gameMode == 'daily') {
      final today = DateTime.now().toIso8601String().split('T')[0];
      documentId = '${user.uid}_$today';
      print('Daily mode - Document ID: $documentId');
    }

    final leaderboardKey = entry.leaderboardKey;
    print('Leaderboard key: $leaderboardKey');
    print('Document ID: $documentId');

    try {
      await _firestore
          .collection('leaderboards')
          .doc(leaderboardKey)
          .collection('entries')
          .doc(documentId)
          .set(entry.toMap());

      print(
        'Score saved successfully: new best score ($score) for $gameMode${subMode != null ? ' ($subMode)' : ''}',
      );
    } catch (e) {
      print('Error saving score: $e');
    }
  }

  // Check if the new score is better than the existing best score
  static Future<bool> _isScoreBetter({
    required String gameMode,
    required int newScore,
    int? newTimeInSeconds,
    String? subMode,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) {
      print('_isScoreBetter: Always save for anonymous users');
      return true; // Always save for anonymous users
    }

    print(
      '_isScoreBetter: Checking if score $newScore is better for $gameMode${subMode != null ? ' ($subMode)' : ''}',
    );

    // Get the current best score
    final currentBest = await getUserBestScore(
      gameMode: gameMode,
      subMode: subMode,
    );

    // If no existing score, this is automatically better
    if (currentBest == null) {
      print('_isScoreBetter: No existing score found - saving new score');
      return true;
    }

    print('_isScoreBetter: Current best score: ${currentBest.score}');

    // Compare based on game mode rules
    switch (gameMode) {
      case 'daily':
        // Daily: Higher score is better, if same score then faster time is better
        if (newScore > currentBest.score) {
          print('_isScoreBetter: Daily - new score higher, saving');
          return true;
        }
        if (newScore == currentBest.score) {
          // If scores are equal, faster time is better
          if (newTimeInSeconds != null && currentBest.timeInSeconds != null) {
            final isBetter = newTimeInSeconds < currentBest.timeInSeconds!;
            print(
              '_isScoreBetter: Daily - scores equal, time comparison: $isBetter',
            );
            return isBetter;
          }
          // If we have time for new score but not old, new is better
          if (newTimeInSeconds != null && currentBest.timeInSeconds == null) {
            print('_isScoreBetter: Daily - new has time, old doesn\'t, saving');
            return true;
          }
          // If we don't have time for new score but old has time, old is better
          if (newTimeInSeconds == null && currentBest.timeInSeconds != null) {
            print(
              '_isScoreBetter: Daily - old has time, new doesn\'t, not saving',
            );
            return false;
          }
          // If neither has time, they're equal (don't save)
          print('_isScoreBetter: Daily - neither has time, not saving');
          return false;
        }
        print('_isScoreBetter: Daily - new score lower, not saving');
        return false;

      case 'timeAttack':
        // Time Attack: Higher score is better
        final isBetter = newScore > currentBest.score;
        print(
          '_isScoreBetter: Time Attack - new score $newScore vs current ${currentBest.score}: $isBetter',
        );
        return isBetter;

      case 'endless':
        // Endless: Higher score is better
        final isBetter = newScore > currentBest.score;
        print(
          '_isScoreBetter: Endless - new score $newScore vs current ${currentBest.score}: $isBetter',
        );
        return isBetter;

      default:
        print('_isScoreBetter: Unknown mode $gameMode - saving');
        return true; // Default to saving if unknown mode
    }
  }

  // Get leaderboard for a specific game mode
  static Future<List<LeaderboardEntry>> getLeaderboard({
    required String gameMode,
    String? subMode,
    int limit = 50,
  }) async {
    String leaderboardKey = gameMode;
    if (gameMode == 'endless' && subMode != null) {
      leaderboardKey = '${gameMode}_$subMode';
    }

    Query query = _firestore
        .collection('leaderboards')
        .doc(leaderboardKey)
        .collection('entries');

    // For daily mode, use a simpler approach - get all entries and filter by date in code
    if (gameMode == 'daily') {
      print(
        'getLeaderboard: Daily mode - getting all entries and filtering by date',
      );

      try {
        final snapshot = await query.get();
        final allEntries =
            snapshot.docs
                .map(
                  (doc) => LeaderboardEntry.fromMap(
                    doc.data() as Map<String, dynamic>,
                  ),
                )
                .toList();

        // Filter for today's entries
        final today = DateTime.now().toIso8601String().split('T')[0];
        final todayStart = DateTime.parse('${today}T00:00:00.000Z');
        final todayEnd = DateTime.parse('${today}T23:59:59.999Z');

        final todayEntries =
            allEntries.where((entry) {
              return entry.timestamp.isAfter(todayStart) &&
                  entry.timestamp.isBefore(todayEnd);
            }).toList();

        // Sort by score (desc), then by time (asc)
        todayEntries.sort((a, b) {
          if (a.score != b.score) {
            return b.score.compareTo(a.score); // Higher score first
          }
          // If scores are equal, sort by time (faster time first)
          final aTime = a.timeInSeconds ?? 999999;
          final bTime = b.timeInSeconds ?? 999999;
          return aTime.compareTo(bTime);
        });

        print(
          'getLeaderboard: Daily mode - found ${todayEntries.length} entries for today',
        );
        return todayEntries.take(limit).toList();
      } catch (e) {
        print('getLeaderboard: Error getting daily leaderboard: $e');
        return [];
      }
    }

    // Apply different sorting based on game mode
    switch (gameMode) {
      case 'daily':
        // Sort by score (desc), then by time (asc)
        query = query
            .orderBy('score', descending: true)
            .orderBy('timeInSeconds', descending: false);
        break;
      case 'timeAttack':
        // Sort by score only (desc)
        query = query.orderBy('score', descending: true);
        break;
      case 'endless':
        // Sort by score only (desc)
        query = query.orderBy('score', descending: true);
        break;
    }

    query = query.limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map(
          (doc) => LeaderboardEntry.fromMap(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  // Get user's best score for a specific game mode
  static Future<LeaderboardEntry?> getUserBestScore({
    required String gameMode,
    String? subMode,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return null;

    String leaderboardKey = gameMode;
    if (gameMode == 'endless' && subMode != null) {
      leaderboardKey = '${gameMode}_$subMode';
    }

    print(
      'getUserBestScore: Looking for $gameMode${subMode != null ? ' ($subMode)' : ''}',
    );
    print('getUserBestScore: Leaderboard key: $leaderboardKey');
    print('getUserBestScore: User ID: ${user.uid}');

    Query query = _firestore
        .collection('leaderboards')
        .doc(leaderboardKey)
        .collection('entries')
        .where('userId', isEqualTo: user.uid);

    // For daily mode, use document ID approach instead of timestamp filtering
    if (gameMode == 'daily') {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final documentId = '${user.uid}_$today';
      print('getUserBestScore: Daily mode - checking document ID: $documentId');

      // Try to get the specific document for today
      try {
        final doc =
            await _firestore
                .collection('leaderboards')
                .doc(leaderboardKey)
                .collection('entries')
                .doc(documentId)
                .get();

        if (doc.exists) {
          final entry = LeaderboardEntry.fromMap(
            doc.data() as Map<String, dynamic>,
          );
          print('getUserBestScore: Found existing daily score: ${entry.score}');
          return entry;
        } else {
          print('getUserBestScore: No existing daily score found for today');
          return null;
        }
      } catch (e) {
        print('getUserBestScore: Error getting daily score: $e');
        return null;
      }
    }

    // Apply sorting based on game mode
    switch (gameMode) {
      case 'daily':
        query = query
            .orderBy('score', descending: true)
            .orderBy('timeInSeconds', descending: false);
        break;
      case 'timeAttack':
      case 'endless':
        query = query.orderBy('score', descending: true);
        break;
    }

    query = query.limit(1);

    try {
      final snapshot = await query.get();
      print(
        'getUserBestScore: Query returned ${snapshot.docs.length} documents',
      );

      if (snapshot.docs.isEmpty) {
        print('getUserBestScore: No existing score found');
        return null;
      }

      final entry = LeaderboardEntry.fromMap(
        snapshot.docs.first.data() as Map<String, dynamic>,
      );
      print('getUserBestScore: Found existing score: ${entry.score}');
      return entry;
    } catch (e) {
      print('getUserBestScore: Error querying leaderboard: $e');
      return null;
    }
  }

  // Get user's rank for a specific game mode
  static Future<int?> getUserRank({
    required String gameMode,
    String? subMode,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return null;

    String leaderboardKey = gameMode;
    if (gameMode == 'endless' && subMode != null) {
      leaderboardKey = '${gameMode}_$subMode';
    }

    Query query = _firestore
        .collection('leaderboards')
        .doc(leaderboardKey)
        .collection('entries');

    // For daily mode, use the same approach as getLeaderboard
    if (gameMode == 'daily') {
      print(
        'getUserRank: Daily mode - getting all entries and filtering by date',
      );

      try {
        final snapshot = await query.get();
        final allEntries =
            snapshot.docs
                .map(
                  (doc) => LeaderboardEntry.fromMap(
                    doc.data() as Map<String, dynamic>,
                  ),
                )
                .toList();

        // Filter for today's entries
        final today = DateTime.now().toIso8601String().split('T')[0];
        final todayStart = DateTime.parse('${today}T00:00:00.000Z');
        final todayEnd = DateTime.parse('${today}T23:59:59.999Z');

        final todayEntries =
            allEntries.where((entry) {
              return entry.timestamp.isAfter(todayStart) &&
                  entry.timestamp.isBefore(todayEnd);
            }).toList();

        // Sort by score (desc), then by time (asc)
        todayEntries.sort((a, b) {
          if (a.score != b.score) {
            return b.score.compareTo(a.score); // Higher score first
          }
          // If scores are equal, sort by time (faster time first)
          final aTime = a.timeInSeconds ?? 999999;
          final bTime = b.timeInSeconds ?? 999999;
          return aTime.compareTo(bTime);
        });

        // Find user's position
        for (int i = 0; i < todayEntries.length; i++) {
          if (todayEntries[i].userId == user.uid) {
            print('getUserRank: Daily mode - user rank: ${i + 1}');
            return i + 1; // Rank is 1-based
          }
        }

        print(
          'getUserRank: Daily mode - user not found in today\'s leaderboard',
        );
        return null;
      } catch (e) {
        print('getUserRank: Error getting daily rank: $e');
        return null;
      }
    }

    // Apply sorting based on game mode
    switch (gameMode) {
      case 'daily':
        query = query
            .orderBy('score', descending: true)
            .orderBy('timeInSeconds', descending: false);
        break;
      case 'timeAttack':
      case 'endless':
        query = query.orderBy('score', descending: true);
        break;
    }

    final snapshot = await query.get();
    final entries =
        snapshot.docs
            .map(
              (doc) =>
                  LeaderboardEntry.fromMap(doc.data() as Map<String, dynamic>),
            )
            .toList();

    // Find user's position
    for (int i = 0; i < entries.length; i++) {
      if (entries[i].userId == user.uid) {
        return i + 1; // Rank is 1-based
      }
    }

    return null;
  }

  // Get all leaderboards for the user
  static Future<Map<String, List<LeaderboardEntry>>>
  getAllLeaderboards() async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return {};

    final Map<String, List<LeaderboardEntry>> leaderboards = {};

    // Get daily leaderboard
    try {
      leaderboards['daily'] = await getLeaderboard(gameMode: 'daily');
    } catch (e) {
      leaderboards['daily'] = [];
    }

    // Get time attack leaderboard
    try {
      leaderboards['timeAttack'] = await getLeaderboard(gameMode: 'timeAttack');
    } catch (e) {
      leaderboards['timeAttack'] = [];
    }

    // Get endless leaderboards
    try {
      leaderboards['endless_1_life'] = await getLeaderboard(
        gameMode: 'endless',
        subMode: '1_life',
      );
    } catch (e) {
      leaderboards['endless_1_life'] = [];
    }

    try {
      leaderboards['endless_3_lives'] = await getLeaderboard(
        gameMode: 'endless',
        subMode: '3_lives',
      );
    } catch (e) {
      leaderboards['endless_3_lives'] = [];
    }

    return leaderboards;
  }

  // Check if user has already played daily today
  static Future<bool> hasPlayedDailyToday() async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return false;

    final today = DateTime.now().toIso8601String().split('T')[0];
    final documentId = '${user.uid}_$today';

    final doc =
        await _firestore
            .collection('leaderboards')
            .doc('daily')
            .collection('entries')
            .doc(documentId)
            .get();

    return doc.exists;
  }
}
