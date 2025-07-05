import 'package:dio/dio.dart';
import 'package:property_manager_app/src/data/models/comment_model.dart';

abstract class ICommentService {
  Future<Response> sendCommentWithImage({
    required String ticketId,
    required String comment,
    required String societyId,
    required List<String> filePaths,
  });

  Future<List<CommentModel>> getCommentsByTicketId(String ticketId);
}
