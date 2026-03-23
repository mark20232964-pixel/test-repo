import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final _db = FirebaseFirestore.instance;

  String chatId(String userId, String providerId) =>
      ([userId, providerId]..sort()).join('_');

  Map<String, dynamic> _toReadable(String id, Map<String, dynamic> data) => {
        'id': id,
        'userId': data['userId'],
        'providerId': data['providerId'],
        'requestId': data['requestId'],
        'createdAt': data['createdAt'] != null
            ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
            : DateTime.now().toIso8601String(),
        'updatedAt': data['updatedAt'] != null
            ? (data['updatedAt'] as Timestamp).toDate().toIso8601String()
            : DateTime.now().toIso8601String(),
      };

  Future<Map<String, dynamic>?> getChat(
      String userId, String providerId) async {
    final snapshot =
        await _db.collection('chats').doc(chatId(userId, providerId)).get();
    if (!snapshot.exists) return null;
    return _toReadable(snapshot.id, snapshot.data()!);
  }

  Future<Map<String, dynamic>> getOrCreateChat({
    required String userId,
    required String providerId,
    required String requestId,
  }) async {
    final snapshot = await _db
        .collection('chats')
        .where('requestId', isEqualTo: requestId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      return _toReadable(doc.id, doc.data());
    }

    final id = chatId(userId, providerId);
    final now = Timestamp.now();
    final data = {
      'userId': userId,
      'providerId': providerId,
      'requestId': requestId,
      'createdAt': now,
      'updatedAt': now,
    };
    await _db.collection('chats').doc(id).set(data);
    return {
      'id': id,
      'userId': userId,
      'providerId': providerId,
      'requestId': requestId,
      'createdAt': now.toDate().toIso8601String(),
      'updatedAt': now.toDate().toIso8601String(),
    };
  }
}
