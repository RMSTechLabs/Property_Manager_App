import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://api.example.com';

  //  static const String baseUrl = String.fromEnvironment(
  //   'API_BASE_URL',
  //   defaultValue: 'https://api.example.com',
  // );

  static const String loginEndpoint = '/auth/authenticate';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String logoutEndpoint = '/auth/logout';
  static const String userProfileEndpoint = '/auth/me';
  static const String sendOtpEndpoint = "/auth/send-otp";
  static const String validateOtpEndpoint = "/auth/validate-otp";
  static const String getCommunityForResidentEndpoint =
      '/master/resident-society-details';
  static const String getComplaintsEndpoint = '/complaints/all-complaint';
  static const String getComplaintEndpoint = '/complaints';
  static const String getNoticeEndpoint = '/notice';
  static const String addComplaintEndpoint = '/complaints';

  static const String getAllCategoryApi = "/category/category-list";
  static const String postComment = '/master/send-comments';
  static const String sendCommentWithImageEndpoint =
      '/master/send-comments-with-image';
  static const String getCommentListByComplaintIdEndpoint =
      '/master/comment-list';

  static const String getNoticesEndpoint = '/notice/app/get-notices';
  // FCM endpoints
  static const String registerDeviceEndpoint = '/devices/register';
  static const String updateDeviceTokenEndpoint = '/devices/update-token';
  static const String unregisterDeviceEndpoint = '/devices/unregister';

  // New endpoint for user profile with properties
  static String getUserProfileEndpoint(String userId) => '/auth/me/$userId';
  static String getUserProfileUpdateWithImageEndpoint(String memberId) =>
      '/member/edit-member-with-profile/$memberId';
  static Duration get connectTimeout =>
      Duration(milliseconds: int.parse(dotenv.env['API_TIMEOUT'] ?? '30000'));
  static Duration get receiveTimeout =>
      Duration(milliseconds: int.parse(dotenv.env['API_TIMEOUT'] ?? '30000'));

  static bool get isDebugMode =>
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
}
