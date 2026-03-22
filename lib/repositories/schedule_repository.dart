import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roadresq/models/schedule.dart';
import 'package:roadresq/services/schedule_service.dart';

class ScheduleRepository {
  final _service = ScheduleService();

  Future<void> createSchedule(ScheduleModel schedule) async {
    try {
      await _service.createSchedule(schedule);
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<List<Map<String, dynamic>>> getSchedules([
    Map<String, dynamic> params = const {},
  ]) async {
    try {
      final schedules = await _service.getSchedules(params);
      return schedules
          .map((s) => {
                'id': s.id,
                'issue': s.issue,
                'scheduledTime': s.scheduledTime,
                'status': s.status,
                'userId': s.userId,
                'providerId': s.providerId,
              })
          .toList();
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    }
  }
}
