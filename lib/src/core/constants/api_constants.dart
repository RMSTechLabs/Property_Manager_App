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
  static const String userProfileEndpoint = '/auth/me';
  static const String sendOtpEndpoint = "/auth/send-otp";
  static const String validateOtpEndpoint = "/auth/validate-otp";
  static const String getCommunityForResidentEndpoint =
      '/master/resident-society-details';
  static const String getComplaintsEndpoint = '/complaints/all-complaint';
  static const String getComplaintEndpoint = '/complaints';

  static Duration get connectTimeout =>
      Duration(milliseconds: int.parse(dotenv.env['API_TIMEOUT'] ?? '30000'));
  static Duration get receiveTimeout =>
      Duration(milliseconds: int.parse(dotenv.env['API_TIMEOUT'] ?? '30000'));

  static bool get isDebugMode =>
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
}
