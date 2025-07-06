// Comments Provider - Add this provider for managing comments separately
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_manager_app/src/data/models/comment_model.dart';
import 'package:property_manager_app/src/data/services/comment/comment_service_impl.dart';

final commentsProvider = FutureProvider.family<List<CommentModel>, String>((ref, ticketId) async {
  final commentService = ref.read(commentServiceProvider);
  return await commentService.getCommentsByTicketId(ticketId);
});