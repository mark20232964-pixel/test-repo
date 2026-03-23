class ChatModel {
  final String id;
  final String userId;
  final String providerId;
  final String requestId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatModel({
    this.id = '',
    required this.userId,
    required this.providerId,
    required this.requestId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'providerId': providerId,
        'requestId': requestId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ChatModel.fromJson(String id, Map<String, dynamic> json) => ChatModel(
        id: id,
        userId: json['userId'] as String,
        providerId: json['providerId'] as String,
        requestId: json['requestId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
