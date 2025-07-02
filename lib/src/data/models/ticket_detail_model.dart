// Data Models
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
  final String imageUrl;
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
    required this.imageUrl,
    required this.comments,
  });
}

class CommentModel {
  final String id;
  final String authorName;
  final String authorRole;
  final String timestamp;
  final String content;
  final bool isSystemMessage;

  CommentModel({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.timestamp,
    required this.content,
    this.isSystemMessage = false,
  });
}