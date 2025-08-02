import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/word.dart';
import '../models/game_result.dart';
import '../services/word_service.dart';
import '../services/leaderboard_service.dart';
import '../utils/constants.dart';

class GameProvider extends ChangeNotifier {
  GameMode _currentMode = GameMode.daily;
  List<Word> _currentWords = [];
  int _currentWordIndex = 0;
  int _score = 0;
  int _lives = 3;
  int _initialLives = 3; // Track initial lives for endless mode
  bool _isGameActive = false;
  bool _isGameFinished = false;
  DateTime? _gameStartTime;
  Duration _elapsedTime = Duration.zero;
  List<WordAttempt> _attempts = [];
  bool _hasPlayedDailyToday = false;
  int _dailyStreak = 0;
  int _lastDailyScore = 0; // Add daily score tracking
  int _previousStreak = 0; // Track previous streak for notifications
  DateTime? _lastCheckedDate; // Track when we last checked the date

  // Timer for time attack mode
  Timer? _timer;
  int _timeRemaining = GameConstants.timeAttackDuration;

  // Cache for displayed words to prevent flashing
  Map<int, String> _displayedWordsCache = {};

  // Preloading mechanism
  bool _isPreloading = false;
  int _preloadThreshold = 5; // Start preloading when we have 5 words left

  // Getters
  GameMode get currentMode => _currentMode;
  List<Word> get currentWords => _currentWords;
  int get currentWordIndex => _currentWordIndex;
  int get score => _score;
  int get lives => _lives;
  bool get isGameActive => _isGameActive;
  bool get isGameFinished => _isGameFinished;
  Duration get elapsedTime => _elapsedTime;
  List<WordAttempt> get attempts => _attempts;
  bool get hasPlayedDailyToday => _hasPlayedDailyToday;
  int get dailyStreak => _dailyStreak;
  int get timeRemaining => _timeRemaining;
  int get lastDailyScore => _lastDailyScore; // Add getter for daily score

  /// Get formatted daily score with accuracy
  String get formattedDailyScore {
    final accuracy =
        (_lastDailyScore / GameConstants.dailyWordCount * 100).toInt();
    return '$_lastDailyScore/${GameConstants.dailyWordCount} correct ($accuracy%)';
  }

  /// Check if streak was just increased
  bool get streakIncreased => _dailyStreak > _previousStreak;

  /// Check if streak was just broken
  bool get streakBroken => _previousStreak > 0 && _dailyStreak == 0;

  /// Get streak milestone message
  String? get streakMilestoneMessage {
    if (_dailyStreak == 7) return '🔥 7 Day Streak!';
    if (_dailyStreak == 14) return '🔥🔥 2 Week Streak!';
    if (_dailyStreak == 30) return '🔥🔥🔥 1 Month Streak!';
    if (_dailyStreak == 100) return '🔥🔥🔥🔥 100 Day Streak!';
    return null;
  }

  Word? get currentWord =>
      _currentWordIndex < _currentWords.length
          ? _currentWords[_currentWordIndex]
          : null;
  String? get currentWordDisplay => _getCurrentWordDisplay();
  String? get currentWordDefinition => currentWord?.definition;

  // Get next word for card stack effect
  Word? get nextWord =>
      _currentWordIndex + 1 < _currentWords.length
          ? _currentWords[_currentWordIndex + 1]
          : null;
  String? get nextWordDisplay => _getNextWordDisplay();
  String? get nextWordDefinition => nextWord?.definition;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> initialize() async {
    await _loadDailyStatus();
    await _loadDailyStreak();
    await _loadDailyScore(); // Add loading daily score
  }

