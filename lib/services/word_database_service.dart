import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/word.dart';
import 'firebase_service.dart';
import 'dart:async'; // Added for Completer
import 'dart:math'; // Added for Random

class WordDatabaseService {
  static List<Word>? _cachedWords;
  static bool _isLoading = false;
  static final List<Completer<List<Word>>> _loadingCompleters = [];

  /// Load words from local JSON file with better caching
  static Future<List<Word>> loadWordsFromJson() async {
    if (_cachedWords != null) return _cachedWords!;

    // If already loading, wait for the existing load to complete
    if (_isLoading) {
      final completer = Completer<List<Word>>();
      _loadingCompleters.add(completer);
      return completer.future;
    }

    _isLoading = true;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/words_combined.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final List<dynamic> wordsList = jsonData['words'];
      _cachedWords =
          wordsList.map((wordData) => Word.fromJson(wordData)).toList();

      print('=== WORD LOADING DEBUG ===');
      print('Loaded ${_cachedWords!.length} words from JSON file');
      if (_cachedWords!.isNotEmpty) {
        print('Sample word 1: ${_cachedWords![0].correctSpelling}');
        print('Sample word 1 misspellings: ${_cachedWords![0].misspellings}');
        print('Sample word 1 definition: ${_cachedWords![0].definition}');
        print('Sample word 2: ${_cachedWords![1].correctSpelling}');
        print('Sample word 2 misspellings: ${_cachedWords![1].misspellings}');
      }
      print('==========================');

      // Resolve all waiting completers
      for (final completer in _loadingCompleters) {
        completer.complete(_cachedWords!);
      }
      _loadingCompleters.clear();

      return _cachedWords!;
    } catch (e) {
      print('Error loading words from JSON: $e');

      // Resolve all waiting completers with empty list
      for (final completer in _loadingCompleters) {
        completer.complete([]);
      }
      _loadingCompleters.clear();

      return [];
    } finally {
      _isLoading = false;
    }
  }

  /// Load words from individual level files (which have definitions)
  static Future<List<Word>> loadWordsWithDefinitions() async {
    try {
      List<Word> allWords = [];

      // Load from each level file
      final levelFiles = [
        'assets/data/words_level1.json',
        'assets/data/words_level2.json',
        'assets/data/words_level3.json',
        'assets/data/words_level4.json',
        'assets/data/words_level5.json',
      ];

      print('=== LOADING WORDS WITH DEFINITIONS ===');
      print('Attempting to load from ${levelFiles.length} level files...');

      for (final filePath in levelFiles) {
        try {
          print('Loading from: $filePath');
          final String jsonString = await rootBundle.loadString(filePath);
          final Map<String, dynamic> jsonData = json.decode(jsonString);
          final List<dynamic> wordsList = jsonData['words'];

          final List<Word> levelWords =
              wordsList.map((wordData) => Word.fromJson(wordData)).toList();

          allWords.addAll(levelWords);

          print(
            '✅ Successfully loaded ${levelWords.length} words from $filePath',
          );

          // Show sample words from this file
          if (levelWords.isNotEmpty) {
            print('   Sample word: ${levelWords[0].correctSpelling}');
            print(
              '   Sample definition: ${levelWords[0].definition ?? "NO DEFINITION"}',
            );
          }
        } catch (e) {
          print('❌ Error loading $filePath: $e');
          print('   Error details: ${e.toString()}');

          // Try to provide more specific error information
          if (e.toString().contains('Unable to load asset')) {
            print('   This appears to be a file not found error');
          } else if (e.toString().contains('Unexpected character')) {
            print('   This appears to be a JSON parsing error');
          }
        }
      }

      print('=== WORDS WITH DEFINITIONS DEBUG ===');
      print('Total words loaded: ${allWords.length}');
      if (allWords.isNotEmpty) {
        print('Sample word 1: ${allWords[0].correctSpelling}');
        print(
          'Sample word 1 definition: ${allWords[0].definition ?? "NO DEFINITION"}',
        );
        print('Sample word 2: ${allWords[1].correctSpelling}');
        print(
          'Sample word 2 definition: ${allWords[1].definition ?? "NO DEFINITION"}',
        );
      } else {
        print('⚠️  No words were loaded! This indicates a serious problem.');
      }
      print('====================================');

      return allWords;
    } catch (e) {
      print('❌ Critical error loading words with definitions: $e');
      return [];
    }
  }

  /// Sync words from JSON to Firestore
  static Future<void> syncWordsToFirestore() async {
    try {
      if (!FirebaseService.isInitialized) {
        print('Firebase not initialized. Cannot sync words.');
        return;
      }

      final List<Word> words = await loadWordsFromJson();
      final FirebaseFirestore firestore = FirebaseService.firestore;

      // Clear existing words collection
      final QuerySnapshot existingWords =
          await firestore.collection('words').get();
      final WriteBatch batch = firestore.batch();

      for (var doc in existingWords.docs) {
        batch.delete(doc.reference);
      }

      // Add new words from JSON
      for (Word word in words) {
        final docRef = firestore.collection('words').doc();
        batch.set(docRef, word.toJson());
      }

      await batch.commit();
      print('Successfully synced ${words.length} words to Firestore');
    } catch (e) {
      print('Error syncing words to Firestore: $e');
      rethrow;
    }
  }

  /// Get words from Firestore (fallback to JSON if Firebase not available)
  static Future<List<Word>> getWords() async {
    try {
      if (FirebaseService.isInitialized) {
        final QuerySnapshot snapshot =
            await FirebaseService.firestore.collection('words').get();

        if (snapshot.docs.isNotEmpty) {
          final List<Word> words =
              snapshot.docs
                  .map(
                    (doc) => Word.fromJson(doc.data() as Map<String, dynamic>),
                  )
                  .toList();
          print('Loaded ${words.length} words from Firestore');
          return words;
        }
      }
    } catch (e) {
      print('Error loading from Firestore, falling back to JSON: $e');
    }

    // Fallback to JSON file
    return await loadWordsFromJson();
  }

  /// Get words by difficulty range
  static Future<List<Word>> getWordsByDifficulty(
    int minDifficulty,
    int maxDifficulty,
  ) async {
    final List<Word> allWords = await getWords();
    return allWords
        .where(
          (word) =>
              word.difficulty >= minDifficulty &&
              word.difficulty <= maxDifficulty,
        )
        .toList();
  }

  /// Get random words for a specific count
  static Future<List<Word>> getRandomWords(int count) async {
    final List<Word> allWords = await getWords();

    // Create a copy to avoid modifying the original list
    final List<Word> shuffledWords = List.from(allWords);

    // Use a more robust shuffling method
    final random = Random();
    for (int i = shuffledWords.length - 1; i > 0; i--) {
      int j = random.nextInt(i + 1);
      Word temp = shuffledWords[i];
      shuffledWords[i] = shuffledWords[j];
      shuffledWords[j] = temp;
    }

    final selectedWords = shuffledWords.take(count).toList();

    print('=== RANDOM WORD SELECTION DEBUG ===');
    print('Requested count: $count');
    print('Total words available: ${allWords.length}');
    print('Selected words count: ${selectedWords.length}');
    if (selectedWords.isNotEmpty) {
      print('First selected word: ${selectedWords[0].correctSpelling}');
      print(
        'First selected word misspellings: ${selectedWords[0].misspellings}',
      );
      print('Last selected word: ${selectedWords.last.correctSpelling}');
      print(
        'Last selected word misspellings: ${selectedWords.last.misspellings}',
      );

      // Show more sample words to verify randomization
      if (selectedWords.length > 5) {
        print('Sample words from selection:');
        for (int i = 0; i < 5; i++) {
          print('  ${i + 1}. ${selectedWords[i].correctSpelling}');
        }
      }
    }
    print('===================================');

    return selectedWords;
  }

  /// Get daily words (seeded random for consistent daily experience)
  static Future<List<Word>> getDailyWords(DateTime date) async {
    final List<Word> allWords = await getWords();
    final int seed = date.year * 10000 + date.month * 100 + date.day;
    final random = _SeededRandom(seed);

    final List<Word> shuffledWords = List.from(allWords);
    for (int i = shuffledWords.length - 1; i > 0; i--) {
      int j = random.nextInt(i + 1);
      Word temp = shuffledWords[i];
      shuffledWords[i] = shuffledWords[j];
      shuffledWords[j] = temp;
    }

    return shuffledWords.take(10).toList();
  }

  /// Clear cache (useful when JSON file is updated)
  static void clearCache() {
    _cachedWords = null;
    _isLoading = false;
    _loadingCompleters.clear();
  }

  /// Preload words in the background for better performance
  static Future<void> preloadWords() async {
    if (_cachedWords != null) return; // Already loaded

    // Start loading in background
    loadWordsFromJson().catchError((e) {
      print('Background preload failed: $e');
    });
  }
}

/// Seeded random number generator for consistent daily words
class _SeededRandom {
  int _seed;

  _SeededRandom(this._seed);

  int nextInt(int max) {
    _seed = (_seed * 9301 + 49297) % 233280;
    return (_seed * max / 233280).floor();
  }
}
