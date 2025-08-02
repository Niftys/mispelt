import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static FirebaseFirestore? _firestore;
  static bool _isInitialized = false;

  static FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }
    return _firestore!;
  }

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Firebase
      await Firebase.initializeApp();
      _firestore = FirebaseFirestore.instance;

      // Create collections if they don't exist
      await _ensureCollectionsExist();

      _isInitialized = true;
      print('Firebase initialized successfully');
    } catch (e) {
      print('Error initializing Firebase: $e');
      rethrow;
    }
  }

  static Future<void> _ensureCollectionsExist() async {
    try {
      // Create collections by writing a dummy document and then deleting it
      // This ensures the collection exists even if empty

      // Words collection
      await _firestore!.collection('words').doc('_init').set({
        'created': FieldValue.serverTimestamp(),
      });
      await _firestore!.collection('words').doc('_init').delete();

      // Leaderboards collection
      await _firestore!.collection('leaderboards').doc('_init').set({
        'created': FieldValue.serverTimestamp(),
      });
      await _firestore!.collection('leaderboards').doc('_init').delete();

      // User profiles collection
      await _firestore!.collection('userProfiles').doc('_init').set({
        'created': FieldValue.serverTimestamp(),
      });
      await _firestore!.collection('userProfiles').doc('_init').delete();

      // Daily games collection
      await _firestore!.collection('dailyGames').doc('_init').set({
        'created': FieldValue.serverTimestamp(),
      });
      await _firestore!.collection('dailyGames').doc('_init').delete();

      print('All Firestore collections created successfully');
    } catch (e) {
      print('Error creating collections: $e');
      // Don't rethrow - app can still work without collections
    }
  }

  static bool get isInitialized => _isInitialized;
}
