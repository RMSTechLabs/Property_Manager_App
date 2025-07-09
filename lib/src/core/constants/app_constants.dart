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

  // static const LinearGradient primaryGradient = LinearGradient(
  //   colors: [Color(0xFF5A5FFF), Color(0xFFB833F2)],
  //   begin: Alignment.topLeft,
  //   end: Alignment.bottomRight,
  // );
  // static const LinearGradient secondartGradient = LinearGradient(
  //   begin: Alignment.topCenter,
  //   end: Alignment.bottomCenter,
  //   colors: [
  //     Color(0xFF6366F1), // Indigo
  //     Color(0xFF8B5CF6), // Purple
  //   ],
  // );

  // Primary gradient (if you have one)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6B73FF), // Light purple
      Color(0xFF9B59B6), // Purple
    ],
  );
  
  // Secondary gradient - Modern professional look
  static const LinearGradient secondartGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.4, 0.8, 1.0],
    colors: [
      Color(0xFF667eea), // Soft blue
      Color(0xFF764ba2), // Purple-blue
      Color(0xFF9B59B6), // Purple
      Color(0xFF8B5A8C), // Deep purple
    ],
  );
  
  // Alternative option 1: Elegant blue-purple gradient
  static const LinearGradient alternativeGradient1 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4facfe), // Light blue
      Color(0xFF00f2fe), // Cyan
      Color(0xFF667eea), // Purple-blue
      Color(0xFF764ba2), // Purple
    ],
  );
  
  // Alternative option 2: Warm sunset gradient
  static const LinearGradient alternativeGradient2 = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFff9a9e), // Light pink
      Color(0xFFfecfef), // Pink
      Color(0xFFfecfef), // Pink
      Color(0xFFa8edea), // Light blue
    ],
  );
  
  // Alternative option 3: Professional dark gradient
  static const LinearGradient alternativeGradient3 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2c3e50), // Dark blue
      Color(0xFF34495e), // Slate
      Color(0xFF5d4e75), // Purple-gray
      Color(0xFF8B5A8C), // Purple
    ],
  );
  
  // Alternative option 4: Modern teal gradient
  static const LinearGradient alternativeGradient4 = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF11998e), // Teal
      Color(0xFF38ef7d), // Green
      Color(0xFF667eea), // Blue
      Color(0xFF764ba2), // Purple
    ],
  );
  static const Color whiteColor = Color(0xFFF2F4F5);
  static const Color white50 = Color(0xFFE5E7EB);
  static const Color black = Color(0xFF1F2937);
  static const Color black50 = Color(0xFF6B7280);
  static const Color purple50 = Color(0xFF6366F1);
  static const Color gray = Color(0xFF6B7280);
}
