import 'package:property_manager_app/src/core/utils/app_helper.dart';

class TicketDetailModel {
  final String id;
  final String title;
  final String category;
  final String status;
  final String timestamp;
  final String description;
  final String location;
  final String assignee;
  final int responseCount;
  final String createdBy;
  final String community;
  final List<String> imageUrls;
  final List<CommentModel> comments;

  TicketDetailModel({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.timestamp,
    required this.description,
    required this.location,
    required this.assignee,
    required this.responseCount,
    required this.createdBy,
    required this.community,
    required this.imageUrls,
    required this.comments,
  });

  factory TicketDetailModel.fromJson(Map<String, dynamic> json) {
    return TicketDetailModel(
      id: 'MW-${json['data']['id'].toString()}',
      title: json['data']['category']['category'] ?? '',
      category: json['data']['category']['category'] ?? '',
      status: json['data']['ticketStatus'] ?? '',
      timestamp: AppHelper.formatComplaintTimestamp(json['data']['createdAt'] ?? ''),
      description: json['data']['complaintDescription'] ?? '',
      location: '${json['data']['apartment']["block"]}-${json['data']['apartment']["flat"]}',
      assignee: json['data']['assignedUser']['name'] ?? '',
      responseCount: (json['data']['comments'] as List?)?.length ?? 0,
      createdBy: json['data']['complainer']["name"] ?? 'user',
      community: json['data']['society']['societyName'] ?? '',
      imageUrls: (json['data']['complaintImages'] as List<dynamic>? ?? [])
          .map((image) => image['fileUrl'].toString())
          .toList(),
      comments: (json['data']['comments'] as List<dynamic>? ?? [])
          .map((comment) => CommentModel.fromJson(comment))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'status': status,
      'timestamp': timestamp,
      'description': description,
      'location': location,
      'assignee': assignee,
      'responseCount': responseCount,
      'createdBy': createdBy,
      'community': community,
      'imageUrls': imageUrls,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }

  TicketDetailModel copyWith({
    String? id,
    String? title,
    String? category,
    String? status,
    String? timestamp,
    String? description,
    String? location,
    String? assignee,
    int? responseCount,
    String? createdBy,
    String? community,
    List<String>? imageUrls,
    List<CommentModel>? comments,
  }) {
    return TicketDetailModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
      location: location ?? this.location,
      assignee: assignee ?? this.assignee,
      responseCount: responseCount ?? this.responseCount,
      createdBy: createdBy ?? this.createdBy,
      community: community ?? this.community,
      imageUrls: imageUrls ?? this.imageUrls,
      comments: comments ?? this.comments,
    );
  }
}

class CommentModel {
  final String id;
  final String authorName;
  final String authorRole;
  final String timestamp;
  final String content;
  final bool isSystemMessage;
  final List<String> images;

  CommentModel({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.timestamp,
    required this.content,
    this.isSystemMessage = false,
    this.images = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'].toString(),
      authorName:'Monish Paul', //json['authorName'] ?? '',
      authorRole: 'Admin', //json['authorRole'] ?? '',
      timestamp: AppHelper.formatComplaintTimestamp(json['createdAt'] ?? ''),
      content: json['comments'] ?? '',
      isSystemMessage: false,//json['isSystemMessage'] ?? false,
      images: (json['images'] as List<dynamic>? ?? [])
          .map((image) => image['imageUrl'].toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'authorRole': authorRole,
      'timestamp': timestamp,
      'content': content,
      'isSystemMessage': isSystemMessage,
      'images': images,
    };
  }

  CommentModel copyWith({
    String? id,
    String? authorName,
    String? authorRole,
    String? timestamp,
    String? content,
    bool? isSystemMessage,
    List<String>? images,
  }) {
    return CommentModel(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      timestamp: timestamp ?? this.timestamp,
      content: content ?? this.content,
      isSystemMessage: isSystemMessage ?? this.isSystemMessage,
      images: images ?? this.images,
    );
  }
}
