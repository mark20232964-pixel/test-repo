import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _messagesRef(String chatId) =>
      _db.collection('chats').doc(chatId).collection('messages');

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    await _messagesRef(chatId).add({
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.now(),
      'isRead': false,
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(String chatId) {
    return _messagesRef(chatId).orderBy('timestamp').snapshots();
  }

  Future<void> markAsRead(String chatId, String messageId) async {
    await _messagesRef(chatId).doc(messageId).update({'isRead': true});
  }
}
