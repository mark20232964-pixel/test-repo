// lib/models/user.dart

import 'package:firebase_auth/firebase_auth.dart' as auth;

class AppUser {
  final String uid;
  final String? name;
  final String? email;
  final String role; // 'driver' or 'provider'
  final String? profilePicUrl;

  AppUser({
    required this.uid,
    this.name,
    this.email,
    required this.role,
    this.profilePicUrl,
  });

  // Factory to create from Firebase user
  factory AppUser.fromFirebaseUser(auth.User firebaseUser, String role) {
    return AppUser(
      uid: firebaseUser.uid,
      name: firebaseUser.displayName,
      email: firebaseUser.email,
      role: role,
      profilePicUrl: firebaseUser.photoURL,
    );
  }
}
