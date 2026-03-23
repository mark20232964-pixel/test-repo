// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user (null if not logged in)
  User? get currentUser => _auth.currentUser;

  // Stream to listen to auth changes (useful later)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email/password
  Future<User?> signUp(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await result.user?.updateDisplayName(name.trim());
      await result.user?.reload(); // refresh user
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  // Login with email/password
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
