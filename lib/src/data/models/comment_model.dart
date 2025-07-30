// Comment Model
// File: lib/src/data/models/comment_model.dart

import 'package:property_manager_app/src/core/utils/app_helper.dart';

class CommentModel {
  final String id;
  final String authorName;
  final String authorRole;
  final String profileUrl;
  final String timestamp;
  final String content;
  final List<String> images;
  final bool isSystemMessage;

  CommentModel({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.timestamp,
    required this.content,
    this.images = const [],
    this.isSystemMessage = false,
    required this.profileUrl,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'].toString(),
      authorName:
          json['person']?['name'] ?? 'Unknown', //json['authorName'] ?? '',
      authorRole: 'Resident', //json['authorRole'] ?? '',
      timestamp: AppHelper.formatComplaintTimestamp(json['createdAt'] ?? ''),
      content: json['comments'] ?? '',
      isSystemMessage: false, //json['isSystemMessage'] ?? false,
      images: (json['images'] as List<dynamic>? ?? [])
          .map((image) => image['imageUrl'].toString())
          .toList(),
      profileUrl: json['person']?['profileUrl'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'authorRole': authorRole,
      'timestamp': timestamp,
      'content': content,
      'images': images,
      'isSystemMessage': isSystemMessage,
      'profileUrl': profileUrl,
    };
  }

  CommentModel copyWith({
    String? id,
    String? authorName,
    String? authorRole,
    String? timestamp,
    String? content,
    List<String>? images,
    bool? isSystemMessage,
    String? profileUrl,
  }) {
    return CommentModel(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      timestamp: timestamp ?? this.timestamp,
      content: content ?? this.content,
      images: images ?? this.images,
      isSystemMessage: isSystemMessage ?? this.isSystemMessage,
      profileUrl: profileUrl ?? this.profileUrl,
    );
  }
}
