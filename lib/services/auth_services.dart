// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if user is already logged in
  Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid') != null;
  }

  // Sign Up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
  }) async {
    try {
      // Create user with email and password first
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user model
      UserModel userModel = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
      );

      try {
        // Store additional user data in Firestore
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toMap());
      } catch (firestoreError) {
        // If Firestore operation fails, delete the created auth user
        await userCredential.user?.delete();
        throw _handleFirestoreError(firestoreError);
      }

      // Store UID in SharedPreferences for persistent login
      await _saveUserSession(userCredential.user!.uid);

      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign In with email/phone and password
  Future<UserCredential> signIn(String emailOrPhone, String password) async {
    try {
      // Check if input is email or phone
      bool isEmail = emailOrPhone.contains('@');

      if (isEmail) {
        // Sign in with email directly
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: emailOrPhone,
          password: password,
        );
        await _saveUserSession(userCredential.user!.uid);
        return userCredential;
      } else {
        try {
          // Clean phone number format (remove any spaces or special characters)
          String cleanPhoneNumber =
              emailOrPhone.replaceAll(RegExp(r'[^\d]'), '');

          // Query Firestore for user with matching phone number
          QuerySnapshot userQuery = await _firestore
              .collection('users')
              .where('phoneNumber', isEqualTo: cleanPhoneNumber)
              .limit(1)
              .get();

          if (userQuery.docs.isEmpty) {
            throw FirebaseAuthException(
              code: 'user-not-found',
              message: 'No user found with this phone number',
            );
          }

          String email = userQuery.docs.first.get('email') as String;

          // Sign in with retrieved email
          UserCredential userCredential =
              await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          await _saveUserSession(userCredential.user!.uid);
          return userCredential;
        } on FirebaseException catch (e) {
          if (e.code == 'permission-denied') {
            throw 'Unable to verify phone number. Please try signing in with email instead.';
          }
          rethrow;
        }
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  String _handleFirestoreError(dynamic e) {
    if (e is FirebaseException) {
      switch (e.code) {
        case 'permission-denied':
          return 'Permission denied. Please check your account permissions.';
        case 'unavailable':
          return 'Service temporarily unavailable. Please try again later.';
        default:
          return 'Database error: ${e.message}';
      }
    }
    return e.toString();
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
  }

  // Save user session
  Future<void> _saveUserSession(String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
  }

  // Get current user data
  Future<UserModel?> getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Handle Firebase Auth Errors
  String _handleAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'This email is already registered';
        case 'invalid-email':
          return 'Invalid email address';
        case 'weak-password':
          return 'Password is too weak';
        case 'user-not-found':
          return 'No user found with this email';
        case 'wrong-password':
          return 'Wrong password';
        default:
          return 'Authentication failed';
      }
    }
    return e.toString();
  }
}
