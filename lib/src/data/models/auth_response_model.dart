// lib/src/data/models/auth_response_model.dart
import 'user_model.dart';

class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final String message;
  final bool success;
  final UserModel user;

  AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.message,
    required this.success,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'];
      print('🔍 Mapping AuthResponseModel from: $data');
      return AuthResponseModel(
        accessToken: data['token'] ?? data['access_token'] ?? '',
        refreshToken: data['refreshToken'] ?? data['refresh_token'] ?? '',
        user: UserModel.fromJson(data['user'] ?? {}),
        message: json['message'],
        success: json['success'],
      );
    } catch (e, stack) {
      print('❌ Error parsing AuthResponseModel: $e\n$stack');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toJson(),
      'success': success,
      'message': message,
    };
  }

  // Copy with method for immutability
  AuthResponseModel copyWith({
    String? accessToken,
    String? refreshToken,
    UserModel? user,
    String? message,
    bool? success,
  }) {
    return AuthResponseModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
      message: message ?? this.message,
      success: success ?? this.success,
    );
  }

  @override
  String toString() {
    return 'AuthResponseModel(accessToken: $accessToken, refreshToken: $refreshToken, user: $user, message: $message, success: $success)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthResponseModel &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.user == user &&
        other.message == message &&
        other.success;
  }

  @override
  int get hashCode {
    return accessToken.hashCode ^
        refreshToken.hashCode ^
        user.hashCode ^
        message.hashCode ^
        success.hashCode;
  }
}
