// lib/src/data/models/notification_model.dart
import '../../domain/entities/notification.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.type,
    required super.data,
    required super.createdAt,
    super.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromRemoteMessage(Map<String, dynamic> message) {
    return NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: message['title'] ?? '',
      body: message['body'] ?? '',
      type: message['type'] ?? 'general',
      data: Map<String, dynamic>.from(message),
      createdAt: DateTime.now(),
    );
  }
}