  /// Check if daily status needs to be refreshed (called periodically)
  Future<void> checkDailyStatus() async {
    final today = _getToday();

    // If we haven't checked today yet, or if the date has changed
    if (_lastCheckedDate == null || !_isSameDay(_lastCheckedDate!, today)) {
      print('=== DAILY STATUS CHECK ===');
      print('Last checked: $_lastCheckedDate');
      print('Today: $today');
      print('Refreshing daily status...');

      await _loadDailyStatus();
      _lastCheckedDate = today;

      print('Daily status refreshed. Has played today: $_hasPlayedDailyToday');
      print('========================');

      // Notify listeners so the UI updates
      notifyListeners();
    }
  }

  /// Get today's date in local timezone (consistent across the app)
  DateTime _getToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get date string for storage (consistent format)
  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Force refresh daily status (useful for testing or manual refresh)
  Future<void> forceRefreshDailyStatus() async {
    print('=== FORCE REFRESHING DAILY STATUS ===');
    await _loadDailyStatus();
    _lastCheckedDate = _getToday();
    notifyListeners();
    print(
      'Daily status force refreshed. Has played today: $_hasPlayedDailyToday',
    );
    print('====================================');
  }

  /// Reset daily status for testing purposes
  Future<void> resetDailyStatus() async {
    print('=== RESETTING DAILY STATUS ===');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lastDailyDate');
    await prefs.remove('lastDailyScore');
    await prefs.remove('dailyStreak');

    _hasPlayedDailyToday = false;
    _lastDailyScore = 0;
    _dailyStreak = 0;
    _lastCheckedDate = null;

    notifyListeners();
    print('Daily status reset complete');
    print('==========================');
  }

  /// Reset daily status and allow retry (for testing purposes)
  Future<void> resetDailyStatusAndAllowRetry() async {
    print('=== RESETTING DAILY STATUS AND ALLOWING RETRY ===');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lastDailyDate');
    await prefs.remove('lastDailyScore');
    // Note: We don't reset the streak here as this is just for retry testing

    _hasPlayedDailyToday = false;
    _lastDailyScore = 0;
    _lastCheckedDate = null;

    notifyListeners();
    print('Daily status reset - retry allowed');
    print('==================================');
  }

