// lib/src/data/models/device_registration_model.dart
class DeviceRegistrationModel {
  final String userId;
  final String fcmToken;
  final String deviceId;
  final String deviceType;
  final String? deviceName;
  final String? osVersion;

  DeviceRegistrationModel({
    required this.userId,
    required this.fcmToken,
    required this.deviceId,
    required this.deviceType,
    this.deviceName,
    this.osVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fcmToken': fcmToken,
      'deviceId': deviceId,
      'deviceType': deviceType,
      if (deviceName != null) 'deviceName': deviceName,
      if (osVersion != null) 'osVersion': osVersion,
    };
  }

  factory DeviceRegistrationModel.fromJson(Map<String, dynamic> json) {
    return DeviceRegistrationModel(
      userId: json['userId'],
      fcmToken: json['fcmToken'],
      deviceId: json['deviceId'],
      deviceType: json['deviceType'],
      deviceName: json['deviceName'],
      osVersion: json['osVersion'],
    );
  }
}
