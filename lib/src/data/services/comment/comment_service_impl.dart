import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart'; // Required for contentType
import 'package:property_manager_app/src/core/constants/api_constants.dart';
import 'package:property_manager_app/src/core/dio/dio_client.dart';
import 'package:property_manager_app/src/data/models/comment_model.dart';
import 'package:property_manager_app/src/data/services/comment/comment_service.dart';
import 'package:property_manager_app/src/presentation/providers/dio_provider.dart';

class CommentService implements ICommentService {
  final DioClient _dioClient;

  CommentService(this._dioClient);

  @override
  Future<Response> sendCommentWithImage({
    required String ticketId,
    required String comment,
    required String societyId,
    required List<String> filePaths,
  }) async {
    final formData = FormData();

    // Create comment body matching your API structure
    final commentBody = {
      'complaintId': ticketId,
      'comments': comment,
      'societyId': societyId,
      "userType": "user",
    };

    // Add comment JSON with correct Content-Type
    formData.files.add(
      MapEntry(
        'comment',
        MultipartFile.fromString(
          jsonEncode(commentBody),
          filename: 'comment.json',
          contentType: MediaType('application', 'json'),
        ),
      ),
    );

    // Add files with field name 'imageFile'
    for (final path in filePaths) {
      formData.files.add(
        MapEntry('imageFile', await MultipartFile.fromFile(path)),
      );
    }

    final response = await _dioClient.post(
      ApiConstants
          .sendCommentWithImageEndpoint, // You'll need to add this to ApiConstants
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );

    print('Comment sent: ${response.data}');
    return response;
  }

  @override
  Future<List<CommentModel>> getCommentsByTicketId(String ticketId) async {
    try {
      final response = await _dioClient.get(
        '${ApiConstants.getCommentListByComplaintIdEndpoint}/$ticketId',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load comments');
      }

      final List<dynamic> dataList = response.data["data"] ?? response.data;
      return dataList.map((json) => CommentModel.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch comments: $error');
    }
  }
}

final commentServiceProvider = Provider<CommentService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return CommentService(dioClient);
});