  Future<void> startGame(GameMode mode, {int? endlessLives}) async {
    _resetGame();
    _currentMode = mode;

    // Set lives based on game mode
    switch (mode) {
      case GameMode.daily:
        _lives = 10; // Daily mode allows completing all 10 words
        _initialLives = 10;
        break;
      case GameMode.timeAttack:
        _lives = 999; // Time attack has unlimited attempts - no lives lost
        _initialLives = 999;
        break;
      case GameMode.endless:
        if (endlessLives != null) {
          _lives = endlessLives;
          _initialLives = endlessLives;
        } else {
          _lives = 3; // Default to 3 lives if not specified
          _initialLives = 3;
        }
        break;
    }

    // Check if words are already preloaded for this mode
    if (_currentWords.isEmpty) {
      // Load words based on game mode
      switch (mode) {
        case GameMode.daily:
          _currentWords = await WordService.getDailyWords(
            WordService.getToday(),
          );
          break;
        case GameMode.timeAttack:
          _currentWords = await WordService.getRandomWords(
            100,
          ); // More words for full 60 seconds
          break;
        case GameMode.endless:
          _currentWords = await WordService.getRandomWords(
            100,
          ); // Many words for endless
          break;
      }
    } else {
      print('=== REUSING PRELOADED WORDS ===');
      print('Using ${_currentWords.length} preloaded words');
    }

    // Debug: Print loaded words info
    print('=== GAME START DEBUG ===');
    print('Game Mode: $mode');
    print('Loaded ${_currentWords.length} words');
    if (_currentWords.isNotEmpty) {
      print('First word: ${_currentWords[0].correctSpelling}');
      print('First word misspellings: ${_currentWords[0].misspellings}');
      print('First word definition: ${_currentWords[0].definition}');
    }
    print('========================');

    _isGameActive = true;
    _gameStartTime = DateTime.now();

    // For daily mode, immediately mark as played to prevent backing out
    if (mode == GameMode.daily) {
      await _markDailyAsStarted();
    }

    // Start timer for time attack mode
    if (mode == GameMode.timeAttack) {
      _startTimer();
    }

    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        _timeRemaining--;
        notifyListeners();
      } else {
        _finishGame();
      }
    });
  }

  void submitAnswer(bool isCorrect) {
    if (!_isGameActive || currentWord == null) return;

    // Record the attempt
    _attempts.add(
      WordAttempt(
        wordShown: currentWordDisplay ?? '',
        correctSpelling: currentWord!.correctSpelling,
        isCorrect: isCorrect,
        userSaidCorrect: isCorrect,
      ),
    );

    if (isCorrect) {
      _score++;
      print('✅ Correct! Score: $_score');
    } else {
      // For daily and time attack modes, don't decrement lives - just track incorrect answers
      if (_currentMode == GameMode.endless) {
        _lives--;
        print('❌ Incorrect! Lives: $_lives');
      } else {
        print(
          '❌ Incorrect! (${_currentMode == GameMode.daily ? 'Daily' : 'Time Attack'} mode - no lives lost)',
        );
      }
    }

    // Move to next word
    _currentWordIndex++;

    // Check if game should end
    if (_currentWordIndex >= _currentWords.length) {
      _finishGame();
    } else if (_currentMode == GameMode.endless && _lives <= 0) {
      // Only end on lives for endless mode
      _finishGame();
    } else {
      notifyListeners();
    }
  }

  void _finishGame() {
    _isGameActive = false;
    _isGameFinished = true;
    _timer?.cancel();

    if (_gameStartTime != null) {
      _elapsedTime = DateTime.now().difference(_gameStartTime!);
    }

    if (_currentMode == GameMode.daily) {
      _saveDailyResult();
    }

    // Save score to leaderboard for account holders
    _saveScoreToLeaderboard();

    notifyListeners();
  }

  void _saveScoreToLeaderboard() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      print('Not saving score: user is null or anonymous');
      return;
    }

    try {
      print('=== SAVING SCORE TO LEADERBOARD ===');
      print('Game Mode: $_currentMode');
      print('Score: $_score');
      print('Lives: $_lives');
      print('User: ${user.uid}');

      switch (_currentMode) {
        case GameMode.daily:
          print('Saving daily score...');
          await LeaderboardService.saveScore(
            gameMode: 'daily',
            score: _score,
            timeInSeconds: _elapsedTime.inSeconds,
          );
          break;
        case GameMode.timeAttack:
          print('Saving time attack score...');
          await LeaderboardService.saveScore(
            gameMode: 'timeAttack',
            score: _score,
          );
          break;
        case GameMode.endless:
          // Save to the correct leaderboard based on initial lives
          String subMode = _initialLives == 1 ? '1_life' : '3_lives';
          print(
            'Saving endless score with subMode: $subMode (initial lives: $_initialLives, current lives: $_lives)',
          );
          await LeaderboardService.saveScore(
            gameMode: 'endless',
            score: _score,
            subMode: subMode,
          );
          break;
      }
      print('Score saved successfully!');
    } catch (e) {
      print('Failed to save score to leaderboard: $e');
    }
  }

  String? _getCurrentWordDisplay() {
    if (currentWord == null) return null;

    // Check if we already have a cached display for this word index
    if (_displayedWordsCache.containsKey(_currentWordIndex)) {
      return _displayedWordsCache[_currentWordIndex];
    }

    final word = currentWord!;
    final displayedWord = _generateDisplayWord(word, _currentWordIndex);

    // Debug: Print what's being displayed
    print('Generated display word: $displayedWord');
    print('==========================');

    // Preload next word display
    _preloadNextWordDisplay();

    return displayedWord;
  }

  String? _getNextWordDisplay() {
    if (nextWord == null) return null;

    // Check if we already have a cached display for the next word index
    if (_displayedWordsCache.containsKey(_currentWordIndex + 1)) {
      return _displayedWordsCache[_currentWordIndex + 1];
    }

    final word = nextWord!;

    // Generate and cache the display word
    return _generateDisplayWord(word, _currentWordIndex + 1);
  }

  /// Preload the first word for a specific game mode
  Future<void> preloadFirstWord(GameMode mode) async {
    print('=== PRELOAD FIRST WORD DEBUG ===');
    print('Preloading first word for mode: $mode');

    // Load words based on game mode
    switch (mode) {
      case GameMode.daily:
        _currentWords = await WordService.getDailyWords(WordService.getToday());
        break;
      case GameMode.timeAttack:
        _currentWords = await WordService.getRandomWords(50);
        break;
      case GameMode.endless:
        _currentWords = await WordService.getRandomWords(100);
        break;
    }

    if (_currentWords.isNotEmpty) {
      // Generate and cache the first word display
      final firstWord = _currentWords[0];
      final displayedWord = _generateDisplayWord(firstWord, 0);

      print('First word loaded: ${firstWord.correctSpelling}');
      print('First word display: $displayedWord');
      print('===============================');
    }
  }

  Future<void> _loadDailyStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPlayedDateString = prefs.getString('lastDailyDate');
    final today = _getDateString(_getToday());

    print('=== LOADING DAILY STATUS ===');
    print('Last played date string: $lastPlayedDateString');
    print('Today string: $today');

    _hasPlayedDailyToday = lastPlayedDateString == today;

    print('Has played daily today: $_hasPlayedDailyToday');
    print('==========================');
  }

  Future<void> _loadDailyStreak() async {
    final prefs = await SharedPreferences.getInstance();
    _dailyStreak = prefs.getInt('dailyStreak') ?? 0;
    print('=== LOADED DAILY STREAK ===');
    print('Loaded streak: $_dailyStreak');
    print('==========================');
  }

  Future<void> _loadDailyScore() async {
    final prefs = await SharedPreferences.getInstance();
    _lastDailyScore = prefs.getInt('lastDailyScore') ?? 0;
  }

  /// Mark daily game as started (prevents backing out and retrying)
  Future<void> _markDailyAsStarted() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getDateString(_getToday());

    print('=== MARKING DAILY AS STARTED ===');
    print('Today: $today');

    // Mark as played today immediately
    await prefs.setString('lastDailyDate', today);
    _hasPlayedDailyToday = true;

    print('Daily game marked as started - user cannot back out');
    print('==============================================');
  }

  Future<void> _saveDailyResult() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getDateString(_getToday());
    final yesterday = _getDateString(
      _getToday().subtract(const Duration(days: 1)),
    );

    print('=== SAVING DAILY RESULT ===');
    print('Today: $today');
    print('Yesterday: $yesterday');
    print('Current score: $_score');
    print('Current streak: $_dailyStreak');

    // Store previous streak before updating
    _previousStreak = _dailyStreak;

    // Get the last played date from storage (before we update it)
    final lastPlayedDateString = prefs.getString('lastDailyDate');

    // Update streak logic - since we now mark as started when game begins,
    // we need to check if this is the first time completing today's game
    if (lastPlayedDateString == yesterday) {
      // Consecutive day - increase streak
      _dailyStreak++;
      print('🔥 Streak increased to $_dailyStreak days!');
    } else if (lastPlayedDateString == today) {
      // Already started today's game - check if this is the first completion
      // For now, we'll keep the streak logic simple and just maintain it
      print('Completing today\'s game - streak maintained: $_dailyStreak');
    } else if (lastPlayedDateString != null) {
      // Missed one or more days - reset streak to 0
      if (_previousStreak > 0) {
        print('💔 Streak broken! Previous: $_previousStreak, New: 0');
      }
      _dailyStreak = 0;
    } else {
      // First time playing - start streak at 0
      print('First time playing - starting streak at 0');
      _dailyStreak = 0;
    }

    // Save the score (date was already saved when game started)
    await prefs.setInt('lastDailyScore', _score);
    _lastDailyScore = _score; // Update the in-memory variable
    await prefs.setInt('dailyStreak', _dailyStreak);
    // _hasPlayedDailyToday is already true from when game started

    print('Final streak: $_dailyStreak');
    print('Has played today: $_hasPlayedDailyToday');
    print('========================');

    // Check for milestone
    if (streakMilestoneMessage != null) {
      print('🎉 ${streakMilestoneMessage}');
    }
  }

  void resetGame() {
    _resetGame();
    notifyListeners();
  }

  /// Handle user backing out of the game - save current progress
  Future<void> handleBackOut() async {
    if (!_isGameActive || _currentMode != GameMode.daily) return;

    print('=== HANDLING BACK OUT ===');
    print('Current score: $_score');
    print('Current word index: $_currentWordIndex');
    print('Total words: ${_currentWords.length}');

    // For daily mode, treat any uncompleted words as incorrect
    // This prevents users from backing out to avoid a bad score
    if (_currentMode == GameMode.daily &&
        _currentWordIndex < _currentWords.length) {
      // Add attempts for any uncompleted words as incorrect
      for (int i = _currentWordIndex; i < _currentWords.length; i++) {
        final word = _currentWords[i];
        _attempts.add(
          WordAttempt(
            wordShown: _generateDisplayWord(word, i),
            correctSpelling: word.correctSpelling,
            isCorrect:
                false, // Treat as incorrect since they didn't complete it
            userSaidCorrect: false,
          ),
        );
      }

      print(
        'Added ${_currentWords.length - _currentWordIndex} uncompleted words as incorrect',
      );

      // Recalculate the score based on all attempts (including the uncompleted words)
      _score = _attempts.where((attempt) => attempt.isCorrect).length;
      print('Recalculated final score: $_score');
    }

    // Save the result as if the game finished
    if (_currentMode == GameMode.daily) {
      await _saveDailyResult();
    }

    // Save to leaderboard
    _saveScoreToLeaderboard();

    print('Back out handled - score saved');
    print('============================');
  }

  GameResult getGameResult() {
    return GameResult(
      mode: _currentMode,
      score: _score,
      totalWords: _attempts.length,
      timeTaken: _elapsedTime,
      attempts: _attempts,
      timestamp: DateTime.now(),
      livesRemaining: _currentMode == GameMode.endless ? _lives : null,
      lives: _currentMode == GameMode.endless ? _initialLives : null,
    );
  }

  void _resetGame() {
    _currentWords = [];
    _currentWordIndex = 0;
    _score = 0;
    _lives = 3;
    _initialLives = 3;
    _isGameActive = false;
    _isGameFinished = false;
    _gameStartTime = null;
    _elapsedTime = Duration.zero;
    _attempts = [];
    _timeRemaining = GameConstants.timeAttackDuration;
    _displayedWordsCache.clear();
    _timer?.cancel();
  }

  String _generateDisplayWord(Word word, int wordIndex) {
    // Check if we already have a cached display for this word
    if (_displayedWordsCache.containsKey(wordIndex)) {
      return _displayedWordsCache[wordIndex]!;
    }

    // Generate a misspelling or keep the correct spelling
    final shouldMisspell = _random.nextBool();
    String displayWord;

    if (shouldMisspell && word.misspellings.isNotEmpty) {
      // Pick a random misspelling
      final misspellingIndex = _random.nextInt(word.misspellings.length);
      displayWord = word.misspellings[misspellingIndex];
    } else {
      // Show the correct spelling
      displayWord = word.correctSpelling;
    }

    // Cache the result
    _displayedWordsCache[wordIndex] = displayWord;

    return displayWord;
  }

  void _preloadNextWordDisplay() {
    if (_currentWordIndex + 1 < _currentWords.length) {
      final nextWord = _currentWords[_currentWordIndex + 1];
      _generateDisplayWord(nextWord, _currentWordIndex + 1);
    }
  }

  // Random generator for consistent word display
  static final Random _random = Random();
}
