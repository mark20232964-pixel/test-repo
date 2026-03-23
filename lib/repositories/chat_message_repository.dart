import 'package:roadresq/services/chat_message_service.dart';

class ChatMessageRepository {
  final _service = ChatMessageService();

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    try {
      await _service.sendMessage(
        chatId: chatId,
        senderId: senderId,
        text: text,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Stream<List<Map<String, dynamic>>> getMessages(String chatId) {
    return _service.getMessages(chatId).map(
          (snapshot) => snapshot.docs
              .map((doc) => {
                    'id': doc.id,
                    ...doc.data(),
                    'timestamp': doc.data()['timestamp'] != null
                        ? (doc.data()['timestamp'] as dynamic)
                            .toDate()
                            .toIso8601String()
                        : null,
                  })
              .toList(),
        );
  }

  Future<void> markAsRead(String chatId, String messageId) async {
    try {
      await _service.markAsRead(chatId, messageId);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
