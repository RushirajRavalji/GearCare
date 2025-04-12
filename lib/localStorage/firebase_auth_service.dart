import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Failed to authenticate user');
      }

      // Update last login timestamp
      await _firestore.collection('users').doc(credential.user!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      // Get user data including profile image
      final userDoc =
          await _firestore.collection('users').doc(credential.user!.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data();

        // Save user data locally with all available fields
        await _saveUserDataLocally(
          uid: credential.user!.uid,
          email: email,
          name: userData?['name'],
          mobile: userData?['mobile'],
          profileImageUrl: userData?['profileImageUrl'],
        );
      } else {
        // If user document doesn't exist yet, just save basic info
        await _saveUserDataLocally(uid: credential.user!.uid, email: email);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

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

      if (credential.user == null) {
        throw Exception('Failed to create user');
      }

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'email': email,
        'mobile': mobile,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });

      await credential.user!.updateDisplayName(name);
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

  Future<void> updateUserProfile({
    required String name,
    String? mobile,
    String? profileImageUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final updateData = <String, dynamic>{
        'name': name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (mobile != null) updateData['mobile'] = mobile;
      if (profileImageUrl != null)
        updateData['profileImageUrl'] = profileImageUrl;

      await _firestore.collection('users').doc(user.uid).update(updateData);
      await user.updateDisplayName(name);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', name);
      if (mobile != null) await prefs.setString('mobile', mobile);
      if (profileImageUrl != null) {
        await prefs.setString('profileImageUrl', profileImageUrl);
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Phone verification methods
  Future<void> sendOTP(String phoneNumber) async {
    try {
      // This is a stub implementation
      // In a real implementation, you would use Firebase Phone Auth
      // Example of how you would implement this with Firebase:
      /*
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed (Android only)
        },
        verificationFailed: (FirebaseAuthException e) {
          throw _handleAuthException(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          // Save the verification ID somewhere to use with confirmOTP
          // You might want to use shared preferences or a state management solution
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Called when the auto-retrieval timeout is reached
        },
        timeout: const Duration(seconds: 60),
      );
      */

      // For this stub, we'll just simulate a successful OTP send
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      throw Exception('Failed to send verification code: $e');
    }
  }

  Future<void> resetPasswordWithPhone({
    required String phoneNumber,
    required String otp,
    required String newPassword,
  }) async {
    try {
      // This is a stub implementation
      // In a real implementation, you would verify the OTP and update the password
      // Example of how you might implement this:
      /*
      // First, create a credential with the verification ID and OTP
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, // You would store this when sending the OTP
        smsCode: otp,
      );
      
      // Sign in with the credential
      await _auth.signInWithCredential(credential);
      
      // Then update the password
      await _auth.currentUser?.updatePassword(newPassword);
      */

      // For this stub, we'll just simulate a successful password reset
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  Future<Map<String, dynamic>> getUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) throw Exception('User data not found');

      return doc.data() as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  Future<void> _saveUserDataLocally({
    required String uid,
    required String email,
    String? name,
    String? mobile,
    String? profileImageUrl,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', uid);
      await prefs.setString('email', email);
      if (name != null) await prefs.setString('name', name);
      if (mobile != null) await prefs.setString('mobile', mobile);
      if (profileImageUrl != null) {
        await prefs.setString('profileImageUrl', profileImageUrl);
      }
    } catch (e) {
      throw Exception('Failed to save user data locally: $e');
    }
  }

  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email.');
      case 'wrong-password':
        return Exception('Wrong password provided.');
      case 'invalid-email':
        return Exception('Invalid email format.');
      case 'weak-password':
        return Exception('The password provided is too weak.');
      case 'email-already-in-use':
        return Exception('An account already exists for that email.');
      case 'operation-not-allowed':
        return Exception('Email/password accounts are not enabled.');
      case 'too-many-requests':
        return Exception('Too many requests. Try again later.');
      case 'user-disabled':
        return Exception('This account has been disabled.');
      case 'network-request-failed':
        return Exception('Network error. Please check your connection.');
      default:
        return Exception(e.message ?? 'An unknown error occurred.');
    }
  }

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
