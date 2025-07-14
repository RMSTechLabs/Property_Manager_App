// lib/src/data/models/user_profile_response_model.dart


class UserProfileResponseModel {
  final bool success;
  final String message;
  final UserProfileDataModel data;
  final String timestamp;
  final int statusCode;

  UserProfileResponseModel({
    required this.success,
    required this.message,
    required this.data,
    required this.timestamp,
    required this.statusCode,
  });

  factory UserProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return UserProfileResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: UserProfileDataModel.fromJson(json['data'] ?? {}),
      timestamp: json['timestamp'] ?? '',
      statusCode: json['statusCode'] ?? 0,
    );
  }
}

class UserProfileDataModel {
  final String name;
  final String phone;
  final String? avatar;
  final List<PropertyDetailsModel> properties;
  final String appVersion;

  UserProfileDataModel({
    required this.name,
    required this.phone,
    this.avatar,
    required this.properties,
    required this.appVersion,
  });

  factory UserProfileDataModel.fromJson(Map<String, dynamic> json) {
    return UserProfileDataModel(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'],
      properties: (json['properties'] as List<dynamic>?)
          ?.map((property) => PropertyDetailsModel.fromJson(property))
          .toList() ?? [],
      appVersion: json['appVersion'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'avatar': avatar,
      'properties': properties.map((property) => property.toJson()).toList(),
      'appVersion': appVersion,
    };
  }
}

class PropertyDetailsModel {
  final int id;
  final String name;
  final String status;
  final String societyName;
  final String passcode;

  PropertyDetailsModel({
    required this.id,
    required this.name,
    required this.status,
    required this.societyName,
    required this.passcode,
  });

  factory PropertyDetailsModel.fromJson(Map<String, dynamic> json) {
    return PropertyDetailsModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      societyName: json['societyName'] ?? '',
      passcode: json['passcode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'societyName': societyName,
      'passcode': passcode,
    };
  }
}