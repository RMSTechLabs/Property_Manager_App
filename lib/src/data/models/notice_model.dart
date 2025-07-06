// Updated NoticeModel
import 'package:property_manager_app/src/core/utils/app_helper.dart';
import 'package:property_manager_app/src/data/models/notice_file_model.dart';

class NoticeModel {
  final String id;
  final String title;
  final String description;
  final String content;
  final String timestamp;
  final String category;
  final bool isRead;
  final bool isSaved;
  final bool hasAttachment;
  final int attachmentCount;
  final String createdBy;
  final DateTime createdAt;
  final List<NoticeFile> noticeFiles; // Changed from images to noticeFiles
  final String noticeId;

  NoticeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.timestamp,
    required this.category,
    this.isRead = false,
    this.isSaved = false,
    this.hasAttachment = false,
    this.attachmentCount = 0,
    required this.createdBy,
    required this.createdAt,
    this.noticeFiles = const [], // Changed from images
    required this.noticeId,
  });

  NoticeModel copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? timestamp,
    String? category,
    bool? isRead,
    bool? isSaved,
    bool? hasAttachment,
    int? attachmentCount,
    String? createdBy,
    DateTime? createdAt,
    List<NoticeFile>? noticeFiles, // Changed from images
    String? noticeId,
  }) {
    return NoticeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      isRead: isRead ?? this.isRead,
      isSaved: isSaved ?? this.isSaved,
      hasAttachment: hasAttachment ?? this.hasAttachment,
      attachmentCount: attachmentCount ?? this.attachmentCount,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      noticeFiles: noticeFiles ?? this.noticeFiles, // Changed from images
      noticeId: noticeId ?? this.noticeId,
    );
  }

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    // Parse noticeFiles array
    final noticeFilesJson = json['noticeFiles'] as List<dynamic>? ?? [];
    final noticeFiles = noticeFilesJson
        .map((fileJson) => NoticeFile.fromJson(fileJson as Map<String, dynamic>))
        .toList();

    return NoticeModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '', // Use actual content field
      timestamp: AppHelper.formatComplaintTimestamp(json['postedAt'] ?? ''),
      category: json['notificationType'] ?? '',
      isRead: json['isRead'] ?? false,
      isSaved: json['isSaved'] ?? false,
      hasAttachment: noticeFiles.isNotEmpty,
      attachmentCount: noticeFiles.length,
      createdBy: json['postedBy']?['name'] ?? '',
      createdAt: DateTime.parse(json['postedAt']),
      noticeFiles: noticeFiles, // Use parsed NoticeFile objects
      noticeId: json['noticeId']?.toString() ?? json['id'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'timestamp': timestamp,
      'category': category,
      'isRead': isRead,
      'isSaved': isSaved,
      'hasAttachment': hasAttachment,
      'attachmentCount': attachmentCount,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'noticeFiles': noticeFiles.map((file) => file.toJson()).toList(),
      'noticeId': noticeId,
    };
  }
}