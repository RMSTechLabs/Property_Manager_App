import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../constants/app_constants.dart';

class JwtDecoderUtil {
  static DateTime getExpiryTime(String token) {
    return JwtDecoder.getExpirationDate(token);
  }
  
  static bool isTokenExpired(String token) {
    try {
      final expiryTime = getExpiryTime(token);
      final now = DateTime.now();
      
      // Consider token expired if it expires within the buffer time
      return expiryTime.isBefore(now.add(AppConstants.tokenRefreshBuffer));
    } catch (e) {
      //print('Error checking token expiry: $e');
      return true; // Assume expired if we can't decode
    }
  }
  
  static Map<String, dynamic> decodeToken(String token) {
    return JwtDecoder.decode(token);
  }
  
  static String? getUserId(String token) {
    try {
      final decoded = decodeToken(token);
      return decoded['sub'] ?? decoded['userId'] ?? decoded['user_id'];
    } catch (e) {
      //print('Error getting user ID from token: $e');
      return null;
    }
  }
  
  static String? getUserEmail(String token) {
    try {
      final decoded = decodeToken(token);
      return decoded['email'];
    } catch (e) {
      //print('Error getting email from token: $e');
      return null;
    }
  }
  
  static Duration getTimeUntilExpiry(String token) {
    try {
      final expiryTime = getExpiryTime(token);
      return expiryTime.difference(DateTime.now());
    } catch (e) {
      //print('Error calculating time until expiry: $e');
      return Duration.zero;
    }
  }
  
  static bool isTokenValidForDuration(String token, Duration duration) {
    try {
      final timeUntilExpiry = getTimeUntilExpiry(token);
      return timeUntilExpiry > duration;
    } catch (e) {
      return false;
    }
  }
  
  static DateTime? getIssuedAt(String token) {
    try {
      final decoded = decodeToken(token);
      final iat = decoded['iat'];
      if (iat != null) {
        return DateTime.fromMillisecondsSinceEpoch(iat * 1000);
      }
    } catch (e) {
      //print('Error getting issued at time: $e');
    }
    return null;
  }
}