import 'package:flutter/material.dart';

class AppConstants {
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';

  // JWT Configuration
  static const Duration accessTokenLifetime = Duration(
    minutes: 10,
  ); // Server gives 10min
  static const Duration refreshInterval = Duration(
    minutes: 9,
  ); // Refresh at 9min
  static const Duration refreshTokenExpiryDuration = Duration(days: 30);
  static const Duration tokenRefreshBuffer = Duration(seconds: 30);

  // App State
  static const String isLoggedInKey = 'is_logged_in';
  static const String lastLoginKey = 'last_login_timestamp';

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF5A5FFF), Color(0xFFB833F2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Color whiteColor = Color(0xFFF2F4F5);
}
