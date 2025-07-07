// lib/src/data/datasources/fcm_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/device_info_helper.dart';
import '../../presentation/providers/dio_provider.dart';
import '../models/device_registration_model.dart';

abstract class FCMRemoteDataSource {
  Future<String?> getFCMToken();
  Future<void> registerDevice(String userId, String accessToken);
  Future<void> updateDeviceToken(String userId, String newToken, String accessToken);
  Future<void> unregisterDevice(String userId, String accessToken);
  Stream<String> get tokenRefreshStream;
}

class FCMRemoteDataSourceImpl implements FCMRemoteDataSource {
  final Dio dio;
  final FirebaseMessaging firebaseMessaging;
  final Logger logger = Logger(printer: PrettyPrinter());

  FCMRemoteDataSourceImpl(this.dio, this.firebaseMessaging);

  @override
  Future<String?> getFCMToken() async {
    try {
      logger.i('🔑 Getting FCM token...');
      final token = await firebaseMessaging.getToken();
      if (token != null) {
        logger.i('✅ FCM Token received: ${token.substring(0, 50)}...');
      } else {
        logger.w('⚠️ FCM Token is null');
      }
      return token;
    } catch (e) {
      logger.e('❌ Failed to get FCM token: $e');
      throw FCMException('Failed to get FCM token: $e');
    }
  }

  @override
  Future<void> registerDevice(String userId, String accessToken) async {
    try {
      logger.i('📱 Registering device for user: $userId');
      
      final fcmToken = await getFCMToken();
      if (fcmToken == null) {
        throw FCMException('FCM token is null');
      }

      final deviceId = await DeviceInfoHelper.getDeviceId();
      final deviceName = await DeviceInfoHelper.getDeviceName();
      final osVersion = await DeviceInfoHelper.getOSVersion();
      final deviceType = DeviceInfoHelper.getDeviceType();

      final deviceRegistration = DeviceRegistrationModel(
        userId: userId,
        fcmToken: fcmToken,
        deviceId: deviceId,
        deviceType: deviceType,
        deviceName: deviceName,
        osVersion: osVersion,
      );

      final response = await dio.post(
        ApiConstants.registerDeviceEndpoint,
        data: deviceRegistration.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        logger.i('✅ Device registered successfully');
      } else {
        throw FCMException('Device registration failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      logger.e('❌ DioException during device registration: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized: Invalid access token');
      } else if (e.response?.statusCode == 409) {
        // Device already registered, try to update instead
        logger.i('🔄 Device already registered, updating token...');
        await updateDeviceToken(userId, await getFCMToken() ?? '', accessToken);
      } else {
        final message = e.response?.data?['message'] ?? 'Device registration failed';
        throw FCMException(message);
      }
    } catch (e) {
      logger.e('💥 Unexpected error during device registration: $e');
      if (e is FCMException || e is AuthException) {
        rethrow;
      }
      throw FCMException('Unexpected error during device registration: $e');
    }
  }

  @override
  Future<void> updateDeviceToken(String userId, String newToken, String accessToken) async {
    try {
      logger.i('🔄 Updating FCM token for user: $userId');
      
      final deviceId = await DeviceInfoHelper.getDeviceId();
      
      final response = await dio.put(
        ApiConstants.updateDeviceTokenEndpoint,
        data: {
          'userId': userId,
          'deviceId': deviceId,
          'fcmToken': newToken,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        logger.i('✅ FCM token updated successfully');
      } else {
        throw FCMException('Token update failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      logger.e('❌ Failed to update FCM token: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized: Invalid access token');
      } else {
        final message = e.response?.data?['message'] ?? 'Token update failed';
        throw FCMException(message);
      }
    } catch (e) {
      logger.e('💥 Unexpected error during token update: $e');
      if (e is FCMException || e is AuthException) {
        rethrow;
      }
      throw FCMException('Unexpected error during token update: $e');
    }
  }

  @override
  Future<void> unregisterDevice(String userId, String accessToken) async {
    try {
      logger.i('🗑️ Unregistering device for user: $userId');
      
      final deviceId = await DeviceInfoHelper.getDeviceId();
      
      final response = await dio.delete(
        ApiConstants.unregisterDeviceEndpoint,
        data: {
          'userId': userId,
          'deviceId': deviceId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        logger.i('✅ Device unregistered successfully');
      } else {
        logger.w('⚠️ Device unregistration returned status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      logger.e('❌ Failed to unregister device: ${e.message}');
      // Don't throw error for unregistration failures during logout
    } catch (e) {
      logger.e('💥 Unexpected error during device unregistration: $e');
      // Don't throw error for unregistration failures
    }
  }

  @override
  Stream<String> get tokenRefreshStream {
    return firebaseMessaging.onTokenRefresh;
  }
}

final fcmRemoteDataSourceProvider = Provider<FCMRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  final firebaseMessaging = FirebaseMessaging.instance;
  return FCMRemoteDataSourceImpl(dio, firebaseMessaging);
});
