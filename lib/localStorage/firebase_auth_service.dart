import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login with email and password
  Future<UserCredential> loginWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save to shared preferences
      await _saveUserDataLocally(
        uid: credential.user!.uid,
        name: name,
        email: email,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String mobile,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save additional user info to Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'email': email,
        'mobile': mobile,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update user profile
      await credential.user!.updateDisplayName(name);

      // Save to shared preferences
      await _saveUserDataLocally(
        uid: credential.user!.uid,
        name: name,
        email: email,
        mobile: mobile,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String name,
    String? mobile,
    String? profileImageUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Update Firestore
      final updateData = <String, dynamic>{'name': name};
      if (mobile != null) updateData['mobile'] = mobile;
      if (profileImageUrl != null)
        updateData['profileImageUrl'] = profileImageUrl;

      await _firestore.collection('users').doc(user.uid).update(updateData);

      // Update Auth displayName
      await user.updateDisplayName(name);

      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', name);
      if (mobile != null) await prefs.setString('mobile', mobile);
      if (profileImageUrl != null)
        await prefs.setString('profileImageUrl', profileImageUrl);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Clear shared preferences first
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Then sign out from Firebase
      await _auth.signOut();
    } catch (e) {
      // Log the error but don't throw
      print('Error during sign out: $e');
      // Still return successfully since we've cleared local data
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>> getUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists) {
        throw Exception('User data not found');
      }

      return doc.data() as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Save user data to shared preferences
  Future<void> _saveUserDataLocally({
    required String uid,
    required String name,
    required String email,
    String? mobile,
    String? profileImageUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    if (mobile != null) await prefs.setString('mobile', mobile);
    if (profileImageUrl != null)
      await prefs.setString('profileImageUrl', profileImageUrl);
  }

  // Handle Firebase Auth exceptions
  Exception _handleAuthException(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'No user found with this email.';
        break;
      case 'wrong-password':
        message = 'Wrong password provided.';
        break;
      case 'invalid-email':
        message = 'Invalid email format.';
        break;
      case 'weak-password':
        message = 'The password provided is too weak.';
        break;
      case 'email-already-in-use':
        message = 'An account already exists for that email.';
        break;
      case 'operation-not-allowed':
        message = 'Email/password accounts are not enabled.';
        break;
      case 'too-many-requests':
        message = 'Too many requests. Try again later.';
        break;
      default:
        message = e.message ?? 'An unknown error occurred.';
    }
    return Exception(message);
  }

  // Show auth error in a SnackBar
  static void showAuthError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
