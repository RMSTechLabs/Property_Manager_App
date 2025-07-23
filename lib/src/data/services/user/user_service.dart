import 'package:dio/dio.dart';

abstract class IUserService {
  Future<Response> updateProfile(
    Map<String, dynamic> body,
    String filePaths,
    String memberId,
  );
}
