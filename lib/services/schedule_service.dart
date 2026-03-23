import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roadresq/models/schedule.dart';

class ScheduleService {
  final _db = FirebaseFirestore.instance;

  Future<void> createSchedule(ScheduleModel schedule) async {
    await _db.collection('requests').add(schedule.toJson());
  }

  Future<List<ScheduleModel>> getSchedules([
    Map<String, dynamic> params = const {},
  ]) async {
    Query<Map<String, dynamic>> query = _db.collection('requests');
    for (final entry in params.entries) {
      query = query.where(entry.key, isEqualTo: entry.value);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ScheduleModel.fromJson(doc.id, doc.data()))
        .toList();
  }
}
