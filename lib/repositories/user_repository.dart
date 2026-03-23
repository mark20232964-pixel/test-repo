import 'package:roadresq/services/user_service.dart';

class UserRepository {
  final _service = UserService();

  Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      return await _service.getUser(uid);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> createUser(Map<String, dynamic> data) async {
    try {
      await _service.createUser(data);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> updateLastLogin(String uid) async {
    try {
      await _service.updateLastLogin(uid);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
