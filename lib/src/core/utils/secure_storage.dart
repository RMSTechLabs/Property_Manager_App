import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:property_manager_app/src/data/models/user_model.dart';
import 'package:property_manager_app/src/domain/entities/user.dart';
import 'dart:convert';
import '../constants/app_constants.dart';



class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Refresh Token Management
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(
      key: AppConstants.refreshTokenKey,
      value: token,
    );
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.refreshTokenKey);
  }

  static Future<void> deleteRefreshToken() async {
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }

  // User Data Management
  static Future<void> saveUserData(User user) async {
    final userData = UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
    ).toJson();
    
    await _storage.write(
      key: AppConstants.userDataKey,
      value: json.encode(userData),
    );
  }

  static Future<User?> getUserData() async {
    try {
      final userDataString = await _storage.read(key: AppConstants.userDataKey);
      if (userDataString != null) {
        final userData = json.decode(userDataString);
        return UserModel.fromJson(userData);
      }
    } catch (e) {
      //print('Error reading user data: $e');
    }
    return null;
  }

  static Future<void> deleteUserData() async {
    await _storage.delete(key: AppConstants.userDataKey);
  }

  // Login State Management
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    await _storage.write(
      key: AppConstants.isLoggedInKey,
      value: isLoggedIn.toString(),
    );
    
    if (isLoggedIn) {
      await _storage.write(
        key: AppConstants.lastLoginKey,
        value: DateTime.now().millisecondsSinceEpoch.toString(),
      );
    }
  }

  static Future<bool> isLoggedIn() async {
    final isLoggedInString = await _storage.read(key: AppConstants.isLoggedInKey);
    return isLoggedInString?.toLowerCase() == 'true';
  }

  static Future<DateTime?> getLastLoginTime() async {
    final timestampString = await _storage.read(key: AppConstants.lastLoginKey);
    if (timestampString != null) {
      try {
        final timestamp = int.parse(timestampString);
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      } catch (e) {
        //print('Error parsing last login time: $e');
      }
    }
    return null;
  }

  // Clear all data (for logout)
  static Future<void> deleteAll() async {
    await Future.wait([
      deleteRefreshToken(),
      deleteUserData(),
      _storage.delete(key: AppConstants.isLoggedInKey),
      _storage.delete(key: AppConstants.lastLoginKey),
    ]);
  }

  // Check if refresh token is still valid
  static Future<bool> hasValidRefreshToken() async {
    final refreshToken = await getRefreshToken();
    final lastLogin = await getLastLoginTime();
    
    if (refreshToken == null || lastLogin == null) {
      return false;
    }
    
    final tokenAge = DateTime.now().difference(lastLogin);
    return tokenAge < AppConstants.refreshTokenExpiryDuration;
  }
}