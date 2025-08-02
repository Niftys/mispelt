import 'dart:math';
import '../models/word.dart';
import 'word_database_service.dart';

class WordService {
  static final Random _random = Random();

  /// Get daily words based on current date - everyone gets the same words on the same day
  static Future<List<Word>> getDailyWords(DateTime date) async {
    // Create a deterministic seed based on the date
    final seed = _createDateSeed(date);
    final seededRandom = Random(seed);

    // Get all available words with definitions
    final allWords = await WordDatabaseService.loadWordsWithDefinitions();

    print('=== DAILY WORD SELECTION DEBUG ===');
    print('Total words available: ${allWords.length}');
    print('Date: ${date.year}-${date.month}-${date.day}');
    print('Seed: $seed');

    // Shuffle with the seeded random to get consistent daily selection
    final shuffledWords = List<Word>.from(allWords);
    _shuffleWithSeed(shuffledWords, seededRandom);

    // Take the first 10 words for daily challenge
    final dailyWords = shuffledWords.take(10).toList();

    print('Words selected for daily challenge: ${dailyWords.length}');

    // Debug: Print daily words with their definitions
    print('=== DAILY WORDS DEBUG ===');
    print('Date: ${date.year}-${date.month}-${date.day}');
    print('Seed: $seed');
    print('Selected ${dailyWords.length} daily words:');
    for (int i = 0; i < dailyWords.length; i++) {
      final word = dailyWords[i];
      print('  ${i + 1}. ${word.correctSpelling}');
      print('     Definition: ${word.definition ?? "NO DEFINITION"}');
      print('     Misspellings: ${word.misspellings}');
    }
    print('========================');

    return dailyWords;
  }

  /// Create a deterministic seed from a date
  static int _createDateSeed(DateTime date) {
    // Convert date to a unique integer seed
    return date.year * 10000 + date.month * 100 + date.day;
  }

  /// Shuffle a list using a seeded random generator
  static void _shuffleWithSeed(List<Word> list, Random random) {
    for (int i = list.length - 1; i > 0; i--) {
      int j = random.nextInt(i + 1);
      Word temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
  }

  /// Get today's date in local time for daily challenges
  static DateTime getToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static Future<List<Word>> getRandomWords(int count) async {
    return await WordDatabaseService.getRandomWords(count);
  }

  static Future<List<Word>> getWordsByDifficulty(
    int minDifficulty,
    int maxDifficulty,
  ) async {
    return await WordDatabaseService.getWordsByDifficulty(
      minDifficulty,
      maxDifficulty,
    );
  }

  /// Sync words from JSON to Firestore (for admin use)
  static Future<void> syncWordsToFirestore() async {
    await WordDatabaseService.syncWordsToFirestore();
  }

  /// Clear word cache (useful when JSON is updated)
  static void clearCache() {
    WordDatabaseService.clearCache();
  }

  /// Preload words in the background for better performance
  static Future<void> preloadWords() async {
    await WordDatabaseService.preloadWords();
  }
}
