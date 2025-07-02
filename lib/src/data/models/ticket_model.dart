// Data Model
import 'package:property_manager_app/src/core/utils/app_helper.dart';

class TicketModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final String timestamp;
  final String location;
  final int responseCount;
  final String createdBy;
  final String assignee;

  TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.timestamp,
    required this.location,
    required this.responseCount,
    required this.createdBy,
    required this.assignee,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: 'MW-${json['id'].toString()}',
      title: json['category']['category'],
      description: json['complaintDescription'] ?? '',
      status: json['ticketStatus'] ?? '',
      timestamp: AppHelper.formatComplaintTimestamp(json['createdAt'] ?? ''),
      location: '${json['apartment']["block"]}-${json['apartment']["flat"]}',
      responseCount: (json['comments'] as List?)?.length ?? 0,
      createdBy: json['complainer']["name"] ?? 'user',
      assignee: json['assignedUser']["name"] ?? 'NA',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'timestamp': timestamp,
      'location': location,
      'responseCount': responseCount,
      'createdBy': createdBy,
      'assignee': assignee,
    };
  }
}
