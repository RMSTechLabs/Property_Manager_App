import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'https://api.example.com';
  //  static const String baseUrl = String.fromEnvironment(
  //   'API_BASE_URL',
  //   defaultValue: 'https://api.example.com',
  // );
  
  static const String loginEndpoint = '/auth/login';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String userProfileEndpoint = '/auth/me';
  
  static Duration get connectTimeout => 
    Duration(milliseconds: int.parse(dotenv.env['API_TIMEOUT'] ?? '30000'));
  static Duration get receiveTimeout => 
    Duration(milliseconds: int.parse(dotenv.env['API_TIMEOUT'] ?? '30000'));
    
  static bool get isDebugMode => 
    dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
}


