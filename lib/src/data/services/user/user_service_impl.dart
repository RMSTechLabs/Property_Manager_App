import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart'; // Required for contentType
import 'package:property_manager_app/src/core/constants/api_constants.dart';
import 'package:property_manager_app/src/core/dio/dio_client.dart';
import 'package:property_manager_app/src/data/services/user/user_service.dart';
import 'package:property_manager_app/src/presentation/providers/dio_provider.dart';

class UserService extends IUserService {
  final DioClient _dioClient;

  UserService(this._dioClient);

  @override
  Future<Response> updateProfile(
    Map<String, dynamic> body,
    String? filePath,
    String memberId,
  ) async {
    final formData = FormData();

    // ✅ Send user JSON as a regular field
    // formData.fields.add(MapEntry('user', jsonEncode(body)));
    formData.files.add(
      MapEntry(
        'user',
        MultipartFile.fromString(
          jsonEncode(body),
          filename: 'user.json',
          contentType: MediaType('application', 'json'), // ⬅️ FIXED!
        ),
      ),
    );

    // ✅ Add image only if available
    if (filePath != null && filePath.isNotEmpty) {
      formData.files.add(
        MapEntry('profileImage', await MultipartFile.fromFile(filePath)),
      );
    }

    final response = await _dioClient.dio.put(
      ApiConstants.getUserProfileUpdateWithImageEndpoint(memberId),
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );

    return response;
  }
}

final userServiceProvider = Provider<UserService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return UserService(dioClient);
});
