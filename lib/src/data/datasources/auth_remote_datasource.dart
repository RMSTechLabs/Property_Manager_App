// lib/src/data/datasources/auth_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:property_manager_app/src/data/datasources/fcm_remote_datasource.dart';
import 'package:property_manager_app/src/data/models/auth_response_model.dart';
import 'package:property_manager_app/src/data/models/send_otp_response_model.dart';
import 'package:property_manager_app/src/data/models/user_profile_response_model.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../presentation/providers/dio_provider.dart';

import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String email, String password);
  Future<String> refreshToken(String refreshToken);
  Future<void> logout(String email);
  Future<UserModel> getCurrentUser();
  Future<SendOtpResponseModel> sendOtp(String email);
  Future<bool> validateOtp(String otp, String otpIdentifier);
  Future<UserProfileResponseModel> getUserProfile(String userId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final FCMRemoteDataSource fcmDataSource; //
  var logger = Logger(printer: PrettyPrinter());

  AuthRemoteDataSourceImpl(this.dio, this.fcmDataSource);

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    try {
      final response = await dio.post(
        ApiConstants.loginEndpoint,
        data: {'username': email, 'password': password, 'platform': 'mobile'},
      );
      if (response.statusCode == 200) {
        if (response.data["success"] == false) {
          throw AuthException("Check Your Credentials");
        }

        final authResponse = AuthResponseModel.fromJson(response.data);
        logger.i('✅ Login successful for user: ${authResponse.user.id}');

        // Register FCM token after successful login
        try {
          await _registerFCMToken(
            authResponse.user.id,
            authResponse.accessToken,
          );
        } catch (fcmError) {
          // Log FCM error but don't fail the login
          logger.w('⚠️ FCM registration failed: $fcmError');
        }
        return authResponse;
      } else {
        // Don't throw generic error, let DioException handler below catch it
        throw ServerException(
          'Login failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.response?.statusCode == 400) {
        // Handle 400 specifically
        final message =
            e.response?.data?['message'] ??
            e.response?.data?['error'] ??
            'Invalid email or password';
        throw AuthException(message);
      } else if (e.response?.statusCode == 401) {
        throw AuthException('Invalid credentials');
      } else if (e.response?.statusCode == 422) {
        final message = e.response?.data?['message'] ?? 'Validation failed';
        throw AuthException(message);
      } else {
        final message =
            e.response?.data?['message'] ??
            e.response?.data?['error'] ??
            'Server error';
        throw ServerException(message);
      }
    } catch (e) {
      if (e is AuthException || e is NetworkException || e is ServerException) {
        rethrow; // Re-throw our custom exceptions
      }
      throw ServerException('Unexpected error occurred');
    }
  }

  Future<void> _registerFCMToken(String userId, String accessToken) async {
    try {
      logger.i('🔔 Registering FCM token for user: $userId');
      await fcmDataSource.registerDevice(userId, accessToken);
      logger.i('✅ FCM token registered successfully');
    } catch (e) {
      logger.e('❌ FCM token registration failed: $e');
      // Don't throw - FCM registration failure shouldn't break login
    }
  }


@override
Future<UserProfileResponseModel> getUserProfile(String userId) async {
  try {
    final response = await dio.get(
      ApiConstants.getUserProfileEndpoint(userId),
      queryParameters: {'userId': userId},
    );

    if (response.statusCode == 200) {
      final profileResponse = UserProfileResponseModel.fromJson(response.data);
      
      if (!profileResponse.success) {
        throw ServerException(profileResponse.message);
      }
      
      logger.i('✅ User profile fetched successfully for user: $userId');
      return profileResponse;
    } else {
      throw ServerException(
        'Failed to get user profile with status: ${response.statusCode}',
      );
    }
  } on DioException catch (e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw NetworkException('Connection timeout');
    } else if (e.response?.statusCode == 401) {
      throw AuthException('Unauthorized access');
    } else if (e.response?.statusCode == 404) {
      throw ServerException('User profile not found');
    } else {
      final message = e.response?.data?['message'] ?? 
                     e.response?.data?['error'] ?? 
                     'Failed to get user profile';
      throw ServerException(message);
    }
  } catch (e) {
    if (e is NetworkException || e is ServerException || e is AuthException) {
      rethrow;
    }
    throw ServerException('Unexpected error occurred while fetching profile');
  }
}

  @override
  Future<SendOtpResponseModel> sendOtp(String email) async {
    try {
      final response = await dio.post(
        ApiConstants.sendOtpEndpoint,
        data: {'email': email},
      );
      if (response.statusCode == 201) {
        if (response.data["success"] == false) {
          throw AuthException("Check Your EmailId");
        }
        return SendOtpResponseModel.fromJson(response.data);
      } else {
        throw ServerException('Server Error!');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else {
        final message =
            e.response?.data?['message'] ??
            e.response?.data?['error'] ??
            'Server error';
        throw ServerException(message);
      }
    } catch (e) {
      if (e is NetworkException || e is ServerException) {
        rethrow; // Re-throw our custom exceptions
      }
      throw ServerException('Unexpected error occurred');
    }
  }

  @override
  Future<bool> validateOtp(String otp, String otpIdentifier) async {
    try {
      final response = await dio.post(
        ApiConstants.validateOtpEndpoint,
        data: {'otp': otp, 'otpIdentifier': otpIdentifier},
      );
      if (response.statusCode == 200) {
        bool validate = response.data["data"]["validate"];
        return validate;
      } else {
        throw ServerException('Server Error!');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else {
        final message =
            e.response?.data?['message'] ??
            e.response?.data?['error'] ??
            'Server error';
        throw ServerException(message);
      }
    } catch (e) {
      if (e is NetworkException || e is ServerException) {
        rethrow; // Re-throw our custom exceptions
      }
      throw ServerException('Unexpected error occurred');
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post(
        ApiConstants.refreshTokenEndpoint,
        data: {'token': refreshToken},
      );
      if (response.statusCode == 200) {
        return response.data['data']['token'];
      } else {
        throw AuthException('Token refresh failed');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Invalid refresh token');
      } else {
        throw ServerException('Token refresh failed');
      }
    }
  }

  @override
  Future<void> logout(String email) async {
    // First try to unregister FCM token
    // Note: You might need to get userId from somewhere (maybe from stored user data)
    // For now, we'll skip FCM unregistration during logout
    // await fcmDataSource.unregisterDevice(userId, accessToken);
    print(email);
    try {
      final response = await dio.post(
        ApiConstants.logoutEndpoint,
        data: {'username': email, 'platform': 'mobile', 'password': '1234'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          'Logout failed with status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Logout API call failed',
      );
    } catch (e) {
      throw ServerException('Unexpected logout error');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await dio.get(ApiConstants.userProfileEndpoint);

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to get user profile');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized');
      } else if (e.response?.statusCode == 404) {
        throw ServerException('User not found');
      } else {
        throw ServerException(
          e.response?.data['message'] ?? 'Failed to get user profile',
        );
      }
    } catch (e) {
      throw ServerException('Unexpected error occurred');
    }
  }
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  final fcmDataSource = ref.read(fcmRemoteDataSourceProvider); //
  return AuthRemoteDataSourceImpl(dio, fcmDataSource);
});
