import 'package:roadresq/services/chat_service.dart';

class ChatRepository {
  final _service = ChatService();

  Future<Map<String, dynamic>?> getChat(
      String userId, String providerId) async {
    try {
      return await _service.getChat(userId, providerId);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> getOrCreateChat({
    required String userId,
    required String providerId,
    required String requestId,
  }) async {
    try {
      return await _service.getOrCreateChat(
        userId: userId,
        providerId: providerId,
        requestId: requestId,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
