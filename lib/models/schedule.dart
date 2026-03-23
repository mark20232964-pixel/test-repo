import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleModel {
  final String id;
  final String userId;
  final String providerId;
  final String issue;
  final GeoPoint location;
  final GeoPoint providerLocation;
  final DateTime scheduledTime;
  final String status;
  final DateTime timestamp;

  ScheduleModel({
    this.id = '',
    required this.userId,
    required this.providerId,
    required this.issue,
    required this.location,
    required this.providerLocation,
    required this.scheduledTime,
    this.status = 'pending',
  }) : timestamp = DateTime.now();

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'providerId': providerId,
    'issue': issue,
    'location': location,
    'providerLocation': providerLocation,
    'scheduledTime': Timestamp.fromDate(scheduledTime),
    'status': status,
    'timestamp': Timestamp.fromDate(timestamp),
  };

  factory ScheduleModel.fromJson(String id, Map<String, dynamic> json) =>
      ScheduleModel(
        id: id,
        userId: json['userId'] as String,
        providerId: json['providerId'] as String,
        issue: json['issue'] as String? ?? '',
        location: json['location'] as GeoPoint,
        providerLocation: json['providerLocation'] as GeoPoint,
        scheduledTime: (json['scheduledTime'] as Timestamp).toDate(),
        status: json['status'] as String? ?? 'pending',
      );
}
