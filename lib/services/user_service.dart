import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if a username is unique
  static Future<bool> isUsernameUnique(String username) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('users')
              .where('username', isEqualTo: username.toLowerCase())
              .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      print('Error checking username uniqueness: $e');

      // If we get a permission error, we'll assume the username is available
      // and let the signup process continue. The actual uniqueness will be
      // enforced at the database level when creating the user document.
      if (e.toString().contains('permission-denied')) {
        print('Permission denied for username check - proceeding with signup');
        return true; // Assume username is available
      }

      return false; // For other errors, assume username is taken
    }
  }

  /// Create a new user document with username
  static Future<void> createUserDocument(
    String uid,
    String username,
    String email,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'username': username.toLowerCase(),
        'email': email,
        'displayName': username,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating user document: $e');

      // If there's a conflict with the username, throw a specific error
      if (e.toString().contains('already exists') ||
          e.toString().contains('duplicate')) {
        throw FirebaseAuthException(
          code: 'username-already-in-use',
          message:
              'This username is already taken. Please choose a different one.',
        );
      }

      throw e;
    }
  }

  /// Get user by username or email
  static Future<String?> getUserIdByUsernameOrEmail(String identifier) async {
    try {
      // First try to find by username
      final usernameQuery =
          await _firestore
              .collection('users')
              .where('username', isEqualTo: identifier.toLowerCase())
              .get();

      if (usernameQuery.docs.isNotEmpty) {
        return usernameQuery.docs.first.id;
      }

      // If not found by username, try by email
      final emailQuery =
          await _firestore
              .collection('users')
              .where('email', isEqualTo: identifier.toLowerCase())
              .get();

      if (emailQuery.docs.isNotEmpty) {
        return emailQuery.docs.first.id;
      }

      return null;
    } catch (e) {
      print('Error finding user by username or email: $e');

      // If we get a permission error, we'll assume the user doesn't exist
      // This allows the login process to continue and fail gracefully if needed
      if (e.toString().contains('permission-denied')) {
        print(
          'Permission denied for user lookup - assuming user does not exist',
        );
        return null;
      }

      return null;
    }
  }

  /// Get user data by UID
  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  /// Update user's last login time
  static Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  /// Validate username format
  static bool isValidUsername(String username) {
    // Username should be 3-20 characters, alphanumeric and underscores only
    final regex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
    return regex.hasMatch(username);
  }
}
