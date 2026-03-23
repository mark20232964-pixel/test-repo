import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final snapshot = await _db.collection('users').doc(uid).get();
    if (!snapshot.exists) return null;
    final data = snapshot.data()!;
    return {
      ...data,
      'createdAt': data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
          : DateTime.now().toIso8601String(),
      'lastLogin': data['lastLogin'] != null
          ? (data['lastLogin'] as Timestamp).toDate().toIso8601String()
          : DateTime.now().toIso8601String(),
    };
  }

  Future<void> createUser(Map<String, dynamic> data) async {
    final now = Timestamp.fromDate(DateTime.now());
    await _db.collection('users').doc(data['uid'] as String).set({
      ...data,
      'createdAt': data['createdAt'] != null
          ? Timestamp.fromDate(DateTime.parse(data['createdAt'] as String))
          : now,
      'lastLogin': data['lastLogin'] != null
          ? Timestamp.fromDate(DateTime.parse(data['lastLogin'] as String))
          : now,
    });
  }

  Future<void> updateLastLogin(String uid) async {
    await _db.collection('users').doc(uid).update({
      'lastLogin': Timestamp.fromDate(DateTime.now()),
    });
  }
}
